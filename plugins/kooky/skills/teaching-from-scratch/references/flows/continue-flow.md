# Continue Flow (flag: `--continue`)

## Step C1 - Locate the Active Tracker

Look for `learning-plans/<slug>/tracker.md` files in CWD.
- 0 active trackers -> apologize, explain `--continue` needs an existing plan, offer to run `--plan` instead. Stop.
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

Append a `session-start` entry to `log.md` (detail: `--continue flow, resume at <task>`) before delivering any lesson content, then commit per the Commit Protocol in `../log-format.md`. Read the last few entries in `log.md` for narrative context — they tell you where the prior session ended (e.g. on a hint, on a failed AC) so the recap can be specific.

## Step C3 - Resume at the Task

Hand off to the matching part of `daily-lesson-delivery.md` depending on the task type (Theory, Exercise, or Measurable goal verification). Skip earlier completed tasks - DO NOT re-teach concepts the learner has already passed unless they ask for a recap.

## Step C4 - Finish-the-Day Gate (NON-NEGOTIABLE)

Do NOT advance `Current day` or start Day `D+1` content while ANY task in Day `D`'s checklist is unchecked.

If the learner asks to skip ahead ("can we just start tomorrow?", "skip the last exercise"), refuse and respond with:
> "Day `D` still has `<N>` task(s) open: `<list>`. Finish them first - the Day `D+1` material assumes you've done these. Want a hint on the next one?"

Only when the last task of Day `D` ticks off:
1. Set Day `D` `Status: done`, fill `Completed`, `Time spent`, `Measurable goal met`, `Struggles`, `Breakthroughs`.
2. Tick the Day `D` checkbox in the Progress list.
3. Update top-level `Last session`.
4. **End-of-Day Questions Gate (NON-NEGOTIABLE).** Before incrementing `Current day` or even mentioning Day `D+1`, open a Q&A wrap-up. Prompt the learner verbatim or near-verbatim:
   > "Day `D` is complete. Before we move on, do you have any questions about today's material? I can clarify any concept we covered, walk through a piece of the exercise again, or connect today's ideas to what's coming next. When you're done, say 'no more questions' / 'ready for tomorrow' / 'let's move on'."

   Loop:
   - If the learner asks a question -> answer it in teacher voice (concept + concrete example + why-it-matters). You MAY answer clarifying questions directly here since the day is graded — but do NOT solve unrelated future exercises and do NOT pre-teach Day `D+1` content. After answering, append a `day-question-answered` log entry (detail: short topic) and ask "Any other questions?".
   - If the learner says they have no questions / signals readiness to move on, append a `day-questions-cleared` log entry (detail: number of questions asked, or `0`) and proceed.
   - If the learner is silent or ambiguous, ask once more explicitly: "Any questions before we wrap Day `D`? Reply 'no' to continue." Do NOT advance on silence alone.

   Do NOT increment `Current day` while this gate is open. Do NOT preview Day `D+1`'s theme or material inside the Q&A — that defeats the purpose of the gate.
5. Increment `Current day` to `D+1`. Append a `day-completed` log entry (per existing rules).
6. Ask the learner whether to continue into Day `D+1` now or stop here. Only on explicit confirmation ("yes", "let's go", "continue") do you start Day `D+1`. On "stop" / "tomorrow" / silence, end the session cleanly with a `session-end` log entry.
