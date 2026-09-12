# Plan Review: Phase 7 (Repository Hygiene, Configuration Truth & Full Corpus Gate Scope)

## Verdict
**APPROVE**

The revised execution plan in `.plans/phase-7/PLAN.md` has been reviewed in a clean context against repository state, the steps protocol, and Task47001/Task47302/Task47303/Task47304 requirements. All four previous blockers have been resolved:
1. Item 3 now targets the un-recompiled `./asl/bin/asl`, correctly failing at baseline (audits only 5 suites vs required 312+).
2. Item 5 includes all necessary imports (`re`, `subprocess`, `hashlib`, `yaml`, `os`, `sys`) and executes without runtime errors.
3. Item 1 strictly verifies manifest presence (`package.json`) in declared workspace packages (`['asl', 'asl/web']`) and checks both configuration files (`.asl.config.asn` and `asl/.asl.config.asn`).
4. Item 2 asserts presence of phonetic variant `"ханес"` as well as `"harness"`, and absence of forbidden `;;` comments.

All 5 item gates were independently executed against the live working tree and confirmed to fail on disk as expected. Disjoint file ownership across independent items is enforced.

---

## Blockers
None.

---

## Non-blocking Suggestions

1. **Explicit Positive Assertion for Core Package Replacements (Item 1)**:
   While the gate asserts that nonexistent paths (`"asl/asl-compiler"` and `"asl/asl-parser"`) are absent from `.asl.config.asn` and `asl/.asl.config.asn`, the implementer should also ensure that the correct target paths (`"asl/packages/asl-compiler"` and `"asl/packages/asl-parser"`) are actively present.
2. **Build and Install Script Alignment (Item 4)**:
   `scripts/build_and_install.sh:26-30` compiles `asl/tools/asl.c` and installs to `asl/asl`, `bin/asl`, and `asl/bin/asl`. Running this build script or replicating its exact copy sequence ensures atomic synchronization across all three binary targets.

---

## Unverified
None. All paths, citations, line numbers, and gate commands were verified against live disk state.

