(module tests/acceptance/d81/Task43904
  :d "Acceptance fixture for Task43904: full task graph consistency validation under ADR-0081."
  :x [RunTests
      TestConsistencyAuditInAslC
      TestConsistencyCapabilityStatusWorks]
  :i [])

(df TestConsistencyAuditInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_consistency"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "run_cmd_consistency")
              "asl.c must implement run_cmd_consistency")
      true)))

(df TestConsistencyCapabilityStatusWorks [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares consistency as works"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist and be readable")
    (let [(cap-txt (.-value cap-res))]
      (assert (string-contains? cap-txt "(:cap :id consistency :use \"asl audit consistency over ADR, tasks, intent, roadmap\" :status :works")
              "capabilities.asn must declare consistency as works")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43904 supervisor acceptance tests"
  (do
    (assert (TestConsistencyAuditInAslC) "TestConsistencyAuditInAslC must pass")
    (assert (TestConsistencyCapabilityStatusWorks) "TestConsistencyCapabilityStatusWorks must pass")
    true))
