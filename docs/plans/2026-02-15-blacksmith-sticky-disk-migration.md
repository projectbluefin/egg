# Blacksmith Sticky Disk Migration Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Switch CI from `Testing` runner to `blacksmith-4vcpu-ubuntu-2404` with sticky disks for the BuildStream cache. Preseed the sticky disk from the existing R2 `cas.tar.zst` on first run. Keep R2 infrastructure intact for now -- remove it as a separate follow-up effort.

**Architecture:** Two Blacksmith sticky disks mounted before the build: one for CAS + artifact metadata, one for source downloads (symlinked into BuildStream's expected location). On cold disk, preseed from the existing `cas.tar.zst` in R2 so the first Blacksmith run starts warm. R2 sync infrastructure is removed from the hot path but R2 data is preserved as a cold backup.

**Tech Stack:** GitHub Actions, Blacksmith runners (`blacksmith-4vcpu-ubuntu-2404`), `useblacksmith/stickydisk@v1`, BuildStream 2, rclone + Cloudflare R2 (preseed only)

---

## Background

### Current State

The CI workflow (`.github/workflows/build-egg.yml`) uses a self-hosted `Testing` runner (line 26). Cache persistence between runs uses Cloudflare R2 via rclone:

1. **Restore** (lines 67-190): Download `cas.tar.zst` (~9+ GB compressed) from R2, validate with `zstd -t`, extract into `~/.cache/buildstream/cas/`. Also restore `artifacts/` and `source_protos/` metadata. (~120 lines of shell)
2. **Background sync** (lines 260-342): A bash loop uploads a tar+zstd snapshot every 5 minutes during the build. Uses lock file coordination. (~80 lines of shell)
3. **Final sync** (lines 373-551): Stops background loop, compresses CAS at zstd level 9, uploads atomically to R2. (~180 lines of shell)
4. **Source cache** (lines 37-43): `actions/cache@v4` caches `~/.cache/buildstream/sources` (10 GB limit).

Total caching infrastructure: ~360 lines of shell, 3 secrets (R2_ACCESS_KEY, R2_SECRET_KEY, R2_ENDPOINT), rclone install step (lines 56-59), health check step (lines 192-213).

### Problems

- **Restore time:** Downloading and decompressing multi-GB archives takes minutes every run
- **Upload time:** Compressing and uploading takes minutes, even with background sync
- **Complexity:** Lock file coordination, atomic upload/rename, integrity validation, error handling
- **Fragility:** rclone can exit 0 with 0 bytes (documented in cache-hardening plan), archive corruption, race conditions
- **Runner doesn't persist cache:** Issue #9 in cache-hardening plan explicitly states this

### Blacksmith Sticky Disks

`useblacksmith/stickydisk@v1` provides persistent ext4 filesystems backed by a Ceph cluster on local NVMe drives.

| Property | Value |
|---|---|
| Access time | ~3 seconds for 6 GB |
| Format | ext4 |
| Persistence | Survives between CI runs; stored in NVMe-backed Ceph cluster |
| Eviction | 7 days of inactivity |
| Limit | 5 sticky disks per job |
| Commit | Automatic on job completion |
| Pricing | $0.50/GB/mo |
| Concurrency | Last Write Wins (LWW) |

### Preseed Strategy

The existing R2 archive (`cas.tar.zst`) preseeds the CAS sticky disk on the very first run:

1. Sticky disk mounts at `~/.cache/buildstream` (empty on first run)
2. Preseed step checks if CAS directory has files
3. If empty: download `cas.tar.zst` from R2, extract into the mounted sticky disk
4. BuildStream builds with warm cache
5. Sticky disk auto-commits on job completion -- future runs start warm in ~3 seconds
6. Preseed step becomes self-healing: if the sticky disk evicts (7 days inactivity), it re-preseeds from R2

R2 data is NOT deleted. It stays in the bucket as a cold backup indefinitely. R2 secrets stay configured. The only change is that we stop writing to R2 (no background sync, no final sync).

---

## Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Runner | `blacksmith-4vcpu-ubuntu-2404` | Matches current 4 vCPU, Ubuntu 24.04. Drop-in replacement. |
| Sticky disk 1 | `bst-cache` at `~/.cache/buildstream` | CAS + artifacts + source_protos. BuildStream manages subdirectory structure. |
| Sticky disk 2 | `bst-sources` at `~/.cache/buildstream-sources` | Source downloads. Decouples source lifecycle from CAS. Replaces `actions/cache`. |
| Sources location | Symlink `~/.cache/buildstream/sources` → `~/.cache/buildstream-sources` | BuildStream expects sources at `~/.cache/buildstream/sources`. Symlink bridges the two mount points. |
| R2 disposition | Keep data, stop writing | Preseed reads from R2 when cold. No ongoing sync. Remove R2 entirely in a follow-up. |
| `actions/cache` | Removed | Replaced by `bst-sources` sticky disk. |

### Why Two Sticky Disks

- Sources change more frequently than CAS objects
- Independent eviction: if one evicts, the other may survive
- Independent growth patterns
- Blacksmith allows up to 5 per job

---

## Tasks

### Task 1: Switch Runner and Add Sticky Disks

**Files:**
- Modify: `.github/workflows/build-egg.yml`

**Step 1: Change the runner label**

Line 26, change:
```yaml
    runs-on: Testing
```
to:
```yaml
    runs-on: blacksmith-4vcpu-ubuntu-2404
```

**Step 2: Replace cache and prepare steps with sticky disk mounts**

Remove these steps:
- "Cache BuildStream sources" (lines 37-43)
- "Prepare BuildStream cache directory" (lines 45-51)

Insert after "Pull BuildStream container image" step:

```yaml
      - name: Mount BuildStream cache (sticky disk)
        uses: useblacksmith/stickydisk@v1
        with:
          key: ${{ github.repository }}-bst-cache
          path: ~/.cache/buildstream

      - name: Mount BuildStream sources (sticky disk)
        uses: useblacksmith/stickydisk@v1
        with:
          key: ${{ github.repository }}-bst-sources
          path: ~/.cache/buildstream-sources

      - name: Prepare BuildStream cache layout
        run: |
          # Ensure subdirectories exist (first run on fresh sticky disk)
          mkdir -p ~/.cache/buildstream/{cas,artifacts,source_protos}
          mkdir -p ~/.cache/buildstream-sources

          # Symlink sources into the expected BuildStream location
          # BuildStream expects sources at ~/.cache/buildstream/sources/
          if [ ! -e ~/.cache/buildstream/sources ]; then
            ln -s ~/.cache/buildstream-sources ~/.cache/buildstream/sources
          elif [ -d ~/.cache/buildstream/sources ] && [ ! -L ~/.cache/buildstream/sources ]; then
            # Real dir exists (e.g. from preseed) -- move contents, replace with symlink
            if [ "$(ls -A ~/.cache/buildstream/sources 2>/dev/null)" ]; then
              cp -a ~/.cache/buildstream/sources/. ~/.cache/buildstream-sources/
            fi
            rm -rf ~/.cache/buildstream/sources
            ln -s ~/.cache/buildstream-sources ~/.cache/buildstream/sources
          fi

          echo "=== Sticky disk status ==="
          echo "CAS:       $(du -sh ~/.cache/buildstream/cas 2>/dev/null | cut -f1 || echo 'empty')"
          echo "Artifacts: $(du -sh ~/.cache/buildstream/artifacts 2>/dev/null | cut -f1 || echo 'empty')"
          echo "Sources:   $(du -sh ~/.cache/buildstream-sources 2>/dev/null | cut -f1 || echo 'empty')"
          df -h ~/.cache/buildstream ~/.cache/buildstream-sources
```

**Step 3: Commit**

```bash
git add .github/workflows/build-egg.yml
git commit -m "ci: switch to blacksmith runner with sticky disks for BuildStream cache"
```

---

### Task 2: Replace R2 Restore with Preseed Step

**Files:**
- Modify: `.github/workflows/build-egg.yml`

**Step 1: Remove the standalone rclone install and R2 restore steps**

Remove these steps entirely:
- "Install rclone" (lines 56-59)
- "Restore BuildStream cache from R2" (lines 67-190)
- "Post-restore cache health check" (lines 192-213)

**Step 2: Add preseed step**

Insert after "Prepare BuildStream cache layout" step:

```yaml
      - name: Preseed CAS from R2 (cold cache only)
        env:
          R2_ACCESS_KEY: ${{ secrets.R2_ACCESS_KEY }}
          R2_SECRET_KEY: ${{ secrets.R2_SECRET_KEY }}
          R2_ENDPOINT: ${{ secrets.R2_ENDPOINT }}
        run: |
          BST_CACHE="$HOME/.cache/buildstream"
          CAS_OBJECTS=$(find "${BST_CACHE}/cas" -type f 2>/dev/null | head -5 | wc -l)

          if [ "$CAS_OBJECTS" -gt 0 ]; then
            echo "Sticky disk has cached CAS objects -- skipping preseed"
            echo "CAS size: $(du -sh "${BST_CACHE}/cas" | cut -f1)"
            ARTIFACT_REFS=$(find "${BST_CACHE}/artifacts" -type f 2>/dev/null | wc -l)
            echo "Artifact refs: ${ARTIFACT_REFS}"
            exit 0
          fi

          echo "Sticky disk is cold -- preseeding from R2 archive"

          if [ -z "${R2_ACCESS_KEY}" ]; then
            echo "::warning::R2 secrets not configured and sticky disk is cold -- full build expected (~2h)"
            exit 0
          fi

          # Install rclone (only needed for preseed on cold disk)
          curl -fsSL https://rclone.org/install.sh | sudo bash

          # Configure rclone for Cloudflare R2
          mkdir -p ~/.config/rclone
          cat > ~/.config/rclone/rclone.conf <<RCONF
          [r2]
          type = s3
          provider = Cloudflare
          access_key_id = ${R2_ACCESS_KEY}
          secret_access_key = ${R2_SECRET_KEY}
          endpoint = ${R2_ENDPOINT}
          no_check_bucket = true
          RCONF
          sed -i 's/^[[:space:]]*//' ~/.config/rclone/rclone.conf

          # Check if R2 has a CAS archive
          CAS_REMOTE_SIZE=$(rclone size --json "r2:${R2_BUCKET}/cas.tar.zst" 2>/dev/null | jq -r '.bytes // 0')
          if [ "${CAS_REMOTE_SIZE:-0}" -le 0 ]; then
            echo "::warning::No cas.tar.zst in R2 -- cold build expected"
            exit 0
          fi

          echo "Downloading cas.tar.zst ($((CAS_REMOTE_SIZE / 1048576)) MB)..."
          TEMP_CAS=$(mktemp /tmp/cas.tar.zst.XXXXXX)
          if rclone copyto "r2:${R2_BUCKET}/cas.tar.zst" "${TEMP_CAS}" --progress; then
            ACTUAL_SIZE=$(stat --format=%s "${TEMP_CAS}" 2>/dev/null || echo 0)
            if [ "$ACTUAL_SIZE" -lt 1000 ]; then
              echo "::warning::Downloaded file is suspiciously small (${ACTUAL_SIZE} bytes) -- cold build"
            else
              echo "Validating archive integrity..."
              if zstd -t "${TEMP_CAS}"; then
                echo "Extracting into sticky disk..."
                zstd -d "${TEMP_CAS}" | tar xf - -C "${BST_CACHE}/"
                echo "CAS preseed complete: $(du -sh "${BST_CACHE}/cas" | cut -f1)"
              else
                echo "::warning::Archive validation failed -- cold build"
              fi
            fi
          else
            echo "::warning::R2 download failed -- cold build"
          fi
          rm -f "${TEMP_CAS}"

          # Also restore artifact refs and source protos metadata
          rclone copy "r2:${R2_BUCKET}/artifacts/" "${BST_CACHE}/artifacts/" \
            --size-only --transfers=16 --fast-list -q || true
          rclone copy "r2:${R2_BUCKET}/source_protos/" "${BST_CACHE}/source_protos/" \
            --size-only --transfers=16 --fast-list -q || true

          echo ""
          echo "=== Preseed summary ==="
          echo "CAS:       $(du -sh "${BST_CACHE}/cas" 2>/dev/null | cut -f1 || echo 'empty')"
          echo "Artifacts: $(find "${BST_CACHE}/artifacts" -type f 2>/dev/null | wc -l) refs"
          echo "Sources:   $(du -sh "${HOME}/.cache/buildstream-sources" 2>/dev/null | cut -f1 || echo 'empty')"
```

**Step 3: Commit**

```bash
git add .github/workflows/build-egg.yml
git commit -m "ci: add R2 preseed for cold sticky disk, remove ongoing R2 restore"
```

---

### Task 3: Remove Background Sync and Final R2 Sync

**Files:**
- Modify: `.github/workflows/build-egg.yml`

**Step 1: Remove background sync**

Delete the entire "Start background R2 sync" step (lines 260-342).

**Step 2: Remove final R2 sync**

Delete the entire "Final sync to R2" step (lines 373-551).

**Step 3: Simplify the cache status step**

Replace "Disk and cache usage after build" (lines 357-365) with:

```yaml
      - name: Cache and disk status
        if: always()
        run: |
          echo "=== Disk usage ==="
          df -h ~/.cache/buildstream ~/.cache/buildstream-sources / 2>/dev/null || df -h /
          echo ""
          echo "=== BuildStream cache breakdown ==="
          du -sh ~/.cache/buildstream/{cas,artifacts,source_protos} 2>/dev/null || true
          echo "Sources: $(du -sh ~/.cache/buildstream-sources 2>/dev/null | cut -f1 || echo 'empty')"
          echo ""
          echo "=== Total ==="
          du -sh ~/.cache/buildstream/ 2>/dev/null || true
```

**Step 4: Commit**

```bash
git add .github/workflows/build-egg.yml
git commit -m "ci: remove R2 background sync and final sync (sticky disk handles persistence)"
```

---

### Task 4: Update Documentation

**Files:**
- Modify: `AGENTS.md` (CI architecture sections)
- Modify: `.opencode/skills/ci-pipeline-operations/SKILL.md`

**Step 1: Update AGENTS.md**

In the CI/CD Pipeline section:
- Change runner from `Testing` to `blacksmith-4vcpu-ubuntu-2404`
- Update "Artifact Caching" to describe sticky disks as primary, R2 as cold preseed backup
- Remove `bazel-remote` references (already stale)
- Update the design decisions table

**Step 2: Update ci-pipeline-operations skill**

- Update workflow step table to reflect new step order
- Update caching architecture section (sticky disks, not R2 sync)
- Remove background sync and final sync documentation
- Add sticky disk troubleshooting entries
- Update "Common Failures" table

**Step 3: Commit**

```bash
git add AGENTS.md .opencode/skills/ci-pipeline-operations/SKILL.md
git commit -m "docs: update CI docs for blacksmith sticky disk architecture"
```

---

### Task 5: Verify End-to-End

**No file changes.** Manual verification.

**Step 1: Validate YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-egg.yml'))"
```

**Step 2: Review the complete workflow**

Read `.github/workflows/build-egg.yml` end-to-end. Checklist:
- [ ] Runner is `blacksmith-4vcpu-ubuntu-2404`
- [ ] Two `useblacksmith/stickydisk@v1` steps before the build
- [ ] Symlink step creates `sources` → `buildstream-sources`
- [ ] Preseed step checks for cold cache, downloads from R2 if needed
- [ ] No `actions/cache` step remains
- [ ] No background sync step
- [ ] No final R2 sync step
- [ ] Build step unchanged (`just bst build oci/bluefin.bst`)
- [ ] Export step unchanged (`just export`)
- [ ] Validation step unchanged (`bootc container lint`)
- [ ] GHCR publish steps unchanged
- [ ] `Install just` step present
- [ ] `Install rclone` is inside the preseed step only
- [ ] Build logs upload step still runs on `always()`

**Step 3: Push to PR branch and observe first run**

Expected behavior:
1. Sticky disks mount (~3 seconds, empty)
2. Preseed downloads `cas.tar.zst` from R2, extracts into sticky disk
3. Build runs with warm cache (~30-40 min)
4. Job ends, sticky disk auto-commits

**Step 4: Observe second run**

Expected behavior:
1. Sticky disks mount (~3 seconds, warm)
2. Preseed skips (CAS objects found)
3. Build runs with warm cache
4. Zero R2 interaction

---

## Expected Final Workflow Structure

```
 1. Checkout
 2. Pull bst2 container image
 3. Mount BuildStream cache (sticky disk)
 4. Mount BuildStream sources (sticky disk)
 5. Prepare BuildStream cache layout
 6. Preseed CAS from R2 (cold cache only)
 7. Install just
 8. Generate BuildStream CI config
 9. Build OCI image with BuildStream
10. Cache and disk status
11. Export OCI image
12. Verify image loaded
13. Validate with bootc container lint
14. Upload build logs
15. Login to GHCR (main only)
16. Tag image for GHCR (main only)
17. Push to GHCR (main only)
```

**Net change:** ~360 lines removed, ~80 lines added. 17 steps instead of 20+.

---

## Rollback Plan

Revert the commit. R2 archive is untouched. `Testing` runner still exists. Zero data loss.

---

## Future Work (not in this plan)

- Remove R2 secrets and rclone preseed entirely (after confirming sticky disk stability)
- Delete `cas.tar.zst` from R2 bucket
- Clean up stale `bazel-remote` references in docs
- Consider single sticky disk if symlink causes issues

---

## Supersedes

- `docs/plans/2026-02-14-cloudflare-r2-cache.md` -- R2 sync replaced by sticky disks (data kept)
- `docs/plans/2026-02-15-cache-hardening.md` -- R2 hardening concerns become moot (no more writes)
