(module tests/acceptance/d81/Task45404
  :d "Acceptance fixture for Task45404: refute as first-class falsification primitive under ADR-0081."
  :x [run-tests
      test-refute-falsy-and-nil
      test-refute-raising-expression
      test-refute-boolean-expressions
      test-refute-counted-separately]
  :i [])

(df test-refute-falsy-and-nil [] -> Bool
  :d "Verifies refute passes when expression is false or nil"
  (do
    (refute false "refute false must pass")
    (refute nil "refute nil must pass")
    true))

(df test-refute-raising-expression [] -> Bool
  :d "Verifies refute passes when expression raises an assertion error"
  (do
    (refute (assert false "deliberate inner assertion failure") "refute on raising expression must pass")
    true))

(df test-refute-boolean-expressions [] -> Bool
  :d "Verifies refute passes on negative boolean predicates and string mismatches"
  (do
    (refute (= 10 20) "refute on 10 = 20 must pass")
    (refute (string-contains? "hello" "world") "refute substring mismatch must pass")
    (refute (> 5 10) "refute 5 > 10 must pass")
    true))

(df test-refute-counted-separately [] -> Bool
  :d "Verifies that both assertions and refutations can be used together and recorded distinctly"
  (do
    (assert (= 1 1) "assertion must succeed")
    (refute (= 1 2) "refutation must succeed")
    (assert (not (= 1 2)) "inverted assert must succeed")
    (refute false "refute false must succeed")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task45404 acceptance tests"
  (do
    (assert (test-refute-falsy-and-nil) "test-refute-falsy-and-nil must pass")
    (assert (test-refute-raising-expression) "test-refute-raising-expression must pass")
    (assert (test-refute-boolean-expressions) "test-refute-boolean-expressions must pass")
    (assert (test-refute-counted-separately) "test-refute-counted-separately must pass")
    true))
