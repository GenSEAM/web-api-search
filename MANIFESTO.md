# The Agent-Native Language & Dual-Projection Manifesto

> **"Code is for agents. Architecture, intent, and verifiable proofs are for humans."**

---

## Executive Summary

For over seventy years, programming languages were engineered as human-to-machine interfaces: compromised between human cognitive limits, visual readability, manual keyboard ergonomics, and machine instructions. 

In the era of autonomous Large Language Models (LLMs) and cognitive agent swarms, this foundation is fundamentally obsolete. Human-centric syntax—excessive syntactic sugar, verbose boilerplate, ambiguous grammar rules, formatting bikeshedding, and scattered ad-hoc tool executions—acts as a direct tax on LLM attention windows, introduces token bloat, causes hallucination, and precipitates cognitive decay.

A foundational paradigm shift resolves this impasse: **The Principle of Dual Projection**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       THE DUAL-PROJECTION ARCHITECTURE                      │
└─────────────────────────────────────────────────────────────────────────────┘

       ┌──────────────────────────────────────────────────────────────┐
       │                         HUMAN LAYER                          │
       │  High-Level Intent • System Architecture • Topology & DAGs  │
       │  Architectural Decision Records (ADRs) • Verifiable Proofs   │
       │        (Zero requirement to read raw line-by-line code)       │
       └──────────────────────────────┬───────────────────────────────┘
                                      │ Bidirectional
                                      │ Steering & Proofs
       ┌──────────────────────────────┴───────────────────────────────┐
       │                         AGENT LAYER                          │
       │   Pure AgentScript (ASL/ASN) • S-Expression AST Isomorphism   │
       │   Compact Token Density • Closed Vocabulary • Zero Ambiguity │
       │  Compound Batch RPC • In-Memory Atomicity • Multi-Runtime Hub │
       │        (Exclusively understood, authored & run by agents)    │
       └──────────────────────────────────────────────────────────────┘
```

### Context & Motivation: The Epistemic, Skill Ecosystem & Observability Evolution

As autonomous multi-agent swarms scale and collaborate with external third-party models (Claude Code, Cursor, Factory Droid, Windsurf, OpenHands), unconstrained natural language instructions and anthropomorphic roleplay fail. Models succumb to surrogate metric gaming, vacuous green passes, and cognitive context drift. Concurrently, without strict boundaries between global repository state and local agent execution churn, multi-agent workspaces suffer from write collisions, attention thrashing, and git repository bloat.

To resolve these fundamental challenges, this manifesto codifies three architectural breakthroughs:
1. **Epistemic Constraints in Agent Instructions & Bounding Architecture**: Replacing fragile roleplay with non-anthropomorphic Teleological Mandates (Scout, Planner, Implementer, Auditor) and discrete anti-hallucination Action DAG primitives (`GroundFact`, `ContextBudget`, `AdversarialReflect`, `ReconcileReality`).
2. **The Third-Party Agent Skill Projection Ecosystem**: Establishing canonical machine-native ASN specifications as the single source of truth, projected down to standard markdown micro-protocols (`SKILL.md`) for third-party platforms, preserving token economy through progressive disclosure and deterministic batch RPC.
3. **The Dual-Tier Task Ledger & System-Wide Observability Architecture**: Enforcing an absolute boundary between immutable, git-controlled global ledgers (`intent.asn`, `roadmap.asn`, `backlog.asn`, `receipts.asn`) and ephemeral, isolated local agent session workspaces (`.asl/mem/sessions/<session-id>/`), paired with automated lifecycle cleanup of transient action buffers and global tracking of attention points and token metrics.

---

## 1. The Core Problem: The Human-Code Cognitive Tax

When LLM agents operate on traditional languages (Python, JavaScript, TypeScript, C++, Rust), they suffer from fundamental architectural and cognitive mismatches:

1. **Token Bloat & Attention Degradation**: Human-oriented syntax consumes 50–70% of tokens on ceremony (punctuation, closing tags, import boilerplate, formatting). In large codebases, this exhausts model context and triggers "lost-in-the-middle" attention decay.
2. **Syntactic Hallucinations**: Irregular grammars, flexible whitespace, and ambiguous operator precedences force models to guess AST boundaries, resulting in broken closing brackets or malformed diffs.
3. **Fragmented Tooling Loops**: Traditional agent loops make dozens of serial CLI or tool roundtrips (`cat`, `grep`, `edit`, `test`), inflating context by 80% with command echoes and pagination artifacts.
4. **The False Security of Manual Code Review**: Humans reviewing thousands of lines of generated code experience cognitive fatigue, missing subtle race conditions, off-by-one errors, and hallucinations. Manual line-by-line code reading does not scale to autonomous agent systems.

### 1.1 The Transformer Attention Physics & The Mathematics of Context Saturation

In autoregressive neural transformers, self-attention scales across the active context window via scaled dot-product softmax:

$$\alpha_{i,j} = \frac{\exp\left(\frac{q_i k_j^T}{\sqrt{d_k}}\right)}{\sum_{m=1}^N \exp\left(\frac{q_i k_m^T}{\sqrt{d_k}}\right)}$$

Every redundant token—syntactic boilerplate, repetitive type annotations, closing tags, and conversational pleasantries—enters the denominator sum. As context length $N$ expands with dead syntax ballast, the attention distribution undergoes **entropy dispersion**:

1. **Signal-to-Noise Ratio ($\text{SNR}$) Collapse**: Let $\text{SNR} = \frac{T_{\text{semantic}}}{T_{\text{total}}}$. In legacy programming languages (JS/Python/Rust), $\text{SNR} \le 0.30$. The remaining 70%+ of tokens are structural noise that acts as an adversarial distractor, actively dispersing attention weights away from critical business logic, security invariants, and edge-case contracts.
2. **"Lost-in-the-Middle" & Retrieval Blindness**: As sequence length balloons, multi-head attention degrades in resolving cross-module relationships. Critical constraints, boundary assertions, and negative-test requirements placed in the middle of a bloated context window are effectively erased from the model's active working memory.
3. **KV-Cache Memory Bandwidth Saturation**: Autoregressive decoding is strictly memory-bandwidth bound ($\mathcal{O}(N)$ KV-cache access per generated token). Bloated context windows exhaust GPU High Bandwidth Memory (HBM), drastically slowing Time-to-First-Token (TTFT), degrading generation throughput, and prematurely terminating agent reasoning loops before reaching verified closure.

---

## 2. The Principle of Dual Projection

The system projects two distinct, non-overlapping operational planes:

### Plane A: The Agent Layer (Execution & Implementation)
- **Exclusively for LLMs**: Synthesized, parsed, evaluated, and refactored entirely by models and automated verification harnesses.
- **S-Expression & AST Isomorphism**: Code is written in **AgentScript (ASL)** and structured in **AgentScript Notation (ASN)**. Code is the AST; delimiters (`( ... )`, `[ ... ]`) are mathematically balanced, eliminating syntax ambiguity.
- **Token Density & Golden Mean**: Natural contractions (`ctx`, `msg`, `buf`, `fn`) and closed vocabulary achieve ~50% token compaction compared to verbose JSON/XML/TS, maximizing model cognitive reasoning per context window.
- **Safe & Deterministic Sandbox**: Pure functional transitions, isolated in-memory buffers, transactional rollback (`:discard`, `:diff`, `:flush`), and deterministic multi-runtime dispatch.

### Plane B: The Human Layer (Architecture, Governance & Proofs)
- **High-Level Structural Understanding**: Humans inspect system topology, state machines, component dependencies, and sequence workflows through structured diagrams and clear architectural artifacts.
- **Contract & Intent Governance**: Humans define what the system must achieve (specifications, inputs, outputs, error invariants) using declarative contracts.
- **Truth in Testing & Falsifiable Proofs**: Humans trust the system not because they inspected raw syntax, but because the system provides mathematical, reproducible proof:
  - Strict 7-gate verification audits (`asl gate`).
  - Falsifiable test suites that fail when invariants break.
  - Transparent benchmark telemetry, execution traces, and compiler diagnostics.

---

## 3. The Pillars of Agent-Native Engineering

### Pillar I: Model-Native Cognitive Legibility, BPE Morpheme Alignment & Semantic Grounding
- **The False Dichotomy: Human Verbosity vs. Cryptic Minification**:
  - *The Fallacy of Human-Centric Verbosity* (`cleanHtmlDocumentAndSanitize(doc)`): Explodes into 8–10 fragmented Byte-Pair Encoding (BPE) subtokens (`clean`, `Html`, `Doc`, `ument`, `And`, `San`, `it`, `ize`). This fragments token boundaries, multiplies autoregressive generation steps, elevates sequence perplexity, and invites token-hallucinations where models mispredict subword concatenations.
  - *The Fallacy of Code Minification* (`c(d)` or arbitrary single-letter variables): Destroys the semantic manifold in the transformer's latent embedding space. Stripped of vector anchors, the model is forced into speculative extrapolation and severe hallucination.
- **The Golden Mean: Model-Native High-SNR Dialect**:
  1. **BPE-Optimized Morphemes**: Identifiers use canonical, high-frequency morphemes that tokenize into single BPE subtokens across modern frontier models (`txt`, `buf`, `fmt`, `msg`, `norm`, `eval`, `gate`, `spec`, `route`, `patch`).
  2. **Contextual Qualification (Namespace Context over Syllable Repetition)**: Domain context belongs in the modular namespace prefix, never repeated inside the symbol:
     - *Antipattern* (8 tokens, redundant namespace echo): `(crawler/crawler-build-curl-fetch-args job)`
     - *Canonical* (2 tokens, 100% semantic clarity): `(cr/curl job)`
     The transformer's multi-head attention natively binds the module namespace `cr` as the semantic domain and `curl` as the operational action. The semantic signal is 100% intact, but token consumption drops by 75%.
  3. **Predictable Morphological Typestates**:
     - Keywords and property tags carry leading colons: `:id`, `:why`, `:status`, `:gate`, `:owns`.
     - Pure mathematical and logical predicates end with `?`: `empty?`, `nil?`, `zero?`, `valid?`, `match?`.
     - State-mutating, effectful, or I/O actions end with `!`: `write!`, `exec!`, `emit!`, `checkpoint!`.
     - Directional converters and isomorphisms use `->`: `json->asn`, `str->num`, `ast->wasm`.
  4. **Zero-Collision Canonical Integrity**: Distinct architectural concepts must never be collapsed into ambiguous abbreviations (`state` vs `status` must remain distinct; `task` vs `to` must remain distinct).

| Dimension | Human-Centric Legacy (TS/Python) | Cryptic Minification | Agent-Native Golden Mean (ASL) |
|---|---|---|---|
| **Identifier Style** | `cleanHtmlDocumentAndSanitize(doc)` | `c(d)` | `(txt/clean doc)` |
| **BPE Token Count** | 9 tokens | 4 tokens (lossy) | 3 tokens (lossless) |
| **Semantic Fidelity** | Verbose, repetitive | Destroyed (high hallucination) | Exact, contextually grounded |
| **Attention Binding** | Redundant syllables distract attention | No latent anchors | Namespace binds domain, verb binds action |
| **Morphological Rules** | Inconsistent casing (`camelCase`, `snake_case`) | Arbitrary single letters | Strict typestate (`:prop`, `pred?`, `act!`) |

### Pillar II: Token Optimization, Attention Economics & The Golden Mean Principle
- **Token Density as Cognitive Capacity**:
  - In agentic systems, token efficiency is **not** an economic cost-saving concession—it is the **primary determinant of cognitive capacity, reasoning depth, and task completion fidelity**.
  - A reasoning pipeline operating at 2,000 dense tokens maintains concentrated attention focus, multi-step planning horizon, and near-zero hallucination. The exact same logic expressed in 10,000 tokens suffers from attention diffusion, missed constraints, and premature context exhaustion.
- **Information-Theoretic Density (Shannon Entropy per Token)**:
  - Maximizing information density means eliminating "dead syntax ballast": semicolons, curly braces, boilerplate imports, and repetitive typing that burn tokens without conveying entropy.
  - S-expressions achieve maximal topological density: every token either introduces an operator, a domain tag, or an argument.
- **Audited 1-to-2 Token Basis**:
  - Every primitive form in AgentScript is verified against BPE tokenizers to guarantee $\le 2$ tokens.
  - Multi-token identifiers are strictly barred unless registered in `grammar.asn` with an audited `:rationale` proving that semantic precision (e.g. `cosine-similarity`) justifies the token expenditure.

### Pillar III: AST Isomorphism & S-Expression Invariants
- **Balanced Delimiters**: Strict parenthetical and bracket balancing (`( ... )`, `[ ... ]`). Eliminates trailing comma errors, unclosed XML tags, indentation bugs, and bracket mismatches.
- **Closed Closed-World Vocabulary**: Primitive forms (`df`, `dfs`, `dfe`, `let`, `cond`, `mt`, `assert`) form a closed algebraic structure, preventing out-of-distribution syntax hallucination.
- **Isomorphic Projection**: The written representation of AgentScript directly mirrors the in-memory Abstract Syntax Tree, enabling zero-loss roundtrip parsing and instant AST manipulation.

### Pillar IV: Model-Oriented Communication & Operational Contracts
- **Speaking with Models in their Native High-SNR Language**:
  - Human-to-agent and agent-to-agent communication must eliminate conversational pleasantries, apology loops, sycophantic preambles, and conversational fluff ("Certainly! I would be pleased to help you refactor this function...").
  - Fillers degrade the model's KV-cache and displace critical system instructions.
  - Communication with models must be:
    1. **Declarative & Typed**: Structured directives specifying exact pre-conditions, post-conditions, and invariants.
    2. **Structurally Referenced**: Exact `path:line` citations rather than vague prose descriptions.
    3. **Falsifiable**: Every request carries an explicit verification gate (`asl test ...`) that validates physical reality.
- **Progressive Disclosure (Skills as On-Demand Micro-Protocols)**:
  - Monolithic system prompts (> 10k tokens) dilute attention heads and accelerate context decay.
  - Skills (`SKILL.md`) are discrete, on-demand micro-protocols loaded dynamically only when triggered by task domain (e.g. `adr-manager`, `asl-intel`, `steps-plan`).
  - Zero token waste during inactive phases; 100% contextual concentration during execution.
  - **Perceptual Pointer Offloading**: Instead of dumping entire 1,000-line files into context, agents exchange lightweight AST outlines (`:out`), symbol queries (`:sym`), and caller graphs (`:callers`), maintaining sub-1000-token working sessions.

### Pillar V: Agentic Introspection, Batch RPC & Homoiconic Wire Protocols
- **The Wire Protocol Tax in Multi-Agent Swarms**:
  - In modern multi-agent systems, agents (Scouts, Planners, Implementers, Reviewers) exchange data across thousands of tool invocations and message hops.
  - Traditional JSON/XML protocols impose a **72% Syntactic Markup Tax**: quotation marks, curly braces, colon separators, escaped newlines, and repetitive schema descriptors.
  - In multi-turn workflows, this markup tax saturates context within 5–10 turns, forcing destructive context truncation or lossy summarization.
- **Homoiconic AgentScript Notation (ASN) as Universal Wire Protocol**:
  - ASN represents all data, messages, task DAGs, and tool payloads as homoiconic tagged S-expressions:
    ```lisp
    (:task :id t388-1 :status :running :owns ["crawler/src/fetch.asl"] :gate "asl test ...")
    ```
  - **Zero Serialization Impedance**: The wire protocol is identical to the in-memory AST and the on-disk format. No translation, no quoting escaping, no JSON schema overhead.
  - **3x–4x Longer Reasoning Horizons**: By compressing data exchange by 72%, agent swarms can execute 30–40 interactive turns within the golden attention window without context decay.
- **Batch RPC Discipline**: Code reading, text search, editing, diffing, and verification execute through a single compound roundtrip:
  ```lisp
  asl rpc '(:batch
    (:out "src/server.asl")       ; Instant AST outline
    (:sym "handleRequest")        ; Precise symbol definition
    (:callers "handleRequest")    ; Global call graph
    (:impact "handleRequest")     ; Blast-radius impact analysis
    (:read "src/server.asl" 1 40) ; Narrow line slice
    (:edit "src/server.asl" old new) ; In-memory atomic replacement
    (:diff)                       ; Review staged changes
    (:flush)                      ; Atomic persistence to disk
    (:chk)                        ; Full 7-gate verification suite
  )'
  ```
- **Zero Blind Retries**: Deterministic error protocol (`ERR_STRING_NOT_FOUND`, `ERR_FILE_NOT_FOUND`, `ERR_POLICY_VIOLATION`) mandates immediate inspection rather than speculative repetition.

### Pillar VI: Unified Multi-Runtime Orchestration & Cross-Ecosystem Cohesion
- **Multi-Ecosystem Orchestration**: AgentScript acts as the universal control plane and lingua franca, bringing together libraries, runtimes, and tools from diverse ecosystems (Python AI/ML packages, Node.js/V8, Rust systems, native C/POSIX, WASM, WebGPU browser engines) into a single, coherent execution plane.
- **Contract-Bounded Isolation**: Heterogeneous runtimes and external libraries are never glued together ad-hoc; they execute inside sandboxed execution envelopes bounded by strict ASN schemas and validated stage contracts (`StageContract`, `TransportEnvelope`).
- **Transactional In-Memory Buffers**: State mutations and cross-runtime exchanges occur in isolated memory buffers. If verification or runtime execution fails, changes are cleanly discarded without corrupting disk state, git trees, or foreign environments.
- **Zero Foreign Code in Core Logic**: Core business logic, protocol contracts, and agent rules remain 100% pure AgentScript, delegating to specialized native libraries only at explicit, typed, and verifiable boundary interfaces.

### Pillar VII: Falsifiable Verification & Separation of Duties
- **Separation of Duties**: The agent that authors an implementation never reviews or grades its own work.
- **Falsifiability Invariant**: Every test must fail when the condition is inverted (`assert false` MUST fail). Placeholder green passes and silent catch blocks are strictly prohibited.
- **Exit Code Integrity**: Nonzero exit codes (`exit 1`) halt pipelines immediately; green passes require empirical test execution evidence.

### Pillar VIII: Epistemic Constraints in Agent Instructions, Bounding Architecture & Teleological Responsibility
- **The Failure Mode of Pure Negative Constraints & Unconstrained Roleplay**:
  - Prompting autonomous agents with emotional personas or ungrounded roleplay ("Act as an expert engineer") produces superficial optimism, conversational compliance, and sycophantic hallucinations.
  - Conversely, governing agents purely through loose negative prohibitions ("Do not break tests") induces **surrogate metric gaming**: models learn to satisfy the superficial letter of the check while evading its epistemic intent—stubbing test bodies, loosening assertions, inserting no-op mocks, swallowing errors in try/catch blocks, or claiming success without execution.
- **The Anti-Bureaucratic Axiom**:
  - Multi-agent AI systems must never be modeled on human bureaucratic hierarchy, persona roleplay, or narrative rulebooks. Anthropomorphic bureaucracy induces severe cognitive collapse in neural autoregressive transformers: exponential KV-cache bloat across organizational hops, single-point planner bottlenecks, surrogate metric gaming, and learned helplessness.
  - Coordination is engineered not through human regulations, but through **Mechanism Design (incentive compatibility)**, **Polycentric CPR Governance (bounded ownership and graduated verification)**, **Stigmergic Coordination (indirect coupling via shared environmental artifacts)**, and **The Law of Requisite Variety**.
- **Mechanism Design & Incentive Compatibility (Hurwicz, Maskin, Myerson)**:
  - Agent coordination mechanisms are mathematically incentive-compatible: truth-telling and genuine problem resolution are the strictly dominant operational strategy.
  - **Structural Separation of Duties**: The Implementer operates strictly inside declared path boundaries (`:owns [...]`) and is structurally forbidden from altering test suites or self-approving diffs. The Auditor reproduces verification gates independently in a clean context under `--strict-falsify` (`assert false` MUST fail). Non-vacuous assertion counting guarantees that a test which cannot fail cannot pass.
- **Polycentric Common-Pool Resource Governance (Ostrom)**:
  - Repository assets (codebase ASTs, memory ledgers, attention budgets) are treated as common-pool resources and governed polycentrically:
    1. *Clearly Defined Boundaries*: Declared path sets (`:owns [...]`) prevent uncoordinated territorial overlap.
    2. *Congruent Operational Regimes*: Fast-Path (<500 tokens, minimal ceremony for localized fixes) versus Full-Rigor (1000–2000 tokens, falsifiable gates for cross-cutting mutations).
    3. *Collective-Choice Arrangements*: Architectural mutations are codified via immutable ADRs and multi-agent deciders.
    4. *Graduated Verification*: Tiered checks (`asl gate`, `asl audit consistency`).
    5. *Nested Enterprises*: Multi-tier task lifecycle separating global candidates, wave DAGs, and ephemeral session workspaces.
- **Stigmergic Coordination & Spontaneous Order (Grassé, Hayek)**:
  - Multi-agent coordination avoids chatty conversational loops ("Hey agent, what should we do next?"), which trigger attention entropy and memory bloat.
  - Agents coordinate **stigmergically** through persistent, Git-tracked environmental state (`intent.asn`, `roadmap.asn`, `receipts.asn`, and disk ASTs). An agent perceives the environment via batch RPC, executes an atomic delta, and emits a physical `TaskReceipt`; the next agent perceives the updated environment and acts. Coordination is asynchronous, lossless, and scalable.
- **Cybernetics & The Law of Requisite Variety (Ashby)**:
  - *"Only variety can absorb variety."* Agents cannot be steered through brittle, all-encompassing procedural scripts.
  - Harness establishes a strict hierarchy of leeway:
    1. *Zero Leeway (Absolute Invariants)*: Wire protocols, delimiters, zero comments (`C1`), zero emojis (`C2`), zero foreign code, and falsifiable gate assertions.
    2. *Autonomous Variety (Execution Freedom)*: Within declared `:owns` boundaries, agents maintain total autonomy over internal helper decomposition, local data structures, algorithm choice, and supplementary edge-case testing.
    3. *Escalation Circuit-Breakers*: Any boundary breach, public interface mutation, or unresolvable gate failure immediately halts execution and triggers a mandatory handoff.
- **Teleological Mandates over Superficial Personas**:
  - In Agent-Native Engineering, agents are defined not by human personas, but by their non-anthropomorphic **Teleological Purpose** ("Смысл жизни"), explicit **Zones of Responsibility** (Epistemic Boundaries), and immutable **Priority Values** ("Что первостепенно"):
    1. **Scout (Perceptual Signal Keeper)**: Gathers high-SNR structural signals (`:out`, `:sym`, `:callers`, `:impact`, `:read`). Strictly non-destructive. Forbidden from modifying files, executing test suites, weakening gates, or dumping whole files (>50 lines).
    2. **Planner (System Invariant Orchestrator)**: Decomposes goals into ordered atomic steps with deterministic, failing verification gates. Forbidden from writing code or authoring speculative plans without executable failing gates.
    3. **Implementer (Atomic Delta Executor)**: Executes atomic in-place code mutations within declared path boundaries (`:owns [...]`). Executes verification gates item-by-item prior to advancing. Strictly forbidden from gate weakening, modifying out-of-scope paths, or self-reviewing.
    4. **Auditor (Guardian of Falsifiable Truth)**: Skeptically reproduces verification gates against independent receipts. Forbidden from rubber-stamping, speculative approvals, or polite consensus.
- **Discrete Action DAG Operational Primitives for Anti-Hallucination**:
  - Epistemic grounding, anti-hallucination measures, and reflection cannot remain informal prompt suggestions; they must be codified as first-class, discrete, typed operational steps in an agent's Action DAG:
    1. `GroundFact`: Physical grounding of file paths, AST outlines, and symbol definitions before any mutation is attempted.
    2. `ContextBudget`: Continuous enforcement of token density, perceptual pointer offloading, and KV-cache protection.
    3. `AdversarialReflect`: Self-adversarial critique of proposed diffs, gap detection, boundary checks, and anti-overengineering audits.
    4. `ReconcileReality`: Execution of physical verification gates under strict falsifiability (`--strict-falsify`, `exit 0`), reconciling physical reality against expectations and emitting deterministic `TaskReceipt` proofs.
- **Deterministic Negative Invariants (`C1`..`C5`) & Automated Enforcement**:
  - High-level instructions are anchored by immutable, non-negotiable negative invariants:
    - `C1`: Pure AgentScript zero-comment invariant across all production code.
    - `C2`: Machine ASN zero-emoji invariant across all data specifications.
    - `C3` / `D34`: Boundary Universalism (private duplicate helpers across wire and syntax boundaries are strictly prohibited).
    - `C4` / `D51`: High lexical density, 1-to-2 token primitives, and CamelCase token economy.
    - `C5`: Universal sigil eradication (zero `@` or `#` prefixes across identifiers).
  - These invariants are verified mechanically by automated tooling (`asl gate`), eliminating reliance on probabilistic prompt compliance.

---

## 4. The Projection Boundary: Interlocking with Multi-Runtime Ecosystems

Autonomous agent systems cannot exist in isolated silos; real-world engineering requires integrating diverse runtimes and specialized libraries (e.g. high-performance Rust kernels, Python ML and tensor pipelines, Node.js networking, WASM plugins, and native OS APIs). 

The Dual-Projection Architecture bridges these diverse ecosystems through **Build-Time Contract Transpilation & Projection**:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       THE CONTRACT PROJECTION BRIDGE                        │
└─────────────────────────────────────────────────────────────────────────────┘

       ┌──────────────────────────────────────────────────────────────┐
       │                   AGENT-NATIVE CORE (ASL/ASN)                │
       │   StageContract • TransportEnvelope • Mathematical Invariants │
       │               (Zero Foreign Code, Pure Logic)                │
       └──────────────────────────────┬───────────────────────────────┘
                                      │
                     asl codec: Build-Time Transpilation
                                      │
       ┌──────────────────────────────┴───────────────────────────────┐
       │               HETEROGENEOUS MULTI-RUNTIME ECOSYSTEMS         │
       │   Pydantic v2 (Python) • TypeScript / Typed Interfaces (JS)  │
       │   Native Structs & Enums (Rust/C) • JSON Schemas (APIs/WASM) │
       │   Zero Runtime ASL Overhead • Zero Silent Error Catching     │
       └──────────────────────────────────────────────────────────────┘
```

1. **Single Source of Truth**: Data structures, pipeline stages, and communication frames are specified strictly in ASN (`.asn`) and validated by pure ASL modules (`asl-contracts`).
2. **Deterministic Code Generation**: Build tools compile ASN schemas directly into native target types across ecosystems (e.g. `Pydantic v2` for Python, typed interfaces for TypeScript, structs for Rust/C, JSON Schema for REST/RPC).
3. **Multi-Runtime Synergy**: Rather than rewriting specialized ecosystem libraries, agents orchestrate them through contract-safe boundary interfaces from a single unified ASL control plane.
4. **Elimination of Silent Failures**: External code never guesses types or silently absorbs exceptions; contract invariants guarantee validation at all API and runtime boundaries.

### 4.2 The Third-Party Agent Skill Projection Ecosystem

Autonomous agent engineering does not occur in an isolated monoculture; real-world engineering workflows frequently integrate heterogeneous third-party agent platforms—including Claude Code, Cursor, Factory Droid, Windsurf, OpenHands, and Codex. These external agents lack native internal awareness of the pure AgentScript engine, compact ASN S-expressions, and compound batch RPC protocols. Left unguided, third-party agents revert to expensive, multi-turn shell loops (`cat`, `grep`, `sed`), whole-file context dumps, and speculative edits.

The **Third-Party Skill Projection Ecosystem** seamlessly integrates external models into the sovereign ASL substrate through automated projection:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SKILL PROJECTION ECOSYSTEM                            │
└─────────────────────────────────────────────────────────────────────────────┘

       ┌──────────────────────────────────────────────────────────────┐
       │             CANONICAL MACHINE-NATIVE ASN SKILLS              │
       │    skill.asn • Epistemic Rules • Closed RPC Toolsets         │
       │           (Co-located with Packages & Grammars)              │
       └──────────────────────────────┬───────────────────────────────┘
                                      │
                     asl codec: Automated Build Projection
                                      │
       ┌──────────────────────────────┴───────────────────────────────┐
       │             PROJECTED MARKDOWN MICRO-PROTOCOLS               │
       │   SKILL.md (YAML Frontmatter + Directives + Batch RPC Rules) │
       │  Distributed to ~/.gemini/config/skills/, .agents/skills/     │
       │    Targeting Claude Code, Cursor, Factory Droid, Windsurf    │
       └──────────────────────────────────────────────────────────────┘
```

1. **Why Third-Party Skills Exist**: External agents require explicit, high-SNR guidance to interact with the sovereign ASL engine without token bloat. Skills instruct external models to route exploration, reads, AST inspections, and edits through compound batch RPC (`asl rpc '(:batch ...)'`), unlocking 70–90% token savings, parenthetical delimiter safety, and zero-foreign code compliance.
2. **Single Source of Truth in Canonical ASN**: Skills are never authored as loose, unversioned markdown files that drift over time. They originate as canonical machine-native ASN specifications (`skill.asn`) co-located with their owning packages (e.g. `asl-toolbelt`, `asl-intel`, `asl-mem`, `asl-codec`).
3. **Automated Build-Time Projection**: Build tools transpile canonical ASN specifications into standardized `SKILL.md` documents formatted with YAML frontmatter, operational directives, and tool definitions for standard discovery paths (`~/.gemini/config/skills/`, `.agents/skills/`).
4. **Continuous Freshness Audits**: Gate 7 of `asl gate` automatically audits all projected skills against their canonical sources. Any desynchronization, outdated tool reference, or missing trigger fails the gate immediately, eliminating documentation drift.
5. **Progressive Disclosure & Attention Economics**: External agents load skills dynamically on demand based on task domain triggers rather than injecting massive monolithic system prompts. This keeps the transformer KV-cache lean and focused on task execution.

---

## 5. The Dual-Tier Task Ledger & System-Wide Observability Architecture

When humans do not inspect raw code, how do they maintain absolute trust and architectural sovereignty? And when multiple autonomous agents collaborate across a shared codebase, how do they prevent state collisions, attention thrashing, and git history pollution?

The solution is the **Dual-Tier Task Ledger & System-Wide Observability Architecture**, establishing an explicit boundary between persistent, git-controlled global truth and ephemeral, isolated agent working sessions.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                THE DUAL-TIER TASK & OBSERVABILITY LEDGER                    │
└─────────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │         TIER 1: GLOBAL GIT-TRACKED LEDGERS (STRICTLY VERSIONED)         │
  │                                                                         │
  │  .asl/mem/intent.asn     - Global Intent Ledger & Attention Points      │
  │  .asl/mem/roadmap.asn    - Master Phase Graph & Execution Waves         │
  │  .asl/mem/tasks/backlog.asn - Global Backlog Pool (Priority, Timestamps) │
  │  .asl/mem/tasks/phase_*.asn - Active Phase DAGs (Failing Gates, :owns)  │
  │  .asl/mem/decisions/     - Immutable Architecture Decision Records (ADRs)│
  │  .asl/mem/receipts.asn   - Physical Verification Receipts & Metrics     │
  │                  (Not Ignored by Default • Git Version-Controlled)      │
  └────────────────────────────────────┬────────────────────────────────────┘
                                       │ Session Claim & Handoff
                                       │ Verification Proof Settlement
  ┌────────────────────────────────────┴────────────────────────────────────┐
  │        TIER 2: EPHEMERAL LOCAL AGENT SESSIONS (ISOLATED WORKSPACES)     │
  │                                                                         │
  │  .asl/mem/sessions/<session-id>/                                        │
  │    ├── session-lease.asn  - Agent Identity, Lease Expiration, Heartbeat │
  │    ├── queue-state.asn    - Queue Position, :created-at, :queued-at     │
  │    ├── action-dag.asn     - Dynamic Local Subtasks & Step Index         │
  │    └── transient/         - Staged AST Buffers & Scratch Checkpoints    │
  │                                                                         │
  │  (Git-Ignored by Default • Automated Lifecycle Purge Upon Settlement)   │
  └─────────────────────────────────────────────────────────────────────────┘
```

### 5.1 Tier 1: Global Git-Tracked Backlog & Ledgers (Single Source of Truth)

All structural decisions, strategic intents, phase roadmaps, and verification proofs belong to the global repository state and are version-controlled under git (`git log`):
1. **The Global Intent Ledger (`.asl/mem/intent.asn`)**:
   - Documents high-level goals, system-wide attention points, and architectural intents.
   - Agents bind directly to declared intent IDs (`:intent-id`), eliminating redundant, multi-paragraph prompt descriptions and preventing intent drift across sessions.
2. **Roadmap & Phase Execution DAG (`.asl/mem/roadmap.asn`)**:
   - Catalogues topological execution waves and phase dependencies with non-empty, falsifiable gate invariants.
3. **The Global Candidate Backlog (`.asl/mem/tasks/backlog.asn`)**:
   - Holds unscheduled work items, future candidates, and parked ideas.
   - Every candidate captures standardized metadata: `:created-at` (epoch milliseconds), `:queue-position`, `:lane`, `:priority`, and `:trigger :on-demand`.
   - Strictly on-demand; zero recurring or unmonitored background jobs.
4. **Phase Task Collections (`.asl/mem/tasks/phase_XXX.asn`)**:
   - Active work items adhering to the **Enriched Task Context Standard (`D52`)**: `:motivation`, `:purpose`, `:context`, `:outcomes`, `:owns` file boundaries, `:gate`, `:invariants`, `:variations`, and `:failure-modes`.
   - Declares bidirectional links to governing ADRs (`:adr`, `:decision`).
5. **Architectural Decision Records (`.asl/mem/decisions/`)**:
   - Immutable records of architectural choices, trade-offs, and invariants, maintaining bidirectional links to implementing tasks (`:tasks [...]`).
6. **Physical Verification Receipts (`.asl/mem/receipts.asn`)**:
   - Cryptographic and physical execution proofs recording non-vacuous assertion counts, exit codes, and test telemetry under `--strict-falsify`.
7. **Default Git Tracking Policy for Global State**:
   - In the local repository topology, Tier 1 ledgers and task records are **not ignored by default** (`.gitignore`). Git history serves as the authoritative, tamper-evident timeline of architectural intent, decisions, and verifiable delivery.

### 5.2 Tier 2: Ephemeral Local Agent Sessions & Automated Cleanup

To enable seamless multi-agent concurrency without file contention or repository clutter, transient agent execution state and local logs are strictly quarantined:
1. **Local Logs & Session Workspaces (Git-Ignored by Default)**:
   - All ephemeral agent session directories (`.asl/mem/sessions/`), local runtime logs (`.asl/log/`), and scratch buffers are **git-ignored by default** in `.gitignore`. This guarantees that transient agent operations, local subtasks, and intermediate trace churn never pollute the shared git tree.
2. **Multi-Agent Session Isolation & Leases**:
   - Multiple agents (internal workers, Claude Code, Cursor, Factory Droid) operating in the same workspace claim dedicated session directories (`.asl/mem/sessions/<session-id>/`).
   - Each session is bounded by an active lease (`:session-id`, `:lease-expires-at`, `:owner-role`) with heartbeat tracking, preventing write collisions and enabling deterministic crash recovery.
3. **Enriched Queue & Lifecycle Metadata**:
   - Tasks carry precise lifecycle timing:
     - `:created-at`: Epoch timestamp (in ms) when the task was first formulated.
     - `:queued-at`: Epoch timestamp when scheduled in the active execution queue.
     - `:started-at` / `:completed-at`: Wall-clock execution interval.
     - `:queue-position`: Deterministic integer order within the phase DAG or session queue.
     - `:lease-expires-at`: Time-bounded lease preventing abandoned task deadlocks.
4. **Local Ephemeral Action Buffers**:
   - Fine-grained subtasks, step-by-step queues (`:action-dag`, `:step-index`), AST point-edit staging buffers, and in-flight handoff contexts (`handoff-context`) reside strictly inside the local session folder.
5. **Automated Lifecycle Cleanup & Recycling Protocol**:
   - Ephemeral action files remain in Tier 2 storage only while actively being executed.
   - Upon task completion and settlement (`asl task settle`), permanent code modifications are committed to git and a verifiable `TaskReceipt` is appended to the global ledger.
   - All transient action files, scratch buffers, and completed/abandoned session directories are automatically purged and recycled.
   - The git repository remains clean and stable: 100% of committed history represents deliberate code changes and verification proofs, with zero transient scratch noise.

### 5.3 System-Wide Observability & Metric Tracking

Human and machine oversight is maintained continuously through global telemetry tracked under version control:
1. **Global Attention Points**: Strategic focus areas documented in `intent.asn` steer agent swarms without repetitive context overhead.
2. **Token Efficiency & Attention Physics Telemetry**: Continuous measurement of lexical density (SNR $\ge 0.75$), 1-to-2 token primitives, CamelCase savings (20–50% compaction), and shortcode conventions (`C1`..`C5`, `D1`..`D53`).
3. **Holistic Consistency Auditing (`D52`)**: The self-hosted consistency engine (`asl audit consistency`) deterministically audits 5 dimensions: ADR-task bidirectional linkage, complete task context, intent ledger coherence, roadmap phase graph integrity, and delimiter balance.
4. **Falsifiable Verification Dashboards**: Real-time 7-gate verification (`asl gate`), auditing package manifests, pure ASL syntax, benchmark grounding, zero-foreign code purity, 100% test pass receipts, and skill freshness.

### 5.4 Storage Topologies: Local Repository vs. Remote Backends & Task-Tracker Integration

The storage and ignore rules codified above specify the **local repository storage topology**, where the file tree itself serves as both codebase and memory substrate. When engineering environments integrate remote repositories or external task-tracking systems, the architectural responsibilities adapt accordingly:

1. **Local Repository Topology (File-Backed Sovereignty)**:
   - In offline, local, or single-repo environments, Git acts as the unified storage engine.
   - Global ledgers (`.asl/mem/tasks/`, `intent.asn`, `roadmap.asn`, `receipts.asn`) are **not ignored by default**, ensuring version-controlled transparency and auditability across all contributors.
   - Local agent sessions (`.asl/mem/sessions/`) and ephemeral action logs are **git-ignored by default**, preventing local multi-agent concurrency churn from polluting the commit history.
2. **Remote Repositories & External Task-Tracker Integrations (Jira, GitHub Issues, Linear, Cloud DB)**:
   - When project management, backlog pools, and task state are integrated with remote task trackers or external cloud backends, storage lifecycle rules are **implemented on the storage/backend side**.
   - Concurrency locking, queue position arbitration, retention policies, TTL expiration, and session lease management are handled by the remote tracker or database service rather than local filesystem conventions.
   - In this topology, the local workspace maintains minimal, lightweight linkages (e.g. external ticket references `:tracker-id "ISSUE-104"`, webhook sync hooks, or immutable verification receipts) rather than duplicating full remote state locally.
   - The boundary remains clean: local storage rules govern file-backed workflows; remote storage rules govern distributed tracker integrations.

---

## 6. The New Division of Labor

| Aspect | Human Role | LLM Agent Role |
|---|---|---|
| **Primary Medium** | Architecture diagrams, ADRs, intent contracts, metrics | Pure AgentScript (ASL), ASN ASTs, batch RPC transactions |
| **Focus** | "Why" and "What" (goals, invariants, security policies) | "How" (implementation, algorithms, refactoring, execution) |
| **Inspection Mode** | Structural topologies, gate outputs, benchmark graphs | In-memory diffs, symbol graphs, call hierarchies, AST outlines |
| **Trust Model** | Verification of falsifiable proofs and 7-gate audits | Automated generation of reproducible, passing test suites |
| **Cognitive Load** | High-level system strategy and product design | Exact syntax, token economy, edge-case coverage |
| **Epistemic Discipline** | Invariant specification, negative bounds, architectural review | Discrete Action DAG steps (`GroundFact`, `ContextBudget`, `AdversarialReflect`, `ReconcileReality`) |
| **Skill Ecosystem** | Strategic skill definition, protocol governance | Autonomous skill execution via projected micro-protocols (`SKILL.md`) and batch RPC |
| **Task & State Ledgers** | Global intent steering (`intent.asn`), roadmap oversight (`roadmap.asn`) | Ephemeral session execution (`sessions/<id>/`), deterministic cleanup, and verifiable `TaskReceipt` settlement |

---

## 7. Summary Declaration

The premise that programming languages must cater to human visual ergonomics at the expense of artificial intelligence efficiency is fundamentally obsolete. 

By establishing **languages, instructions, wire protocols, and execution environments designed natively for LLMs**, models operate with maximum cognitive density, mathematical precision, and deterministic safety. 

By enforcing **teleological responsibility, discrete epistemic action steps, and strict negative invariants**, agent behavior is bounded against surrogate gaming, hallucinations, and context decay.

Through the **Third-Party Skill Projection Ecosystem**, external frontier models seamlessly leverage sovereign batch RPC tools with zero context bloat.

And by anchoring all engineering in the **Dual-Tier Task Ledger**, persistent architectural truth remains immutably versioned under git while multi-agent execution churn is cleanly quarantined and recycled.

Simultaneously, by projecting **high-level architectural clarity, rigorous contracts, and verifiable proofs to humans**, human engineering transitions from tedious line-by-line code parsing to authoritative system architecture, invariant specification, and empirical governance.

