# Phase 5 Plan Review

## Verdict
**APPROVE-WITH-AMENDMENTS**

Phase 5 addresses critical P3 token economics, sigil eradication, gateway zero stub certification, and manifest synchronization. The plan is well-structured with reproducible gates and exact line citations. Two amendments must be incorporated before/during implementation to ensure complete invariant coverage and eliminate gate leakage.

---

## Required Amendments

### 1. Item 1 & Item 5 Sigil Regex Gate Leakage (@alias and @fable Omission)
- **Path & Line**: [.plans/phase-5/PLAN.md:28](file:///Users/purplelephant/projects/asex/.plans/phase-5/PLAN.md#L28), [.plans/phase-5/PLAN.md:200](file:///Users/purplelephant/projects/asex/.plans/phase-5/PLAN.md#L200)
- **Citations**: [agent/src/tui.asl:61](file:///Users/purplelephant/projects/asex/agent/src/tui.asl#L61), [agent/tests/tui-test.asl:76](file:///Users/purplelephant/projects/asex/agent/tests/tui-test.asl#L76)
- **Finding**:
  The gate verification regex in Item 1 and Item 5 currently specifies:
  ```python
  pattern = re.compile(r"(@ref:|#L|@scout|@coder|@reviewer)")
  ```
  Physical code inspection reveals 2 additional prohibited sigils that escape this pattern:
  - `agent/src/tui.asl:61`: `(str "  [Agent: " role "] routed to alias @" alias " (" model ")"))` contains `@` in `alias @`.
  - `agent/tests/tui-test.asl:76`: `(assert (string-contains? b "alias @fable") "contains alias")` contains `@fable`.
  
  Under the current gate regex, a conformant-but-wrong implementation that only eradicates `@ref:`, `#L`, `@scout`, `@coder`, and `@reviewer` would leave `@` in `agent/src/tui.asl:61` and `agent/tests/tui-test.asl:76`, yet the gate would PASS.
  
  Total prohibited `@` and `#` occurrences across the 5 files are **32**, not 30.
- **Action**:
  Broaden the regex in Item 1 and Item 5 to audit all `@` and `#` sigils across the 5 target files (matching Invariant C5 and `has-sigil?` in `asl-lint`):
  ```python
  pattern = re.compile(r"(@|#)")
  ```
  Update the recorded baseline count to 32 (or `(@ref:|#L|@scout|@coder|@reviewer|@alias|@fable|@)`).

### 2. Sequential Wave Serialization for Item 1 and Item 4 on `intel/tests/xref_test.asl`
- **Path & Line**: [.plans/phase-5/PLAN.md:39](file:///Users/purplelephant/projects/asex/.plans/phase-5/PLAN.md#L39), [.plans/phase-5/PLAN.md:185-187](file:///Users/purplelephant/projects/asex/.plans/phase-5/PLAN.md#L185-L187)
- **Finding**:
  Both Item 1 (`owns: ["intel/src/xref.asl", "intel/tests/xref_test.asl", ...]`) and Item 4 (`owns: ["intel/tests/xref_test.asl"]`) claim ownership of `intel/tests/xref_test.asl`.
  
  While Item 4 correctly declares `depends_on: ["item-1"]`, parallel executors must enforce strict wave boundaries:
  - **Wave 1**: Items 1, 2, and 3 run concurrently (strictly disjoint file ownership).
  - **Wave 2**: Item 4 runs sequentially after Item 1 completes and verifies.
  - **Wave 3**: Item 5 runs final repo-wide master gate audit.
- **Action**:
  Explicitly formalize wave assignments in the plan or execution notes so implementers do not attempt to execute Item 4 in parallel with Item 1.

---

## Verified Baseline Failures

All 5 items were independently reproduced and verified to fail on current disk baseline:

1. **Item 1 (Invariant C5 Sigil Eradication)**:
   - **Command**: Gate Python regex check + `./bin/asl test intel/tests/xref_test.asl intel/tests/boundary_test.asl agent/tests/tui-test.asl`
   - **Baseline Result**: **FAILS (exit 1)**. Output: `Total prohibited sigil occurrences found: 30`.
2. **Item 2 (STUB-01 Zero Stub Certification)**:
   - **Command**: Gate Python check on `bin/asl-gateway`
   - **Baseline Result**: **FAILS (exit 1)**. Output:
     - `STUB-01: mock-local fallback mode present in bin/asl-gateway`
     - `STUB-01: mock_completion simulation present in bin/asl-gateway`
     - `STUB-01: 503 unconfigured diagnostic error handler missing in bin/asl-gateway`
3. **Item 3 (MAN-01..05 Manifest Synchronization)**:
   - **Command**: Gate Python manifest validation + `./bin/asl gate --only=1`
   - **Baseline Result**: **FAILS (exit 1)**. Detects missing `asl/web/manifest.asn`, missing `:modules` in 8 manifests, and incomplete 2 of 14 modules in `agent-bus/manifest.asn`.
4. **Item 4 (D51 PascalCase Test Refactor)**:
   - **Command**: Gate Python PascalCase defs check + `./bin/asl test --strict-falsify intel/tests/xref_test.asl`
   - **Baseline Result**: **FAILS (exit 1)**. Output: `D51 violation: 8 kebab test defs remain, 8 PascalCase defs missing`.
5. **Item 5 (Repo Master Gate Verification)**:
   - **Command**: Gate Python multi-invariant check + `./bin/asl gate`
   - **Baseline Result**: **FAILS (exit 1)**. Output: `Phase 5 incomplete: C5=30 sigils, STUB-01=True, MAN-01 web manifest=False, D51=True`.
   - **Master Gate Baseline Check**: Independent `./bin/asl gate` execution passes 7/7 gates on the unedited codebase, verifying zero pre-existing regressions.

---

## Non-blocking Suggestions

1. **Gateway Bash Syntax Validation**: In Item 2 gate, add `bash -n bin/asl-gateway` to ensure bash wrapping syntax is verified after removing the fallback blocks.
2. **Manifest Module Format Linting**: In Item 3, verify that all declared `:modules` entries match valid module paths within each package's `src/` hierarchy.

---

## Unverified
None. All 5 gate commands, citations, and source files were inspected and executed directly in clean context.
