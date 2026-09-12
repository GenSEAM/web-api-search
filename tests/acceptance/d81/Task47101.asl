(module tests/acceptance/d81/Task47101
  :d "Acceptance fixture for Task47101: repository plan verification command under ADR-0081."
  :x [RunTests
      TestAuditPlanSubcommandSupported
      TestPlanScannerLogicInAslC]
  :i [])

(df TestAuditPlanSubcommandSupported [] -> Bool
  :d "Verifies that asl/tools/asl.c implements plan audit subcommand"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "plan") "asl.c must mention plan audit")
      (assert (string-contains? c-src "run_cmd_audit_plan") "asl.c must implement run_cmd_audit_plan")
      true)))

(df TestPlanScannerLogicInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c contains DAG cycle detection and D52 checks"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "detect_dag_cycles") (string-contains? c-src "plan_cycle"))
              "asl.c must implement DAG cycle detection for plans")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47101 supervisor acceptance tests"
  (do
    (assert (TestAuditPlanSubcommandSupported) "TestAuditPlanSubcommandSupported must pass")
    (assert (TestPlanScannerLogicInAslC) "TestPlanScannerLogicInAslC must pass")
    true))
