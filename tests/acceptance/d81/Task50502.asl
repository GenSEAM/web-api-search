(module tests/acceptance/d81/Task50502
  :d "Acceptance fixture for Task 50502: asl-sql DDL Dialect Abstraction Restoration per D77 and D34"
  :x [testDdlDynamicExecution
      testSqlDynamicExecution
      RunTests]
  :i [])

(df testDdlDynamicExecution [] -> Bool
  :d "Verifies dynamic execution of ddl_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-sql/tests/ddl_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "asl-sql ddl_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "asl-sql ddl_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "ddl_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "ddl_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "ddl_test must not encounter assertion failures")
    true))

(df testSqlDynamicExecution [] -> Bool
  :d "Verifies dynamic execution of sql_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-sql/tests/sql_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "asl-sql sql_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "asl-sql sql_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "sql_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "sql_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "sql_test must not encounter assertion failures")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50502 acceptance tests"
  (do
    (assert (testDdlDynamicExecution) "testDdlDynamicExecution must pass")
    (assert (testSqlDynamicExecution) "testSqlDynamicExecution must pass")
    true))
