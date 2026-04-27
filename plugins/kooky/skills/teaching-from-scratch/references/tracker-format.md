# Tracker Format

Schema and update rules for `learning-plans/<slug>/tracker.md`.

## Why a Tracker

The tracker is the single source of truth for "where is the learner right now". When a new Claude Code session starts, reading the tracker is enough to resume teaching at the correct day with the correct context. Without it, every session starts from zero.

## Schema

The tracker is a markdown file with required headings. Order matters - parsers and humans both read top-to-bottom.

```
# Tracker: <goal>

**Status:** active | paused | completed | abandoned
**Started:** YYYY-MM-DD
**Last session:** YYYY-MM-DD
**Current day:** <integer, 1-indexed>
**Total days:** <integer>
**Plan:** ./plan.md
**Day files:** ./days/
**Log:** ./log.md

## Progress

- [ ] [Day 1 - <theme>](./days/day-01-<slug>.md)
- [ ] [Day 2 - <theme>](./days/day-02-<slug>.md)
- [ ] [Day 3 - <theme>](./days/day-03-<slug>.md)
...

## Daily Log

### Day 1 - [<theme>](./days/day-01-<slug>.md)
- Status: not-started | in-progress | done
- Tasks:
  - [ ] Theory: <day-theme summary covering ALL the day's theory sections>
  - [ ] Exercise 1: <name>
  - [ ] Exercise 2: <name>
  - [ ] Measurable goal verification
- Completed: YYYY-MM-DD
- Time spent: <minutes>
- Measurable goal met: yes | no | partial
- Struggles: <bullet points>
- Breakthroughs: <bullet points>
- Notes: <free text>

### Day 2 - [<theme>](./days/day-02-<slug>.md)
...

## Open Questions

- <thing the learner got stuck on; revisit later>
- <concept that needs a second pass>

## Checkpoints

- Day <N>: <description> - <status>
- Day <M>: <description> - <status>

## Adjustments

- YYYY-MM-DD: <what was changed and why> (e.g., "Inserted recovery exercise after Day 4 - learner confused on closures.")
```

## Day Heading Links (REQUIRED)

Each `### Day N - <theme>` heading in the Daily Log MUST be a markdown link to the day's per-day file under `./days/`. Same for the Progress checklist entries. This is what lets the learner jump from the tracker to the lesson content in one click.

Example:
```
### Day 1 - [Python Setup and Syntax for the Experienced OOP Dev](./days/day-01-python-setup.md)
```

Filenames MUST match the links used in `plan.md`'s Day-by-Day Index. If a filename ever changes, update both files in the same edit pass.

## Tasks Checklist (per-day, REQUIRED)

Each day's `Daily Log` entry contains a `Tasks` checklist. This checklist is what makes mid-day resume possible - the `continue` argument finds the first unchecked task and picks up there.

Populate the checklist at tracker init time (Plan Flow Step 5) with:
- **ONE umbrella `Theory: <day-theme summary>` entry** that covers ALL the day's `### <Concept>` background-theory sections combined. Do NOT create one Theory checkbox per section — long theory checklists bore the learner. The teacher still walks each section inline during delivery, but the tracker only carries one tick.
- One entry per exercise listed in the day file (`Exercise N: <name>`).
- One final entry: `Measurable goal verification`.

Order matters - the checklist is the canonical execution order for the day. Do NOT add or remove tasks mid-day; if the plan changes, log an entry in `Adjustments` and update the checklist explicitly.

Tick a task (`[ ]` -> `[x]`) immediately after the learner clears it. Save the tracker after EVERY tick - if the session dies between ticks, only the most recent task is lost.

For the umbrella `Theory` task, "clears it" means **the LAST `### <Concept>` section's check question has been answered correctly** — not the first one. While theory is in flight, append a progress line to the day's `Notes` field after each section the learner clears, e.g. `Theory progress — covered venv/pip, names/truthiness; next: built-in types`. Save the tracker after every progress note. On session resume, this `Notes` line is what tells the teacher which section to start from; if `Notes` is empty, start from the first section. Once the umbrella tick is set, the progress line in `Notes` may be left as a record or replaced with general notes.

For an `Exercise N` task, "clears it" has a specific meaning: every Acceptance Criterion in that exercise's AC list (defined in `plan.md`, see plan-design-guide.md Principle 6.5) is marked pass. If any AC is failed or partial, the exercise task stays `[ ]` - even if the learner thinks they are done.

The day MUST NOT be marked done until every task in its checklist is `[x]`.

## Update Rules

When to update:
- **Day start**: set the day's `Status: in-progress`. Update `Last session`.
- **After each task clears**: tick the corresponding checkbox in the day's `Tasks` list. Save the tracker.
- **Day end (all tasks ticked)**: set `Status: done`, fill `Completed`, `Time spent`, `Measurable goal met`, `Struggles`, `Breakthroughs`. Tick the day checkbox in the Progress list. Increment `Current day`.
- **Pause**: set top-level `Status: paused`. Add a note in `Adjustments`. Leave the in-progress day's task ticks intact - that's the resume anchor.
- **Resume**: set top-level `Status: active`. Update `Last session`. Find the first unchecked task in `Current day` and continue there.
- **Plan change**: log in `Adjustments` with date and reason. If the change touches a day's theory/exercise list, also update that day's `Tasks` checklist (and call out the edit in `Adjustments`).
- **Abandonment**: set `Status: abandoned`. Be honest in the log.

Do NOT silently rewrite history. Adjustments are append-only.

## Resume Logic

When the `continue` argument runs and finds an active tracker:
1. Read top-level `Current day` (call it `D`) and the matching plan section in `plan.md`.
2. Read Day `D`'s `Daily Log` entry - in particular the `Tasks` checklist.
3. The first `[ ]` task is the resume point. If every task is `[x]`, finalize Day `D` (mark done, increment `Current day`) and re-evaluate.
4. Read the prior day's `Daily Log` entry - mention struggles in the recap if you have not yet recapped them this session.
5. If the prior day's `Measurable goal met: partial` or `no`, do a brief recovery before moving on.
6. If the tracker has `Open Questions`, raise the most relevant one when it becomes pertinent.
7. NEVER advance to Day `D+1` content while any Day `D` task is unchecked.

## Completion

When the final day's measurable goal is met:
- Set `Status: completed`.
- Tick all checkboxes.
- Add a final entry to `Adjustments` summarizing total time and key learnings.
- Congratulate the learner. Concretely - name what they can now do.

## Multiple Plans

A learner can have multiple active plans (e.g., learning Spanish AND Rust simultaneously). Each lives in its own `learning-plans/<slug>/` directory. When the skill activates, list all active trackers and ask which to work on.

## Companion Log

Every plan also gets a `learning-plans/<slug>/log.md` — an append-only chronological audit trail of every action the learner takes. Tracker = state ("now"); log = history ("what got us here"). Pair every tracker save with a log append for the same event. Schema and action-type list: `references/log-format.md`.

## Privacy

The tracker contains the learner's struggles - treat it as private. Do not surface its contents to other tools or external systems without explicit permission. Same for `log.md`.
