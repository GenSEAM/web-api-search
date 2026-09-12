# Phase 6 Plan Review

- **Target Plan**: `.plans/phase-6/PLAN.md`
- **Verdict**: `approve`
- **Reviewer**: `steps-plan-reviewer`
- **Review Date**: 2026-09-12

---

## Executive Summary

The Phase 6 plan (`.plans/phase-6/PLAN.md`) provides a rigorous, high-fidelity operational blueprint addressing Repository Hygiene, Lexicon Truth, and Duplication Eradication (Tasks Task45604, Task44701, Task44702, and Task45601).

Every cited path and line range was directly inspected against the live codebase:
- `asl/dist/dist`: 23 nested build artifact files confirmed on disk.
- `scripts/install.sh:1-570` vs `asl/dist/install.sh`, `asl/web/dist/install.sh`, `asl/web/public/install.sh`: byte desynchronization and stale copies confirmed.
- `voice/src/hyness_profile.asl:50-55`: mishearing `("хайнесс" "hyness")` and absence of `"ханес"` confirmed.
- `voice/tests/audio_bridge_test.asl:76-98`: assertions locking in `"hyness"` and `:alias-count 5` confirmed.
- `asl/packages/asl-codec/src/sh-transpile.asl:22-38`: redundant unexported shadow helper `(df estimate-tokens ...)` and call sites confirmed.

All five item gates were independently reproduced and confirmed to **FAIL on the current baseline** with exact output matching the plan documentation. All file ownership scopes (`owns`) are strictly disjoint. Master verification certifies monorepo health across all 7 tiers of `./bin/asl gate` and 5 dimensions of `./bin/asl audit consistency`.

---

## Blockers

**Count**: 0

No blocking defects identified. All contracts, task scopes, dependencies, and baselines are sound.

---

## Non-blocking Recommendations & Gate Hardening

1. **Item 2 Gate Schema & Anti-Mishearing Assertion**:
   - *Current Gate*: Checks for presence of string tokens `["harness", "asex", "shrody", "pcp", "edison"]` and `["хайнесс", "ханес", "асекс", "шроуди", "пцп", "эдисон"]`.
   - *Enhancement*: To prevent a conformant-but-wrong implementation that omits schema keys or re-introduces the mishearing as a target, assert that `:canonical`, `:scope`, `:why`, and `:spoken` are present in `asl/grammar/lexicon.asn`, and assert that `"hyness"` is NOT present.

2. **Item 3 Gate Test Completeness for "ханес"**:
   - *Current Gate*: Verifies `"хайнесс" "harness"` and `"ханес" "harness"` in `hyness_profile.asl`, and asserts that `audio_bridge_test.asl` verifies `"хайнесс"` resolves to `"harness"`.
   - *Enhancement*: Also verify that `audio_bridge_test.asl` explicitly tests the resolution of `"ханес"` -> `"harness"`, and that `:alias-count 6` is reflected.

3. **Item 4 Gate Call-Site Hygiene**:
   - *Current Gate*: Checks `if "(df estimate-tokens" in content:`.
   - *Enhancement*: Also check that no bare call site `"(estimate-tokens "` survives in `sh-transpile.asl`, ensuring all invocations route through canonical `(txt/estimate-tokens ...)`.

4. **Item 1 Executable Permissions**:
   - *Recommendation*: Ensure synchronization commands preserve or apply executable permissions (`chmod +x`) to `asl/dist/install.sh`, `asl/web/dist/install.sh`, and `asl/web/public/install.sh`.

---

## Unverified

None. All 5 work item gates were independently executed and reproduced on disk; all cited source ranges and test files were inspected and confirmed.
