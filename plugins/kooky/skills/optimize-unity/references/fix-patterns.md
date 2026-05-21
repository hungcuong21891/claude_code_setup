# Fix Patterns

Canonical before/after snippets per issue ID. The main agent uses these as the source-of-truth for `Edit` tool transformations. When a fix is risky, emit as "manual action" in the summary report instead of editing.

Convention:
- `B:` Before
- `A:` After
- `M:` UnityMCP recipe (if applicable)
- `R:` Risk / caveat — read this BEFORE editing. The risk line maps directly to the logic-preservation gate in SKILL.md Phase 5.

## Logic-Preservation Gate (READ FIRST)

**Every fix must preserve the program's observable behavior.** Performance changes only — never silently change semantics. Before applying any pattern below, run the five-check gate from SKILL.md Phase 5:

1. **Semantic equivalence** — same side-effects, return values, event firings, lifecycle order.
2. **Reference timing** — cached references resolve at the correct moment.
3. **No stale state** — buffers/callbacks/objects not retained across frames in conflict with the change.
4. **No external assumptions** — no other code path conflicts with the new shape.
5. **Idempotency** — fix not already applied.

If any check is **inconclusive** for a given finding, do NOT edit. Record as `uncertain` with the specific doubt, and surface in the summary's "Uncertain" section so the user can review. **A skipped fix is recoverable; a behavior regression is not.**

Behavior-affecting patterns that MUST be gated per-finding (never blanket-apply):
- `U-03` Canvas.enabled vs SetActive — different lifecycle callbacks fire.
- `C-10` Coroutine WaitForSeconds → Time.time — pause/timeScale behavior differs subtly.
- `A-07` LoadScene → LoadSceneAsync — callers expecting sync load break.
- `P-05` Reuse Collision Callbacks — breaks code that stores `Collision` across frames.
- `C-08` NonAlloc raycasts — undersized buffer silently drops hits.
- `P-01` / `R-02` Static flag — runtime movement no longer possible.
- `R-04` Bake real-time light — visual differences + long bake time.
- `B-01` Switch to IL2CPP — reflection-heavy plugins may need `link.xml`.

Pure-mechanical, low-risk patterns (still gated, but typically clear pass):
- `C-02` Cache `Camera.main`, `C-03` Cache `transform`, `C-04` `CompareTag`, `C-07` Delete empty callback, `C-09` `sqrMagnitude`.

## C-01 Cache GetComponent

```csharp
// B:
void FixedUpdate() {
    GetComponent<Rigidbody>().AddForce(Vector3.up * 10f);
}

// A:
Rigidbody _body;
void Awake() { _body = GetComponent<Rigidbody>(); }
void FixedUpdate() { _body.AddForce(Vector3.up * 10f); }
```
R: If the script can be added/removed at runtime to a parent, cache may be stale. Confirm no `Destroy(GetComponent<Rigidbody>())` exists.

## C-02 Cache Camera.main

```csharp
// B:
Vector3 p = Camera.main.WorldToScreenPoint(transform.position);

// A:
Camera _cam;
void Awake() { _cam = Camera.main; }
// then:
Vector3 p = _cam.WorldToScreenPoint(transform.position);
```
R: Camera tagged "MainCamera" must exist before this `Awake`. If your camera is spawned later, fall back to `Camera.main` once with null-check.

## C-03 Cache transform

```csharp
// A:
Transform _t;
void Awake() { _t = transform; }
// then use _t.position, _t.rotation, etc.
```

## C-04 CompareTag

```csharp
// B:
if (other.tag == "Player") { ... }
// A:
if (other.CompareTag("Player")) { ... }
```

## C-05 StringBuilder for UI Text

```csharp
// B:
void Update() { timerTxt.text = "Time: " + (int)t; }

// A:
using System.Text;
StringBuilder _sb = new StringBuilder(16);
int _lastShown = -1;
void Update() {
    int sec = (int)t;
    if (sec == _lastShown) return;        // bail when value unchanged
    _lastShown = sec;
    _sb.Length = 0;
    _sb.Append("Time: ").Append(sec);
    timerTxt.text = _sb.ToString();
}
```

## C-07 Delete empty MonoBehaviour callback

```csharp
// B (Update is empty):
void Update() { }

// A: remove the method entirely.
```
R: Some IDEs auto-insert stubs. Re-deletion after every regenerate.

## C-08 NonAlloc raycasts

```csharp
// B:
Collider[] hits = Physics.OverlapSphere(pos, radius, mask);

// A:
Collider[] _hitBuf = new Collider[16];
int n = Physics.OverlapSphereNonAlloc(pos, radius, _hitBuf, mask);
for (int i = 0; i < n; i++) { ... _hitBuf[i] ... }
```
R: Buffer size must be ≥ expected max hits; over-flow silently drops. Pick a generous constant.

## C-09 sqrMagnitude over Distance

```csharp
// B:
if (Vector3.Distance(a, b) < range) { ... }

// A:
float rSqr = range * range;
if ((a - b).sqrMagnitude < rSqr) { ... }
```
R: Only valid for comparisons; do not use for display ("you are X meters away").

## C-10 Time.time-based timer

```csharp
// B:
IEnumerator Tick() {
    while (true) { yield return new WaitForSeconds(1f); DoThing(); }
}

// A:
float _next;
void Update() {
    if (Time.time >= _next) { _next = Time.time + 1f; DoThing(); }
}
```
R: If game can pause via `Time.timeScale = 0`, this also pauses — desired in most cases.

## C-12 Cache Find result

```csharp
// B:
void Update() {
    GameObject p = GameObject.FindWithTag("Player");
    transform.LookAt(p.transform);
}

// A:
Transform _player;
void Awake() { _player = GameObject.FindWithTag("Player")?.transform; }
void Update() { if (_player) transform.LookAt(_player); }
```
R: If the Player can be respawned (new GameObject), reacquire on PlayerSpawned event.

## P-01 Set Static flag

```
B: Inspector → Static = unchecked
A: Inspector → Static dropdown → Batching Static (minimum) or Everything for permanent scenery.
```
M: UnityMCP set_static_flags on the GameObject by GUID. Flag mask: 4 = Batching, 31 = Everything.
R: Static objects cannot move at runtime, ever. Picking up the wrong object soft-locks physics until restart.

## P-02 Switch to Discrete collision

```yaml
# Rigidbody YAML in scene/prefab — only edit via UnityMCP:
m_CollisionDetection: 0   # 0=Discrete, 1=Continuous, 2=ContinuousDynamic, 3=ContinuousSpeculative
```
M: UnityMCP set_component_property on Rigidbody, `collisionDetectionMode = CollisionDetectionMode.Discrete`.

## P-05 Reuse Collision Callbacks

```yaml
# ProjectSettings/DynamicsManager.asset:
m_ReuseCollisionCallbacks: 1
```
M: UnityMCP `set_physics_setting(reuseCollisionCallbacks=true)`.
R: Breaks code that stores `Collision` object across frames. Search for `Collision _saved;` patterns first.

## R-02 Batching Static flag

Same as P-01. Set Batching Static (mask bit 4).

## R-03 Enable GPU Instancing on material

```yaml
# *.mat:
m_EnableInstancingVariants: 1
```
M: UnityMCP `set_material_property(enableInstancing=true)`.
R: Only useful when many renderers share this material. Verify with renderer count from R-03 detection.

## R-04 Bake real-time light

```yaml
# Light component:
m_Lightmapping: 1   # 0=Realtime, 1=Mixed, 2=Baked. URP/HDRP use different values.
```
M: UnityMCP set Light.lightmapBakeType; then trigger Lightmapping.Bake().
R: Baking takes minutes-hours. Always confirm with user before triggering.

## U-02 Disable Raycast Target

```yaml
# Image / Text / RawImage component:
m_RaycastTarget: 0
```
M: UnityMCP `set_component_property(raycastTarget=false)`. Batch-applicable across many components.
R: If a script later calls `GetComponent<Image>().raycastTarget = true`, it will re-enable. Search the project to confirm.

## U-03 Canvas.enabled instead of SetActive

```csharp
// B:
panel.gameObject.SetActive(false);

// A:
panel.GetComponent<Canvas>().enabled = false;
// or cache _canvas first.
```
R: If MonoBehaviours on the panel need OnDisable to fire, switch CHANGES BEHAVIOR. Verify lifecycle.

## U-05 Add RectMask2D

M: UnityMCP `add_component(target=ScrollRect.viewport, type='UnityEngine.UI.RectMask2D')`.

## A-01 Compress texture

```yaml
# *.png.meta:
textureCompression: 1   # 0=Uncompressed, 1=Compressed, 2=HighQuality
maxTextureSize: 1024    # was 4096
```
R: Reduces VRAM and disk; quality drop. Have user inspect before/after on representative device. Mobile platforms need ETC2/ASTC override blocks; do not auto-edit those without UnityMCP.

## A-03 Audio Load Type

```yaml
# *.wav.meta, *.mp3.meta:
loadType: 0   # 0=DecompressOnLoad (short SFX), 1=CompressedInMemory (medium), 2=Streaming (music)
```

## A-07 LoadSceneAsync

```csharp
// B:
SceneManager.LoadScene("Level2");

// A:
StartCoroutine(LoadAsync("Level2"));
IEnumerator LoadAsync(string name) {
    AsyncOperation op = SceneManager.LoadSceneAsync(name);
    while (!op.isDone) { uiProgress.value = op.progress; yield return null; }
}
```
R: Calling sites that depend on the next scene being immediately loaded will break. Audit callers.

## B-01 Switch to IL2CPP

```yaml
# ProjectSettings/ProjectSettings.asset:
scriptingBackend:
  Android: 1   # 0=Mono, 1=IL2CPP
  iOS: 1
```
M: UnityMCP `set_player_setting(scriptingBackend=ScriptingImplementation.IL2CPP, platform='Android')`.
R: Triggers a full recompile (5-30 min on first build). Some reflection-heavy plugins need a `link.xml` to avoid stripping.

## General Fix-Application Rules

1. **Run the Logic-Preservation Gate first.** See top of this file + SKILL.md Phase 5. Five checks: semantic equivalence, reference timing, stale state, external assumptions, idempotency. Any inconclusive check → `uncertain`, do NOT edit.
2. **One file = one read + one set of edits.** Group multiple findings on the same .cs file into a single `Edit` call (or a sequence of edits after one Read).
3. **Verify after edit:** re-Read the relevant range to confirm the patch applied. If the pattern wasn't unique and `Edit` failed → mark `skipped` with reason `pattern-not-unique`, do not guess.
4. **Never** edit `ProjectSettings/*.asset` YAML by hand. Either via UnityMCP or emit as manual action.
5. **Never** edit a scene or prefab YAML by hand to change components — always UnityMCP or manual.
6. **OK to edit** `.meta` YAML directly with `Edit` for unambiguous flag flips (mipmapEnabled, forceToMono, loadType, isReadable, textureCompression). These are well-defined small fields. Still confirm with user up-front in Phase 4.
7. **Atomic per-finding:** each fix either applies fully or is skipped/uncertain. No partial fixes.
8. **Idempotent:** if the fix is already in place (e.g., `_cam` already cached), `Edit` will fail uniqueness — that's the signal to mark `already-applied` and move on.
9. **Outcome buckets are distinct** — `applied`, `manual` (needs Editor / UnityMCP user action), `uncertain` (logic-risk, surfaced in dedicated summary section), `skipped` (already-applied / pattern-not-unique / user-deselected). Never collapse `uncertain` into `skipped`.
