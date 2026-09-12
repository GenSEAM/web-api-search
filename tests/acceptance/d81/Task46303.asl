(module tests/acceptance/d81/Task46303
  :d "Acceptance fixture for Task46303: Bounded binding-to-use distance and self-describing bindings under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestBindingToUseDistanceRuleContract
      TestBindingDistanceBoundedLocalityRequirements
      TestTask46303GroundedInPhase463]
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

(df TestBindingToUseDistanceRuleContract [] -> Bool
  :d "Verifies language-semantics.asn defines bindingToUseDistanceRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "bindingToUseDistanceRule") "language-semantics.asn must define bindingToUseDistanceRule semantic")
      (assert (string-contains? s-src "ERR_UNBOUNDED_BINDING_DISTANCE") "language-semantics.asn must specify ERR_UNBOUNDED_BINDING_DISTANCE failureCode")
      true)))

(df TestBindingDistanceBoundedLocalityRequirements [] -> Bool
  :d "Verifies language-semantics.asn mandates bounded distance and self-describing bindings"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "bounded") "language-semantics.asn must mandate bounded distance")
      (assert (string-contains? s-src "self-describing") "language-semantics.asn must mandate self-describing bindings")
      (assert (string-contains? s-src "slice") "language-semantics.asn must mandate slice interpretability")
      true)))

(df TestTask46303GroundedInPhase463 [] -> Bool
  :d "Verifies Phase 463 task file grounds binding-to-use distance"
  (let [(p-res (file-read ".asl/mem/tasks/Phase463AslFirstBeyondRacket.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 463 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "A binding is never far from its use") "Phase 463 must state task title")
      (assert (string-contains? p-src "Binding to use distance measured and bounded") "Phase 463 must state bounded distance outcome")
      (assert (string-contains? p-src "Self describing bindings where distance is unavoidable") "Phase 463 must state self-describing outcome")
      (assert (string-contains? p-src "A slice interpretable without the rest of its file") "Phase 463 must state slice interpretability outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46303 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestBindingToUseDistanceRuleContract) "TestBindingToUseDistanceRuleContract must pass")
    (assert (TestBindingDistanceBoundedLocalityRequirements) "TestBindingDistanceBoundedLocalityRequirements must pass")
    (assert (TestTask46303GroundedInPhase463) "TestTask46303GroundedInPhase463 must pass")
    true))
