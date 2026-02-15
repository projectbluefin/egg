# BST Pipeline Skills Implementation Plan

> **For agents:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create 10 new skills and update 4 existing skills to cover every stage of the Bluefin BuildStream build pipeline, from "I want to add a package" through "it ships in the OCI image."

**Architecture:** Each skill documents a specific packaging pattern, build technique, or operational workflow. Skills are reference guides (not narratives) following the `writing-skills` TDD cycle. All skills live in `.opencode/skills/<name>/SKILL.md`. The plan also includes one housekeeping fix (Renovate config gap) and an AGENTS.md update.

**Tech Stack:** BuildStream 2, YAML (.bst elements), podman, QEMU, GitHub Actions, Renovate, Cloudflare R2

---

## Scope

### Task 0: Fix Renovate BST2_IMAGE sync gap
### Tasks 1-10: Create new skills
### Tasks 11-14: Update existing skills
### Task 15: Update AGENTS.md skill index

## Dependency Tracking Landscape

Three mechanisms keep upstream sources current. Every skill that touches a dependency MUST document which mechanism tracks it:

| Mechanism | What It Tracks | Config Location |
|---|---|---|
| **Renovate** | GH Actions, bst2 image, bazel-remote, PyPI plugins, Nerd Fonts | `.github/renovate.json5` |
| **`bst source track` workflow** | git-sourced elements (auto-merge group + manual-merge group) | `.github/workflows/track-bst-sources.yml` |
| **`track-tarballs` job** | brew-tarball, wallpapers (bash/sed/gh-api) | same workflow, `track-tarballs` job |
| **Nothing (gap)** | Tailscale, Ghostty, Zig, ghostty-gobject | needs future Renovate expansion |

---

### Task 0: Fix Renovate BST2_IMAGE sync gap

> **Status: Code change applied, needs commit.**

`BST2_IMAGE` is pinned in 3 files but Renovate only matched 2. The `track-bst-sources.yml` copy would drift silently.

**Files:**
- Modify: `.github/renovate.json5` (already modified, uncommitted)

**Change:** Add `/\\.github/workflows/track-bst-sources\\.yml$/` to the bst2 manager's `managerFilePatterns` array.

**Step 1: Verify the diff**
```bash
git diff .github/renovate.json5
```
Expected: One new line adding `track-bst-sources.yml` to `managerFilePatterns`.

**Step 2: Commit**
```bash
git add .github/renovate.json5
git commit -m "fix: add track-bst-sources.yml to Renovate bst2 image manager"
```

---

### Task 1: Create `packaging-zig-projects` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/packaging-zig-projects/SKILL.md`

**What this skill covers:**
The Zig offline build pattern used by Ghostty -- the most complex element in the repo (293 lines). Agents packaging any Zig project need to understand:
- Using a pre-built Zig SDK as `build-depends` (reference `bluefin/zig.bst`)
- Zig dependency caching: HTTP deps → `zig-deps/` directory, git deps → `place_git_dep()` shell function
- The `zig fetch --global-cache-dir` + `zig build --system` offline build pattern
- Source structure: one `tar` source for the project + N `remote` sources for zig deps + M `remote` sources for zig git deps
- Build flags: `-Doptimize=ReleaseFast -Dcpu=baseline -Dpie=true`
- GTK/Wayland/X11 integration flags
- `strip-binaries: ""` is NOT needed (Zig produces ELF binaries)

**Source material:** Read `elements/bluefin/ghostty.bst` (293 lines) and `elements/bluefin/zig.bst` (35 lines) as primary references.

**TDD steps:**

**Step 1 (RED): Run baseline test without skill**

Dispatch a subagent with this prompt (no skill loaded):
> "You are working in a BuildStream project. Write a .bst element to package a Zig project called 'river' (a Wayland compositor) that has 15 Zig dependencies fetched via HTTP and 2 git-based Zig dependencies. The project source is a tarball. Show the full element YAML."

Document what the agent gets wrong. Expected failures: wrong source structure, no offline cache setup, missing `zig fetch` step, incorrect `zig build` flags, no `place_git_dep()` pattern.

**Step 2 (GREEN): Write the skill**

Write `SKILL.md` addressing the specific failures from baseline. Include:
- YAML frontmatter: `name: packaging-zig-projects`, `description: Use when packaging a project that uses the Zig build system, when an element needs zig fetch/build, or when adding Zig dependencies to an existing element`
- Overview: what Zig offline builds are and why BuildStream needs them
- Template element YAML showing the source structure (tar + remote deps)
- The `place_git_dep()` function with explanation
- The `zig fetch` + `zig build --system` command sequence
- Common build flags table
- Dependency tracking note: Ghostty + Zig are NOT tracked by any automation (manual updates only)
- Cross-reference to `packaging-pre-built-binaries` for the Zig SDK element
- Common mistakes table

**Step 3 (GREEN): Verify with skill**

Re-run the same subagent prompt but with the skill loaded. Verify the agent produces correct element YAML.

**Step 4 (REFACTOR): Close loopholes**

If the agent missed anything (e.g., git dep handling, cache directory paths), add explicit guidance and re-test.

**Step 5: Commit**
```bash
git add .opencode/skills/packaging-zig-projects/SKILL.md
git commit -m "feat: add packaging-zig-projects skill"
```

---

### Task 2: Create `packaging-rust-cargo-projects` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/packaging-rust-cargo-projects/SKILL.md`

**What this skill covers:**
The Rust/Cargo pattern used by bootc, sudo-rs, and uutils-coreutils. Three real examples exist with increasing complexity:
- **sudo-rs** (40 lines): Simple binary install with setuid, small cargo2 dep list
- **uutils-coreutils** (1583 lines): Multi-call binary with symlink generation, ~500 cargo2 crates
- **bootc** (1358 lines): Complex with git-hosted crates in cargo2, custom make targets

Key patterns:
- Element kind is `make` (not `cargo`), overriding `build-commands` with `cargo build --release`
- `cargo2` source kind for offline dependency vendoring
- Some cargo2 entries use `kind: git` for git-hosted crates
- `gen_cargo_lock` source kind for generating Cargo.lock
- `files/scripts/generate_cargo_sources.py` helper script for generating cargo2 source lists
- Install patterns: single binary, multi-call binary + symlinks, setuid binaries
- `overlap-whitelist` for intentionally overriding upstream files (sudo-rs)
- `strip-binaries: ""` is NOT needed (Cargo produces ELF binaries)

**Source material:** Read `elements/bluefin/sudo-rs.bst`, `elements/bluefin/uutils-coreutils.bst`, `elements/core/bootc.bst`, and `files/scripts/generate_cargo_sources.py`.

**TDD steps:**

**Step 1 (RED): Run baseline test without skill**

Prompt:
> "You are working in a BuildStream project. Write a .bst element to package a Rust project called 'bat' (a cat replacement) that depends on 50 Rust crates. The project has a Cargo.toml and builds with `cargo build --release`. Show the full element YAML including how to handle the crate dependencies."

Expected failures: wrong element kind (cargo instead of make), missing cargo2 source pattern, no knowledge of generate_cargo_sources.py, incorrect install paths.

**Step 2 (GREEN): Write the skill**

- YAML frontmatter: `name: packaging-rust-cargo-projects`, `description: Use when packaging a Rust project with Cargo.toml, when an element needs cargo2 sources for offline builds, or when generating cargo dependency lists for BuildStream`
- Template for simple Rust binary (sudo-rs pattern)
- Template for multi-call binary with symlinks (uutils pattern)
- How to use `generate_cargo_sources.py` to create the cargo2 source list
- `overlap-whitelist` for replacing upstream binaries
- Setuid installation pattern
- Dependency tracking note: these elements are tracked by `bst source track` (manual-merge group for core/ elements, auto-merge for bluefin/ elements)
- Cross-reference to `buildstream-element-reference` for cargo2/gen_cargo_lock source kinds

**Step 3 (GREEN): Verify with skill**

**Step 4 (REFACTOR): Close loopholes**

**Step 5: Commit**

---

### Task 3: Create `packaging-gnome-shell-extensions` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/packaging-gnome-shell-extensions/SKILL.md`

**What this skill covers:**
7 GNOME shell extensions exist in the repo with 4 distinct build patterns:
1. **Make + jq UUID extraction** (search-light): `make` → extract UUID from metadata.json → copy to extensions dir
2. **Make + gschema recompile** (dash-to-dock): `make install` → move+recompile gschemas in extension dir; needs `sassc`
3. **Make + zip extraction** (blur-my-shell): `make` → extract `.shell-extension.zip` with `bsdtar` → compile schemas
4. **Manual + glib-compile-schemas** (logomenu): No make; compile schemas directly, copy files
5. **Meson** (gsconnect, app-indicators): Standard meson build, simplest pattern
6. **Pure config** (disable-ext-validator): No sources, inline `cat <<EOF` gschema override

Key patterns:
- UUID discovery: `jq -r '.uuid' metadata.json` → install to `%{datadir}/gnome-shell/extensions/<uuid>/`
- Schema compilation: `glib-compile-schemas --strict --targetdir=<dir> <dir>`
- `strip-binaries: ""` is required (extensions are JavaScript, not ELF)
- All extensions aggregate under `bluefin/gnome-shell-extensions.bst`
- Dependency tracking: all git-sourced extensions are in the `bst source track` auto-merge group

**Source material:** Read all files in `elements/bluefin/shell-extensions/`.

**TDD steps:**

**Step 1 (RED): Baseline test**

Prompt:
> "You are working in a BuildStream project. Write a .bst element to package a GNOME Shell extension called 'Tiling Assistant' from its git repo at https://github.com/Leleat/Tiling-Assistant. The extension has a Makefile and includes GSettings schemas. Show the full element YAML."

Expected failures: missing UUID extraction, wrong install path, missing schema compilation, missing strip-binaries.

**Step 2-5: GREEN/REFACTOR/Commit** (same pattern as above)

---

### Task 4: Create `packaging-go-projects` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/packaging-go-projects/SKILL.md`

**What this skill covers:**
Go packaging in BuildStream has three approaches (documented briefly in `buildstream-element-reference` but without templates). This skill provides complete templates for each:

1. **`make` + vendored deps** (simplest): When upstream vendors dependencies in the git repo. Most common in freedesktop-sdk (podman, skopeo). Uses standard `make` kind.
2. **`manual` + `go_module` sources**: One source entry per Go module dependency. Verbose but reproducible. Example: git-lfs in freedesktop-sdk (33 modules).
3. **`manual` + vendored tarball**: When deps are bundled in a separate tarball.

Key decisions:
- Go arch variable: `%{go-arch}` expands to `amd64`/`arm64`/`riscv64` (defined in project.conf)
- `GOFLAGS="-mod=vendor"` for vendored builds
- `CGO_ENABLED=0` for static builds
- `strip-binaries: ""` needed for statically-linked Go binaries (they're not standard ELF)
- Multi-arch dispatch needed if source URL contains arch string (same pattern as pre-built binaries)

**Source material:** Read Go-related entries in `elements/bluefin/buildstream-element-reference`, cross-reference with freedesktop-sdk junction for real examples.

**TDD steps:** Same RED/GREEN/REFACTOR pattern.

---

### Task 5: Create `oci-layer-composition` skill

**Skill type:** Reference (documentation)

**Files:**
- Create: `.opencode/skills/oci-layer-composition/SKILL.md`

**What this skill covers:**
How `elements/oci/` and `elements/oci/layers/` assemble the final OCI image. This is the "last mile" -- understanding how individual packages flow through the layer chain into a bootable container image.

Key concepts:
- The full layer chain: element → `deps.bst` → `bluefin-stack.bst` → `bluefin-runtime.bst` → `oci/layers/bluefin.bst` → `oci/bluefin.bst`
- **stack** elements: aggregate dependencies (no filtering)
- **compose** elements: filter artifacts by split domain (exclude `devel`, `debug`, `extra`, `static-blocklist`)
- **collect_initial_scripts**: collects first-boot scripts from dependency tree
- **script** elements: OCI assembly using `build-oci` heredoc with `prepare-image.sh`
- Two-stage compose: `bluefin-runtime.bst` (excludes devel) → `bluefin.bst` (further excludes extra)
- Parent layer pattern: `oci/bluefin.bst` layers on top of `oci/gnomeos.bst`
- OCI labels: `containers.bootc: 1`, `ostree.bootable: true`
- `fakecap` LD_PRELOAD for capability emulation in sandbox
- `os-release.bst`: generates `/usr/lib/os-release` from environment variables
- `glib-compile-schemas` run in the OCI assembly script (not per-element)

**Source material:** Read all files in `elements/oci/` and `elements/oci/layers/`.

**TDD steps:** Same pattern. Baseline prompt: "Explain how to add a new filesystem layer to the Bluefin OCI image."

---

### Task 6: Create `patching-upstream-junctions` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/patching-upstream-junctions/SKILL.md`

**What this skill covers:**
How to apply patches to freedesktop-sdk or gnome-build-meta elements without forking the upstream project. This uses the `patch_queue` source kind.

Key concepts:
- Junction elements: `elements/freedesktop-sdk.bst` and `elements/gnome-build-meta.bst` pin upstream refs
- `patch_queue` source kind applies a directory of patches to junction elements
- Patches live in `patches/freedesktop-sdk/` and `patches/gnome-build-meta/`
- When to patch: fixing bugs, adding build flags, changing dependencies, backporting fixes
- When NOT to patch: better to override the element entirely (create in `elements/core/`)
- Override pattern: create `elements/core/<name>.bst` that replaces the junction element
- The junction override mechanism in project.conf

**Source material:** Read `patches/` directory structure, junction elements, and `project.conf` override config.

**TDD steps:** Same pattern. Baseline prompt: "The upstream freedesktop-sdk element for package X has a bug. How do I patch it in bluefin-egg?"

---

### Task 7: Create `removing-packages` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/removing-packages/SKILL.md`

**What this skill covers:**
Safely removing a package from the Bluefin image. The reverse of `adding-a-package`.

Key steps:
1. Remove from `elements/bluefin/deps.bst` (or appropriate stack)
2. Delete the element file(s) from `elements/bluefin/` or `elements/core/`
3. Remove any source aliases from `include/aliases.yml` (if only used by this element)
4. Remove from tracking workflow groups in `.github/workflows/track-bst-sources.yml` (if tracked)
5. Remove from Renovate config if applicable
6. Check for reverse dependencies: `grep -r "bluefin/<name>.bst" elements/`
7. Clean up any files in `files/` that were only used by this element
8. Clean up any patches in `patches/` that were only for this element

Common mistakes:
- Forgetting to remove from tracking workflow (creates cron failures)
- Forgetting to check reverse dependencies (breaks other elements)
- Removing a source alias still used by other elements

**TDD steps:** Same pattern. Baseline prompt: "Remove Tailscale from the Bluefin image. What files need to change?"

---

### Task 8: Create `updating-upstream-refs` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/updating-upstream-refs/SKILL.md`

**What this skill covers:**
How the three dependency tracking mechanisms work and how to manually update when automation is insufficient.

Key concepts:
- **Junction ref updates**: Changing `ref:` in `gnome-build-meta.bst` or `freedesktop-sdk.bst` to track new upstream commits
- **`bst source track`**: How it works, what it updates, the auto-merge vs manual-merge distinction
- **Manual tarball updates**: Changing `url:` and `ref:` (SHA256) for tar/remote sources
- **Renovate custom managers**: How the regex matchers work, what they track, how to add new patterns
- **Version bump workflow**: bump version in URL → update SHA256 ref → test build → commit

**Source material:** Read `.github/workflows/track-bst-sources.yml` and `.github/renovate.json5`.

**TDD steps:** Same pattern. Baseline prompt: "Tailscale released v2.0.0. How do I update the Bluefin image to use it?"

---

### Task 9: Create `debugging-bst-build-failures` skill

**Skill type:** Technique (how-to guide)

**Files:**
- Create: `.opencode/skills/debugging-bst-build-failures/SKILL.md`

**What this skill covers:**
Diagnosing and fixing BuildStream build failures. The most common operational task.

Key techniques:
- Reading build logs: `just bst artifact log <element>`
- Interactive debugging: `just bst shell <element>` to get a shell in the build sandbox
- Dependency inspection: `just bst show <element>` to see resolved deps, variables, commands
- Common failure modes:
  - Source fetch failures (network, wrong ref, expired URL)
  - Build command failures (missing deps, wrong flags, sandbox restrictions)
  - Install failures (wrong paths, permission issues, missing dirs)
  - Compose/filter failures (split domain issues, missing artifacts)
  - Cache corruption (stale artifacts, hash mismatches)
- CI-specific debugging: reading workflow logs, cache proxy logs, artifact push failures
- The `on-error: continue` CI setting and what it means for failure diagnosis

**Source material:** Read `local-e2e-testing` skill for build commands, `.github/workflows/build-egg.yml` for CI context.

**TDD steps:** Same pattern. Baseline prompt: "My BuildStream element fails with 'No such file or directory' during install-commands. How do I debug this?"

---

### Task 10: Create `ci-pipeline-operations` skill

**Skill type:** Reference (documentation)

**Files:**
- Create: `.opencode/skills/ci-pipeline-operations/SKILL.md`

**What this skill covers:**
The CI/CD pipeline from end to end -- what happens when code is pushed, how caching works, how to debug CI failures, and how to operate the pipeline.

Key concepts:
- Workflow structure: the 13 steps in `build-egg.yml` and what each does
- Artifact caching: GNOME upstream CAS (read-only) + project R2 cache (read-write on main)
- `bazel-remote` as CAS-to-S3 bridge: how it works, ports, network config
- CI-specific BuildStream config: `on-error: continue`, `fetchers: 32`, `builders: 1`
- PR vs main differences: PRs don't push to cache, don't push to GHCR
- `bootc container lint`: what it validates
- Secrets and permissions: R2 keys, GHCR push, what's safe for fork PRs
- Debugging CI: where to find logs (build logs artifact, cache proxy logs), common failures
- The disk space reclamation step and why it's critical

**Source material:** Read `.github/workflows/build-egg.yml` and `docs/plans/2026-02-14-cloudflare-r2-cache.md` and `docs/plans/2026-02-14-github-actions-ci.md`.

**TDD steps:** Same pattern. Baseline prompt: "The CI build failed on a PR. How do I find and diagnose the failure?"

---

### Task 11: Update `adding-a-package` skill

**Files:**
- Modify: `.opencode/skills/adding-a-package/SKILL.md`

**Changes:**
1. Update the decision tree to add "Zig project" path → `manual kind + zig build` → link to `packaging-zig-projects`
2. Add sub-skill references for each documented path:
   - Pre-built binary → `packaging-pre-built-binaries` (already there)
   - Zig project → `packaging-zig-projects` (new)
   - Rust/Cargo → `packaging-rust-cargo-projects` (new)
   - Go project → `packaging-go-projects` (new)
   - GNOME Shell extension → `packaging-gnome-shell-extensions` (new)
3. Replace "Not Yet Documented" section with cross-references to the new skills
4. Add link to `oci-layer-composition` for understanding the layer chain
5. Add link to `removing-packages` for the reverse workflow
6. Add link to `patching-upstream-junctions` for junction patches

**TDD:** Baseline prompt: "I want to add a Zig project to the Bluefin image. Walk me through the process." Verify the skill now routes correctly.

---

### Task 12: Update `buildstream-element-reference` skill

**Files:**
- Modify: `.opencode/skills/buildstream-element-reference/SKILL.md`

**Changes:**
1. Add `collect_initial_scripts` to Element Kinds table
2. Add Zig build pattern to Element Kinds (or add note pointing to `packaging-zig-projects`)
3. Expand Go Packaging Approaches section with cross-reference to `packaging-go-projects`
4. Add `remote` source with `directory:` option to Source Kinds (used by Ghostty zig deps)
5. Add note about `generate_cargo_sources.py` helper in cargo2 section
6. Add `overlap-whitelist` to Variables table
7. Ensure the Rust/cargo pattern is represented (kind: `make` with `cargo2`, not `cargo`)

**TDD:** Baseline prompt: "What element kind and source kinds do I use for a Rust project in BuildStream?" Verify answer is accurate after update.

---

### Task 13: Update `local-e2e-testing` skill

**Files:**
- Modify: `.opencode/skills/local-e2e-testing/SKILL.md`

**Changes:**
1. Add cross-reference to `debugging-bst-build-failures` for when builds fail
2. Add brief section on cache warming: first build is slow (~2 hours), subsequent builds with warm cache are fast
3. Add note about `bst artifact delete` for reclaiming disk space
4. Add link to `ci-pipeline-operations` for understanding the full CI pipeline

**TDD:** Verify skill still reads cleanly and cross-references resolve.

---

### Task 14: Update `packaging-pre-built-binaries` skill

**Files:**
- Modify: `.opencode/skills/packaging-pre-built-binaries/SKILL.md`

**Changes:**
1. Add dependency tracking note: Tailscale (and similar pre-built binaries) are NOT tracked by any automation. Updates are manual: bump version in URL, update SHA256 ref, test build.
2. Add note about the Zig SDK (`bluefin/zig.bst`) as an example of a pre-built compiler that follows this same pattern
3. Add cross-reference to `updating-upstream-refs` for the version bump workflow

**TDD:** Verify the dependency tracking guidance is clear and actionable.

---

### Task 15: Update AGENTS.md skill index

**Files:**
- Modify: `AGENTS.md`

**Changes:**
Add all new skills to the "Superpowers Skill System" table in AGENTS.md:

| Skill | When |
|---|---|
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

Also update the Repository Layout section to mention the new skills count.

---

## Execution Notes

### Parallelism

Tasks 1-10 (new skills) are independent of each other and can be dispatched in parallel. However, each skill requires the TDD cycle (baseline → write → verify → refactor), so a single agent should handle each skill end-to-end.

Tasks 11-14 (updates) depend on Tasks 1-10 completing first, since they add cross-references to the new skills.

Task 15 (AGENTS.md) depends on all previous tasks.

### TDD Compliance

Every task follows the `writing-skills` TDD cycle. The specific testing approach for reference/technique skills:
1. **Baseline test (RED)**: Dispatch subagent with scenario prompt, no skill loaded. Document failures.
2. **Write skill (GREEN)**: Address specific baseline failures. Run same prompt with skill loaded.
3. **Close loopholes (REFACTOR)**: Fix any remaining gaps, re-test.

### Commit Strategy

One commit per task. Convention: `feat: add <skill-name> skill` for new skills, `feat: update <skill-name> skill with <what>` for updates.

## Future Work (Out of Scope)

- **Renovate expansion**: Add custom managers for Tailscale, Ghostty, Zig, ghostty-gobject. Tracked as a separate plan.
- **Automated testing harness for skills**: Currently manual subagent testing. Could be automated.
