# Interview Script

Use these exact prompts. One block at a time. Wait for the reply.

## Block A - Goal

Ask both questions in a single message, then wait.

```
Before I design your plan, I need to understand the destination.

1. What is the goal you want to achieve?
   Be concrete and observable - what will you be able to DO at the end?
   Examples of strong goals:
     - "Build and deploy a REST API in Node.js with auth"
     - "Read intermediate Japanese news articles without a dictionary"
     - "Pass the AWS Solutions Architect Associate exam"
   Examples of vague goals (I will probe further):
     - "Learn web dev"
     - "Get good at Python"
     - "Understand AI"

2. How long do you want to take to achieve it?
   Give me a timeframe (days / weeks / months) AND roughly how many hours
   per day you can commit. If you don't know, say "1 hr/day" - that's our default.
```

## Block B - Skill Assessment

Ask after Block A is answered.

```
Now I need a snapshot of where you are starting from.

3. What is your overall background as a learner or professional?
   Years of study/work, related fields, learning style preferences,
   anything that helps me calibrate pace.

4. Do you have any experience in this specific field?
   If yes, list what you already know - concepts, tools, projects.
   If no, just say "none" and I will start from absolute basics.
```

## Probing Vague Goals

If the answer to Q1 is vague, probe with ONE follow-up at a time:

| Vague answer | Probe |
|---|---|
| "Learn web dev" | "What would you build at the end? Pick one: a static portfolio, a CRUD app with login, an e-commerce store, a real-time chat?" |
| "Get good at Python" | "Good enough to do what? Automate scripts, build APIs, do data analysis, train ML models?" |
| "Understand AI" | "Understand to USE (call APIs, prompt engineering) or to BUILD (train models, fine-tune, deploy)?" |
| "Improve my English" | "For what context - reading research papers, conversation, business emails, exam (TOEFL/IELTS)?" |
| "Learn to code" | "Pick a first concrete project: a personal website, a Discord bot, a budget tracker, a 2D game?" |

Stop probing once the goal is observable - someone else could watch the learner perform it and agree it is met.

## Probing Vague Timeframes

| Vague answer | Probe |
|---|---|
| "As fast as possible" | "What's your real deadline? An interview, a course start, a project launch?" |
| "Whenever" | "Set a target. 30 days is the default sweet spot for skill-building." |
| "I have a lot of time" | "How many hours per day, realistically, after subtracting work/sleep/meals?" |

## Calibrating Experience

Beginner signals (start from absolute basics):
- "Never written code"
- "I've only used the GUI"
- "I read about it once"

Intermediate signals (skip Day 1-2 foundations, jump to applied work):
- Has shipped something real, even small
- Can name 3+ concepts and explain at least one
- Has used the tooling/language for >10 hours

Advanced signals (focus on gaps and edge cases):
- Production experience
- Can teach a beginner the basics
- Asks questions about edge cases or alternatives

Use this calibration to set the START of the plan, not to remove days. Total days stays anchored to the timeframe.

## Feasibility Check (HARD GATE)

After collecting all four answers, BEFORE confirming back to the learner, evaluate whether the requested timeframe can plausibly carry them from their starting level to the goal.

If not feasible: APOLOGIZE, do NOT generate a plan, recommend the minimum time. Offer three escape routes (extend, intensify, narrow). Wait for the learner's choice. Re-run the feasibility check. Only proceed when it passes.

### Floor Heuristics (minimums, not averages)

Assume 1 hr/day starting from BEGINNER unless noted. These are floors - real plans usually need more.

| Goal type | Min days @ 1 hr/day |
|---|---|
| Understand a concept (no project) | 3 |
| Build a small concrete project (todo app, scraper) | 14 |
| Build a non-trivial real project (REST API w/ auth, deployed site) | 30 |
| New programming language to working competence (with prior language) | 30 |
| New programming language from zero coding | 60 |
| Vendor certification (AWS SAA, AZ-104, CKA, etc.) | 30-60 |
| Natural language - tourist level (A1) | 60 |
| Natural language - news reading without dictionary (B2) | 180 |
| Musical instrument - basic competence | 90 |
| Pivot to a new professional role | 90+ |

Adjustments:
- Intermediate learner (already shipped something in the field): multiply by 0.5-0.7.
- Advanced learner (production experience, gap-filling only): multiply by 0.3-0.5.
- 2 hr/day: multiply day count by 0.6. 3+ hr/day: multiply by 0.5 (diminishing returns - sleep and rest matter for memory consolidation).

### Decision

Compute `requested_hours = requested_days x hours_per_day`. Compare against `floor_hours = floor_days x 1`.

| Ratio (requested / floor) | Verdict | Action |
|---|---|---|
| >= 1.3 | Feasible | Proceed to confirmation summary. |
| 1.0 - 1.3 | Tight | Warn the learner the plan will be aggressive. Ask them to confirm the daily hours commitment. Proceed if confirmed. |
| < 1.0 | Infeasible | Apologize. Do NOT generate plan. Use the script below. |

### Apology Script (Infeasible Case)

Fill in the placeholders. Be specific - vague apologies feel canned.

```
Sorry - I can't honestly design a <REQUESTED_DAYS>-day plan for
"<GOAL>" from your starting point. The skill curve does not
compress that far without skipping foundations that you would
need to actually do the goal afterwards.

Realistic minimum from your level:
- About <MIN_DAYS> days at <REQUESTED_HOURS_PER_DAY> hr/day, OR
- About <ALT_DAYS> days if you can do <ALT_HOURS> hr/day.

You have three options:
1. Extend the timeframe to at least <MIN_DAYS> days. Same goal,
   real plan.
2. Increase daily hours to <ALT_HOURS>+ for <ALT_DAYS> days.
3. Narrow the goal. For <REQUESTED_DAYS> days, a feasible target
   would be: "<NARROWER_GOAL>". Want a plan for that instead?

Which option do you want?
```

After the learner picks, re-run the feasibility check on the new inputs. If still infeasible, apologize again and refine the recommendation. Do NOT generate a plan until feasibility passes.

### When in Doubt

If the goal is unusual and not in the table, ask: "Could a competent intermediate learner reach this in the requested time?" If no, it is infeasible for a beginner too.

Do NOT inflate plans to fit unrealistic timeframes. The learner will fail and blame the plan. Honesty saves them weeks.

## Output After Interview

Once you have answers to all 4 questions AND feasibility passes, summarize back to the learner:

```
Got it. Here is what I heard:

- Goal: <one-line restatement>
- Timeframe: <N> days at ~<H> hr/day = ~<total hours>
- Starting from: <calibrated level - beginner / intermediate / advanced>
- Already know: <key items from Q4>

Next, I'll propose the acceptance criteria for "goal reached" — confirm or correct anything above first.
```

Wait for confirmation. If the learner corrects, update and confirm again. Once confirmed, proceed to `plan-flow.md` Step 3.5 (Goal Verification Criteria) BEFORE designing the day-by-day plan.
