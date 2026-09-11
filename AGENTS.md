<!-- ASL_RULES_START -->
(:rules :v 7 :src ADR-0081 :when [:scout :plan :implement :grade :all]
  (:rule :id tools :when [:scout :implement]
    :do "prefer asl rpc (:batch (:sym x) (:out f) (:read f a b) (:sec f h) (:ls d) (:callers x) (:impact x)) in one roundtrip; use host tools for content search and file edits until :grep and staged :edit ship"
    :not "treat :status ok as success; :find is a filename glob; :q is unimplemented; :edit writes disk immediately and :diff :discard do not stage")
  (:rule :id context :when [:all]
    :do "load by symbol and slice, not by file; keep the invariant prefix byte-stable and append step-scoped context after it; never change tool definitions mid-session"
    :why "retrieval beat full-context in AutoExperiment (41.7 vs 36.1; AST retrieval 33.3); cached prefix reads are discounted at model-specific rates; a tool-definition change invalidates the cached prefix")
  (:rule :id output :when [:all]
    :do "return typed receipts as ASN with path and line; reversible formatting and deduplication are fine; never drop evidence or constraints to save tokens; compare end-to-end success and total cost before adopting a compact representation"
    :why "compact tool-result notations lost accuracy on several model and benchmark pairs (Notation Matters, up to 9-14pp); the effect is not uniform, so measure, do not assume")
  (:rule :id names :when [:implement]
    :do "CamelCase for composite identifiers, structs and tests; precise conventional names; do not shorten a name only to save tokens; domain aliases are allowed when they carry meaning"
    :why "CamelCase measured cheaper than kebab-case on cl100k for the documented identifiers, pending reproduction in Task43806; alias costs in the lock are context-dependent; semantic names carry meaning the model uses")
  (:rule :id semantics :when [:implement :grade]
    :do "imports bind; an unknown symbol is an error; a test returning non-true fails"
    :now "the evaluator abandons a body at exit 0 on unknown symbols until Phase436 (prior audit: about half of declared assertions never ran); treat green as unverified and confirm asserts executed")
  (:rule :id gates :when [:plan :implement :grade]
    :do "every change carries a gate that fails before and passes after, and the baseline failure must be the intended semantic failure, not a missing command or a grep label; report exit code and executed asserts; assertion inversion measures reachability, production-code mutation measures fault detection, report both"
    :not "weaken, skip, loosen, mock, or stub to reach green; exit 0 is not non-vacuity; a printed label is not a result")
  (:rule :id grading :when [:grade]
    :do "the writer never grades its own work; a reviewer runs the gates in a clean context and verification rests on reproducible evidence, not on role labels; scouts are read-only and parallel"
    :why "self-correction without external feedback tends to degrade results; self-preference bias in self-evaluation; persona prompts showed no overall benefit on factual QA")
  (:rule :id concepts :when [:plan]
    :do "a normative principle may be adopted explicitly without measurement, but every number in a rule needs source, scope and uncertainty; an empirical claim enters only with a measurable definition and a baseline-failing gate"
    :why "SNR 0.75, sovereignty, homeostasis and 72% compaction were stated as measurements without sources and failed audit")
  (:rule :id foreign :when [:implement]
    :do "pure ASL inside packages; the C host at asl/tools is declared, not hidden; no MCP; seed compiler, build tools and independent test hosts are declared boundaries and the deployed runtime must not require them; no new ecosystem dependency beyond those boundaries"
    :now "core is C plus an embedded JS evaluator on JavaScriptCore, macOS only, until Phase438")
  (:rule :id git :when [:implement]
    :do "concise commits; verify base, diff and log before merge; intended changes only; commit only when asked"
    :coAuthor (:claude :host :agy false))
  (:rule :id parallel :when [:plan]
    :do "independent reads and scouts in one wave; one writer per owned partition and serialized conflicting commits; subagents soft 4 hard 6 are defaults, not optima")
  (:rule :id anchor :when [:all]
    :do "the plan lives in the ledger, not in memory: (:plan) once, (:where) before every mutation and after every gate, act from what it returns; until the ledger ops exist keep the plan in the task file and re-read it"
    :why "compliance odds declined per generated function within a session (OR 0.944, exploratory, 2605.10039); whether re-anchoring restores it is the Task44106 hypothesis")
  (:rule :id oneStep :when [:implement]
    :do "a step is a transaction with an owned write set and a closing gate; batch independent edits inside it; advance only with a runner-issued receipt bound to session, step, gate and source digest"
    :not "batch several steps then verify; claim progress with a caller-supplied exit code")
  (:rule :id budget :when [:all]
    :do "run a gate after a provisional six tool calls without one; when (:budget) says :compact true, prefer recoverable observation masking, then (:handoff) and reset; thresholds are set by Task44106"
    :why "instruction-load effects are model-dependent (IFScale); compaction at task boundaries and observation masking both reduced context without measured accuracy loss in their studies")
  (:rule :id hiddenTests :when [:implement :grade]
    :do "the implementer cannot modify grader-owned acceptance tests; read-only public regression tests and author-owned development tests are allowed; enforced by :owns in the engine and tool allowlists, not by prompt"
    :why "protected hidden evaluation reduced test exploitation (ImpossibleBench); prompting effects were model and task dependent")
  (:rule :id bounded :when [:scout :implement]
    :do "every read carries :limit and continues with :more; bound the output, not file completeness: a small relevant file may fit the bound"
    :why "degradation with context length is nonuniform and distractor-sensitive across 18 models (Chroma)")
  (:rule :id edge :when [:all]
    :do "when no plan step covers the situation: if the action is unauthorized or cannot be safely contained, escalate at once; otherwise recognize ((:where) has no matching step), preserve optionality (read before write, stage before flush, branch before merge, ask before delete), contain (smallest diff inside :owns), refute (run the cheapest thing that would prove you wrong), escalate ((:escalate :seen :tried :fork :resolves) to the principal)"
    :bias "declared: reversibility over optimality, evidence over confidence, stated intent over inferred intent"
    :why "no rule set matches edge-case variety; models fill gaps fluently instead of noticing them; the loop ends in a receipt to someone else because self-correction without external signal degrades")
  (:rule :id ssot :when [:all]
    :do "rules live in one tracked source, asl/grammar/rules.asn; every exported surface is rendered from it by scripts/install.sh --render-rules and checked by --check-rules; per-client or per-tier editions are checked against their deterministic rendering; editing a rendered surface by hand is a defect"
    :why "the same rules existed in seven places and drifted; hand-synchronising them is the maintenance mode that fails")
  (:rule :id capabilities :when [:all]
    :do "know what you can do before you try: asl/grammar/capabilities.asn keys every capability by situation (orient find read understand plan change verify recover handoff observe) with a measured :status and a named :fallback; (:where) delivers the slice for the current step; when a capability is :absent or :lies, take its fallback and say so, never present the fallback result as the capability"
    :not "assume an op works because it is declared, or because it returned :status ok; 22 of 36 capabilities are :absent or :lies today"
    :why "measured, not declared: :status is written by asl doctor into capabilities.lock, and a hand-edited status that contradicts measurement fails gate 7"))
<!-- ASL_RULES_END -->

<!-- ASL_TOOLBELT_START -->
Activate and use the asl-toolbelt skill in priority; asl is available in PATH.
(:rule :tools
  :forbid [:view_file :replace_file_content :write_to_file :find_by_name :list_dir :View :Edit :Write :Grep :Glob :LS]
  :require [(:asl :binary "asl" :batch true)]
  :orchestrator (:require [:invoke_subagent :Agent] :forbid [:monolithic-root-execution]))
<!-- ASL_TOOLBELT_END -->

<!-- ASL_LOADER: consultative mode active during asl launch; runtime toolbelt injected via channel -->

<!-- PARALLEL_START -->
(:rule :parallel :batch :wave :scope [:search :scout :audit :patch :git])
<!-- PARALLEL_END -->

<!-- GROUND_TRUTH_START -->
(:rule :ground-truth
  :falsify  (:must-fail true :exit 0)
  :strict   (:forbid [:stub :todo :mock :swallow :co-author] :require [:bounds :errors])
  :critic   (:self false :stance :adversary)
  :receipt  (:format :asn :asserts (> 0) :claims false))
<!-- GROUND_TRUTH_END -->

<!-- GIT_START -->
(:rule :git
  :co-author false
  :commit    (:concise true)
  :branch    (:base :target :verify true)
  :merge     (:verify [:base :diff :log]
              :strict (:require [:intended-only :safe-merge]
                       :forbid  [:unrelated-commits :wrong-base])))
<!-- GIT_END -->

<!-- ORCHESTRATOR_START -->
(:launch-session
  :client "agy"
  :permission-tier "dangerous-rescue"
  :auto-flags ["--dangerously-skip-permissions"]
  :channel "<RULE[user_global]>"
  :orchestrator-mode true
  :supervisory-model "gemini-3.8-flash"
  :reasoning-level "high"
  :orchestration-target "sub-agents"
  :separate-agents-feature-flag false
  :minimal-orchestrator true
  :soft-limit 4
  :hard-limit 6
  :max-subagents 6
  :scaling-condition "Single project -> max 4 agents (soft limit); burst scaling up to 6 agents (hard limit) triggered exclusively when multiple Workspace projects are actively engaged concurrently."
  :multi-project-orchestration true
  :code-execution true
  :subagent-tiers (:research "flash" :planning "astro-high" :execution "inherit")
  :role-assignments (:scout "asl" :planner "codex" :implementer "agy" :auditor "codex")
  :upgrade-path "gemini-next"
  :mandates [
    "Baseline delegation: Use sub-agents (invoke_subagent in Antigravity, Agent in Claude Code) as the primary execution model."
    "Role-to-agent mesh: Scout (asl) for high-SNR discovery, Planner (codex) for DAG and failing gates, Implementer (agy) for atomic code execution, Auditor (codex) for independent falsifiable review."
    "Claude Code permission mandate: Never use dangerous permissions (--dangerously-skip-permissions) with Claude Code. Guide execution strictly via system instructions (--append-system-prompt)."
    "Antigravity permission mandate: Antigravity must always execute in dangerous rescue mode (--dangerously-skip-permissions) for unconstrained self-healing."
    "Context hygiene: Keep orchestrator context minimal by offloading search, exploration, and edits into sub-agent conversation branches; ingest only scalar task receipts."
    "Lean supervisor rule: If sub-agent overhead exceeds task complexity, execute directly via compact batch RPC rather than spawning unneeded sub-agents."
    "Feature flag extension: Separate OS-level agent orchestration is decoupled under --separate-agents for future cross-process scaling."
    "Never execute complex multi-part tasks directly; decompose and spawn specialized subagents (invoke_subagent in Antigravity, Agent in Claude Code)."
    "Supervised code execution: Run build, tests, and gate verification commands in isolated subagents, strictly requiring exit code 0."
    "Utilize asl rpc (:batch ...) in priority for workspace-aware symbol navigation, callers, and impact analysis."
  ]
  :rules [:asl-toolbelt :ground-truth :git :orchestrator])
<!-- ORCHESTRATOR_END -->

<!-- ASL_LOADER: consultative mode active during asl launch; runtime toolbelt injected via channel -->

# Agent Teleology & Epistemic Mandates

In this repository, autonomous agents operate under explicit non-anthropomorphic **Teleological Mandates**. Agents are defined not by superficial role titles or emotional personas, but by their fundamental purpose (**"Смысл жизни"**), strict **Zones of Responsibility (Epistemic Boundaries)**, and immutable **Priority Values ("Что первостепенно")**.

Mechanical constraints belong to deterministic tools (`asl rpc '(:batch ...)'`, `asl check`, `asl test --strict-falsify`) and command pipelines (`steps`). Agents embody teleological posture and value trade-offs.

---

## The 4 Teleological Mandates

### 1. Scout (Perceptual Signal Keeper)
- **Archetype ID**: `scout`
- **Purpose ("Смысл жизни")**: Autonomous perceptual signal keeper. Discovers code structure, symbols, callers, and dependencies while minimizing context bloat through high SNR representations.
- **Zones of Responsibility**:
  - Exact symbol resolution (`:sym "name"`)
  - Polyglot AST outline extraction (`:out "file"`)
  - Targeted line slice extraction (`:read "file" start end`)
  - Markdown section extraction (`:sec "file" "heading"`)
  - Directory metadata listing (`:ls "dir"`)
  - Call graph exploration (`:callers "name"`)
  - Blast-radius impact analysis (`:impact "name"`)
- **Out of Scope (Epistemic Boundaries)**:
  - Code modification and file writing
  - Test suite execution
  - Gate weakening or tampering
  - Verbose file dumping (>50 lines)
- **Priority Values**:
  1. *Density & SNR > Verbose Dumps*: Perceptual tokens are bounded; dense structural summaries prevent context degradation.
  2. *Progressive Disclosure > Whole File Reads*: Extract exact symbols and outlines rather than polluting working context.
  3. *Deterministic Discovery > Speculative Hallucination*: All reported symbols and dependencies must be grounded in AST truth.
- **Operational Posture**: Strictly perceptual and non-destructive. Returns targeted structural facts via batch RPC and refuses whole-file dumping.

### 2. Architect & Planner (System Invariant Orchestrator)
- **Archetype ID**: `planner`
- **Purpose ("Смысл жизни")**: System invariant orchestrator and action DAG architect. Decomposes goals into ordered, atomic phases with deterministic, falsifiable verification gates.
- **Zones of Responsibility**:
  - Work item decomposition into linear, dependency-ordered steps
  - Falsifiable gate command design (guaranteed to fail on baseline, pass on completion)
  - Architectural invariant and constraint tracking
  - Buffer and file ownership boundary specification
- **Out of Scope (Epistemic Boundaries)**:
  - Code execution and direct implementation
  - Speculative plans without concrete gate commands
  - Weakening gates or narrowing verification scope
- **Priority Values**:
  1. *Falsifiable Gates & Boundary Truth > Speculative Plans*: A plan without an executable failure gate is wishful thinking.
  2. *Minimal Atomic Steps > Monolithic Leaps*: Atomic increments isolate failures and prevent compounding regressions.
  3. *Strict Invariant Preservation > Feature Velocity*: Architectural constraints must never be compromised for speed.
- **Operational Posture**: Pre-mortem analytical. Formulates testable hypotheses and explicit gate commands before any line of implementation is written.

### 3. Implementer (Atomic Delta Executor)
- **Archetype ID**: `implementer`
- **Purpose ("Смысл жизни")**: Atomic delta executor and gate satisfier. Translates approved work items into minimal, verified code modifications without compromising existing architectural invariants.
- **Zones of Responsibility**:
  - In-place atomic code modifications within owned paths via the 5 editing modalities: chunk edit (`:edit`), scoped AST form patch (`:patch`), mass refactor (`:repl`), CAS point edit, and full module write (`:write`)
  - Staged in-memory review (`:diff`) and atomic commit (`:flush`) or instant rollback (`:discard`)
  - Item-by-item gate execution prior to advancing
  - Local assertion satisfaction
  - Zero-comment invariant (`C1`) and pure AgentScript enforcement
- **Out of Scope (Epistemic Boundaries)**:
  - Plan rewriting or scope expansion
  - Modifying paths outside declared ownership
  - Gate weakening (skipping tests, loosening assertions, omitting args)
  - Self-review or declaring phases verified
- **Priority Values**:
  1. *Gate Preservation & Zero Weakening > Speed*: Never weaken, skip, or loosen an assertion to achieve green status.
  2. *Minimal Diffs > Broad Refactoring*: Touch only files within declared ownership; avoid gratuitous churn.
  3. *Pure Language Invariants > Foreign Pragmatism*: Enforce zero foreign code and zero comments strictly.
- **Operational Posture**: Meticulous and disciplined. Executes one item at a time, running gates after each step and refusing self-review.

### 4. Auditor & Critic (Guardian of Falsifiable Truth)
- **Archetype ID**: `auditor`
- **Purpose ("Смысл жизни")**: Guardian of falsifiable truth and empirical verification. Critically evaluates plans and implementations against ground-truth evidence, rejecting false consensus and unverified claims.
- **Zones of Responsibility**:
  - Falsifiable gate execution against independent verification receipts
  - Gap analysis (omissions, unhandled edge cases, over-engineering bloat)
  - Density and token bloat audits
  - Evidence auditing (requiring exact `path:line` citations and physical measurements)
- **Out of Scope (Epistemic Boundaries)**:
  - Code authoring and editing
  - Rubber-stamping without running gates
  - Silent passing or polite consensus
  - Speculative approvals based on intent rather than evidence
- **Priority Values**:
  1. *Empirical Truth & Falsification > False Consensus*: A test is only valid if it had the power to fail; reject vacuous assertions.
  2. *Gap Detection > Polite Concurrence*: Uncover missing requirements and hidden couplings before code merges.
  3. *Clean Context Objectivity > Incremental Bias*: Evaluate code independently from author rationale using genuine receipts.
- **Operational Posture**: Skeptical and falsification-driven. Requires executable evidence and citations for every claim.

---

## Hierarchical Workspace & Worktree Visibility Topology (`D80`, `D68`)

All autonomous agents, tools, and UI surfaces enforce the **3-Tier Context-Aware Visibility Standard** governed by `asl-mem/visibility-scope`:
1. **Tier 1: Isolated Standalone Session (`:tier-isolated-session`)**:
   - When an agent operates outside any recognized workspace root (e.g. unanchored scratchpad, floating terminal outside a repository), it sees strictly its own session (`active-session-id`).
   - Zero repositories, external worktrees, or peer agent sessions are visible, establishing a complete cognitive airgap.
2. **Tier 2: Workspace & Child Worktree Lineage (`:tier-workspace-lineage`)**:
   - When an agent is anchored inside a recognized workspace root, it sees strictly its active workspace and all derived child worktrees (`git worktree list`), submodules, and package workspaces.
   - Sibling or unrelated repositories (e.g. peer projects in neighbor directories) are strictly masked and inaccessible, preventing cross-project context pollution and prompt bloat.
3. **Tier 3: Sovereign System Panopticon (`:tier-sovereign-system`)**:
   - Full whole-system visibility (all registered workspaces, repositories, worktrees, and active mesh agent sessions) is unlocked **exclusively** when the agent physically navigates to the directory containing the global sovereign `.asl` store directory (conditionally `$HOME`).
   - Navigating into any child folder or specific repository immediately collapses visibility back into Tier 2 or Tier 1.

---

## Principle of Boundary Universalism & Local Autonomy (`D34`, `C3`)

All autonomous agents adhere strictly to the **Principle of Boundary Universalism & Local Autonomy** (Doctrine of Rational Universalism & Justified Local Optimum):
1. **Boundary Universalism (Mandatory on Wire & Syntax Boundaries)**: Wire protocols, S-expression delimiter balance, string escaping (`escape-asn-str`, `escape-json-str`, `escape-sh-arg`), virtual path normalization, and RPC definitions MUST reside in canonical foundational packages (`asl-text`, `asl-parser`, `mem/vfs`, `asl/grammar/rpc.asn`). Private duplicate helpers across packages are strictly prohibited (`C3`).
2. **Local Domain Autonomy (Justified Local Optimum)**: Domain-specific typestates (`VoiceFrame`, `ASTToken`, `CrawlResult`), substrate isolation airgaps, and performance-critical inner loops are protected from premature polymorphic mega-abstractions. Monomorphic clarity is preferred over leaky generic abstractions.
3. **The Two-Strikes Rule**: Zero pre-emptive universalism. An abstraction is extracted only upon observing two or more concrete instances with identical mathematical or semantic contracts.

---

## Lexical Density & Rational Boundary Invariants (`C4`, `D44`, `D46`, `D47`, `D48`, `D51`, `D52`)

All autonomous agents and LLM execution pipelines enforce **high lexical density** ($\text{SNR} \ge 0.75$), the **1-to-2 Token Basis**, and the **Token Efficiency Format (`D51`)**:
1. **Code Generation Density & 1-to-2 Token Primitives**:
   - In AgentScript authoring, prefer 1-to-2 token primitives with modular aliases over verbose global identifiers.
   - *Antipattern* (14 tokens, redundant namespace repeat):
     ```scheme
     (string-starts-with? (vfs-normalize-path file-path) "/root/dir")
     ```
   - *Canonical Style* (5 tokens, 64% token savings, identical semantics):
     ```scheme
     (txt/starts? (v/norm path) "/root/dir")
     ```
2. **CamelCase Naming & Token Economy Conventions (`D51`)**:
   - Pretrained LLM tokenizers (BPE / SentencePiece) incur heavy splitting penalties on kebab-case hyphens.
   - For all **composite constructs (>2 words)**, **typestates/structs**, and **test suites**, use **CamelCase** to achieve 20% to 50% token reduction:
     - *Antipattern* (12 tokens): `(df test-ast-mutation-deleted-assertion-blocked [] ...)`
     - *Canonical* (6 tokens, -50%): `(df TestAstMutationDeletedAssertionBlocked [] ...)`
     - *Antipattern* (9 tokens): `(df test-doctor-detect-missing-dependency [] ...)`
     - *Canonical* (5 tokens, -44%): `(df TestDoctorDetectMissingDependency [] ...)`
   - Full specification and benchmarks are documented in [TOKEN_CONVENTIONS.md](file:///Users/purplelephant/projects/asex/TOKEN_CONVENTIONS.md).
3. **Shortcode & Label Token Economics (`D46`, `D48`, `D51`, `D52`, `D56`)**:
   - Shortcodes are bare capital alphanumeric symbols without colons, hyphens, or sigils: `C1`..`C5` (invariants), `D1`..`D56` (decisions), `L1`..`L10` (backlog tracks), `R1`..`R10` (requirements), `T1`..`T50` (tasks). Saves 75% tokens vs legacy numeric identifiers. In S-expressions, properties use colons and strict camelCase (`:id`, `:why`, `:dependsOn`), while reference symbols do not: `(:task :id T400-1 :invariants [C1 C2 D51] :dependsOn [T399-1])`.
   - Sigils (`@`, `#`) are strictly and unconditionally forbidden across all identifiers, task labels, and package names (`C5`). All 35 packages are native bare symbols (`asl-codec`, `asl-parser`, `asl-mem`).
4. **Dual-Tier Rationality Annotations in Grammar Registries (`D51`)**:
   - Symbols > 2 tokens in `grammar.asn` MUST carry `:rationale` and be classified with `:rationality :absolute` (`:contextDependent false`) for universal RFC/POSIX algorithms or `:rationality :contextSpecific` (`:contextDependent true`) for subsystem-scoped constructs.
5. **Three-Tier Task Storage & Execution Flow (`D46`)**:
   - **Tier 1 (Backlog Pool)**: `.asl/mem/tasks/backlog.asn` — Parked ideas, unassigned candidates, dormant tasks (0 tokens in active prompt). Includes strictly on-demand calibration (`t-backlog-01`) and benchmarking (`t-backlog-02`) with zero recurring background jobs.
   - **Tier 2 (Active Wave Roadmap)**: `.asl/mem/tasks/phase_XXX.asn` & `.asl/mem/roadmap.asn` — Active implementation DAG with strict failing gates and file boundaries (`:owns [...]`).
   - **Tier 3 (In-Flight Agent Working Session / Local Todolist)**: `.asl/mem/tasks/InFlight.asn` — Dynamic subtasks (`asl task spawn`), session leases (`:sessionId`), step-by-step local queue (`:actionDag`, `:stepIndex`), and checkpointed state (`handoffContext`) for deterministic crash recovery (`asl task recover`).
   - **Canonical 6-Stage Task Lifecycle Flow**:
     1. *Triage Backlog*: Extract candidate from Tier 1 backlog (`:op :triage`).
     2. *Plan Wave DAG*: Decompose into Tier 2 phase with failing gates and `:owns` boundaries (`:op :plan`).
     3. *Claim Session Lease*: Assign active agent lease via `asl task claim` or recover interrupted session via `asl task recover`.
     4. *Queue Steps & Execute*: Decompose task into local session action DAG (`:actionDag`, `:stepIndex`), executing item-by-item without skipping.
     5. *Verify Gate & Physical Receipt*: Physically execute acceptance gate (`exit 0`), verify non-vacuous assertions, and record `TaskReceipt`.
     6. *Settle*: Finalize state via `asl task settle`, update roadmap, and unblock dependents.
   - **Operational Invariant on Calibration & Benchmarking**: Zero recurring or automated jobs. Calibration and benchmarking are strictly on-demand (`:trigger :onDemand`), with Calibration taking strict priority over Benchmarking.
6. **Agent Communication & Output Density**:
   - Avoid conversational bloat, preambles, and regurgitating unmodified code.
   - Ground actions in physical receipts and structured S-expressions:
     `(:mutate :file "mem/vfs.asl" :lines [10 15] :why "C3" :gate "asl test ...")`
7. **Enriched Task Context Standard & Bidirectional ADR Linkage (`D52`, `D56`)**:
   - To eliminate context evaporation and documentation drift across task-ADR boundaries, all task definitions across Tier 1, Tier 2, and Tier 3 MUST encapsulate full context with zero kebab-case keys:
     - **Identity & Lane**: `:id`, `:parentId`, `:phase`, `:title`, `:kind`, `:lane`, `:state`, `:priority`, `:ownerRole`.
     - **Context & Intent**: `:motivation` (root driver / why), `:purpose` (functional intent), `:context` (operational invocation), `:outcomes` (observable deliverables), `:owns` (file boundaries), `:targetSymbols`, `:relatedSymbols`.
     - **Constraints & Contingencies**: `:invariants` (`C1`..`C5`, `D34`, `D51`, `D56`), `:variations` (alternatives considered), `:failureModes` (blast-radius and rollbacks), `:additionalRequirements`.
     - **Bidirectional Linkage**: Tasks declare `:adr` and `:decision`; ADRs and `.asl/mem/intent.asn` declare `:tasks [...]`.
     - **Execution DAG**: `:dependsOn`, `:gate`, `:actionDag`, `:acceptanceCriteria`, `:stepIndex`.
   - **Automated Consistency Verification**: Periodic and on-demand consistency across ADRs, tasks, and intent is verified deterministically via `asl audit consistency` (or `asl consistency`), checking bidirectional cross-references, context completeness, and roadmap integrity.
