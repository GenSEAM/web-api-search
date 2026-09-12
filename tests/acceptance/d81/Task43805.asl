(module tests/acceptance/d81/Task43805
  :d "Acceptance fixture for Task43805: transactional batches with isolated staging under ADR-0081."
  :x [RunTests
      TestStagingOperationsInAslC
      TestSequencedBatchInAslC
      TestStagingCapabilitiesStatusWorks]
  :i [])

(df TestStagingOperationsInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements staging table and operations"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "StagedBuffer") (string-contains? c-src "staged_buffer"))
              "asl.c must define staging buffer structure")
      (assert (string-contains? c-src "op_diff") "asl.c must implement op_diff")
      (assert (string-contains? c-src "op_flush") "asl.c must implement op_flush")
      (assert (string-contains? c-src "op_discard") "asl.c must implement op_discard")
      true)))

(df TestSequencedBatchInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements sequenced batch fail-fast logic"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "seq_mode") (string-contains? c-src "is_sequenced"))
              "asl.c must implement sequenced batch mode")
      true)))

(df TestStagingCapabilitiesStatusWorks [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares stagedEdit and rollback as works"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist and be readable")
    (let [(cap-txt (.-value cap-res))]
      (assert (string-contains? cap-txt "(:cap :id stagedEdit :use \"stage, review with (:diff), commit with (:flush) or drop with (:discard)\" :status :works")
              "capabilities.asn must declare stagedEdit as works")
      (assert (string-contains? cap-txt "(:cap :id rollback :use \"(:discard) reverts staged edits\" :status :works")
              "capabilities.asn must declare rollback as works")
      (assert (string-contains? cap-txt "(:cap :id sequencedBatch :use \"(:batch :seq true ...) runs steps in order and short-circuits\" :status :works")
              "capabilities.asn must declare sequencedBatch as works")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43805 supervisor acceptance tests"
  (do
    (assert (TestStagingOperationsInAslC) "TestStagingOperationsInAslC must pass")
    (assert (TestSequencedBatchInAslC) "TestSequencedBatchInAslC must pass")
    (assert (TestStagingCapabilitiesStatusWorks) "TestStagingCapabilitiesStatusWorks must pass")
    true))
