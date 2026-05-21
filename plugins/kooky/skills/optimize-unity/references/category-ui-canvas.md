# Category: UI / Canvas

Scans Canvas hierarchies in scenes and prefabs, plus UI-touching scripts.

## Issues To Detect

### U-01. Single mega-canvas with mixed update frequencies
- **Detection:** A `Canvas` component whose descendant tree contains BOTH "static" elements (Image with permanent sprite, Text without timer code) AND "dynamic" elements (Text driven by Update, time/score display, animated UI).
- **Heuristic:** Canvas root has >20 descendant `MaskableGraphic`-derived components.
- **Why bad:** Any dirty descendant rebuilds the whole canvas mesh.
- **Severity hint:** HIGH if root canvas has >40 elements, MEDIUM 20-40.
- **Fix:** Split into 2 canvases (Static + Dynamic). Requires Editor structural change — emit as manual with clear instruction. UnityMCP can create new Canvas + reparent if supported.

### U-02. `Raycast Target` enabled on non-interactive UI
- **Detection:** Image, RawImage, Text, TMP_Text components in scenes/prefabs where `m_RaycastTarget: 1` AND no `Button`/`Toggle`/`Slider`/`InputField`/`EventTrigger`/`Selectable` on same GameObject or any ancestor up to Canvas. Names heuristic: `Background`, `Title`, `Label`, `Icon`, `Divider`.
- **Why bad:** Every pointer event walks all raycast targets.
- **Severity hint:** MEDIUM. HIGH if >50 elements have raycast on.
- **Fix:** Set `m_RaycastTarget: 0` on each non-interactive Graphic. Safe and reversible. UnityMCP `set_component_property` per element, or sweep the prefab.

### U-03. Canvas deactivated via GameObject.SetActive instead of Canvas.enabled
- **Pattern (grep):** Scripts that toggle a UI parent. Look for `\.gameObject\.SetActive\(` near references to fields/objects named `*[Cc]anvas*`, `*[Pp]anel*`, `*[Mm]enu*`.
- **Why bad:** SetActive(false) destroys batched mesh; on re-activate, full rebuild + draw call hit.
- **Severity hint:** MEDIUM.
- **Fix:** Replace with `canvas.enabled = false`. Show before/after in fix patterns. If GameObject toggle is intentional (entire panel logic suspends), document that — emit as manual.

### U-04. UI Element animated via Animator
- **Detection:** Animator component on a GameObject inside a Canvas tree (any descendant has `Canvas` ancestor). Combined with controller referencing UI-relevant fields (RectTransform anchoredPosition, Image color/sprite).
- **Why bad:** Animator change dirties Canvas every frame → full UI rebuild.
- **Severity hint:** HIGH.
- **Fix:** Replace with tweening library (DOTween, LeanTween) or direct lerp in Update. Cannot auto-fix — manual action with named files.

### U-05. ScrollView without RectMask2D
- **Detection:** GameObjects with `ScrollRect` component whose `Viewport` child lacks `RectMask2D`. Look for `m_Viewport` reference and check the referenced object's component list.
- **Why bad:** Off-screen children still trigger layout + raycast.
- **Severity hint:** HIGH (ScrollViews are common hot spots).
- **Fix:** Add `RectMask2D` component to the Viewport. UnityMCP `add_component`.

### U-06. UI hidden via alpha = 0
- **Detection:** CanvasGroup with `m_Alpha: 0` AND `m_BlocksRaycasts: 0` AND `m_Interactable: 0` — this is INTENDED (proper hide). NOT a finding.
- **Real finding:** Image/Text with `m_Color: {a: 0}` while `m_Enabled: 1` → emits draw call invisible.
- **Why bad:** Element still drawn.
- **Severity hint:** LOW.
- **Fix:** Set `m_Enabled: 0` on the Image/Text instead, OR use CanvasGroup with blocksRaycasts=false.

### U-07. Layout Group with many children + Content Size Fitter
- **Detection:** GameObjects with `VerticalLayoutGroup`, `HorizontalLayoutGroup`, or `GridLayoutGroup` AND descendant or self has `ContentSizeFitter` AND >30 children.
- **Why bad:** Layout dirty propagation rebuilds full chain on any child change.
- **Severity hint:** MEDIUM (HIGH if >100 children).
- **Fix:** Consider virtualized scroll (manual rewrite). Note in manual actions. For static lists, can bake sizes and disable Fitter — case-by-case.

### U-09. Text using Built-in `Text` component instead of TextMeshPro
- **Detection:** Components `Text` (`!u!114` with `m_Script` GUID of legacy UI Text). Count instances. If TMP is in package manifest AND legacy `Text` count > 0 → flag.
- **Why bad:** Legacy Text rebuilds mesh on every character change, no SDF, more draw calls.
- **Severity hint:** LOW per element, MEDIUM cumulative.
- **Fix:** Migration is non-trivial; emit as manual action with link to "Convert to TextMeshPro" Unity menu.

## Detection Workflow

1. Glob `Assets/**/*.unity`, `Assets/**/*.prefab` — every scene/prefab with a Canvas.
2. Build a quick tree of Canvas → children for each found Canvas root. Many findings need parent-child context.
3. For U-02 (raycast target), match the GameObject's component list (Button, Toggle, etc.) to decide if interactive.
4. Skip Editor-only canvases in `Assets/**/Editor/**`.

## Notes for the Reviewer

- UI is the #1 source of waste in casual / mobile games — prioritize this category for mobile projects.
- Raycast Target sweep (U-02) can produce dozens of findings — group by parent prefab and report counts.
- Many UI fixes are 100% safe (U-02, U-05); a few are risky (U-01 canvas split). Severity hint should reflect risk + impact, not just impact.
- If TMP is not in the project, don't suggest TMP migration — emit only if TMP is already installed.
