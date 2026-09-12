(module tests/acceptance/d81/Task46601
  :d "Acceptance fixture for Task46601: four declared forces (invariant, orientation, affordance, heuristic) under ADR-0081."
  :x [run-tests
      test-four-forces-declared
      test-heuristic-defeat-condition
      test-invariant-falsifiable-gate
      test-orientation-no-compliance-test]
  :i [])

(df test-four-forces-declared [] -> Bool
  :d "Verifies that rules.asn categorizes items into four distinct forces"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":force :invariant") (string-contains? src "(:invariant"))
              "rules.asn must declare invariant force")
      (assert (or (string-contains? src ":force :orientation") (string-contains? src "(:orientation"))
              "rules.asn must declare orientation force")
      (assert (or (string-contains? src ":force :affordance") (string-contains? src "(:affordance"))
              "rules.asn must declare affordance force")
      (assert (or (string-contains? src ":force :heuristic") (string-contains? src "(:heuristic"))
              "rules.asn must declare heuristic force")
      true)))

(df test-heuristic-defeat-condition [] -> Bool
  :d "Verifies that heuristics declare their defeat condition"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":defeat") (string-contains? src ":unless") (string-contains? src ":whenDefeated"))
              "heuristics must name condition under which they fail")
      true)))

(df test-invariant-falsifiable-gate [] -> Bool
  :d "Verifies that invariants declare a gate and are bounded to seven"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":rule :id semantics :force :invariant") "semantics must be invariant")
      (assert (string-contains? src ":rule :id gates :force :invariant") "gates must be invariant")
      (assert (string-contains? src ":rule :id grading :force :invariant") "grading must be invariant")
      (assert (string-contains? src ":rule :id concepts :force :invariant") "concepts must be invariant")
      (assert (string-contains? src ":rule :id foreign :force :invariant") "foreign must be invariant")
      (assert (string-contains? src ":rule :id oneStep :force :invariant") "oneStep must be invariant")
      (assert (string-contains? src ":rule :id hiddenTests :force :invariant") "hiddenTests must be invariant")
      (assert (string-contains? src ":gate \"./bin/asl audit gates\"") "semantics/gates must have audit gate")
      (assert (string-contains? src ":gate \"sh tests/acceptance/d81/SuperviseGate.sh\"") "grading must have SuperviseGate")
      true)))

(df test-orientation-no-compliance-test [] -> Bool
  :d "Verifies that orientations do not carry compliance tests"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":rule :id output :force :orientation") "output orientation declared")
      (assert (string-contains? src ":rule :id anchor :force :orientation") "anchor orientation declared")
      (assert (string-contains? src ":rule :id edge :force :orientation") "edge orientation declared")
      (assert (not (string-contains? src ":id output :force :orientation :gate")) "output has no gate")
      (assert (not (string-contains? src ":id anchor :force :orientation :gate")) "anchor has no gate")
      (assert (not (string-contains? src ":id edge :force :orientation :gate")) "edge has no gate")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46601 supervisor acceptance tests"
  (do
    (assert (test-four-forces-declared) "test-four-forces-declared must pass")
    (assert (test-heuristic-defeat-condition) "test-heuristic-defeat-condition must pass")
    (assert (test-invariant-falsifiable-gate) "test-invariant-falsifiable-gate must pass")
    (assert (test-orientation-no-compliance-test) "test-orientation-no-compliance-test must pass")
    true))
