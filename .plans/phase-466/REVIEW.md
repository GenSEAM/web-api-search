# Phase 466: Plan Review Report

- **Target Plan**: `.plans/phase-466/PLAN.md`
- **Reviewed Against**:
  - `.asl/mem/tasks/Phase466ParadigmByForceAndTier.asn` (Task46601 to Task46605)
  - `docs/D81_PROGRAMME.md` (ADR-0081, Wave 113)
  - `asl/grammar/rules.asn:1-63`
  - `.asl/mem/principles.asn:1-171`
  - `TOKEN_CONVENTIONS.md:1-168`
  - `scripts/install.sh:8-106,307-391`
  - `asl/grammar/capabilities.asn:1-62`
  - Grader acceptance fixtures: `tests/acceptance/d81/Task46601.asl` through `Task46605.asl`
- **Reviewer Role**: `steps-plan-reviewer` (clean context)
- **Review Date**: 2026-09-12

---

## Verdict

**APPROVE-WITH-AMENDMENTS**

The plan is well-grounded, architecturally sound, and directly addresses the core objective of ADR-0081 (separating invariants, orientations, affordances, and heuristics, establishing deterministic context tiers with strict prefix containment, and providing empirical telemetry). Zero blocking defects were identified. Three non-blocking amendments are documented below for implementer alignment.

---

## Evaluation Against Review Criteria

### 1. Work Items Coverage vs `.asl/mem/tasks/Phase466ParadigmByForceAndTier.asn`
- **Task46601 (Item 1)**: Fully covered. Correctly maps four forces (`:invariant`, `:orientation`, `:affordance`, `:heuristic`), enforces `:gate` on invariants and `:defeat` on heuristics, and bounds invariants to $\le 7$.
- **Task46602 (Item 2)**: Fully covered. Correctly maps six context tiers (`essential`, `hot`, `tier 1` through `tier 5`), enforces strict byte-level prefix containment, and integrates deterministic rendering via `scripts/install.sh --tier`.
- **Task46603 (Item 3)**: Fully covered. Introduces three missing orientations (`stake`, `adaptive`, `problemSolving`) sized for Tier 1 without compliance tests.
- **Task46604 (Item 4)**: Fully covered. Implements modular domain packs (`design`, `development`, `research`, `audit`), links to situations in `capabilities.asn`, and eliminates concept duplication.
- **Task46605 (Item 5)**: Fully covered. Measures tier performance against invariant violations and records empirical findings in `.asl/mem/telemetry/TierEvaluation20260912.asn`.

### 2. Falsifiable Gate Integrity
All five acceptance gates were independently executed against the repository baseline. Each failed as documented with exit code `1`:
- **Task46601**: `./bin/asl test --strict-falsify tests/acceptance/d81/Task46601.asl`
  - *Observed Baseline*: Exit `1`, `[ASL_ASSERTION_FAILURE]: rules.asn must declare invariant force` (Exact match).
- **Task46602**: `./bin/asl test --strict-falsify tests/acceptance/d81/Task46602.asl`
  - *Observed Baseline*: Exit `1`, `[ASL_ASSERTION_FAILURE]: scripts/install.sh must support tier rendering` (Exact match).
- **Task46603**: `./bin/asl test --strict-falsify tests/acceptance/d81/Task46603.asl`
  - *Observed Baseline*: Exit `1`, `[ASL_ASSERTION_FAILURE]: rules.asn must declare stake orientation` (Exact match).
- **Task46604**: `./bin/asl test --strict-falsify tests/acceptance/d81/Task46604.asl`
  - *Observed Baseline*: Exit `1`, `[ASL_ASSERTION_FAILURE]: rules.asn must declare domain packs` (Exact match).
- **Task46605**: `./bin/asl test --strict-falsify tests/acceptance/d81/Task46605.asl`
  - *Observed Baseline*: Exit `1`, `[ASL_ASSERTION_FAILURE]: TierEvaluation20260912.asn must exist` (Exact match).
- **Supervisor Harness**: `sh tests/acceptance/d81/SuperviseGate.sh Task46601` fails at step `[1/3]` on baseline, confirming end-to-end non-vacuity.

### 3. Separation of Duties (`hiddenTests` Invariant)
- All acceptance test fixtures (`tests/acceptance/d81/Task46601.asl` through `Task46605.asl`) and `SuperviseGate.sh` are strictly excluded from implementer `:owns`.
- Each work item explicitly places its test fixture under `:verificationOwns` as read-only by the implementer.
- Section "Out of Scope" explicitly forbids modifying files in `tests/acceptance/d81/`.

### 4. Technical Invariants & Gate Suite Continuity
- **C1 (Zero Comments)**: Enforced across all ASN/ASL modifications; verified that `./bin/asl lint` and `./bin/asl check` pass on current `rules.asn` and `principles.asn`.
- **C2 (Zero Emojis)**: Machine ASN emoji check verified via Gate 6.
- **Rules SSOT**: Verified that `bash scripts/install.sh --check-rules` is green across all 7 downstream surfaces on baseline (`agents-md`, `skill-md`, `skill-md-asl`, `install-template`, `install-directive`, and both `skill.asn` files). The plan strictly prohibits manual edits to downstream surfaces and mandates `--render-rules` followed by `--check-rules`.
- **Continuity**: `./bin/asl audit consistency` passes 100% (all 5 dimensions reconciled). `./bin/asl audit gates --skip 5` passes all structural gates cleanly.

### 5. Risk Mitigations
- **Strict Prefix Containment**: Explicitly addressed by ordering rules monotonically so that higher tiers append to the lower tier byte stream, preserving KV-cache across sessions.
- **Rule Drift Prevention**: Automated via `scripts/install.sh --render-rules` and Gate 7 / `--check-rules`.
- **Ground Truth Telemetry**: Telemetry in Item 5 relies on physically running gates rather than estimating violation counts.

---

## Blockers

**None.** (0 blocking defects)

---

## Non-blocking (Amendments & Observations)

1. **Task46605 Dependency Alignment (`Task46304` vs `Task46604`)**:
   - *Observation*: In `.asl/mem/tasks/Phase466ParadigmByForceAndTier.asn:191`, Task46605 declares `:dependsOn ["Task46602" "Task46304"]`. In `PLAN.md:320`, Work Item 5 lists `- **Prerequisites (depends_on)**: ["Task46602", "Task46604"]`.
   - *Context*: `Task46304` belongs to Wave 110 (Phase 463) which is currently in `:state :planned`. The task fixture `Task46605.asl` only verifies the existence and schema of `.asl/mem/telemetry/TierEvaluation20260912.asn`.
   - *Amendment*: The implementer should note this distinction: within Phase 466, Task46605 can evaluate the renderable tiers and domain packs from Task46602 and Task46604, while noting in the telemetry artifact whether external Wave 110 emission benchmarks were used or repository baseline test suites. If necessary, reconcile the task ledger during completion.

2. **Invariant Budget Exactness ($\le 7$ Rules)**:
   - *Observation*: Line 52 of `PLAN.md` states: `"7 Invariants: semantics, gates, grading, concepts, foreign, oneStep, hiddenTests (or ssot)"`.
   - *Amendment*: The implementer must ensure exactly 7 invariants are marked `:force :invariant`, not 8. If `ssot` is made an invariant, one of the others must not be; alternatively, keep `ssot` as an affordance or heuristic with defeat condition. This keeps the essential core within the measured 617-token budget.

3. **`skill_rules` Regex in `scripts/install.sh`**:
   - *Observation*: `scripts/install.sh:42` currently parses `:(why|not|now|bias) "`. When `:defeat` is introduced to heuristics in `rules.asn`, `skill_rules` will not capture `:defeat` text into `skill.asn` unless updated.
   - *Amendment*: In Work Item 2 (where `scripts/install.sh` is owned), update the regex in `skill_rules()` to `:(why|not|now|bias|defeat) "` so that heuristic defeat conditions are properly rendered into downstream skill registries.

4. **Proactive Suggestion (Future Phases)**:
   - *Context-Aware Tier Injection*: When Phase 441 (Attention Prosthesis) and Phase 437 (Client Launch) ship, client hooks can automatically invoke `scripts/install.sh --tier <name>` based on the active agent model capacity (e.g. SLM vs Opus).

---

## Unverified

- None. All 5 gate failure probe outputs, cited path:line ranges, SSOT check scripts, and consistency audit commands were physically verified in the clean execution environment.
