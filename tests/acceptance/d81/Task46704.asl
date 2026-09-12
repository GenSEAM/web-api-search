(module tests/acceptance/d81/Task46704
  :d "Acceptance fixture for Task46704: queryable call-graph and impact surface under ADR-0081."
  :x [run-tests
      test-callers-and-impact-cli-implemented
      test-callers-and-impact-dispatched]
  :i [])

(df test-callers-and-impact-cli-implemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_callers and run_cmd_impact"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_callers") "asl.c must implement run_cmd_callers")
      (assert (string-contains? src "run_cmd_impact") "asl.c must implement run_cmd_impact")
      true)))

(df test-callers-and-impact-dispatched [] -> Bool
  :d "Verifies that main in asl/tools/asl.c dispatches callers and impact subcommands"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(argv[1], \"callers\") == 0")
              "asl.c must dispatch callers subcommand")
      (assert (string-contains? src "strcmp(argv[1], \"impact\") == 0")
              "asl.c must dispatch impact subcommand")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46704 supervisor acceptance tests"
  (do
    (assert (test-callers-and-impact-cli-implemented) "test-callers-and-impact-cli-implemented must pass")
    (assert (test-callers-and-impact-dispatched) "test-callers-and-impact-dispatched must pass")
    true))
