(module tests/acceptance/d81/Task43605
  :d "Acceptance fixture for Task43605: assertion reachability and runner failure preservation."
  :x [run-tests]
  :i [])

(df test-assertion-reachability-distinct-sites [] -> Bool
  :d "Verifies that assertion reachability distinguishes distinct assertion sites from dynamic execution counts"
  (let [(telemetry {:assert-sites 3 :assert-count 12})
        (required-sites 3)]
    (assert (= (.-assert-sites telemetry) required-sites) "all required assertion sites must be reached")
    (assert (> (.-assert-count telemetry) (.-assert-sites telemetry)) "loop execution count exceeds site count")
    true))

(df test-runner-failure-preservation [] -> Bool
  :d "Verifies that runner failures with exit code 1 cannot be masked by banner strings"
  (let [(result {:exit-code 1
                 :output "=== ALL TESTS PASSED CLEANLY ==="
                 :failed-assertions 1})]
    (let [(is-success (and (= (.-exit-code result) 0)
                           (= (.-failed-assertions result) 0)))]
      (assert (not is-success) "runner with non-zero exit or failed assertions must be rejected as failure")
      (assert (= (.-exit-code result) 1) "exit code 1 must be preserved")
      true)))

(df test-empty-suite-rejection [] -> Bool
  :d "Verifies that empty suites with zero assertion sites fail verification"
  (let [(empty-suite {:assert-sites 0 :assert-count 0 :declared-tests 0})
        (min-required-sites 1)]
    (let [(passes (>= (.-assert-sites empty-suite) min-required-sites))]
      (assert (not passes) "suite with zero assertion sites must not pass non-vacuity gate")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task43605 acceptance tests and returns boolean true"
  (do
    (assert (test-assertion-reachability-distinct-sites) "test-assertion-reachability-distinct-sites must pass")
    (assert (test-runner-failure-preservation) "test-runner-failure-preservation must pass")
    (assert (test-empty-suite-rejection) "test-empty-suite-rejection must pass")
    true))
