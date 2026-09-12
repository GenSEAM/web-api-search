# Phase 2: P0 Engine Runtime, Evaluator & Module Foundation (Consolidated)

## Acceptance Criterion
All P0 foundation defects blocking compiler evaluation, package boundaries, and continuous gate execution must be eradicated:
1. Evaluator qualified enum constructor lookup (${enumName}:${variantName}) must function correctly across module boundaries, supported by recompiled bin/asl.
2. All references to non-existent module core/strings must be purged from all packages and replaced with canonical asl-text/string.
3. All module headers must use canonical :x exports instead of :exports, and Clojure (ns ...) headers in asl/web must be standard ASL (module ...).
4. All unbound symbols (eddie-run, sm/state-clarification, on/Middleware) and non-functional constructs (set!, to-string) in steps-pipeline must be refactored to pure functional ASL.
5. All vacuous assertions (assert true) in browser-bridge-test must be replaced with concrete header validations.
6. Monorepo continuous audit (asl audit gates) Gates 1, 2, 3, and 4 must pass cleanly.

---

## Ordered Work Items

### Item 1: Evaluator Qualified Enum Constructor Binding & Binary Recompilation
- **Path**: asl/tools/engine.js, asl/tools/engine_js.h, asl/tools/asl.c, bin/asl
- **Why**: Currently, engine.js registers enum variants bare, failing qualified calls (tr/RuntimeKind:browser-webpage and InferenceTarget:on-device-webgpu). Because bin/asl embeds engine_js.h as a C string literal, changes to engine.js must be regenerated via gen_engine_header.sh and recompiled into bin/asl.
- **Gate**:
  ```bash
  ./bin/asl test browser-plugin/tests/browser_agent_test.asl && ./bin/asl test web-api-search/tests/quota_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  ERR_UNBOUND_SYMBOL: unknown builtin or function InferenceTarget:on-device-webgpu
  ERR_UNBOUND_SYMBOL: unknown builtin or function tr/RuntimeKind:browser-webpage
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["asl/tools/engine.js", "asl/tools/engine_js.h", "asl/tools/asl.c", "asl/asl", "bin/asl"]

---

### Item 2: Eradicate Non-Existent core/strings Across Monorepo Packages
- **Path**: asl/packages/asl-sql/src/core/sql.asl, asl/packages/asl-sql/manifest.asn, agent-bus/tests/browser-bridge-test.asl, mem/src/migration.asl, editorial-matrix/src/syndication-cadence.asl, editorial-matrix/src/article-projector.asl, harness/tests/bench-runners-test.asl, harness/tests/browser-harness-test.asl, asl/web/src/components/
- **Why**: Non-existent module core/strings crashes tests with fatal ERR_UNRESOLVED_IMPORT across 5 packages. Must import canonical (asl-text/string :a s) or (asl-text :a txt) and declare dependency in manifest.asn. Also replace vacuous (assert true) in browser-bridge-test.asl:68-70 with concrete CORS header assertions (BND-07).
- **Gate**:
  ```bash
  ./bin/asl test asl/packages/asl-sql/tests/sql_test.asl && ./bin/asl test asl/packages/asl-sql/tests/ddl_test.asl && ./bin/asl test agent-bus/tests/browser-bridge-test.asl && ./bin/asl test mem/tests/migration-test.asl && ./bin/asl test editorial-matrix/tests/syndication-cadence-test.asl && ./bin/asl test editorial-matrix/tests/article-projector-test.asl && ./bin/asl test harness/tests/bench-runners-test.asl && ./bin/asl test harness/tests/browser-harness-test.asl
  ```
- **Current Baseline Failure**:
  ```text
  ERR_UNRESOLVED_IMPORT: module core/strings could not be resolved (8 test files fail)
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["asl/packages/asl-sql/src/core/sql.asl", "asl/packages/asl-sql/manifest.asn", "agent-bus/tests/browser-bridge-test.asl", "mem/src/migration.asl", "editorial-matrix/src/syndication-cadence.asl", "editorial-matrix/src/article-projector.asl", "harness/tests/bench-runners-test.asl", "harness/tests/browser-harness-test.asl", "asl/web/src/components/Hero.asl", "asl/web/src/components/Navbar.asl", "asl/web/src/components/ThemeToggle.asl", "asl/web/src/components/Footer.asl", "asl/web/src/components/ui/Logo.asl"]

---

### Item 3: Canonicalize Module Headers (:exports to :x, ns to module)
- **Path**: agent-core/src/dag_merge.asl, agent-core/src/prompt_tree.asl, agent-bus/src/mvcc_bus.asl, mem/src/speculative_fork.asl, mem/src/ast_merge.asl, mem/src/stm.asl, asl/web/src/views/playground_test.asl, asl/web/src/views/test_card.asl
- **Why**: Invariant C4/D46 dictates :x for module exports. Four packages used non-standard :exports, masking exported symbols from loaders. asl/web used Clojure (ns ...) headers crashing with ERR_UNBOUND_SYMBOL: ns.
- **Gate**:
  ```bash
  ! grep -rn ":exports \\[" agent-core/src/ agent-bus/src/ mem/src/ && ./bin/asl test asl/web/src/views/playground_test.asl && ./bin/asl test asl/web/src/views/test_card.asl
  ```
- **Current Baseline Failure**:
  ```text
  ERR_UNBOUND_SYMBOL: unknown builtin or function ns
  Matches found for :exports [ in 6 source files
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["agent-core/src/dag_merge.asl", "agent-core/src/prompt_tree.asl", "agent-bus/src/mvcc_bus.asl", "mem/src/speculative_fork.asl", "mem/src/ast_merge.asl", "mem/src/stm.asl", "asl/web/src/views/playground_test.asl", "asl/web/src/views/test_card.asl"]

---

### Item 4: Fix Symbol Aliases, Pure Functional Steps Pipeline & Onion Middleware
- **Path**: agent/tests/agent-test.asl, agent-core/tests/promptpool_test.asl, harness/src/steps-pipeline.asl, harness/src/plugin_host.asl, harness/src/resident_layer.asl
- **Why**: Fix import alias in agent-test.asl (:i [(eddie :a eddie)]); constructor calls in promptpool_test.asl ((tt/state-clarification)); refactor both set! imperative mutation (GATE-10) and nonexistent to-string (GATE-12) in steps-pipeline.asl to pure functional let/fold and string-from-int64; resolve onion middleware bindings between agent and harness.
- **Gate**:
  ```bash
  ./bin/asl test agent/tests/agent-test.asl && ./bin/asl test agent-core/tests/promptpool_test.asl && ./bin/asl test harness/tests/steps-pipeline-test.asl && ./bin/asl test harness/tests/teleology_test.asl && ./bin/asl test harness/tests/plugin_host_test.asl && ./bin/asl test harness/tests/resident_layer_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  ERR_UNBOUND_SYMBOL: unknown builtin or function eddie/eddie-run
  ERR_UNBOUND_SYMBOL: unknown builtin or function sm/state-clarification
  ERR_UNBOUND_SYMBOL: unknown builtin or function set!
  ERR_UNBOUND_SYMBOL: unknown builtin or function on/Middleware
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["agent/tests/agent-test.asl", "agent-core/tests/promptpool_test.asl", "harness/src/steps-pipeline.asl", "harness/src/plugin_host.asl", "harness/src/resident_layer.asl", "harness/manifest.asn"]

---

### Item 5: Purge Embedded Comments in asl/web and Grammar Registries
- **Path**: asl/web/src/views/BlogView.asl, asl/web/src/views/DocsView.asl, asl/web/src/views/EcosystemView.asl, asl/web/src/components/UnifiedPackageMatrix.asl, asl/packages/*/grammar.asn
- **Why**: Invariant C1 requires 0 comments in pure ASL files and pure ASN registries. Purge 51 HTML comment tags and inline JS comments across asl/web views/components, and purge legacy ;; comments from 20 grammar.asn registries.
- **Gate**:
  ```bash
  python3 -c 'import glob, re, sys; files = glob.glob("asl/web/**/*.asl", recursive=True); comments = [f for f in files if "<!--" in open(f).read() or "//" in open(f).read()]; sys.exit(1 if comments else 0)'
  ```
- **Current Baseline Failure**:
  ```text
  Found 51 HTML comments and inline JS comments in 14 asl/web files.
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["asl/web/src/views/BlogView.asl", "asl/web/src/views/DocsView.asl", "asl/web/src/views/EcosystemView.asl", "asl/web/src/components/UnifiedPackageMatrix.asl", "asl/web/src/components/InBrowserAgent.asl", "asl/web/src/views/InIdeView.asl"]
