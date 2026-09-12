(module tests/acceptance/d81/Task43602
  :d "Acceptance fixture for Task43602: Boolean test results and distinct assertion site accounting."
  :x [run-tests]
  :i [])

(df test-boolean-return-contract [] -> Bool
  :d "Verifies that boolean true return is required and validated"
  (let [(result true)]
    (assert (= result true) "test entry must produce boolean true")
    true))

(df test-distinct-assertion-sites [] -> Bool
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

(df run-tests [] -> Bool
  :d "Runs all Task43602 acceptance tests and returns boolean true"
  (do
    (assert (test-boolean-return-contract) "test-boolean-return-contract must pass")
    (assert (test-distinct-assertion-sites) "test-distinct-assertion-sites must pass")
    true))
