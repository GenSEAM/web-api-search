(module tests/acceptance/d81/Task47207
  :d "Acceptance fixture for Task47207: dead suites and execution deficit telemetry under ADR-0081."
  :x [RunTests
      TestSubsystemCoverageTelemetryStructure
      TestDeficitCategorization]
  :i [])

(df TestSubsystemCoverageTelemetryStructure [] -> Bool
  :d "Verifies that SubsystemCoverage20260912 telemetry exists and tracks written vs executed assertions"
  (let [(cov-res (file-read ".asl/mem/telemetry/SubsystemCoverage20260912.asn"))]
    (assert (= (.-_tag cov-res) "ok") "SubsystemCoverage20260912.asn must exist and be readable")
    (let [(content (.-value cov-res))]
      (assert (string-contains? content ":neverExecuted 810") "Telemetry must record 810 unexecuted assertions")
      (assert (string-contains? content ":deadSuites 47") "Telemetry must record 47 dead suites")
      (assert (string-contains? content "browser-plugin") "browser-plugin must be tracked")
      true)))

(df TestDeficitCategorization [] -> Bool
  :d "Verifies that runtime vs coverage density deficits are distinguished"
  (let [(cov-res (file-read ".asl/mem/telemetry/SubsystemCoverage20260912.asn"))]
    (assert (= (.-_tag cov-res) "ok") "SubsystemCoverage20260912.asn must exist and be readable")
    (let [(content (.-value cov-res))]
      (assert (string-contains? content ":thinnestByDensity") "Telemetry must track density deficits")
      (assert (string-contains? content ":observation") "Telemetry must distinguish binding vs density defects")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47207 supervisor acceptance tests"
  (do
    (assert (TestSubsystemCoverageTelemetryStructure) "TestSubsystemCoverageTelemetryStructure must pass")
    (assert (TestDeficitCategorization) "TestDeficitCategorization must pass")
    true))
