default: build

# oci/bluefin.bst
image_name := env("BUILD_IMAGE_NAME", "bluefin-distroless")
image_tag := env("BUILD_IMAGE_TAG", "latest")
base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "btrfs")

build *ARGS:
    #!/usr/bin/env bash
    set -eu

    bst build oci/bluefin.bst
    bst artifact checkout --tar - oci/bluefin.bst | run0 podman load

build-containerfile $image_name=image_name:
    sudo podman build --squash-all -t "${image_name}:latest" .

bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 30G "${base_dir}/bootable.img"
    fi

    just bootc install to-disk --composefs-backend \
        --via-loopback /data/bootable.img \
        --filesystem "${filesystem}" \
        --wipe \
        --bootloader systemd \
        --karg systemd.firstboot=no \
        --karg splash \
        --karg quiet \
        --karg console=tty0 \
        --karg systemd.debug_shell=ttyS1
