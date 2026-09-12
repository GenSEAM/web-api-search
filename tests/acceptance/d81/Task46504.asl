(module tests/acceptance/d81/Task46504
  :d "Acceptance fixture for Task46504: working memory rule and anchor concession retirement under ADR-0081."
  :x [run-tests
      test-rules-source-has-note-rule
      test-anchor-concession-retired]
  :i [])

(df test-rules-source-has-note-rule [] -> Bool
  :d "Verifies that asl/grammar/rules.asn defines the working memory rule"
  (let [(rules-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag rules-res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(rules (.-value rules-res))]
      (assert (string-contains? rules ":rule :id note") "rules.asn must define rule :id note")
      (assert (string-contains? rules "asl note") "rule must reference asl note command")
      true)))

(df test-anchor-concession-retired [] -> Bool
  :d "Verifies that the anchor rule concession has been cleanly retired"
  (let [(rules-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag rules-res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(rules (.-value rules-res))]
      (assert (not (string-contains? rules "until the ledger ops exist keep the plan in the task file and re-read it"))
              "anchor concession must be retired from rules.asn")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46504 supervisor acceptance tests"
  (do
    (assert (test-rules-source-has-note-rule) "test-rules-source-has-note-rule must pass")
    (assert (test-anchor-concession-retired) "test-anchor-concession-retired must pass")
    true))
