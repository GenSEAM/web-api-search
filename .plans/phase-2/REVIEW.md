# Phase 2 Plan Review

## Verdict
**REJECT**

Phase 2 cannot be approved in its current form due to non-falsifiable verification gates, missing engine recompilation steps that guarantee downstream test failure, incomplete defect scope across cited files, and unsequenced git submodule mutations.

---

## Blockers

### 1. Gate 1 Passes on Current Baseline (Non-Falsifiable) & Drops Related Comment Gaps
- **Path & Line**: [asl/packages/asl-sh/tests/session_test.asl:80-115](file:///Users/purplelephant/projects/asex/asl/packages/asl-sh/tests/session_test.asl#L80-L115), [.plans/phase-2/PLAN.md:64-80](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L64-L80)
- **Evidence**:
  Running Gate 1 on the current baseline:
  ```bash
  ! grep -E '^\s*;;' asl/packages/asl-sh/tests/session_test.asl && ./bin/asl test asl/packages/asl-sh/tests/session_test.asl && ./bin/asl audit gates
  ```
  Exits `0` immediately. `session_test.asl` contains zero semicolon line comments (verified via `grep ';'`). An empty / no-op implementation passes Gate 1.
  Furthermore, Item 1 claims to represent Phase 454 (`INV-01`, `INV-02`, `INV-03`), but completely omitted `INV-02` (51 embedded HTML/JS comments in `asl/web`) and `INV-03` (20 `grammar.asn` files retaining `;;` section comments).

### 2. Missing Engine Header Generation & Binary Recompilation in Item 4 (GATE-06, GATE-07)
- **Path & Line**: [asl/tools/engine.js:742-766](file:///Users/purplelephant/projects/asex/asl/tools/engine.js#L742-L766), [asl/tools/asl.c:2425](file:///Users/purplelephant/projects/asex/asl/tools/asl.c#L2425), [asl/tools/gen_engine_header.sh:1-36](file:///Users/purplelephant/projects/asex/asl/tools/gen_engine_header.sh#L1-L36), [.plans/phase-2/PLAN.md:174-206](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L174-L206)
- **Evidence**:
  `asl.c:2425` executes `engine_js`, which is an embedded C byte array generated in `asl/tools/engine_js.h` by `asl/tools/gen_engine_header.sh` and compiled into `bin/asl`. Item 4 modifies `asl/tools/engine.js` but does not regenerate `engine_js.h` nor recompile `bin/asl`.
  Gate 4 executes `./bin/asl test browser-plugin/tests/browser_agent_test.asl`, which will execute the old embedded engine code and continue to fail with `ERR_UNBOUND_SYMBOL: unknown builtin or function 'InferenceTarget:on-device-webgpu'`.
  Item 4 must explicitly include `asl/tools/engine_js.h`, `asl/asl`, and `bin/asl` in its ownership and execute `bash asl/tools/gen_engine_header.sh && clang -O2 -framework JavaScriptCore -o asl/asl asl/tools/asl.c && cp asl/asl bin/asl`.

### 3. Incomplete Scope of `core/strings` Eradication (GATE-02..05)
- **Path & Line**: [asl/web/asl-src/EcosystemView.asl:4](file:///Users/purplelephant/projects/asex/asl/web/asl-src/EcosystemView.asl#L4), [asl/web/src/components/Hero.asl:4](file:///Users/purplelephant/projects/asex/asl/web/src/components/Hero.asl#L4), [asl/web/src/components/Footer.asl:4](file:///Users/purplelephant/projects/asex/asl/web/src/components/Footer.asl#L4), [.plans/phase-2/PLAN.md:89-130](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L89-L130)
- **Evidence**:
  Item 2 states in its acceptance criterion that `core/strings` must be eradicated from all active packages, but leaves 15 files in `asl/web` importing `core/strings` (`EcosystemView.asl`, `ArchitectureView.asl`, `Hero.asl`, `Navbar.asl`, `Footer.asl`, etc.).
  While lines 309-310 defer `asl/web/asl-src/` to "Phase 455 continuation", Phase 2 claims to BE Phase 455, and Phase 3 explicitly excludes `core/strings`. This leaves `asl/web` permanently importing a nonexistent module.

### 4. Omission of Vacuous Assertions (`BND-07`) in Item 2 Boundary File
- **Path & Line**: [agent-bus/tests/browser-bridge-test.asl:68-70](file:///Users/purplelephant/projects/asex/agent-bus/tests/browser-bridge-test.asl#L68-L70), [.plans/phase-2/PLAN.md:107](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L107)
- **Evidence**:
  Item 2 owns `agent-bus/tests/browser-bridge-test.asl`. Lines 68-70 contain three consecutive `(assert true)` statements (`BND-07` in `GAPS.asn`). Item 2 removes the `core/strings` import but does not replace the vacuous assertions. Gate 2 does not enforce non-vacuous assertions or `--strict-falsify`, allowing a conformant-but-wrong implementation to pass.

### 5. Incomplete Scope of `:exports [` Canonicalization (`MAN-02`)
- **Path & Line**: [mem/src/ast_merge.asl:2](file:///Users/purplelephant/projects/asex/mem/src/ast_merge.asl#L2), [mem/src/stm.asl:3](file:///Users/purplelephant/projects/asex/mem/src/stm.asl#L3), [.plans/phase-2/PLAN.md:146](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L146)
- **Evidence**:
  Item 3 targets 4 files for `:exports [` -> `:x`, and Gate 3 specifically restricts its grep to those 4 files. However, `mem/src/ast_merge.asl:2` and `mem/src/stm.asl:3` also contain `:exports [`. A conformant-but-wrong implementation will pass Gate 3 while leaving non-standard module headers in `mem/src/`.

### 6. Same-File Omission of Unbound Builtin `to-string` (`GATE-12`) in Item 5
- **Path & Line**: [harness/src/steps-pipeline.asl:624](file:///Users/purplelephant/projects/asex/harness/src/steps-pipeline.asl#L624), [harness/tests/teleology_test.asl:224](file:///Users/purplelephant/projects/asex/harness/tests/teleology_test.asl#L224), [.plans/phase-2/PLAN.md:208-257](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L208-L257)
- **Evidence**:
  Item 5 owns `harness/src/steps-pipeline.asl` and refactors `set!` on lines 475-490 (`GATE-10`). However, line 624 of the exact same file invokes `(to-string replan-idx)`, which is non-existent in ASL and causes `harness/tests/teleology_test.asl` to fail (`GATE-12`). Leaving this defect unaddressed in a file owned by Item 5 causes avoidable regression debt.

### 7. File Ownership Collision & Missing Git Submodule Sequencing in Wave 1
- **Path & Line**: [.plans/phase-2/PLAN.md:248-256](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L248-L256), [.plans/phase-2/PLAN.md:278-285](file:///Users/purplelephant/projects/asex/.plans/phase-2/PLAN.md#L278-L285)
- **Evidence**:
  - `harness/manifest.asn` is modified by both Item 2 and Item 5, but Item 5 omits `harness/manifest.asn` from its `owns` declaration list.
  - In Wave 1, Items 1, 2, 3, and 4 run concurrently in parallel. However, all four items modify the nested git submodule `asl/` (`asl/packages/asl-sh`, `asl/packages/asl-sql`, `asl/web`, `asl/tools/engine.js`). Concurrent git write operations across subagents will trigger `asl/.git/index.lock` collisions and merge conflicts.

---

## Non-blocking Findings & Opportunities

1. **Gate 2 Subsystem Isolation**:
   Gate 2 runs an 8-command chained `&&` line. If the first test fails, the remaining 7 test outputs are suppressed. Splitting into independent sub-gates or using a unified runner improves diagnosis.
2. **Explicit Verification of Module Exports**:
   Gate 3 verifies the removal of `:exports [` and tests two web view files, but does not verify that `dag_merge_test.asl`, `prompt_tree_test.asl`, and `mvcc_bus_test.asl` successfully import and execute functions from the newly `:x`-annotated modules.

---

## Unverified
None. All claimed files, line citations, and gate commands were independently executed and verified against the working tree.
