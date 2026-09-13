(module tests/acceptance/d81/Task-F01
  :d "Acceptance fixture for Task-F01: Wire Dynamic Verification into C Host RPC Gate under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestCSourceRpcGateDynamicExecution
      TestRpcGateNoHardcodedStaticMock
      TestTaskF01GroundedInPhaseFINSEL]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestCSourceRpcGateDynamicExecution [] -> Bool
  :d "Verifies that asl/tools/asl.c wires dynamic verification into op_gate instead of static mock"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "op_gate(") "asl.c must define op_gate function")
      (assert (string-contains? c-src ":dynamic true") "asl.c op_gate must emit :dynamic true indicator")
      (assert (string-contains? c-src ":passedGates") "asl.c op_gate must emit :passedGates count")
      (assert (string-contains? c-src ":verdicts") "asl.c op_gate must emit :verdicts list")
      true)))

(df TestRpcGateNoHardcodedStaticMock [] -> Bool
  :d "Verifies that asl/tools/asl.c does not contain hardcoded static mock for RPC gate"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (not (string-contains? c-src ":status \\\"ok\\\" :allClean true :passed 7 :active 7 :total 7"))
              "asl.c must not contain hardcoded gate mock string")
      true)))

(df TestTaskF01GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F01 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F01\"") "Must declare Task-F01")
      (assert (string-contains? f-src "asl/tools/asl.c") "Must own asl/tools/asl.c")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F01 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestCSourceRpcGateDynamicExecution) "TestCSourceRpcGateDynamicExecution must pass")
    (assert (TestRpcGateNoHardcodedStaticMock) "TestRpcGateNoHardcodedStaticMock must pass")
    (assert (TestTaskF01GroundedInPhaseFINSEL) "TestTaskF01GroundedInPhaseFINSEL must pass")
    true))
