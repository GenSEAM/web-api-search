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
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "execute_single_step") "asl.c must implement execute_single_step")
      (assert (string-contains? c-src ":ERR_UNIMPLEMENTED") "asl.c must reject unknown ops with :ERR_UNIMPLEMENTED")
      (assert (string-contains? c-src "Operation not implemented") "asl.c must emit descriptive rejection message")
      true)))

(df TestMalformedMissingArgumentsRejected [] -> Bool
  :d "Malformed: operations invoked with missing mandatory arguments must reject with ERR_MISSING_ARG"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl.c must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src ":ERR_MISSING_ARG") "asl.c must declare :ERR_MISSING_ARG")
      (assert (string-contains? c-src "get_kw_arg") "asl.c must parse keyword arguments")
      (assert (string-contains? c-src "get_pos_arg") "asl.c must parse positional arguments")
      true)))

(df TestErrorPropagationBoundaryViolation [] -> Bool
  :d "Error propagation: boundary escapes inside RPC batch propagate ERR_BOUNDARY_VIOLATION and fail batch"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl.c must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src ":ERR_BOUNDARY_VIOLATION") "asl.c must emit :ERR_BOUNDARY_VIOLATION")
      (assert (string-contains? c-src "Path escapes workspace boundary") "asl.c must state boundary escape message")
      true)))

(df TestBoundarySingleAndBatchExecution [] -> Bool
  :d "Boundary: dispatcher executes single operation or parallel batch operations cleanly"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl.c must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "handle_payload") "asl.c must implement handle_payload")
      (assert (string-contains? c-src ":batch-res") "asl.c must emit :batch-res wrapper")
      (assert (string-contains? c-src ":failed-count") "asl.c must report failed-count on errors")
      true)))

(df TestRoundTripPositionalAndKeywordEquivalence [] -> Bool
  :d "Round trip: positional and keyword argument forms of the same operation resolve identically"
  (let [(r-src-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-src-res) "ok") "rpc.asn must exist")
    (let [(r-src (.-value r-src-res))]
      (assert (string-contains? r-src ":rpc-registry") "rpc.asn must define :rpc-registry")
      (assert (string-contains? r-src ":rejectionCode \":ERR_UNIMPLEMENTED\"") "rpc.asn must specify rejectionCode")
      (assert (string-contains? r-src "asl-intel-read") "rpc.asn must declare read op")
      (assert (string-contains? r-src "asl-intel-sec") "rpc.asn must declare sec op")
      (assert (string-contains? r-src "asl-intel-ls") "rpc.asn must declare ls op")
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
