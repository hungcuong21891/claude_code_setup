# Category: Physics

Scans prefabs, scenes, ProjectSettings, and physics-touching scripts. Reviewer must distinguish 2D vs 3D project (detected in recon).

## Issues To Detect

### P-01. Non-static colliders on permanent geometry
- **Where:** `Assets/**/*.prefab`, `Assets/**/*.unity`.
- **Detection:** GameObjects with a Collider (or Collider2D) component AND no Rigidbody/Rigidbody2D AND `m_StaticEditorFlags: 0` in YAML (or no static flag). Patterns:
  - YAML: `m_Component:.*Collider` near a transform with `m_StaticEditorFlags: 0`.
  - Naming heuristic: names like `Wall`, `Floor`, `Ground`, `Platform`, `Obstacle`, `Tree`, `Rock`, `Building`, `Fence`.
- **Why bad:** Unity treats them as dynamic in physics, paying every-step overhead.
- **Severity hint:** HIGH if ≥20 such objects, MEDIUM otherwise. CRITICAL if they exist in scenes used during gameplay.
- **Fix:** Set GameObject's Static flag (Batching Static at minimum). Use UnityMCP `set_static_flag` if available.

### P-02. Continuous collision detection on slow-moving Rigidbody
- **Where:** Rigidbody / Rigidbody2D components in scenes/prefabs.
- **Detection:** `m_CollisionDetection: 1` (Continuous), `2` (ContinuousDynamic), or `3` (ContinuousSpeculative) on objects whose Rigidbody has `m_Mass < 5` and is not bullet/projectile.
- **Why bad:** Continuous is 3-10× slower than Discrete; only justified for fast/small objects.
- **Severity hint:** HIGH per case. Confirm with name heuristic: NOT `Bullet`, `Projectile`, `Arrow`, `Missile`, `Ball`.
- **Fix:** Set `m_CollisionDetection: 0` (Discrete). Use UnityMCP if available; never patch scene YAML by hand without confirmation.

### P-03. Mesh / Polygon collider on dynamic / multiple objects
- **Detection:**
  - 3D: GameObjects with `MeshCollider` AND a Rigidbody attached, OR ≥10 MeshCollider instances total.
  - 2D: GameObjects with `PolygonCollider2D` having >12 path points (look for `m_Points` array size in YAML), OR ≥20 PolygonCollider2D instances.
- **Why bad:** Mesh/Polygon colliders are O(n) on vertex count. Box/Sphere/Capsule are O(1).
- **Severity hint:** HIGH.
- **Fix:** Replace with primitive composite (Box/Sphere/Capsule). If shape critical, simplify point count. Cannot be done automatically — emit as manual action.

### P-04. Layer collision matrix not pruned
- **Detection:** Read `ProjectSettings/DynamicsManager.asset` and `Physics2DSettings.asset`. Check `m_LayerCollisionMatrix`. If all bits enabled (all `FFFFFFFFFFFFFFFF`) AND project has ≥4 custom layers defined in `TagManager.asset` → finding.
- **Why bad:** Every collider pair-test runs even between layers that should never interact (e.g., Coin ↔ EnemyProjectile).
- **Severity hint:** MEDIUM.
- **Fix:** Manual — list defined layers and ask user which pairs should never collide. Then update matrix (UnityMCP or instructions for Edit → Project Settings → Physics).

### P-05. `Physics.reuseCollisionCallbacks` not enabled
- **Detection:** Read `ProjectSettings/DynamicsManager.asset`. Look for `m_ReuseCollisionCallbacks: 0`.
- **Why bad:** Each `OnCollisionEnter/Stay/Exit` allocates a new `Collision` object → GC pressure.
- **Severity hint:** MEDIUM. HIGH if project has many OnCollision callbacks.
- **Fix:** Set `m_ReuseCollisionCallbacks: 1`. Safe in 99% of cases; only breaks code that stores `Collision` reference across frames (rare).

### P-06. `Physics.autoSyncTransforms` enabled
- **Detection:** `ProjectSettings/DynamicsManager.asset` has `m_AutoSyncTransforms: 1`.
- **Why bad:** Every Transform change triggers physics resync; without this, sync only happens before FixedUpdate.
- **Severity hint:** MEDIUM.
- **Fix:** Set to 0 unless gameplay code relies on immediate sync (rare). If found, leave to user — add to manual actions with explanation.

### P-08. Spawning Static objects at runtime
- **Detection:** Scripts call `Instantiate` and the prefab has Batching/Static flags set.
- **Pattern (grep):** `Instantiate\(` AND look up the prefab to check static flags via .prefab YAML.
- **Why bad:** Re-baking static scenery causes spikes; static should be authored, not spawned.
- **Severity hint:** HIGH per occurrence.
- **Fix:** Either remove static flag from the spawnable prefab, OR pool a single static parent and reposition. Emit as manual.

### P-09. Empty `OnTrigger*` / `OnCollision*` callbacks
- **Pattern (grep, multiline):** `void\s+On(Trigger|Collision)(Enter|Stay|Exit)(2D)?\s*\([^)]*\)\s*\{\s*\}`
- **Why bad:** Unity still dispatches the call.
- **Severity hint:** LOW.
- **Fix:** Delete the method.

## Detection Workflow

1. Recon already told us 2D vs 3D — bias detection accordingly. Skip 2D-only patterns for pure-3D projects and vice versa.
2. Glob targets: `Assets/**/*.prefab`, `Assets/**/*.unity`, `ProjectSettings/DynamicsManager.asset`, `ProjectSettings/Physics2DSettings.asset`, `Assets/**/*.cs`.
3. Most physics finds need YAML inspection. For each scene/prefab containing a Collider AND no Rigidbody, capture the GameObject name (`m_Name:` field) for context.
4. Group findings per ProjectSettings file when applicable (one P-04, P-05, P-06 finding total, not per layer pair).

## Notes for the Reviewer

- ProjectSettings YAML changes are GLOBAL — they affect everything. Always mark severity precisely so user can opt-in.
- If UnityMCP isn't connected, ALL settings changes go into "manual actions" — do not modify YAML by hand for ProjectSettings.
- For prefab/scene Static flag fixes: safe to flag via UnityMCP `set_static_flag` per GameObject.
- Distinguish 2D vs 3D in finding evidence ("uses PolygonCollider2D" vs "uses MeshCollider").
