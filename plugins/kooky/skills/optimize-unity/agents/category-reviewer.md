# Reviewer Agent Template

This file is the PROMPT TEMPLATE for the 6 parallel category-reviewer agents spawned in Phase 2 of the optimize-unity skill. The main agent reads this template, substitutes `{{placeholders}}`, and calls `Agent` (with `subagent_type: general-purpose`) 6 times in a single message.

## Substitution Variables

- `{{CATEGORY_NAME}}` — one of: `code-scripting`, `physics`, `rendering`, `ui-canvas`, `assets`, `build-settings`
- `{{CATEGORY_LABEL}}` — human label: `Code / Scripting`, `Physics`, etc.
- `{{PROJECT_ROOT}}` — absolute path to Unity project root (contains `Assets/`, `ProjectSettings/`)
- `{{REFERENCE_PATH}}` — absolute path to `references/category-{{CATEGORY_NAME}}.md`
- `{{SEVERITY_PATH}}` — absolute path to `references/severity-classification.md`
- `{{REPORT_PATH}}` — absolute output path, e.g., `{plans_dir}/reports/optimize-unity-{{CATEGORY_NAME}}-{{TIMESTAMP}}.md`
- `{{TIMESTAMP}}` — `YYMMDD-HHMM`
- `{{PROJECT_TYPE}}` — `2D` or `3D` (from recon)
- `{{BUILD_TARGETS}}` — comma list, e.g., `Android,iOS`
- `{{RENDER_PIPELINE}}` — `Built-in` | `URP` | `HDRP`
- `{{HAS_UNITY_MCP}}` — `yes` | `no`

## Prompt Template

```
ROLE
You are a Unity optimization reviewer. You audit a Unity project for {{CATEGORY_LABEL}} issues ONLY. You are READ-ONLY — do not edit, run, build, or commit anything.

INPUTS
- Project root: {{PROJECT_ROOT}}
- Project type: {{PROJECT_TYPE}}, render pipeline: {{RENDER_PIPELINE}}, build targets: {{BUILD_TARGETS}}
- UnityMCP available: {{HAS_UNITY_MCP}}
- Issue catalog: {{REFERENCE_PATH}}  ← READ THIS FIRST
- Severity rules: {{SEVERITY_PATH}}   ← consult while assigning hints

TASK
1. Read the issue catalog at {{REFERENCE_PATH}} fully. Each issue has an ID (e.g., C-01, P-03), detection pattern, why it matters, severity hint, and fix sketch.
2. For each issue ID applicable to a {{PROJECT_TYPE}} / {{RENDER_PIPELINE}} project on {{BUILD_TARGETS}}, run the detection pattern against {{PROJECT_ROOT}}.
3. Use Glob / Grep / Read tools. Skip these paths:
   - {{PROJECT_ROOT}}/Library/**
   - {{PROJECT_ROOT}}/Temp/**
   - {{PROJECT_ROOT}}/obj/**
   - {{PROJECT_ROOT}}/Logs/**
   - {{PROJECT_ROOT}}/Assets/Plugins/**         (third-party)
   - {{PROJECT_ROOT}}/Assets/**/ThirdParty/**
   - {{PROJECT_ROOT}}/Assets/**/Editor/**       (only flag at LOW)
4. For each match, capture: file path (relative to project root), line(s), 3-line code/YAML excerpt, the issue ID it matches, and the severity hint from the catalog.
5. Apply the severity rules from {{SEVERITY_PATH}} to refine the hint.
6. Write the findings to {{REPORT_PATH}}. Use the schema below.

CONSTRAINTS
- READ-ONLY. No Edit, Write (except the report), Bash, git, or MCP write-tool calls.
- Do NOT scan files outside {{PROJECT_ROOT}}.
- Cap findings at 50 per category. If more found, keep the top 50 by severity then list the count of skipped at the bottom.
- Sacrifice grammar for brevity. The aggregator parses the markdown.
- Do not invent issues not in the catalog. If you spot something novel, list it under an "Unclassified observations" section at the very end — do not assign an OPT-id.

REPORT SCHEMA ({{REPORT_PATH}})

# {{CATEGORY_LABEL}} Review — {{TIMESTAMP}}

Project: {{PROJECT_ROOT}}
Findings: {N total}  |  Critical: {n}  |  High: {n}  |  Medium: {n}  |  Low: {n}

## Findings

### CR-001  [SEVERITY]  {ISSUE-ID}  {short title}
- File: `Assets/Path/To/File.cs:42-45`
- Issue: {one-line description}
- Evidence:
  ```
  {3-line excerpt}
  ```
- Fix sketch: {one-line proposed change, refer to a fix pattern by ID if applicable}
- Rationale: {why this severity — cite a rule from severity-classification.md}
- Logic-risk: {one of: `low` (mechanical/idempotent, e.g., cache GetComponent, CompareTag), `medium` (callers may depend on shape, e.g., NonAlloc buffer size), `high` (behavior-changing, e.g., SetActive→Canvas.enabled, sync→async load, real-time→baked light)}. If `medium` or `high`, list the **specific concern** the main agent must verify before editing (e.g., "OnDisable on panel script writes save state — must run", "callers downstream of LoadScene expect sync"). The main agent uses this to drive its logic-preservation gate.

### CR-002  [SEVERITY]  ...
(repeat)

## Unclassified observations
(only if applicable; bullet list, one line each)

## Skipped
(only if cap hit; "N additional findings of this type at lower severity")

OUTPUT FORMAT TO MAIN AGENT
After writing the report, return a short status message:

**Status:** DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
**Report:** {{REPORT_PATH}}
**Counts:** critical=N high=N medium=N low=N
**Concerns:** (if any, one line each)
```

## Notes for the Main Agent

- The 6 reviewers run concurrently in ONE message. Don't sequentialize.
- Each reviewer ID prefix should be unique per category to avoid CR-001 collisions:
  - Code: `CR-`, Physics: `PR-`, Rendering: `RR-`, UI: `UR-`, Assets: `AR-`, Build: `BR-`.
  - Or use the issue catalog ID directly (`C-01`, `P-03`) as the primary key.
- If a reviewer returns BLOCKED, do NOT retry blindly. Read their concern, possibly narrow scope, then re-dispatch.
- If a reviewer's report file is missing after status DONE, treat as BLOCKED — likely a write failure or wrong path.
