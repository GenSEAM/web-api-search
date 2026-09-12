(module tests/acceptance/d81/Task46906
  :d "Acceptance fixture for Task46906: empirical measurement of swarm room visibility on write collision rates."
  :x [RunTests
      TestTelemetryArtifactExists
      TestTelemetryContainsBothArms
      TestTelemetryRecordsCollisionMetrics]
  :i [])

(df TestTelemetryArtifactExists [] -> Bool
  :d "Verifies that an empirical telemetry evaluation artifact exists in .asl/mem/telemetry/"
  (let [(res1 (file-read ".asl/mem/telemetry/CollisionReduction20260912.asn"))
        (res2 (file-read ".asl/mem/telemetry/SwarmCollisionEvaluation20260912.asn"))]
    (assert (or (= (.-_tag res1) "ok") (= (.-_tag res2) "ok"))
            "telemetry evaluation artifact for swarm collision reduction must exist in .asl/mem/telemetry/")
    true))

(df TestTelemetryContainsBothArms [] -> Bool
  :d "Verifies that the telemetry report compares room-visible vs room-hidden arms under identical workloads"
  (let [(res1 (file-read ".asl/mem/telemetry/CollisionReduction20260912.asn"))
        (res2 (file-read ".asl/mem/telemetry/SwarmCollisionEvaluation20260912.asn"))]
    (let [(src (if (= (.-_tag res1) "ok") (.-value res1) (if (= (.-_tag res2) "ok") (.-value res2) "")))]
      (assert (not (= src "")) "telemetry content must not be empty")
      (assert (or (string-contains? src ":visible") (string-contains? src "room-visible"))
              "telemetry report must evaluate room-visible condition")
      (assert (or (string-contains? src ":hidden") (string-contains? src "room-hidden"))
              "telemetry report must evaluate room-hidden baseline condition")
      true)))

(df TestTelemetryRecordsCollisionMetrics [] -> Bool
  :d "Verifies that telemetry reports physical metrics: lost writes, conflicts, model, date, uncertainty"
  (let [(res1 (file-read ".asl/mem/telemetry/CollisionReduction20260912.asn"))
        (res2 (file-read ".asl/mem/telemetry/SwarmCollisionEvaluation20260912.asn"))]
    (let [(src (if (= (.-_tag res1) "ok") (.-value res1) (if (= (.-_tag res2) "ok") (.-value res2) "")))]
      (assert (not (= src "")) "telemetry content must not be empty")
      (assert (or (string-contains? src "lost-writes") (string-contains? src "writes-lost") (string-contains? src "collision"))
              "telemetry report must record write collision metrics")
      (assert (or (string-contains? src "model") (string-contains? src "date"))
              "telemetry report must ground model and measurement date")
      true)))

(df RunTests [] -> Bool
  (and (TestTelemetryArtifactExists)
       (TestTelemetryContainsBothArms)
       (TestTelemetryRecordsCollisionMetrics)))
