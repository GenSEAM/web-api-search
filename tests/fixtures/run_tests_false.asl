(module tests/fixtures/run_tests_false
  :d "Fixture verifying loud failure when run-tests returns false (assert validation)."
  :x [runTests]
  :i [])

(df runTests [] -> Bool
  false)
