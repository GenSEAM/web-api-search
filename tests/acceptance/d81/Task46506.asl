(module tests/acceptance/d81/Task46506
  :d "Acceptance fixture for Task46506: empirical memory telemetry and comparative evaluation under ADR-0081."
  :x [run-tests
      test-telemetry-evaluation-receipt-exists]
  :i [])

(df test-telemetry-evaluation-receipt-exists [] -> Bool
  :d "Verifies that the empirical working memory evaluation telemetry exists and contains comparative counts"
  (let [(telem-res (file-read ".asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn"))]
    (assert (= (.-_tag telem-res) "ok") "WorkingMemoryEvaluation20260912.asn must exist and be readable")
    (let [(telem (.-value telem-res))]
      (assert (string-contains? telem ":memoryWithheld") "telemetry must record memory withheld arm")
      (assert (string-contains? telem ":memoryAvailable") "telemetry must record memory available arm")
      (assert (string-contains? telem ":unsupportedClaims") "telemetry must record unsupported claims count")
      (assert (string-contains? telem ":droppedSteps") "telemetry must record dropped steps count")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46506 supervisor acceptance tests"
  (do
    (assert (test-telemetry-evaluation-receipt-exists) "test-telemetry-evaluation-receipt-exists must pass")
    true))
