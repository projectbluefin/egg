# Agent Instructions

This repository builds **Bluefin** -- a custom GNOME-based Linux desktop image -- using [BuildStream 2](https://buildstream.build/). The output is a [bootc](https://containers.github.io/bootc/)-compatible OCI container image published to `ghcr.io/projectbluefin/egg`.

All AI-assisted development uses the [superpowers](https://github.com/jchook/superpowers) skill system.

## Quick Reference

| What | Where |
|---|---|
| Build target | `oci/bluefin.bst` |
| Local build | `just build` |
| CI workflow | `.github/workflows/build-egg.yml` |
| Published image | `ghcr.io/projectbluefin/egg:latest` |
| Upstream repo | `github.com/projectbluefin/egg` |
| Implementation plans | `docs/plans/` |
| BuildStream project config | `project.conf` |

## What This Project Is

Bluefin Egg is the "primal form" of [Project Bluefin](https://projectbluefin.io/) -- a full desktop OS image built from source using BuildStream. It layers Bluefin-specific packages (Homebrew, Plymouth theme, GNOME extensions, wallpapers, fonts) on top of a GNOME OS base image derived from [gnome-build-meta](https://gitlab.gnome.org/GNOME/gnome-build-meta) and [freedesktop-sdk](https://gitlab.com/freedesktop-sdk/freedesktop-sdk).

The build pipeline:
1. BuildStream resolves the dependency graph rooted at `oci/bluefin.bst`
2. It pulls cached artifacts from GNOME's upstream CAS and our R2 cache
3. Elements not in any cache are built from source inside bubblewrap sandboxes
4. The final output is an OCI image containing a bootable Linux filesystem
5. CI validates with `bootc container lint` and pushes to GHCR

## Repository Layout

```
.github/workflows/       CI/CD pipeline (GitHub Actions)
docs/plans/              Implementation plans (source of truth for decisions)
elements/                BuildStream element definitions (.bst files)
  bluefin/               Bluefin-specific packages (brew, fonts, extensions, etc.)
  core/                  Core system component overrides (bootc, grub, ptyxis, etc.)
  oci/                   OCI image assembly -- build targets live here
    bluefin.bst          THE primary build target
    gnomeos.bst          Base GNOME OS image (parent layer)
    layers/              Filesystem layers composed into the final image
  plugins/               BuildStream plugin junctions
  freedesktop-sdk.bst    Junction to freedesktop-sdk
  gnome-build-meta.bst   Junction to gnome-build-meta
files/                   Static files overlaid into the image (plymouth theme, etc.)
include/                 Shared YAML includes (source aliases)
patches/                 Patches applied to upstream junctions
  freedesktop-sdk/       Patches for freedesktop-sdk elements
  gnome-build-meta/      Patches for gnome-build-meta elements
project.conf             BuildStream project configuration
Justfile                 Local development commands
Containerfile            Minimal validation container (FROM egg:latest + lint)
```

## Build System

### BuildStream 2

[BuildStream](https://buildstream.build/) is a build orchestration tool that uses Content Addressable Storage (CAS) for deterministic, cacheable builds. Key concepts:

- **Elements** (`.bst` files): Define build steps -- source fetching, build commands, dependencies
- **Junctions**: References to external BuildStream projects (gnome-build-meta, freedesktop-sdk)
- **Artifacts**: Cached build outputs, identified by CAS hash
- **Sources**: Upstream tarballs, git repos, etc. -- cached separately from artifacts

### Building Locally

```bash
just build    # Runs bst build + exports OCI image via podman load
```

Requires BuildStream 2.5+ installed locally. The Justfile handles `bst build oci/bluefin.bst` followed by `bst artifact checkout --tar - | podman load`.

### project.conf

The project configuration defines:
- **Artifact caches**: GNOME's upstream CAS at `gbm.gnome.org:11003` (read-only)
- **Source caches**: Same GNOME endpoint for source mirrors
- **Plugins**: From buildstream-plugins, buildstream-plugins-community, and gnome-build-meta
- **Architecture options**: x86_64, aarch64, riscv64
- **Source ref format**: `git-describe`

**Important**: `project.conf` is shared between local dev and CI. CI-specific settings (like the R2 cache remote) are passed via CLI flags, NOT added to project.conf.

## CI/CD Pipeline

### Workflow: `.github/workflows/build-egg.yml`

Runs on `ubuntu-24.04`. Triggers on push to main, PRs against main, and manual dispatch.

**Architecture**: BuildStream runs inside GNOME's official `bst2` Docker image via podman. This container needs `--privileged` and `--device /dev/fuse` for bubblewrap sandboxing. The container is NOT the GitHub Actions `container:` directive -- it's invoked via `podman run` because the disk-space-reclamation action needs host filesystem access.

**Steps** (in order):
1. Free disk space (removes pre-installed SDKs -- essential, builds need >50 GB)
2. Checkout repository
3. Pull bst2 container image
4. Restore BuildStream source cache (`actions/cache`)
5. Start bazel-remote cache proxy (main branch only)
6. Generate CI-specific BuildStream config (`buildstream-ci.conf`)
7. Build `oci/bluefin.bst` inside bst2 container
8. Push artifacts to R2 cache (main branch only, non-fatal)
9. Export OCI image (`bst artifact checkout --tar - | podman load`)
10. Validate with `bootc container lint`
11. Upload build logs and cache proxy logs
12. Stop cache proxy
13. Tag and push to GHCR (main branch only)

### Artifact Caching

Two layers of artifact caching:

1. **GNOME upstream** (`gbm.gnome.org:11003`): Read-only. Configured in `project.conf`. Contains artifacts for freedesktop-sdk and gnome-build-meta elements. Available to all builds.

2. **Project R2 cache** (Cloudflare R2 via `bazel-remote`): Read-write. Only active on main-branch pushes. Stores artifacts for Bluefin-specific elements that aren't in GNOME's cache.

The R2 cache uses `bazel-remote` v2.6.1 as a CAS-to-S3 bridge:
- Runs on the GitHub Actions host (not inside the bst2 container)
- Exposes gRPC CAS on port 9092, HTTP status on port 8080
- The bst2 container reaches it via `--network=host`
- BuildStream pulls from it during build via `--artifact-remote=grpc://localhost:9092`
- A separate `bst artifact push` step uploads after a successful build
- Binary integrity verified via SHA256 checksum

**Secrets** (configured on projectbluefin/egg):
- `R2_ACCESS_KEY`: Cloudflare R2 access key ID
- `R2_SECRET_KEY`: Cloudflare R2 secret access key
- `R2_ENDPOINT`: R2 S3-compatible endpoint (`https://<ACCOUNT_ID>.r2.cloudflarestorage.com`)
- R2 bucket name: `bst-cache` (hardcoded in workflow)

### CI Config Rationale

The `buildstream-ci.conf` generated during CI uses these settings:
- `on-error: continue` -- Find ALL build failures, don't stop at first
- `fetchers: 32` -- Aggressive parallel downloads from artifact caches
- `builders: 1` -- GHA runners have 4 vCPUs; conservative to avoid OOM
- `retry-failed: True` -- Auto-retry flaky builds
- `error-lines: 80` -- Generous error context in logs
- `cache-buildtrees: never` -- Save disk; only final artifacts matter

## Key Design Decisions

Read `docs/plans/` for full context and rationale. Summary:

| Decision | Why |
|---|---|
| bst2 container via podman (not pip/Homebrew) | Consistent with GNOME upstream CI; avoids dependency conflicts |
| CLI flags for CI cache config (not project.conf) | Avoids affecting local dev builds |
| `on-error: continue` in CI | Find all failures in one run, not just the first |
| R2 cache push only on main | PRs don't write to shared cache; avoids exposing secrets to fork PRs |
| `bazel-remote` as CAS bridge | BuildStream needs gRPC CAS; R2 speaks S3; bazel-remote bridges them |
| `--network=host` for bst2 container | Simplest way for container to reach host's cache proxy |
| Separate `bst artifact push` step | BuildStream has no `--artifact-push` flag on `bst build`; push is a separate command |
| Non-fatal cache push (`continue-on-error`) | Cache failures must not block image builds |
| Disk space reclamation still needed | R2 cache reduces rebuild time but BuildStream's local CAS still needs >50 GB |

## Working with Elements

### Adding a New Package

1. Create a `.bst` file in `elements/bluefin/` (or `elements/core/` for system components)
2. Define the element kind, sources, build commands, and dependencies
3. Add it as a dependency of the appropriate layer in `elements/oci/layers/`
4. Test locally with `bst build elements/bluefin/your-package.bst`

### Patching Upstream Elements

Patches to freedesktop-sdk or gnome-build-meta go in `patches/`. These are applied via `patch_queue` sources in junction overrides.

### Updating Upstream Refs

The `gnome-build-meta.bst` and `freedesktop-sdk.bst` junction elements pin specific git refs. To update, change the `ref:` field and test the build.

## Conventions

- **Commit messages**: Conventional commits (`feat:`, `fix:`, `ci:`, `docs:`, `chore:`)
- **Plans**: `docs/plans/YYYY-MM-DD-<feature-name>.md`
- **YAML indentation**: 2 spaces
- **Shell in workflows**: `${VAR}` notation, double-quote all expansions, single-quoted `bash -c` with `-e` env passthrough for podman
- **Agent state**: `.opencode/` is gitignored -- never commit it

## Superpowers Skill System

All agents MUST load and follow these skills before acting:

| Skill | When |
|---|---|
| `using-superpowers` | Start of every session |
| `brainstorming` | Before any creative/feature work |
| `writing-plans` | Before any multi-step implementation |
| `executing-plans` | When implementing from a plan in a separate session |
| `subagent-driven-development` | When implementing from a plan in the current session |
| `test-driven-development` | Before writing implementation code |
| `systematic-debugging` | Before proposing fixes for bugs |
| `verification-before-completion` | Before claiming work is done |
| `finishing-a-development-branch` | After all tasks pass, before merge/PR |
| `requesting-code-review` | After completing major features |
| `receiving-code-review` | When processing review feedback |
| `using-git-worktrees` | When starting isolated feature work |

### Planning Workflow

All non-trivial work follows:

1. **Brainstorm** -- Understand the problem, explore requirements
2. **Write a plan** -- Save to `docs/plans/YYYY-MM-DD-<feature-name>.md`
3. **Execute the plan** -- Task by task, with review checkpoints
4. **Verify** -- Run builds/tests, confirm success with evidence
5. **Finish** -- PR or merge via the finishing skill

Plans are the source of truth for what was decided and why. They include corrections discovered during implementation. Always read existing plans in `docs/plans/` before starting related work.
