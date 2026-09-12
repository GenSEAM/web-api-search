(module tests/acceptance/d81/Task46907
  :d "Acceptance fixture for Task46907: ad hoc composition, reduction outside the model, and bounded outputs."
  :x [RunTests
      TestComposeRpcOpRegistered
      TestAslCSupportsComposition
      TestUnboundedLogRefusalDocumented]
  :i [])

(df TestComposeRpcOpRegistered [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn registers ad hoc composition or pipeline operation"
  (let [(res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "compose") (string-contains? src "pipe") (string-contains? src "reduce"))
              "rpc.asn must register compose/pipe/reduce RPC operation")
      true)))

(df TestAslCSupportsComposition [] -> Bool
  :d "Verifies that asl/tools/asl.c implements RPC composition or bounded reduction logic"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "compose") (string-contains? src "op_compose") (string-contains? src "rpc_compose"))
              "asl.c must implement RPC composition logic")
      true)))

(df TestUnboundedLogRefusalDocumented [] -> Bool
  :d "Verifies that asl.c or rpc.asn defines truncation notice and refuses unreduced log-shaped output"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "truncated") (string-contains? src "TRUNCATED") (string-contains? src "ERR_UNBOUNDED"))
              "asl.c must handle output truncation or log refusal")
      true)))

(df RunTests [] -> Bool
  (and (TestComposeRpcOpRegistered)
       (TestAslCSupportsComposition)
       (TestUnboundedLogRefusalDocumented)))
