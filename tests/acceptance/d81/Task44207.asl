(module tests/acceptance/d81/Task44207
  :d "Acceptance fixture for Task44207: append-only session trace with digests under ADR-0081."
  :x [RunTests
      TestTraceOperatorImplementedInAslC
      TestTraceOperatorDeclaredInRpcAsn
      TestTraceSessionLedgerStructure]
  :i [])

(df TestTraceOperatorImplementedInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements :trace op and append_session_trace"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "strcmp(op, \"trace\")")
              "asl.c must handle :trace op")
      (assert (string-contains? c-src "op_trace")
              "asl.c must implement op_trace")
      (assert (string-contains? c-src "append_session_trace")
              "asl.c must implement append_session_trace")
      (assert (string-contains? c-src ":before-digest")
              "asl.c must track :before-digest")
      (assert (string-contains? c-src ":after-digest")
              "asl.c must track :after-digest")
      (assert (string-contains? c-src ":duration-ms")
              "asl.c must track :duration-ms")
      true)))

(df TestTraceOperatorDeclaredInRpcAsn [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn declares :id asl-trace"
  (let [(rpc-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-res) "ok") "asl/grammar/rpc.asn must exist")
    (let [(rpc-src (.-value rpc-res))]
      (assert (string-contains? rpc-src ":id \"asl-trace\"")
              "rpc.asn must declare asl-trace op")
      (assert (string-contains? rpc-src "(:trace")
              "rpc.asn must declare (:trace ...) syntax")
      true)))

(df TestTraceSessionLedgerStructure [] -> Bool
  :d "Verifies that asl.c references session trace storage"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "trace.asn")
              "asl.c must reference trace.asn for trace storage")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44207 supervisor acceptance tests"
  (do
    (assert (TestTraceOperatorImplementedInAslC) "TestTraceOperatorImplementedInAslC must pass")
    (assert (TestTraceOperatorDeclaredInRpcAsn) "TestTraceOperatorDeclaredInRpcAsn must pass")
    (assert (TestTraceSessionLedgerStructure) "TestTraceSessionLedgerStructure must pass")
    true))
