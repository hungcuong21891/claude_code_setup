# Evaluate Flow (flag: `--evaluate`)

Read-only debrief. NEVER advances `Current day`, ticks tasks, modifies tracker state, or grades the learner-as-person. The output is metric-driven; metrics describe the work product, not the human.

## Step E1 - Locate the Active Tracker

Same as Continue Flow Step C1 (0 active -> apologize and offer `--plan`; 1 -> use; 2+ -> ask which). See `continue-flow.md`.

## Step E2 - Determine the Completed-Days Set

Read tracker. Collect every Day `N` where `Status: done`. Call this set `C`. If `|C| == 0`, apologize: "Need at least one completed day to evaluate. Finish Day 1 first." Stop. If `|C| >= 1`, proceed; mention the scope explicitly: "Evaluating Days 1 through `max(C)` (`|C|` days)."

## Step E3 - Parse Tracker and Log

Read both files end-to-end. Extract for each day in `C`:
- From tracker: `Time spent`, `Completed` date, `Struggles`, `Breakthroughs`, `Notes`, the day's `Tasks` checklist (count of exercises, count of theory sections inferable from Notes / day file).
- From log: every entry whose `Day N` matches a day in `C`. Group by action type: `theory-section-cleared`, `theory-task-cleared`, `hint-given`, `exercise-submitted`, `exercise-ac-result`, `exercise-cleared`, `surrender-requested`, `surrender-walkthrough-delivered`, `measurable-goal-verified`, `day-completed`.

Also read top-level tracker `Started` and use today's date for elapsed-calendar-days.

## Step E4 - Compute Metrics

**Speed (progress vs ideal):**
- `total_days` = tracker `Total days` (call it `N`).
- `elapsed_calendar_days` = today − `Started` (whole days, clamp `>=1`).
- `current_days` = `|C|` (days the learner has marked done).
- `ideal_days` = `min(elapsed_calendar_days, N)`. Assumption: the plan commits to one learning day per calendar day. If the plan was explicitly designed at a different cadence (e.g. weekend-only), note this in the Speed conclusion line and adjust `ideal_days` accordingly.
- `delta` = `ideal_days - current_days`. Positive = behind, zero = on pace, negative = ahead.
- `avg_minutes_per_day` = average of tracker `Time spent` fields where parseable; else `(day-completed time − day-started time)` from log per day.
- (Legacy) `pace_ratio` = `current_days / elapsed_calendar_days` — keep for the log entry only; not rendered to chat.

**Quality (4 sub-metrics):**
1. **Hint frequency** = total `hint-given` entries across `C` divided by `days_completed`. Label: `<=0.5/day` strong, `0.5-1.5` normal, `>1.5` heavy.
2. **First-submit AC pass rate** — for each exercise in `C`, find its `exercise-submitted` entries; the FIRST one is "first submit". Read its paired `exercise-ac-result` entry, count ACs marked `pass` vs `partial`/`fail`. Aggregate across all exercises: `total_first_submit_passes / total_first_submit_ACs`. Label: `>=80%` strong, `60-80%` normal, `<60%` needs attention.
3. **Surrender rate** = count of `surrender-walkthrough-delivered` / `days_completed`. Label: `0` clean, `>0` flag the surrendered tasks explicitly.
4. **Comprehension-check accuracy** — for each `theory-section-cleared` event, look at the log entries between it and the previous `theory-section-cleared` (or `day-started`). If a `hint-given` appears in that window AND its detail mentions "comprehension" / "theory" / a section name, the section was cleared with a hint (not first-try). Accuracy = `sections_cleared_first_try / total_sections_cleared`. Label: `>=80%` strong, `60-80%` normal, `<60%` needs attention.

**Concept hotspots:** group `hint-given` entries by the concept named in their detail. List the top 3 (or fewer if there are fewer than 3) concepts by hint count.

## Step E5 - Render to Chat

Print exactly FOUR sections in this order: **Statistics**, **Speed**, **Quality**, **Summary**. Keep total under ~55 lines. Lead with a one-line header, then the four sections.

**Header (1 line):**
```
Learner Evaluation: <slug> — Days 1..<max(C)> (<|C|> completed, started <YYYY-MM-DD>)
```

### Section 0 — Statistics

Print the headline facts about the run before any analysis. No labels, no judgement — just numbers.

```
=== STATISTICS ===
Start date         <YYYY-MM-DD>
Elapsed            <elapsed_calendar_days> calendar day(s)
Avg time/day       ~<avg_minutes_per_day> min/day  (over <K> day(s) with parseable time)
```

Rules:
- `Start date` = tracker `Started` field, verbatim.
- `Elapsed` = `elapsed_calendar_days` from E4 (whole days; clamp `>=1`).
- `Avg time/day` = `avg_minutes_per_day` from E4. Append the parenthetical "(over `<K>` day(s) with parseable time)" where `K` is the count of days that contributed to the average. If `K < |C|` (some days had unparseable `Time spent` and no usable log fallback), the parenthetical is mandatory so the learner knows which days were excluded. If `K == |C|`, drop the parenthetical for brevity.
- If `avg_minutes_per_day` cannot be computed for any day in `C`, print `unavailable` instead of a number and skip the parenthetical.

### Section 1 — Speed

Render TWO progress bars (current vs ideal), then a conclusion line. Bar width = 20 cells. Use `█` for filled and `·` for unfilled. Round filled cells to nearest whole cell; never show >`width` filled.

```
=== SPEED ===
Your progress:    [████████············]  <current_days>/<N> days  (<pct>%)
Ideal progress:   [████████████········]  <ideal_days>/<N> days  (<pct>%)
Conclusion: <phrase>. <ideal_days> day(s) expected, <current_days> done.
```

Conclusion phrase rules (driven by `delta`):
- `delta == 0` → "On pace".
- `delta < 0` → "`<|delta|>` day(s) ahead of ideal pace".
- `delta == 1` → "1 day behind ideal pace".
- `delta > 1` → "`<delta>` days behind ideal pace".
- If `elapsed_calendar_days > N` → also append: " Plan window has closed; `<N - current_days>` day(s) remain unfinished."
- If a non-default cadence was noted in E4, append a short clause: " (Cadence: `<note>`.)"

Do NOT repeat `elapsed_calendar_days` or `avg_minutes_per_day` here — those are already in the Statistics section.

### Section 2 — Quality

Quantitative scorecard built from the log. Render the 4 sub-metrics from Step E4 as a compact table, then concept hotspots and surrender register.

```
=== QUALITY ===
Hint frequency           <h>/day      <label>     (<=0.5 strong, >1.5 heavy)
First-submit AC pass     <p>%         <label>     (>=80% strong, <60% needs attention)
Surrender rate           <s>/day      <n surrender(s) across <|C|> day(s)>
Comprehension accuracy   <a>%         <label>     (>=80% strong, <60% needs attention)

Concept hotspots:
- <concept> — N hint(s) on Day(s) X[, Y]
- ...
(max 3; if zero hints across C: "No hints across completed days.")

Surrender register:
- Day N — <task> (comprehension <pass|partial|fail>)
- ...
(if zero surrenders: "No surrenders.")
```

All four metric values MUST be derived from the log — quote the count source if helpful, but never paste raw log lines.

### Section 3 — Summary

Two-part bullet block: a **work-product level** (one of four tiers) followed by **2-4 concrete improvement actions**, each tied to a specific metric or hotspot from Sections 1-2.

```
=== SUMMARY ===
- Level: <Strong | Solid | Developing | Behind>
- Reading: <one short clause describing the work product, never the person>
- To improve:
  - <action 1 — tied to a specific metric, hotspot, or pace gap>
  - <action 2 — ...>
  - <action 3 — ...>  (optional)
  - <action 4 — ...>  (optional)
```

**Level rubric** (compute strictly; pick the LOWEST tier the data qualifies for — i.e. if any rule says "Behind", level is Behind even if other metrics are strong):

| Level | Conditions (ALL must hold) |
|-------|---------------------------|
| **Strong** | `delta <= 0` AND all 4 Quality labels are `strong` (or `clean`/`0` for surrender) AND no concept hotspots |
| **Solid** | `delta <= 1` AND no Quality label is `needs attention`/`heavy` AND surrender rate `0` |
| **Developing** | `delta <= 2` AND at most ONE Quality label is `needs attention`/`heavy` |
| **Behind** | `delta >= 3` OR two-plus Quality labels are `needs attention`/`heavy` OR surrender rate `>0` with comprehension `partial`/`fail` |

Tie-break: if the data straddles two tiers, pick the LOWER one. The level describes the work product on the completed days; it is NOT a verdict on the learner.

**Reading line** rules:
- One short clause (≤ 15 words). Examples: "Pace and quality both on track.", "Pace on, quality bottom-of-normal.", "Pace 1 day behind, no quality red flags.", "Quality green, pace 2 days behind."
- NEVER use lecture tone, praise, or person-language ("you're doing great", "you struggled with...").

**To improve** rules:
- 2-4 bullets, each one concrete, actionable, and tied to a specific data point (metric label, concept hotspot, surrender, or pace gap). One bullet may be a recovery lever (extend daily session, narrow scope, add a catch-up day) IF `delta > 0`.
- Cite the day number or concept that drove the action (e.g. "Re-attempt the closure loop-capture exercise on Day 5 — it cost 1 hint on Day 2.").
- If `Level == Strong`, replace the entire `To improve` block with a single bullet: `- No adjustments needed. Pace and quality both on track.`
- NEVER include fluff, references to learner files outside the plan, or raw log lines.

## Step E6 - Log the Evaluation

Append ONE entry to `log.md`:
```
YYYY-MM-DD HH:MM | Day <current_day> | evaluation-rendered | scope=Days 1..<max(C)>; pace-delta=<delta>d; hint=<n>/day; first-submit-AC=<pct>%; surrenders=<n>; comp-acc=<pct>%
```
Do NOT modify the tracker. Do NOT write any other file. Commit the log entry per the Commit Protocol in `../log-format.md` (`learn(<goal-slug>): evaluation-rendered — Days 1..N`).

## Step E7 - Continuation Prompt

Ask the learner: "Continue from where you left off (`--continue`), or stop here?" Default to stop if no answer.
