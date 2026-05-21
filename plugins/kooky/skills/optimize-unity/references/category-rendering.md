# Category: Rendering

Scans materials, scenes, prefabs, lights, and ProjectSettings/QualitySettings.

## Issues To Detect

### R-01. Dynamic batching disabled
- **Detection:** `ProjectSettings/GraphicsSettings.asset` → `m_DynamicBatching: 0` (URP/HDRP projects ignore — handled by SRP Batcher).
- **Render pipeline check:** Look for `Assets/**/*.asset` with `UniversalRenderPipelineAsset` or `HDRenderPipelineAsset` to determine pipeline. Built-in RP → flag.
- **Why bad:** More draw calls than necessary for small dynamic meshes sharing materials.
- **Severity hint:** MEDIUM (only useful in Built-in RP).
- **Fix:** Set `m_DynamicBatching: 1` (Edit → Project Settings → Player → Other Settings → Dynamic Batching) via UnityMCP.

### R-02. Static batching not enabled on static geometry
- **Detection:** GameObjects in scenes/prefabs with `MeshRenderer` AND `m_StaticEditorFlags: 0` (none set) AND name matches static-geo heuristics (see P-01).
- **Why bad:** Each static mesh draws separately even when sharing material.
- **Severity hint:** HIGH if ≥20 such objects.
- **Fix:** Set `m_StaticEditorFlags: 4` (Batching Static) or higher. Per-GameObject via UnityMCP.

### R-03. GPU Instancing disabled on materials
- **Detection:** `Assets/**/*.mat`. Look for `m_EnableInstancingVariants: 0` AND `m_Shader` references either Standard or URP/Lit (these support instancing). For each material referenced by ≥5 MeshRenderers (cross-ref needed) → finding.
- **Why bad:** Cuts draw calls when many objects share material but differ in transform.
- **Severity hint:** MEDIUM.
- **Fix:** Set `m_EnableInstancingVariants: 1` in the material. Safe — only adds GPU instancing variants at build.

### R-04. Real-time lights count too high
- **Detection:** Per scene `.unity`, count instances of `--- !u!108 &` (Light component). If a scene has >3 real-time non-baked lights (`m_Lightmapping: 4`, where 4 = Realtime), flag.
- **Why bad:** Real-time lighting adds draw call multipliers and shadow passes.
- **Severity hint:** HIGH on mobile-target projects, MEDIUM on desktop.
- **Fix:** Bake stationary lights: set `m_Lightmapping: 0` (Baked) or `1` (Mixed). Then bake lighting via Window → Rendering → Lighting (UnityMCP `bake_lighting` if available). Cannot do safely without user confirmation.

### R-05. Light Culling Mask = Everything
- **Detection:** Light components with `m_CullingMask: -1` (Everything) when project has custom layers.
- **Why bad:** Light affects every object even when meaningless (e.g., UI layer, gizmos).
- **Severity hint:** LOW.
- **Fix:** Exclude UI/non-renderable layers. Manual action — depends on project.

## Detection Workflow

1. Detect render pipeline first (Built-in vs URP vs HDRP) — many findings only apply to Built-in RP.
2. Globs: `Assets/**/*.unity`, `Assets/**/*.prefab`, `Assets/**/*.mat`, `Assets/**/*.png.meta`, `Assets/**/*.jpg.meta`, `ProjectSettings/{Graphics,Quality,Player}Settings.asset`.
3. For instancing finding, cross-reference material GUID with renderer counts via scene scan (sample top 10 materials by reference count).
4. Report counts in evidence ("scene X has 7 real-time lights") — helps user judge.

## Notes for the Reviewer

- Render pipeline drastically changes which settings matter. Always state the pipeline in the report header.
- Per-material instancing is safe to flip; per-scene light baking IS NOT — emit as manual action.
- Mobile target multiplies severity for many findings. Always check Player build target in recon.
- Do not propose URP migration or shader graph changes — out of scope.
