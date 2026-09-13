(module tests/acceptance/d81/Task43602
  :d "Acceptance fixture for Task43602: Boolean test results and distinct assertion site accounting."
  :x [runTests]
  :i [])

(df testBooleanReturnContract [] -> Bool
  :d "Verifies that boolean true return is required and validated"
  (let [(result true)]
    (assert (= result true) "test entry must produce boolean true")
    true))

(df testDistinctAssertionSites [] -> Bool
  :d "Verifies distinct assertion sites across functions and inside loops"
  (let [(x 10)
        (y 20)
        (items (list 1 2 3 4 5))]
    (assert (> x 0) "site 1: x must be positive")
    (assert (> y x) "site 2: y must exceed x")
    (map (fn [(item Int64)] -> Bool
           (assert (> item 0) "site 3: loop item must be positive")
           true)
         items)
    true))

(df runTests [] -> Bool
  :d "Runs all Task43602 acceptance tests and returns boolean true"
  (do
    (assert (testBooleanReturnContract) "test-boolean-return-contract must pass")
    (assert (testDistinctAssertionSites) "test-distinct-assertion-sites must pass")
    true))
