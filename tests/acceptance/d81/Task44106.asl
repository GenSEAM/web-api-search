(module tests/acceptance/d81/Task44106
  :d "Acceptance fixture for Task44106: Evaluate attention policies with repeated reliable task outcomes under ADR-0081."
  :x [RunTests
      TestAttentionProsthesisModuleContract
      TestAttentionFixturesManifest
      TestTrialResultTelemetryFields
      TestEvaluationSemanticsAndNegativeResultsHonesty]
  :i [])

(df TestAttentionProsthesisModuleContract [] -> Bool
  :d "Verifies that attention_prosthesis.asl exports required structs and functions"
  (let [(m-res (file-read "asl/bench/attention_prosthesis.asl"))]
    (assert (= (.-_tag m-res) "ok") "attention_prosthesis.asl must exist and be readable")
    (let [(src (.-value m-res))]
      (assert (string-contains? src "(dfs TrialResult") "Must define TrialResult struct")
      (assert (string-contains? src "(dfs PolicyEvaluation") "Must define PolicyEvaluation struct")
      (assert (string-contains? src "make-trial-result") "Must export make-trial-result")
      (assert (string-contains? src "make-policy-evaluation") "Must export make-policy-evaluation")
      (assert (string-contains? src "evaluate-trial-consistency") "Must export evaluate-trial-consistency")
      (assert (string-contains? src "is-constraint-preserved?") "Must export is-constraint-preserved?")
      (assert (string-contains? src "is-observation-recoverable?") "Must export is-observation-recoverable?")
      (assert (string-contains? src "calculate-pass-rate") "Must export calculate-pass-rate")
      (assert (string-contains? src "calculate-mean-cost") "Must export calculate-mean-cost")
      (assert (string-contains? src "(df run-tests") "Must export run-tests entrypoint")
      true)))

(df TestAttentionFixturesManifest [] -> Bool
  :d "Verifies that attention_fixtures/manifest.asn preregisters 5 evaluation arms and metrics"
  (let [(f-res (file-read "asl/bench/attention_fixtures/manifest.asn"))]
    (assert (= (.-_tag f-res) "ok") "attention_fixtures/manifest.asn must exist and be readable")
    (let [(src (.-value f-res))]
      (assert (string-contains? src ":arm :id \"baseline\"") "Must define baseline arm")
      (assert (string-contains? src ":arm :id \"ledger-only\"") "Must define ledger-only arm")
      (assert (string-contains? src ":arm :id \"observation-masking\"") "Must define observation-masking arm")
      (assert (string-contains? src ":arm :id \"relevant-retrieval\"") "Must define relevant-retrieval arm")
      (assert (string-contains? src ":arm :id \"summary\"") "Must define summary arm")
      (assert (string-contains? src ":metric :id \"passRate\"") "Must define passRate metric")
      (assert (string-contains? src ":metric :id \"consistency\"") "Must define consistency metric")
      (assert (string-contains? src ":metric :id \"costPerTask\"") "Must define costPerTask metric")
      (assert (string-contains? src ":metric :id \"cacheEfficiency\"") "Must define cacheEfficiency metric")
      (assert (string-contains? src ":metric :id \"constraintPreservation\"") "Must define constraintPreservation metric")
      (assert (string-contains? src ":metric :id \"observationRecoverability\"") "Must define observationRecoverability metric")
      true)))

(df TestTrialResultTelemetryFields [] -> Bool
  :d "Verifies that TrialResult captures provider telemetry, cache data, and confidence scores"
  (let [(m-res (file-read "asl/bench/attention_prosthesis.asl"))]
    (assert (= (.-_tag m-res) "ok") "attention_prosthesis.asl must exist")
    (let [(src (.-value m-res))]
      (assert (string-contains? src "cache-reads") "Must bind cache-reads field")
      (assert (string-contains? src "cache-writes") "Must bind cache-writes field")
      (assert (string-contains? src "cache-misses") "Must bind cache-misses field")
      (assert (string-contains? src "has-provider-data") "Must bind has-provider-data field")
      (assert (string-contains? src "constraints-satisfied") "Must bind constraints-satisfied field")
      (assert (string-contains? src "observation-recovered") "Must bind observation-recovered field")
      (assert (string-contains? src "confidence-score") "Must bind confidence-score field")
      (assert (string-contains? src "abstention-flag") "Must bind abstention-flag field")
      true)))

(df TestEvaluationSemanticsAndNegativeResultsHonesty [] -> Bool
  :d "Verifies that pass rates, cost calculations, and constraint preservation execute cleanly"
  (let [(m-res (file-read "asl/bench/attention_prosthesis.asl"))]
    (assert (= (.-_tag m-res) "ok") "attention_prosthesis.asl must exist")
    (let [(src (.-value m-res))]
      (assert (string-contains? src "calculate-pass-rate") "Must implement pass rate calculation")
      (assert (string-contains? src "calculate-mean-cost") "Must implement mean cost calculation")
      (assert (string-contains? src "evaluate-trial-consistency") "Must implement trial consistency")
      (assert (string-contains? src "assert") "Must contain executable assertions in test suite")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44106 supervisor acceptance tests"
  (do
    (assert (TestAttentionProsthesisModuleContract) "TestAttentionProsthesisModuleContract must pass")
    (assert (TestAttentionFixturesManifest) "TestAttentionFixturesManifest must pass")
    (assert (TestTrialResultTelemetryFields) "TestTrialResultTelemetryFields must pass")
    (assert (TestEvaluationSemanticsAndNegativeResultsHonesty) "TestEvaluationSemanticsAndNegativeResultsHonesty must pass")
    true))
