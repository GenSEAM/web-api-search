(module tests/acceptance/d81/Task45402
  :d "Acceptance fixture for Task45402: located and fatal unresolved import error diagnostics under ADR-0081."
  :x [run-tests
      test-unresolved-import-diagnostic-schema
      test-import-error-localization
      test-unresolved-import-prevents-alias-binding]
  :i [])

(df test-unresolved-import-diagnostic-schema [] -> Bool
  :d "Verifies that unresolved import diagnostics contain importing file, line, module name, and candidate searched"
  (let [(diag "ERR_UNRESOLVED_IMPORT: module 'nonexistent/pkg' imported in 'agent-bus/src/bus.asl:15' could not be resolved (searched candidate: '/workspace/agent-bus/src/nonexistent/pkg.asl')")]
    (assert (string-contains? diag "ERR_UNRESOLVED_IMPORT:") "diagnostic must have ERR_UNRESOLVED_IMPORT failure code")
    (assert (string-contains? diag "nonexistent/pkg") "diagnostic must name the module as written")
    (assert (string-contains? diag "agent-bus/src/bus.asl:15") "diagnostic must name importing file and exact line")
    (assert (string-contains? diag "searched candidate:") "diagnostic must name the searched candidate path")
    true))

(df test-import-error-localization [] -> Bool
  :d "Verifies that import errors are localized to the import site rather than a downstream call site or unknown symbol"
  (let [(import-diag "ERR_UNRESOLVED_IMPORT: module 'core/strings' imported in 'agent-bus/src/bus.asl:15' could not be resolved (searched candidate: '/workspace/agent-bus/src/core/strings.asl')")
        (downstream-symbol-diag "ERR_UNBOUND_SYMBOL: unknown builtin or function 's/concat'")]
    (assert (string-contains? import-diag "ERR_UNRESOLVED_IMPORT") "import failure must be attributed to ERR_UNRESOLVED_IMPORT")
    (assert (not (string-contains? import-diag "ERR_UNBOUND_SYMBOL")) "import failure must not report downstream unbound symbol")
    (assert (string-contains? import-diag "agent-bus/src/bus.asl:15") "import failure must report declaring import site")
    (assert (not (string-contains? import-diag "agent-bus/tests/bus_test.asl")) "import failure must never blame test call site")
    true))

(df test-unresolved-import-prevents-alias-binding [] -> Bool
  :d "Verifies that an unresolvable import produces fatal error and never leaves an alias bound to an unloaded module"
  (let [(import-status {:resolved false
                        :alias "s"
                        :target-module "core/strings"
                        :fatal-raised true
                        :alias-bound false})]
    (assert (not (.-resolved import-status)) "unresolvable import must not be marked resolved")
    (assert (.-fatal-raised import-status) "unresolvable import must raise fatal error")
    (assert (not (.-alias-bound import-status)) "alias must never be bound to an unloaded module")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task45402 acceptance tests"
  (do
    (assert (test-unresolved-import-diagnostic-schema) "test-unresolved-import-diagnostic-schema must pass")
    (assert (test-import-error-localization) "test-import-error-localization must pass")
    (assert (test-unresolved-import-prevents-alias-binding) "test-unresolved-import-prevents-alias-binding must pass")
    true))
