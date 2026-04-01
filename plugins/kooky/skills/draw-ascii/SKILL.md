---
name: draw-ascii
description: >
  Draw ASCII diagrams to visually explain systems, architectures, protocols, codebases, data flows,
  and relationships. Use when the user wants to explain, describe, investigate, explore, visualize,
  or draw a diagram of something — including but not limited to: codebase structure, feature architecture,
  network protocols, API flows, database schemas, state machines, class hierarchies, sequence flows,
  deployment topologies, or any concept that benefits from a visual representation.
  Also trigger when the user says: "draw", "diagram", "visualize", "map out", "show me how X works",
  "what does X look like", "architecture of", "flow of", or "explore X".
---

# Draw ASCII

Draw clear, readable ASCII diagrams to visually explain whatever the user asks about.

## Process

1. **Identify what to visualize.** Read relevant code/files if needed to understand the subject.
2. **Pick the best diagram type** from the catalog below.
3. **Draw the diagram.** Follow the style rules.
4. **Add a brief legend** if the diagram uses symbols that aren't self-evident.
5. **Add a short explanation** (2-4 sentences) below the diagram summarizing the key takeaway.

## Diagram Type Catalog

Pick based on what the user is trying to understand:

| Need | Diagram type |
|------|-------------|
| How components connect | Box-and-arrow |
| Request/response or message order | Sequence |
| Step-by-step process or branching | Flowchart |
| Class/interface relationships | Class hierarchy |
| Folder/file organization | Tree |
| State transitions | State machine |
| Data transformation pipeline | Pipeline |
| Layered architecture | Layer stack |
| Timeline or phases | Timeline |

## Style Rules

- **Max width: 100 characters.** Wrap or split if wider.
- **Use box-drawing characters** for clean boxes:

```
+------------------+      +---------+
|   Component A    |----->| Comp B  |
+------------------+      +---------+
```

- **Arrows**: `-->`, `<--`, `<-->` for horizontal; `|`, `v`, `^` for vertical.
- **Label every arrow** when the relationship isn't obvious.
- **Group related items** with dashed borders or section headers.
- **Align consistently** — use fixed-width spacing, keep boxes uniform height where possible.

## Quick Reference Patterns

### Box-and-Arrow (Architecture / Components)

```
+-------------+    request     +-------------+    query     +-----------+
|   Client    |--------------->|   Server    |------------->| Database  |
+-------------+    response    +-------------+    result    +-----------+
               <---------------               <-------------
```

### Sequence (Protocols / API Flows)

```
  Client          Server         Database
    |               |               |
    |-- POST /api ->|               |
    |               |-- INSERT ---->|
    |               |<-- OK --------|
    |<-- 201 -------|               |
    |               |               |
```

### Flowchart (Decisions / Processes)

```
          +--------+
          | Start  |
          +---+----+
              |
              v
        +-----+------+
        | Condition? |
        +-----+------+
         yes /   \ no
            v     v
      +------+ +------+
      | Do A | | Do B |
      +--+---+ +--+---+
         |         |
         v         v
        +----------+
        |   End    |
        +----------+
```

### Tree (File Structure / Hierarchy)

```
project/
  src/
    core/
      Engine.cs
      Config.cs
    ui/
      MainMenu.cs
      HUD.cs
  tests/
    CoreTests.cs
```

### Layer Stack (Layered Architecture)

```
+---------------------------------------+
|           Presentation Layer          |
|  (UI Components, Views, Controllers) |
+---------------------------------------+
|            Business Layer             |
|  (Services, Use Cases, Validation)   |
+---------------------------------------+
|          Data Access Layer            |
|  (Repositories, ORM, Queries)        |
+---------------------------------------+
|             Infrastructure            |
|  (Database, Cache, External APIs)    |
+---------------------------------------+
```

### State Machine

```
            start
              |
              v
    +------------------+
    |      Idle        |<-----------+
    +--------+---------+            |
             |                      |
        [play pressed]         [finished]
             |                      |
             v                      |
    +--------+---------+            |
    |     Playing      +------------+
    +--------+---------+
             |
        [pause pressed]
             |
             v
    +--------+---------+
    |      Paused      |
    +--------+---------+
             |
        [play pressed]
             |
             v
         (Playing)
```

### Pipeline (Data Flow / ETL)

```
  Raw Data --> [Parse] --> [Validate] --> [Transform] --> [Load] --> Database
                 |              |
                 v              v
              errors        rejected
              log           queue
```

## When Exploring Code

If the user asks to explore/investigate a codebase or feature:

1. Use Glob/Grep/Read to understand the structure first.
2. Draw the diagram based on what you found — don't guess.
3. Prefer multiple focused diagrams over one massive diagram.
4. Start high-level, offer to zoom into specific areas.
