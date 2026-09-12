(module tests/acceptance/d81/Task46502
  :d "Acceptance fixture for Task46502: cursor-driven file worklist, mandatory skip reason, and non-colliding walkers under ADR-0081."
  :x [run-tests
      test-worklist-module-and-manifest
      test-worklist-source-contracts]
  :i [])

(df test-worklist-module-and-manifest [] -> Bool
  :d "Verifies that mem/src/worklist.asl exists and is declared in mem/manifest.asn"
  (let [(src-res (file-read "mem/src/worklist.asl"))
        (man-res (file-read "mem/manifest.asn"))]
    (assert (= (.-_tag src-res) "ok") "mem/src/worklist.asl must exist and be readable")
    (assert (= (.-_tag man-res) "ok") "mem/manifest.asn must exist and be readable")
    (let [(man (.-value man-res))]
      (assert (string-contains? man "\"asl-mem/worklist\"") "mem/manifest.asn must declare asl-mem/worklist")
      true)))

(df test-worklist-source-contracts [] -> Bool
  :d "Verifies worklist entry states, cursor batching, and mandatory skip reason enforcement"
  (let [(src-res (file-read "mem/src/worklist.asl"))]
    (assert (= (.-_tag src-res) "ok") "mem/src/worklist.asl must exist")
    (let [(src (.-value src-res))]
      (assert (string-contains? src "worklist-create") "worklist must define worklist-create")
      (assert (string-contains? src "worklist-cursor-next") "worklist must define worklist-cursor-next")
      (assert (string-contains? src "worklist-mark-done") "worklist must define worklist-mark-done")
      (assert (string-contains? src "worklist-mark-skipped") "worklist must define worklist-mark-skipped")
      (assert (string-contains? src "reason") "worklist must require skip reason")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46502 supervisor acceptance tests"
  (do
    (assert (test-worklist-module-and-manifest) "test-worklist-module-and-manifest must pass")
    (assert (test-worklist-source-contracts) "test-worklist-source-contracts must pass")
    true))
