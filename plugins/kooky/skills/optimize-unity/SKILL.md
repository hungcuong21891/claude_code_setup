---
name: optimize-unity
description: Audit and fix Unity project performance — caches GetComponent/Camera.main, eliminates per-frame allocations, fixes physics layer matrix and collider choices, tunes batching/GPU instancing/lights, splits canvases, sets texture/audio import settings, switches to IL2CPP. Use when the user says "optimize Unity", "fix lag/stuttering", "audit FPS", "Unity performance review", "reduce GC spikes", or invokes /optimize-unity. Triggers parallel category reviewers → severity-classified report → user can re-review until satisfied → user decision (fix all / critical+high / custom) → applies fixes via Edit and UnityMCP.
---

# Optimize Unity

## Overview

End-to-end Unity performance audit and remediation. Spawns parallel category-specific reviewer agents that scan the project against a bundled checklist of 60+ patterns from the "Optimize Your Games In Unity – The Ultimate Guide" tutorial, aggregates findings into a severity-classified report (CRITICAL / HIGH / MEDIUM / LOW), then applies fixes the user approves.

## Workflow

### Phase 1 — Reconnaissance

Before spawning reviewers, gather context:

1. Confirm CWD is a Unity project — look for `ProjectSettings/ProjectVersion.txt`, `Assets/`, `Packages/manifest.json`. If missing, ask the user for the project root.
2. Detect Unity version from `ProjectSettings/ProjectVersion.txt` (line `m_EditorVersion:`). Note major version (2021 / 2022 / 6000.x) — affects which patterns apply.
3. Detect render pipeline — check `Packages/manifest.json` for `com.unity.render-pipelines.universal` or `.high-definition`, otherwise built-in. URP/HDRP have different batching/lighting rules.
4. Detect UnityMCP availability — list available tools and look for `mcp__*unity*` entries. If present, prefer UnityMCP for asset import settings and ProjectSettings edits.
5. Identify hot folders — `Assets/Scripts/`, `Assets/Prefabs/`, `Assets/Scenes/`, `Assets/Materials/`, `Assets/Textures/`, `Assets/Audio/`. Skip third-party `Assets/Plugins/`, `Assets/ThirdParty/`, anything under `Packages/` unless user requests.

Report Phase 1 findings to the user in one paragraph: project path, Unity version, render pipeline, UnityMCP available y/n, # of C# scripts, # of prefabs, # of scenes.

### Phase 2 — Parallel Category Review

Spawn **6 reviewer agents in a single message** (subagent_type: `general-purpose`). Each owns one category and reads only files in its scope. Use the prompt template in `agents/category-reviewer.md` — substitute the category, scope globs, checklist path, and output file.

| Agent | Category | Checklist | Scope |
|-------|----------|-----------|-------|
| 1 | code-scripting | `references/category-code-scripting.md` | `Assets/**/*.cs` (exclude `Editor/`, `Plugins/`, `ThirdParty/`) |
| 2 | physics | `references/category-physics.md` | `Assets/**/*.cs`, `Assets/**/*.prefab`, `ProjectSettings/DynamicsManager.asset` |
| 3 | rendering | `references/category-rendering.md` | `Assets/**/*.mat`, `Assets/**/*.unity`, `Assets/**/*.prefab`, `ProjectSettings/QualitySettings.asset` |
| 4 | ui-canvas | `references/category-ui-canvas.md` | `Assets/**/*.prefab`, `Assets/**/*.unity` (Canvas hierarchies), UI scripts |
| 5 | assets | `references/category-assets.md` | `Assets/**/*.png`, `*.jpg`, `*.tga`, `*.wav`, `*.mp3`, `*.ogg`, `*.fbx`, and their `.meta` siblings |
| 6 | build-settings | `references/category-build-settings.md` | `ProjectSettings/*.asset` (especially `PlayerSettings`, `QualitySettings`, `GraphicsSettings`) |

Each reviewer writes one report to `{project}/plans/reports/optimize-unity-{category}-{date}.md` using the schema in `agents/category-reviewer.md` (issue IDs like `C-01`, `P-03`, `R-07`, file path + line + snippet + suggested fix).

**Catalog-only scope (hard rule).** Every finding MUST map 1:1 to a Catalog ID defined in the matching `references/category-*.md`. Reviewers drop any candidate that does not map — no "unclassified" / "miscellaneous" / novel-pattern entries. The aggregator must reject any reviewer row missing a `Catalog:` field. If a reviewer report contains rows without a Catalog ID, treat them as invalid and exclude them from the aggregated table.

**Do NOT let reviewers edit any source files.** They are read-only — they only emit reports.

### Phase 3 — Aggregate & Classify

After all 6 reviewers complete:

1. Read every report.
2. Apply severity rules from `references/severity-classification.md` — use the issue-to-severity quick map first, then apply override rules (hot-path promotion, layer-matrix promotion, etc.).
3. Deduplicate — same Catalog ID + same file = one entry. Group multiple instances by file.
4. **Validate every row against the catalog.** Drop any row that is missing a Catalog ID or whose Catalog ID is not present in the matching `references/category-*.md`. The aggregated report must NOT contain any non-catalog findings.
5. Build a single summary table. The `Catalog` column is mandatory and points to the exact ID in `references/category-{category}.md`.

```
| ID    | Catalog | Severity | File:Line                          | Issue                          | Fix Source        |
|-------|---------|----------|------------------------------------|--------------------------------|-------------------|
| C-01  | C-01    | CRITICAL | Assets/Scripts/Enemy.cs:42         | GetComponent in Update         | fix-patterns#C-01 |
| P-03  | P-03    | HIGH     | Assets/Prefabs/Bullet.prefab       | MeshCollider on dynamic body   | fix-patterns#P-03 |
...
```

When the reviewer's local ID equals the Catalog ID (the common case) both columns will match — that is expected. If a reviewer used a category-prefixed local ID (e.g. `CR-001`), keep the local ID in the `ID` column and put the catalog reference (e.g. `C-01`) in the `Catalog` column.

6. Cap the CRITICAL section — if more than 15 entries, demote the lowest-impact ones to HIGH per the cap rule. Per-frame GC allocs and hot-path GetComponent calls always stay critical.
7. **Generate HTML report.** Read the template at `assets/report-template.html`, substitute placeholders, write to `{project}/plans/reports/optimize-unity-report-{date}.html`. Placeholders:

   - `__PROJECT_NAME__` — folder name of project root
   - `__UNITY_VERSION__` — from `ProjectVersion.txt`
   - `__RENDER_PIPELINE__` — `URP` / `HDRP` / `Built-in`
   - `__GENERATED_AT__` — ISO date+time
   - `__COUNTS_CRITICAL__`, `__COUNTS_HIGH__`, `__COUNTS_MEDIUM__`, `__COUNTS_LOW__` — integers
   - `__ISSUES_JSON__` — JSON array (one object per issue). Schema:
     ```json
     [{"id":"C-01","catalogId":"C-01","severity":"CRITICAL","category":"code-scripting","file":"Assets/Scripts/Enemy.cs","line":42,"issue":"GetComponent called in Update","snippet":"void Update(){ GetComponent<Rigidbody>().AddForce(...); }","fix":"Cache reference in Awake/Start"}]
     ```
   - `catalogId` is **required** and must exactly match an ID in the matching `references/category-{category}.md` (formats: `C-01`, `P-03`, `R-07`, `U-04`, `A-02`, `B-01`). Drop any issue lacking a valid `catalogId` before embedding.
   - `category` values must be one of: `code-scripting`, `physics`, `rendering`, `ui-canvas`, `assets`, `build-settings` (matches the dropdown).
   - Embed the JSON directly inside the `<script id="issues-data">` tag — no escaping beyond valid JSON.

Present the markdown table to the user inline AND link the HTML report path. Include counts (`CRITICAL: 7, HIGH: 14, MEDIUM: 22, LOW: 9`).

### Phase 4 — User Decision (with re-review loop)

Use `AskUserQuestion` with these options:

- **Critical + High only** (Recommended) — skip MEDIUM and LOW
- **Fix all** — apply every fix
- **Critical only** — minimum risk, maximum gain
- **Custom selection** — user names specific IDs
- **Review again** — re-run Phase 2 + 3 to catch anything missed before fixing

If **Review again** is chosen:

1. Ask a scope follow-up via `AskUserQuestion`: "Same scope, or refocus?"
   - **Same scope** — re-run all 6 reviewers across the entire project (catches anything missed; reviewers are non-deterministic).
   - **Pick categories** — user names categories to re-scan (e.g. `code-scripting, ui-canvas`).
   - **Pick files/folders** — user names file globs to focus on (e.g. `Assets/Scripts/Combat/**`).
   - **Deepen low-confidence findings** — re-examine only the issues flagged as `uncertain` or where the previous reviewer reported low confidence.
2. Re-spawn only the relevant reviewers from Phase 2 with the new scope. Use a NEW report filename per pass: `optimize-unity-{category}-{date}-r{N}.md` where N = pass number (r1 = first re-review, r2 = second, …).
3. Merge findings: keep all prior findings, append new ones, dedupe by `(issue_id, file, line)`. New-only findings are tagged `new in r{N}` in the aggregated table so the user can spot what the re-review caught.
4. Re-aggregate per Phase 3. Generate a NEW aggregated HTML report named `optimize-unity-report-{date}-r{N}.html`. Show both the cumulative count and the delta versus previous pass (e.g. `CRITICAL: 7 (+2), HIGH: 14 (+0), MEDIUM: 22 (+3), LOW: 9 (+1)`).
5. Return to the top of Phase 4. Loop until the user picks one of the four fix actions.

There is no hard cap on re-reviews. After 2 consecutive passes with zero new findings, surface a one-line note: "Two passes with no new findings — consider moving to fix selection." Do not force the choice.

After the user picks a fix action (non-review), if **Custom selection**, ask a follow-up: "Which issue IDs? (comma-separated, e.g. C-01, R-03, U-05)".

### Phase 5 — Apply Fixes

**Guiding principle — logic preservation is non-negotiable.** Every fix MUST keep the existing program behavior identical except for the targeted performance characteristic. If you cannot prove preservation for a specific finding, do NOT edit — record it under `uncertain` and explain why in the summary.

For every selected issue:

0. **Logic-Preservation Gate (run BEFORE any edit).** Read the full enclosing method/class for code fixes, or the full component block for asset/scene edits. Then confirm ALL of the following:
   - **Semantic equivalence** — Before/After produce the same observable behavior (same side-effects, same return values, same event firings, same lifecycle order). Ex: `SetActive(false)` → `Canvas.enabled = false` is NOT equivalent if `OnDisable`/`OnEnable` are wired up.
   - **Reference timing** — for caching fixes (`C-01`, `C-02`, `C-03`, `C-12`), the cached reference is valid at the call site (the GameObject exists, the tag is set, the Camera is spawned before `Awake`).
   - **No stale state** — for collision-callback reuse (`P-05`) or NonAlloc buffers (`C-08`), no code stores the parameter/buffer across frames.
   - **No external assumptions** — no other script reads/writes the same field with a conflicting expectation (e.g., raycastTarget toggled at runtime, scriptingBackend gated by `#if MONO`, etc.).
   - **Idempotency check** — if the fix is already in place (cached field already declared, flag already set, snippet already matches "After"), mark `already-applied` and move on.
   
   Decision rule:
   - All five checks **pass** → apply the fix.
   - Any check **fails** with a clear conflict → mark `manual` with the conflict cited.
   - Any check is **inconclusive / requires runtime knowledge you don't have** → mark `uncertain`. Do NOT apply. Record file, line, finding ID, and the specific doubt (one sentence).
   
   When in doubt, choose `uncertain`. A skipped fix is recoverable; a behavior regression is not.

1. Look up the recipe in `references/fix-patterns.md` by ID. Re-read the `R:` (risk) line — it lists the failure modes that map to the gate checks above.
2. **For code (`C-*`, `U-*` script-side, `P-*` script-side)** — use `Edit` on the C# file. Apply the Before/After snippet exactly. Verify the edit compiled-clean by reading surrounding context first.
3. **For asset import settings (`A-*`, `R-*` material flags)** — prefer UnityMCP if available (`set_asset_import_settings` or equivalent). If not, edit the `.meta` YAML directly but ONLY the documented keys — never reformat the file.
4. **For ProjectSettings (`B-*`, `P-*` global)** — UnityMCP only. If unavailable, output the exact change for the user to apply in Editor (Edit > Project Settings) and mark the issue as "manual".
5. **For prefab/scene edits (`U-*` canvas restructure, `P-*` collider swap)** — UnityMCP only. Without it, report as "manual" with step-by-step Editor instructions.

Rules:
- One file = one atomic Edit. No batched multi-file rewrites.
- Idempotent — if the fix is already applied (e.g. `transform` already cached), skip and note "already fixed".
- Never apply a fix marked `R: high risk` without confirming with the user first.
- **Behavior-changing fixes** (those whose `R:` line warns about lifecycle, callback semantics, or pause/timing — e.g., `U-03`, `C-10`, `A-07`, `P-05`) ALWAYS require explicit user confirmation per-finding before applying. If the user does not confirm, mark `uncertain`.
- Track applied / skipped / manual / **uncertain** counts. `uncertain` is its own bucket — it is NOT a synonym for `skipped` (which means already-applied / pattern-not-unique / user-deselected).

### Phase 6 — Summary (HTML output)

Write a final report to `{project}/plans/reports/optimize-unity-summary-{date}.html` as **self-contained HTML** (inline CSS, no external assets, no JS required). Markdown summaries are deprecated — always emit `.html`.

Use the template at `assets/summary-template.html` as the skeleton. Substitute placeholders:

- `__PROJECT_NAME__`, `__UNITY_VERSION__`, `__RENDER_PIPELINE__`, `__GENERATED_AT__` (ISO date+time)
- `__SCOPE_APPLIED__` — e.g. `CRITICAL + HIGH`, `Critical only`, `Custom (C-01, R-03)`
- `__COUNTS_CRITICAL__`, `__COUNTS_HIGH__`, `__COUNTS_MEDIUM__`, `__COUNTS_LOW__`
- `__COUNTS_APPLIED__`, `__COUNTS_MANUAL__`, `__COUNTS_SKIPPED__`, `__COUNTS_UNCERTAIN__`
- `__CATEGORY_ROWS__` — `<tr><td>code-scripting</td><td>13</td><td>0</td><td>13</td></tr>` per category
- `__APPLIED_ROWS__` — one `<tr>` per applied fix with: ID · Severity badge · File · Change description
- `__SCRIPT_DIFFS_HTML__` — one `<div class="diff-card">` per **script** fix (any code-scripting fix that edited a `.cs` file). Each card contains: header (ID · Severity badge · File:Line) + side-by-side Before/After `<pre>` blocks with the actual old and new code snippets that were applied. **Material/asset/audio/prefab/ProjectSettings fixes do NOT get a diff card** — they have no code to show. Use the exact code snippets from the Edit operations (do not paraphrase). Wrap the cards in the container `<div class="diffs">__SCRIPT_DIFFS_HTML__</div>`.
- `__MANUAL_ROWS__` — one `<tr>` per manual item with: ID · Severity · Where · Action
- `__UNCERTAIN_ROWS__` — one `<tr>` per **uncertain** finding (logic-preservation gate failed inconclusively): ID · Severity · File · **Concern** (one-sentence reason the fix was NOT applied) · Suggested-review-action. This is the most important table for the user — they decide whether to apply manually after review.
- `__FILES_TOUCHED_HTML__` — `<li>` items inside `<ul>`
- `__VERIFICATION_HTML__` — `<ol>` of verification steps (Profiler paths, scenes to playtest)
- `__EXPECTED_GAINS_HTML__` — `<ul>` of expected wins per fix family
- `__REPORTS_REFERENCED_HTML__` — `<li>` links to the 6 category reports + aggregated HTML report

Required sections in the rendered HTML (in this order):
1. Header — title, project meta, scope applied
2. Counts grid — severity tiles + applied/manual/skipped/**uncertain**
3. Per-category outcome — table
4. Applied fixes — table grouped by category (code / materials / assets) using `<tbody>` separators
5. **Applied script fixes — code diffs** — Before/After snippets for every script edit (cards from `__SCRIPT_DIFFS_HTML__`)
6. **Uncertain — NOT applied (logic-preservation concerns)** — table from `__UNCERTAIN_ROWS__`. Render even if empty (show "None" placeholder row). These are findings the skill detected but could not prove safe to auto-fix; the user must review each manually.
7. Manual / out-of-scope items — table grouped by category
8. Verification steps — ordered list
9. Files touched — code block
10. Expected gains — bullet list
11. Reports referenced — link list

**Diff card content rules:**
- Use the literal code that was replaced (Before) and the literal code that replaced it (After).
- Escape HTML entities (`<`, `>`, `&`) inside `<pre>` blocks.
- For fixes that touched multiple sites in one file (e.g. 6× `Camera.main` cached), show one representative Before/After pair, then a short note like `<div class="diff-note">+ 5 more identical sites in this file</div>`.
- For supporting infrastructure (e.g. helper methods added), show the new method body only with label "Added" instead of Before/After.

Severity styling: red badge for CRITICAL, orange for HIGH, blue for MEDIUM, gray for LOW.

After writing, tell the user the HTML path and remind them to run the Profiler (Window > Analysis > Profiler) to verify gains. The HTML opens directly in any browser (no server needed).

## Resources

- `references/category-*.md` — six per-category checklists, each lists issue IDs, what to grep for, and the rationale
- `references/severity-classification.md` — severity definitions, override rules, issue-to-severity quick map
- `references/fix-patterns.md` — Before/After C# snippets, UnityMCP recipes, risk flags for every fixable issue
- `agents/category-reviewer.md` — prompt template for the 6 parallel reviewer agents; output schema and status footer convention
- `assets/report-template.html` — self-contained HTML report (CSS + JS inline) with severity filters, category dropdown, search, sortable columns; substitute placeholders in Phase 3 step 6
- `assets/summary-template.html` — self-contained HTML summary template (inline CSS, no JS) for Phase 6; severity badges, counts grid, applied/manual tables grouped by category
