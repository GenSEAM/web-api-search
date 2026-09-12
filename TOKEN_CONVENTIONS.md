# AgentScript Token Efficiency Conventions & Standards

This document establishes the canonical **Token Efficiency Format** for the AgentScript monorepo. It governs naming conventions, marker formats, grammar registry schemas, and token density optimizations across all packages, tools, and autonomous agent executions.

---

## 1. Epistemic Background & Tokenizer Research

### 1.1 The BPE Hyphenation Penalty
Modern Large Language Models (Claude, GPT-4, Gemini) process source code through Byte-Pair Encoding (BPE) or WordPiece/SentencePiece tokenizers (such as `cl100k_base` and `o200k_base`). In these tokenizers:
- Hyphens (`-`) are treated as distinct punctuation tokens.
- A multi-word identifier written in kebab-case—such as `test-doctor-detect-missing-dependency`—is segmented into **9 separate BPE tokens**:
  `['test', '-', 'doctor', '-', 'detect', '-', 'missing', '-', 'dependency']`
- When written in CamelCase—`TestDoctorDetectMissingDependency`—the capitalization boundaries allow subwords to merge with common stems into existing vocabulary entries, yielding **5 BPE tokens** (**-44.4% token reduction**).

Across 888 files in the corpus (1,512,691 total tokens measured under `cl100k` on 2026-09-12):
- **Per long identifier (>2 words)**: CamelCase achieves **44 to 50 percent** token reduction (e.g. 50.0% on `TestAstMutationDeletedAssertionBlocked` and 44.4% on `TestDoctorDetectMissingDependency`).
- **Corpus-wide**: Converting all hyphenated identifiers saves 46,259 tokens (**3.06 percent** corpus-wide saving), because most identifiers are one or two words and 41.8% of tokens are string literals unreachable by naming conventions.
- Across grammar registries alone (33 `grammar.asn` files, 3,714 exported symbols), 2,819 dashed symbols consume 12,105 tokens; CamelCase compresses them into 10,495 tokens (1,610 token savings / 13.3%).

### 1.2 The S-Expression Context Bias
When autonomous agents generate AgentScript (`.asl`) or ASN (`.asn`), the prompt context (parentheses, homoiconic S-expressions, prefix notation) activates their historical training prior on classical Lisps (Scheme, Common Lisp, Clojure), where kebab-case is universal.

**Empirical Invariant**:
> **Agents DO NOT naturally choose CamelCase in S-expressions without explicit contractual guidance.**
> To achieve optimal token density, agents must be explicitly guided by canonical examples, clear scope boundaries, and automated audit gates.

---

## 2. The Four Pillars of Token Efficiency

```
+---------------------------------------------------------------------------------------+
|                               FOUR PILLARS OF TOKEN EFFICIENCY                        |
+---------------------------------------------------------------------------------------+
|  I. Capital Alphanumeric Markers      |  II. PascalCase Composite Constructs          |
|  D1..D56, C1..C5, L1..L10, R1..R10    |  Types, Structs, Test Suites, Phase Nodes     |
|  -75% token reduction per reference   |  44% to 50% per id (3.06% corpus-wide)        |
+---------------------------------------+-----------------------------------------------+
|  III. Universal Zero-Kebab Standard   |  IV. Dual-Tier Rationality Annotations        |
|  :camelCase Properties & Functions    |  :rationality :absolute | :contextSpecific    |
|  Zero hyphens in identifiers monorepo |  Full epistemic justification in grammar.asn  |
+---------------------------------------------------------------------------------------+
```

### Pillar I: Capital Alphanumeric Markers & Shortcodes (`C4`, `D46`, `D51`)
Markers reference immutable invariants, architectural decisions, deferred tracks, and tasks. They MUST use bare capital alphanumeric symbols without colons, hyphens, or zero-padding.

- **Invariants**: `C1`, `C2`, `C3`, `C4`, `C5`
- **Decisions**: `D1`, `D2`, ..., `D50`, `D51`, `D56`, `D57`
- **Backlog Tracks**: `L1`, `L2`, ..., `L10`
- **Requirements**: `R1`, `R2`, ..., `R10`
- **Tasks**: `T1`, `T2`, ..., `T412Audit`

| Context | Legacy (Dash-Zero) | Modern (Alphanumeric) | Token Delta |
| :--- | :--- | :--- | :--- |
| Invariant Citation | `C0001`, `C0003` | `C1`, `C3` | 4 tokens -> 1 token (**-75%**) |
| Decision Reference | `D0034`, `D0046` | `D34`, `D46` | 4 tokens -> 1 token (**-75%**) |
| Task Property | `(:invariants [C0001 C0002])` | `(:invariants [C1 C2])` | 8 tokens -> 2 tokens (**-75%**) |

### Pillar II: PascalCase for Composite Constructs & Types (`D51`)
When an identifier defines a **type, struct, typestate, phase, or test suite**, PascalCase MUST be used to eliminate punctuation splitting (achieving 44 to 50 percent token reduction per long identifier, and 3.06 percent corpus-wide across 888 files under cl100k):

- **Structs and Types**: `VoiceFrame`, `AuditTokenEfficiency`, `ASTToken`, `CrawlResult`, `TaskRecord`
- **Test Suites**: `TestAstMutationDeletedAssertionBlocked`, `TestDoctorDetectMissingDependency`
- **Phase Collections**: `Phase412HolisticAuditAndCamelCaseOptimization`, `Phase429VoiceMesh`

### Pillar III: Universal Zero-Kebab Invariant & camelCase Properties (`D56`)
Hyphens (`-`) are strictly forbidden across all identifiers, properties, and symbols monorepo-wide.
Modern BPE tokenizers incur dedicated punctuation penalties on every hyphen delimiter.
1. **Property Keys in ASN & S-Expressions**: MUST use `:camelCase`:
   - `:dependsOn`, `:actionDag`, `:sessionId`, `:ownerRole`, `:createdAt`, `:queuedAt`, `:updatedAt`, `:startedAt`, `:completedAt`
   - `:targetSymbols`, `:relatedSymbols`, `:failureModes`, `:additionalRequirements`, `:acceptanceCriteria`, `:stepIndex`
2. **Functions, Verbs, and Primitives**: MUST use `camelCase`:
   - `isEmpty`, `assocIn`, `parseAst`, `txt.starts`, `vfs.norm`, `vfs.read`, `vfs.write`

```asn
;; ANTIPATTERN (Hybrid / Legacy kebab-case: 18 tokens)
(:task
  :depends-on ["T1"]
  :action-dag ["Scan AST"]
  :session-id "sess-1")

;; CANONICAL (Zero-Kebab Universal Standard: 13 tokens, -28% savings)
(:task
  :dependsOn ["T1"]
  :actionDag ["Scan AST"]
  :sessionId "sess-1")
```

### Pillar IV: Dual-Tier Rationality Annotations in Grammar Registries (`D51`)
Every exported symbol with more than 2 BPE tokens declared in `grammar.asn` MUST carry an explicit `:rationale` and be classified with fine-grained rationality flags:

1. **Absolute Rationality (`:rationality :absolute`, `:contextDependent false`)**:
   Universal algorithms, standard RFC/POSIX codecs, mathematical operations, or fundamental data structures that exist independently of specific subsystems.
   - Examples: `decodeHtmlEntities`, `escapeShArg`, `vectorCosineSimilarity`

2. **Context-Specific Rationality (`:rationality :contextSpecific`, `:contextDependent true`)**:
   Symbols tied to a particular domain, benchmark harness, heuristic pipeline, or canary suite.
   - Examples: `formatClauseBreadcrumb`, `superHardCalibrationTasks`, `fullSpectrumCanaryTasks`

```asn
;; Canonical grammar.asn Entry Example
(:sym "ValidateJsonPayloadFormat"
  :tokens 4
  :rationality :absolute
  :contextDependent false
  :rationale "Universal RFC-8259 JSON payload validator and schema validator")
```

---

## 3. Duplicate Prevention & Namespace Isolation

1. **Zero Internal Duplicates**: A symbol name MUST NOT be declared more than once within the same package's `grammar.asn`.
2. **Harmonized Cross-Package Definitions**: Where symbols with identical names exist across multiple packages (e.g., `run-tests`, `make-message`), their definitions MUST carry matching, verified rationales to prevent semantic drift.
3. **Foundation Centralization (`D34`, `C3`)**: Universal utilities (string escaping, delimiter balancing, path normalization) MUST reside in foundational packages (`asl-text`, `asl-parser`, `mem/vfs`). Private duplicate helpers across packages are strictly forbidden.

---

## 4. Verification & Diagnostic Toolchain

The monorepo provides self-hosted CLI commands to audit efficiency and consistency deterministically:

```bash
# 1. Run consistency audit across memory and tasks
asl audit consistency

# 2. Run pure ASL verification gates
asl audit gates

# 3. Run unit tests
asl test

# 4. Run full 7-tier verification gate (includes token density check)
asl gate
```

---

### Pillar V: Semantic Subwords & Subword-Aligned Identifiers (`D57`)
Punctuation delimiters (`-`, `/`, `:`) force pretrained LLM BPE tokenizers to allocate dedicated tokens purely for the delimiter. Furthermore, uninformative numeric suffixes (`T412-1`, `task-400-01`) waste tokens and provide zero functional information to the model attention mechanism in dependency arrays (`:dependsOn`).

#### Rules for Semantic Subwords:
1. **Subtask Identifiers**: Subtasks MUST append a capitalized, single-token **Semantic Morpheme** instead of a numeric dash:
   - *Antipattern* (4 tokens): `T412-1`, `T412-2`, `T412-3`
   - *Canonical* (3 tokens, 100% functional grounding): `T412Audit`, `T412Codec`, `T412Sagas`
2. **Canonical 30-Morpheme Vocabulary**:
   - *Actions*: `Audit`, `Check`, `Scan`, `Parse`, `Build`, `Diff`, `Patch`, `Flush`, `Test`, `Settle`
   - *Lifecycle*: `Init`, `Fork`, `Merge`, `Abort`, `Commit`, `Spawn`, `Prune`, `Clean`, `Lock`, `Lease`
   - *Entities*: `Sagas`, `Vfs`, `Tree`, `Node`, `Edge`, `Fact`, `Rule`, `Gate`, `Task`, `Lens`

---

## 5. Progressive Disclosure Architecture

To prevent context bloat, agents encounter token efficiency guidance across standard layered channels:

1. **Mandatory Execution Contract (`AGENTS.md` / `CLAUDE.md`)**:
   Summary rules on lexical density, capital markers, and CamelCase conventions.
2. **Authoritative Decision Record (`.asl/mem/decisions/ADR-0051-...asn`)**:
   Immutable rationale, decision drivers, and invariants registered in `decisions.asn` and `intent.asn`.
3. **Comprehensive Manual (`TOKEN_CONVENTIONS.md`)**:
   The full reference specification (this document).
4. **On-Demand Agent Skills (`asl/.agents/skills/`)**:
   Practical micro-protocols for `asl-toolbelt`, `asl-plan`, and `asl-native`.
5. **Deterministic Gates (`asl audit gates` / `asl gate`)**:
   Automated enforcement verifying 100% compliance before merge.

---

## 6. The Four Forces & Grammatical Authority (`ADR-0081`)

To prevent defeasible heuristics from being treated with the same perceived authority as non-negotiable correctness conditions, rules in `asl/grammar/rules.asn` declare an explicit grammatical force (`:force`):

1. **Invariant (`:force :invariant`)**:
   Defines what makes work invalid. Bounded to $\le 7$ rules. Every invariant MUST declare a falsifiable verification gate (`:gate`) pointing to an executable check. Invariants are never dropped under context pressure.
2. **Orientation (`:force :orientation`)**:
   Explains how to read a situation, evaluate posture, and resolve high-entropy dead ends. Orientations MUST NOT carry compliance tests or assertion gates.
3. **Affordance (`:force :affordance`)**:
   States what can actually be done and which tools are operational in the environment.
4. **Heuristic (`:force :heuristic`)**:
   Defines practices that usually work. Every heuristic MUST declare its explicit defeat condition (`:defeat`) naming when the rule does not apply.

---

## 7. One Name per Concept (`Task45901`, `ADR-0081`)

To guarantee language predictability and eliminate memory overhead across autonomous agents and language models, the repository enforces strictly **one canonical name per concept** recorded in `asl/grammar/language-semantics.asn`:

1. **Predicates (`predicateNaming`)**:
   - A predicate MUST end in a question mark (`?`) and MUST NEVER begin with `is-` or `is`.
   - **Sanctioned Form**: `empty?`, `fresh?`, `valid?`, `alive?`.
   - **Retired Forms**: `is-empty`, `is-empty?`, `is-fresh?`, `is-valid?` (`ERR_RETIRED_PREDICATE_FORM`).
2. **Constructors (`constructorNaming`)**:
   - A constructor MUST begin with `make-` followed by the target type or construct name.
   - **Sanctioned Form**: `make-node`, `make-symbol-entry`, `make-frame`.
   - **Retired Forms**: `create-node`, `build-node`, `new-node` (`ERR_RETIRED_CONSTRUCTOR_FORM`).
3. **Conversions (`conversionNaming`)**:
   - A type conversion MUST strictly follow the `source-to-target` pattern.
   - **Sanctioned Form**: `int-to-string`, `json-to-vdom`, `asn-to-svg`.
   - **Retired Forms**: `string-from-int`, `to-string`, `as-string` (`ERR_RETIRED_CONVERSION_FORM`).

---

## 8. Symbol Surface Tracking & Ratchet Policy (`Task45905`, `ADR-0081`)

To govern language complexity and model predictability beyond superficial token counts, the repository tracks **distinct symbol surface** as a primary quantity:

1. **Empirical Baseline**:
   - 17112 (17,112) distinct symbols appear in head position across 1,512,691 corpus tokens (approximately 1 distinct symbol per 88.4 tokens).
   - In low-resource language representations, distinct symbol surface and the distance between identifier bindings and their uses govern attention degradation and syntax hallucination.
2. **The Trade Rule**:
   - Distinct symbol surface is evaluated alongside token count in every language proposal.
   - Any proposed change that saves tokens while increasing distinct symbol surface, or while increasing distance between a binding and its uses, is **rejected by default** unless accompanied by empirical evidence demonstrating that model accuracy does not degrade (`ERR_SURFACE_EXPANSION_WITHOUT_EVIDENCE`).
3. **Symbol Surface Ratchet**:
   - Adding synonyms, alternative spellings, or duplicate names for existing primitives expands the distinct symbol surface and fails the ratchet check (`ERR_SYMBOL_SURFACE_RATCHET_VIOLATION`).
4. **Dual Quantity Inventory**:
   - Language telemetry inventories must report both total token count and distinct head symbol surface in a single run (`ERR_MISSING_DUAL_INVENTORY`).

---

## 9. Lexicon Selection Rule: Measured Cost Decides (`Task46201`, `ADR-0081`)

One selection rule governs every identifier and keyword in the language and grammar:

1. **Measured Minimum Token Count**:
   - Among candidate names that carry the intended meaning, take the measured token count under the production tokenizer (cl100k).
   - At equal cost, take the form with the stronger presence in ordinary code, because the model's prior was built from it.
2. **Excluded Criteria**:
   - **Length is not a criterion**: shorter character strings often tokenize into more BPE tokens. For example, `define` costs 1 token while `df` costs 1 token; devowelling 16 common words increased token cost from 16 to 33 tokens (+106%).
   - **Uniformity of a family is not a criterion**: a single-token form that cannot be extended into a family is accepted as it stands. For example, `try` is 1 token while uniform `with-handlers` is 3 tokens. Raising cost to satisfy family uniformity is strictly rejected (`ERR_SPECULATIVE_NAME_CHOICE`).
   - A non-extensible single-token form is accepted without compromise.

---

## 9. Measured Token Cost Selection Rule (`Task46201`, `ADR-0081`)

Every identifier in the language and grammar registries is governed by measured token count under cl100k:

1. **The Selection Rule**:
   - Among candidate identifiers that carry the intended meaning, choose the one with the minimum measured token count under the canonical tokenizer (cl100k).
   - At equal token cost, choose the form with the stronger pre-existing representation in standard code corpora, matching model training priors.
2. **Excluded Criteria**:
   - Length is not a criterion: Character count does not correlate with token cost, and devowelling or truncation frequently doubles token costs.
   - Uniformity of a family is not a criterion: Syntactic families do not require artificial lexical consistency if uniformity increases token counts. A single-token form that does not extend into a family is accepted as it stands.
3. **Closed Refuted Intuitions**:
   - Shorter is cheaper (refuted: devowelling 16 words increased cost from 16 to 33 tokens, a 106% rise).
   - Families must look uniform (refuted: raises cost without syntactic benefit).
   - Single-token forms must generalize (refuted: non-extensible single-token forms are accepted as is).
   - Deleting delimiters from existing formatting appears to save 13.6% but yields an unparseable tree; indentation-significant rendering raises token costs by 7.7%.
   - **Surviving Structural Law**: Explicit delimiters are the token-optimal structural encoding at this corpus depth; S-expressions are retained without compromise.



## 10. Refuted Structural Compaction Rewrites (`Task46305`, `ADR-0081`)

Three intuitive structural rewrites were empirically evaluated on the corpus (888 files, 1,512,691 tokens under cl100k) and all three failed:

1. **Devowelling**:
   - Compaction hypothesis: dropping vowels shortens tokens.
   - Empirical finding: devowelling 16 common words increased token cost from 16 to 33 tokens (+106%).
2. **Delimiter Deletion**:
   - Compaction hypothesis: deleting delimiters from existing formatting appears to save 13.6%.
   - Empirical finding: delimiter deletion leaves syntax unparseable, destroying tree balance and structural verification.
3. **Indentation-Significant Rendering**:
   - Compaction hypothesis: Python/YAML style significant indentation eliminates closing delimiters.
   - Empirical finding: indentation-significant rendering costs 7.7% more tokens, because every level pays a newline and an indent token, whereas paren runs merge into single tokens.
4. **Surviving Conclusion**:
   - Explicit delimiters with balanced S-expressions are the token-optimal structural encoding at this corpus depth. The language retains explicit delimiters throughout.
   - Reopening any refuted rewrite requires reproducible measured evidence on the current tree rather than opinion or argument.

