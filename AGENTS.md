# Agent Instructions

This repository builds **Bluefin** -- a custom GNOME-based Linux desktop image -- using [BuildStream 2](https://buildstream.build/). The output is a [bootc](https://containers.github.io/bootc/)-compatible OCI container image published to `ghcr.io/projectbluefin/egg`.

All AI-assisted development is skill-driven. Skills (`.opencode/skills/`) are vendored in-repo and are the primary mechanism for institutional memory. Agents MUST load and follow relevant skills before acting, and MUST create or update skills whenever they discover automatable patterns.

## Quick Reference

| What | Where |
|---|---|
| Build target | `oci/bluefin.bst` |
| End-to-end local test | `just show-me-the-future` |
| Local build | `just build` |
| Publish to local registry | `just publish` (requires `just registry-start`) |
| Local OTA registry | `just registry-start` / `just registry-stop` (zot on port 5000) |
| CI workflow | `.github/workflows/build-egg.yml` |
| Published image | `ghcr.io/projectbluefin/egg:latest` |
| Upstream repo | `github.com/projectbluefin/egg` |
| Implementation plans | `docs/plans/` |
| BuildStream project config | `project.conf` |
| Skills (vendored) | `.opencode/skills/` |

## What This Project Is

Bluefin Egg is the "primal form" of [Project Bluefin](https://projectbluefin.io/) -- a full desktop OS image built from source using BuildStream. It layers Bluefin-specific packages (Homebrew, Plymouth theme, GNOME extensions, wallpapers, fonts) on top of a GNOME OS base image derived from [gnome-build-meta](https://gitlab.gnome.org/GNOME/gnome-build-meta) and [freedesktop-sdk](https://gitlab.com/freedesktop-sdk/freedesktop-sdk).

The build pipeline:
1. BuildStream resolves the dependency graph rooted at `oci/bluefin.bst`
2. It pulls cached artifacts from GNOME's upstream CAS and the local sticky disk cache
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
just show-me-the-future    # Full end-to-end: build + bootable disk + QEMU VM
just build                 # Build OCI image only (uses bst2 container via podman)
just bst show oci/bluefin.bst  # Run any bst command inside the bst2 container
```

All BuildStream commands run inside the official bst2 container image (same one CI uses), invoked automatically via podman. No native BuildStream installation needed. Requires: podman, ~50 GB free disk. For VM boot: QEMU + OVMF.

### Local OTA Updates

A local `zot` OCI registry enables pushing builds to running VMs as OTA updates, without leaving the network. The full dev loop:

```bash
just registry-start                    # Start local zot registry on port 5000
just build                             # Build the image
just publish                           # Push to local registry
just generate-bootable-image           # Create bootable disk (first time)
just boot-vm                           # Boot VM
# Inside VM (one-time): sudo bootc switch --transport registry 10.0.2.2:5000/egg:latest
# Iterate: edit -> just build -> just publish -> (in VM) sudo bootc upgrade
```

**Plan:** `docs/plans/2026-02-15-local-ota-registry.md` has the full design.

**Skill:** Load `local-e2e-testing` for full prerequisites, troubleshooting, and environment variable reference.

Requires BuildStream 2.5+ (provided by the bst2 container). The Justfile handles `bst build oci/bluefin.bst` followed by `bst artifact checkout --tar - | podman load`.

### Local-First Development Policy

**Local development is the default.** All build verification MUST happen locally before pushing to the remote. CI is a safety net, not the primary build environment.

**Hard gate:** No code may be committed to `main` or pushed for PR without a local build log showing the affected elements build successfully. This means:

1. **Before committing element changes:** Run `just bst build <element>` for the changed element(s)
2. **Before pushing image-affecting changes:** Run `just build` (full OCI image build)
3. **Build log evidence is required:** The `verification-before-completion` skill enforces this -- agents must show build command output before claiming success

The rationale: CI runs take 30-60 minutes and consume shared resources. Local builds with a warm cache take minutes. Catching failures locally is faster, cheaper, and more respectful of the shared CI infrastructure.

**Skill:** Load `local-e2e-testing` for the complete local development workflow -- it is the default workflow for all build work, not just "testing."

### project.conf

The project configuration defines:
- **Artifact caches**: GNOME's upstream CAS at `gbm.gnome.org:11003` (read-only)
- **Source caches**: Same GNOME endpoint for source mirrors
- **Plugins**: From buildstream-plugins, buildstream-plugins-community, and gnome-build-meta
- **Architecture options**: x86_64, aarch64, riscv64
- **Source ref format**: `git-describe`

**Important**: `project.conf` is shared between local dev and CI. CI-specific settings are passed via CLI flags, NOT added to project.conf.

## CI/CD Pipeline

### Workflow: `.github/workflows/build-egg.yml`

Runs on `blacksmith-4vcpu-ubuntu-2404`. Triggers on push to main, PRs against main, and manual dispatch.

**Architecture**: BuildStream runs inside GNOME's official `bst2` Docker image via podman. This container needs `--privileged` and `--device /dev/fuse` for bubblewrap sandboxing. The container is NOT the GitHub Actions `container:` directive -- it's invoked via `podman run` because sticky disk mounts must happen on the host before being bind-mounted into the container.

**Steps** (in order):
1. Checkout repository
2. Pull bst2 container image
3. Mount BuildStream cache (sticky disk)
4. Prepare BuildStream cache layout (mkdir subdirs)
5. Preseed CAS from R2 (cold cache only -- runs only when sticky disk is empty)
6. Install just
7. Generate CI-specific BuildStream config (`buildstream-ci.conf`)
8. Build `oci/bluefin.bst` inside bst2 container
9. Cache and disk status
10. Export OCI image (`just export`)
11. Verify image loaded
12. Validate with `bootc container lint`
13. Upload build logs
14. Login to GHCR (main only)
15. Tag image for GHCR (main only)
16. Push to GHCR (main only)

### Artifact Caching

Three layers of artifact caching:

1. **Sticky disk cache** (NVMe-backed Ceph): A single persistent disk at `~/.cache/buildstream` that survives across CI runs (~3s mount time, auto-commit on job end, 7-day eviction). Contains CAS objects, artifact refs, source protos, and source tarballs -- everything BuildStream needs in one volume.

2. **GNOME upstream** (`gbm.gnome.org:11003`): Read-only. Configured in `project.conf`. Contains artifacts for freedesktop-sdk and gnome-build-meta elements. Available to all builds.

3. **R2 cold preseed** (Cloudflare R2, read-only): Used only when the sticky disk is empty (first run or after 7-day eviction). Installs rclone on-demand, downloads CAS archive and metadata refs, then never touches R2 again until the next cold start. **Note:** The R2 `cas.tar.zst` is currently corrupt (93 bytes despite claiming 12.9 GB) -- cold starts build from scratch using GNOME upstream CAS.

**Secrets** (configured on projectbluefin/egg, used only for R2 preseed):
- `R2_ACCESS_KEY`: Cloudflare R2 access key ID
- `R2_SECRET_KEY`: Cloudflare R2 secret access key
- `R2_ENDPOINT`: R2 S3-compatible endpoint (`https://<ACCOUNT_ID>.r2.cloudflarestorage.com`)
- R2 bucket name: `bst-cache` (hardcoded in workflow env block)

### CI Config Rationale

The `buildstream-ci.conf` generated during CI uses these settings:
- `on-error: continue` -- Find ALL build failures, don't stop at first
- `fetchers: 12` -- Parallel downloads from artifact caches
- `builders: 1` -- Conservative to avoid OOM on complex elements
- `retry-failed: True` -- Auto-retry flaky builds
- `error-lines: 80` -- Generous error context in logs
- `cache-buildtrees: never` -- Save disk; only final artifacts matter

## Key Design Decisions

Read `docs/plans/` for full context and rationale. Summary:

| Decision | Why |
|---|---|
| bst2 container via podman (not pip/Homebrew) | Consistent with GNOME upstream CI; avoids dependency conflicts |
| `on-error: continue` in CI | Find all failures in one run, not just the first |
| Blacksmith sticky disks for CI cache | NVMe-backed persistent storage; ~3s mount; no sync overhead; auto-commit on job end |
| R2 as cold preseed only | Sticky disks are primary; R2 bootstraps empty disks after 7-day eviction |
| No `actions/cache` for sources | Sticky disk replaces it; no 10 GB size limit, no upload/download step |
| Non-fatal R2 preseed (`continue-on-error`) | Preseed failures must not block builds; sticky disk may already be warm |

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
- **Agent state**: `.opencode/` is gitignored -- never commit it (except `.opencode/skills/` which is tracked)

## Justfile Style Guide

All Justfiles in this repository follow bluefin-lts style patterns:

**Variables:**
- Use `export` for all variables: `export FOO := env("FOO", "default")`
- Prefer `env()` with defaults over bare assignments
- Environment variables should match exported variable names

**Recipe Organization:**
- Add `[group('category')]` decorators to all recipes
- Categories: `build`, `test`, `dev`, `registry`, `vm`
- Order recipes by logical workflow, not alphabetically

**Default Recipe:**
- First recipe should be `@just --list` (displays available commands)
- This improves discoverability for new contributors

**Recipe Style:**
- Use quiet mode: Prefix with `@` to suppress command echo
- Set shell options: `#!/usr/bin/env bash` with `set -euo pipefail`
- Keep recipes focused: One task per recipe, compose with dependencies

**Comments:**
- Add brief description above each recipe
- Explain non-obvious environment variables
- Document prerequisites for complex recipes

## Superpowers Skill System

All agents MUST load and follow these skills before acting:

| Skill | When |
|---|---|
| `using-superpowers` | Start of every session |
| `brainstorming` | Before any creative/feature work |
| `writing-plans` | Before any multi-step implementation |
| `writing-skills` | When creating or updating skills |
| `executing-plans` | When implementing from a plan in a separate session |
| `subagent-driven-development` | When implementing from a plan in the current session |
| `test-driven-development` | Before writing implementation code |
| `systematic-debugging` | Before proposing fixes for bugs |
| `verification-before-completion` | Before claiming work is done |
| `finishing-a-development-branch` | After all tasks pass, before merge/PR |
| `requesting-code-review` | After completing major features |
| `receiving-code-review` | When processing review feedback |
| `using-git-worktrees` | When starting isolated feature work |
| `dispatching-parallel-agents` | When facing 2+ independent tasks |
| `adding-a-package` | When adding a new software package to the image |
| `buildstream-element-reference` | When writing or reviewing .bst element files |
| `packaging-pre-built-binaries` | When packaging pre-built static binaries |
| `packaging-zig-projects` | When packaging Zig build system projects |
| `packaging-rust-cargo-projects` | When packaging Rust/Cargo projects with cargo2 sources |
| `packaging-gnome-shell-extensions` | When packaging GNOME Shell extensions |
| `packaging-go-projects` | When packaging Go projects for BuildStream |
| `oci-layer-composition` | When working with OCI layers or the image assembly pipeline |
| `patching-upstream-junctions` | When patching freedesktop-sdk or gnome-build-meta elements |
| `removing-packages` | When removing a package from the Bluefin image |
| `updating-upstream-refs` | When updating upstream source refs or dependency versions |
| `debugging-bst-build-failures` | When diagnosing BuildStream build errors |
| `ci-pipeline-operations` | When working with the GitHub Actions CI pipeline |
| `local-e2e-testing` | When building or testing the OCI image locally |

Skills are vendored at `.opencode/skills/` and auto-discovered by the agent runtime. Load them with the `Skill` tool by name (e.g., `brainstorming`, `writing-plans`).

### Skill Maintenance -- The Agentic Feedback Loop

**Skills are living documents. Every agent session is an opportunity to improve them.**

This project is designed around an agentic feedback loop: agents do work, learn things, and encode that learning into skills so future agents start from a higher baseline. Skills are institutional memory that compounds over time.

**Mandatory behaviors:**

1. **Create skills** when you discover a pattern, workflow, or technique that isn't obvious and would benefit future agents. If you had to figure something out, write a skill so the next agent doesn't have to.

2. **Update skills** when you find existing guidance insufficient, incorrect, or incomplete. If a skill told you to do X but you had to do Y, update the skill.

3. **Evaluate skill opportunities** at the end of every plan execution. Ask: "What did I learn that should be a skill?" Common candidates:
   - Build system patterns (how to add elements, debug failures, patch upstream)
   - CI/CD patterns (workflow debugging, cache management)
   - Package-specific build knowledge (Zig, Rust, Meson quirks)
   - Troubleshooting runbooks (boot failures, sandbox issues)

4. **Follow the writing-skills skill** when creating or updating skills. It defines the TDD-based process: baseline test, write skill, verify improvement, close loopholes.

5. **Skills over AGENTS.md** for detailed procedural knowledge. AGENTS.md is the overview and index. Skills contain the deep how-to. Don't bloat AGENTS.md with information that belongs in a skill.

**What makes a good skill:**
- Reusable across sessions (not a one-off fix)
- Non-obvious (you wouldn't know this without experience)
- Actionable (tells you what to do, not just what to know)
- Discoverable (good name, good description with "Use when..." triggers)

**What does NOT need a skill:**
- Project-specific constants (put in AGENTS.md or project.conf)
- One-time setup instructions (put in a plan)
- Standard practices documented upstream (link to docs instead)

### Planning Workflow

All non-trivial work follows:

1. **Brainstorm** -- Understand the problem, explore requirements
2. **Write a plan** -- Save to `docs/plans/YYYY-MM-DD-<feature-name>.md`
3. **Execute the plan** -- Task by task, with review checkpoints
4. **Verify** -- Run builds/tests, confirm success with evidence
5. **Finish** -- PR or merge via the finishing skill
6. **Create/update skills** -- Encode what you learned

Plans are the source of truth for what was decided and why. They include corrections discovered during implementation. Always read existing plans in `docs/plans/` before starting related work.

### Subagent Workflow

When executing a multi-task implementation plan in the current session, use the `subagent-driven-development` skill. This applies whenever a plan has two or more independent tasks.

**Dispatch pattern:**

| Rule | Why |
|---|---|
| One fresh subagent per task | Isolation prevents cross-contamination of context |
| Include full task text in the dispatch | Subagents must not read plan files -- they lack conversation context |
| Provide surrounding context | Tell the subagent where the task fits in the plan and what other tasks exist |
| Subagents ask questions if unclear | Better to block than to guess wrong |

**Parallelism:**

- Independent tasks (different files, no shared state) -- dispatch in parallel
- Tasks that modify the same files -- dispatch sequentially, never in parallel
- When in doubt, run sequentially

**Two-stage review after each task:**

1. **Spec compliance** -- Does the output match the plan's requirements exactly?
2. **Code quality** -- Is the implementation clean, correct, and consistent with the codebase?

Both stages must pass before the task is marked complete. If a reviewer finds issues, the implementer fixes them and the reviewer re-reviews. This loop repeats until both stages pass.

**Completion:**

- Load `verification-before-completion` before claiming any task or the overall plan is done
- Run builds or checks as specified in the plan -- evidence before assertions
- Mark todos complete only after verification passes
