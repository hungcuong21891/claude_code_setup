---
name: commit-staged-files
description: Commit already-staged files across the current repo AND all its git submodules. Auto-generates Conventional Commit messages from staged diffs. Never stages additional files — only commits what is already in the index. Offers to push at the end. Use this whenever the user wants to commit, has staged changes in both the main repo and submodules, or says something like "commit my changes", "commit everything", "commit staged", or "commit submodules too". Prefer this over a plain commit skill when a `.gitmodules` file is present or when `git status` shows submodule changes.
---

# Commit Staged Files

Commit already-staged changes across the repo and all its git submodules, with auto-generated Conventional Commit messages. Only commits what is already in the index — never runs `git add`.

## Workflow

### Step 1: Discover submodules

Run from the repo root:
```bash
git submodule foreach --quiet 'echo $sm_path'
```

Collect the list of submodule paths (relative to root). If no submodules exist, skip ahead to Step 3 (commit root only).

### Step 2: Scan for staged changes

For the root repo and each submodule, check whether anything is staged:
```bash
# Root repo
git diff --cached --stat

# For each submodule (run inside that directory)
cd <submodule-path> && git diff --cached --stat
```

Collect only locations that have staged changes. Silently skip any location with nothing staged. If nothing is staged anywhere, tell the user and stop.

### Step 3: Commit submodules first

Process each submodule that has staged changes, one at a time:

1. Get the full staged diff (run inside the submodule directory):
   ```bash
   git diff --cached
   ```

2. Analyze the diff and generate a Conventional Commit message (see format below).

3. Show the user a brief summary: which files are staged and the proposed commit message.

4. Commit:
   ```bash
   git commit -m "$(cat <<'EOF'
   <generated message>

   Co-Authored-By: <model currently in use> <noreply@anthropic.com>
   EOF
   )"
   ```

If any commit fails, report the error and stop — do not silently continue to the next location.

### Step 4: Commit the root repo

Check what the root repo has staged:
```bash
git diff --cached --stat
```

If nothing is staged, skip this step.

Otherwise:
1. Get the full staged diff: `git diff --cached` in root
2. Generate a Conventional Commit message based on the staged changes.
3. Show the user the summary and proposed message.
4. Commit using the same heredoc pattern as Step 3.

### Step 5: Offer to push

After all commits succeed, show a summary of what was committed (which locations, which messages), then ask:

> "All done. Do you want to push now?"

If the user says yes, push submodules first, then the root repo:
```bash
# Inside each committed submodule directory
git push

# Then from root
git push
```

If any push fails (e.g., no upstream set), show the error and suggest the fix (e.g., `git push -u origin <branch>`).

---

## Conventional Commit Message Format

```
<type>(<optional scope>): <short description>
```

**Types — pick the one that best fits the staged changes:**

| Type | When to use |
|------|-------------|
| `feat` | New feature or new behavior |
| `fix` | Bug fix |
| `chore` | Maintenance, config, dependency/submodule updates |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation only |
| `style` | Formatting/whitespace, no logic change |
| `test` | Adding or fixing tests |
| `perf` | Performance improvement |
| `ci` / `build` | CI/CD or build system changes |

**Rules:**
- Lowercase after the colon, no period at the end
- Subject line under 72 characters
- Scope is optional — use it when changes are clearly scoped to one system (e.g., `fix(piggybank): ...`)
- Infer type from the nature of the change, not just the filenames

**Examples:**
```
chore: update fsdk submodule to latest
fix(daily-mission): prevent null ref on mission board refresh
feat(ui): add animated currency counter to lobby
refactor(piggybank): extract withdrawal logic to strategy class
docs: update feature module table in README
```

---

## Notes

- Always run git commands in the correct directory. Use `cd <path> && git <command>` or open a shell in the right directory — never assume the CWD is correct.
- Never run `git add` of any kind — only commit what the user has already staged.
- Never amend, force-push, or use `--no-verify`.
- If a pre-commit hook fails, fix the issue and create a new commit — do not amend.
