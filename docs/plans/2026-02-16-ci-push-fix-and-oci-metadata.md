# CI Push Fix and OCI Metadata Labels

**Date:** 2026-02-16  
**Status:** Approved  
**Assignee:** AI Agent

## Problem Statement

The CI pipeline has three issues preventing reliable image publication:

1. **GHCR push skipped on manual runs**: Workflow dispatch (manual triggers) don't push to GHCR because the condition checks `github.event_name == 'push'`, which excludes `workflow_dispatch` events
2. **Missing OCI metadata labels**: Published images lack comprehensive labels (title, description, vendor, license, url, source, created, revision, version) that match ublue-os/bluefin standard
3. **Inconsistent Justfile style**: Current Justfile doesn't follow bluefin-lts style patterns, reducing maintainer familiarity

**Evidence:**
- Last successful GHCR push: f4f65d8 at 05:44 UTC
- Most recent run (13:00 UTC): Skipped GHCR push despite being on main branch
- Current GHCR image created: 2026-02-16T05:44:31Z with minimal labels only

## Goals

1. **Fix GHCR push conditions** so manual workflow_dispatch runs on main branch push successfully
2. **Add comprehensive OCI metadata labels** matching ublue-os/bluefin standard
3. **Adopt bluefin-lts Justfile style patterns** for maintainer familiarity
4. **Remove all continue-on-error flags** for fail-fast behavior
5. **Document Justfile style guide** in AGENTS.md

## Non-Goals

- Changing the build system (staying with BuildStream)
- Additional bluefin-lts alignment work beyond style (future plan covers this)
- Modifying caching strategy or artifact handling

## Design

### OCI Labels Architecture

**Static labels** (in `elements/oci/bluefin.bst`):
```yaml
config:
  labels:
    org.opencontainers.image.title: "Bluefin"
    org.opencontainers.image.description: "A custom GNOME-based desktop image"
    org.opencontainers.image.vendor: "Project Bluefin"
    org.opencontainers.image.licenses: "Apache-2.0"
    org.opencontainers.image.url: "https://projectbluefin.io"
    org.opencontainers.image.source: "https://github.com/projectbluefin/egg"
```

**Dynamic labels** (injected via Justfile during export):
- `org.opencontainers.image.created` - ISO 8601 timestamp from CI
- `org.opencontainers.image.revision` - Git SHA from CI
- `org.opencontainers.image.version` - Currently "latest", extensible for future versioning

**Rationale:** Static labels defined in element remain constant across builds. Dynamic labels injected at export time via `podman image build --label` to reflect the specific build.

### GHCR Push Condition Fix

**Current (broken):**
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

**Fixed:**
```yaml
if: github.ref == 'refs/heads/main'
```

**Rationale:** The `github.ref` check is sufficient. Both `push` and `workflow_dispatch` events can have `github.ref == 'refs/heads/main'`. Checking event_name unnecessarily excludes manual runs.

### Justfile Style Patterns

Adopt bluefin-lts conventions:

1. **Export all variables**: `export var := env("ENV_VAR", "default")`
2. **Group recipes**: `[group('build')]` decorators for organization
3. **Default recipe**: `@just --list` for discoverability (instead of `build`)
4. **Quiet mode**: Keep `set -euo pipefail`, not verbose

**Rationale:** Maintainers familiar with bluefin-lts should recognize the style even though build system differs. This is about **patterns**, not content.

### Justfile Style Guide (for AGENTS.md)

```markdown
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
```

## Implementation Plan

### Task 1: Add Static OCI Labels to bluefin.bst

**File:** `elements/oci/bluefin.bst`  
**Location:** Lines 62-68 (after `config:` block start)

**Changes:**
```yaml
config:
  labels:
    org.opencontainers.image.title: "Bluefin"
    org.opencontainers.image.description: "A custom GNOME-based desktop image"
    org.opencontainers.image.vendor: "Project Bluefin"
    org.opencontainers.image.licenses: "Apache-2.0"
    org.opencontainers.image.url: "https://projectbluefin.io"
    org.opencontainers.image.source: "https://github.com/projectbluefin/egg"
```

**Verification:** `grep -A 10 'config:' elements/oci/bluefin.bst` shows labels

**Dependencies:** None

---

### Task 2: Convert Justfile Variables to Export Style

**File:** `Justfile`  
**Location:** Lines 1-19

**Changes:**
1. Convert all variable declarations to `export var := env("VAR", "default")` pattern
2. Add OCI metadata environment variables:
   - `export OCI_IMAGE_CREATED := env("OCI_IMAGE_CREATED", "")`
   - `export OCI_IMAGE_REVISION := env("OCI_IMAGE_REVISION", "")`
   - `export OCI_IMAGE_VERSION := env("OCI_IMAGE_VERSION", "latest")`

**Before:**
```just
bst_version := "2.5.0"
bst_image := "registry.gitlab.com/buildstream/bst2-plugins-fedora:" + bst_version
```

**After:**
```just
export BST_VERSION := env("BST_VERSION", "2.5.0")
export BST_IMAGE := env("BST_IMAGE", "registry.gitlab.com/buildstream/bst2-plugins-fedora:" + BST_VERSION)
export OCI_IMAGE_CREATED := env("OCI_IMAGE_CREATED", "")
export OCI_IMAGE_REVISION := env("OCI_IMAGE_REVISION", "")
export OCI_IMAGE_VERSION := env("OCI_IMAGE_VERSION", "latest")
```

**Verification:** `just --evaluate` shows all variables exported

**Dependencies:** None

---

### Task 3: Add Recipe Groups and Change Default

**File:** `Justfile`  
**Location:** All recipes throughout file

**Changes:**
1. Add `[group('build')]` above: build, export
2. Add `[group('dev')]` above: bst, shell
3. Add `[group('test')]` above: show-me-the-future, generate-bootable-image, boot-vm
4. Add `[group('registry')]` above: registry-start, registry-stop, registry-clean, publish
5. Change first recipe from `build:` to:
   ```just
   # List available commands
   [group('info')]
   default:
       @just --list
   ```

**Verification:** `just` shows list, `just --list` shows groups

**Dependencies:** None

---

### Task 4: Modify Export Recipe for Dynamic OCI Labels

**File:** `Justfile`  
**Location:** Lines 75-80 (export recipe)

**Changes:**
Add conditional label injection based on environment variables:

```just
[group('build')]
export:
    #!/usr/bin/env bash
    set -euo pipefail
    just bst artifact checkout --tar oci/bluefin.bst - | podman load
    
    # Build args for dynamic OCI labels
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
    
    # Re-tag with labels if any are provided
    if [ -n "${LABEL_ARGS}" ]; then
        IMAGE_ID=$(podman images --filter reference=localhost/egg:latest --format "{{.ID}}")
        podman image build ${LABEL_ARGS} -t localhost/egg:latest - <<EOF
FROM localhost/egg@sha256:${IMAGE_ID}
EOF
    fi
```

**Rationale:** `podman load` from tar doesn't support --label. We load first, then use `podman image build` with a trivial FROM directive to apply labels without rebuilding.

**Verification:** 
```bash
export OCI_IMAGE_CREATED="2026-02-16T12:00:00Z"
export OCI_IMAGE_REVISION="abc123"
just export
podman image inspect localhost/egg:latest --format '{{json .Labels}}' | jq
```

**Dependencies:** Task 2 (variables must exist)

---

### Task 5: Add Timestamp Capture in CI

**File:** `.github/workflows/build-egg.yml`  
**Location:** After line 117 (after "Install just")

**Changes:**
Add new step:
```yaml
      - name: Capture build timestamp
        id: timestamp
        run: echo "created=$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> $GITHUB_OUTPUT
```

**Verification:** Check workflow logs for timestamp output

**Dependencies:** None

---

### Task 6: Pass OCI Environment Variables to Export

**File:** `.github/workflows/build-egg.yml`  
**Location:** Lines 125-133 (Export OCI image step)

**Changes:**
Add environment variables to the step:

```yaml
      - name: Export OCI image
        id: export
        env:
          OCI_IMAGE_CREATED: ${{ steps.timestamp.outputs.created }}
          OCI_IMAGE_REVISION: ${{ github.sha }}
          OCI_IMAGE_VERSION: latest
        run: |
          just export
```

**Verification:** Check workflow logs show environment variables set

**Dependencies:** Task 5 (timestamp must be captured first)

---

### Task 7: Fix GHCR Push Conditions

**File:** `.github/workflows/build-egg.yml`  
**Location:** Lines 163, 170, 179 (Login, Tag, Push steps)

**Changes:**
Replace all three occurrences:

**Before:**
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

**After:**
```yaml
if: github.ref == 'refs/heads/main'
```

**Verification:** Manual workflow_dispatch run on main should push to GHCR

**Dependencies:** None

---

### Task 8: Remove Continue-on-Error Flags

**File:** `.github/workflows/build-egg.yml`  
**Location:** Lines 141, 162, 169, 178

**Changes:**
Remove `continue-on-error: true` from these steps:
- Line 141: "Upload build logs"
- Line 162: "Login to GitHub Container Registry"
- Line 169: "Tag image for GHCR"
- Line 178: "Push to GitHub Container Registry"

**Rationale:** 
- Upload logs: Should fail if logs are critical for debugging
- GHCR steps: Should fail immediately if push infrastructure is broken (not silently skip)

**Verification:** Build should stop on first failure

**Dependencies:** None

---

### Task 9: Document Justfile Style Guide in AGENTS.md

**File:** `AGENTS.md`  
**Location:** After "Conventions" section (around line 150)

**Changes:**
Add new section with the style guide from the Design section above.

**Verification:** `grep -A 20 "Justfile Style Guide" AGENTS.md` shows content

**Dependencies:** None

---

## Verification Plan

### Local Verification

1. **Justfile syntax:**
   ```bash
   just --evaluate  # Should show all exported variables
   just --list      # Should show grouped recipes
   just             # Should run default recipe (show list)
   ```

2. **OCI label injection (dry run):**
   ```bash
   export OCI_IMAGE_CREATED="2026-02-16T12:00:00Z"
   export OCI_IMAGE_REVISION="test123"
   export OCI_IMAGE_VERSION="latest"
   # Don't run full export (takes time), just verify syntax
   just --dry-run export
   ```

3. **BuildStream element syntax:**
   ```bash
   just bst show oci/bluefin.bst  # Should validate YAML syntax
   ```

### CI Verification

1. **Push changes to feature branch**
2. **Trigger manual workflow_dispatch run on main branch**
3. **Verify GHCR push executes** (should not skip)
4. **Inspect published image:**
   ```bash
   podman pull ghcr.io/projectbluefin/egg:latest
   podman image inspect ghcr.io/projectbluefin/egg:latest --format '{{json .Labels}}' | jq
   ```
5. **Confirm all OCI labels present:**
   - org.opencontainers.image.title
   - org.opencontainers.image.description
   - org.opencontainers.image.vendor
   - org.opencontainers.image.licenses
   - org.opencontainers.image.url
   - org.opencontainers.image.source
   - org.opencontainers.image.created (with valid timestamp)
   - org.opencontainers.image.revision (with git SHA)
   - org.opencontainers.image.version (with "latest")

### Failure Scenarios

**If labels are missing from published image:**
1. Check CI logs for "Export OCI image" step - are env vars set?
2. Check if `podman image build` with labels executed
3. Verify `podman load` completed before label injection

**If GHCR push still skips:**
1. Check workflow logs for condition evaluation
2. Verify `github.ref` value in workflow context
3. Confirm no typos in condition syntax

**If Justfile fails:**
1. Check `just --evaluate` output for syntax errors
2. Verify all variable references updated (old `bst_version` → new `BST_VERSION`)
3. Test individual recipes with `just --dry-run <recipe>`

## Rollback Plan

All changes are isolated and can be reverted independently:

1. **Justfile changes**: Revert commit, previous version still works
2. **OCI labels in element**: Revert commit, BuildStream still builds
3. **CI workflow changes**: Revert commit, previous workflow still functions

No data loss risk - only affects CI behavior and image metadata.

## Future Work

Create separate plan (`docs/plans/2026-02-16-bluefin-justfile-alignment.md`) for additional bluefin-lts alignment:
- Podman Quadlet integration patterns
- Additional recipe conventions
- Testing infrastructure alignment

## Decision Log

### 2026-02-16: Corrected False Assumption

**Initial assumption:** bluefin-lts was BuildStream-based  
**Reality:** Only egg uses BuildStream; bluefin and bluefin-lts use Containerfiles  
**Impact:** Changed scope from "align build system" to "adopt Justfile style patterns"  
**Result:** We're adopting **style** (export, env(), groups, @just --list) not **content**

### 2026-02-16: Label Injection Strategy

**Options considered:**
1. Inject labels at `bst artifact checkout` time (not possible - tar format)
2. Inject labels at `podman load` time (not supported by podman load)
3. Inject labels via `podman image build` after load (chosen)

**Decision:** Use trivial `FROM` directive with `podman image build --label` to apply labels without rebuilding image layers.

**Rationale:** Preserves all BuildStream work while adding metadata at the last possible moment.

### 2026-02-16: Remove Continue-on-Error from GHCR Steps

**Rationale:** Silent failures in CI hide infrastructure problems. Better to fail loudly and fix the root cause than to skip publishing and wonder why images aren't updated.

**Risk mitigation:** Can re-add to specific steps if they prove flaky, but only after investigation.

---

## Notes

- All file line numbers are approximate and may shift as edits are made
- The podman image build trick for label injection is unusual but necessary given BuildStream's tar output
- Justfile changes are purely stylistic - no functional changes to recipes
- OCI labels follow [OCI Image Spec](https://github.com/opencontainers/image-spec/blob/main/annotations.md)
