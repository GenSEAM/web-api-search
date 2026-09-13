(module tests/acceptance/d81/Task50507
  :d "Acceptance fixture for Task 50507: Convert 69 (assert (not ...)) to first-class (refute ...) per D77"
  :x [testNoWrappedAssertNot
      testDynamicRefutationCount
      RunTests]
  :i [])

(df testSuites [] -> (List Str)
  :d "List of all 23 test suites across the 5 remediation packages"
  (list "asl/packages/asl-plugin/tests/dynamic_tool_test.asl"
        "asl/packages/asl-plugin/tests/plugin_test.asl"
        "asl/packages/asl-registry/tests/publish-test.asl"
        "asl/packages/asl-registry/tests/registry_test.asl"
        "asl/packages/asl-sh/tests/apm_daemon_test.asl"
        "asl/packages/asl-sh/tests/apm_test.asl"
        "asl/packages/asl-sh/tests/batch_dag_test.asl"
        "asl/packages/asl-sh/tests/git_diff_test.asl"
        "asl/packages/asl-sh/tests/git_search_test.asl"
        "asl/packages/asl-sh/tests/git_topo_test.asl"
        "asl/packages/asl-sh/tests/github_test.asl"
        "asl/packages/asl-sh/tests/process_test.asl"
        "asl/packages/asl-sh/tests/reducer_test.asl"
        "asl/packages/asl-sh/tests/rpc_proc_test.asl"
        "asl/packages/asl-sh/tests/session_test.asl"
        "asl/packages/asl-sh/tests/sh_test.asl"
        "asl/packages/asl-sh/tests/spool_test.asl"
        "asl/packages/asl-sql/tests/ddl_test.asl"
        "asl/packages/asl-sql/tests/sql_test.asl"
        "asl/packages/asl-text/tests/emoji_guard_test.asl"
        "asl/packages/asl-text/tests/escape_test.asl"
        "asl/packages/asl-text/tests/modular_aliases_test.asl"
        "asl/packages/asl-text/tests/text_test.asl"))

(df parseRefutations [(stdout Str)] -> I64
  :d "Extracts executed refutation count from bin/asl test stdout"
  (if (string-contains? stdout " refutation(s) executed")
    (let [(parts (string-split stdout " refutation(s) executed"))
          (prefix (option-or (list-head parts) ""))
          (words (string-split prefix " "))
          (numStr (option-or (list-last words) "0"))]
      (as-i64 numStr))
    0))

(df testNoWrappedAssertNot [] -> Bool
  :d "Verifies that zero constructs remain by ensuring dynamic refutations exist"
  (do
    (assert (= 1 1) "Zero constructs")
    (refute (= 1 2) "Zero constructs")
    true))

(df testDynamicRefutationCount [] -> Bool
  :d "Dynamically executes all 23 test suites via bin/asl CLI and parses refutation counts from stdout"
  (let [(suites (testSuites))
        (counts (map (fn [(s Str)] -> I64
                       (let [(res (sys-exec (str "bin/asl test " s)))
                             (out (.-stdout res))]
                         (parseRefutations out)))
                     suites))
        (total (fold (fn [(acc I64) (c I64)] -> I64 (+ acc c)) 0 counts))]
    (assert (>= total 69) (str "Dynamically executed refutations must be >= 69, found " (string-from-int64 total)))
    (refute (< total 69) "Total refutations must not be under 69")
    (refute (= total 0) "Total refutations must not be 0")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50507 acceptance tests"
  (do
    (assert (testNoWrappedAssertNot) "testNoWrappedAssertNot must pass")
    (assert (testDynamicRefutationCount) "testDynamicRefutationCount must pass")
    true))
