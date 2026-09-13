(module tests/acceptance/d81/Task48406
  :d "Acceptance fixture for Task48406: Ergonomic CLI Projections and Agent Toolbelt Commands under D83."
  :x [run-tests
      test-cli-subcommands-implemented
      test-cli-dispatcher-routes-subcommands
      test-cli-helpers-and-projector-implemented]
  :i [])

(df test-cli-subcommands-implemented [] -> Bool
  :d "Verifies that cmd_task, cmd_adr, cmd_note, cmd_receipt, and cmd_plan are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "cmd_task") (string-contains? src "run_cmd_task")) "cmd_task implemented")
      (assert (or (string-contains? src "cmd_adr") (string-contains? src "run_cmd_adr")) "cmd_adr implemented")
      (assert (or (string-contains? src "cmd_note") (string-contains? src "run_cmd_note")) "cmd_note implemented")
      (assert (or (string-contains? src "cmd_receipt") (string-contains? src "run_cmd_receipt")) "cmd_receipt implemented")
      (assert (or (string-contains? src "cmd_plan") (string-contains? src "run_cmd_plan")) "cmd_plan implemented")
      true)))

(df test-cli-dispatcher-routes-subcommands [] -> Bool
  :d "Verifies that main dispatcher routes adr, receipt, and plan commands"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(argv[1], \"adr\") == 0") "adr subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"receipt\") == 0") "receipt subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"plan\") == 0") "plan subcommand routed")
      true)))

(df test-cli-helpers-and-projector-implemented [] -> Bool
  :d "Verifies that cli_dispatcher and asn_projector concepts are declared in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "cli_dispatcher") "cli_dispatcher declared")
      (assert (string-contains? src "asn_projector") "asn_projector declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48406 acceptance assertions"
  (let [(r1 (test-cli-subcommands-implemented))
        (r2 (test-cli-dispatcher-routes-subcommands))
        (r3 (test-cli-helpers-and-projector-implemented))]
    (assert (and r1 (and r2 r3)) "All Task48406 checks must pass")
    true))
