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
| `theory-html-rendered` | After the per-day theory HTML supplement is written and opened in full at chat-walk depth (one entry per render; idempotent skip on resume) | relative path to the rendered html file |
| `theory-refreshed` | After a context7 / WebFetch freshness check found stale content in the day file and the affected `### <Concept>` section was revised in place before walking it | concept name + brief delta (e.g. `lifespan events: replaced on_event deprecation`) |
| `theory-html-section-filled` | Exception-path only: when a single section's HTML body is rewritten mid-day to incorporate a learner-asked clarifier added during the inline walk | section number + concept name |
| `theory-section-cleared` | After each `### <Concept>` section's check question is answered correctly | concept name (matches the day file's section heading) |
| `theory-task-cleared` | When the umbrella Theory checkbox is ticked (last section answered) | day theme summary |
| `exercise-submitted` | When the learner submits an exercise solution | exercise name |
| `exercise-ac-result` | After grading the submission against its Acceptance Criteria | "X/Y AC pass" + names of failed/partial AC |
| `exercise-cleared` | When every AC passes and the exercise checkbox is ticked | exercise name |
| `measurable-goal-verified` | When the day's goal-verification task is ticked | how it was verified (run output, narration, demo) |
| `hint-given` | After delivering a hint-ladder rung | rung level + concept |
| `day-question-answered` | When the learner asks a question during the End-of-Day Questions Gate and the teacher answers it | short topic of the question (e.g. `scoping rules`, `why useEffect runs twice`) |
| `day-questions-cleared` | When the learner confirms no more questions and the End-of-Day Questions Gate closes (logged even when 0 questions were asked) | count of questions asked in the gate (e.g. `0`, `3`) |
| `day-completed` | When the day is finalized (all tasks ticked, day status -> done, questions gate cleared) | minutes spent + measurable-goal-met outcome |
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
- **Commit after every log update.** Every log append MUST be followed by a git commit covering the log + paired tracker/day-file changes for that event. This makes the audit trail recoverable and gives the learner a per-action git history.

## Commit Protocol

After each log append + paired tracker save, stage and commit the changed files in the plan directory.

- **Stage:** `learning-plans/<slug>/log.md`, `learning-plans/<slug>/tracker.md`, and any day file touched by the same event (e.g. `days/day-NN-<slug>.md` if a section's check question was answered, an exercise submission landed, or struggles were recorded).
- **Scope:** one commit per log entry. Do not batch multiple log actions into a single commit — the 1:1 mapping is what makes the history useful for retrospectives.
- **Message format:** conventional commit, scope = goal slug, summary = `<action>: <compact detail>`.
  - `learn(<goal-slug>): <action> — <detail>`
  - Examples:
    - `learn(react-fundamentals): theory-section-cleared — jsx vs html`
    - `learn(react-fundamentals): exercise-cleared — counter component`
    - `learn(react-fundamentals): hint-given — rung 2, useState reducer`
    - `learn(react-fundamentals): day-completed — Day 3, goal met`
    - `learn(react-fundamentals): surrender-walkthrough-delivered — Day 5 exercise 2, comprehension partial`
- **Body (optional):** include only when the detail line is insufficient (e.g. plan-adjusted, correction). Keep under 3 lines.
- **No skipping hooks.** Never use `--no-verify`. If a hook fails, fix the root cause and retry — do not bypass.
- **No force-push, no amend.** The log is append-only at the git level too. To correct a bad commit, make a NEW commit whose log line is a `correction` action.
- **Failure handling.** If `git commit` fails (e.g. nothing staged because tracker/log were already clean, or repo is in a detached state), surface the error to the learner in chat and continue the lesson — do not silently skip. Re-run the commit once the underlying issue is resolved.
- **Non-git environments.** If the plan directory is not inside a git repo, skip the commit step silently and continue. The log + tracker remain the source of truth.

## Resume Logic

When `--continue` runs:
1. Read the tracker first — that decides the resume point.
2. Read the LAST entry (or last few) in `log.md` for narrative context — it tells the teacher what the previous session ended on (e.g. "ended on hint-given, exercise still open").
3. Append a new `session-start` entry before doing anything else this session.

The log is read for context, never to drive execution. The tracker remains authoritative for "what task is next".

## Privacy

The log contains the learner's struggles, hint requests, and surrender events — treat it as private, same as the tracker. Do not surface its contents to other tools or external systems without explicit permission.
