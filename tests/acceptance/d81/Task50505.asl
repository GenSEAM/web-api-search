(module tests/acceptance/d81/Task50505
  :d "Acceptance fixture for Task 50505: Register Missing Exported Symbols into Grammar Registries per Gate 6 and D77"
  :x [testTextGrammarSymbolsExecution
      testSqlGrammarSymbolsExecution
      testShGrammarSymbolsExecution
      testGrammarRegistriesSyntaxCheck
      testSuitesDynamicExecution
      RunTests]
  :i [(asl-text/escape :a esc)
      (asl-sql/ddl     :a ddl)
      (asl-sh/process  :a proc)
      (asl-sh/github   :a gh)])

(df testTextGrammarSymbolsExecution [] -> Bool
  :d "Dynamically evaluates UnescapeState and escape module exports"
  (let [(st (esc/UnescapeState :out "escaped" :esc false))
        (res (esc/escapeAsnStr "sample \"string\""))
        (un (esc/unescapeAsnStr "sample \\\"string\\\""))]
    (assert (= (.-out st) "escaped") "UnescapeState.out must match initialized value")
    (refute (!= (.-out st) "escaped") "UnescapeState.out must refute mismatch")
    (refute (.-esc st) "UnescapeState.esc must refute true")
    (assert (string-contains? res "\\\"") "escapeAsnStr must escape quotes")
    (refute (not (string-contains? res "\\\"")) "escapeAsnStr must refute unescaped quotes")
    (assert (= un "sample \"string\"") "unescapeAsnStr must unescape quotes")
    true))

(df testSqlGrammarSymbolsExecution [] -> Bool
  :d "Dynamically evaluates registered DDL column type constructor symbols"
  (let [(cInt (ddl/colInt64))
        (cFloat (ddl/colFloat64))
        (cText (ddl/colText))
        (cBoolean (ddl/colBoolean))
        (cBool (ddl/colBool))
        (cTimestamp (ddl/colTimestamp))]
    (assert (!= (.-_tag cInt) "") "colInt64 must construct valid type variant")
    (refute (= (.-_tag cInt) "") "colInt64 must refute empty tag")
    (assert (!= (.-_tag cFloat) "") "colFloat64 must construct valid type variant")
    (assert (!= (.-_tag cText) "") "colText must construct valid type variant")
    (assert (!= (.-_tag cBoolean) "") "colBoolean must construct valid type variant")
    (assert (!= (.-_tag cBool) "") "colBool must construct valid type variant")
    (assert (!= (.-_tag cTimestamp) "") "colTimestamp must construct valid type variant")
    (refute (= (.-_tag cTimestamp) "") "colTimestamp must refute empty tag")
    true))

(df testShGrammarSymbolsExecution [] -> Bool
  :d "Dynamically evaluates procList, procStatus, and githubCiFormat exported symbols"
  (let [(pList (proc/procList (list)))
        (pStat (proc/procStatus 10 1000 "build"))
        (ciFmt (gh/githubCiFormat (list)))]
    (assert (string-contains? pList "DAEMON") "procList must format daemon table header")
    (refute (string-empty? pList) "procList must refute empty string")
    (assert (= (.-status pStat) ":ok") "procStatus within 10ms of 1000ms deadline must be :ok")
    (refute (!= (.-status pStat) ":ok") "procStatus must refute non-:ok status")
    (assert (string-contains? ciFmt ":github-ci") "githubCiFormat must format :github-ci envelope")
    (refute (string-empty? ciFmt) "githubCiFormat must refute empty string")
    true))

(df testGrammarRegistriesSyntaxCheck [] -> Bool
  :d "Verifies grammar registries delimiter balance and syntax integrity via bin/asl check"
  (let [(res (sys-exec "bin/asl check asl/packages/asl-text/grammar.asn asl/packages/asl-sql/grammar.asn asl/packages/asl-sh/grammar.asn"))
        (code (.-exitCode res))]
    (assert (= code 0) (str "Grammar registries check must exit 0: " (.-stderr res)))
    (refute (!= code 0) "Grammar registries check must refute non-zero exit")
    true))

(df testSuitesDynamicExecution [] -> Bool
  :d "Dynamically executes test suites exercising registered symbols across packages"
  (let [(resText (sys-exec "bin/asl test asl/packages/asl-text/tests/escape_test.asl"))
        (resSql (sys-exec "bin/asl test asl/packages/asl-sql/tests/ddl_test.asl asl/packages/asl-sql/tests/sql_test.asl"))
        (resSh (sys-exec "bin/asl test asl/packages/asl-sh/tests/process_test.asl asl/packages/asl-sh/tests/github_test.asl"))]
    (assert (= (.-exitCode resText) 0) (str "escape_test must exit 0: " (.-stderr resText)))
    (refute (!= (.-exitCode resText) 0) "escape_test must not fail")
    (assert (= (.-exitCode resSql) 0) (str "sql suites must exit 0: " (.-stderr resSql)))
    (refute (!= (.-exitCode resSql) 0) "sql suites must not fail")
    (assert (= (.-exitCode resSh) 0) (str "asl-sh suites must exit 0: " (.-stderr resSh)))
    (refute (!= (.-exitCode resSh) 0) "asl-sh suites must not fail")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50505 acceptance tests"
  (do
    (assert (testTextGrammarSymbolsExecution) "testTextGrammarSymbolsExecution must pass")
    (assert (testSqlGrammarSymbolsExecution) "testSqlGrammarSymbolsExecution must pass")
    (assert (testShGrammarSymbolsExecution) "testShGrammarSymbolsExecution must pass")
    (assert (testGrammarRegistriesSyntaxCheck) "testGrammarRegistriesSyntaxCheck must pass")
    (assert (testSuitesDynamicExecution) "testSuitesDynamicExecution must pass")
    true))
