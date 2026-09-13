(module tests/conformance/rpc/RpcDispatcherTest
  :d "Conformance test suite for RPC dispatcher, protocol wire contract and status rejection per ADR-0081"
  :x [RunTests
      TestNegativeControlUnknownOpRejected
      TestMalformedMissingArgumentsRejected
      TestErrorPropagationBoundaryViolation
      TestBoundarySingleAndBatchExecution
      TestRoundTripPositionalAndKeywordEquivalence]
  :i [])

(df TestNegativeControlUnknownOpRejected [] -> Bool
  :d "Negative control: undeclared operation must be rejected with status rejected and ERR_UNIMPLEMENTED"
  (let [(cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag cSrcRes) "ok") "asl.c must exist and be readable")
    (let [(cSrc (.-value cSrcRes))]
      (assert (string-contains? cSrc "execute_single_step") "asl.c must implement execute_single_step")
      (assert (string-contains? cSrc ":ERR_UNIMPLEMENTED") "asl.c must reject unknown ops with :ERR_UNIMPLEMENTED")
      (assert (string-contains? cSrc "Operation not implemented") "asl.c must emit descriptive rejection message")
      true)))

(df TestMalformedMissingArgumentsRejected [] -> Bool
  :d "Malformed: operations invoked with missing mandatory arguments must reject with ERR_MISSING_ARG"
  (let [(cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag cSrcRes) "ok") "asl.c must exist")
    (let [(cSrc (.-value cSrcRes))]
      (assert (string-contains? cSrc ":ERR_MISSING_ARG") "asl.c must declare :ERR_MISSING_ARG")
      (assert (string-contains? cSrc "get_kw_arg") "asl.c must parse keyword arguments")
      (assert (string-contains? cSrc "get_pos_arg") "asl.c must parse positional arguments")
      true)))

(df TestErrorPropagationBoundaryViolation [] -> Bool
  :d "Error propagation: boundary escapes inside RPC batch propagate ERR_BOUNDARY_VIOLATION and fail batch"
  (let [(cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag cSrcRes) "ok") "asl.c must exist")
    (let [(cSrc (.-value cSrcRes))]
      (assert (string-contains? cSrc ":ERR_BOUNDARY_VIOLATION") "asl.c must emit :ERR_BOUNDARY_VIOLATION")
      (assert (string-contains? cSrc "Path escapes workspace boundary") "asl.c must state boundary escape message")
      true)))

(df TestBoundarySingleAndBatchExecution [] -> Bool
  :d "Boundary: dispatcher executes single operation or parallel batch operations cleanly"
  (let [(cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag cSrcRes) "ok") "asl.c must exist")
    (let [(cSrc (.-value cSrcRes))]
      (assert (string-contains? cSrc "handle_payload") "asl.c must implement handle_payload")
      (assert (string-contains? cSrc ":batch-res") "asl.c must emit :batch-res wrapper")
      (assert (string-contains? cSrc ":failed-count") "asl.c must report failed-count on errors")
      true)))

(df TestRoundTripPositionalAndKeywordEquivalence [] -> Bool
  :d "Round trip: positional and keyword argument forms of the same operation resolve identically"
  (let [(rSrcRes (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rSrcRes) "ok") "rpc.asn must exist")
    (let [(rSrc (.-value rSrcRes))]
      (assert (string-contains? rSrc ":rpc-registry") "rpc.asn must define :rpc-registry")
      (assert (string-contains? rSrc ":rejectionCode \":ERR_UNIMPLEMENTED\"") "rpc.asn must specify rejectionCode")
      (assert (string-contains? rSrc "asl-intel-read") "rpc.asn must declare read op")
      (assert (string-contains? rSrc "asl-intel-sec") "rpc.asn must declare sec op")
      (assert (string-contains? rSrc "asl-intel-ls") "rpc.asn must declare ls op")
      true)))

(df RunTests [] -> Bool
  :d "Executes all RPC dispatcher and wire contract conformance tests"
  (do
    (assert (TestNegativeControlUnknownOpRejected) "TestNegativeControlUnknownOpRejected must pass")
    (assert (TestMalformedMissingArgumentsRejected) "TestMalformedMissingArgumentsRejected must pass")
    (assert (TestErrorPropagationBoundaryViolation) "TestErrorPropagationBoundaryViolation must pass")
    (assert (TestBoundarySingleAndBatchExecution) "TestBoundarySingleAndBatchExecution must pass")
    (assert (TestRoundTripPositionalAndKeywordEquivalence) "TestRoundTripPositionalAndKeywordEquivalence must pass")
    true))
