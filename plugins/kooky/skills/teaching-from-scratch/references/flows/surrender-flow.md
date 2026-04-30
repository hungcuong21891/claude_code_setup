# Surrender Flow (argument: `surrender`)

The ONLY branch where the teacher solves the work. Used when the learner explicitly gives up on the current task and wants to see the answer. Every other branch refuses.

## Step S1 - Locate the Active Tracker

Same as Continue Flow Step C1 (0 active -> apologize and offer `plan`; 1 -> use; 2+ -> ask which). See `continue-flow.md`.

## Step S2 - Locate the Surrender Target

Read `Current day` and the Daily Log entry for that day. The surrender target is the first unchecked task in that day's `Tasks` checklist. Confirm with the learner before solving:

> "You're surrendering on `<task>` (Day `D` of `N`, `<theme>`). I'll solve it and walk you through the solution. Continue?"

Wait for explicit yes. If the learner says no, abort and return to Continue Flow.

## Step S3 - Solve the Task

Solve based on task type. Read the day's `./days/day-NN-<slug>.md` for the exact spec first.

- **Theory task** - deliver the full concept explanation in chat (no Socratic probe). Same depth and IN-CHAT delivery as a normal theory step (do NOT just point at the file or the source link).
- **Exercise task** - write a complete solution that passes EVERY Acceptance Criterion in the day file. Then walk each AC out loud, marking pass / pass / pass against your own code so the rubric is honored — surrender does NOT skip the AC walkthrough.
- **Measurable goal verification** - produce the artifact the goal asks for (run output, diagram, demo) on the learner's behalf.

## Step S4 - Senior Teacher Walkthrough (MANDATORY)

After solving, deliver a structured walkthrough. NEVER drop the solution and stop — the walkthrough is what converts surrender into learning. Cover, in order:

1. **Intent** - one sentence on what the solution does at the highest level.
2. **Chunk-by-chunk** - break the solution into 3-7 logical chunks. For each: what it does AND why this shape (which concept it applies; one alternative avoided and why).
3. **Concepts named** - tie each chunk back to a theory section from today's day file or earlier days. Cite the day's reference link for further reading.
4. **Trade-offs** - one viable alternative implementation and why we did not pick it (perf, readability, scope).
5. **Pitfalls** - inputs and edge cases that would break a naive version of this code; how the solution handles them.
6. **"If you see this again"** - one-sentence pattern signature so the learner recognizes the shape next time (e.g. "Two-pointer scan over a sorted array — recognize it when paired bounds shrink inward").
7. **Comprehension check** - ONE Socratic question on the most important concept. Wait for the learner's answer. Hint-ladder if they struggle. If they cannot answer at all, mark the concept shaky and propose a recovery exercise tomorrow (Step S6).

## Step S5 - Update the Tracker and Log

1. Tick the surrendered task in the day's `Tasks` checklist.
2. Append to that day's `Struggles` field: `Surrendered <task> on YYYY-MM-DD; reviewed walkthrough; comprehension check: <pass|partial|fail>`.
3. Save the tracker immediately.
4. Append two entries to `log.md`: a `surrender-requested` entry (detail: task name) at the start of the surrender flow, and a `surrender-walkthrough-delivered` entry (detail: `<task> — comprehension <pass|partial|fail>`) after Step S4 completes. Save the log.

The surrender is logged honestly — future-you reading the tracker AND the log should see exactly where they leaned on the teacher. If this was the last task of Day `D`, run the Finish-the-Day Gate (`continue-flow.md` Step C4 finalization) as usual and append a `day-completed` log entry.

## Step S6 - Continuation Prompt

Ask the learner one of three:
1. Continue with the next task in Day `D` (default if comprehension check passed).
2. Schedule a recovery exercise on this concept for tomorrow (default if comprehension check was partial / fail). On approval, append a `### Adjustments` line in the tracker noting "Day D+1 add recovery exercise on <concept>".
3. Stop the session here.
