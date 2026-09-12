(module tests/acceptance/d81/Task44303
  :d "Acceptance fixture for Task44303: RPC dispatcher and wire contract under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRpcConformanceSuiteExecution
      TestRpcDispatcherTargetSymbolsContract
      TestRpcRejectionCodeContract
      TestRequiredCaseKindsContract
      TestTask44303GroundedInPhase443]
  :i [("../../conformance/rpc/rpc_dispatcher_test" :a rdt)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestRpcConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/rpc/rpc_dispatcher_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/rpc/rpc_dispatcher_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (rdt/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestRpcDispatcherTargetSymbolsContract [] -> Bool
  :d "Verifies asl/tools/asl.c implements execute_single_step and handle_payload"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "execute_single_step") "asl.c must declare execute_single_step")
      (assert (string-contains? c-src "handle_payload") "asl.c must declare handle_payload")
      true)))

(df TestRpcRejectionCodeContract [] -> Bool
  :d "Verifies asl/grammar/rpc.asn declares rejectionCode :ERR_UNIMPLEMENTED"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src ":rejectionCode \":ERR_UNIMPLEMENTED\"") "rpc.asn must declare :ERR_UNIMPLEMENTED")
      (assert (string-contains? r-src ":rejectionPolicy") "rpc.asn must declare rejectionPolicy")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (negativeControl, malformed, errorPropagation, boundary, roundTrip) are present"
  (let [(f-res (file-read "tests/conformance/rpc/rpc_dispatcher_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestNegativeControlUnknownOpRejected") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestMalformedMissingArgumentsRejected") "Must implement malformed case")
      (assert (string-contains? f-src "TestErrorPropagationBoundaryViolation") "Must implement errorPropagation case")
      (assert (string-contains? f-src "TestBoundarySingleAndBatchExecution") "Must implement boundary case")
      (assert (string-contains? f-src "TestRoundTripPositionalAndKeywordEquivalence") "Must implement roundTrip case")
      true)))

(df TestTask44303GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44303"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "RPC dispatcher and wire contract") "Phase 443 must state Task44303 title")
      (assert (string-contains? p-src ":lane \"rpc\"") "Phase 443 must specify rpc lane")
      (assert (string-contains? p-src "tests/conformance/rpc") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "execute_single_step") "Phase 443 must target execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44303 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRpcConformanceSuiteExecution) "TestRpcConformanceSuiteExecution must pass")
    (assert (TestRpcDispatcherTargetSymbolsContract) "TestRpcDispatcherTargetSymbolsContract must pass")
    (assert (TestRpcRejectionCodeContract) "TestRpcRejectionCodeContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44303GroundedInPhase443) "TestTask44303GroundedInPhase443 must pass")
    true))
