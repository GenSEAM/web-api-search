(module tests/acceptance/d81/Task44204
  :d "Acceptance fixture for Task44204: executable plan verifier (asl plan verify) under ADR-0081."
  :x [RunTests
      TestPlanVerifySubcommandImplemented
      TestPlanVerifyAsnFindingsFormat
      TestPlanVerifyChecksD52AndAcyclicity]
  :i [])

(df TestPlanVerifySubcommandImplemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements plan verify subcommand routing"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_cmd_audit_plan")
              "asl.c must implement run_cmd_audit_plan")
      (assert (string-contains? c-src "strcmp(argv[1], \"plan\")")
              "asl.c must route plan subcommand")
      (assert (string-contains? c-src "strcmp(argv[2], \"verify\")")
              "asl.c must route verify subaction")
      (assert (string-contains? c-src "asl plan verify")
              "asl.c must document asl plan verify in help/usage")
      true)))

(df TestPlanVerifyAsnFindingsFormat [] -> Bool
  :d "Verifies that asl plan audit/verify implements ASN findings emission"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "(:plan-audit-report")
              "asl.c must emit (:plan-audit-report structure")
      (assert (string-contains? c-src ":cycles")
              "plan audit report must include :cycles count")
      (assert (string-contains? c-src ":d52-errors")
              "plan audit report must include :d52-errors count")
      true)))

(df TestPlanVerifyChecksD52AndAcyclicity [] -> Bool
  :d "Verifies that asl.c implements DAG cycle detection and D52 metadata verification"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "detect_dag_cycles")
              "asl.c must implement detect_dag_cycles")
      (assert (string-contains? c-src "detect_dag_cycles_dfs")
              "asl.c must implement detect_dag_cycles_dfs")
      (assert (string-contains? c-src "has_owns")
              "asl.c must check has_owns")
      (assert (string-contains? c-src "has_gate")
              "asl.c must check has_gate")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44204 supervisor acceptance tests"
  (do
    (assert (TestPlanVerifySubcommandImplemented) "TestPlanVerifySubcommandImplemented must pass")
    (assert (TestPlanVerifyAsnFindingsFormat) "TestPlanVerifyAsnFindingsFormat must pass")
    (assert (TestPlanVerifyChecksD52AndAcyclicity) "TestPlanVerifyChecksD52AndAcyclicity must pass")
    true))
