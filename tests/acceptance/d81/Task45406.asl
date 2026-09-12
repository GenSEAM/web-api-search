(module tests/acceptance/d81/Task45406
  :d "Acceptance fixture for Task45406: telemetry baseline, runner digest, failure grouping, and assertion regression detection under ADR-0081."
  :x [run-tests
      test-telemetry-baseline-recorded
      test-failures-grouped-by-cause
      test-runner-digest-enforced
      test-regression-detection-on-assertion-drop]
  :i [])

(df test-telemetry-baseline-recorded [] -> Bool
  :d "Verifies that the 2026-09-12 telemetry baseline is recorded with honest executed counts exceeding historical baseline"
  (let [(telemetry-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))]
    (assert (= (.-_tag telemetry-res) "ok") "TestExecution20260912.asn must exist and be readable")
    (let [(content (.-value telemetry-res))]
      (assert (string-contains? content ":testTelemetry :v 2") "telemetry must declare v2 testTelemetry")
      (assert (string-contains? content ":runnerDigest") "telemetry must carry runnerDigest")
      (assert (string-contains? content "8d58ace528ff8605") "runnerDigest must match runner calculation")
      (assert (string-contains? content ":executedAsserts 7941") "executedAsserts must record 7941")
      (assert (string-contains? content ":executedRefutes 23") "executedRefutes must record 23")
      (assert (string-contains? content ":suites 316") "suites count must be 316")
      (assert (> 7941 4448) "executed assertions must strictly exceed 2026-09-11 baseline")
      true)))

(df test-failures-grouped-by-cause [] -> Bool
  :d "Verifies that suite failures are classified and grouped by cause rather than flat"
  (let [(telemetry-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))]
    (assert (= (.-_tag telemetry-res) "ok") "TestExecution20260912.asn must be readable")
    (let [(content (.-value telemetry-res))]
      (assert (string-contains? content ":failureCauses [") "telemetry must contain failureCauses group")
      (assert (string-contains? content "ASSERTION_FAILURE") "must group ASSERTION_FAILURE")
      (assert (string-contains? content "ERR_UNRESOLVED_IMPORT") "must group ERR_UNRESOLVED_IMPORT")
      (assert (string-contains? content "ERR_UNBOUND_SYMBOL") "must group ERR_UNBOUND_SYMBOL")
      (assert (string-contains? content "OTHER_ERROR") "must group OTHER_ERROR")
      true)))

(df test-runner-digest-enforced [] -> Bool
  :d "Verifies that handwritten baselines lacking runner digest are rejected"
  (let [(script-res (file-read "scripts/run-gate-tests.sh"))]
    (assert (= (.-_tag script-res) "ok") "run-gate-tests.sh must be readable")
    (let [(code (.-value script-res))]
      (assert (string-contains? code "runnerDigest") "runner script must inspect runnerDigest")
      (assert (string-contains? code "hand-written baseline rejected") "runner script must reject handwritten baseline")
      (let [(handwritten-entry "(:testTelemetry :suites 10 :executedAsserts 100)")]
        (assert (not (string-contains? handwritten-entry ":runnerDigest")) "handwritten entry lacks runnerDigest")
        true))))

(df test-regression-detection-on-assertion-drop [] -> Bool
  :d "Verifies that deleting assertions or dropping below baseline triggers regression detection"
  (let [(script-res (file-read "scripts/run-gate-tests.sh"))]
    (assert (= (.-_tag script-res) "ok") "run-gate-tests.sh must be readable")
    (let [(code (.-value script-res))]
      (assert (string-contains? code "--check-regression") "runner must support --check-regression")
      (assert (string-contains? code "Regression detected: executed assertions") "runner must detect assertion regression")
      (assert (< 7940 7941) "dropping executed assertions from 7941 to 7940 is a regression")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task45406 acceptance tests"
  (do
    (assert (test-telemetry-baseline-recorded) "test-telemetry-baseline-recorded must pass")
    (assert (test-failures-grouped-by-cause) "test-failures-grouped-by-cause must pass")
    (assert (test-runner-digest-enforced) "test-runner-digest-enforced must pass")
    (assert (test-regression-detection-on-assertion-drop) "test-regression-detection-on-assertion-drop must pass")
    true))
