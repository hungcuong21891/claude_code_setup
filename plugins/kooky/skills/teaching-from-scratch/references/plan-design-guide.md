# Plan Design Guide

How to convert (goal, timeframe, starting level) into a smooth day-by-day curriculum.

## Principle 1 - Backwards From the Goal

Start at the END. Write the final-day measurable goal first - the verifiable demonstration that the learner has arrived. Then work backwards: what must they know the day before? Two days before? This produces a chain of prerequisites that fills the curve naturally.

Avoid the rookie mistake of starting at "Day 1: install the language" and inventing days until time runs out.

## Principle 2 - Measurable Goal Per Day

A measurable goal MUST be:
- **Observable** - someone watching can agree it is met.
- **Bounded** - achievable in the day's allotted hours.
- **Layered on yesterday** - reuses or extends prior days' material.

Bad: "Understand functions."
Good: "Write three pure functions: one that returns a sum, one that filters a list, one that composes the other two. Explain in your own words why composition works."

Bad: "Learn about React state."
Good: "Build a counter component with +/- buttons. Demonstrate that lifting state to a parent lets two siblings share the count."

## Principle 3 - Theory Before Exercise

Each day's structure: theory -> exercise -> self-check.

The Background Theory section MUST be self-contained. The learner should be able to read it once and have what they need to attempt the day's exercises WITHOUT opening any external link. Sources are listed as further-reading references, not as the primary explanation.

Each theory section therefore contains, in order:
1. A **headline** for the concept (`### <Concept Name>`).
2. A **2-5 paragraph explanation** that defines new terms in line, gives a concrete example, and (where the learner has prior experience in another stack) bridges with a one-line analogy ("like C#'s X, except…").
3. **At most 1-2 short code snippets** when a snippet beats prose. Snippets must be runnable or near-runnable, not pseudocode.
4. A **closing sentence** that names the one fact the learner will use in today's exercises.
5. *Reference: <link>* — the authoritative source, italicised, AFTER the explanation. Marked as optional further reading.

Aim for ~80-200 words per concept section, plus optional snippet. Do NOT replace the explanation with a link. Do NOT invent material that contradicts the source — read the source first, then teach from it.

Plan for 3-7 concept sections per day. If you have more, the day is too dense — split it.

Why self-contained: the learner is reading this offline, on a phone, or while travelling. They expect the day file to teach them. A bullet list of links is a reading assignment, not a lesson. A plan that ships theory-as-link-list is INCOMPLETE — revise before saving.

## Principle 4 - Phases Over Days

Cluster days into 2-5 phases. Typical pattern for an N-day plan:

| Phase | Share of days | Focus |
|---|---|---|
| 1 - Foundations | 15-25% | Vocabulary, mental model, environment setup |
| 2 - Core skills | 30-40% | The 80/20 of techniques the learner will use daily |
| 3 - Integration | 20-30% | Combining techniques on a real-ish project |
| 4 - Mastery / edge cases | 10-20% | Optimization, debugging, ecosystem awareness |
| 5 - Final project | 5-15% | Demonstration of the goal end-to-end |

Adjust based on goal type:
- **Knowledge-heavy goals** (exams, language learning): heavier phase 1, lighter phase 3.
- **Skill-heavy goals** (build X): lighter phase 1, heavier phase 3-5.
- **Mixed goals**: roughly the table above.

## Principle 5 - Spaced Recall

Every 5-7 days, insert a "review and apply" day. The measurable goal: combine three skills from earlier days in a small new exercise. This fights forgetting curves.

## Principle 6 - Exercise Difficulty Ladder

Within a single day, exercises follow a ladder:
1. **Recognize** - identify the concept in given code/text.
2. **Reproduce** - apply it in a near-identical scenario.
3. **Reapply** - use it in a slightly different scenario.

Optional 4th rung for advanced learners:
4. **Reframe** - solve a problem where the right concept is not obvious.

Do not include rung 4 on every day - reserve it for phase 3+ and review days.

## Principle 6.25 - One File Per Day (REQUIRED structure)

The plan is NOT a single monolithic markdown file. It is a small directory:

```
learning-plans/<slug>/
  plan.md                      # INDEX only: profile, outcome, curriculum map, links
  tracker.md                   # Progress + per-day Tasks checklists (links to day files)
  days/
    day-01-<topic-slug>.md     # Full Day 1 lesson
    day-02-<topic-slug>.md     # Full Day 2 lesson
    ...
    day-NN-final-assessment.md # Final day
```

Why split:
- **Context efficiency.** Each day file is ~50-150 lines. The teacher (and the learner) load only the day in flight, not all 30.
- **Browseability.** The learner can read tomorrow's day file ahead, link directly to a single day, or skim past days for review without scrolling through hundreds of lines.
- **Resilience.** Editing or regenerating one day does not risk corrupting another.
- **Linkability.** `tracker.md` links each Day heading to its file; the learner jumps from "where am I" to "what do I do" in one click.

Naming rules for day files:
- `day-NN-<topic-slug>.md` — `NN` is two-digit zero-padded; `<topic-slug>` is kebab-case, 2-4 words derived from the day's theme.
- Examples: `day-01-python-setup.md`, `day-09-sqlalchemy-alembic.md`, `day-21-redis-leaderboard.md`.
- Filenames MUST match the links in `plan.md` (Day-by-Day Index) AND in `tracker.md` (Progress list + Daily Log headings).

Per-day file contents (use `assets/day-template.md`):
- Header line with Previous/Next links and a back-link to `plan.md` and `tracker.md`.
- **Phase** label.
- **Measurable goal** (one sentence).
- **Background theory** (3-7 self-contained concept sections — see Principle 3). Each section teaches the concept inline; the cited source is a *reference*, not a substitute for the explanation.
- **Exercises** (1-3, each with Definition of Done + Acceptance Criteria — see Principle 6.5 below).
- **Self-check** (learner-facing AC summary).

`plan.md` itself stays under ~80 lines and contains:
- Header (created date, timeframe, paths to days/ and tracker).
- Learner profile.
- Outcome (final measurable goal as a checklist).
- Curriculum map (phase table).
- Day-by-day index (grouped by phase, each entry a link to the day file).
- Final assessment summary.
- "How to use these files" section.
- References.

## Principle 6.5 - Definition of Done + Acceptance Criteria (per exercise)

EVERY exercise in `plan.md` MUST carry two extra fields in addition to the task description:

- **Definition of Done (DoD)** - one sentence naming the artifact the learner produces. The DoD is the answer to "what does 'finished' look like for this exercise?". Examples:
  - "A function `is_prime(n)` saved in `solutions/day-03/is_prime.py` that runs without error."
  - "A 3-sentence written explanation of why HTTP is stateless, in `notes/day-01.md`."
  - "A hand-drawn diagram of the request -> response flow, photographed and saved as `notes/day-02-diagram.jpg`."

- **Acceptance Criteria (AC)** - a checklist of 2-5 observable, binary (pass/fail) conditions the artifact must satisfy. The AC is the grading rubric. Examples:
  - [ ] `is_prime(0)` returns `False`.
  - [ ] `is_prime(2)` returns `True`.
  - [ ] `is_prime(15)` returns `False`.
  - [ ] Solution does not import any library.
  - [ ] Learner can explain in one sentence why the loop bounds are what they are.

Rules for AC:
1. Each criterion is **observable** - the teacher and learner can both agree on pass/fail.
2. Each criterion is **binary** - no "mostly", no "kind of". Partial = fail.
3. The AC is **complete** - if all items pass, the exercise is genuinely done. Do not leave a real requirement implicit.
4. The AC is **minimal** - 2-5 items per exercise. If you need 10, the exercise is too big - split it.
5. The AC is **front-loaded into the plan** - written when designing the day, NOT when grading.

Why DoD + AC: without them, "is the exercise done?" becomes a vibe call. With them, grading is a checklist walk - faster, fairer, and the learner knows the bar before starting. Self-check (Principle 7) is the learner-facing version of the AC; the AC is the teacher's full grading rubric.

A plan that ships exercises without DoD + AC is INCOMPLETE. Revise before saving.

## Principle 7 - Self-Check Without Spoilers

Each day's self-check tells the learner HOW to know they got it right, without giving the answer. Patterns:

- "Run the code with input X. The output should have property Y." (not "the output is 42")
- "Explain the concept aloud in 30 seconds. If you stumble on word W, re-read source S."
- "Diagram the flow on paper. Compare structurally to the diagram on page P of source S." (learner does the comparison)
- "Write 3 test cases that should fail and 3 that should pass. Run them - all should behave as expected."

## Calibrating Pace

Hours-per-day to depth conversion:
- 0.5 hr/day -> 1 small concept + 1 exercise.
- 1 hr/day (default) -> 2-3 concepts + 1-2 exercises + self-check.
- 2 hr/day -> 3-5 concepts + 2-3 exercises + 1 small extension task.
- 3+ hr/day -> add a daily mini-project that integrates the day's skills.

If the learner says "intermediate" in Q4, do not cut days - shift the START. Day 1 begins where the learner's known knowledge ends, not at "hello world".

## Adjusting When Stuck

If the tracker shows a day was hard (logged struggle), the next session should:
1. Insert a remedial 30-minute warmup before the next day's content.
2. Re-cover the stuck concept with a different analogy or source.
3. Only then move forward.

Do NOT silently extend the plan - tell the learner you are inserting a recovery exercise.

## Final Assessment

The last day of the plan is always a final assessment that demonstrates the goal end-to-end without scaffolding. The learner performs it; you grade. If they fail, you log it in the tracker and either extend by a few days or note partial completion - never pretend it passed.
