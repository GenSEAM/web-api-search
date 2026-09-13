(module tests/acceptance/d81/Task50504
  :d "Acceptance fixture for Task 50504: Purge Orphaned Grammar Symbols per Gate 6 and D77"
  :x [testShGrammarLocalExecution
      testPluginGrammarLocalExecution
      testLegitimateEstimateTokensExecution
      testGrammarRegistriesSyntaxCheck
      RunTests]
  :i [(asl-sh/batchDag        :a bd)
      (asl-plugin/dynamicTool :a dt)
      (asl-text/text          :a txt)])

(df testShGrammarLocalExecution [] -> Bool
  :d "Verifies functional execution of legitimate local exports from asl-sh"
  (let [(step (bd/dagStepCreate 10 "audit" "gate" "run" (list)))
        (plan (bd/dagPlanCreate "seq" (list step)))]
    (assert (= (.-id step) 10) "Step ID must match 10")
    (refute (!= (.-id step) 10) "Step ID must refute mismatch")
    (assert (= (.-op step) "gate") "Step op must match gate")
    (assert (.-isValid plan) "Plan must be valid")
    (refute (not (.-isValid plan)) "Plan must refute invalid")
    true))

(df testPluginGrammarLocalExecution [] -> Bool
  :d "Verifies functional execution of legitimate local exports from asl-plugin"
  (let [(tool (dt/createTool "eval" "core" (list) "Any" "Evaluates ASL expression" ""))
        (plane (dt/emptyPlane))]
    (assert (= (.-name tool) "eval") "Tool name must match eval")
    (refute (!= (.-name tool) "eval") "Tool name must refute mismatch")
    (assert (= (.-domain tool) "core") "Tool domain must match core")
    (assert (= (dt/toolCount plane) 4) "Empty plane must have 4 base tools")
    (refute (!= (dt/toolCount plane) 4) "Tool count must refute not 4")
    true))

(df testLegitimateEstimateTokensExecution [] -> Bool
  :d "Dynamically evaluates estimateTokens in its legitimate origin package (asl-text)"
  (let [(toks (txt/estimateTokens "Pure AgentScript token evaluation"))
        (res (sys-exec "bin/asl test asl/packages/asl-text/tests/text_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (> toks 0) "Token estimate must return positive count")
    (refute (<= toks 0) "Token estimate must refute <= 0")
    (assert (= code 0) (str "asl-text text_test must pass: " (.-stderr res)))
    (refute (!= code 0) "text_test must exit 0")
    (assert (string-contains? stdout "assertion(s) executed") "text_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "text_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "text_test must not fail")
    true))

(df testGrammarRegistriesSyntaxCheck [] -> Bool
  :d "Verifies grammar registries delimiter balance and syntax integrity via bin/asl check"
  (let [(res (sys-exec "bin/asl check asl/packages/asl-sh/grammar.asn asl/packages/asl-plugin/grammar.asn"))
        (code (.-exitCode res))]
    (assert (= code 0) (str "Grammar files must pass check: " (.-stderr res)))
    (refute (!= code 0) "Grammar check must refute non-zero exit")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50504 acceptance tests"
  (do
    (assert (testShGrammarLocalExecution) "testShGrammarLocalExecution must pass")
    (assert (testPluginGrammarLocalExecution) "testPluginGrammarLocalExecution must pass")
    (assert (testLegitimateEstimateTokensExecution) "testLegitimateEstimateTokensExecution must pass")
    (assert (testGrammarRegistriesSyntaxCheck) "testGrammarRegistriesSyntaxCheck must pass")
    true))
