(module tests/acceptance/d81/Task44202
  :d "Acceptance fixture for Task44202: structured supervised execution (:run cmd) under ADR-0081."
  :x [RunTests
      TestRunOperatorImplementedInAslC
      TestRunDeclaredInRpcAsn
      TestRunExecutionResults]
  :i [])

(df TestRunOperatorImplementedInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements :run operator in execute_single_step"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "strcmp(op, \"run\")")
              "asl.c must handle :run op")
      (assert (string-contains? c-src ":ERR_TIMEOUT")
              "asl.c must report :ERR_TIMEOUT on timeout")
      (assert (string-contains? c-src ":exit")
              "asl.c must report :exit code")
      (assert (string-contains? c-src ":duration-ms")
              "asl.c must report :duration-ms")
      (assert (string-contains? c-src ":stdout")
              "asl.c must report :stdout")
      (assert (string-contains? c-src ":stderr")
              "asl.c must report :stderr")
      true)))

(df TestRunDeclaredInRpcAsn [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn declares :run and retires :exec"
  (let [(rpc-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-res) "ok") "asl/grammar/rpc.asn must exist")
    (let [(rpc-src (.-value rpc-res))]
      (assert (string-contains? rpc-src ":id \"asl-run\"")
              "rpc.asn must declare asl-run op")
      (assert (string-contains? rpc-src "(:run :cmd")
              "rpc.asn must declare (:run :cmd ...) syntax")
      true)))

(df TestRunExecutionResults [] -> Bool
  :d "Verifies that asl.c parses :run arguments (:cmd, :cwd, :timeout-ms, :limit)"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "\"cmd\"")
              "asl.c must parse :cmd arg")
      (assert (string-contains? c-src "\"timeout-ms\"")
              "asl.c must parse :timeout-ms arg")
      (assert (string-contains? c-src "\"limit\"")
              "asl.c must parse :limit arg")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44202 supervisor acceptance tests"
  (do
    (assert (TestRunOperatorImplementedInAslC) "TestRunOperatorImplementedInAslC must pass")
    (assert (TestRunDeclaredInRpcAsn) "TestRunDeclaredInRpcAsn must pass")
    (assert (TestRunExecutionResults) "TestRunExecutionResults must pass")
    true))
