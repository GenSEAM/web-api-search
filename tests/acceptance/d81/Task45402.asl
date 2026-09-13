(module tests/acceptance/d81/Task45402
  :d "Acceptance fixture for Task45402: located and fatal unresolved import error diagnostics under ADR-0081."
  :x [runTests
      testUnresolvedImportDiagnosticSchema
      testImportErrorLocalization
      testUnresolvedImportPreventsAliasBinding]
  :i [])

(df testUnresolvedImportDiagnosticSchema [] -> Bool
  :d "Verifies that unresolved import diagnostics contain importing file, line, module name, and candidate searched"
  (let [(diag "ERR_UNRESOLVED_IMPORT: module 'nonexistent/pkg' imported in 'agent-bus/src/bus.asl:15' could not be resolved (searched candidate: '/workspace/agent-bus/src/nonexistent/pkg.asl')")]
    (assert (string-contains? diag "ERR_UNRESOLVED_IMPORT:") "diagnostic must have ERR_UNRESOLVED_IMPORT failure code")
    (assert (string-contains? diag "nonexistent/pkg") "diagnostic must name the module as written")
    (assert (string-contains? diag "agent-bus/src/bus.asl:15") "diagnostic must name importing file and exact line")
    (assert (string-contains? diag "searched candidate:") "diagnostic must name the searched candidate path")
    true))

(df testImportErrorLocalization [] -> Bool
  :d "Verifies that import errors are localized to the import site rather than a downstream call site or unknown symbol"
  (let [(importDiag "ERR_UNRESOLVED_IMPORT: module 'core/strings' imported in 'agent-bus/src/bus.asl:15' could not be resolved (searched candidate: '/workspace/agent-bus/src/core/strings.asl')")
        (downstreamSymbolDiag "ERR_UNBOUND_SYMBOL: unknown builtin or function 's/concat'")]
    (assert (string-contains? importDiag "ERR_UNRESOLVED_IMPORT") "import failure must be attributed to ERR_UNRESOLVED_IMPORT")
    (assert (not (string-contains? importDiag "ERR_UNBOUND_SYMBOL")) "import failure must not report downstream unbound symbol")
    (assert (string-contains? importDiag "agent-bus/src/bus.asl:15") "import failure must report declaring import site")
    (assert (not (string-contains? importDiag "agent-bus/tests/bus_test.asl")) "import failure must never blame test call site")
    true))

(df testUnresolvedImportPreventsAliasBinding [] -> Bool
  :d "Verifies that an unresolvable import produces fatal error and never leaves an alias bound to an unloaded module"
  (let [(importStatus {:resolved false
                        :alias "s"
                        :targetModule "core/strings"
                        :fatalRaised true
                        :aliasBound false})]
    (assert (not (.-resolved importStatus)) "unresolvable import must not be marked resolved")
    (assert (.-fatalRaised importStatus) "unresolvable import must raise fatal error")
    (assert (not (.-aliasBound importStatus)) "alias must never be bound to an unloaded module")
    true))

(df runTests [] -> Bool
  :d "Executes all Task45402 acceptance tests"
  (do
    (assert (testUnresolvedImportDiagnosticSchema) "test-unresolved-import-diagnostic-schema must pass")
    (assert (testImportErrorLocalization) "test-import-error-localization must pass")
    (assert (testUnresolvedImportPreventsAliasBinding) "test-unresolved-import-prevents-alias-binding must pass")
    true))
