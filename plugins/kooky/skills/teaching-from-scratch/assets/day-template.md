# Day <N> — <Theme>

> Plan index: [plan.md](../plan.md) · Tracker: [tracker.md](../tracker.md)
> Previous: [Day <N-1> — <Prev Theme>](./day-<NN-1>-<prev-slug>.md) · Next: [Day <N+1> — <Next Theme>](./day-<NN+1>-<next-slug>.md)

**Phase:** <P> — <Phase Name>

**Measurable goal:** <one sentence describing the verifiable outcome the learner can demonstrate at end of day>

## Background Theory

> Read this section through end-to-end. It is written to teach the concept, not to point you at a source. Sources are listed as further reading only — you should NOT need to open them to do today's exercises.

### <Concept A>

<2-5 short paragraphs that actually teach the concept. Define new terms in line. Where the learner has prior experience in another language/framework, use a one-line analogy ("like C#'s X, except…") to bridge. Show 1-2 minimal code snippets when a snippet beats prose. End with the one practical fact that will matter in today's exercises.>

*Reference (optional further reading): <link or book chapter>*

### <Concept B>

<Same structure as Concept A. Self-contained explanation, then a reference link.>

*Reference: <link>*

### <Concept C>

<...>

*Reference: <link>*

(3-7 concept sections per day. If you have more, the day is too dense — split it. Each section ~80-200 words plus optional snippet. Sources are references, NOT a substitute for the explanation.)

## Exercises

### 1. Recognize — <Name>
- **Task:** <task using the concept in a near-identical scenario>
- **Definition of Done:** <one sentence describing the artifact the learner produces>
- **Acceptance Criteria:**
  - [ ] <observable, binary criterion 1>
  - [ ] <observable, binary criterion 2>
  - [ ] <observable, binary criterion 3>

### 2. Reproduce — <Name>
- **Task:** <task applying the concept directly>
- **Definition of Done:** <artifact, e.g., "A function `foo(x)` saved in `solutions/day-NN/foo.py` that runs without error.">
- **Acceptance Criteria:**
  - [ ] <e.g., "`foo([])` returns `[]`.">
  - [ ] <e.g., "`foo([1,2,3])` returns `[2,4,6]`.">
  - [ ] <e.g., "Solution uses concept A, not a manual loop workaround.">

### 3. Reapply — <Name>
- **Task:** <task using the concept in a slightly varied scenario>
- **Definition of Done:** <artifact>
- **Acceptance Criteria:**
  - [ ] <criterion 1>
  - [ ] <criterion 2>
  - [ ] <criterion 3>

(2-5 AC items per exercise. Each is observable + binary. Skip the Recognize rung on Reproduce-only days; add a Reframe rung only on review or phase-3+ days. See references/plan-design-guide.md Principle 6.)

## Self-Check

- <how the learner verifies their own work without being given the answer>
- <e.g., "Run with input X. Output should have property Y.">
- <e.g., "Explain concept A aloud in 30 seconds without notes.">

<!--
File naming convention:
  ./days/day-NN-<topic-slug>.md
  - NN is two-digit zero-padded day number (01..30)
  - <topic-slug> is kebab-case from the theme, 2-4 words max (e.g., async-asyncio, redis-leaderboard)
  - Filename MUST match the link target used by ../plan.md and ../tracker.md
-->
