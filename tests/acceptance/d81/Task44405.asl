(module tests/acceptance/d81/Task44405
  :d "Acceptance fixture for Task44405: Flakiness, bottlenecks and regression detection from repeated runs under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestPlantedUnstableSuiteContract
      TestStabilityAcrossNRunsContract
      TestDurationDistributionAndRankedBottlenecksContract
      TestExecutedSetRegressionDiffContract
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

(df TestPlantedUnstableSuiteContract [] -> Bool
  :d "Verifies verifier planted a deliberately unstable suite and flakiness corpus"
  (let [(f-res (file-read "asl/bench/tasks/flaky_fixture.asl"))
        (c-res (file-read "asl/bench/tasks/flakiness_corpus.asn"))]
    (assert (= (.-_tag f-res) "ok") "asl/bench/tasks/flaky_fixture.asl must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl/bench/tasks/flakiness_corpus.asn must exist and be readable")
    (let [(f-src (.-value f-res))
          (c-src (.-value c-res))]
      (assert (string-contains? f-src "SimulateFlakyRun") "flaky_fixture.asl must implement SimulateFlakyRun")
      (assert (string-contains? c-src ":flakiness-corpus") "flakiness_corpus.asn must declare :flakiness-corpus")
      (assert (string-contains? c-src "flaky-fixture") "Corpus must include planted flaky-fixture suite")
      (assert (string-contains? c-src ":expectedStable false") "Corpus must mark flaky suite as expectedStable false")
      (assert (string-contains? c-src ":expectedGuaranteeEligible false") "Corpus must mark flaky suite as ineligible for guarantee")
      true)))

(df TestStabilityAcrossNRunsContract [] -> Bool
  :d "Verifies a suite that passes and fails across runs is reported unstable and does not count toward any guarantee"
  (let [(d-res (file-read "asl/bench/flakiness_detector.asl"))]
    (assert (= (.-_tag d-res) "ok") "asl/bench/flakiness_detector.asl must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src "EvaluateSuiteStability") "Must implement EvaluateSuiteStability")
      (assert (string-contains? d-src "counts-toward-guarantee?") "Must track counts-toward-guarantee?")
      (assert (string-contains? d-src "is-unstable?") "Must track is-unstable?")
      (assert (string-contains? d-src "pass-count") "Must track pass-count")
      (assert (string-contains? d-src "fail-count") "Must track fail-count")
      true)))

(df TestDurationDistributionAndRankedBottlenecksContract [] -> Bool
  :d "Verifies duration distribution rather than a single sample, and bottlenecks ranked by share of total wall clock"
  (let [(d-res (file-read "asl/bench/flakiness_detector.asl"))
        (t-res (file-read ".asl/mem/telemetry/StabilityAndRegression20260913.asn"))]
    (assert (= (.-_tag d-res) "ok") "asl/bench/flakiness_detector.asl must exist")
    (assert (= (.-_tag t-res) "ok") ".asl/mem/telemetry/StabilityAndRegression20260913.asn must exist")
    (let [(d-src (.-value d-res))
          (t-src (.-value t-res))]
      (assert (string-contains? d-src "min-duration-ms") "Must compute min-duration-ms")
      (assert (string-contains? d-src "max-duration-ms") "Must compute max-duration-ms")
      (assert (string-contains? d-src "mean-duration-ms") "Must compute mean-duration-ms")
      (assert (string-contains? d-src "RankBottlenecks") "Must implement RankBottlenecks")
      (assert (string-contains? t-src ":bottlenecks") "Telemetry must contain :bottlenecks section")
      (assert (string-contains? t-src "compiler-test.asl") "Telemetry must rank compiler-test bottleneck")
      (assert (string-contains? t-src "checker_test.asl") "Telemetry must rank checker_test bottleneck")
      (assert (string-contains? t-src ":wallSharePct") "Telemetry must report :wallSharePct")
      true)))

(df TestExecutedSetRegressionDiffContract [] -> Bool
  :d "Verifies an assertion that executed in previous receipt and does not now is reported as regression with both receipts named"
  (let [(d-res (file-read "asl/bench/flakiness_detector.asl"))
        (t-res (file-read ".asl/mem/telemetry/StabilityAndRegression20260913.asn"))]
    (assert (= (.-_tag d-res) "ok") "asl/bench/flakiness_detector.asl must exist")
    (assert (= (.-_tag t-res) "ok") ".asl/mem/telemetry/StabilityAndRegression20260913.asn must exist")
    (let [(d-src (.-value d-res))
          (t-src (.-value t-res))]
      (assert (string-contains? d-src "DiffExecutedAssertionSets") "Must implement DiffExecutedAssertionSets")
      (assert (string-contains? d-src "previous-receipt") "Must record previous-receipt")
      (assert (string-contains? d-src "current-receipt") "Must record current-receipt")
      (assert (string-contains? d-src "regression?") "Must flag regression?")
      (assert (string-contains? t-src ":regressions") "Telemetry must record :regressions section")
      (assert (string-contains? t-src "rc-task44403-verified-20260912") "Telemetry must name previous receipt")
      (assert (string-contains? t-src "rc-task44404-verified-20260913") "Telemetry must name current receipt")
      (assert (string-contains? t-src "newly-unreached") "Telemetry must categorize regression as newly-unreached")
      true)))

(df TestTask44405GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44405"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Flakiness, bottlenecks and regression detection from repeated runs") "Phase 444 must state Task44405 title")
      (assert (string-contains? p-src ":lane \"telemetry\"") "Phase 444 must specify telemetry lane")
      (assert (string-contains? p-src "asl/bench") "Phase 444 must own asl/bench")
      (assert (string-contains? p-src ".asl/mem/telemetry") "Phase 444 must own .asl/mem/telemetry")
      (assert (string-contains? p-src "Task44405.asl") "Phase 444 must name Task44405.asl as verification fixture")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44405 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestPlantedUnstableSuiteContract) "TestPlantedUnstableSuiteContract must pass")
    (assert (TestStabilityAcrossNRunsContract) "TestStabilityAcrossNRunsContract must pass")
    (assert (TestDurationDistributionAndRankedBottlenecksContract) "TestDurationDistributionAndRankedBottlenecksContract must pass")
    (assert (TestExecutedSetRegressionDiffContract) "TestExecutedSetRegressionDiffContract must pass")
    (assert (TestTask44405GroundedInPhase444) "TestTask44405GroundedInPhase444 must pass")
    true))
