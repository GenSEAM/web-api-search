(module tests/acceptance/d81/Task44206
  :d "Acceptance fixture for Task44206: continuous pre-flight (asl watch) under ADR-0081."
  :x [RunTests
      TestWatchSubcommandImplemented
      TestWatchRunsDelimiterCheckAndLint
      TestWatchRecordsSessionStatus]
  :i [])

(df TestWatchSubcommandImplemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_watch and dispatches watch in main"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_cmd_watch")
              "asl.c must implement run_cmd_watch")
      (assert (string-contains? c-src "strcmp(argv[1], \"watch\")")
              "asl.c must dispatch watch in main")
      (assert (string-contains? c-src "asl watch")
              "asl.c must document asl watch in help/usage")
      true)))

(df TestWatchRunsDelimiterCheckAndLint [] -> Bool
  :d "Verifies that run_cmd_watch validates delimiters and tree status"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_file_delimiters")
              "watch must check delimiters")
      (assert (string-contains? c-src "tree-status")
              "watch must report tree-status")
      true)))

(df TestWatchRecordsSessionStatus [] -> Bool
  :d "Verifies that watch updates session status in InFlight.asn"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "InFlight.asn")
              "watch must reference InFlight.asn session ledger")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44206 supervisor acceptance tests"
  (do
    (assert (TestWatchSubcommandImplemented) "TestWatchSubcommandImplemented must pass")
    (assert (TestWatchRunsDelimiterCheckAndLint) "TestWatchRunsDelimiterCheckAndLint must pass")
    (assert (TestWatchRecordsSessionStatus) "TestWatchRecordsSessionStatus must pass")
    true))
