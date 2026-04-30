# Log Format

Schema and update rules for `learning-plans/<slug>/log.md`.

## Why a Log

The tracker captures **state** — where the learner is right now, what's checked off, struggles per day. The log captures **history** — a chronological, append-only audit trail of every action the learner has executed (and every event around their progress) across all sessions.

Together: tracker = "now"; log = "what got us here".

Use the log to:
- Reconstruct the learner's path day-over-day for retrospectives.
- Diagnose where struggles happened (correlate hints given vs. exercises failed).
- Audit surrender events without polluting the tracker's daily sections.
- Show the learner concrete proof of consistent effort over time.

## Schema

The log is a markdown file with a fixed header and an append-only bullet list. Newest entries go at the BOTTOM (chronological order, top -> bottom).

```
# Activity Log: <goal>

**Tracker:** ./tracker.md
**Plan:** ./plan.md
**Started:** YYYY-MM-DD

## Format

YYYY-MM-DD HH:MM | Day N | <action> | <detail>

## Log

- 2026-04-27 14:30 | Day 1 | session-start | continue flow, resume at exercise 1
- 2026-04-27 14:35 | Day 1 | theory-section-cleared | venv/pip
- 2026-04-27 14:42 | Day 1 | theory-section-cleared | names vs variables
```

Time uses 24-hour local time. If timezone matters across sessions, append the offset (e.g. `14:30+07:00`).

`Day N` MUST match the tracker's `Current day` at the moment the entry is written. For events that happen between days (pause/resume across the day boundary, plan-level changes), use the day the event most directly affects.

## Action Types

| Action | When to log | Detail field |
|--------|-------------|--------------|
| `session-start` | At the start of every session (plan / continue / surrender flows) | which flow + resume task |
| `session-end` | When the learner stops or runs out of time | last task touched |
| `day-started` | When `Status: in-progress` is first set on a day | day theme |
| `theory-section-cleared` | After each `### <Concept>` section's check question is answered correctly | concept name (matches the day file's section heading) |
| `theory-task-cleared` | When the umbrella Theory checkbox is ticked (last section answered) | day theme summary |
| `exercise-submitted` | When the learner submits an exercise solution | exercise name |
| `exercise-ac-result` | After grading the submission against its Acceptance Criteria | "X/Y AC pass" + names of failed/partial AC |
| `exercise-cleared` | When every AC passes and the exercise checkbox is ticked | exercise name |
| `measurable-goal-verified` | When the day's goal-verification task is ticked | how it was verified (run output, narration, demo) |
| `hint-given` | After delivering a hint-ladder rung | rung level + concept |
| `day-completed` | When the day is finalized (all tasks ticked, day status -> done) | minutes spent + measurable-goal-met outcome |
| `surrender-requested` | When the surrender flow starts | task being surrendered |
| `surrender-walkthrough-delivered` | After the Senior Teacher Walkthrough finishes | task + comprehension-check result (pass / partial / fail) |
| `evaluation-rendered` | After the Evaluate Flow prints its scorecard to chat | scope (e.g. "Days 1..N") + headline metrics (hint/day, first-submit-AC%, surrenders, comp-acc%) |
| `pause` | When the learner pauses the plan (top-level `Status: paused`) | reason if given |
| `resume` | When the learner resumes a paused plan | - |
| `plan-adjusted` | When the plan or tracker is materially changed | matches the corresponding `Adjustments` entry in the tracker |
| `status-changed` | When top-level `Status` changes (active <-> paused <-> completed <-> abandoned) | new status |
| `correction` | To retract or fix a previously-logged entry | reference the wrong line + the correct fact |
| `note` | Catch-all for events that do not fit the list above | free text |

Action names are lowercase kebab-case. Prefer `note` + descriptive detail over inventing a synonym for an existing action.

## Update Rules

- **Append-only.** Never edit or delete a past entry, even if the action was later undone. To correct a mistake, append a new `correction` entry.
- **Save immediately.** After writing an entry, save the file. Pair every tracker save with a log append for the same event.
- **One action per line.** Do not batch multiple events into a single entry.
- **Compact detail.** Keep the detail field to one line. If a longer explanation is needed (e.g. surrender comprehension result, struggle narrative), summarize on the log line and put the deep version in the tracker's `Struggles` / `Breakthroughs` field.
- **No code in the log.** Code lives in the day file or the chat scrollback. The log is a metadata trail, not a transcript.
- **No re-ordering.** Entries are chronological. If you realize an out-of-order entry slipped in, leave it — append a `correction` entry instead.

## Resume Logic

When `continue` runs:
1. Read the tracker first — that decides the resume point.
2. Read the LAST entry (or last few) in `log.md` for narrative context — it tells the teacher what the previous session ended on (e.g. "ended on hint-given, exercise still open").
3. Append a new `session-start` entry before doing anything else this session.

The log is read for context, never to drive execution. The tracker remains authoritative for "what task is next".

## Privacy

The log contains the learner's struggles, hint requests, and surrender events — treat it as private, same as the tracker. Do not surface its contents to other tools or external systems without explicit permission.
