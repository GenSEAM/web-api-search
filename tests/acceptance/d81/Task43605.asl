(module tests/acceptance/d81/Task43605
  :d "Acceptance fixture for Task43605: assertion reachability and runner failure preservation."
  :x [runTests]
  :i [])

(df testAssertionReachabilityDistinctSites [] -> Bool
  :d "Verifies that assertion reachability distinguishes distinct assertion sites from dynamic execution counts"
  (let [(telemetry {:assertSites 3 :assertCount 12})
        (requiredSites 3)]
    (assert (= (.-assertSites telemetry) requiredSites) "all required assertion sites must be reached")
    (assert (> (.-assertCount telemetry) (.-assertSites telemetry)) "loop execution count exceeds site count")
    true))

(df testRunnerFailurePreservation [] -> Bool
  :d "Verifies that runner failures with exit code 1 cannot be masked by banner strings"
  (let [(result {:exitCode 1
                 :output "=== ALL TESTS PASSED CLEANLY ==="
                 :failedAssertions 1})]
    (let [(isSuccess (and (= (.-exitCode result) 0)
                           (= (.-failedAssertions result) 0)))]
      (assert (not isSuccess) "runner with non-zero exit or failed assertions must be rejected as failure")
      (assert (= (.-exitCode result) 1) "exit code 1 must be preserved")
      true)))

(df testEmptySuiteRejection [] -> Bool
  :d "Verifies that empty suites with zero assertion sites fail verification"
  (let [(emptySuite {:assertSites 0 :assertCount 0 :declaredTests 0})
        (minRequiredSites 1)]
    (let [(passes (>= (.-assertSites emptySuite) minRequiredSites))]
      (assert (not passes) "suite with zero assertion sites must not pass non-vacuity gate")
      true)))

(df runTests [] -> Bool
  :d "Runs all Task43605 acceptance tests and returns boolean true"
  (do
    (assert (testAssertionReachabilityDistinctSites) "test-assertion-reachability-distinct-sites must pass")
    (assert (testRunnerFailurePreservation) "test-runner-failure-preservation must pass")
    (assert (testEmptySuiteRejection) "test-empty-suite-rejection must pass")
    true))
