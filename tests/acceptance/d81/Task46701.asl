(module tests/acceptance/d81/Task46701
  :d "Acceptance fixture for Task46701: tool inventory command with measured status and fallbacks under ADR-0081."
  :x [run-tests
      test-asl-c-implements-inventory-command
      test-inventory-subcommand-dispatched]
  :i [])

(df test-asl-c-implements-inventory-command [] -> Bool
  :d "Verifies that asl/tools/asl.c defines run_cmd_inventory and implements inventory reporting"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_inventory") "asl.c must implement run_cmd_inventory")
      (assert (string-contains? src "asl inventory") "asl.c must document asl inventory command")
      true)))

(df test-inventory-subcommand-dispatched [] -> Bool
  :d "Verifies that asl/tools/asl.c dispatches inventory in main"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(argv[1], \"inventory\") == 0")
              "asl.c must dispatch inventory subcommand in main")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46701 supervisor acceptance tests"
  (do
    (assert (test-asl-c-implements-inventory-command) "test-asl-c-implements-inventory-command must pass")
    (assert (test-inventory-subcommand-dispatched) "test-inventory-subcommand-dispatched must pass")
    true))
