# Severity Classification

Every finding from a category reviewer ships with a severity-hint. The aggregator (main agent) MAY override the hint by applying the rules below.

## Severity Definitions

| Level | Meaning | Typical Impact |
|-------|---------|----------------|
| CRITICAL | Ships-blocker or major frame-time killer | iOS rejection, frame budget exceeded on target device, large GC pauses every frame, > 1MB/s allocations |
| HIGH | Significant perf cost, common to find, often easy to fix | Persistent 5-20% frame-time savings, build-size > 10% reduction, mobile thermal/battery |
| MEDIUM | Moderate cost, often situational | 1-5% frame-time savings, code quality, memory hygiene |
| LOW | Best practice, marginal cost | < 1% savings, style consistency, future-proofing |

## Override Rules (applied AFTER reviewer hints)

Rules cascade top-to-bottom; first match wins.

### Promote to CRITICAL when:
1. Finding is in a **scene that ships** (in `EditorBuildSettings.asset` build-list) AND severity-hint is HIGH AND issue is in MonoBehaviour Update/FixedUpdate/LateUpdate.
2. iOS target + `scriptingBackend: 0` (Mono) — Apple Store rejection blocker.
3. Development build flags (`m_DevelopmentBuild: 1`, `m_ConnectProfiler: 1`) on a project the user is shipping.
4. Allocations every frame inside Update — specifically `new` keyword for reference types, string concatenation, LINQ, `foreach` on List<T> in Mono.
5. UnityMCP is connected AND user has explicitly said "audit for release" — most HIGH items in user-shipping code path can be promoted.

### Promote to HIGH when:
1. Issue affects ≥20 GameObjects in a scene (e.g., 50 static-flag-missing colliders, 30 raycast-targets enabled needlessly).
2. Build-time consequence (texture compression, audio compression) AND project has >100 such assets.
3. Real-time lighting in a mobile-target project.

### Demote to LOW when:
1. File is editor-only (`Assets/**/Editor/**`, `#if UNITY_EDITOR` wrap).
2. File is in `Plugins/`, `ThirdParty/`, or any path matching `*Third*Party*`, `*Vendor*`, `*Imported*` — third-party code that user likely won't touch.
3. Issue exists in tests (`Assets/**/Tests/**`, file matches `*Test.cs`).
4. Pattern fires once in a non-hot method (not Update/FixedUpdate/LateUpdate, not in a loop, not in OnCollisionStay).

### Demote to MEDIUM when:
1. Reviewer hint is HIGH but issue is in initialization (`Awake`, `Start`, `OnEnable`) — runs once per spawn.
2. Build-target is desktop / console (not mobile), and finding is mobile-specific (HDR/MSAA, sample rate, mipmaps).

## Issue-to-Severity Quick Map

| Issue ID | Default | Rationale |
|----------|---------|-----------|
| C-01 GetComponent in Update | HIGH | 60+ calls/sec/instance |
| C-02 Camera.main in Update | HIGH | Tag-based scene search |
| C-02 Camera.main in init | MEDIUM | Once per scene, still cache-worthy |
| C-03 Repeated transform | MEDIUM | Compiler sometimes inlines |
| C-04 tag == comparison | MEDIUM | LOW outside hot path |
| C-05 String concat in Update | HIGH | GC every frame |
| C-06 new Vector in Update | LOW | Struct, often fine |
| C-07 Empty Update/Fixed/Late | MEDIUM | LOW for Awake/Start |
| C-08 Allocating raycast | HIGH | GC + heap pressure |
| C-09 magnitude in comparison | MEDIUM | HIGH if Update |
| C-10 Coroutine timer | MEDIUM | |
| C-11 foreach on List in Update | LOW | |
| C-12 Find / FindObjectOfType in Update | CRITICAL | Full scene walk |
| C-12 Find in init | MEDIUM | |
| C-13 Resources.Load in Update | HIGH | |
| C-15 LINQ in Update | HIGH | |
| P-01 Missing Static flag | HIGH | If ≥20 objects |
| P-01 Missing Static flag | MEDIUM | < 20 objects |
| P-02 Wrong Continuous mode | HIGH | |
| P-03 Mesh/Polygon collider on dynamic | HIGH | |
| P-04 Layer matrix not pruned | MEDIUM | |
| P-05 Reuse Collision Callbacks off | MEDIUM | HIGH if many callbacks |
| P-06 autoSyncTransforms on | MEDIUM | |
| P-08 Spawning static objects | HIGH | Per-spawn spike |
| R-01 Dynamic batching off (Built-in RP) | MEDIUM | |
| R-02 Static batching not enabled | HIGH | If ≥20 candidates |
| R-03 GPU Instancing off | MEDIUM | |
| R-04 Realtime lights count high | HIGH | On mobile |
| R-04 Realtime lights count high | MEDIUM | On desktop |
| U-01 Mega-canvas mixed updates | HIGH | If >40 elements |
| U-02 Raycast Target on non-interactive | MEDIUM | HIGH if >50 elements |
| U-03 SetActive(false) on Canvas | MEDIUM | |
| U-04 Animator on UI element | HIGH | |
| U-05 ScrollView without RectMask2D | HIGH | |
| U-06 UI hidden via alpha 0 | LOW | |
| U-07 Layout group huge children | MEDIUM | HIGH if >100 |
| U-09 Legacy Text vs TMP | LOW | MEDIUM cumulative |
| A-01 Uncompressed/oversized textures | HIGH | CRITICAL if >5MB single asset |
| A-03 Audio wrong load type | MEDIUM-HIGH | Depends on clip length |
| A-04 Audio not compressed | MEDIUM | HIGH cumulative |
| A-05 Stereo SFX | LOW | |
| A-07 SceneManager.LoadScene blocking | HIGH | MEDIUM if init |
| A-08 Instantiate without pooling | HIGH | For hot-path spawners |
| B-01 Mono backend on iOS | CRITICAL | Apple Store reject |
| B-01 Mono backend on Android | HIGH | |

## Aggregation Heuristics

- **Cap critical count:** if the run produces > 15 CRITICAL items, the aggregator MUST re-examine — likely a category reviewer was too aggressive. Demote items in editor-only / third-party paths.
- **Group by file:** when reporting to user, group findings by file. A file with 7 issues shouldn't surface as 7 separate top-level entries.
- **Dedupe pattern:** same issue-id + same file + same line → one entry. Same issue-id + same file but different lines → keep both but display once with "× N occurrences".

## Output Constraints

- Severity in output is UPPERCASE: `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`.
- Every finding has exactly one severity — no "HIGH-MEDIUM" or ranges.
- Severity must justify itself via the rules above in the finding's `rationale` field (one short clause).
