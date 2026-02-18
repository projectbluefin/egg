# List available commands
[group('info')]
default:
    @just --list

# ── Configuration ─────────────────────────────────────────────────────
export image_name := env("BUILD_IMAGE_NAME", "egg")
export image_tag := env("BUILD_IMAGE_TAG", "latest")
export base_dir := env("BUILD_BASE_DIR", ".")
export filesystem := env("BUILD_FILESYSTEM", "btrfs")

# Same bst2 container image CI uses -- pinned by SHA for reproducibility
export bst2_image := env("BST2_IMAGE", "registry.gitlab.com/freedesktop-sdk/infrastructure/freedesktop-sdk-docker-images/bst2:f89b4aef847ef040b345acceda15a850219eb8f1")

# VM settings
export vm_ram := env("VM_RAM", "8192")
export vm_cpus := env("VM_CPUS", "4")

# OCI metadata (dynamic labels)
export OCI_IMAGE_CREATED := env("OCI_IMAGE_CREATED", "")
export OCI_IMAGE_REVISION := env("OCI_IMAGE_REVISION", "")
export OCI_IMAGE_VERSION := env("OCI_IMAGE_VERSION", "latest")

# ── BuildStream wrapper ──────────────────────────────────────────────
# Runs any bst command inside the bst2 container via podman.
# Set BST_FLAGS env var to prepend flags (e.g. --no-interactive --config ...).
# Usage: just bst build oci/bluefin.bst
#        just bst show oci/bluefin.bst
#        BST_FLAGS="--no-interactive" just bst build oci/bluefin.bst
[group('dev')]
bst *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "${HOME}/.cache/buildstream"
    # BST_FLAGS env var allows CI to inject --no-interactive, --config, etc.
    # Word-splitting is intentional here (flags are space-separated).
    # shellcheck disable=SC2086
    podman run --rm \
        --privileged \
        --device /dev/fuse \
        --network=host \
        -v "{{justfile_directory()}}:/src:rw" \
        -v "${HOME}/.cache/buildstream:/root/.cache/buildstream:rw" \
        -w /src \
        "{{bst2_image}}" \
        bash -c 'ulimit -n 1048576 || true; bst --colors "$@"' -- ${BST_FLAGS:-} {{ARGS}}

# ── Build ─────────────────────────────────────────────────────────────
# Build the OCI image and load it into podman.
[group('build')]
build:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "==> Building OCI image with BuildStream (inside bst2 container)..."
    just bst build oci/bluefin.bst

    just export

# ── Export ─────────────────────────────────────────────────────────────
# Checkout the built OCI image from BuildStream and load it into podman.
# Assumes `bst build oci/bluefin.bst` has already completed.
# Used by: `just build` (after building) and CI (as a separate step).
#
# Uses SUDO_CMD to handle root vs non-root: CI runs as root (no sudo),
# local dev needs sudo for podman access to containers-storage.
[group('build')]
export:
    #!/usr/bin/env bash
    set -euo pipefail

    # Use sudo unless already root (CI runners are root)
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi

    echo "==> Exporting OCI image..."
    rm -rf .build-out
    just bst artifact checkout oci/bluefin.bst --directory /src/.build-out

    # Load the multi-layer OCI image and squash into a single layer.
    # BuildStream produces separate layers (platform + gnomeos + bluefin);
    # bootc and registry distribution work better with one squashed layer.
    # Using podman (not skopeo) ensures the squashed view is preserved on push.
    echo "==> Loading and squashing OCI image..."
    IMAGE_ID=$($SUDO_CMD podman pull -q oci:.build-out)
    rm -rf .build-out
    
    # Build label arguments for dynamic OCI metadata
    LABEL_ARGS=""
    if [ -n "${OCI_IMAGE_CREATED}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.created=${OCI_IMAGE_CREATED}"
    fi
    if [ -n "${OCI_IMAGE_REVISION}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.revision=${OCI_IMAGE_REVISION}"
    fi
    if [ -n "${OCI_IMAGE_VERSION}" ]; then
        LABEL_ARGS="${LABEL_ARGS} --label org.opencontainers.image.version=${OCI_IMAGE_VERSION}"
    fi
    
    # Squash and apply dynamic labels
    # shellcheck disable=SC2086
    printf 'FROM %s\n' "$IMAGE_ID" \
        | $SUDO_CMD podman build --pull=never --security-opt label=type:unconfined_t --squash-all ${LABEL_ARGS} -t "{{image_name}}:{{image_tag}}" -f - .
    $SUDO_CMD podman rmi "$IMAGE_ID" || true

    echo "==> Export complete. Image loaded as {{image_name}}:{{image_tag}}"
    $SUDO_CMD podman images | grep -E "{{image_name}}|REPOSITORY" || true

    # Step: Chunkify (reorganize layers)
    just chunkify "{{image_name}}:{{image_tag}}"

# ── Clean ─────────────────────────────────────────────────────────────
# Remove generated artifacts (disk image, OVMF vars, build output).
[group('build')]
clean:
    rm -f bootable.raw .ovmf-vars.fd
    rm -rf .build-out

# ── Containerfile build (alternative) ────────────────────────────────
[group('build')]
build-containerfile $image_name=image_name:
    sudo podman build --security-opt label=type:unconfined_t --squash-all -t "${image_name}:latest" .

# ── bootc helper ─────────────────────────────────────────────────────
[group('dev')]
bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

# ── Generate bootable disk image ─────────────────────────────────────
[group('test')]
generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    set -euo pipefail

    if ! sudo podman image exists "{{image_name}}:{{image_tag}}"; then
        echo "ERROR: Image '{{image_name}}:{{image_tag}}' not found in podman." >&2
        echo "Run 'just build' first to build and export the OCI image." >&2
        exit 1
    fi

    if [ ! -e "${base_dir}/bootable.raw" ] ; then
        echo "==> Creating 30G sparse disk image..."
        fallocate -l 30G "${base_dir}/bootable.raw"
    fi

    echo "==> Installing OS to disk image via bootc..."
    just bootc install to-disk \
        --via-loopback /data/bootable.raw \
        --filesystem "${filesystem}" \
        --wipe \
        --composefs-backend \
        --bootloader systemd \
        --karg systemd.firstboot=no \
        --karg splash \
        --karg quiet \
        --karg console=tty0 \
        --karg systemd.debug_shell=ttyS1

    echo "==> Bootable disk image ready: ${base_dir}/bootable.raw"

# ── Boot VM ───────────────────────────────────────────────────────────
# Boot the raw disk image in QEMU with UEFI (OVMF).
# Requires: qemu-system-x86_64, OVMF firmware, KVM access
[group('test')]
boot-vm $base_dir=base_dir:
    #!/usr/bin/env bash
    set -euo pipefail

    DISK="${base_dir}/bootable.raw"
    if [ ! -e "$DISK" ]; then
        echo "ERROR: ${DISK} not found. Run 'just generate-bootable-image' first." >&2
        exit 1
    fi

    # Auto-detect OVMF firmware paths
    OVMF_CODE=""
    for candidate in \
        /usr/share/edk2/ovmf/OVMF_CODE.fd \
        /usr/share/OVMF/OVMF_CODE.fd \
        /usr/share/OVMF/OVMF_CODE_4M.fd \
        /usr/share/edk2/x64/OVMF_CODE.4m.fd \
        /usr/share/qemu/OVMF_CODE.fd; do
        if [ -f "$candidate" ]; then
            OVMF_CODE="$candidate"
            break
        fi
    done
    if [ -z "$OVMF_CODE" ]; then
        echo "ERROR: OVMF firmware not found. Install edk2-ovmf (Fedora) or ovmf (Debian/Ubuntu)." >&2
        exit 1
    fi

    # OVMF_VARS must be writable -- use a local copy
    OVMF_VARS="${base_dir}/.ovmf-vars.fd"
    if [ ! -e "$OVMF_VARS" ]; then
        OVMF_VARS_SRC=""
        for candidate in \
            /usr/share/edk2/ovmf/OVMF_VARS.fd \
            /usr/share/OVMF/OVMF_VARS.fd \
            /usr/share/OVMF/OVMF_VARS_4M.fd \
            /usr/share/edk2/x64/OVMF_VARS.4m.fd \
            /usr/share/qemu/OVMF_VARS.fd; do
            if [ -f "$candidate" ]; then
                OVMF_VARS_SRC="$candidate"
                break
            fi
        done
        if [ -z "$OVMF_VARS_SRC" ]; then
            echo "ERROR: OVMF_VARS not found alongside OVMF_CODE." >&2
            exit 1
        fi
        cp "$OVMF_VARS_SRC" "$OVMF_VARS"
    fi

    echo "==> Booting ${DISK} in QEMU (UEFI, KVM)..."
    echo "    Firmware: ${OVMF_CODE}"
    echo "    RAM: {{vm_ram}}M, CPUs: {{vm_cpus}}"
    echo "    Serial debug shell on ttyS1 available via QEMU monitor"
    echo ""

    qemu-system-x86_64 \
        -enable-kvm \
        -m "{{vm_ram}}" \
        -cpu host \
        -smp "{{vm_cpus}}" \
        -drive file="${DISK}",format=raw,if=virtio \
        -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
        -drive if=pflash,format=raw,file="${OVMF_VARS}" \
        -device virtio-vga \
        -display gtk \
        -device virtio-keyboard \
        -device virtio-mouse \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -chardev stdio,id=char0,mux=on,signal=off \
        -serial chardev:char0 \
        -serial chardev:char0 \
        -mon chardev=char0

# ── Show me the future ────────────────────────────────────────────────
# The full end-to-end: build the OCI image, install it to a bootable
# disk, and launch it in a QEMU VM. One command to rule them all.
# Uses charm.sh gum for styled output when available.
[group('test')]
show-me-the-future:
    #!/usr/bin/env bash
    set -euo pipefail

    # ── Helpers ───────────────────────────────────────────────────
    HAS_GUM=false
    command -v gum &>/dev/null && [[ -t 1 ]] && HAS_GUM=true

    OVERALL_START=$SECONDS

    format_time() {
        local secs=$1
        if (( secs >= 3600 )); then
            printf '%dh %02dm %02ds' $((secs / 3600)) $(((secs % 3600) / 60)) $((secs % 60))
        elif (( secs >= 60 )); then
            printf '%dm %02ds' $((secs / 60)) $((secs % 60))
        else
            printf '%ds' "$secs"
        fi
    }

    step_start() {
        local name=$1
        if $HAS_GUM; then
            gum style --foreground 212 --bold "◔ ${name}..."
        else
            echo "==> ${name}..."
        fi
    }

    step_done() {
        local name=$1 elapsed=$2
        if $HAS_GUM; then
            gum style --foreground 46 "● ${name} ($(format_time "$elapsed"))"
        else
            echo "==> ${name} done ($(format_time "$elapsed"))"
        fi
    }

    step_failed() {
        local name=$1 elapsed=$2
        if $HAS_GUM; then
            gum style --foreground 196 "◍ ${name} FAILED ($(format_time "$elapsed"))"
        else
            echo "==> ${name} FAILED ($(format_time "$elapsed"))"
        fi
    }

    run_step() {
        local name=$1; shift
        step_start "$name"
        local start=$SECONDS
        if "$@"; then
            step_done "$name" $((SECONDS - start))
        else
            step_failed "$name" $((SECONDS - start))
            echo ""
            if $HAS_GUM; then
                gum style --foreground 196 --border rounded --align center --padding "1 2" \
                    'BUILD FAILED' \
                    "Failed: ${name}" \
                    "Total elapsed: $(format_time $((SECONDS - OVERALL_START)))"
            else
                echo "BUILD FAILED: ${name}"
                echo "Total elapsed: $(format_time $((SECONDS - OVERALL_START)))"
            fi
            exit 1
        fi
    }

    # ── Banner ────────────────────────────────────────────────────
    if $HAS_GUM; then
        TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
        BANNER_WIDTH=$((TERM_WIDTH > 62 ? 60 : TERM_WIDTH - 4))
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --border double \
            --align center \
            --width $BANNER_WIDTH \
            --margin "1 2" \
            --padding "1 4" \
            'SHOW ME THE FUTURE' \
            'Building Bluefin from source and booting it in a VM'
    else
        echo ""
        echo "=== SHOW ME THE FUTURE ==="
        echo "Building Bluefin from source and booting it in a VM"
    fi
    echo ""

    # ── Steps ─────────────────────────────────────────────────────
    run_step "Build OCI image" just build
    echo ""
    run_step "Bootable disk" just generate-bootable-image
    echo ""

    # Step 3: VM is interactive -- just announce it
    step_start "Launch VM"
    just boot-vm
    echo ""

    # ── Completion ────────────────────────────────────────────────
    if $HAS_GUM; then
        gum style --foreground 46 "● Launch VM"
        echo ""
        gum style \
            --foreground 46 \
            --border-foreground 46 \
            --border rounded \
            --align center \
            --width 42 \
            --padding "1 2" \
            'ALL STEPS COMPLETE' \
            "Total: $(format_time $((SECONDS - OVERALL_START)))"
    else
        echo "==> All steps complete. Total: $(format_time $((SECONDS - OVERALL_START)))"
    fi

# ── Chunkah ──────────────────────────────────────────────────────────
build-chunkah-tool:
    #!/usr/bin/env bash
    set -euo pipefail
    
    # Use sudo unless already root (CI runners are root)
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi

    if [ ! -d "chunkah" ]; then
        git clone https://github.com/coreos/chunkah.git
    fi
    $SUDO_CMD podman build --security-opt label=type:unconfined_t --build-arg FINAL_FROM=rootfs -t chunkah-tool chunkah/

chunkify image_ref: build-chunkah-tool
    #!/usr/bin/env bash
    set -euo pipefail

    # Use sudo unless already root (CI runners are root)
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi

    echo "==> Chunkifying {{image_ref}}..."
    
    # Get config from existing image
    CONFIG=$($SUDO_CMD podman inspect "{{image_ref}}")
    
    # Run chunkah (default 64 layers) and pipe to podman load
    # Uses --mount=type=image to expose the source image content to chunkah
    # Note: We need --privileged for some podman-in-podman/mount scenarios or just standard access
    LOADED=$($SUDO_CMD podman run --rm \
        --security-opt label=type:unconfined_t \
        --mount=type=image,src="{{image_ref}}",dest=/chunkah \
        -e "CHUNKAH_CONFIG_STR=$CONFIG" \
        chunkah-tool build | $SUDO_CMD podman load)
    
    echo "$LOADED"
    
    # Parse the loaded image reference
    NEW_REF=$(echo "$LOADED" | grep -oP '(?<=Loaded image: ).*' || \
              echo "$LOADED" | grep -oP '(?<=Loaded image\(s\): ).*')
    
    if [ -n "$NEW_REF" ] && [ "$NEW_REF" != "{{image_ref}}" ]; then
        echo "==> Retagging chunked image to {{image_ref}}..."
        $SUDO_CMD podman tag "$NEW_REF" "{{image_ref}}"
    fi

# ── Lint ─────────────────────────────────────────────────────────────
[group('test')]
lint:
    #!/usr/bin/env bash
    set -euo pipefail

    # Use sudo unless already root
    SUDO_CMD=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO_CMD="sudo"
    fi

    echo "==> Linting {{image_name}}:{{image_tag}} with bootc container lint..."
    $SUDO_CMD podman run --rm --privileged --pull=never \
        "{{image_name}}:{{image_tag}}" \
        bootc container lint
