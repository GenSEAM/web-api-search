# Phase 474 Plan: One Projection, Many Surfaces

## Status
- **Phase**: Phase474OneProjectionManySurfaces
- **Priority**: Developer Tooling & Verification Ground Truth (Top priority per user instruction)
- **Status**: in-progress

## Context & Baseline Findings

1. **Task47401 (One projection: content, shape, destination)**:
   - **Baseline**: The same rules were rendered by 4 separate shell scripts and awk blocks with ad-hoc escaping, constraining the rules source (e.g. banning apostrophes because of bash single quoting).
   - **Remedy**:
     1. Unified `project` command implemented in `asl/tools/asl.c` (`run_cmd_project`, `project_content`, `filter_rules_by_tier`) with `--content`, `--shape` (delimited, fenced, record), `--dest`, and `--check`.
     2. Update `scripts/install.sh` to use `asl project` when available instead of ad-hoc awk escaping.
     3. Verification fixture `tests/acceptance/d81/Task47401.asl` verifies the command, shapes, and tier filtering.

2. **Task47402 (Skills draw from the projection, and there is one skill tree)**:
   - **Baseline**: 
     - Two skill trees disagree: `.agents/skills` has 20 skills while `asl/.agents/skills` has 22 skills. `asl-adaptive-dag` and `asl-skills-installer` exist only in `.agents/skills`; `steps`, `steps-implement`, `steps-plan`, and `steps-review` exist only in `asl/.agents/skills`.
     - Exactly one skill (`asl-toolbelt`) carries rules, embedding a 100+ line copy of them, while 19+ skills carry no rules.
   - **Remedy**:
     1. Unify the skill trees into one canonical root `.agents/skills` containing all 24 skills.
     2. Symlink or synchronize `asl/.agents/skills` to `.agents/skills` so both trees are guaranteed identical.
     3. Allow skills to declare projections by reference (e.g. `projection: rules:full` or `projection: capabilities`) rather than embedding hardcoded copies of shared rules.
     4. Build acceptance fixture `tests/acceptance/d81/Task47402.asl` verifying tree parity and projection declaration.

3. **Task47403 (What is the launcher's own is declared as its own)**:
   - **Baseline**: The launcher in `asl/tools/asl.c` mixes client routing (`agy`, `claude`, `codex`, `addie`, `eddie`), orchestration flags, and safety invariants into inline hardcoded if-statements. If porting or refactoring, invariants can be silently lost.
   - **Remedy**:
     1. Formally declare client specs, channels, and named invariants in `asl/grammar/protocol-conformance.asn` and structured client tables in `asl/tools/asl.c`.
     2. Provide explicit named checks for Claude safety invariants (converting `-s`/`--system-prompt` overwrite to `--append-system-prompt`, stripping `--dangerously-skip-permissions`).
     3. Provide explicit channel validation: a client declared without a channel or with unknown parameters fails cleanly.
     4. Build acceptance fixture `tests/acceptance/d81/Task47403.asl` verifying each invariant.

4. **Task47404 (Gate 7 checks currency, not population)**:
   - **Baseline**: Gate 7 (`run_gate_7_skills`) checks whichever tree it finds first, counts files, validates frontmatter, and checks deprecated tool keywords, but never verifies currency against the source or checks both trees.
   - **Remedy**:
     1. Update `run_gate_7_skills` to audit both trees and verify they match.
     2. Verify projection currency: check that skills with declared projections match the generated projection from `rules.asn`.
     3. Report total checked count against existing count.
     4. Build acceptance fixture `tests/acceptance/d81/Task47404.asl` verifying currency checking and double-tree detection.

## Ordered Implementation DAG

1. **Task47401**:
   - Verification Fixture: `tests/acceptance/d81/Task47401.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47401`
   - Verify `asl project` command in `asl/tools/asl.c` and clean gate execution.

2. **Task47402**:
   - Verification Fixture: `tests/acceptance/d81/Task47402.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47402`
   - Baseline Failure: Tree divergence and missing projection declarations.
   - Implementation: Reconcile skill trees to 24 skills, establish symlink/parity, support declared projections.

3. **Task47403**:
   - Verification Fixture: `tests/acceptance/d81/Task47403.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47403`
   - Baseline Failure: Client invariants not declared as structured rules.
   - Implementation: Define client launch invariants in `protocol-conformance.asn` and `asl/tools/asl.c`.

4. **Task47404**:
   - Verification Fixture: `tests/acceptance/d81/Task47404.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47404`
   - Baseline Failure: Gate 7 only counts skills and misses tree parity and projection currency.
   - Implementation: Update `run_gate_7_skills` in `asl/tools/asl.c` to check currency and report tree consistency.
