# Implementation Review: Phase 474 (One Projection, Many Surfaces)

## Review Metadata
- **Phase**: Phase474OneProjectionManySurfaces
- **Reviewer**: Independent Acceptance Supervisor
- **Date**: 2026-09-12
- **Status**: VERIFIED & SETTLED

## Task-by-Task Acceptance Verification

### 1. Task47401: One projection: content, shape, destination
- **Status**: PASSED
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47401`
- **Executed Assertions**: 15 assertions cleanly evaluated.
- **Evidence**:
  - `asl/tools/asl.c` implements `run_cmd_project`, `project_content`, `filter_rules_by_tier`.
  - Supports `--content` (rules tiers, capabilities, lexicon), `--shape` (delimited, fenced, record), `--dest`, and `--check`.
  - Binary parity verified across `bin/asl`, `asl/bin/asl`, and `asl/asl`.

### 2. Task47402: Skills draw from the projection, and there is one skill tree
- **Status**: PASSED
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47402`
- **Executed Assertions**: 37 assertions cleanly evaluated.
- **Evidence**:
  - Unified root `.agents/skills` and `asl/.agents/skills` to exactly 24 skills each.
  - Resolved missing skills (`steps`, `steps-implement`, `steps-plan`, `steps-review`, `asl-adaptive-dag`, `asl-skills-installer`).
  - Skills declare projections by reference (`projection: "rules:full"` in frontmatter and `:projection "rules:full"` in `skill.asn`).

### 3. Task47403: What is the launcher's own is declared as its own
- **Status**: PASSED
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47403`
- **Executed Assertions**: 16 assertions cleanly evaluated.
- **Evidence**:
  - Declared `clientLauncher` contract in `asl/grammar/protocol-conformance.asn` with client target specs (`agy`, `claude`, `codex`, `addie`, `eddie`), permission tiers, channels, and named invariants.
  - Implemented `ClientTargetSpec`, `g_client_specs`, `lookup_client_spec`, `enforce_claude_system_prompt_append`, and `enforce_claude_strip_dangerous_permissions` in `asl/tools/asl.c`.
  - Explicit channel validation: unknown clients or clients without channels fail cleanly.

### 4. Task47404: Gate 7 checks currency, not population
- **Status**: PASSED
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task47404`
- **Executed Assertions**: 12 assertions cleanly evaluated.
- **Evidence**:
  - Implemented `verify_skill_projection_currency` and updated `run_gate_7_skills` in `asl/tools/asl.c`.
  - Audits both `.agents/skills` and `asl/.agents/skills`, verifying tree counts and reporting discrepancies.
  - Verifies that skills with declared projections match generated projections from `rules.asn`.
  - Gate 7 outputs: `Audited 24/24 modular skills across canonical trees. Currency against source verified.`

## Full Acceptance Run Receipt
- Command: `for task in Task47401 Task47402 Task47403 Task47404; do sh tests/acceptance/d81/SuperviseGate.sh "$task" || exit $?; done`
- Exit Code: 0 (All 4 gates passed with 100% evaluated assertions, 7 pure ASL gates clean, and 5-dimension D52 consistency audit clean).
- Rules SSOT: `scripts/install.sh --check-rules` passed cleanly with all surfaces identical.
