---
name: packaging-rust-cargo-projects
description: Use when packaging a Rust project with Cargo.toml, when an element needs cargo2 sources for offline builds, or when generating cargo dependency lists for BuildStream
---

# Packaging Rust/Cargo Projects

## Overview

Rust projects in this BuildStream repo use `kind: make` elements with `cargo2` sources for offline dependency vendoring. The element overrides `build-commands` to call `cargo build --release` directly. **Do NOT use `kind: cargo` elements or `kind: cargo` sources** -- they don't exist in this project's plugin set.

## When to Use

- Project has a `Cargo.toml` and builds with `cargo build`
- You need to package crate dependencies for offline BuildStream builds
- You're replacing an upstream binary with a Rust alternative (overlap-whitelist)
- You're generating cargo2 source lists from a Cargo.lock file

## Element Kind and Build Dependencies

**Always use `kind: make`** with these build-depends:

```yaml
kind: make

build-depends:
  - freedesktop-sdk.bst:components/rust.bst
  - freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
```

Both are required. `rust.bst` provides the Rust toolchain. `buildsystem-make.bst` provides the make build system that `kind: make` expects.

## Source Structure

A Rust element has two sources:

```yaml
sources:
  # 1. Project source (git_repo for tracked projects, tar for releases)
  - kind: git_repo
    url: github:<org>/<repo>.git
    track: <ref-or-tag-pattern>
    ref: <commit-or-tag-ref>

  # 2. Cargo dependencies (offline vendored crates)
  - kind: cargo2
    ref:
      # Registry crates (from crates.io)
      - kind: registry
        name: <crate-name>
        version: <version>
        sha: <sha256>

      # Git-hosted crates (from GitHub/GitLab repos, rare)
      - kind: git
        commit: <git-commit>
        repo: github:<org>/<repo>
        query:
          rev: <git-commit>
        name: <crate-name>
        version: <version>
```

**Critical:** The source kind is `cargo2`, NOT `cargo`. Each crate is listed under `ref:` with `kind: registry` (for crates.io) or `kind: git` (for git-hosted crates).

### Projects without Cargo.lock in repo

Some upstream projects don't commit their `Cargo.lock`. For these, add a `gen_cargo_lock` source between the git_repo and cargo2 sources:

```yaml
sources:
  - kind: git_repo
    url: github:<org>/<repo>.git
    track: <ref>
    ref: <ref>
  - kind: gen_cargo_lock
    ref: <base64-encoded-Cargo.lock-content>
  - kind: cargo2
    cargo-lock: Cargo.lock
    ref:
      - kind: registry
        ...
```

The `gen_cargo_lock` source generates the `Cargo.lock` file at source time. The `cargo2` source then references it with `cargo-lock: Cargo.lock`.

## Build and Install Commands

Override `build-commands` with a direct cargo invocation:

```yaml
config:
  build-commands:
    - cargo build --release

  install-commands:
    - install -Dm755 target/release/<binary> "%{install-root}/usr/bin/<binary>"
```

Add feature flags as needed:

```yaml
  build-commands:
    - cargo build --release --features feat_os_unix --no-default-features
```

### Install Patterns

**Simple binary:**
```yaml
  install-commands:
    - install -Dm755 target/release/<binary> "%{install-root}/usr/bin/<binary>"
```

**Setuid binary** (e.g., sudo-rs replacing sudo):
```yaml
  install-commands:
    - install -Dm4755 target/release/sudo "%{install-root}/usr/bin/sudo"
    - ln -sr "%{install-root}/usr/bin/sudo" "%{install-root}/usr/bin/sudoedit"
```

`-Dm4755` sets the setuid bit. Use this when the binary needs elevated privileges at runtime.

**Multi-call binary with symlinks** (e.g., uutils-coreutils):
```yaml
  install-commands:
    - install -Dm755 target/release/coreutils "%{install-root}/usr/bin/uutils-coreutils"
    - |
      for prog in $(target/release/coreutils --help | grep -E '^  [a-z]+' | awk '{print $1}'); do
        ln -sr "%{install-root}/usr/bin/uutils-coreutils" "%{install-root}/usr/bin/uutils-${prog}"
      done
```

**Custom make targets** (e.g., bootc with man pages, systemd units):
```yaml
variables:
  make-install-args: >-
    PREFIX="%{prefix}" LIBDIR="%{lib}" DESTDIR="%{install-root}" install-all
```

This uses `kind: make`'s built-in install mechanism instead of custom `install-commands`.

## Replacing Upstream Binaries (overlap-whitelist)

When your Rust binary intentionally replaces a file from an upstream dependency (e.g., sudo-rs replacing GNU sudo), declare the overlap:

```yaml
public:
  bst:
    overlap-whitelist:
      - /usr/bin/sudo
      - /usr/bin/sudoedit
```

Without this, BuildStream will error on overlapping files during layer composition.

## Generating cargo2 Source Lists

The helper script `files/scripts/generate_cargo_sources.py` reads a `Cargo.lock` and outputs the `cargo2` source YAML:

```bash
# Clone the project, then:
python3 files/scripts/generate_cargo_sources.py path/to/Cargo.lock
```

This outputs registry crate entries. **Note:** The script does NOT handle git-hosted crates -- add `kind: git` entries manually by inspecting the `Cargo.lock` for `source = "git+https://..."` entries.

For git-hosted crates, the format is:
```yaml
- kind: git
  commit: <the-git-commit-from-Cargo.lock>
  repo: github:<org>/<repo>
  query:
    rev: <same-git-commit>
  name: <crate-name>
  version: <version-from-Cargo.lock>
```

## Element Template

```yaml
kind: make

build-depends:
  - freedesktop-sdk.bst:components/rust.bst
  - freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
  # Add other build-time deps (e.g., linux-pam, systemd, openssl)

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
  # Add runtime deps

config:
  build-commands:
    - cargo build --release

  install-commands:
    - install -Dm755 target/release/<binary> "%{install-root}/usr/bin/<binary>"

sources:
  - kind: git_repo
    url: github:<org>/<repo>.git
    track: <commit-or-tag>
    ref: <commit-or-tag>
  - kind: cargo2
    ref:
      - kind: registry
        name: <crate>
        version: <version>
        sha: <sha256>
      # ... more crates
```

## Dependency Tracking

| Element | Location | Tracked By | Group |
|---|---|---|---|
| bootc | `elements/core/bootc.bst` | `bst source track` workflow | manual-merge |
| sudo-rs | `elements/bluefin/sudo-rs.bst` | **Not tracked** | -- |
| uutils-coreutils | `elements/bluefin/uutils-coreutils.bst` | **Not tracked** | -- |

Elements in the `bst source track` workflow get automatic PRs when upstream refs change. Elements not tracked require manual version bumps.

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Using `kind: cargo` element | Element kind not found / wrong build behavior | Use `kind: make` and override `build-commands` |
| Using `kind: cargo` source | Source kind not found | Use `kind: cargo2` |
| Manual `cargo vendor` approach | Doesn't work in BuildStream's offline sandbox | Use `cargo2` source kind -- it handles vendoring |
| Missing `buildsystem-make.bst` build-dep | Make-related errors during build | Add `freedesktop-sdk.bst:public-stacks/buildsystem-make.bst` |
| Missing `rust.bst` build-dep | `cargo` command not found | Add `freedesktop-sdk.bst:components/rust.bst` |
| Wrong install permissions for setuid | Binary doesn't have elevated privileges | Use `-Dm4755` not `-Dm755` for setuid binaries |
| Missing `overlap-whitelist` | Build fails with overlap error during layer composition | Add `public.bst.overlap-whitelist` listing conflicting paths |
| Forgetting git crates in cargo2 | Build fails with unresolved dependency | Check Cargo.lock for `git+https://` sources, add `kind: git` entries |

## Real Examples

- **Simple binary with setuid:** `elements/bluefin/sudo-rs.bst` (41 lines)
- **Multi-call binary with symlinks:** `elements/bluefin/uutils-coreutils.bst` (~1583 lines, mostly cargo2 deps)
- **Complex with git crates:** `elements/core/bootc.bst` (~1358 lines, includes `kind: git` cargo2 entries)
- **gen_cargo_lock pattern:** `gnomeos-deps/zram-generator.bst` (in gnome-build-meta junction)
