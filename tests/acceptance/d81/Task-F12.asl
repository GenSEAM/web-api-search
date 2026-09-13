(module tests/acceptance/d81/Task-F12
  :d "Acceptance fixture for Task-F12: Enforce Non-Vacuous Execution in Supervisor Acceptance Gate under ADR-0081."
  :x [RunTests
      TestSuperviseGateParsesExecutedAssertions
      TestSuperviseGateRejectsZeroAssertionFixture
      TestTaskF12GroundedInPhaseFINSEL]
  :i [])

(df TestSuperviseGateParsesExecutedAssertions [] -> Bool
  :d "Verifies SuperviseGate.sh parses executed assertion count from test output"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "EXECUTED_ASSERTS")
              "SuperviseGate.sh must parse EXECUTED_ASSERTS from fixture output")
      (assert (string-contains? s-src "0 assertion(s) executed")
              "SuperviseGate.sh must check for zero executed assertions pattern")
      true)))

(df TestSuperviseGateRejectsZeroAssertionFixture [] -> Bool
  :d "Verifies SuperviseGate.sh has non-zero exit branch on zero or empty assertions"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "vacuous fixture execution detected")
              "SuperviseGate.sh must report vacuous fixture execution on 0 assertions")
      (assert (string-contains? s-src "exit 4")
              "SuperviseGate.sh must exit with code 4 on vacuous zero-assertion fixture")
      true)))

(df TestTaskF12GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F12 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F12\"") "Must declare Task-F12")
      (assert (string-contains? f-src "tests/acceptance/d81/SuperviseGate.sh")
              "Must own tests/acceptance/d81/SuperviseGate.sh")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F12 acceptance checks"
  (do
    (assert (TestSuperviseGateParsesExecutedAssertions) "TestSuperviseGateParsesExecutedAssertions must pass")
    (assert (TestSuperviseGateRejectsZeroAssertionFixture) "TestSuperviseGateRejectsZeroAssertionFixture must pass")
    (assert (TestTaskF12GroundedInPhaseFINSEL) "TestTaskF12GroundedInPhaseFINSEL must pass")
    true))
