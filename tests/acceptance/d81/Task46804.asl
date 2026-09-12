(module tests/acceptance/d81/Task46804
  :d "Acceptance fixture for Task46804: dynamic state view, eliminating literal counts, and changed-since query under ADR-0081."
  :x [RunTests
      TestNoHardcodedLiteralPhaseCount
      TestStateCommandImplemented
      TestStateCommandDispatched
      TestStateChangedSinceQuery]
  :i [])

(df TestNoHardcodedLiteralPhaseCount [] -> Bool
  :d "Verifies that asl/tools/asl.c does not hardcode phase_count as literal 39"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "int phase_count = 39;"))
              "asl.c must not hardcode phase_count to literal 39")
      (assert (or (string-contains? src "count_roadmap_phases")
                  (string-contains? src "compute_phase_count"))
              "asl.c must dynamically compute phase count from roadmap")
      true)))

(df TestStateCommandImplemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_state for computed project state"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_state") "asl.c must implement run_cmd_state")
      (assert (string-contains? src "asl state") "asl.c must document asl state usage")
      true)))

(df TestStateCommandDispatched [] -> Bool
  :d "Verifies that main in asl/tools/asl.c dispatches state subcommand"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(argv[1], \"state\") == 0")
              "asl.c must dispatch state subcommand in main")
      true)))

(df TestStateChangedSinceQuery [] -> Bool
  :d "Verifies that state view supports changed-since queries filtering output"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "\"--since\"")
                  (or (string-contains? src "\"changed-since\"")
                      (string-contains? src "\"--after\"")))
              "asl.c state view must support changed-since query filtering")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46804 supervisor acceptance tests"
  (do
    (assert (TestNoHardcodedLiteralPhaseCount) "TestNoHardcodedLiteralPhaseCount must pass")
    (assert (TestStateCommandImplemented) "TestStateCommandImplemented must pass")
    (assert (TestStateCommandDispatched) "TestStateCommandDispatched must pass")
    (assert (TestStateChangedSinceQuery) "TestStateChangedSinceQuery must pass")
    true))
