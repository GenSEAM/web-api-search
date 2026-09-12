(module tests/acceptance/d81/Task46801
  :d "Acceptance fixture for Task46801: three kinds distinguished by closure condition under ADR-0081."
  :x [RunTests
      TestRecordsClosureContractsDefined
      TestRecordWithoutClosureRefused
      TestUnevaluableClosureRefused
      TestGoalClosedByEvaluation]
  :i [(asl-mem/records :a records)])

(df TestRecordsClosureContractsDefined [] -> Bool
  :d "Verifies that mem/src/records.asl defines lifecycle kinds and closure evaluation functions"
  (let [(res (file-read "mem/src/records.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/records.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "intent") "records.asl must declare intent kind")
      (assert (string-contains? src "goal") "records.asl must declare goal kind")
      (assert (string-contains? src "practice") "records.asl must declare practice kind")
      (assert (string-contains? src "evaluate-closure") "records.asl must define evaluate-closure")
      (assert (string-contains? src "validate-closure-condition") "records.asl must define validate-closure-condition")
      (assert (string-contains? src "is-closure-evaluable?") "records.asl must define is-closure-evaluable?")
      true)))

(df TestRecordWithoutClosureRefused [] -> Bool
  :d "Verifies that records without closure conditions are refused at creation and memory ledgers declare closures"
  (let [(intent-res (file-read ".asl/mem/intent.asn"))
        (prac-res (file-read ".asl/mem/practices.asn"))]
    (assert (= (.-_tag intent-res) "ok") ".asl/mem/intent.asn must exist and be readable")
    (assert (= (.-_tag prac-res) "ok") ".asl/mem/practices.asn must exist and be readable")
    (let [(intent-src (.-value intent-res))
          (prac-src (.-value prac-res))]
      (assert (string-contains? prac-src "PRAC-001") "PRAC-001 must be defined")
      (assert (string-contains? prac-src "PRAC-002") "PRAC-002 must be defined")
      (assert (string-contains? prac-src "PRAC-003") "PRAC-003 must be defined")
      (assert (string-contains? prac-src "PRAC-004") "PRAC-004 must be defined")
      (assert (string-contains? prac-src "PRAC-005") "PRAC-005 must be defined")
      (assert (string-contains? prac-src "PRAC-006") "PRAC-006 must be defined")
      (assert (string-contains? prac-src "PRAC-007") "PRAC-007 must be defined")
      (assert (string-contains? prac-src "PRAC-008") "PRAC-008 must be defined")
      (assert (string-contains? prac-src "PRAC-009") "PRAC-009 must be defined")
      (assert (string-contains? prac-src "PRAC-010") "PRAC-010 must be defined")
      (assert (>= (list-length (string-split prac-src ":closure")) 11) "practices.asn must declare :closure for all practices")
      (assert (string-contains? intent-src "(:id \"d1\"") "d1 must be defined")
      (assert (string-contains? intent-src "(:id \"d2\"") "d2 must be defined")
      (assert (string-contains? intent-src "(:id \"d10\"") "d10 must be defined")
      (assert (string-contains? intent-src "(:id \"d20\"") "d20 must be defined")
      (assert (string-contains? intent-src "(:id \"d30\"") "d30 must be defined")
      (assert (string-contains? intent-src "(:id \"d40\"") "d40 must be defined")
      (assert (string-contains? intent-src "(:id \"d50\"") "d50 must be defined")
      (assert (string-contains? intent-src "(:id \"d53\"") "d53 must be defined")
      (assert (string-contains? intent-src "(:id \"c1\"") "c1 must be defined")
      (assert (string-contains? intent-src "(:id \"c2\"") "c2 must be defined")
      (assert (string-contains? intent-src "(:id \"c3\"") "c3 must be defined")
      (assert (>= (list-length (string-split intent-src ":closure")) 60) "intent.asn records must declare closure conditions")
      (let [(invalid-cond (records/make-closure-condition "invalid" "" "" false))
            (valid-cond (records/make-closure-condition "observable-satisfied" "sh test.sh" "exit 0" true))]
        (assert (not (records/validate-closure-condition invalid-cond)) "record without valid closure condition must be refused")
        (assert (records/validate-closure-condition valid-cond) "record with evaluable closure condition must be accepted")
        true))))

(df TestUnevaluableClosureRefused [] -> Bool
  :d "Verifies that a closure condition that no command can evaluate is refused"
  (let [(res (file-read "mem/src/records.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/records.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "unevaluable") "records.asl must handle unevaluable closure conditions")
      (assert (string-contains? src "refuse-unevaluable-closure") "records.asl must define refuse-unevaluable-closure")
      (let [(refusal (records/refuse-unevaluable-closure "command not executable"))
            (uneval-cond (records/make-closure-condition "reason-invalidated" "unevaluable" "cannot verify" true))
            (uneval-flag (records/make-closure-condition "reason-invalidated" "check" "done" false))]
        (assert (string-contains? refusal "refused: unevaluable closure condition") "refusal message must specify unevaluable closure")
        (assert (not (records/is-closure-evaluable? uneval-cond)) "condition with unevaluable string must be rejected")
        (assert (not (records/is-closure-evaluable? uneval-flag)) "condition with evaluable=false must be rejected")
        true))))

(df TestGoalClosedByEvaluation [] -> Bool
  :d "Verifies that a goal whose observable is true is closed by evaluation not by hand"
  (let [(res (file-read "mem/src/records.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/records.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "close-goal-by-evaluation") "records.asl must define close-goal-by-evaluation")
      (assert (string-contains? src "observable") "records.asl must evaluate goal observable")
      (let [(cond (records/make-closure-condition "observable-satisfied" "./bin/asl test" "exit 0" true))
            (goal-rec (records/make-lifecycle-record "G-46801" "goal" "Close by evaluation" "Observable verified" cond "active"))]
        (let [(unclosed (records/close-goal-by-evaluation goal-rec false))
              (closed (records/close-goal-by-evaluation goal-rec true))]
          (assert (= (.-status unclosed) "active") "goal with unsatisfied observable must remain active")
          (assert (= (.-status closed) "fulfilled") "goal with satisfied observable must transition to fulfilled by evaluation")
          true)))))

(df RunTests [] -> Bool
  :d "Executes all Task46801 supervisor acceptance tests"
  (do
    (assert (TestRecordsClosureContractsDefined) "TestRecordsClosureContractsDefined must pass")
    (assert (TestRecordWithoutClosureRefused) "TestRecordWithoutClosureRefused must pass")
    (assert (TestUnevaluableClosureRefused) "TestUnevaluableClosureRefused must pass")
    (assert (TestGoalClosedByEvaluation) "TestGoalClosedByEvaluation must pass")
    true))
