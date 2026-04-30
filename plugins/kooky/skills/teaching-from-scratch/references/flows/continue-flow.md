# Continue Flow (argument: `continue`)

## Step C1 - Locate the Active Tracker

Look for `learning-plans/<slug>/tracker.md` files in CWD.
- 0 active trackers -> apologize, explain `continue` needs an existing plan, offer to run `plan` instead. Stop.
- 1 active tracker -> use it.
- 2+ active trackers -> list them with `Current day` / `Total days` and ask the learner which to resume.

Read both `tracker.md` and the matching `plan.md` end-to-end before responding.

## Step C2 - Locate the Resume Point

From the chosen tracker:
1. Read `Current day` (call it `D`).
2. Read the Daily Log entry for Day `D` and its `Tasks` checklist.
3. The first unchecked task is the resume point.
4. If every task for Day `D` is already checked but the day is not marked done, finalize the day (see Step C4) and re-check whether `D+1` exists; if so, prompt the learner whether to start Day `D+1` now.

Open the session by stating: "Resuming `<slug>`, Day `D` of `N` (`<theme>`). Last completed task: `<previous task>`. Next task: `<resume task>`. X tasks remaining today before we can move to Day `D+1`."

Append a `session-start` entry to `log.md` (detail: `continue flow, resume at <task>`) before delivering any lesson content. Read the last few entries in `log.md` for narrative context — they tell you where the prior session ended (e.g. on a hint, on a failed AC) so the recap can be specific.

## Step C3 - Resume at the Task

Hand off to the matching part of `daily-lesson-delivery.md` depending on the task type (Theory, Exercise, or Measurable goal verification). Skip earlier completed tasks - DO NOT re-teach concepts the learner has already passed unless they ask for a recap.

## Step C4 - Finish-the-Day Gate (NON-NEGOTIABLE)

Do NOT advance `Current day` or start Day `D+1` content while ANY task in Day `D`'s checklist is unchecked.

If the learner asks to skip ahead ("can we just start tomorrow?", "skip the last exercise"), refuse and respond with:
> "Day `D` still has `<N>` task(s) open: `<list>`. Finish them first - the Day `D+1` material assumes you've done these. Want a hint on the next one?"

Only when the last task of Day `D` ticks off:
1. Set Day `D` `Status: done`, fill `Completed`, `Time spent`, `Measurable goal met`, `Struggles`, `Breakthroughs`.
2. Tick the Day `D` checkbox in the Progress list.
3. Increment `Current day` to `D+1`.
4. Update top-level `Last session`.
5. Ask the learner whether to continue into Day `D+1` now or stop here.
