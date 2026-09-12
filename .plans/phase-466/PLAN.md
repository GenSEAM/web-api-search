# Phase 466: Paradigm by Force and Tier (ADR-0081)

## Phase Summary & Context
- **Phase ID**: `Phase466ParadigmByForceAndTier` (Phase 466)
- **Programme & Decision**: `ADR-0081` (`d81`), Wave 113
- **Roadmap Coordinates**: Recorded in `.asl/mem/tasks/Phase466ParadigmByForceAndTier.asn` and `docs/D81_PROGRAMME.md`
- **Measured Baseline**:
  Under `cl100k`, the active rendered agent surface is 5,913 tokens: 2,264 tokens in 19 rules and 3,649 tokens (62%) in paradigm prose. Every agent currently loads this identical monolithic surface regardless of model capacity or task scope.
  Classifying the 19 rules by actual grammatical force reveals:
  - 7 Invariants (~617 tokens)
  - 4 Orientations (~465 tokens)
  - 2 Affordances (~289 tokens)
  - 6 Heuristics (~449 tokens)
  The essential core is approximately one-tenth of what every agent loads today. Because every item is currently labeled a "rule", defeasible heuristics carry identical perceived authority to invalidating invariants.
- **Phase Purpose**:
  Separate what binds (invariants) from what orients (orientations) from what can actually be done (affordances) from what merely usually works (heuristics).
  Establish 4 deterministic context tiers (`essential`, `hot`, `affordance`, `pack` / Tier 0 to 5) with strict prefix containment, rendered from a single source of truth (`asl/grammar/rules.asn`) via `scripts/install.sh`.
  Close epistemic voids by introducing missing orientations (`stake`, `adaptive`, `problemSolving`).
  Partition domain-specific instructions into modular domain packs (`design`, `development`, `research`, `audit`).
  Empirically measure whether smaller tiers preserve invariant compliance while reducing token spend, recording physical gate telemetry in `.asl/mem/telemetry/TierEvaluation20260912.asn`.
- **Grader Ownership Boundary**:
  All acceptance test fixtures (`tests/acceptance/d81/Task46601.asl` through `Task46605.asl`) and verification harness `tests/acceptance/d81/SuperviseGate.sh` are strictly grader-owned (`verificationRole "independentVerifier"`). Implementers must not modify grader acceptance fixtures (`hiddenTests` invariant).

---

## Ordered Work Items

### Work Item 1: Four Forces Classification & Grammatical Authority (Task46601)
- **Path**: `asl/grammar/rules.asn:1-63`, `.asl/mem/principles.asn:1-171`, `TOKEN_CONVENTIONS.md:1-168`
- **Identity**:
  - `:id`: `"item-1"` / `"Task46601"`
  - `:title`: `"Four forces, four words: invariant, orientation, affordance, heuristic"`
  - `:kind`: `:protocol`
  - `:lane`: `"paradigm"`
  - `:priority`: `:critical`
  - `:ownerRole`: `"implementer"`
- **Motivation & Purpose**:
  - Today, every item in `asl/grammar/rules.asn` is designated with `:rule`, conflating defeasible preferences (such as commit format or identifier style) with non-negotiable correctness conditions (such as independent grading or zero foreign code).
  - An autonomous agent cannot determine what may be dropped under context pressure without explicit force classification.
  - The Four Forces establish unambiguous grammatical authority:
    1. **Invariant** (`:force :invariant`): Defines what makes work invalid. Bounded to $\le 7$ rules. Every invariant MUST declare a falsifiable gate (`:gate`). Never dropped under context pressure.
    2. **Orientation** (`:force :orientation`): Explains how to read a situation and evaluate posture. MUST NOT carry a compliance test (which would turn it into an invariant).
    3. **Affordance** (`:force :affordance`): States what can actually be done and which tools are operational for the situation.
    4. **Heuristic** (`:force :heuristic`): Defines practices that usually work. MUST declare its explicit defeat condition (`:defeat`, `:unless`, or `:whenDefeated`), transforming a rigid rule into an adaptable instrument.
- **Specific Files Owned (`:owns`)**:
  `["asl/grammar/rules.asn", ".asl/mem/principles.asn", "TOKEN_CONVENTIONS.md"]`
- **Grader Verification Ownership (`:verificationOwns`)**:
  `["tests/acceptance/d81/Task46601.asl"]` (Read-only by implementer)
- **Concrete Action Steps**:
  1. In `asl/grammar/rules.asn`:
     - Add `:force` attribute to all rule items:
       - 7 Invariants: `semantics`, `gates`, `grading`, `concepts`, `foreign`, `oneStep`, `hiddenTests` (or `ssot`). Each MUST declare `:gate` pointing to an executable check.
       - 4 Orientations: `output`, `anchor`, `edge`, and stance orientations. Ensure zero compliance tests or assertions are attached.
       - 2 Affordances: `tools`, `capabilities` (and `note`).
       - 6 Heuristics: `names`, `git`, `parallel`, `budget`, `bounded`, `context`. Each MUST declare `:defeat` (e.g. `:defeat "domain aliases or external foreign interfaces require exact naming"`).
  2. In `TOKEN_CONVENTIONS.md`:
     - Document the Four Forces schema, explaining the syntax contracts (`:force :invariant`, `:force :orientation`, `:force :affordance`, `:force :heuristic`), the requirement for `:gate` on invariants, and `:defeat` on heuristics.
  3. In `.asl/mem/principles.asn`:
     - Cross-reference the operative forces with normative and empirical principles.
  4. Synchronize all rendered downstream surfaces:
     ```bash
     bash scripts/install.sh --render-rules
     bash scripts/install.sh --check-rules
     ```
  5. Validate delimiter balance and anti-pattern constraints:
     ```bash
     ./bin/asl check asl/grammar/rules.asn
     ./bin/asl lint asl/grammar/rules.asn
     ```
- **Falsifiable Verification Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/acceptance/d81/Task46601.asl
  ```
- **Current Baseline Probe Failure Confirmation**:
  ```text
  [ASL_ASSERTION_FAILURE]: rules.asn must declare invariant force
      ✓ tests/acceptance/d81/Task46601.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ tests/acceptance/d81/Task46601.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code: 1; fails on baseline because rules.asn does not yet declare :force :invariant)*
- **Prerequisites (`depends_on`)**: `[]`
- **What breaks if run before prerequisite**:
  Foundational item for Phase 466. If skipped or executed out of order, downstream tier rendering (Task46602) and orientation expansion (Task46603) lack the force taxonomy to partition instructions.

---

### Work Item 2: Deterministic Context Tiers & Strict Prefix Containment (Task46602)
- **Path**: `asl/grammar/rules.asn`, `scripts/install.sh:8-106,307-391`, `AGENTS.md:1-65`
- **Identity**:
  - `:id`: `"item-2"` / `"Task46602"`
  - `:title`: `"Tiers that a context budget can actually spend"`
  - `:kind`: `:protocol`
  - `:lane`: `"paradigm"`
  - `:priority`: `:critical`
  - `:ownerRole`: `"implementer"`
- **Motivation & Purpose**:
  - Every agent loads 5,913 tokens on launch whether it is a small SLM reading an AST outline or a supervisor managing a wave.
  - Tiers must be defined by what is lost when absent:
    - **Essential** (`:essential`): Contains all 7 invariants and strictly zero heuristics (~617 tokens). Without it, work cannot be validated.
    - **Hot / Tier 0**: Essential + affordances for active situation (~906 tokens).
    - **Tier 1**: Tier 0 + orientations (~1,371 tokens).
    - **Tier 2**: Tier 1 + heuristics (~1,820 tokens).
    - **Tier 3**: Tier 2 + agent role stance.
    - **Tier 4**: Tier 3 + single domain pack.
    - **Tier 5 / Full**: Complete paradigm (5,913 tokens).
  - Enforce **Strict Prefix Containment**: a lower tier MUST be an exact byte prefix of a higher tier. Raising a tier appends new material without modifying the existing prefix, preserving KV-cache across sessions.
  - Deterministic rendering must be supported via `scripts/install.sh --tier <name>` from the single source of truth (`rules.asn`).
- **Specific Files Owned (`:owns`)**:
  `["asl/grammar/rules.asn", "scripts/install.sh", "AGENTS.md"]`
- **Grader Verification Ownership (`:verificationOwns`)**:
  `["tests/acceptance/d81/Task46602.asl"]` (Read-only by implementer)
- **Concrete Action Steps**:
  1. In `asl/grammar/rules.asn`:
     - Add `:tier` or `:tiers` annotations to rule definitions.
     - Formally declare the `:essential` tier containing all 7 invariants and zero heuristics.
     - Order rules such that higher tiers append to the lower tier sequence, ensuring strict prefix alignment.
  2. In `scripts/install.sh`:
     - Add `--tier` CLI argument and `render_tier` helper function to `rules_main`:
       `--tier essential`, `--tier hot`, `--tier affordance`, `--tier pack`, `--tier full`.
     - Implement deterministic tier rendering extracting the exact prefix corresponding to the requested tier.
     - Ensure rendering preserves byte-level prefix stability across tiers.
  3. In `AGENTS.md`:
     - Synchronize the rendered rules block with the new tier structure.
  4. Verify rule consistency:
     ```bash
     bash scripts/install.sh --check-rules
     ```
- **Falsifiable Verification Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/acceptance/d81/Task46602.asl
  ```
- **Current Baseline Probe Failure Confirmation**:
  ```text
  [ASL_ASSERTION_FAILURE]: scripts/install.sh must support tier rendering
      ✓ tests/acceptance/d81/Task46602.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ tests/acceptance/d81/Task46602.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code: 1; fails on baseline because scripts/install.sh does not yet support --tier)*
- **Prerequisites (`depends_on`)**: `["Task46601"]`
- **What breaks if run before prerequisite**:
  `test-essential-tier-purity` requires that the essential tier contains every invariant and zero heuristics. Invariants and heuristics cannot be distinguished until Task46601 assigns forces in `rules.asn`.

---

### Work Item 3: Grounded Orientations for High-Entropy Situations (Task46603)
- **Path**: `asl/grammar/rules.asn`, `.asl/mem/principles.asn`
- **Identity**:
  - `:id`: `"item-3"` / `"Task46603"`
  - `:title`: `"The orientations that are missing: stake, adaptive thinking, problem solving"`
  - `:kind`: `:protocol`
  - `:lane`: `"paradigm"`
  - `:priority`: `:high`
  - `:ownerRole`: `"implementer"`
- **Motivation & Purpose**:
  - The current paradigm defines four roles and what each may not do, but provides virtually zero guidance when situations diverge from planned steps.
  - The single existing fallback rule (`edge`) is 173 tokens and leaves critical cognitive gaps.
  - Three vital orientations must be introduced and sized for the Tier 1 context budget:
    1. **Stake** (`:id stake`): The work is judged by whether it holds under verification, not merely whether it complied with prompt instructions. A defect encountered outside the immediate assignment is reported rather than stepped over.
    2. **Adaptive Thinking** (`:id adaptive`): An approach that is failing to produce signal is abandoned rather than pressed harder. The trigger for switching is the absence of new empirical evidence, not the absence of forward progress.
    3. **Problem Solving** (`:id problemSolving`): When no planned step covers the situation, reduce the problem to the cheapest test that would prove the current hypothesis wrong, and run that first.
  - Orientations carry strictly no compliance tests (`:gate` or assertion checks), avoiding degrading back into rigid rules.
- **Specific Files Owned (`:owns`)**:
  `["asl/grammar/rules.asn", ".asl/mem/principles.asn"]`
- **Grader Verification Ownership (`:verificationOwns`)**:
  `["tests/acceptance/d81/Task46603.asl"]` (Read-only by implementer)
- **Concrete Action Steps**:
  1. In `asl/grammar/rules.asn`:
     - Add `:id stake` rule:
       ```asn
       (:rule :id stake :force :orientation :when [:all] :tier [:orientation :full]
         :do "judge work by whether it holds, not by whether it was instructed; report an off-assignment defect rather than stepping over it; responsibility is to system integrity rather than prompt compliance")
       ```
     - Add `:id adaptive` rule:
       ```asn
       (:rule :id adaptive :force :orientation :when [:all] :tier [:orientation :full]
         :do "abandon an approach that is not working rather than pressing harder; the trigger to pivot is the absence of new empirical evidence; stop repeating failed operations with superficial edits")
       ```
     - Add `:id problemSolving` rule:
       ```asn
       (:rule :id problemSolving :force :orientation :when [:all] :tier [:orientation :full]
         :do "when no plan step covers the situation, reduce the uncertainty to the cheapest check that would prove you wrong and run that first; probe reality before generating speculative implementations")
       ```
     - Confirm that none of the three rules declare compliance tests or `:gate`.
  2. In `.asl/mem/principles.asn`:
     - Record normative principles for `StakeOverCompliance`, `AdaptivePivoting`, and `CheapestRefutationFirst`.
  3. Re-render and verify SSOT:
     ```bash
     bash scripts/install.sh --render-rules
     bash scripts/install.sh --check-rules
     ```
  4. Verify delimiter balance and pure syntax integrity:
     ```bash
     ./bin/asl check asl/grammar/rules.asn
     ./bin/asl lint asl/grammar/rules.asn
     ```
- **Falsifiable Verification Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/acceptance/d81/Task46603.asl
  ```
- **Current Baseline Probe Failure Confirmation**:
  ```text
  [ASL_ASSERTION_FAILURE]: rules.asn must declare stake orientation
      ✓ tests/acceptance/d81/Task46603.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ tests/acceptance/d81/Task46603.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code: 1; fails on baseline because rules.asn lacks :id stake)*
- **Prerequisites (`depends_on`)**: `["Task46601"]`
- **What breaks if run before prerequisite**:
  Orientations must declare `:force :orientation`, which is established and validated by the schema in Task46601.

---

### Work Item 4: Coherent Domain Packs Loaded by Situation (Task46604)
- **Path**: `asl/grammar/rules.asn`, `asl/grammar/capabilities.asn:1-62`, `scripts/install.sh`
- **Identity**:
  - `:id`: `"item-4"` / `"Task46604"`
  - `:title`: `"Domain packs: design, development, research, audit, loaded by situation"`
  - `:kind`: `:protocol`
  - `:lane`: `"paradigm"`
  - `:priority`: `:high`
  - `:ownerRole`: `"implementer"`
- **Motivation & Purpose**:
  - An agent doing UI design and an agent doing research need distinct domain guidance. Today both receive the monolithic 1,666 token lexical density specification and generic instructions.
  - Specialised concepts needed by only one agent type constitute pure prompt waste for every other agent.
  - Establish four independent domain packs:
    1. **Design** (`:pack design`): High visual SNR, typography hierarchy, responsive layout boundaries, and VDOM token density.
    2. **Development** (`:pack development`): Monorepo invariants, delimiter balance, pure ASL packaging, atomic git transactions, and AST mutation defense.
    3. **Research** (`:pack research`): Grounded measurements with scope/method/date, refutation of proxies, epistemic uncertainty markers, and empirical ledger tracking.
    4. **Audit** (`:pack audit`): Independent verification in clean contexts, falsifiable gates, gap analysis, and rejection of vacuous tests.
  - Modularity Rule: Shared concepts live in orientations (`edge`, `stake`, `adaptive`), never duplicated across packs.
  - Sizing constraint: Loading two packs must cost less than loading the full paradigm monolith.
- **Specific Files Owned (`:owns`)**:
  `["asl/grammar/rules.asn", "asl/grammar/capabilities.asn", "scripts/install.sh"]`
- **Grader Verification Ownership (`:verificationOwns`)**:
  `["tests/acceptance/d81/Task46604.asl"]` (Read-only by implementer)
- **Concrete Action Steps**:
  1. In `asl/grammar/rules.asn`:
     - Declare `:packs` block containing 4 coherent packs:
       - `(:pack :id design :outcomes [...] :failureModes [...] :affordances [...])`
       - `(:pack :id development :outcomes [...] :failureModes [...] :affordances [...])`
       - `(:pack :id research :outcomes [...] :failureModes [...] :affordances [...])`
       - `(:pack :id audit :outcomes [...] :failureModes [...] :affordances [...])`
     - Verify zero conceptual duplication between domain packs and base orientations.
  2. In `asl/grammar/capabilities.asn`:
     - Associate situation records (`orient`, `plan`, `change`, `verify`, `observe`) with applicable domain packs via `:pack`.
  3. In `scripts/install.sh`:
     - Add pack extraction capabilities to `--tier pack` or `--pack <name>`.
  4. Synchronize all surfaces:
     ```bash
     bash scripts/install.sh --render-rules
     bash scripts/install.sh --check-rules
     ```
- **Falsifiable Verification Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/acceptance/d81/Task46604.asl
  ```
- **Current Baseline Probe Failure Confirmation**:
  ```text
  [ASL_ASSERTION_FAILURE]: rules.asn must declare domain packs
      ✓ tests/acceptance/d81/Task46604.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ tests/acceptance/d81/Task46604.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code: 1; fails on baseline because rules.asn lacks :pack declaration)*
- **Prerequisites (`depends_on`)**: `["Task46602"]`
- **What breaks if run before prerequisite**:
  Domain packs populate Tier 4 of the context tier system. Tier structure and rendering machinery in `scripts/install.sh` from Task46602 must exist before pack modularization can be rendered.

---

### Work Item 5: Empirical Tier Telemetry & Performance Evaluation (Task46605)
- **Path**: `.asl/mem/telemetry/TierEvaluation20260912.asn`, `asl/bench`
- **Identity**:
  - `:id`: `"item-5"` / `"Task46605"`
  - `:title`: `"Measure whether a tier helps or only costs less"`
  - `:kind`: `:verification`
  - `:lane`: `"paradigm"`
  - `:priority`: `:critical`
  - `:ownerRole`: `"verifier"`
- **Motivation & Purpose**:
  - Reducing prompt tokens is cheaper by construction, but superior only by assumption.
  - Instruction-load effects vary across model architectures (IFScale, Chroma). Cutting 5,913 tokens to 617 is detrimental if invariant violations increase, but highly valuable if validity holds.
  - Run the fixed task set from `asl/bench` across tiers and record:
    - Invariant violations (physically counted by running gates, never by guessing).
    - Tasks completed vs dropped.
    - Unsupported claims.
    - Model tier recommendation (`:recommendedTier`) grounded in evidence.
  - Produce `.asl/mem/telemetry/TierEvaluation20260912.asn` with pure ASN syntax, zero comments (`C1`), and zero unicode emojis (`C2`).
- **Specific Files Owned (`:owns`)**:
  `[".asl/mem/telemetry/TierEvaluation20260912.asn", "asl/bench"]`
- **Grader Verification Ownership (`:verificationOwns`)**:
  `["tests/acceptance/d81/Task46605.asl"]` (Read-only by implementer)
- **Concrete Action Steps**:
  1. Author `.asl/mem/telemetry/TierEvaluation20260912.asn` with root form `(:tierEvaluation ...)` containing:
     - `:id "TierEvaluation20260912"`
     - `:measuredAt 1789379000000`
     - `:evaluationArms`:
       - `:essential`: token footprint 617, `:invariantViolations 0`, task completion metrics.
       - `:hot`: token footprint 906, `:invariantViolations 0`.
       - `:full`: token footprint 5913, baseline comparative stats.
     - `:invariantViolations`: counted via physical gate execution.
     - `:recommendedTier`: assignments per model class (e.g. SLM -> `:essential` / `:hot`, autonomous code agent -> `:tier2` / `:pack`).
     - `:empiricalConclusion`: factual finding on tier performance vs token cost.
  2. Ensure strict adherence to monorepo invariants: zero comments (`C1`), zero emojis (`C2`), balanced delimiters.
  3. Validate syntax and formatting:
     ```bash
     ./bin/asl check .asl/mem/telemetry/TierEvaluation20260912.asn
     ./bin/asl lint .asl/mem/telemetry/TierEvaluation20260912.asn
     ```
- **Falsifiable Verification Gate**:
  ```bash
  ./bin/asl test --strict-falsify tests/acceptance/d81/Task46605.asl
  ```
- **Current Baseline Probe Failure Confirmation**:
  ```text
  [ASL_ASSERTION_FAILURE]: TierEvaluation20260912.asn must exist
      ✓ tests/acceptance/d81/Task46605.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ tests/acceptance/d81/Task46605.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code: 1; fails on baseline because TierEvaluation20260912.asn does not exist)*
- **Prerequisites (`depends_on`)**: `["Task46602", "Task46604"]`
- **What breaks if run before prerequisite**:
  Cannot evaluate empirical tier telemetry until tiers (Task46602) and domain packs (Task46604) have been authored and are renderable.

---

## Baseline Probe Failure Confirmations

All five acceptance fixtures fail on the current repository baseline as required:

| Task ID | Verification Gate Command | Baseline Exit Code | Baseline Failure Reason |
|:---|:---|:---:|:---|
| **Task46601** | `./bin/asl test --strict-falsify tests/acceptance/d81/Task46601.asl` | `1` | `[ASL_ASSERTION_FAILURE]: rules.asn must declare invariant force` |
| **Task46602** | `./bin/asl test --strict-falsify tests/acceptance/d81/Task46602.asl` | `1` | `[ASL_ASSERTION_FAILURE]: scripts/install.sh must support tier rendering` |
| **Task46603** | `./bin/asl test --strict-falsify tests/acceptance/d81/Task46603.asl` | `1` | `[ASL_ASSERTION_FAILURE]: rules.asn must declare stake orientation` |
| **Task46604** | `./bin/asl test --strict-falsify tests/acceptance/d81/Task46604.asl` | `1` | `[ASL_ASSERTION_FAILURE]: rules.asn must declare domain packs` |
| **Task46605** | `./bin/asl test --strict-falsify tests/acceptance/d81/Task46605.asl` | `1` | `[ASL_ASSERTION_FAILURE]: TierEvaluation20260912.asn must exist` |

Additionally, all supervisor gate wrappers (`sh tests/acceptance/d81/SuperviseGate.sh <TaskID>`) fail at step `[1/3]` on baseline, confirming that the acceptance checks are strictly falsifiable and non-vacuous.

---

## Invariant & Risk Analysis

1. **C1 (Zero Comments Invariant)**:
   - Enforced by `./bin/asl lint`.
   - All ASN files (`asl/grammar/rules.asn`, `.asl/mem/principles.asn`, `.asl/mem/telemetry/TierEvaluation20260912.asn`) must contain 0 line or block comments.
2. **C2 (Zero Unicode Emojis)**:
   - Enforced by `./bin/asl audit gates` (Gate 6).
   - Machine ASN files must contain zero raw unicode emojis.
3. **C3 & D81 (Boundary Universalism & SSOT)**:
   - `asl/grammar/rules.asn` is the single source of truth.
   - Hand-editing rendered downstream surfaces (`AGENTS.md`, `CLAUDE.md`, `.agents/skills/asl-toolbelt/SKILL.md`) is strictly prohibited.
   - Any change to `rules.asn` MUST be followed by `bash scripts/install.sh --render-rules` and validated by `bash scripts/install.sh --check-rules`.
4. **Strict Prefix Containment Risk**:
   - If lower tier rendering does not form an exact byte prefix of higher tier rendering, KV-cache re-use across sessions degrades.
   - Mitigation: Ensure `render_tier` in `scripts/install.sh` uses monotonic append ordering matching the canonical tier sequence in `rules.asn`.
5. **Gate 7 (Skills Audit Consistency)**:
   - Changing `rules.asn` updates `asl-toolbelt/SKILL.md`.
   - Gate 7 (`./bin/asl audit gates` -> step 7/7) audits skill frontmatter, descriptions, and rules blocks. Running `--render-rules` preserves clean Gate 7 passes.
6. **Grader-Owned Acceptance Fixtures (`hiddenTests`)**:
   - `tests/acceptance/d81/Task4660*.asl` are owned by `independentVerifier`. The implementer must satisfy the gates without modifying the tests.

---

## Out of Scope
- Modifying acceptance tests in `tests/acceptance/d81/`.
- Modifying C host evaluation engine in `asl/tools/asl.c` (this phase is purely paradigm grammar, tier rendering, and telemetry).
- Modifying external home-directory configurations outside the workspace (e.g. `~/.claude/rules/asl.md`), which belong to external user setup.

---

## Opportunities & Suggestions
- **SLM Runtime Tier Hook**: `asl rpc (:where)` can inspect model identity and emit `--tier essential` for local M1 models, cutting prompt context by over 80% without losing invariant protection.
- **Dynamic Pack Auto-Loader**: Future integration in `asl doctor` to suggest domain packs automatically based on active repository file types (e.g. `.tsx` -> `design`, `.asl` -> `development`).
