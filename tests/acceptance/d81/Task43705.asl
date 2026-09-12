(module tests/acceptance/d81/Task43705
  :d "Acceptance fixture for Task43705: validate capability references and future-operation fallbacks under ADR-0081."
  :x [run-tests
      test-token-conventions-no-absent-tokens-cmd
      test-phase415-gates-no-absent-tokens-cmd]
  :i [])

(df test-token-conventions-no-absent-tokens-cmd [] -> Bool
  :d "Verifies that TOKEN_CONVENTIONS.md does not present absent asl tokens command as active without fallback"
  (let [(res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "asl tokens --camel"))
              "TOKEN_CONVENTIONS.md must not reference absent command asl tokens --camel")
      (assert (not (string-contains? src "asl audit tokens"))
              "TOKEN_CONVENTIONS.md must not reference absent command asl audit tokens")
      true)))

(df test-phase415-gates-no-absent-tokens-cmd [] -> Bool
  :d "Verifies that Phase415 task gates do not cite absent asl tokens command as an active gate"
  (let [(res (file-read ".asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn"))]
    (assert (= (.-_tag res) "ok") "Phase415 task collection must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src ":gate \"asl tokens --camel"))
              "Phase415 gates must not cite absent command asl tokens --camel")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43705 supervisor acceptance tests"
  (do
    (assert (test-token-conventions-no-absent-tokens-cmd) "test-token-conventions-no-absent-tokens-cmd must pass")
    (assert (test-phase415-gates-no-absent-tokens-cmd) "test-phase415-gates-no-absent-tokens-cmd must pass")
    true))
