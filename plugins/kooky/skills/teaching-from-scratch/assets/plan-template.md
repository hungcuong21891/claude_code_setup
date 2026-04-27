# Learning Plan: <GOAL>

**Created:** YYYY-MM-DD
**Timeframe:** <N> days at ~<H> hr/day (~<total> hours)
**Plan path:** learning-plans/<slug>/plan.md
**Day files:** learning-plans/<slug>/days/
**Tracker:** learning-plans/<slug>/tracker.md

> This file is the INDEX. Each day's full lesson lives in its own file under `./days/`.
> Open the day file you are working on; this index is for navigation, scope, and orientation only.

## Learner Profile

- **General background:** <years, related fields, learning style notes>
- **Field experience:** <none | what they already know>
- **Calibrated start level:** <beginner | intermediate | advanced>

## Outcome (Final Measurable Goal)

<one observable, verifiable end state — what the learner will be able to DO on Day N>

Concretely, on the final day the learner can demonstrate:
- [ ] <criterion 1>
- [ ] <criterion 2>
- [ ] <criterion 3>

## Curriculum Map

| Phase | Days | Theme |
|-------|------|-------|
| 1 — Foundations | 1-<a> | <vocabulary, mental model, env setup> |
| 2 — Core skills | <a+1>-<b> | <the 80/20> |
| 3 — Integration | <b+1>-<c> | <combine on a real-ish project> |
| 4 — Mastery / edges | <c+1>-<d> | <optimization, debugging, ecosystem> |
| 5 — Final project | <d+1>-<N> | <end-to-end demonstration> |

(Adjust phase shape based on goal — see references/plan-design-guide.md.)

## Day-by-Day Index

### Phase 1 — <Phase 1 Name>
- [Day 1 — <theme>](./days/day-01-<slug>.md)
- [Day 2 — <theme>](./days/day-02-<slug>.md)
- [Day 3 — <theme>](./days/day-03-<slug>.md)
<!-- ... -->

### Phase 2 — <Phase 2 Name>
- [Day <a+1> — <theme>](./days/day-<NN>-<slug>.md)
<!-- ... -->

### Phase 3 — <Phase 3 Name>
<!-- ... -->

### Phase 4 — <Phase 4 Name>
<!-- ... -->

### Phase 5 — <Phase 5 Name>
- [Day <N> — Final Assessment](./days/day-<NN>-final-assessment.md)

## Per-Day File Convention

Each `./days/day-NN-<topic-slug>.md` is self-contained and follows the structure in `assets/day-template.md`:
- Header with Previous/Next links
- **Measurable goal** (one sentence)
- **Background theory** (3-7 bullets, each cited)
- **Exercises** (1-3, each with Definition of Done + Acceptance Criteria)
- **Self-check** (learner-facing AC summary)

Day-file naming rules:
- `NN` is two-digit zero-padded (01..N).
- `<topic-slug>` is kebab-case, 2-4 words.
- Filenames MUST match the links in this index AND in `tracker.md`.

## Final Assessment Summary

The last day file (`./days/day-<N>-final-assessment.md`) contains the end-to-end demonstration. Its pass criteria mirror the Outcome checklist above.

If the learner fails the final assessment, log it in `tracker.md` `Adjustments` and either extend by recovery days or mark partial — never pretend it passed.

## How To Use These Files

1. Open `tracker.md` to see `Current day` (call it `D`).
2. Open `./days/day-DD-<slug>.md` for the full lesson.
3. Follow the day file top-to-bottom: theory → exercises → self-check.
4. Tick tasks in `tracker.md` as each one clears (theory checks, exercise AC, measurable goal).
5. When all tasks for Day `D` are ticked, the day finalizes and `Current day` increments to `D+1`.

## References

- <primary textbook / docs>
- <secondary course / video series>
- <community / forum for stuck moments>
