# Category: Code / Scripting

Scans `Assets/**/*.cs`. Skip `Assets/Plugins/**`, `Assets/ThirdParty/**`, `Library/**`, `Temp/**`, `*.Editor/**` unless project owner asks.

## Issues To Detect

### C-01. Uncached GetComponent in hot path
- **Pattern (grep):** `GetComponent<[A-Za-z0-9_]+>\(\)` inside `void (Update|FixedUpdate|LateUpdate)\b`
- **Why bad:** GetComponent walks the component list each call; in Update it runs 60+ times/sec per instance.
- **Severity hint:** HIGH (CRITICAL if inside loops or many instances).
- **Fix:** Cache reference in `Awake()` (or `[SerializeField]` if assignable in editor). Replace `GetComponent<T>().X` calls with cached field.

### C-02. Camera.main repeated access
- **Pattern:** `Camera\.main\b` anywhere in script files. Especially flag inside Update/FixedUpdate/LateUpdate.
- **Why bad:** `Camera.main` performs a tag-based scene search.
- **Severity hint:** HIGH inside Update, MEDIUM elsewhere if called >1x.
- **Fix:** Cache once: `Camera _cam; void Awake(){ _cam = Camera.main; }`.

### C-03. Repeated `transform` access in tight loops
- **Pattern:** `transform\.(position|rotation|localScale|forward|up|right)` referenced ≥3× in same Update/FixedUpdate body.
- **Why bad:** `transform` internally calls `GetComponent<Transform>()`.
- **Severity hint:** MEDIUM. CRITICAL only if inside nested loops.
- **Fix:** `Transform _t; void Awake(){ _t = transform; }` then use `_t.position` etc.

### C-04. `tag ==` string comparison
- **Pattern:** `\.tag\s*==\s*"`
- **Why bad:** Allocates string comparison every call; `CompareTag` is faster and avoids GC.
- **Severity hint:** MEDIUM (HIGH if inside OnCollision/OnTrigger hot path).
- **Fix:** `if (other.CompareTag("Player"))`.

### C-05. String concat in Update for UI Text
- **Pattern:** `(Text|TMP_Text|TextMeshProUGUI)[^;]*\.text\s*=\s*[^;]*\+` inside `Update|FixedUpdate|LateUpdate` (multiline regex).
- **Why bad:** Every concat allocates new string → GC pressure each frame.
- **Severity hint:** HIGH.
- **Fix:** Use `StringBuilder` from `System.Text`, clear via `sb.Length = 0` then `Append`, assign `sb.ToString()`. Only write when value actually changes.

### C-06. `new Vector(2|3|4)` allocated every Update
- **Pattern:** `new Vector[234]\(` inside Update/FixedUpdate.
- **Why bad:** Although struct, repeated construction inflates IL and shows up in Profiler when combined with math calls.
- **Severity hint:** LOW per occurrence, MEDIUM if dozens of sites.
- **Fix:** Cache as field, mutate components directly: `_v.x = ...; _v.y = ...`.

### C-07. Empty MonoBehaviour callbacks
- **Pattern:** Method bodies `^\s*(void|private void|protected void)\s+(Awake|Start|OnEnable|Update|LateUpdate|FixedUpdate)\s*\(\s*\)\s*\{\s*\}` (multiline) OR with only whitespace/comments.
- **Why bad:** Unity still adds them to the call list; thousands of objects → real cost.
- **Severity hint:** MEDIUM for Update/FixedUpdate/LateUpdate, LOW for Awake/Start/OnEnable.
- **Fix:** Delete the empty method entirely.

### C-08. Allocating Physics raycasts
- **Pattern:** Calls to `Physics\.(OverlapBox|OverlapSphere|OverlapCapsule|RaycastAll|SphereCastAll|BoxCastAll|CapsuleCastAll)\(` AND the 2D variants `Physics2D.OverlapCircleAll`, `Physics2D.OverlapAreaAll`, etc.
- **Why bad:** Allocates a new array every call. GC spikes.
- **Severity hint:** HIGH if inside Update, MEDIUM if rare.
- **Fix:** Use `NonAlloc` variant + pre-sized buffer field `Collider[] _buf = new Collider[16];`. Returns count.

### C-09. `magnitude` / `Vector3.Distance` in comparisons
- **Pattern:** `\.magnitude\b` or `Vector[23]\.Distance\(.*\)\s*[<>]=?` (used in comparison).
- **Why bad:** sqrt is expensive; comparing squared distances avoids the sqrt.
- **Severity hint:** MEDIUM (HIGH if hot path).
- **Fix:** `(a-b).sqrMagnitude < r*r`. Pre-compute `rSqr = r*r`.

### C-10. Coroutine/InvokeRepeating used as a per-second timer
- **Pattern:** `StartCoroutine\([^)]*\)` followed by yield `WaitForSeconds`, or `InvokeRepeating\(` with interval ≥ 0.1s used for displays/timers.
- **Why bad:** Coroutine allocates state-machine memory each yield; InvokeRepeating slightly cheaper but still reflective. Time.time check is free.
- **Severity hint:** MEDIUM.
- **Fix:** Drive in Update with `if (Time.time >= _next) { _next = Time.time + interval; Tick(); }`.

### C-11. `foreach` over hot-path arrays/lists
- **Pattern:** `foreach\s*\(` inside Update/FixedUpdate/LateUpdate AND collection type is `List<T>` or `T[]`.
- **Why bad:** `foreach` on List<T> in older Mono allocates IEnumerator; on arrays it's fine, but compilers vary.
- **Severity hint:** LOW.
- **Fix:** Replace with `for (int i = 0; i < list.Count; i++)`. Skip if Burst/IL2CPP project AND collection isn't a List.

### C-12. `GameObject.Find` / `FindObjectOfType` in hot path
- **Pattern:** `(GameObject\.Find|GameObject\.FindWithTag|FindObjectOfType|FindObjectsOfType)\(` outside `Awake/Start/OnEnable`.
- **Why bad:** Full scene walk per call.
- **Severity hint:** CRITICAL inside Update, MEDIUM in init.
- **Fix:** Move to `Awake`/`Start` and cache; or use `[SerializeField]` + assign in Inspector.

### C-13. `Resources.Load` in hot path
- **Pattern:** `Resources\.Load(<.+>)?\(` outside init methods.
- **Why bad:** Disk I/O and IL2CPP reflection cost.
- **Severity hint:** HIGH inside loops, MEDIUM otherwise.
- **Fix:** Load once into a field on Awake; consider Addressables for larger projects.

### C-15. LINQ in hot path
- **Pattern:** `using System\.Linq` AND any of `\.Where\(|\.Select\(|\.OrderBy\(|\.ToList\(|\.ToArray\(|\.FirstOrDefault\(` inside Update/FixedUpdate.
- **Why bad:** Allocates enumerator and intermediate collections.
- **Severity hint:** HIGH.
- **Fix:** Rewrite with explicit `for` loop; pre-filter into a cached buffer.

## Detection Workflow

1. Glob `Assets/**/*.cs` (skip excluded dirs above).
2. For each issue ID above, run a Grep with the pattern. Use `output_mode: content` with `-n` and 1 line context.
3. For each match, open file and capture 3-line excerpt around the match.
4. Emit finding entry per the SKILL.md schema.

## Notes for the Reviewer

- Some patterns are noisy (e.g., `transform.` in random utility scripts). Prioritize hits in MonoBehaviour subclasses with active `Update`/`FixedUpdate`.
- If a file has `[BurstCompile]` or `IJobParallelFor` ignore allocations — handled differently.
- Flag editor-only scripts (`#if UNITY_EDITOR`, `Assets/**/Editor/**`) at LOW severity regardless of pattern; they don't ship.
