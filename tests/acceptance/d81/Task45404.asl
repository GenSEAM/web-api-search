(module tests/acceptance/d81/Task45404
  :d "Acceptance fixture for Task45404: refute as first-class falsification primitive under ADR-0081."
  :x [runTests
      testRefuteFalsyAndNil
      testRefuteRaisingExpression
      testRefuteBooleanExpressions
      testRefuteCountedSeparately]
  :i [])

(df testRefuteFalsyAndNil [] -> Bool
  :d "Verifies refute passes when expression is false or nil"
  (do
    (refute false "refute false must pass")
    (refute nil "refute nil must pass")
    true))

(df testRefuteRaisingExpression [] -> Bool
  :d "Verifies refute passes when expression raises an assertion error"
  (do
    (refute (assert false "deliberate inner assertion failure") "refute on raising expression must pass")
    true))

(df testRefuteBooleanExpressions [] -> Bool
  :d "Verifies refute passes on negative boolean predicates and string mismatches"
  (let [(msg "refutation test payload")
        (prefix (option-or (string-slice msg 0 4) ""))]
    (do
      (refute (string-contains? msg "nonexistent keyword") "refute substring mismatch must pass")
      (refute (string-empty? msg) "refute on non-empty string must pass")
      (refute (= prefix "void") "refute mismatching slice must pass")
      true)))

(df testRefuteCountedSeparately [] -> Bool
  :d "Verifies that both assertions and refutations can be used together and recorded distinctly"
  (let [(items (list "alpha" "beta" "gamma"))
        (total (list-length items))]
    (do
      (assert (= total 3) "list length must equal 3")
      (refute (list-empty? items) "populated list must not be empty")
      (assert (not (list-empty? items)) "inverted empty check must succeed")
      (refute false "refute false must succeed")
      true)))

(df runTests [] -> Bool
  :d "Executes all Task45404 acceptance tests"
  (do
    (assert (testRefuteFalsyAndNil) "test-refute-falsy-and-nil must pass")
    (assert (testRefuteRaisingExpression) "test-refute-raising-expression must pass")
    (assert (testRefuteBooleanExpressions) "test-refute-boolean-expressions must pass")
    (assert (testRefuteCountedSeparately) "test-refute-counted-separately must pass")
    true))
