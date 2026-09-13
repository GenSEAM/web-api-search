(module tests/acceptance/d81/Task48406
  :d "Acceptance fixture for Task48406: Ergonomic CLI Projections and Agent Toolbelt Commands under D83."
  :x [run-tests
      test-dynamic-execution-receipt-verified
      test-cli-subcommands-implemented
      test-cli-dispatcher-routes-subcommands
      test-in-ram-vfs-and-shortcodes-implemented]
  :i [])

(df test-dynamic-execution-receipt-verified [] -> Bool
  :d "Verifies that the Task48406 dynamic test suite has executed and emitted a passing receipt"
  (let [(res (file-read ".asl/mem/receipts/task-48406-dynamic.asn"))]
    (assert (= (.-_tag res) "ok") "dynamic execution receipt must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":taskId \"Task48406\"") "receipt taskId must match Task48406")
      (assert (string-contains? src ":status :passed") "dynamic suite status must be passed")
      (assert (string-contains? src ":exitCode 0") "dynamic suite exitCode must be 0")
      (assert (string-contains? src "(:check :name \"intel-outline\" :status :passed)") "intel outline dynamic verification passed")
      (assert (string-contains? src "(:check :name \"mem-lifecycle\" :status :passed)") "mem lifecycle dynamic verification passed")
      (assert (string-contains? src "(:check :name \"crossproc-vfs\" :status :passed)") "crossproc vfs dynamic verification passed")
      (assert (string-contains? src "(:check :name \"batch-shortcodes\" :status :passed)") "batch shortcodes dynamic verification passed")
      (assert (string-contains? src "(:check :name \"in-memory-delimiter-guard\" :status :passed)") "in-memory delimiter guard dynamic verification passed")
      true)))

(df test-cli-subcommands-implemented [] -> Bool
  :d "Verifies that cmd_task, cmd_adr, cmd_note, cmd_receipt, cmd_plan, cmd_intel, and cmd_mem are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "cmd_task") (string-contains? src "run_cmd_task")) "cmd_task implemented")
      (assert (or (string-contains? src "cmd_adr") (string-contains? src "run_cmd_adr")) "cmd_adr implemented")
      (assert (or (string-contains? src "cmd_note") (string-contains? src "run_cmd_note")) "cmd_note implemented")
      (assert (or (string-contains? src "cmd_receipt") (string-contains? src "run_cmd_receipt")) "cmd_receipt implemented")
      (assert (or (string-contains? src "cmd_plan") (string-contains? src "run_cmd_plan")) "cmd_plan implemented")
      (assert (or (string-contains? src "cmd_intel") (string-contains? src "run_cmd_intel")) "cmd_intel implemented")
      (assert (or (string-contains? src "cmd_mem") (string-contains? src "run_cmd_mem")) "cmd_mem implemented")
      true)))

(df test-cli-dispatcher-routes-subcommands [] -> Bool
  :d "Verifies that main dispatcher routes adr, receipt, plan, intel, and mem commands"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(argv[1], \"adr\") == 0") "adr subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"receipt\") == 0") "receipt subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"plan\") == 0") "plan subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"intel\") == 0") "intel subcommand routed")
      (assert (string-contains? src "strcmp(argv[1], \"mem\") == 0") "mem subcommand routed")
      (assert (string-contains? src "cli_dispatcher") "cli_dispatcher declared")
      (assert (string-contains? src "asn_projector") "asn_projector declared")
      true)))

(df test-in-ram-vfs-and-shortcodes-implemented [] -> Bool
  :d "Verifies that In-RAM VFS operations and RPC shortcodes are implemented with cross-process staging"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "load_staged_buffers_from_disk") "load_staged_buffers_from_disk implemented")
      (assert (string-contains? src "save_staged_buffers_to_disk") "save_staged_buffers_to_disk implemented")
      (assert (string-contains? src "check_memory_delimiters") "check_memory_delimiters implemented")
      (assert (string-contains? src "strcmp(op, \"repl\") == 0") "repl shortcode dispatched")
      (assert (string-contains? src "strcmp(op, \"out\") == 0") "out shortcode dispatched")
      (assert (string-contains? src "strcmp(op, \"sec\") == 0") "sec shortcode dispatched")
      (assert (string-contains? src "strcmp(op, \"chk\") == 0") "chk shortcode dispatched")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48406 acceptance assertions"
  (let [(r1 (test-dynamic-execution-receipt-verified))
        (r2 (test-cli-subcommands-implemented))
        (r3 (test-cli-dispatcher-routes-subcommands))
        (r4 (test-in-ram-vfs-and-shortcodes-implemented))]
    (assert (and r1 (and r2 (and r3 r4))) "All Task48406 checks must pass")
    true))
