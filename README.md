# Bluefin
*Dakotaraptor steini*

[Bluefin's](https://projectbluefin.io) final form. 

> How dare you.
>
> -- John Bazzite

`projectbluefin/dakota` is built on [GNOME OS](https://os.gnome.org/) using [BuildStream](https://buildstream.build/). This is a prototype and not ready and may bite.

![Dakorator](https://github.com/user-attachments/assets/ee92291d-a617-496e-abb6-9045a4c665ce)

## Status

- Consume GNOME nightly bootc image (done)
- Final assembly in this repo (done)

## Goals

- No dx image, everything in homebrew or sysexts

## Missing things

- Installation
- Ensuring upgrades and rollbacks work

## Get started
    git clone https://github.com/projectbluefin/dakota.git
    cd dakota
    just show-me-the-future

## Trying it: 

1. Clone this repo
2. `just show-me-the-future`
3. VM with Bluefin built on GNOME OS!
4. WIP: Pushing to a locally run registry for super fast development!
   - But also means a Dakotaraptor system can build and host itself. On a fast machine this can take about 2 minutes once the initial caching is complete!  

## Make It Yours

1. **Fork this repo** and clone your fork
2. **Edit the package list** in `elements/bluefin/deps.bst` -- add or remove lines to customize what ships in your image
3. **Build and boot:**
   ```
   just show-me-the-future
   ```

That's it. The first build takes about an hour (it pulls cached artifacts from GNOME's upstream servers). After that, rebuilds only touch what changed.

## Prerequisites

You need [podman](https://podman.io/docs/installation), [just](https://just.systems/man/en/packages.html)

**(WIP)** `just preflight` -- a preflight check that validates your setup and auto-installs missing tools (like QEMU) via [Homebrew](https://brew.sh), reducing hard prerequisites to just `podman` and `just`.

## How It Works

[BuildStream](https://buildstream.build/) resolves a dependency graph rooted at `elements/oci/bluefin.bst`, pulls pre-built artifacts from GNOME's public cache, builds anything that's missing, and produces a bootable OCI container image. The image is installed to a virtual disk and booted in QEMU.

All build artifacts are cached locally in `~/.cache/buildstream/`. There is no cloud dependency beyond the initial artifact fetch from GNOME's servers. Your laptop is the build farm.

### Disk Space

| What | Size |
|---|---|
| Build cache (after first build) | ~50 GB |
| Bootable VM disk | 30 GB (sparse) |
| Total recommended free | **100 GB** |

### Step-by-Step Commands

If you prefer more control over each step:

```bash
just build                     # Build the OCI image (~1 hour first time, minutes after)
just generate-bootable-image   # Create a bootable disk from the image
just boot-vm                   # Launch QEMU VM -- a GNOME desktop appears
```

### Iterative Development

After the first build, the edit-rebuild-boot cycle is fast:

```bash
# 1. Edit elements/bluefin/deps.bst (or any element)
# 2. Rebuild -- only changed elements are rebuilt
just build
# 3. Regenerate the disk and boot
just generate-bootable-image
just boot-vm
```

**(WIP)** Local OTA updates -- push rebuilt images to a local registry and update a running VM without rebooting the full pipeline:

```bash
just registry-start              # Start local OCI registry
just build && just publish       # Build and push to local registry
# In VM: sudo bootc upgrade      # Pull the update over the network
```

## Customizing Packages

The file `elements/bluefin/deps.bst` controls what ships in the image. Each line is a BuildStream element:

```yaml
depends:
  # GNOME Shell extensions
  - bluefin/gnome-shell-extensions.bst

  # CLI tools
  - bluefin/glow.bst
  - bluefin/gum.bst
  - bluefin/fzf.bst

  # Fonts
  - bluefin/jetbrains-mono.bst

  # ... add your own here
```

To **remove a package**: delete its line from `deps.bst`.

To **add a package**: create a `.bst` element in `elements/bluefin/` and add it to `deps.bst`. Look at existing elements like `elements/bluefin/glow.bst` for a simple example -- it downloads a pre-built binary and installs it to the right path.

Packages from the upstream [freedesktop-sdk](https://gitlab.com/freedesktop-sdk/freedesktop-sdk) and [gnome-build-meta](https://gitlab.gnome.org/GNOME/gnome-build-meta) projects can be included directly by referencing their junction path:

```yaml
  - freedesktop-sdk.bst:components/some-package.bst
  - gnome-build-meta.bst:gnomeos-deps/some-other-package.bst
```

## Project Structure

```
elements/
  bluefin/           Bluefin-specific packages (edit these)
    deps.bst         Master package list (start here)
  core/              Core system overrides (bootc, grub, ptyxis)
  oci/               Image assembly pipeline
    bluefin.bst      THE build target
  freedesktop-sdk.bst   Junction to freedesktop-sdk
  gnome-build-meta.bst  Junction to gnome-build-meta
files/               Static files (plymouth theme, etc.)
patches/             Patches applied to upstream projects
Justfile             All build commands
```

## Roadmap

These features are planned but not yet implemented:

- **`just preflight`** -- automated prerequisite checking with Homebrew auto-install
- **Local OTA updates** -- `just registry-start` / `just publish` for iterative VM updates via `bootc upgrade`
- **`just add-package <url>`** -- scaffolding a new package element from a GitHub release URL
- **Rebranding guide** -- documentation for people who want to change the image name/identity
- **Multi-arch builds** -- aarch64 support
