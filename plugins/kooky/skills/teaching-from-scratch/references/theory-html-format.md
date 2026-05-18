# Theory HTML Format

Spec for the per-day theory HTML supplement rendered at the start of each day's Theory task.

## Purpose

A printable, browsable visual aid for the day's Background Theory. **Supplement only** — the teacher STILL walks every `### <Concept>` section inline in chat with Socratic checks. The HTML does NOT replace inline teaching. See `flows/daily-lesson-delivery.md` Step 2.

## When Rendered

**Once per day, in full**, at the FIRST entry into Step 2 (Theory task) of Daily Lesson Delivery — BEFORE walking the first concept inline.

At render time the teacher composes the full chat-walk-depth prose for **every** section in one pass and writes the complete HTML in one shot. This means the HTML is ready in the browser before the inline walk begins, and a learner reading only the HTML offline reaches the same depth of understanding as a learner who only saw the chat.

**Idempotency:** if the target HTML file already exists, skip generation and proceed directly to the inline walk. Do NOT regenerate on session resume mid-theory. Do NOT regenerate per session.

To force regeneration, the learner deletes the file manually (or asks the teacher to "remake the HTML for Day NN"); the next `--continue` re-renders.

## Output Path

`learning-plans/<goal-slug>/days/html/day-NN-<slug>.html`

The `days/html/` directory is created on first render. Filename mirrors the source markdown (`day-NN-<slug>.md` → `day-NN-<slug>.html`).

## Content Rules

The HTML contains ONLY theory prose. **NEVER Socratic-check blocks.** NEVER exercises, NEVER acceptance criteria, NEVER measurable-goal verification text, NEVER solutions. Socratic checks happen exclusively in chat — they do NOT appear in the HTML supplement.

Order of sections in the rendered page:
1. **Header** — day number, day title (from the `# Day NN — <Title>` line), phase label, measurable goal as a single italic line for context only (no checkboxes).
2. **Theory sections** — for each `### <Concept>` heading under `## Background Theory` in the source `.md`:
   - Heading (`<h2>`)
   - **Prose written at chat-walk depth, not source-`.md` depth.** The source `.md` is the *seed*; the HTML body must include the same expansions, analogies, framings, and gotchas the teacher would deliver live in chat for this section. If the chat walk would add a "two doors" framing, a comparison to EF Core, an extra paragraph warning about a downstream consequence — bake those into the HTML at render time. The HTML and the chat are two views of the **same** explanation, not two different summaries of the source `.md`.
   - Code blocks rendered as `<pre><code>` with monospace styling (no syntax-highlighter dependency). Include the same code blocks the teacher will use in chat (often a superset of the source `.md`'s code blocks).
   - Reference link rendered as a small `<a>` with text "Further reading" if present.
3. **Footer** — single sentence: "Theory supplement. Read alongside the chat walkthrough."

**Depth-parity rule (mandatory).** Before writing the file, draft each section's chat-walk content as if you were about to deliver it in chat — including the framing, the analogies, the gotchas, the "today's practical fact" anchor. Then commit that drafted content to the HTML. The yardstick: a learner who only reads the HTML offline reaches the same level of understanding as a learner who only saw the chat. If a section's HTML reads thinner than the chat would, the section is under-rendered and must be expanded before the file is opened.

**Mid-day clarifications.** If a learner asks a clarifying question in chat during the inline walk and the answer adds substantive new framing the up-front render did not anticipate, the teacher MAY rewrite that section's HTML body to incorporate it (and append a `theory-html-section-filled` log entry). This is exception-only — the default is one-shot full render up-front.

## Styling

Self-contained HTML. Inline `<style>` only. No external CSS, no CDN, no JS dependencies. The file MUST render correctly when double-clicked offline.

**Dark mode is mandatory.** All generated HTML uses the dark palette defined in `assets/theory-html-template.html` (deep slate background, light text, gold accent). Do NOT switch to a light theme — the template already includes a `@media print` block that maps the dark colors to a printable light variant automatically.

Baseline styles required:
- Dark background (~`#11161d`) with light body text (~`#dde3ec`); readable serif body (max-width ~72ch)
- Monospace code blocks on a slightly lighter dark surface with a subtle border
- Print-friendly: dark→light auto via `@media print` (no fixed-position elements)

Copy the scaffold from `assets/theory-html-template.html` verbatim. Do not invent a new palette per day.

## Key-Term Highlighting (mandatory)

Each `### <Concept>` section MUST highlight **3–7** key terms using the `.kw` span class:

```html
<span class="kw">DeclarativeBase</span>
<span class="kw">expire_on_commit=False</span>
```

Highlight rules:
- Pick **defining terms**, **must-know rules**, **gotchas**, and **"today's practical fact" anchor phrases**. Skip filler.
- Apply to inline prose, not inside `<pre><code>` blocks (code blocks are already visually distinct).
- Do NOT highlight more than ~7 spans per section — over-highlighting defeats the purpose.
- Already-emphasized phrases using `<strong>` (e.g. lead-in labels like "Today's practical fact:") need not be wrapped again — `<strong>` is styled separately.
- Inline `<code>` references to APIs do not need `.kw` wrapping; they already stand out via code styling. Use `.kw` for the *concept name* in the surrounding sentence instead.

## File Open

After write, open the file in the default browser:
- Windows: `Start-Process <path>` or `Invoke-Item <path>` (PowerShell)
- macOS: `open <path>`
- Linux: `xdg-open <path>`

If open fails (e.g. headless env), print the absolute path in chat and continue — the inline walk proceeds regardless.

## Logging

- Append a `theory-html-rendered` entry to `log.md` when the full HTML is written (one entry per render). Detail = relative HTML path; append " (via --html flag)" when triggered by the `--html` flow.
- Append a `theory-html-section-filled` entry only on the exception-path mid-day rewrite of a single section. Detail = section number + concept name. See `log-format.md`.

No tracker mutation — rendering does not tick any checkbox, update `Notes`, or change `Current day`.

## Failure Handling

If write fails (filesystem error, permission denied), tell the learner the path that failed and proceed with the inline walk. The HTML is a supplement; missing it does not block teaching.
