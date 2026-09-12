# Phase 467 Plan Review

## Verdict: APPROVE

## Summary
The updated phase plan at `.plans/phase-467/PLAN.md` satisfies all architectural, falsifiability, and task decomposition requirements under ADR-0081 and `.asl/mem/tasks/Phase467ToolReliabilityAndScenarioCoverage.asn`. All prior blockers have been resolved:
1. **Item Decomposition**: Exactly 6 distinct work items map 1:1 to Task46701 through Task46706.
2. **Content Search Gate (Item 2)**: Gate asserts both CLI line coordinate and text span (`[0-9]+:.*int main`) and RPC `:line` structural attribute, ensuring filename find fallback fails.
3. **Engine Process Model Gate (Item 5)**: Gate tests substantive required section keys (`:session-model`, `:process-lifetime`, `:root-determination`) in `docs/ENGINE_PROCESS_MODEL.md`.
4. **Process Output Truncation (Item 2)**: Covered in Item 2 with `asl/packages/asl-sh/src` explicitly in `:owns` and `spool-truncate` via `RingBuffer` and `DiskSpool`.
5. **Complete Ownership Sets**: Complete `:owns` sets include all three binary parity targets (`bin/asl`, `asl/bin/asl`, `asl/asl`) for every item modifying `asl/tools/asl.c`.
6. **Separation of Duties**: Implementer owns only production code and docs. All acceptance grader fixtures (`tests/acceptance/d81/Task4670*.asl`, `SuperviseGate.sh`) are held-out under `independentVerifier` in `verificationOwns`.
7. **Standards Compliance**: Zero comments (C1), zero emojis (C2), strict ADR-0081 conformance.

---

## Blockers
0 blockers. All 4 previous blockers have been completely resolved.

---

## Baseline Falsification Verification

All gates and acceptance fixtures were executed against the clean repository baseline and verified to fail with genuine semantic failure receipts:

### Item Gates
- **Item 1 Gate** (`./bin/asl inventory`): Exit code 1 -> `Error: unrecognized subcommand 'inventory'`
- **Item 2 Gate** (`./bin/asl grep "int main" asl/tools/asl.c | grep -E -q "(4940|6246|[0-9]+:.*int main)" && ./bin/asl rpc '(:batch (:grep "int main" :file "asl/tools/asl.c"))' | grep -q ':line'`): Exit code 1 -> `Error: unrecognized subcommand 'grep'` (baseline RPC returns `:op "find"` without `:line`)
- **Item 3 Gate** (`./bin/asl callers make-note && ./bin/asl impact make-note`): Exit code 1 -> `Error: unrecognized subcommand 'callers'`
- **Item 4 Gate** (`./bin/asl test --strict-falsify tests/probes/tool_scenarios_test.asl`): Exit code 1 -> `Error: test file not found: tests/probes/tool_scenarios_test.asl`
- **Item 5 Gate** (`grep -q ':session-model' docs/ENGINE_PROCESS_MODEL.md && grep -q ':process-lifetime' docs/ENGINE_PROCESS_MODEL.md && grep -q ':root-determination' docs/ENGINE_PROCESS_MODEL.md`): Exit code 2 -> `grep: docs/ENGINE_PROCESS_MODEL.md: No such file or directory`
- **Item 6 Gate** (`./bin/asl rpc '(:batch (:out "test.xyz"))' | grep -q ':ERR_UNSUPPORTED_LANGUAGE' && ./bin/asl test --strict-falsify tests/probes/language_matrix_test.asl`): Exit code 1 -> baseline returns `:ERR_FILE_NOT_FOUND` instead of language refusal, and test file is absent

### Supervisor Acceptance Fixtures (`tests/acceptance/d81/SuperviseGate.sh`)
- `Task46701`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: asl.c must implement run_cmd_inventory`
- `Task46702`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: tests/probes/tool_scenarios_test.asl must exist and be readable`
- `Task46703`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: asl.c must sever alias between grep and find`
- `Task46704`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: asl.c must implement run_cmd_callers`
- `Task46705`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: docs/ENGINE_PROCESS_MODEL.md must exist and be readable`
- `Task46706`: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: capabilities.asn must declare :supportedLanguages per tool`

---

## Non-blocking Recommendations

1. **Sequential Execution Flow**:
   - The plan executes linearly: Item 1 (Task46701: inventory) -> Item 2 (Task46703: grep & process bounding) -> Item 3 (Task46704: callers & impact) -> Item 4 (Task46702: scenario matrix) -> Item 5 (Task46705: process model) -> Item 6 (Task46706: language matrix).
   - This linear order allows Item 4's scenario matrix to run against implemented tools without premature failure.
2. **Item 1 Gate Substantive Assertion**:
   - In implementation, verify `./bin/asl inventory | grep -q 'works\|partial\|lies\|absent'` in addition to exit code 0 to ensure non-empty output.
3. **Triple Binary Parity Recompilation**:
   - Run `scripts/build_and_install.sh` after touching `asl/tools/asl.c` to guarantee identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.

---

## Unverified
None. All cited symbols, files, lines (`asl/tools/asl.c` at 841, 873, 1513, 5836, 5875, 6246, 6473), gates, and acceptance fixtures were directly inspected and verified against the repository baseline.
