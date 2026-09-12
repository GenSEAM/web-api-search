(module tests/acceptance/d81/Task47102
  :d "Acceptance fixture for Task47102: native scaffolding and staged editing operations under ADR-0081."
  :x [RunTests
      TestScaffoldSubcommandInAslC
      TestRpcStagingStatusActive]
  :i [])

(df TestScaffoldSubcommandInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_scaffold"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "run_cmd_scaffold") "asl.c must implement run_cmd_scaffold")
      (assert (string-contains? c-src "asl scaffold") "asl.c must document asl scaffold usage")
      true)))

(df TestRpcStagingStatusActive [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn registers staging operations"
  (let [(rpc-src-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-src-res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(rpc-src (.-value rpc-src-res))]
      (assert (or (string-contains? rpc-src ":status :active") (string-contains? rpc-src "asl-mem-staging"))
              "rpc.asn must register active staging operations")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47102 supervisor acceptance tests"
  (do
    (assert (TestScaffoldSubcommandInAslC) "TestScaffoldSubcommandInAslC must pass")
    (assert (TestRpcStagingStatusActive) "TestRpcStagingStatusActive must pass")
    true))
