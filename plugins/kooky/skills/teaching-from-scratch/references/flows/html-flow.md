# HTML Flow (`--html`)

On-demand current-day HTML supplement render-or-link. Does NOT advance `Current day`, tick tasks, or trigger any part of the daily lesson loop. Pure utility: ensure the HTML supplement for the current day exists, then print its link.

## Preconditions

- Active `tracker.md` exists in CWD (or under a `learning-plans/<slug>/` subdirectory). If not, apologize and offer to run `--plan`. STOP.
- `Current day: N` field is readable from the tracker.

## Steps

### H1. Locate active plan + current day

1. Find `tracker.md` (CWD → `learning-plans/*/tracker.md`).
2. Read `Current day: N` and the active plan's `<goal-slug>` from the tracker header.
3. Resolve the day source file: `learning-plans/<slug>/days/day-NN-<title-slug>.md` (use `Glob` on `day-NN-*.md` to find the exact filename).
4. Resolve the target HTML path: `learning-plans/<slug>/days/html/day-NN-<title-slug>.html`.

### H2. Existence check (idempotent)

If the target HTML file already exists:
- Print the absolute path to chat as a `file://` link.
- Attempt to open in default browser (`Start-Process` on Windows, `open` on macOS, `xdg-open` on Linux). On failure, just print the path.
- Do NOT regenerate.
- Do NOT append a log entry (no new render happened).
- STOP — flow complete.

### H3. Render (only if file does not exist)

Render the HTML following `references/theory-html-format.md`:
- Self-contained dark-theme HTML, copy palette from `assets/theory-html-template.html`.
- Header: day number, day title, phase label, measurable goal as italic line.
- One `<section>` per `### <Concept>` heading under `## Background Theory` in the day source `.md`.
- Each section: heading, **chat-walk-depth prose** with 3–7 `<span class="kw">` highlights, code blocks as `<pre><code>`, optional "Further reading" link.
- **NO `.socratic-check` blocks. NO exercise content. NO acceptance criteria. NO solutions.** Theory-only.
- Footer: single italic line ("Theory supplement for Day NN. Read alongside the chat walkthrough.").

Create `days/html/` directory if it does not exist.

### H4. Open + log

1. Open the rendered file in the default browser (best-effort; print path on failure).
2. Append one `theory-html-rendered` entry to `log.md` with detail = relative HTML path + " (via --html flag)".
3. Commit per the Commit Protocol in `log-format.md`: `learn(<goal-slug>): theory-html-rendered — Day NN via --html flag`.

### H5. Return to chat

Print the file path and a one-line confirmation. Do NOT continue into Theory walk, Socratic checks, exercises, or any other part of the daily flow — `--html` is utility-only.

## Failure Handling

| Failure | Response |
|---------|----------|
| No active tracker | Apologize, offer `--plan`. STOP. |
| `Current day` missing/invalid | Apologize, ask learner to fix tracker. STOP. |
| Day source `.md` missing | Apologize, print expected path, suggest the learner restore or rerun `--plan`. STOP. |
| HTML write fails | Print the failing path + error to chat. Do NOT log. STOP. |
| Browser-open fails | Print the absolute path; treat as success (file is on disk). |

## Scope (Strict)

- Reads: tracker, day source `.md`.
- Writes: at most one `.html` file + one log line + one git commit.
- Does NOT: tick tracker tasks, change `Current day`, deliver theory in chat, ask Socratic questions, grade exercises, or enter any other flow.
