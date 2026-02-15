---
name: packaging-pre-built-binaries
description: Use when packaging a project that provides official pre-built static binaries, when building from source is impractical, or when you need a bootstrap compiler
---

# Packaging Pre-Built Binaries

## When to Use

- Project provides official static binary releases (GitHub Releases, vendor CDN)
- Building from source is impractical (huge dep trees, incompatible toolchains)
- You need a bootstrap compiler (like `rust-stage1`)

## Required Settings

Every pre-built binary element MUST have these:

| Setting | Why |
|---|---|
| `variables: strip-binaries: ""` | Pre-built binaries aren't ELF from our toolchain. Without this, build fails during strip phase. |
| `build-depends: freedesktop-sdk.bst:public-stacks/runtime-minimal.bst` | Provides `install`, `sed`, and other basic tools needed by install-commands. |

## Single-Arch Template

Use when the project only targets one architecture or you're writing the per-arch element file.

```yaml
kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar  # or 'remote' for single files
    url: github_files:org/repo/releases/download/vX.Y.Z/package_X.Y.Z_arch.tgz
    ref: <sha256>

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" binary1 binary2
    - |
      # Install systemd service (if applicable)
      install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" path/to/service.service
    - |
      # Install systemd preset to enable the service
      install -Dm644 /dev/stdin "%{install-root}%{indep-libdir}/systemd/system-preset/80-name.preset" <<'PRESET'
      enable service-name.service
      PRESET
    - |
      %{install-extra}
```

## Multi-Arch Pattern

Binary tarball URLs almost always differ per architecture. BuildStream does NOT support variable substitution in `sources:` URLs or `(?):` conditionals on `sources:` blocks. The only option is a multi-arch dispatcher.

**Create these files:**

1. **Per-arch elements** -- each with its own source URL and SHA256:
   - `elements/bluefin/package-x86_64.bst`
   - `elements/bluefin/package-aarch64.bst`

2. **Stack dispatcher** (`elements/bluefin/package.bst`):

```yaml
kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/package-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/package-aarch64.bst
```

The dispatcher is what other elements depend on. It selects the correct arch-specific element at build time.

## Systemd Service Patching for GNOME OS

Upstream service files often need patching for GNOME OS:

- **`/usr/sbin/` -> `/usr/bin/`** -- GNOME OS uses merged-usr; everything lives in `/usr/bin`
- **Remove `EnvironmentFile=/etc/default/...`** -- GNOME OS doesn't use `/etc/default/`
- **Enable via preset, NOT `systemctl enable`** -- presets are declarative and sandbox-safe

Patching pattern:

```bash
sed -e 's|/usr/sbin/|/usr/bin/|g' \
    -e '/^EnvironmentFile=/d' \
    upstream.service > patched.service
install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" patched.service
```

Preset pattern:

```bash
install -Dm644 /dev/stdin "%{install-root}%{indep-libdir}/systemd/system-preset/80-name.preset" <<'PRESET'
enable service-name.service
PRESET
```

## Source URL Patterns

- **GitHub Releases:** Use the existing `github_files:` alias -- e.g., `github_files:org/repo/releases/download/vX.Y.Z/file.tgz`
- **Other domains:** Add a new alias to `include/aliases.yml` under the `# file aliases` section
- **SHA256 checksums:** Many projects publish `.sha256` files alongside releases: `curl -sL <url>.sha256`

## Real Example: Tailscale

Tailscale v1.94.2 is packaged as pre-built static binaries for x86_64 and aarch64.

**Files:**
- `elements/bluefin/tailscale-x86_64.bst` -- amd64 tarball
- `elements/bluefin/tailscale-aarch64.bst` -- arm64 tarball
- `elements/bluefin/tailscale.bst` -- stack dispatcher

**Key decisions:**
- Used `github_files:` alias (Tailscale publishes to GitHub Releases)
- Patched service file: `/usr/sbin/` -> `/usr/bin/`, removed `EnvironmentFile=`
- Added `80-tailscale.preset` to enable `tailscaled.service`
- Set `strip-binaries: ""` (pre-built Go static binaries)

**Per-arch element** (`tailscale-x86_64.bst`):

```yaml
kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:tailscale/tailscale/releases/download/v1.94.2/tailscale_1.94.2_amd64.tgz
    ref: c6f99a5d774c7783b56902188d69e9756fc3dddfb08ac6be4cb2585f3fecdc32

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" tailscale tailscaled
    - |
      sed -e 's|/usr/sbin/tailscaled|/usr/bin/tailscaled|g' \
          -e '/^EnvironmentFile=/d' \
          systemd/tailscaled.service > tailscaled.service.patched
      install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" tailscaled.service.patched
      mv "%{install-root}%{indep-libdir}/systemd/system/tailscaled.service.patched" \
         "%{install-root}%{indep-libdir}/systemd/system/tailscaled.service"
    - |
      install -Dm644 /dev/stdin "%{install-root}%{indep-libdir}/systemd/system-preset/80-tailscale.preset" <<'PRESET'
      enable tailscaled.service
      PRESET
    - |
      %{install-extra}
```

## Other Examples

**Zig SDK** (`bluefin/zig.bst`): The Zig compiler is downloaded as a pre-built tarball and used as a build dependency for Zig projects like Ghostty. It follows the same pattern — `kind: manual`, `strip-binaries: ""`, tar source with SHA256 ref. It's a bootstrap compiler, not a runtime package.

## Dependency Tracking

Pre-built binaries like Tailscale and Zig are **NOT tracked by any automated dependency update mechanism** (Renovate, `bst source track`, etc.). Updates are entirely manual:

1. Check upstream for a new release
2. Bump the version in the source URL
3. Update the SHA256 `ref`
4. Test the build (`bst build elements/bluefin/<package>.bst`)

This is a known gap. When working on pre-built binary elements, always check whether the pinned version is current.

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Forget `strip-binaries: ""` | Build fails during strip phase | Add `variables: strip-binaries: ""` |
| Use `/usr/sbin` in paths | Binary not found at runtime | Always use `%{bindir}` (`/usr/bin`) |
| Use `EnvironmentFile=/etc/default/` | Service fails to start | Remove directive, inline defaults |
| Use variables in source URLs | YAML parse error or wrong URL | Use multi-arch dispatcher pattern |
| Forget `%{install-extra}` | Breaks extensibility convention | Always end install-commands with it |
| Wrong `install` argument order | Files installed to wrong location | Use `-t DIR FILE` form for clarity |
| Forget preset file | Service not enabled on boot | Add `80-<name>.preset` with `enable` |

## Related Skills

- **`updating-upstream-refs`** — For the version bump workflow when updating pre-built binary versions. Covers tracking refs, testing builds, and validating changes.
