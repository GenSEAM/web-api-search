(module tests/fixtures/failingAssert
  :d "Adversarial fixture with deliberate assertion failure to prove test runner falsifiability."
  :x [runTests]
  :i [])

(df runTests [] -> Bool
  :d "Deliberately asserts false to prove falsifiable test execution."
  (assert false "adversarial failure"))
