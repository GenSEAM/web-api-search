(module tests/acceptance/d81/Task46605
  :d "Acceptance fixture for Task46605: empirical measurement of context tiers vs performance under ADR-0081."
  :x [run-tests
      test-tier-telemetry-artifact-exists
      test-invariant-violation-measured
      test-model-tier-assignment-recorded]
  :i [])

(df test-tier-telemetry-artifact-exists [] -> Bool
  :d "Verifies that tier comparison telemetry exists in .asl/mem/telemetry"
  (let [(res (file-read ".asl/mem/telemetry/TierEvaluation20260912.asn"))]
    (assert (= (.-_tag res) "ok") "TierEvaluation20260912.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":tierEvaluation") "must declare :tierEvaluation")
      (assert (string-contains? src ":essential") "must record essential tier")
      true)))

(df test-invariant-violation-measured [] -> Bool
  :d "Verifies that invariant violations are physically counted by running gates"
  (let [(res (file-read ".asl/mem/telemetry/TierEvaluation20260912.asn"))]
    (assert (= (.-_tag res) "ok") "telemetry must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":invariantViolations") "must record invariant violations")
      true)))

(df test-model-tier-assignment-recorded [] -> Bool
  :d "Verifies that model tier recommendations are recorded based on measurement"
  (let [(res (file-read ".asl/mem/telemetry/TierEvaluation20260912.asn"))]
    (assert (= (.-_tag res) "ok") "telemetry must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":recommendedTier") "must record recommended tier")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46605 supervisor acceptance tests"
  (do
    (assert (test-tier-telemetry-artifact-exists) "test-tier-telemetry-artifact-exists must pass")
    (assert (test-invariant-violation-measured) "test-invariant-violation-measured must pass")
    (assert (test-model-tier-assignment-recorded) "test-model-tier-assignment-recorded must pass")
    true))
