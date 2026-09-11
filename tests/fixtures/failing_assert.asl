(module tests/fixtures/failing-assert
  :d "Adversarial fixture with deliberate assertion failure to prove test runner falsifiability."
  :x [run-tests]
  :i [])

(df run-tests [] -> Bool
  :d "Deliberately asserts false to prove falsifiable test execution."
  (assert false "adversarial failure"))
