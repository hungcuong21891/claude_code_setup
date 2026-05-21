# Category: Build Settings

Scans `ProjectSettings/*.asset` and platform-specific player settings. ALL changes here are project-wide — require user confirmation.

## Issues To Detect

### B-01. Mono scripting backend on release platform
- **Detection:** `ProjectSettings/ProjectSettings.asset` → `scriptingBackend` map. Values:
  - `Android: 0` (Mono) → HIGH finding for mobile release.
  - `iOS: 0` → IL2CPP REQUIRED by App Store; treat as ERROR (CRITICAL, blocks shipping).
  - `Standalone: 0` (Mono) → MEDIUM (acceptable but IL2CPP recommended).
- **Why bad:** IL2CPP produces faster code via AOT; required by iOS.
- **Severity hint:** see per-platform above.
- **Fix:** Set value to `1` (IL2CPP). Triggers a recompile; warn user.

## Detection Workflow

1. Read `ProjectSettings/ProjectSettings.asset`. This is YAML, several hundred lines. Grep for each key listed above.
2. Each ProjectSettings finding is GLOBAL — only one finding per setting, not per platform unless the setting is per-platform (B-01).

## Notes for the Reviewer

- These changes are POWERFUL and require recompiles, re-imports, or full rebuilds. Always emit at the user-confirmation step with clear warnings.
- DO NOT auto-patch ProjectSettings YAML by hand. Use UnityMCP if it exposes setters; else manual.
