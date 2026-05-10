# Plan Flow (flag: `--plan`)

Run Steps 1 -> 5 in order, then hand off to `daily-lesson-delivery.md` for Day 1.

## Step 1 - Pre-flight: Existing Plans

Look for `learning-plans/<slug>/tracker.md` files in CWD. If any tracker has `Status: active`, ask the learner:
- (a) Switch to `--continue` and resume that plan?
- (b) Pause it (set `Status: paused`, append note in `Adjustments`) and start a new plan?
- (c) Replace it with a new slug suffixed `-v2` / `-v3`?

Only proceed to Step 2 after the learner picks a path.

## Step 2 - Interview the Learner (4 questions, two blocks)

Use the exact wording in `../interview-script.md`. Ask one block at a time, wait for the reply, then ask the next.

Block A (Goal):
1. What is the goal you want to achieve? (concrete, observable end state)
2. How long do you want to take to achieve it? (days / weeks / months, and ~hours per day)

Block B (Skill assessment):
3. What is your overall background as a learner / professional? (years, related fields)
4. Do you have any experience in this specific field? If yes, describe what you already know.

If the goal is vague (e.g. "learn web dev"), probe with the follow-ups in `../interview-script.md` until the goal is observable (a concrete project, output, or demonstrable skill).

## Step 3 - Feasibility Gate (HARD CHECK)

After the interview, BEFORE designing the plan, check whether the requested timeframe is realistic for the goal given the learner's starting level. Methodology and heuristics in `../interview-script.md` (Feasibility Check section).

Three outcomes:
- **Feasible** (>= 1.3x the floor) - proceed to the confirmation summary, then Step 4.
- **Tight but feasible** (1.0x - 1.3x the floor) - warn the learner the plan will be aggressive, ask them to confirm the daily hours commitment, then proceed.
- **Infeasible** (< 1.0x the floor) - APOLOGIZE, DO NOT generate a plan, recommend the realistic minimum days/hours, and offer three options:
  1. Extend the timeframe to at least the minimum.
  2. Increase daily hours.
  3. Narrow the goal to one feasible within the original timeframe.
  Wait for the learner's choice. Re-run the feasibility check on the new inputs. Only proceed to Step 4 when feasibility passes.

NEVER fudge a plan to fit an unrealistic timeframe - it sets the learner up to fail and blame the plan. Honesty here saves them weeks.

## Step 4 - Design the Day-by-Day Plan (split into per-day files)

Methodology in `../plan-design-guide.md`. Output is a SMALL DIRECTORY, not a single monolithic file:

```
learning-plans/<goal-slug>/
  plan.md                       # INDEX only (use assets/plan-template.md)
  days/
    day-01-<topic-slug>.md      # Full Day 1 lesson (use assets/day-template.md)
    day-02-<topic-slug>.md      # Full Day 2 lesson
    ...
    day-NN-final-assessment.md  # Final day
```

Why split: see `../plan-design-guide.md` Principle 6.25 (context efficiency, browseability, resilience, linkability).

**`plan.md` (INDEX, ~80 lines max)** contains:
- Header (created date, timeframe, paths to days/ and tracker).
- Learner profile.
- Outcome (final measurable goal as a checklist of observable criteria).
- Curriculum map (phase table).
- Day-by-day index (grouped by phase, each entry a markdown link to the day file).
- Final assessment summary.
- "How to use these files" section.
- References.

**Each `./days/day-NN-<topic-slug>.md`** contains:
- Header line with Previous/Next links and back-links to `plan.md` + `tracker.md`.
- **Phase** label.
- **Measurable goal** - a verifiable outcome the learner can demonstrate.
- **Background theory** - 3-7 self-contained concept sections. Each section is a `### <Concept>` heading followed by 2-5 paragraphs that actually teach the concept inline, plus an *italicised reference link* at the end. The cited source is for further reading only — the learner must NOT need to open it to understand or to do the exercises. See `../plan-design-guide.md` Principle 3 for the required format. A day file that ships theory as a bullet list of links is INCOMPLETE — revise before saving.
- **Exercises** - 1-3 practice tasks. Each MUST: (1) produce an artifact a working engineer would actually use on THIS project (code, test, config, migration, deployment script, ADR, capacity write-up, etc.), (2) move the measurable goal closer, and (3) carry its own **Definition of Done (DoD)** and **Acceptance Criteria (AC)**. Learning-journal write-ups ("write 2 sentences explaining X in notes/day-NN.md", "describe Y in your own words", reflection essays) are FORBIDDEN — see `../plan-design-guide.md` Principle 6.6. Theory comprehension belongs in the Theory step. Without DoD + AC, or if the exercise is a write-up, revise before saving.
- **Self-check** - how the learner verifies their own work without you handing over the answer.

Day-file naming:
- `day-NN-<topic-slug>.md` where `NN` is two-digit zero-padded; `<topic-slug>` is kebab-case, 2-4 words derived from the day's theme.
- Examples: `day-01-python-setup.md`, `day-21-redis-leaderboard.md`, `day-30-final-assessment.md`.
- Filenames MUST match the links in `plan.md` AND in `tracker.md` (Progress + Daily Log headings).

Curve must be smooth: no jumps that skip prerequisites; reuse earlier concepts.

Copy the structures from `assets/plan-template.md` (for `plan.md`) and `assets/day-template.md` (for each day file). Create the `days/` subdirectory. Save all files, then announce the directory path to the learner.

## Step 5 - Initialize the Tracker and Log

Create `learning-plans/<goal-slug>/tracker.md` from `assets/tracker-template.md`. Schema in `../tracker-format.md`. Initial state:
- Status: active
- Current day: 1
- Completed days: empty
- Started: today's date

CRITICAL: For each day in the plan, populate that day's `Tasks` checklist in the Daily Log with: **ONE umbrella `Theory: <day-theme summary>` entry** covering all of the day's `### <Concept>` theory sections together, **one entry per exercise**, and a final `Measurable goal verification` entry. We use ONE theory checkbox per day ON PURPOSE — a long list of micro-theory ticks bores the learner. The teacher still walks each `### <Concept>` section inline during delivery; only the tracker checkbox is unified. Mid-theory progress is tracked in the day's `Notes` field for resume — see `daily-lesson-delivery.md` Theory step. This is what makes mid-day resume possible. See `../tracker-format.md` (Tasks Checklist section).

ALSO CRITICAL: Each `### Day N` heading in the Daily Log AND each item in the Progress checklist MUST be a markdown link to that day's per-day file under `./days/`. The link target MUST match the filename created in Step 4. See `../tracker-format.md` (Day Heading Links section).

ALSO create `learning-plans/<goal-slug>/log.md` from `assets/log-template.md`. The log is the append-only chronological audit trail of every action the learner takes — schema and full action-type list in `../log-format.md`. Tracker = state ("now"); log = history ("what got us here"). Pair every tracker save with a log append for the same event, and commit each log append per the Commit Protocol in `../log-format.md`. Seed the log with a `session-start` entry (action: `session-start`, detail: `plan flow initialized`) and a `day-started` entry once Day 1 lesson delivery begins. Commit the initial plan + tracker + log scaffolding as a single setup commit (`learn(<goal-slug>): plan-initialized — Day 1 ready`); after that, revert to one-commit-per-log-entry.

After init, hand off to `daily-lesson-delivery.md` for Day 1.
