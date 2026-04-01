# Slide Patterns Reference

Use these patterns to structure presentations based on the user's intent.

## Pattern 1: Explain a Concept / Framework / Technology

**Goal:** Take the audience from zero to deep understanding.

**Slide structure:**
1. **Title** — name + one-line "what is it"
2. **Why it matters** — problem it solves, context, motivation (2-3 bullets w/ fragments)
3. **Core concepts** — card-grid of 3-4 key ideas with icons
4. **How it works** — flow-steps showing the lifecycle/pipeline
5. **Architecture** — mermaid diagram of components
6. **Code: Basic example** — minimal working code, line-by-line highlight
7. **Code: Intermediate example** — realistic use case, callout box for key insight
8. **Code: Advanced pattern** — collapsible details for optional deep dive
9. **Common pitfalls** — callout-warn boxes
10. **Ecosystem & tools** — table or card-grid of related libraries
11. **Key Takeaways** — summary slide

**Tips:**
- Start each code slide with a brief "what we're building" line
- Use `data-line-numbers="|1-3|5-8"` for step-by-step code reveals
- Add callout-info after code blocks to highlight the "aha" moment
- Use vertical slides (`<section>` nesting) to keep optional deep dives accessible but not blocking

## Pattern 2: Compare Two or More Technologies

**Goal:** Help the audience make an informed choice.

**Slide structure:**
1. **Title** — "X vs Y" or "Comparing X, Y, Z"
2. **Context** — when would you face this choice? (brief bullets)
3. **Overview of X** — 2-3 slides covering key traits, code sample, strengths
4. **Overview of Y** — same structure as X for fair comparison
5. **Side-by-side comparison** — compare-grid layout for qualitative, table for quantitative
6. **Code comparison** — tabs component showing same task in both languages/frameworks
7. **Performance / benchmarks** — table with numbers if applicable
8. **When to pick X** — callout-tip
9. **When to pick Y** — callout-tip
10. **Decision framework** — flow-steps or mermaid decision tree
11. **Key Takeaways** — summary slide

**Tips:**
- Always compare the same task/feature in both technologies
- Use tabs for side-by-side code (Python tab vs JavaScript tab)
- Be balanced — show genuine strengths of each, avoid bias
- Use tags (tag-blue, tag-green) to visually associate colors with each option

## Pattern 3: Present a Solution / Architecture / Proposal

**Goal:** Convince the audience that this solution is the right approach.

**Slide structure:**
1. **Title** — solution name + context
2. **The problem** — what's broken or needed (callout-danger or bullet fragments)
3. **Requirements** — what the solution must satisfy (numbered list)
4. **Options considered** — table comparing 2-3 approaches (with pros/cons columns)
5. **Recommended solution** — overview with mermaid architecture diagram
6. **How it works** — flow-steps for the happy path
7. **Implementation details** — 2-3 code slides showing key pieces
8. **Trade-offs** — compare-grid of pros vs cons of chosen approach
9. **Risks & mitigations** — table or callout-warn boxes
10. **Next steps / roadmap** — flow-steps or numbered list
11. **Key Takeaways** — summary slide

**Tips:**
- Lead with the problem — make the audience feel the pain before the solution
- Use fragments to build up the architecture diagram or steps gradually
- Show code for the trickiest parts, not everything
- Keep each option description fair even if recommending one

## Pattern 4: Code Walkthrough / Deep Dive

**Goal:** Understand existing code in depth.

**Slide structure:**
1. **Title** — what code we're exploring
2. **Big picture** — mermaid diagram of the codebase/module structure
3. **Entry point** — code slide showing where execution starts
4. **Core logic** — 3-5 code slides, each focusing on one function/class
5. **Data flow** — flow-steps showing how data moves through the system
6. **Key patterns used** — card-grid naming design patterns with brief explanation
7. **Edge cases & error handling** — code with callout-warn annotations
8. **How to extend** — code showing extension points with callout-tip
9. **Key Takeaways** — summary slide

**Tips:**
- Use `data-line-numbers` heavily — never show a full code block without highlighting
- Add a callout after each code slide explaining the "why"
- Use collapsible `<details>` for auxiliary code that supports but isn't the main point
- For large codebases, use vertical slides to group related files

## Available Slide Components

Quick reference for building slides:

| Component | Class/Element | Use for |
|-----------|--------------|---------|
| Bullet fragments | `<li class="fragment">` | Revealing points one-by-one |
| Code highlight | `data-line-numbers="\|1-3\|5-8"` | Step-by-step code walkthrough |
| Callout info | `<div class="callout callout-info">` | Key insights, notes |
| Callout tip | `<div class="callout callout-tip">` | Best practices, recommendations |
| Callout warn | `<div class="callout callout-warn">` | Pitfalls, cautions |
| Callout danger | `<div class="callout callout-danger">` | Critical warnings, problems |
| Compare grid | `<div class="compare-grid">` | Side-by-side comparison (2 cols) |
| Card grid | `<div class="card-grid">` | Feature/concept cards (auto-fit) |
| Flow steps | `<div class="flow-steps">` | Sequential process visualization |
| Table | `<table>` | Structured data comparison |
| Tabs | `<div class="tabs">` | Multi-variant content (code in different langs) |
| Collapsible | `<details><summary>` | Optional deep-dive content |
| Mermaid | `<div class="mermaid">` | Architecture/flow diagrams |
| Tags | `<span class="tag tag-blue">` | Labels, categories, badges |
| Key takeaways | `<ul class="key-takeaways">` | Summary slide bullet list |
