(module tests/acceptance/d81/Task46603
  :d "Acceptance fixture for Task46603: missing orientations (stake, adaptive thinking, problem solving) under ADR-0081."
  :x [run-tests
      test-stake-orientation-present
      test-adaptive-thinking-present
      test-problem-solving-present
      test-orientations-carry-no-compliance-test]
  :i [])

(df test-stake-orientation-present [] -> Bool
  :d "Verifies that stake orientation is declared in rules.asn"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":id stake") (string-contains? src "stake"))
              "rules.asn must declare stake orientation")
      true)))

(df test-adaptive-thinking-present [] -> Bool
  :d "Verifies that adaptive thinking orientation is declared in rules.asn"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":id adaptive") (string-contains? src "adaptiveThinking"))
              "rules.asn must declare adaptive thinking orientation")
      true)))

(df test-problem-solving-present [] -> Bool
  :d "Verifies that problem solving orientation is declared in rules.asn"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":id problemSolving") (string-contains? src "problemSolving"))
              "rules.asn must declare problem solving orientation")
      true)))

(df test-orientations-carry-no-compliance-test [] -> Bool
  :d "Verifies that orientations carry no compliance test"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "(:rule :id stake :force :orientation") "stake rule must declare orientation force")
      (assert (string-contains? src "(:rule :id adaptive :force :orientation") "adaptive rule must declare orientation force")
      (assert (string-contains? src "(:rule :id problemSolving :force :orientation") "problemSolving rule must declare orientation force")
      (assert (not (string-contains? src ":id stake :force :orientation :when [:all] :tier [:orientation :full]\n    :gate")) "stake must not carry gate")
      (assert (not (string-contains? src ":id adaptive :force :orientation :when [:all] :tier [:orientation :full]\n    :gate")) "adaptive must not carry gate")
      (assert (not (string-contains? src ":id problemSolving :force :orientation :when [:all] :tier [:orientation :full]\n    :gate")) "problemSolving must not carry gate")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46603 supervisor acceptance tests"
  (do
    (assert (test-stake-orientation-present) "test-stake-orientation-present must pass")
    (assert (test-adaptive-thinking-present) "test-adaptive-thinking-present must pass")
    (assert (test-problem-solving-present) "test-problem-solving-present must pass")
    (assert (test-orientations-carry-no-compliance-test) "test-orientations-carry-no-compliance-test must pass")
    true))
