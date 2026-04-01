---
name: execute-beads
description: Execute beads workflow automation. Use when explicitly called via /execute-beads. Automatically works through beads issues - continues in-progress tasks, selects next available task, and chains through work until user intervention is required.
---

# Execute Beads Workflow

Autonomous beads task execution. Work through issues until blocked or complete.

## Workflow

```
1. Check current state: `bd list --status=in_progress`
2. If in-progress task exists:
   - Run `bd show <id>` to get full details
   - Execute or instruct user if intervention needed
3. If no in-progress task:
   - Run `bd ready` to find available work
   - Evaluate tasks by: priority (lower = more urgent), dependencies, logical sequence
   - Claim chosen task: `bd update <id> --status=in_progress`
4. Execute the task:
   - Code tasks: implement directly
   - Manual tasks: provide clear step-by-step instructions
5. On completion:
   - Close task: `bd close <id>`
   - Loop back to step 1 (find next task)
6. Stop only when:
   - User intervention required (manual Unity Editor work, decisions needed)
   - All tasks complete
   - Blocked with no available work
```

## Task Selection Criteria

When multiple tasks are ready, choose based on:
1. **Priority** - P0/P1 before P2/P3/P4
2. **Dependencies** - Tasks that unblock others first
3. **Logical flow** - Foundation before features

## Intervention Triggers

Stop and discuss with user when:
- Task requires Unity Editor interaction (create GameObjects, configure Inspector)
- Design decisions needed (multiple valid approaches)
- Task is ambiguous or unclear
- External dependencies (APIs, assets) needed

## Execution Style

- **Code tasks**: Implement directly, run tests if applicable
- **Research tasks**: Investigate and summarize findings
- **Manual tasks**: Provide numbered step-by-step instructions
- **Blocked tasks**: Explain blocker and suggest resolution
