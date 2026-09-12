(module tests/acceptance/d81/Task44504
  :d "Acceptance fixture for Task44504: Concept-to-checker coverage report under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestDoctorCoverageClassesContract
      TestDoctorDistinguishesRuntimeOnlyContract
      TestGate7FailsOnNewRuleWithoutCheckContract
      TestTask44504GroundedInPhase445]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestDoctorCoverageClassesContract [] -> Bool
  :d "Verifies asl/tools/asl.c run_doctor emits structured coverage reporting for rules, invariants, decisions, and capabilities"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":coverage [") "run_doctor must emit :coverage section")
      (assert (string-contains? c-src "class \\\"rules\\\"") "coverage must include rules class")
      (assert (string-contains? c-src "class \\\"invariants\\\"") "coverage must include invariants class")
      (assert (string-contains? c-src "class \\\"decisions\\\"") "coverage must include decisions class")
      (assert (string-contains? c-src "class \\\"capabilities\\\"") "coverage must include capabilities class")
      (assert (string-contains? c-src ":unconfirmed") "coverage must report unconfirmed constraints")
      true)))

(df TestDoctorDistinguishesRuntimeOnlyContract [] -> Bool
  :d "Verifies asl/tools/asl.c run_doctor distinguishes unchecked rules from declared runtime-only rules"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":runtimeOnlyReason") "doctor must inspect runtimeOnlyReason")
      (assert (string-contains? c-src ":runtimeOnly true") "doctor must mark runtime-only rules")
      (assert (string-contains? c-src ":runtimeOnly") "coverage summary must count runtimeOnly rules")
      true)))

(df TestGate7FailsOnNewRuleWithoutCheckContract [] -> Bool
  :d "Verifies check_rule_checkers in asl/tools/asl.c fails and names any rule added without a :check field"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_rule_checkers") "asl.c must declare check_rule_checkers")
      (assert (string-contains? c-src "Constraint rule '%s' added without :check field") "Gate 7 must name missing constraint rule")
      true)))

(df TestTask44504GroundedInPhase445 [] -> Bool
  :d "Verifies Phase 445 task collection grounds Task44504"
  (let [(p-res (file-read ".asl/mem/tasks/Phase445StaticConfirmationCoverage.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 445 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Concept-to-checker coverage report") "Phase 445 must state Task44504 title")
      (assert (string-contains? p-src "Confirmation-coverage report per constraint class") "Phase 445 must state coverage outcome")
      (assert (string-contains? p-src "Unconfirmed constraints listed by name") "Phase 445 must state unconfirmed outcome")
      (assert (string-contains? p-src "New constraint without :check fails gate 7") "Phase 445 must state gate 7 outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44504 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestDoctorCoverageClassesContract) "TestDoctorCoverageClassesContract must pass")
    (assert (TestDoctorDistinguishesRuntimeOnlyContract) "TestDoctorDistinguishesRuntimeOnlyContract must pass")
    (assert (TestGate7FailsOnNewRuleWithoutCheckContract) "TestGate7FailsOnNewRuleWithoutCheckContract must pass")
    (assert (TestTask44504GroundedInPhase445) "TestTask44504GroundedInPhase445 must pass")
    true))
