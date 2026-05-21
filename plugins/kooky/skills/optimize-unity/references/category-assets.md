# Category: Assets (Sprites / Audio / Scenes)

Scans `.meta` files for textures and audio, and scene-loading code patterns.

## Issues To Detect

### A-01. Uncompressed / oversized textures
- **Detection:** `Assets/**/*.{png,jpg,jpeg,psd,tga}.meta`. Look for:
  - `textureCompression: 0` (Uncompressed)
  - `maxTextureSize: 4096` AND file is UI/non-hero asset (heuristic via path: contains `/UI/`, `/Icons/`, `/Buttons/`).
- **Why bad:** Inflates build size; uncompressed VRAM 4-8× larger.
- **Severity hint:** HIGH per case for mobile, MEDIUM for desktop. CRITICAL if file is >5MB on disk.
- **Fix:** Set `textureCompression: 1` (Compressed) or `2` (HighQuality); for UI, cap `maxTextureSize: 1024` or `512`. Use `androidETC2FallbackOverride` per-platform via UnityMCP if available. Safer to emit as manual unless UnityMCP confirmed.

### A-03. Audio Load Type wrong for clip length
- **Detection:** `Assets/**/*.{wav,mp3,ogg,aif,aiff}.meta`. Read clip metadata if available. Rules:
  - Clip <5s with `loadType: 1` (CompressedInMemory) or `2` (Streaming) → MEDIUM finding, should be `0` (DecompressOnLoad).
  - Clip >60s with `loadType: 0` (DecompressOnLoad) → HIGH finding, should be `2` (Streaming).
  - Background music marked as 3D AND `forceToMono: 0` → MEDIUM, force to mono.
- **Why bad:** Wrong load type wastes RAM (long clips decoded) or CPU (short clips streamed).
- **Severity hint:** See rules above.
- **Fix:** Edit `.meta` `loadType` field. Provide before/after snippet.

### A-04. Audio not compressed
- **Detection:** `.meta` files with `compressionFormat: 0` (PCM) AND clip > 1MB on disk.
- **Why bad:** Build size bloat.
- **Severity hint:** MEDIUM (HIGH if many large clips).
- **Fix:** Set `compressionFormat: 2` (Vorbis) for music, `1` (ADPCM) for short SFX. Quality 70-100 acceptable.

### A-05. Stereo SFX
- **Detection:** `.meta` files for short SFX (clip <3s heuristic — path contains `/SFX/`, `/Sounds/SFX/`) where `forceToMono: 0`.
- **Why bad:** Doubles file size for no audible benefit on positional sources.
- **Severity hint:** LOW.
- **Fix:** Set `forceToMono: 1`. Safe.

### A-06. Audio sample rate too high
- **Detection:** `.meta` `sampleRateSetting: 0` (Preserve) AND original sample rate likely 48000+ for game SFX/music.
- **Why bad:** 22050-44100 is plenty for games; halves size at 22050.
- **Severity hint:** LOW per case.
- **Fix:** Set `sampleRateSetting: 1` (OptimizeSampleRate) or `2` (Override) at 44100/22050.

### A-07. SceneManager.LoadScene used (blocking) instead of LoadSceneAsync
- **Pattern (grep):** `SceneManager\.LoadScene\(` without `Async`.
- **Why bad:** Stalls main thread until scene loads.
- **Severity hint:** HIGH if called outside `Awake/Start` of an existing scene (mid-gameplay transition), MEDIUM otherwise.
- **Fix:** Replace with `SceneManager.LoadSceneAsync(...)`, wrap in coroutine for loading screen. Provide template.

### A-08. Heavy `Instantiate` calls without object pooling
- **Pattern (grep):** `Instantiate\(` inside Update/FixedUpdate, OR called within methods named `Spawn|Shoot|Fire|Emit`. Cross-check: same prefab referenced > 5 times via field naming → likely pooling candidate.
- **Why bad:** Allocates new GameObjects and components per call; destroys them too → GC.
- **Severity hint:** HIGH for hot-path spawners (bullets, particles), MEDIUM for level-setup.
- **Fix:** Introduce object pooling. Cannot auto-rewrite — emit as manual action with link to pooling template (could be added in assets/ later).

### A-09. Levels-as-scenes instead of prefab-levels
- **Detection:** `EditorBuildSettings.asset` lists ≥20 scenes named `Level_*`, `Lvl*`, `Stage_*`. Likely better as prefabs unless very heavy.
- **Why bad:** Loading scenes is heavier than swapping prefabs; teardown cost.
- **Severity hint:** LOW (project-specific decision).
- **Fix:** Manual recommendation, not auto-applied.

## Detection Workflow

1. Glob targets:
   - Textures: `Assets/**/*.png.meta`, `Assets/**/*.jpg.meta`, `Assets/**/*.psd.meta`, `Assets/**/*.tga.meta`
   - Audio: `Assets/**/*.wav.meta`, `Assets/**/*.mp3.meta`, `Assets/**/*.ogg.meta`
   - Scenes: `EditorBuildSettings.asset`
   - Scripts: `Assets/**/*.cs` for A-07, A-08.
2. Read each .meta and extract relevant fields. .meta is YAML — safe to grep + read line counts.
3. For UI-vs-non-UI texture distinction, use path heuristics. State the heuristic in the evidence.

## Notes for the Reviewer

- .meta edits are safer than ProjectSettings edits and CAN be applied via direct file edit. Still confirm with user.
- Don't propose Vorbis on ALL audio — short SFX prefer ADPCM (cheaper to decode).
- A-08 (pooling) is high-impact but high-effort — always emit as manual unless a pooling utility already exists in the project (check `Assets/**/*Pool*.cs`).
