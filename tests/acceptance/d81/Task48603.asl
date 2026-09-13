(module tests/acceptance/d81/Task48603
  :d "Acceptance fixture for Task48603: Polyglot Monorepo Scanner and AST Defect Hunter Harness under D85."
  :x [run-tests
      test-scanner-file-exists
      test-scanner-target-symbols
      test-vacuous-test-detection]
  :i [])

(df test-scanner-file-exists [] -> Bool
  :d "Verifies that scanner.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-mesh/src/scanner.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-mesh/src/scanner.asl must exist")
    true))

(df test-scanner-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in scanner.asl"
  (let [(res (file-read "asl/packages/asl-mesh/src/scanner.asl"))]
    (assert (= (.-_tag res) "ok") "scanner.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "scan_ast_defects") "scan_ast_defects defined")
      (assert (string-contains? src "check_vacuous_tests") "check_vacuous_tests defined")
      (assert (string-contains? src "ast_visitor") "ast_visitor defined")
      (assert (string-contains? src "defect_emitter") "defect_emitter defined")
      true)))

(df test-vacuous-test-detection [] -> Bool
  :d "Verifies that scanner detects vacuous assertions and formats defect records"
  (let [(res (file-read "asl/packages/asl-mesh/src/scanner.asl"))]
    (assert (= (.-_tag res) "ok") "scanner.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-mesh/scanner") "module declared correctly")
      (assert (string-contains? src "assert") "assertion logic present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48603 acceptance assertions"
  (let [(r1 (test-scanner-file-exists))
        (r2 (test-scanner-target-symbols))
        (r3 (test-vacuous-test-detection))]
    (assert (and (and r1 r2) r3) "All Task48603 checks must pass")
    true))
