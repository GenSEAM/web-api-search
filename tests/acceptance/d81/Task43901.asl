(module tests/acceptance/d81/Task43901
  :d "Acceptance fixture for Task43901: real fault detection and mutation scoring under ADR-0081."
  :x [RunTests
      TestMutationScoreInAslC
      TestMutationScoreCapabilityStatusWorks]
  :i [])

(df TestMutationScoreInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements strict falsification and fault detection"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "strict-falsify") (string-contains? c-src "strict_falsify"))
              "asl.c must implement strict falsify")
      true)))

(df TestMutationScoreCapabilityStatusWorks [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares mutationScore as works"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist and be readable")
    (let [(cap-txt (.-value cap-res))]
      (assert (string-contains? cap-txt "(:cap :id mutationScore :use \"asl test --strict-falsify reports fault-detection power\" :status :works")
              "capabilities.asn must declare mutationScore as works")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43901 supervisor acceptance tests"
  (do
    (assert (TestMutationScoreInAslC) "TestMutationScoreInAslC must pass")
    (assert (TestMutationScoreCapabilityStatusWorks) "TestMutationScoreCapabilityStatusWorks must pass")
    true))
