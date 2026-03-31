---
name: tech-debt
description: >
  End-of-session tech debt analysis. Scans for duplicated code, overly long functions (80+ lines),
  and overly long classes (500+ lines). Use when explicitly called via /tech-debt.
  Reports findings with suggestions, then offers to fix each issue with user confirmation.
  Supports any language. Default scope: files changed on current branch vs main.
  Optional: pass a folder path to analyze a specific directory instead.
---

# Tech Debt Cleanup

End-of-session skill to find and fix common tech debt: duplication, long functions, long classes.

## Workflow

### 1. Determine Scope

Parse the argument passed to the skill:

- **No argument or empty**: Use `git diff --name-only main...HEAD` to get files changed on the current branch. Filter to source code files only (exclude `.meta`, `.asset`, `.unity`, `.prefab`, config files).
- **Folder path provided**: Recursively find all source code files in the specified folder.

If no source files are found, inform the user and exit.

### 2. Analyze Each File

Read every in-scope file. For each file, check the three rules below. Track all findings in a structured list.

#### Rule 1: Duplicated Code

Compare code blocks across all in-scope files. Flag duplication when:

- **Cross-file**: Two or more files contain a block of 6+ consecutive lines that are identical or near-identical (ignoring whitespace and comments).
- **Intra-file**: The same file contains 2+ blocks of 4+ consecutive lines that are identical or near-identical.

For each finding, note which files/lines are involved and suggest an extraction target (shared method, base class, utility function).

#### Rule 2: Long Functions

Flag any function/method whose body exceeds **80 lines** (excluding blank lines and comment-only lines). For each:

- Report the function name, file, line range, and actual line count.
- Suggest how to split it: identify logical sections that could become separate methods, describing each by purpose.

#### Rule 3: Long Classes

Flag any class/struct whose body exceeds **500 lines** (excluding blank lines and comment-only lines). For each:

- Report the class name, file, and actual line count.
- Analyze responsibilities and suggest how to decompose: extract inner classes, split by responsibility into separate files, use composition, or apply relevant patterns (Strategy, State, etc.).

### 3. Report Findings

Present a summary table:

```
## Tech Debt Report

### Summary
| Category         | Count |
|------------------|-------|
| Duplicated Code  | X     |
| Long Functions   | X     |
| Long Classes     | X     |

### Findings
(List each finding with category, location, severity, and suggestion)
```

Sort findings by severity: Long Classes > Long Functions > Duplicated Code.

If zero findings, congratulate the user and exit.

### 4. Fix with Confirmation

After presenting the report, iterate through findings one by one:

1. Show the specific finding with the proposed change (exact lines to add/remove/move).
2. Ask user: "Apply this fix?" (Yes / Skip / Stop)
   - **Yes**: Apply the edit, then move to next finding.
   - **Skip**: Move to next finding without editing.
   - **Stop**: End the fix loop.

Do NOT batch-apply fixes. Each fix must be confirmed individually.

## Notes

- When counting lines, exclude blank lines and comment-only lines for threshold comparison.
- "Near-identical" means lines differ only in variable names, string literals, or whitespace.
- For duplication detection, focus on structural similarity over exact text matching.
- Prioritize actionable suggestions over exhaustive reporting.
- If a function is long because it contains a switch/match with many cases, suggest a dispatch table or polymorphism rather than just splitting.
