# Phase 4 Plan Review

## Verdict
**APPROVE-WITH-AMENDMENTS**

Phase 4 successfully addresses critical P2 invariants and boundary consolidations across Unicode emojis, enum multi-definitions, and duplicate function sprawl. Two amendments are required to ensure strict gate falsifiability:

---

## Required Amendments

### 1. Item 2 (../../ Escapes) is Already Clean on Target Directories (Vacuous Gate)
- **Path & Line**: [.plans/phase-4/PLAN.md:37-56](file:///Users/purplelephant/projects/asex/.plans/phase-4/PLAN.md#L37-L56)
- **Finding**:
  Gate 2 executes:
  ```bash
  ! grep -rn "\.\./\.\./" intel/ mem/ agent-bus/
  ```
  Physical baseline audit confirms that `intel/`, `mem/`, and `agent-bus/` currently contain **zero** occurrences of `../../` (already resolved in prior commits).
  Because `grep` finds 0 matches and returns exit 1, `! grep` evaluates to `0` immediately on baseline. An empty implementation trivially passes.
- **Action**:
  Update Item 2 to acknowledge the verified clean state of `intel/`, `mem/`, and `agent-bus/`, or broaden the gate to verify monorepo-wide imports (`! grep -rn "(\.\./\.\./" **/*.asl`), ensuring non-vacuous assertion.

### 2. Item 3 Regex Word Boundary Fix for Newline Formatting
- **Path & Line**: [.plans/phase-4/PLAN.md:76-80](file:///Users/purplelephant/projects/asex/.plans/phase-4/PLAN.md#L76-L80)
- **Finding**:
  Gate 3 uses `re.search(r"\(dfe\s+TaskState ", ...)` with a literal trailing space.
  In `agent-core/src/dag.asl:15`, `tasktypes.asl:6`, and `clarify.asl:15`, `TaskState` is followed immediately by a newline `\n`. The regex matches 0 records rather than the actual 3 definitions.
- **Action**:
  Change regex from `r"\(dfe\s+TaskState "` to `r"\(dfe\s+TaskState\b"` and `r"\(dfs\s+TaskRecord\b"`. Verified baseline detection accurately reports 3 `TaskState` definitions and 3 `TaskRecord` definitions.

---

## Verified Items

1. **Item 1 (Invariant C2 Unicode Emojis & Pictographs)**:
   - Baseline check: **FAILS (exit 1)** as required. 44 files contain raw Unicode symbols (`🌀..🫿`, `▶▼⠋❯◆✔✓✗⏸`).
2. **Item 4 (56 Duplicate Helpers in `mem/src` & Orphan Test)**:
   - Baseline check: **FAILS (exit 1)** as required. Exactly 56 duplicate function definitions detected across `mem/src/*.asl` and `pack/tests/standalone.test.asl` is present.
