---
name: html-present
description: >
  Generate visual HTML slide presentations that explain topics in depth. Use when the user asks to
  explain, present, compare, or teach something — such as frameworks (FastAPI, React), programming
  languages, architectures, code walkthroughs, concepts, or solution proposals. Triggers on requests
  like: "explain how X works", "present X", "compare X vs Y", "create a presentation about X",
  "walk me through this code", "teach me X", or any request for a visual/slide-based explanation.
---

# Visual HTML Presentation Generator

Generate self-contained, multi-slide HTML presentations using Reveal.js with a dark-mode theme,
code highlighting, Mermaid diagrams, and interactive elements.

## Workflow

1. Identify the presentation type from the user's request:
   - **Explain** — framework, concept, technology, code
   - **Compare** — two or more technologies/languages/approaches
   - **Present solution** — architecture proposal, problem-solving
   - **Code walkthrough** — deep dive into specific code

2. Read the template at `assets/template.html` in this skill's directory to use as the HTML base.

3. Read `references/slide-patterns.md` for the matching pattern's recommended slide structure.

4. If explaining a library/framework, fetch current documentation using context7 MCP tools
   (resolve-library-id then query-docs) to ensure accuracy.

5. Generate the full HTML file:
   - Copy the `<head>` section (styles, CDN links) from the template exactly
   - Copy the `<script>` section at the bottom from the template exactly
   - Replace only the slides inside `<div class="slides">` with real content
   - Follow the slide structure from the matched pattern
   - Target **10-15 slides** for a standard presentation

6. Write the HTML file to the user's working directory as `{topic-name}-presentation.html`.

7. Open the file in the browser for the user if browser tools are available.

## Content Guidelines

- **Deep-dive level**: Include working code examples, not just bullet points
- **Every code block** must use `data-line-numbers` with step highlights (e.g., `"|1-3|5-8"`)
- **Every code block** must be followed by a callout explaining the key insight
- **Use fragments** (`class="fragment"`) on list items and cards for progressive reveal
- **Include at least one Mermaid diagram** for architecture or data flow
- **Use tabs** when comparing code across languages or approaches
- **Use collapsible `<details>`** for optional deep-dive content that would clutter the main flow
- Write concise slide content — slides are not documents. Prefer short phrases over sentences.

## Slide Count by Type

| Type | Recommended slides |
|------|-------------------|
| Explain concept | 10-15 |
| Compare technologies | 12-16 |
| Present solution | 10-14 |
| Code walkthrough | 8-12 |

## Do NOT

- Add any external CSS/JS beyond what the template uses (Reveal.js, highlight.js, Mermaid)
- Use images or external assets that require network access beyond CDNs
- Create slides with walls of text — keep each slide focused on one idea
- Skip the title slide or summary slide
