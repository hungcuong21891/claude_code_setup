# Kooky - Claude Code Plugin for Unity Projects

A Claude Code plugin that provides coding standards, workflows, and productivity skills for Unity development.

## Installation

### From GitHub (recommended)

1. Add the marketplace:

```
/plugin marketplace add https://github.com/hungcuong21891/claude_code_setup
```

2. Install the plugin:

```
/plugin install kooky@kooky-marketplace
```

### From a local clone

```bash
claude --plugin-dir /path/to/claude_code_setup/plugins/kooky
```

## What's Included

### Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Agent Doc | `/agent-doc` | Generate CLAUDE.md documentation for folders |
| Commit Staged Files | `/commit-staged-files` | Commit workflow helper |
| Draw ASCII | `/draw-ascii` | Create ASCII art diagrams |
| HTML Present | `/html-present` | Generate HTML slide presentations |
| Tech Debt | `/tech-debt` | Identify and track technical debt |
| Beads (Check) | `/check-beads` | Check beads status and current work |
| Beads (Execute) | `/execute-beads` | Execute beads workflow automation |
| Beads (File) | `/file-beads` | File beads epics and issues |
| Beads (Review) | `/review-beads` | Review and refine beads issues |

### Hooks

- **Unity MCP Logger** - Automatically logs all `mcp__UnityMCP__*` tool calls (both success and failure) for debugging and auditing Unity MCP interactions.

### CLAUDE.md

Includes Unity-specific coding standards covering:

- Naming conventions (PascalCase, camelCase, underscore prefixes)
- Architecture patterns (MVC, DI with Zenject, state machines)
- Performance best practices (object pooling, UniTask, Addressables)
- Code style and file organization guidelines

## Updating

To get the latest version:

```
/plugin update kooky@kooky-marketplace
```

## Uninstalling

```
/plugin uninstall kooky@kooky-marketplace
```
