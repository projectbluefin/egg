---
name: buildstream-element-reference
description: Use when writing, editing, or reviewing BuildStream .bst element files — provides variable names, element kinds, source kinds, command hooks, systemd paths, and layer structure
---

# BuildStream Element Reference

Quick-reference for authoring `.bst` elements in the bluefin-egg project. Look up variables, element kinds, source kinds, and common patterns here. For packaging workflows, see the `packaging-pre-built-binaries` skill.

## Variables

| Variable | Expands To | Notes |
|----------|-----------|-------|
| `%{install-root}` | Staging directory | Always prefix install paths with this |
| `%{prefix}` | `/usr` | |
| `%{bindir}` | `/usr/bin` | |
| `%{indep-libdir}` | `/usr/lib` | For systemd units, presets, sysusers, tmpfiles |
| `%{datadir}` | `/usr/share` | |
| `%{sysconfdir}` | `/etc` | Rarely used in GNOME OS elements |
| `%{install-extra}` | Empty hook | Convention: always end install-commands with this |
| `%{go-arch}` | `amd64`/`arm64`/`riscv64` | Defined in project.conf per-arch |
| `%{arch}` | `x86_64`/`aarch64`/`riscv64` | Raw architecture name |
| `strip-binaries` | Set to `""` to disable | Required for non-ELF elements (fonts, configs, pre-built) |
| `overlap-whitelist` | `public: bst: overlap-whitelist:` | List of paths allowed to overlap between elements. Declared under `public:` block |

## Element Kinds

| Kind | Use Case | Examples |
|------|----------|---------|
| `manual` | Custom build/install, pre-built binaries, config files | brew, brew-tarball, tailscale-x86_64, jetbrains-mono |
| `meson` | GNOME libraries/apps | gsconnect, ptyxis |
| `make` | Makefile projects, Go with vendored deps | podman, skopeo |
| `autotools` | Legacy C projects | grub, firewalld, openvpn |
| `make` + `cargo2` | Rust projects (actual pattern used) | just, bpftop, virtiofsd, bootc. See `packaging-rust-cargo-projects` |
| `cmake` | CMake projects | fish |
| `import` | Direct file placement (no build) | systemd-presets |
| `stack` | Dependency aggregation, arch dispatch | deps.bst, tailscale.bst |
| `compose` | Layer filtering (exclude debug/devel) | bluefin-runtime.bst |
| `script` | OCI image assembly | oci/bluefin.bst |
| `collect_initial_scripts` | Collect systemd preset/sysusers/tmpfiles from deps | oci/layers/bluefin-stack.bst (gnome-build-meta plugin) |

## Source Kinds

| Source Kind | Use Case | Examples |
|-------------|----------|---------|
| `git_repo` | Most elements | brew, common, jetbrains-mono |
| `tar` | Release tarballs | tailscale-x86_64, wallpapers |
| `remote` | Single file download (not extracted) | brew-tarball, ghostty deps. Use `directory:` to place into a subdirectory (critical for Zig offline builds) |
| `local` | Files from repo's `files/` directory | plymouth-bluefin-theme |
| `cargo2` | Rust crate vendoring | bootc, just. Generate with `files/scripts/generate_cargo_sources.py` from Cargo.lock |
| `go_module` | Go module deps (one per dep) | git-lfs (in freedesktop-sdk) |
| `git_module` | Git submodule checkout | common (bluefin-branding) |
| `patch_queue` | Apply patches directory | toolbox |
| `gen_cargo_lock` | Generate Cargo.lock from base64 | zram-generator |

## Command Hooks

| Syntax | Meaning |
|--------|---------|
| `(>):` | Append to inherited command list from element kind |
| `(<):` | Prepend to inherited command list |
| `(@):` | Include a YAML file (like `rust-stage1-common.yml`) |
| `(?):` | Conditional block (evaluates options like `arch`) |

Convention: always end `install-commands` with `%{install-extra}` so downstream elements can extend.

## Multi-Arch Dispatcher Pattern

BuildStream does NOT support variable substitution in source URLs. When a source URL contains an architecture string (like `amd64` or `arm64`), you cannot use `%{go-arch}`. Instead, create per-arch elements and a dispatcher:

```yaml
# tailscale.bst (dispatcher)
kind: stack
(?):
- arch == "x86_64":
    depends:
      - bluefin/tailscale-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/tailscale-aarch64.bst
```

Each per-arch element has its own source URL with the hardcoded architecture string. See the `packaging-pre-built-binaries` skill for the complete pattern.

## Zig Build Pattern

Zig projects use `kind: manual` with custom `zig build` commands and many `remote` sources with `directory:` for offline dependency resolution. See the `packaging-zig-projects` skill for the complete workflow.

## Layer Chain

How elements flow into the final OCI image:

```
element → deps.bst (stack)
  → bluefin-stack.bst (stack, adds gnomeos-stack)
    → bluefin-runtime.bst (compose, excludes devel/debug/static-blocklist)
      → oci/layers/bluefin.bst (compose, excludes debug/extra/static-blocklist)
        → oci/bluefin.bst (script, assembles OCI with parent gnomeos image)
```

To add a new package to the image: add it as a dependency of `elements/bluefin/deps.bst`.

## Systemd Integration Paths

| What | Install Path | Command Pattern |
|------|-------------|-----------------|
| Service files | `%{indep-libdir}/systemd/system/` | `install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system"` |
| User services | `%{indep-libdir}/systemd/user/` | Same pattern with `/user/` |
| System presets | `%{indep-libdir}/systemd/system-preset/` | `install -Dm644 ... 80-<name>.preset` |
| User presets | `%{indep-libdir}/systemd/user-preset/` | Same pattern |
| sysusers | `%{indep-libdir}/sysusers.d/` | `install -Dm644 -t ... sysusers.d` |
| tmpfiles | `%{indep-libdir}/tmpfiles.d/` | `install -Dm644 -t ... tmpfiles.d` |

## Go Packaging Approaches

Three patterns exist across the project (in upstream junctions):

1. **`make` + vendored deps in git submodule** — simplest when upstream vendors deps (podman, skopeo in freedesktop-sdk)
2. **`manual` + `go_module` sources per dep** — verbose; one `go_module` entry per dependency (git-lfs: 33 modules in freedesktop-sdk)
3. **`manual` + `go build` with vendored tar** — when deps are bundled in a tarball

See the `packaging-go-projects` skill for step-by-step packaging instructions and helper scripts.

## Source Aliases

Defined in `include/aliases.yml`. Key aliases for Bluefin elements:

| Alias | Expands To | Used For |
|-------|-----------|----------|
| `github:` | `https://github.com/` | git sources |
| `github_files:` | `https://github.com/` | tarballs, release downloads |
| `gnome:` | `https://gitlab.gnome.org/GNOME/` | GNOME git sources |
| `ghostty_deps:` | `https://deps.files.ghostty.org/` | Ghostty dependency files |
| `ghostty_releases:` | `https://release.files.ghostty.org/` | Ghostty release tarballs |

**Important:** Variable substitution (`%{go-arch}`, etc.) does NOT work in source URLs. Use the multi-arch dispatcher pattern instead.
