(module tests/acceptance/d81/Task46703
  :d "Acceptance fixture for Task46703: real content search separated from find under ADR-0081."
  :x [run-tests
      test-grep-alias-severed-in-asl-c
      test-grep-cli-implemented
      test-rpc-registry-distinct-grep]
  :i [])

(df test-grep-alias-severed-in-asl-c [] -> Bool
  :d "Verifies that asl/tools/asl.c no longer aliases grep to find"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "strcmp(op, \"find\") == 0 || strcmp(op, \"grep\") == 0"))
              "asl.c must sever alias between grep and find")
      true)))

(df test-grep-cli-implemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_grep"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_grep") "asl.c must implement run_cmd_grep")
      (assert (string-contains? src "strcmp(argv[1], \"grep\") == 0")
              "asl.c must dispatch grep subcommand in main")
      true)))

(df test-rpc-registry-distinct-grep [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn registers grep distinctly from find"
  (let [(res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":op \"grep\"") "rpc.asn must register :op grep")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46703 supervisor acceptance tests"
  (do
    (assert (test-grep-alias-severed-in-asl-c) "test-grep-alias-severed-in-asl-c must pass")
    (assert (test-grep-cli-implemented) "test-grep-cli-implemented must pass")
    (assert (test-rpc-registry-distinct-grep) "test-rpc-registry-distinct-grep must pass")
    true))
