# Phase 505 Plan: Stdlib & Extensions Remediation

## Executive Summary & Metadata
- **Phase ID**: `Phase505StdlibAndExtensionsRemediation`
- **Shortcode**: `Phase 505`
- **Architecture Mandates**: `D81` (Canonical Shortcodes), `D77` (Dual-Polarity Verification), `D34` / `C3` (Boundary Universalism), `C5` (Zero Sigils)
- **Status**: `planned`
- **Priority**: `critical`
- **Deciders**: `["user" "architect" "planner" "implementer" "auditor"]`
- **Invariants Enforced**: `C1` (0 comments), `C2` (0 emojis), `C3` / `D34` (Boundary Universalism), `C5` (Zero Sigils), `D51` (CamelCase identifiers), `D77` (Dual-Polarity Verification & 0 vacuous tests), `D81` (Canonical Shortcode formatting).
- **Core Scope**: Remediation of all REJECT findings from the Scope 5 Gap/Falsification Audit across standard library and extension packages (`asl-sh`, `asl-sql`, `asl-text`, `asl-registry`, `asl-plugin`):
  1. `asl/packages/asl-text/src/emoji_guard.asl:36` incorrect line number computation.
  2. `asl/packages/asl-sql/src/core/ddl.asl` dialect abstraction breakdown (`is-pg Bool` reduction).
  3. Package manifests out of sync (`asl-sh/manifest.asn`, `asl-plugin/manifest.asn`).
  4. Orphaned grammar symbols (`estimateTokens` / `estimate-tokens`).
  5. Missing exports in grammar (`UnescapeState`, DDL constructors, dialect query helpers).
  6. Remaining `@pcp:d-446d` sigils across `asl-sh`.
  7. Elimination of 69 `(assert (not ...))` forms across ALL 23 test suites via conversion to first-class `(refute ...)`.

---

## 1. Problem Statement & Audit Findings

The Scope 5 Gap and Falsification Audit revealed 7 concrete structural, syntactic, and testing defects across standard library and extension packages:
1. **Emoji Guard Line Number Desynchronization**: In `asl/packages/asl-text/src/emoji_guard.asl:36`, line numbers are computed via `(+ (list-length acc) 1)`. `acc` is the list of previously accumulated violations, not the line index. In files where violations occur on non-consecutive or non-initial lines, the reported line numbers are corrupt.
2. **SQL DDL Dialect Degeneration**: In `asl/packages/asl-sql/src/core/ddl.asl`, the 4-dialect enum (`SqlDialect`: `sqlite`, `postgres`, `mysql`, `clickhouse`) is collapsed into an `(isPg Bool)` boolean flag. In dynamic ASL evaluation, passing `(sql/sqlite)` evaluates as truthy, falsely formatting SQLite definitions using PostgreSQL keywords (`DOUBLE PRECISION`, `$1`).
3. **Manifest and Module Declaration Drift**: In `asl/packages/asl-plugin/manifest.asn`, `:modules` specifies `"asl-plugin/dynamic_tool"` instead of canonical camelCase `"asl-plugin/dynamicTool"`, and omits dependency `"asl-text"`. In `asl/packages/asl-sh/manifest.asn`, `:modules` references non-existent `"asl-sh/core"`, uses kebab-case names, omits 6 public modules, and omits dependency `"asl-text"`.
4. **Orphaned Grammar Symbols**: `asl/packages/asl-sh/grammar.asn:55` and `asl/packages/asl-plugin/grammar.asn:40` declare `(:sym :name "estimateTokens" :kind :fn :tokens 2)`. Neither package implements `estimateTokens`; both import it from `asl-text/text`.
5. **Missing Grammar Export Registrations**: Legitimate exported symbols are missing from package grammar registries, including `UnescapeState` in `asl-text`, DDL typed constructors (`colInt64`, `colFloat64`, etc.) and dialect parameter helpers in `asl-sql`, and GitHub/process helpers in `asl-sh`.
6. **Banned Sigil Formats**: Five occurrences of `@pcp:d-446d` remain in `asl/packages/asl-sh` source, documentation, and tests, violating Invariant C5 and D81 canonical bare shortcode rules.
7. **Test Polarity Deficit (0 Refute Forms)**: Across all 23 test suites in `asl-sh`, `asl-sql`, `asl-text`, `asl-registry`, and `asl-plugin`, there are exactly 0 `(refute ...)` forms and 69 `(assert (not ...))` constructs. Under D77 and Gate 5, negative assertion semantics must be expressed via first-class `(refute ...)` to prevent double-wrapping and ensure unambiguous failure diagnostics.

---

## 2. Attention Separation Architecture

Phase 505 distributes remediation across 3 Attention Planes:

```
+─────────────────────────────────────────────────────────────────────────────────────────────+
|                                    ATTENTION SEPARATION                                     |
+─────────────────────────────────────────────────────────────────────────────────────────────+
|  PLANE 1: ISOLATED RUNTIME & SCHEMA FIXES (ZERO CROSS-PACKAGE COUPLING)                     |
|  • Independent modules (emojiGuard, DDL, manifests, sigils) repaired within own bounds.     |
|  • No inter-module edits or global mutations in Wave 1.                                     |
+─────────────────────────────────────────────────────────────────────────────────────────────+
|  PLANE 2: GRAMMAR REGISTRY PURITY & SYMBOL ALIGNMENT                                        |
|  • Orphaned symbols purged and missing public exports registered.                           |
|  • Symbol token density (:tokens <= 2 or explicit :rationale) enforced per Gate 6.          |
+─────────────────────────────────────────────────────────────────────────────────────────────+
|  PLANE 3: DUAL-POLARITY REFUTATION SWEEP ACROSS 23 TEST SUITES                             |
|  • 69 (assert (not ...)) invocations converted to native (refute ...) forms.                |
|  • Executed after implementation fixes to avoid write conflicts on test files.              |
+─────────────────────────────────────────────────────────────────────────────────────────────+
```

---

## 3. Work Item DAG & Clustered Execution Waves

```mermaid
graph TD
    subgraph Wave 1: Core Runtime, Schemas & Sigils
        T50501["Task 50501: asl-text Emoji Guard Line Index Fix"]
        T50502["Task 50502: asl-sql DDL Dialect Abstraction Restoration"]
        T50503["Task 50503: asl-sh & asl-plugin Manifest Resynchronization"]
        T50504["Task 50504: Orphaned Grammar Symbol Purge"]
        T50506["Task 50506: Sigil Hygiene: Eradicate @pcp:d-446d in asl-sh"]
    end

    subgraph Wave 2: Grammar Export Completion
        T50505["Task 50505: Grammar Symbol Registration for UnescapeState & Exports"]
    end

    subgraph Wave 3: Test Polarity & Refutation Migration
        T50507["Task 50507: Convert 69 (assert (not ...)) to (refute ...) across 23 Test Suites"]
    end

    T50504 --> T50505
    T50501 --> T50507
    T50502 --> T50507
    T50503 --> T50507
    T50505 --> T50507
    T50506 --> T50507
```

---

## 4. Ordered Work Items

### Task 50501: Fix `asl-text` Emoji Guard Line Number Computation
- **What changes, by path**:
  - `asl/packages/asl-text/src/emoji_guard.asl`
  - `asl/packages/asl-text/tests/emoji_guard_test.asl`
  - `tests/acceptance/d81/Task50501.asl`
- **Why**:
  In `asl/packages/asl-text/src/emoji_guard.asl:35-41`, `scanFileEmoji` calculates line numbers as `(+ (list-length acc) 1)`. When non-initial or spaced lines have emojis, the violation's `:lineNum` reflects the violation index rather than the 1-based source line index. This causes false line reporting in C2 emoji invariant audits.
- **Depends on**: none (Wave 1 unblocked)
- **Owns**:
  - `asl/packages/asl-text/src/emoji_guard.asl`
  - `asl/packages/asl-text/tests/emoji_guard_test.asl`
  - `tests/acceptance/d81/Task50501.asl`
- **Gate**:
  `! grep -q '(list-length acc)' asl/packages/asl-text/src/emoji_guard.asl && bin/asl test tests/acceptance/d81/Task50501.asl`
- **Current Gate Result (Fails Now)**:
  - `! grep -q '(list-length acc)' asl/packages/asl-text/src/emoji_guard.asl` exits with status 1 (pattern matches `(let [(idx (+ (list-length acc) 1))]` at line 36).
  - `bin/asl test tests/acceptance/d81/Task50501.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50501.asl`.
- **What breaks if run before prerequisite**:
  Nothing; isolated within `asl-text`.

---

### Task 50502: Fix `asl-sql` DDL Dialect Abstraction Breakdown (`is-pg Bool` Reduction)
- **What changes, by path**:
  - `asl/packages/asl-sql/src/core/ddl.asl`
  - `asl/packages/asl-sql/tests/ddl_test.asl`
  - `tests/acceptance/d81/Task50502.asl`
- **Why**:
  `asl/packages/asl-sql/src/core/ddl.asl` replaced multi-dialect AST rendering with binary `(isPg Bool)` flags across `typeToSqlString`, `renderColumnDef`, `renderPlaceholderItem`, `renderPlaceholders`, `renderUpsert`, `renderCreateTable`, and `renderInsert`. This breaks MySQL and SQLite emission (e.g. SQLite emits `DOUBLE PRECISION` and `$1` placeholders when passed `(sql/sqlite)`). The abstraction must take `(dialect SqlDialect)` and dispatch across all 4 canonical dialects (`postgres`, `sqlite`, `mysql`, `clickhouse`).
- **Depends on**: none (Wave 1 unblocked)
- **Owns**:
  - `asl/packages/asl-sql/src/core/ddl.asl`
  - `asl/packages/asl-sql/tests/ddl_test.asl`
  - `tests/acceptance/d81/Task50502.asl`
- **Gate**:
  `! grep -q 'isPg Bool' asl/packages/asl-sql/src/core/ddl.asl && bin/asl test tests/acceptance/d81/Task50502.asl`
- **Current Gate Result (Fails Now)**:
  - `! grep -q 'isPg Bool' asl/packages/asl-sql/src/core/ddl.asl` exits with status 1 (found 8 occurrences in `ddl.asl`).
  - `bin/asl test tests/acceptance/d81/Task50502.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50502.asl`.
- **What breaks if run before prerequisite**:
  Nothing; isolated within `asl-sql`.

---

### Task 50503: Resynchronize Package Manifests and Module Declarations
- **What changes, by path**:
  - `asl/packages/asl-sh/manifest.asn`
  - `asl/packages/asl-plugin/manifest.asn`
  - `tests/acceptance/d81/Task50503.asl`
- **Why**:
  `asl/packages/asl-plugin/manifest.asn` declares `"asl-plugin/dynamic_tool"` instead of `"asl-plugin/dynamicTool"` and omits dependency `"asl-text"`. `asl/packages/asl-sh/manifest.asn` lists non-existent `"asl-sh/core"`, uses kebab-case module identifiers, omits 6 existing modules (`ansi`, `diagnostics`, `log`, `pipe`, `process`, `coreProcess`), and omits dependency `"asl-text"`. Manifest drift breaks Gate 1 package resolution and dynamic module loaders.
- **Depends on**: none (Wave 1 unblocked)
- **Owns**:
  - `asl/packages/asl-sh/manifest.asn`
  - `asl/packages/asl-plugin/manifest.asn`
  - `tests/acceptance/d81/Task50503.asl`
- **Gate**:
  `grep -q '"asl-plugin/dynamicTool"' asl/packages/asl-plugin/manifest.asn && grep -q '"asl-text"' asl/packages/asl-plugin/manifest.asn && grep -q '"asl-sh/gitDiff"' asl/packages/asl-sh/manifest.asn && grep -q '"asl-text"' asl/packages/asl-sh/manifest.asn && ! grep -q '"asl-sh/core"' asl/packages/asl-sh/manifest.asn && bin/asl test tests/acceptance/d81/Task50503.asl`
- **Current Gate Result (Fails Now)**:
  - `grep -q '"asl-plugin/dynamicTool"' asl/packages/asl-plugin/manifest.asn` exits with status 1 (`dynamic_tool` currently listed).
  - `bin/asl test tests/acceptance/d81/Task50503.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50503.asl`.
- **What breaks if run before prerequisite**:
  Nothing; metadata files only.

---

### Task 50504: Purge Orphaned Grammar Symbols (`estimateTokens`)
- **What changes, by path**:
  - `asl/packages/asl-sh/grammar.asn`
  - `asl/packages/asl-plugin/grammar.asn`
  - `tests/acceptance/d81/Task50504.asl`
- **Why**:
  `asl/packages/asl-sh/grammar.asn:55` and `asl/packages/asl-plugin/grammar.asn:40` declare `(:sym :name "estimateTokens" :kind :fn :tokens 2)`. Neither package implements or exports `estimateTokens` in `src/`; both consume `estimateTokens` as foreign clients from `asl-text/text`. Declaring imported symbols as local grammar exports violates Gate 6 grammar integrity and token economics.
- **Depends on**: none (Wave 1 unblocked)
- **Owns**:
  - `asl/packages/asl-sh/grammar.asn` (purge `estimateTokens`)
  - `asl/packages/asl-plugin/grammar.asn` (purge `estimateTokens`)
  - `tests/acceptance/d81/Task50504.asl`
- **Gate**:
  `! grep -rn '"estimateTokens"' asl/packages/asl-sh/grammar.asn asl/packages/asl-plugin/grammar.asn && bin/asl test tests/acceptance/d81/Task50504.asl`
- **Current Gate Result (Fails Now)**:
  - Negated grep exits with status 1:
    ```
    asl/packages/asl-sh/grammar.asn:55:    (:sym :name "estimateTokens" :kind :fn :tokens 2)
    asl/packages/asl-plugin/grammar.asn:40:    (:sym :name "estimateTokens" :kind :fn :tokens 2)
    ```
  - `bin/asl test tests/acceptance/d81/Task50504.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50504.asl`.
- **What breaks if run before prerequisite**:
  Nothing.

---

### Task 50505: Register Missing Exported Symbols into Grammar Registries
- **What changes, by path**:
  - `asl/packages/asl-text/grammar.asn`
  - `asl/packages/asl-sql/grammar.asn`
  - `asl/packages/asl-sh/grammar.asn`
  - `tests/acceptance/d81/Task50505.asl`
- **Why**:
  Public exports defined in `src/` are omitted from `grammar.asn` files:
  1. `asl-text`: `UnescapeState` (exported by `escape.asl:3,5`).
  2. `asl-sql`: `colBool`, `colBoolean`, `colFloat64`, `colInt64`, `colText`, `colTimestamp` (exported by `ddl.asl:7`), and `collectJoinsParams`, `renderJoinsIndexed`, `renderWhereClauseIndexed` (exported by `sql.asl:8`).
  3. `asl-sh`: `githubCiFormat`, `githubCiParse`, `githubCiRollup`, `githubIssuesFormat`, `githubPrsFormat` (exported by `github.asl`), and `procList`, `procStatus` (exported by `process.asl`).
  Gate 6 requires all public exported symbols to be cataloged with verified token densities and rationales.
- **Depends on**: `Task50504` (shared edit on `asl/packages/asl-sh/grammar.asn`)
- **Owns**:
  - `asl/packages/asl-text/grammar.asn`
  - `asl/packages/asl-sql/grammar.asn`
  - `asl/packages/asl-sh/grammar.asn` (add missing exports)
  - `tests/acceptance/d81/Task50505.asl`
- **Gate**:
  `grep -q '"UnescapeState"' asl/packages/asl-text/grammar.asn && grep -q '"colInt64"' asl/packages/asl-sql/grammar.asn && grep -q '"procList"' asl/packages/asl-sh/grammar.asn && bin/asl test tests/acceptance/d81/Task50505.asl`
- **Current Gate Result (Fails Now)**:
  - `grep -q '"UnescapeState"' asl/packages/asl-text/grammar.asn` exits with status 1.
  - `bin/asl test tests/acceptance/d81/Task50505.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50505.asl`.
- **What breaks if run before prerequisite**:
  If run before Task 50504, concurrent edits to `asl/packages/asl-sh/grammar.asn` create grammar merge conflicts.

---

### Task 50506: Purge Prohibited `@pcp:d-446d` Sigils Across `asl-sh`
- **What changes, by path**:
  - `asl/packages/asl-sh/src/sh.asl`
  - `asl/packages/asl-sh/src/core/log.asl`
  - `asl/packages/asl-sh/src/core/pipe.asl`
  - `asl/packages/asl-sh/tests/sh_test.asl`
  - `asl/packages/asl-sh/README.md`
  - `tests/acceptance/d81/Task50506.asl`
- **Why**:
  Five occurrences of `@pcp:d-446d` remain in `asl-sh`. Invariant C5 and D81 mandate bare shortcodes (e.g. `d-446d` or `D81`). Sigil prefixes pollute symbol indexing and documentation references.
- **Depends on**: none (Wave 1 unblocked)
- **Owns**:
  - `asl/packages/asl-sh/src/sh.asl`
  - `asl/packages/asl-sh/src/core/log.asl`
  - `asl/packages/asl-sh/src/core/pipe.asl`
  - `asl/packages/asl-sh/tests/sh_test.asl`
  - `asl/packages/asl-sh/README.md`
  - `tests/acceptance/d81/Task50506.asl`
- **Gate**:
  `! grep -rn '@pcp:d-446d' asl/packages/asl-sh/ && bin/asl test tests/acceptance/d81/Task50506.asl`
- **Current Gate Result (Fails Now)**:
  - Negated grep exits with status 1:
    ```
    asl/packages/asl-sh/tests/sh_test.asl:2:  :d "Verification suite for AgentScript process automation and piping (@pcp:d-446d)."
    asl/packages/asl-sh/README.md:3:**Native AgentScript System & Process Automation Toolkit** (@pcp:d-446d).
    asl/packages/asl-sh/src/core/pipe.asl:2:  :d "Structured Shell Pipelines: Streaming stdout between processes without shell subshells (@pcp:d-446d)."
    asl/packages/asl-sh/src/core/log.asl:2:  :d "Structured Administrative Logging & Error Streams for Agent Scripts (@pcp:d-446d)."
    asl/packages/asl-sh/src/sh.asl:2:  :d "AgentScript Shell & Process Automation Engine: Subprocess execution, pipelines & logging (@pcp:d-446d)."
    ```
  - `bin/asl test tests/acceptance/d81/Task50506.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50506.asl`.
- **What breaks if run before prerequisite**:
  Must run before Task 50507 so that `tests/sh_test.asl` receives its sigil cleanup before the refutation conversion pass.

---

### Task 50507: Convert 69 `(assert (not ...))` Forms to First-Class `(refute ...)` Across ALL 23 Test Suites
- **What changes, by path**:
  - All 23 test suites across the 5 remediation packages:
    1. `asl/packages/asl-plugin/tests/dynamic_tool_test.asl` (4 occurrences)
    2. `asl/packages/asl-plugin/tests/plugin_test.asl` (2 occurrences)
    3. `asl/packages/asl-registry/tests/publish-test.asl` (0 occurrences, verified)
    4. `asl/packages/asl-registry/tests/registry_test.asl` (1 occurrence)
    5. `asl/packages/asl-sh/tests/apm_daemon_test.asl` (3 occurrences)
    6. `asl/packages/asl-sh/tests/apm_test.asl` (1 occurrence)
    7. `asl/packages/asl-sh/tests/batch_dag_test.asl` (7 occurrences)
    8. `asl/packages/asl-sh/tests/git_diff_test.asl` (0 occurrences, verified)
    9. `asl/packages/asl-sh/tests/git_search_test.asl` (4 occurrences)
    10. `asl/packages/asl-sh/tests/git_topo_test.asl` (4 occurrences)
    11. `asl/packages/asl-sh/tests/github_test.asl` (1 occurrence)
    12. `asl/packages/asl-sh/tests/process_test.asl` (0 occurrences, verified)
    13. `asl/packages/asl-sh/tests/reducer_test.asl` (1 occurrence)
    14. `asl/packages/asl-sh/tests/rpc_proc_test.asl` (0 occurrences, verified)
    15. `asl/packages/asl-sh/tests/session_test.asl` (0 occurrences, verified)
    16. `asl/packages/asl-sh/tests/sh_test.asl` (0 occurrences, verified)
    17. `asl/packages/asl-sh/tests/spool_test.asl` (5 occurrences)
    18. `asl/packages/asl-sql/tests/ddl_test.asl` (2 occurrences)
    19. `asl/packages/asl-sql/tests/sql_test.asl` (4 occurrences)
    20. `asl/packages/asl-text/tests/emoji_guard_test.asl` (7 occurrences)
    21. `asl/packages/asl-text/tests/escape_test.asl` (2 occurrences)
    22. `asl/packages/asl-text/tests/modular_aliases_test.asl` (6 occurrences)
    23. `asl/packages/asl-text/tests/text_test.asl` (6 occurrences)
  - `tests/acceptance/d81/Task50507.asl`
- **Why**:
  Across all 23 test suites, there are currently 0 instances of `(refute ...)` and 69 instances of `(assert (not ...))`. D77 and the Scope 5 Gap Audit require native first-class refutation forms rather than double-wrapped assertions. This makes tests falsifiable, provides cleaner diagnostic failure reports, and satisfies Gate 5 dual-polarity standards.
- **Depends on**: `Task50501`, `Task50502`, `Task50503`, `Task50504`, `Task50505`, `Task50506`
- **Owns**:
  - The 23 test files listed above
  - `tests/acceptance/d81/Task50507.asl`
- **Gate**:
  `test $(grep -rn '(refute ' asl/packages/asl-sh/tests asl/packages/asl-sql/tests asl/packages/asl-text/tests asl/packages/asl-registry/tests asl/packages/asl-plugin/tests | wc -l) -ge 69 && ! grep -rn '(assert (not ' asl/packages/asl-sh/tests asl/packages/asl-sql/tests asl/packages/asl-text/tests asl/packages/asl-registry/tests asl/packages/asl-plugin/tests && bin/asl test tests/acceptance/d81/Task50507.asl`
- **Current Gate Result (Fails Now)**:
  - `test $(grep -rn '(refute ' ... | wc -l) -ge 69` exits with status 1 (currently 0 `refute` forms found).
  - `! grep -rn '(assert (not ' ...` exits with status 1 (currently 69 occurrences found across the 23 suites).
  - `bin/asl test tests/acceptance/d81/Task50507.asl` exits with status 1: `Error: test file not found: tests/acceptance/d81/Task50507.asl`.
- **What breaks if run before prerequisite**:
  If run before Task 50501 (`emoji_guard_test.asl`), Task 50502 (`ddl_test.asl`), or Task 50506 (`sh_test.asl`), the refutation conversions on those files would conflict with or be overridden by earlier tasks modifying the same test files.

---

## 5. Risks & Mitigations

| Risk | Impact | Mitigation |
| :--- | :--- | :--- |
| **Refute Form Argument Semantic Drift** | High | In ASL, `(assert (not cond) msg)` wraps negation; `(refute cond msg)` evaluates `cond` directly and fails if `cond` is true. Care must be taken not to preserve the inner `not` when converting to `refute` (e.g. `(refute (not x))` would invert meaning). |
| **SQL Dialect Enum Mismatch in DDL Callers** | Medium | Changing `(isPg Bool)` to `(dialect SqlDialect)` could break external callers if any pass a raw boolean. An audit confirmed only `ddl_test.asl` calls these functions, and it already passes `(sql/sqlite)` and `(sql/postgres)` constructor forms. |
| **Grammar Registry Token Bloat** | Medium | Adding symbols to `grammar.asn` must follow D51: symbols <= 2 tokens require no justification; symbols > 2 tokens require strict `:rationale`. Gate 6 (`bin/asl audit gates --only=6`) will be run as an invariant. |
| **Test Execution Regressions** | High | Converting 69 assertions across 23 test suites could cause silent syntax errors or regression. All 23 test suites will be re-executed with `bin/asl test` to guarantee 100% pass rate. |

---

## 6. Out of Scope

The following items are deliberately excluded from Phase 505:
- **Core Compiler AoT Code Generation (Mach-O / ELF)**: Handled in Phase 487 (`D86`). Phase 505 strictly remediates stdlib extensions and testing debt.
- **Wasm Runtime OPFS Storage Engine**: Handled in Phase 488 (`D87`).
- **Phase 484-486 Multi-Model Mesh Infrastructure**: Verified and certified in their respective phases; Phase 505 only touches standard library packages (`asl-sh`, `asl-sql`, `asl-text`, `asl-registry`, `asl-plugin`).
- **Converting Non-Negative Assertions**: Tests with positive predicates (`assert (= ...)`) remain assertions. Only negative forms `(assert (not ...))` are converted to `(refute ...)`.

---

## 7. Opportunities & Suggestions (Architectural / Latent Capabilities)

- **Static Refute Linter Rule**: An AST lint rule can be added to `asl-lint` (e.g. `no-wrapped-assert-not`) that automatically detects `(assert (not ...))` in test files and flags it as a polarity smell, suggesting `(refute ...)` instead.
- **Parametric SQL Dialect Test Generator**: Rather than writing separate test cases for each SQL dialect in `ddl_test.asl`, a property-based macro could run each DDL definition across all 4 registered dialects (`sqlite`, `postgres`, `mysql`, `clickhouse`) to verify syntax output.
- **Package Manifest Self-Validation Hook**: A pre-commit hook could verify that every file in `src/` has its module identifier registered in `manifest.asn :modules`, preventing manifest desynchronization permanently.
