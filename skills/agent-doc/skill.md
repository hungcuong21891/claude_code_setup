---
name: agent-doc
description: >
  Generate CLAUDE.md documentation files for one or more folders in the codebase.
  The CLAUDE.md serves as onboarding documentation for AI agents, helping them
  quickly understand the folder's purpose, structure, patterns, and usage.
  Use when explicitly called via /agent-doc. This skill is manually triggered by
  the developer to document a specific folder, multiple folders, or the entire codebase.
  Supports batch mode: pass multiple folder paths separated by commas, or a parent folder
  to auto-discover documentable subfolders.
---

# Agent Doc Generator

Generate CLAUDE.md files for one or more folders to help AI agents quickly understand and work with that code.

## Workflow

1. **Determine target folders.** Check the ARGUMENTS provided:

   **Single folder** (e.g., `Assets/fsdk/Scripts/Core`):
   - Proceed with that one folder.

   **Multiple folders** (comma-separated, e.g., `Assets/fsdk/Scripts/Core/Features/Ads, Assets/fsdk/Scripts/Core/Features/IAP, Assets/fsdk/Scripts/Core/Features/GameServices`):
   - Parse the comma-separated list and process each folder.

   **Parent folder with `--discover` flag** (e.g., `Assets/fsdk/Scripts/Core/Features --discover`):
   - List immediate subdirectories of the parent folder.
   - Present the discovered subfolders to the developer and ask which ones to document (multi-select).
   - Proceed with the selected folders.

   **No arguments provided:**
   - Ask the developer which folder(s) they want to document. Present options:
     - Current working directory (root of the project)
     - A specific folder path (let them type it)
     - A parent folder to discover subfolders from

   **Processing order for batch mode:**
   - Process each folder using a **separate Task subagent** (subagent_type: `general-purpose`) running in parallel for efficiency.
   - Each subagent receives the full instructions (steps 2-6 below) and the specific folder path to document.
   - After all subagents complete, summarize results: list each folder and whether its CLAUDE.md was created/updated successfully.

### Per-Folder Steps (steps 2-6)

These steps are executed for **each** target folder. In batch mode, they run in parallel via subagents.

2. **Discover all files** in the target folder recursively using Glob (`**/*` pattern within that folder). Skip binary files, build artifacts, and dependency folders (e.g., `node_modules/`, `Library/`, `Temp/`, `obj/`, `bin/`, `.git/`, `Logs/`).

3. **Check child folders for existing CLAUDE.md files** before reading their contents. For each immediate subdirectory of the target folder:
   - If the subdirectory contains its own CLAUDE.md, **skip reading that entire subdirectory**. Do not recurse into it.
   - Collect these paths to include as links in the parent's CLAUDE.md (see "Submodules" section in the structure below).
   - Only read files that are directly in the target folder or in subdirectories that do NOT have their own CLAUDE.md.

4. **Read all source files** in the folder (excluding skipped subdirectories from step 3). For large folders (>50 files), prioritize:
   - Entry points and main files first
   - Configuration files
   - Core logic files
   - Utility/helper files
   - Test files last
   - Skip auto-generated files, meta files, and binary assets

5. **Analyze and write** a CLAUDE.md file at the root of the target folder. The documentation must include:

### CLAUDE.md Structure

```markdown
# [Folder Name] - Agent Documentation

## Purpose
Brief description of what this folder/module does and its role in the project.

## Architecture Overview
High-level description of how the code is organized, key design patterns used,
and the relationships between major components.

## Key Files & Components
List of the most important files with brief descriptions of what they do.
Group by logical category if applicable.

## Data Flow / How It Works
Describe how data flows through the system, key entry points,
and the execution sequence for common operations.

## Public API / Interfaces
List exported classes, methods, events, or interfaces that other parts
of the codebase consume. Include signatures and brief usage examples.

## Dependencies
What this folder depends on (internal modules, external packages).

## Conventions & Patterns
Coding patterns, naming conventions, or architectural decisions
specific to this folder that an agent should follow.

## Common Tasks
Brief guide on how to:
- Add a new feature/component to this folder
- Modify existing behavior
- Where to look when debugging issues

## Submodules
Link to child folders that have their own CLAUDE.md documentation.
Only include this section if child CLAUDE.md files were found in step 3.
Example:
- [FeatureName](./FeatureName/CLAUDE.md) - Brief one-line description of what this submodule does.

## Gotchas & Important Notes
Non-obvious behaviors, edge cases, or things that could trip up
an agent working in this folder.
```

6. **Adapt the structure** based on what's actually in the folder. Omit sections that don't apply. Add sections if the code warrants it (e.g., "State Management" for UI code, "API Endpoints" for server code, "Event System" for event-driven code).

7. **Be specific and actionable.** Prefer concrete file paths, class names, and method signatures over vague descriptions. The goal is for an agent to read this CLAUDE.md and immediately know how to navigate and modify the code.

## Important Rules

- Write the CLAUDE.md at the ROOT of the target folder (e.g., if target is `Assets/fsdk/Scripts/`, write to `Assets/fsdk/Scripts/CLAUDE.md`).
- If a CLAUDE.md already exists in that folder, read it first and ask the developer whether to overwrite or update it.
- If a child subfolder already has its own CLAUDE.md, do NOT read or review that subfolder's contents. Simply add a link to its CLAUDE.md in the parent's "Submodules" section.
- Keep the documentation concise but comprehensive. Aim for quick scanability.
- Do NOT include information that would quickly become stale (e.g., exact line numbers, counts of files).
- Focus on structural and conceptual knowledge that remains stable across changes.

## Batch Mode Details

When processing multiple folders:

- **Parallelism**: Launch one Task subagent per folder (subagent_type: `general-purpose`). Each subagent gets the folder path and the full per-folder instructions (steps 2-6 plus CLAUDE.md structure and important rules).
- **Existing CLAUDE.md handling in batch mode**: If a CLAUDE.md already exists in a folder, **skip that folder** and note it in the summary (do not prompt per-folder in batch mode — this avoids blocking parallel execution). The developer can re-run with just that folder to update it.
- **Summary output**: After all subagents finish, present a table:
  ```
  | Folder | Status |
  |--------|--------|
  | Assets/fsdk/Scripts/Core/Features/Ads | Created |
  | Assets/fsdk/Scripts/Core/Features/IAP | Created |
  | Assets/fsdk/Scripts/Core/Features/GameServices | Skipped (already exists) |
  ```
- **Error handling**: If a subagent fails for a folder, report the error in the summary and continue with the rest.
