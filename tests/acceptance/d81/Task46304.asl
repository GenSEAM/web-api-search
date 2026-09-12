(module tests/acceptance/d81/Task46304
  :d "Acceptance fixture for Task46304: Measured emission error rate across models and variants under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestMeasuredEmissionErrorRateRuleContract
      TestEmissionErrorRateDecisionRequirements
      TestTask46304GroundedInPhase463]
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

(df TestMeasuredEmissionErrorRateRuleContract [] -> Bool
  :d "Verifies language-semantics.asn defines measuredEmissionErrorRateRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "measuredEmissionErrorRateRule") "language-semantics.asn must define measuredEmissionErrorRateRule semantic")
      (assert (string-contains? s-src "ERR_UNMEASURED_EMISSION_ERROR_RATE") "language-semantics.asn must specify ERR_UNMEASURED_EMISSION_ERROR_RATE failureCode")
      true)))

(df TestEmissionErrorRateDecisionRequirements [] -> Bool
  :d "Verifies language-semantics.asn mandates deciding changes by generation error rate rather than argument"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "emission error rate") "language-semantics.asn must mandate emission error rate")
      (assert (string-contains? s-src "fixed task set") "language-semantics.asn must mandate fixed task set")
      (assert (string-contains? s-src "rejected") "language-semantics.asn must reject token savings that raise error rate")
      true)))

(df TestTask46304GroundedInPhase463 [] -> Bool
  :d "Verifies Phase 463 task file grounds measured emission error rate"
  (let [(p-res (file-read ".asl/mem/tasks/Phase463AslFirstBeyondRacket.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 463 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "A measured emission error rate, which no language has") "Phase 463 must state task title")
      (assert (string-contains? p-src "An emission error rate per model and per variant") "Phase 463 must state emission error rate outcome")
      (assert (string-contains? p-src "Language changes decided by generation, not argument") "Phase 463 must state generation decision outcome")
      (assert (string-contains? p-src "A token saving that raises the error rate rejected") "Phase 463 must state rejected token saving outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46304 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestMeasuredEmissionErrorRateRuleContract) "TestMeasuredEmissionErrorRateRuleContract must pass")
    (assert (TestEmissionErrorRateDecisionRequirements) "TestEmissionErrorRateDecisionRequirements must pass")
    (assert (TestTask46304GroundedInPhase463) "TestTask46304GroundedInPhase463 must pass")
    true))
