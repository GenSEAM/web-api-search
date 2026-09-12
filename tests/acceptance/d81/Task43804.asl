(module tests/acceptance/d81/Task43804
  :d "Acceptance fixture for Task43804: truthful content search in RPC and CLI under ADR-0081."
  :x [RunTests
      TestContentSearchInAslC
      TestContentSearchCapabilityStatusWorks]
  :i [])

(df TestContentSearchInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements content search via run_cmd_grep and rpc grep"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "run_cmd_grep") "asl.c must implement run_cmd_grep")
      (assert (string-contains? c-src "op_grep") "asl.c must implement op_grep")
      true)))

(df TestContentSearchCapabilityStatusWorks [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares contentSearch as works"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist and be readable")
    (let [(cap-txt (.-value cap-res))]
      (assert (string-contains? cap-txt "(:cap :id contentSearch :use \"(:grep \\\"text\\\") searches file CONTENTS\" :status :works")
              "capabilities.asn must declare contentSearch as works")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43804 supervisor acceptance tests"
  (do
    (assert (TestContentSearchInAslC) "TestContentSearchInAslC must pass")
    (assert (TestContentSearchCapabilityStatusWorks) "TestContentSearchCapabilityStatusWorks must pass")
    true))
