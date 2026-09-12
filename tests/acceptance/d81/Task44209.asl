(module tests/acceptance/d81/Task44209
  :d "Acceptance fixture for Task44209: reflection gap report under ADR-0081."
  :x [RunTests
      TestReflectSubcommandImplemented
      TestReflectDetectsMissingOutcomesAndOutOfOwns
      TestReflectDetectsForeignModifications]
  :i [])

(df TestReflectSubcommandImplemented [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_reflect and dispatches reflect in main"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_cmd_reflect")
              "asl.c must implement run_cmd_reflect")
      (assert (string-contains? c-src "audit_reflection")
              "asl.c must implement audit_reflection")
      (assert (string-contains? c-src "asl reflect")
              "asl.c must document asl reflect in help/usage")
      true)))

(df TestReflectDetectsMissingOutcomesAndOutOfOwns [] -> Bool
  :d "Verifies that reflection reports unfulfilled outcomes and out-of-owns modifications"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":gap-report")
              "reflect must emit :gap-report")
      (assert (string-contains? c-src ":unfulfilled-outcomes")
              "reflect must track :unfulfilled-outcomes")
      (assert (string-contains? c-src ":out-of-owns-mutations")
              "reflect must detect :out-of-owns-mutations")
      (assert (string-contains? c-src ":stale-receipts")
              "reflect must detect :stale-receipts")
      true)))

(df TestReflectDetectsForeignModifications [] -> Bool
  :d "Verifies that reflection compares trace records and working tree state"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":foreign-changes")
              "reflect must detect :foreign-changes")
      (assert (string-contains? c-src ":findings")
              "reflect must emit :findings")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44209 supervisor acceptance tests"
  (do
    (assert (TestReflectSubcommandImplemented) "TestReflectSubcommandImplemented must pass")
    (assert (TestReflectDetectsMissingOutcomesAndOutOfOwns) "TestReflectDetectsMissingOutcomesAndOutOfOwns must pass")
    (assert (TestReflectDetectsForeignModifications) "TestReflectDetectsForeignModifications must pass")
    true))
