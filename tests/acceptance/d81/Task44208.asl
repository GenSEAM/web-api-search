(module tests/acceptance/d81/Task44208
  :d "Acceptance fixture for Task44208: coverage and case-diversity map under ADR-0081."
  :x [RunTests
      TestCoverageSubcommandImplemented
      TestCoverageMapsSymbolsAndCases
      TestCoverageGate7Integration]
  :i [])

(df TestCoverageSubcommandImplemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_coverage and dispatches coverage in main"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_cmd_coverage")
              "asl.c must implement run_cmd_coverage")
      (assert (string-contains? c-src "audit_coverage")
              "asl.c must implement audit_coverage")
      (assert (string-contains? c-src "asl coverage")
              "asl.c must document asl coverage in help/usage")
      true)))

(df TestCoverageMapsSymbolsAndCases [] -> Bool
  :d "Verifies that coverage mapping models exported symbols and case kinds"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":symbol-coverage")
              "coverage must emit :symbol-coverage records")
      (assert (string-contains? c-src ":case-kinds")
              "coverage must detect and report :case-kinds")
      (assert (string-contains? c-src ":executed")
              "coverage must report :executed status")
      (assert (string-contains? c-src "TEST_CASE_CATALOG.md")
              "coverage must reference docs/TEST_CASE_CATALOG.md")
      true)))

(df TestCoverageGate7Integration [] -> Bool
  :d "Verifies that coverage integrates with package verification and gate checks"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":uncovered-count")
              "coverage must report :uncovered-count")
      (assert (string-contains? c-src ":coverage-pct")
              "coverage must report :coverage-pct")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44208 supervisor acceptance tests"
  (do
    (assert (TestCoverageSubcommandImplemented) "TestCoverageSubcommandImplemented must pass")
    (assert (TestCoverageMapsSymbolsAndCases) "TestCoverageMapsSymbolsAndCases must pass")
    (assert (TestCoverageGate7Integration) "TestCoverageGate7Integration must pass")
    true))
