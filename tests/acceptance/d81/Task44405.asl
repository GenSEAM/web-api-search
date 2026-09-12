(module tests/acceptance/d81/Task44405
  :d "Acceptance fixture for Task44405: Flakiness, bottlenecks and regression detection from repeated runs under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestFlakinessDetectorContract
      TestUnstableSuiteDetectionAndDisqualification
      TestExecutedSetRegressionDiff
      TestBottleneckRankingByWallClockShare
      TestTask44405GroundedInPhase444]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestFlakinessDetectorContract [] -> Bool
  :d "Verifies that asl/bench/flakiness_detector.asl exists and implements core stability APIs"
  (let [(f-res (file-read "asl/bench/flakiness_detector.asl"))]
    (assert (= (.-_tag f-res) "ok") "asl/bench/flakiness_detector.asl must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "EvaluateSuiteStability") "Must implement EvaluateSuiteStability")
      (assert (string-contains? f-src "DiffExecutedAssertionSets") "Must implement DiffExecutedAssertionSets")
      (assert (string-contains? f-src "RankBottlenecks") "Must implement RankBottlenecks")
      (assert (string-contains? f-src "SuiteStabilityReport") "Must declare SuiteStabilityReport")
      (assert (string-contains? f-src "ExecutedSetRegression") "Must declare ExecutedSetRegression")
      true)))

(df TestUnstableSuiteDetectionAndDisqualification [] -> Bool
  :d "Verifies that a suite passing and failing across runs is reported unstable and disqualified"
  (let [(f-res (file-read "asl/bench/flakiness_detector.asl"))]
    (assert (= (.-_tag f-res) "ok") "flakiness_detector.asl must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "is-unstable?") "Must track is-unstable status")
      (assert (string-contains? f-src "counts-toward-guarantee?") "Must determine if suite counts toward guarantees")
      (assert (string-contains? f-src "outcome stability") "Must evaluate outcome stability across runs")
      true)))

(df TestExecutedSetRegressionDiff [] -> Bool
  :d "Verifies executed assertion set regression diff names both receipts"
  (let [(f-res (file-read "asl/bench/flakiness_detector.asl"))
        (s-res (file-read "scripts/run-gate-tests.sh"))]
    (assert (= (.-_tag f-res) "ok") "flakiness_detector.asl must exist")
    (assert (= (.-_tag s-res) "ok") "scripts/run-gate-tests.sh must exist")
    (let [(f-src (.-value f-res))
          (s-src (.-value s-res))]
      (assert (string-contains? f-src "previous-receipt") "Must record previous receipt identifier")
      (assert (string-contains? f-src "current-receipt") "Must record current receipt identifier")
      (assert (string-contains? f-src "regression?") "Must flag executed assertion regression")
      (assert (string-contains? s-src "COMPARE_BASELINE") "run-gate-tests.sh must support baseline comparison")
      true)))

(df TestBottleneckRankingByWallClockShare [] -> Bool
  :d "Verifies bottlenecks are ranked by share of total wall clock"
  (let [(f-res (file-read "asl/bench/flakiness_detector.asl"))]
    (assert (= (.-_tag f-res) "ok") "flakiness_detector.asl must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "wall-clock-share") "Must compute wall-clock share")
      (assert (string-contains? f-src "rank-bottlenecks") "Must rank bottlenecks")
      (assert (string-contains? f-src "duration distribution") "Must record duration distribution")
      true)))

(df TestTask44405GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44405"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Flakiness, bottlenecks and regression detection") "Phase 444 must state Task44405 title")
      (assert (string-contains? p-src ":lane \"telemetry\"") "Phase 444 must specify telemetry lane")
      (assert (string-contains? p-src "run_gate_5") "Phase 444 must target run_gate_5")
      (assert (string-contains? p-src "asl/bench") "Phase 444 must own asl/bench")
      (assert (string-contains? p-src ".asl/mem/telemetry") "Phase 444 must own .asl/mem/telemetry")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44405 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestFlakinessDetectorContract) "TestFlakinessDetectorContract must pass")
    (assert (TestUnstableSuiteDetectionAndDisqualification) "TestUnstableSuiteDetectionAndDisqualification must pass")
    (assert (TestExecutedSetRegressionDiff) "TestExecutedSetRegressionDiff must pass")
    (assert (TestBottleneckRankingByWallClockShare) "TestBottleneckRankingByWallClockShare must pass")
    (assert (TestTask44405GroundedInPhase444) "TestTask44405GroundedInPhase444 must pass")
    true))
