---
name: ci-pipeline-operations
description: Use when debugging CI failures, understanding the build pipeline, modifying the GitHub Actions workflow, working with artifact caching, or troubleshooting why a build succeeded locally but fails in CI
---

# CI Pipeline Operations

## Overview

The CI pipeline (`.github/workflows/build-egg.yml`) builds the Bluefin OCI image inside the bst2 container on Blacksmith runners, validates it with `bootc container lint`, and pushes to GHCR on main. Caching uses Blacksmith sticky disks (NVMe-backed Ceph) as primary storage, with GNOME upstream CAS (read-only, configured in `project.conf`) as a remote artifact source, and Cloudflare R2 as a read-only cold preseed for bootstrapping empty sticky disks.

## Quick Reference

| What | Value |
|---|---|
| Workflow file | `.github/workflows/build-egg.yml` |
| Runner | `blacksmith-4vcpu-ubuntu-2404` |
| Build target | `oci/bluefin.bst` |
| Build timeout | 120 minutes |
| bst2 container | `registry.gitlab.com/.../bst2:<sha>` (pinned in workflow `env.BST2_IMAGE`) |
| GNOME CAS endpoint | `gbm.gnome.org:11003` (gRPC, read-only) |
| Cache strategy | Single Blacksmith sticky disk (NVMe-backed Ceph, ~3s mount, 7-day eviction) |
| Sticky disk | `bst-cache` -> `~/.cache/buildstream` (CAS + artifacts + source_protos + sources) |
| R2 role | Read-only cold preseed (bootstraps empty sticky disks) |
| R2 bucket | `bst-cache` |
| Published image | `ghcr.io/projectbluefin/egg:latest` and `:$SHA` |
| Build logs artifact | `buildstream-logs` (7-day retention) |

## Workflow Steps

| # | Step | What it does | Notes |
|---|---|---|---|
| 1 | Checkout | Clones the repo | Standard |
| 2 | Pull bst2 image | `podman pull` of the pinned bst2 container | Same image as GNOME upstream CI |
| 3 | Mount BST cache (sticky disk) | `useblacksmith/stickydisk@v1` mounts NVMe volume | Key: `${{ github.repository }}-bst-cache`; mounted at `~/.cache/buildstream` |
| 4 | Prepare cache layout | `mkdir -p` subdirs | Ensures CAS/artifacts/source_protos/sources dirs exist |
| 5 | Preseed CAS from R2 | Downloads `cas.tar.zst`, artifact refs, source protos from R2 | **Cold cache only** -- skips if sticky disk already has CAS objects; installs rclone on-demand |
| 6 | Install just | `sudo apt-get install -y just` | Used by build and export steps |
| 7 | Generate BST config | Writes `buildstream-ci.conf` with CI-tuned settings | No remote artifact server -- only local cache + upstream GNOME |
| 8 | Build | `just bst --log-file /src/logs/build.log build oci/bluefin.bst` | `--privileged --device /dev/fuse`; no `--network=host` needed |
| 9 | Cache and disk status | `df -h` + `du -sh` of cache components | Diagnostic; always runs |
| 10 | Export OCI image | `just export` (checkout + skopeo load + bootc fixup) | Uses Justfile recipe |
| 11 | Verify image loaded | `podman images` | Diagnostic |
| 12 | bootc lint | `bootc container lint` on exported image | Validates ostree structure, no `/usr/etc`, valid bootc metadata |
| 13 | Upload build logs | `actions/upload-artifact` | Always runs, even on failure |
| 14 | Login to GHCR | `podman login` with `GITHUB_TOKEN` | **Main only** |
| 15 | Tag for GHCR | Tags as `:latest` and `:$SHA` | **Main only** |
| 16 | Push to GHCR | `podman push --retry 3` both tags | **Main only** |

## CI BuildStream Config

Generated as `buildstream-ci.conf` at step 8. Values and rationale:

| Setting | Value | Why |
|---|---|---|
| `on-error` | `continue` | Find ALL failures in one run, not just the first |
| `fetchers` | `12` | Parallel downloads from artifact caches |
| `builders` | `1` | Conservative to avoid OOM on complex elements |
| `network-retries` | `3` | Retry transient network failures |
| `retry-failed` | `True` | Auto-retry flaky builds |
| `error-lines` | `80` | Generous error context in logs |
| `cache-buildtrees` | `never` | Save disk; only final artifacts matter |
| `max-jobs` | `0` | Let BuildStream auto-detect (uses nproc) |

**Important:** No remote artifact server is configured in `buildstream-ci.conf`. BuildStream uses only the local sticky disk cache and upstream GNOME caches defined in `project.conf` (read-only). Sticky disks auto-commit on job end -- no explicit upload step is needed.

## Caching Architecture

Three layers, checked in order:

```
1. Sticky disk cache (~/.cache/buildstream/)
   Single NVMe-backed Ceph volume, persists across CI runs, ~3s mount
   Contains: CAS objects, artifact refs, source protos, source tarballs
   |-- miss -->
2. GNOME upstream CAS (https://gbm.gnome.org:11003)
   Read-only, configured in project.conf
   |-- miss -->
3. Build from source
```

### Sticky Disk Details

Blacksmith sticky disks are NVMe-backed Ceph volumes that persist across CI runs. They auto-commit on job end (regardless of job outcome -- even failed builds persist their cache progress) and are evicted after 7 days of inactivity.

A single sticky disk holds the entire BuildStream cache:

| Disk key | Mount point | Contains |
|---|---|---|
| `${{ github.repository }}-bst-cache` | `~/.cache/buildstream` | CAS objects, artifact refs, source protos, source tarballs |

**Key behaviors:**
- **~3 second mount** -- negligible overhead vs. downloading a multi-GB cache archive
- **Auto-commit on job end** -- all changes written during the job are persisted automatically, even if the build fails
- **7-day eviction** -- disks unused for 7 days are reclaimed; the R2 preseed step handles cold recovery
- **Per-repository isolation** -- disk keys include `github.repository`, so forks get separate disks
- **Single volume inside container** -- the Justfile mounts `~/.cache/buildstream` at `/root/.cache/buildstream` inside the bst2 podman container; only this single volume is visible to BuildStream

### R2 Cold Preseed

R2 is used only for cold cache recovery (when sticky disks are empty). The preseed step:

1. Checks if `~/.cache/buildstream/cas/` already has objects (warm disk = skip)
2. Installs rclone on-demand (not a separate workflow step)
3. Downloads `cas.tar.zst` from R2, validates with `zstd -t`, extracts
4. Syncs artifact refs from `r2:bst-cache/artifacts/`
5. Syncs source protos from `r2:bst-cache/source_protos/`

**R2 is never written to during normal operation.** The preseed data is a static snapshot. To refresh it, manually upload a new `cas.tar.zst` archive to R2.

### Layer Summary

| Layer | Configured in | Read | Write | Contains |
|---|---|---|---|---|
| Sticky disk | `useblacksmith/stickydisk@v1` | Always | Always (auto-commit) | CAS objects, artifact refs, source protos, source tarballs |
| GNOME upstream | `project.conf` `artifacts:` section | Always | Never | freedesktop-sdk + gnome-build-meta artifacts |
| R2 preseed | Workflow step (rclone, on-demand) | Cold cache only | Never | Bootstrap CAS snapshot (currently corrupt) |

## Trigger Modes

| Behavior | Scheduled (daily 08:00 UTC) | Manual dispatch |
|---|---|---|
| Build runs? | Yes | Yes |
| bootc lint? | Yes | Yes |
| Sticky disk cache? | Yes | Yes |
| R2 preseed (cold cache)? | Yes | Yes |
| Push to GHCR? | Yes | Yes |
| Concurrency | Single group; cancel-in-progress if another build arrives | Single group; cancel-in-progress if another build arrives |

**Schedule timing:** The workflow runs daily at 08:00 UTC, after GNOME OS publishes artifacts (~03:03 UTC, done by ~04:00) and source tracking runs (06:00 UTC).

## Secrets and Permissions

| Secret | Required? | Purpose |
|---|---|---|
| `R2_ACCESS_KEY` | Optional | Cloudflare R2 access key ID (cold preseed only) |
| `R2_SECRET_KEY` | Optional | Cloudflare R2 secret access key (cold preseed only) |
| `R2_ENDPOINT` | Optional | R2 S3-compatible endpoint (cold preseed only) |
| `GITHUB_TOKEN` | Auto-provided | GHCR login (always pushes on success) |

**All R2 secrets are optional.** If missing, the cold preseed step is skipped and the build proceeds using the sticky disk cache (if warm) plus GNOME upstream CAS. On a truly cold start without R2 secrets, everything builds from source -- slow but functional.

Job permissions: `contents: read`, `packages: write`.

## bst2 Container Configuration

The bst2 container runs via `podman run` (NOT as a GitHub Actions `container:`), because sticky disk mounts must happen on the host before being bind-mounted into the container.

| Flag | Why |
|---|---|
| `--privileged` | Required for bubblewrap sandboxing inside BuildStream |
| `--device /dev/fuse` | Required for `buildbox-fuse` (ext4 on GHA lacks reflinks) |
| `-v workspace:/src:rw` | Mount repo into container |
| `-v ~/.cache/buildstream:...:rw` | Persist CAS across steps (backed by sticky disk) |
| `ulimit -n 1048576` | `buildbox-casd` needs many file descriptors |
| `--no-interactive` | Prevents blocking on prompts in CI |

Note: `--network=host` is not needed since there is no local cache proxy. The bst2 container only needs network access for GNOME upstream CAS, which is accessed directly.

## Debugging CI Failures

### Where to Find Logs

| Log | Location | Contents |
|---|---|---|
| Build log | `buildstream-logs` artifact -> `logs/build.log` | Full BuildStream build output |
| Preseed output | "Preseed CAS from R2" step output | Cold cache restore status (skipped if warm) |
| Workflow log | GitHub Actions UI -> step output | Each step's stdout/stderr |
| Disk usage | "Cache and disk status" step | `df -h` + cache component breakdown |

### Common Failures

| Symptom | Likely cause | Fix |
|---|---|---|
| Build OOM or hangs | Too many parallel builders | `builders` is already 1; check if element's own build is too memory-heavy |
| "No space left on device" | BuildStream CAS fills sticky disk | Check `cache-buildtrees: never` is set; consider if sticky disk needs size increase |
| `bootc container lint` fails | Image has `/usr/etc`, missing ostree refs, or invalid metadata | Check `oci/bluefin.bst` assembly script; ensure `/usr/etc` merge runs |
| Build succeeds locally, fails in CI | Different element versions cached, or network-dependent sources | Compare `bst show` output locally vs CI; check if GNOME CAS has stale artifacts |
| GHCR push fails | Token permissions or rate limiting | Check `packages: write` permission; `--retry 3` handles transient failures |
| Source fetch timeout | GNOME CAS or upstream source unreachable | `network-retries: 3` handles transient issues; check GNOME infra status |
| Sticky disk mount fails | Blacksmith infra issue or disk key mismatch | Check `useblacksmith/stickydisk` step output; verify disk key in workflow |
| Sticky disk is cold (7-day eviction) | Normal -- disk was evicted after inactivity | Preseed step handles this automatically if R2 secrets are configured |
| Preseed step fails but build continues | R2 secrets missing or R2 unreachable | `continue-on-error: true`; build proceeds from GNOME upstream CAS + source builds |
| Preseed step skipped on warm disk | Normal -- sticky disk already has CAS objects | No action needed; this is the fast path |

### Debugging Workflow

1. **Check sticky disk mount**: In the `useblacksmith/stickydisk` step output, verify the disk mounted successfully. If mounting fails, it's a Blacksmith infra issue.

2. **Check preseed status**: If the build is unexpectedly slow, check the "Preseed CAS from R2" step. If it ran, the sticky disk was cold. If it was skipped ("Sticky disk already warm"), the cache should have been populated.

3. **Check disk space**: Look at the "Cache and disk status" step -- it shows `df -h` and a breakdown of each cache component's size.

4. **Search build log**: Download `buildstream-logs` artifact and look for `[FAILURE]` lines in `logs/build.log`. `on-error: continue` means all failures are collected in one run.

5. **Reproduce locally**: `just bst build oci/bluefin.bst` uses the same bst2 container. See `local-e2e-testing` skill for full local workflow.

## Cross-References

| Skill | When |
|---|---|
| `local-e2e-testing` | Reproducing CI issues locally |
| `oci-layer-composition` | Understanding what the build produces |
| `debugging-bst-build-failures` | Diagnosing individual element build failures |
| `buildstream-element-reference` | Writing or modifying `.bst` elements |
