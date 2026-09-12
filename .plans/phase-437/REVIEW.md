# Phase 437 Plan Review: Client Launch and Codex Efficiency

## Verdict: APPROVE

- **Reviewer**: `steps-plan-reviewer` (Independent Clean-Context Audit)
- **Date**: 2026-09-12
- **Target Plan**: [.plans/phase-437/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-437/PLAN.md)
- **Canonical Specification**: [.asl/mem/tasks/Phase437ClientLaunchAndCodexEfficiency.asn](file:///Users/purplelephant/projects/asex/.asl/mem/tasks/Phase437ClientLaunchAndCodexEfficiency.asn)
- **Governing ADR**: [Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn](file:///Users/purplelephant/projects/asex/.asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn)

---

## Executive Summary
The rewritten Phase 437 plan at [.plans/phase-437/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-437/PLAN.md) satisfies all architectural, falsifiability, governance, and decomposition requirements under ADR-0081 and `.asl/mem/tasks/Phase437ClientLaunchAndCodexEfficiency.asn`:
1. All four prior blockers from the initial review have been completely resolved.
2. The plan maps 1:1 to seven sequential, topologically ordered work items matching Task43701 through Task43707.
3. Every item provides a genuine, executable failing gate command with an intended semantic baseline failure (exit code 1).
4. Dual gate coverage is verified: each item carries a physical author-executable gate in `PLAN.md` and binds to an independent supervisor acceptance fixture (`tests/acceptance/d81/Task4370X.asl`) executed via `sh tests/acceptance/d81/SuperviseGate.sh Task4370X`. All seven fixtures fail on baseline with semantic assertion errors.
5. Ownership (`:owns`) is exhaustive and accurate: all source files, package manifests (`harness/manifest.asn`, `harness/grammar.asn`), prospective task specifications, and required engine binaries (`bin/asl`, `asl/bin/asl`, `asl/asl`) are explicitly declared whenever `asl/tools/asl.c` is modified.
6. Mechanical separation of duties is strictly enforced: implementer `:owns` contains only production code and documentation; grader acceptance fixtures are assigned strictly to `independentVerifier` under `verificationOwns` per rule `hiddenTests` ([asl/grammar/rules.asn:46-48](file:///Users/purplelephant/projects/asex/asl/grammar/rules.asn#L46-L48)).
7. Zero comments (C1), zero emojis (C2), and strict ADR-0081 conformance are verified across the entire document.

---

## Blocker Resolution Verification

### 1. Item Decomposition (Blocker 1 - Resolved)
- **Requirement**: Exactly 7 distinct work items matching Task43701 through Task43707.
- **Physical Verification**:
  - Item 1 (lines 59-124): Settle CLI Integration Boundary & Retire Unused MCP Projections (`Task43701`)
  - Item 2 (lines 127-196): Render Minimal Stable Claude Launch Projection (`Task43702`)
  - Item 3 (lines 198-263): Render Truthful Codex and Antigravity Client Projections (`Task43703`)
  - Item 4 (lines 265-334): Deduplicate Effective Injection with One Home per Block (`Task43704`)
  - Item 5 (lines 336-417): Validate Capability References and Future-Operation Fallbacks (`Task43705`)
  - Item 6 (lines 419-488): Settle Contradictory Directives without Performance Mythology (`Task43706`)
  - Item 7 (lines 490-570): Settle All Reviewed Rules in One Canonical Generated Source (`Task43707`)
  - Dependency order is strictly sequential: `Item 1 -> Item 2 -> Item 3 -> Item 4 -> Item 5 -> Item 6 -> Item 7`, satisfying `rule:oneStep`.

### 2. Falsifiable Baseline Failure Gates (Blocker 2 - Resolved)
- **Requirement**: Every item has a genuine, executable failing gate command with an intended semantic baseline failure.
- **Physical Verification**:
  All seven author-executable gates and all seven independent supervisor gates were executed against the current baseline and verified to fail with exit code 1:
  - **Item 1**:
    - *Author Gate*: Python RPC batch checking symbol table definition count for `McpServerConfig`, `generate-claude-mcp-config`, and `format-antigravity-mcp-payload`.
      - Result: Exit code 1 -> `Error: retired MCP symbols still exported in symbol table (3 definitions found)`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43701`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: harness/src/mcp_bridge.asl must be removed`.
  - **Item 2**:
    - *Author Gate*: Checks absence of duplicate toolbelt block in `AGENTS.md`, validates `system-guided` mode in `asl launch claude --dry-run`, and verifies token count <= 2500.
      - Result: Exit code 1 -> `Error: AGENTS.md still contains duplicate <!-- ASL_TOOLBELT_START --> block`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43702`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: AGENTS.md must not contain legacy duplicate ASL_TOOLBELT_START block`.
  - **Item 3**:
    - *Author Gate*: Verifies Antigravity retains `invoke_subagent` and `--dangerously-skip-permissions` while Codex projection removes mandatory nonexistent subagent commands.
      - Result: Exit code 1 -> `Error: Codex projection untruthfully mandates host operations it cannot execute (invoke_subagent/Agent)`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43703`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: AGENTS.md must not contain legacy duplicate ORCHESTRATOR_START block`.
  - **Item 4**:
    - *Author Gate*: Verifies all four legacy duplicate rule markers (`ASL_TOOLBELT_START`, `PARALLEL_START`, `GROUND_TRUTH_START`, `GIT_START`) are pruned from `AGENTS.md` and session word count <= 5000.
      - Result: Exit code 1 -> `Error: duplicate legacy rule blocks found in AGENTS.md: ['<!-- ASL_TOOLBELT_START -->', '<!-- PARALLEL_START -->', '<!-- GROUND_TRUTH_START -->', '<!-- GIT_START -->']`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43704`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: AGENTS.md must not contain legacy duplicate PARALLEL_START block`.
  - **Item 5**:
    - *Author Gate*: Verifies prospective phase specs declare `:requiresIndependentBaseline`, `./bin/asl doctor` passes, and `./bin/asl audit gates` passes.
      - Result: Exit code 1 -> `Error: prospective task specs missing :requiresIndependentBaseline tag: ['.asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn']`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43705`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: TOKEN_CONVENTIONS.md must not reference absent command asl tokens --camel`.
  - **Item 6**:
    - *Author Gate*: Verifies contradictory blanket host-tool bans (`:forbid [:view_file ...]`) are removed from `AGENTS.md` and canonical `tools` rule is preserved in `asl/grammar/rules.asn`.
      - Result: Exit code 1 -> `Error: AGENTS.md contains contradictory host-tools ban (:forbid [:view_file ...]) without capability fallbacks`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43706`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: AGENTS.md must not contain contradictory blanket :forbid on host tools`.
  - **Item 7**:
    - *Author Gate*: Runs `bash scripts/install.sh --check-rules`, verifies absence of superseded legacy blocks in `AGENTS.md`, and runs `./bin/asl audit consistency`.
      - Result: Exit code 1 -> `Error: superseded normative duplicates present in AGENTS.md: ['<!-- ASL_TOOLBELT_START -->', '<!-- ORCHESTRATOR_START -->', '<!-- GROUND_TRUTH_START -->', '<!-- GIT_START -->', '<!-- PARALLEL_START -->']`.
    - *Supervisor Gate* (`sh tests/acceptance/d81/SuperviseGate.sh Task43707`):
      - Result: Exit code 1 -> `[ASL_ASSERTION_FAILURE]: AGENTS.md must not retain legacy unmanaged ASL_TOOLBELT_START block`.

### 3. File Ownership Completeness (Blocker 3 - Resolved)
- **Requirement**: Complete `:owns` sets including binary targets (`bin/asl`, `asl/bin/asl`, `asl/asl`) when `asl/tools/asl.c` is modified, manifest and grammar files.
- **Physical Verification**:
  - Item 1 explicitly owns `harness/grammar.asn` and `harness/manifest.asn` alongside retiring sources.
  - Items 2, 3, 4, 5, 6, and 7 modify `asl/tools/asl.c`, and every one of them explicitly declares `["asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl"]` under `:owns`.
  - Item 5 includes all 5 prospective task specifications (`Phase415`, `Phase436`, `Phase437`, `Phase438`, `Phase439`, `Phase440`, `Phase441`).
  - Item 7 includes all rendered skill surfaces (`.agents/skills/asl-toolbelt`, `asl/.agents/skills/asl-toolbelt`, `scripts/install.sh`, `AGENTS.md`, `asl/grammar/rules.asn`).

### 4. Separation of Duties (Blocker 4 - Resolved)
- **Requirement**: Implementer owns only production code; grader-owned fixtures belong strictly to `independentVerifier`.
- **Physical Verification**:
  - Acceptance fixtures `tests/acceptance/d81/Task43701.asl` through `Task43707.asl` and runner script `SuperviseGate.sh` do not appear anywhere in implementer `:owns` or `:action-dag`.
  - In all seven items, acceptance fixtures are placed strictly under `- **Verification ownership (`verificationOwns`)**:` with the explicit annotation `owned strictly by independentVerifier per Invariant hiddenTests`.
  - Section `## Out of Scope` (line 590) explicitly states: `Authoring grader acceptance fixtures tests/acceptance/d81/Task43701.asl through Task43707.asl is reserved strictly for independentVerifier under Invariant hiddenTests.`

### 5. Invariant Conformance (C1, C2, ADR-0081)
- **Comments (C1)**: Zero comments in plan code blocks; zero unmanaged comments. All citations of comment markers (`<!-- ASL_TOOLBELT_START -->`) are literal target strings.
- **Emojis (C2)**: Zero Unicode emoji characters across the entire document.
- **ADR-0081 Conformance**: Strictly aligns with ADR-0081 Drivers 1, 2, 6, 7, 8, 9, Paradigm Revisions 5, 8, 9, and Settled Choices `ruleSource` and `nativeArtifact`.

---

## Blockers
**None.** All prior blockers have been resolved and physically verified.

---

## Non-blocking (Suggestions & Recommendations)
1. **Binary Parity Recompilation Routine**:
   When implementing Items 2, 3, 6, and 7, recompile `bin/asl` (`cc -O2 -Wall asl/tools/asl.c -o bin/asl`) and copy immediately to `asl/bin/asl` and `asl/asl`. Running `./bin/asl audit gates` verifies that Gate 4 SHA-256 binary parity holds before proceeding to the next item.
2. **Deterministic Token Measurement**:
   In Items 2 and 4, the author gates use whitespace word estimation as a proxy for token counts. During supervisor verification, the pinned tokenizer in `SuperviseGate.sh` measures exact token usage. Ensure descriptions and headers remain concise to comfortably clear the 2500 launch and 5000 session limits.
3. **Automated Surface Rendering Check**:
   In Item 7, execute `bash scripts/install.sh --render-rules` prior to running `bash scripts/install.sh --check-rules` to ensure all 7 export surfaces are synchronized from `asl/grammar/rules.asn` without manual editing.

---

## Unverified
**None.** All 7 work items, author gate commands, supervisor acceptance fixtures, baseline exit codes, symbol references, and file:line citations were physically opened, executed, and verified.
