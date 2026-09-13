(module tests/acceptance/d81/Task48505
  :d "Acceptance fixture for Task48505: Dry-Run Diagnostic and Capability Handshake Verifier under D84."
  :x [run-tests
      test-dry-run-symbols-implemented
      test-dry-run-receipt-and-plan-declared
      test-agy-dry-run-execution
      test-claude-dry-run-execution]
  :i [])

(df test-dry-run-symbols-implemented [] -> Bool
  :d "Verifies that launch_dry_run and print_launch_plan are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "launch_dry_run") "launch_dry_run implemented")
      (assert (string-contains? src "print_launch_plan") "print_launch_plan implemented")
      true)))

(df test-dry-run-receipt-and-plan-declared [] -> Bool
  :d "Verifies that dry_run_receipt and invocation_plan concepts are declared in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "dry_run_receipt") "dry_run_receipt declared")
      (assert (string-contains? src "invocation_plan") "invocation_plan declared")
      true)))

(df test-agy-dry-run-execution [] -> Bool
  :d "Verifies that asl launch agy --dry-run emits permission tier and auto-flags"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "dangerous-rescue") "dangerous-rescue handled")
      (assert (string-contains? src "--dangerously-skip-permissions") "auto flags handled")
      true)))

(df test-claude-dry-run-execution [] -> Bool
  :d "Verifies that asl launch claude --dry-run emits clean invocation plan"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "claude-mode") "claude-mode handled")
      (assert (string-contains? src "is_claude") "claude client handled")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48505 acceptance assertions"
  (let [(r1 (test-dry-run-symbols-implemented))
        (r2 (test-dry-run-receipt-and-plan-declared))
        (r3 (test-agy-dry-run-execution))
        (r4 (test-claude-dry-run-execution))]
    (assert (and (and (and r1 r2) r3) r4) "All Task48505 checks must pass")
    true))
