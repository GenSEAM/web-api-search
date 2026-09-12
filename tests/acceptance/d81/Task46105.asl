(module tests/acceptance/d81/Task46105
  :d "Acceptance fixture for Task46105: Data and view adapters as extensions under two-strikes rule under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTwoStrikesAdapterAdmissionContract
      TestAdapterAdmissionInDependencyBoundaries
      TestTask46105GroundedInPhase461]
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

(df TestTwoStrikesAdapterAdmissionContract [] -> Bool
  :d "Verifies language-semantics.asn defines twoStrikesAdapterAdmission semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "twoStrikesAdapterAdmission") "language-semantics.asn must define twoStrikesAdapterAdmission semantic")
      (assert (string-contains? s-src "ERR_PREMATURE_GENERALIZATION") "language-semantics.asn must specify ERR_PREMATURE_GENERALIZATION failureCode")
      true)))

(df TestAdapterAdmissionInDependencyBoundaries [] -> Bool
  :d "Verifies dependency-boundaries.asn defines adapter admission and two-strikes rule"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src ":adapterAdmission") "dependency-boundaries.asn must specify adapterAdmission")
      (assert (string-contains? d-src "twoStrikesRule") "dependency-boundaries.asn must specify twoStrikesRule")
      true)))

(df TestTask46105GroundedInPhase461 [] -> Bool
  :d "Verifies Phase 461 task file grounds two-strikes adapter admission"
  (let [(p-res (file-read ".asl/mem/tasks/Phase461CoreAndInterchangeableExtensions.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 461 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Data and view adapters as extensions, admitted only on the two strikes rule") "Phase 461 must state task title")
      (assert (string-contains? p-src "Data and view live entirely in extensions") "Phase 461 must state data and view outcome")
      (assert (string-contains? p-src "The two strikes rule enforced rather than stated") "Phase 461 must state two strikes enforcement outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46105 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTwoStrikesAdapterAdmissionContract) "TestTwoStrikesAdapterAdmissionContract must pass")
    (assert (TestAdapterAdmissionInDependencyBoundaries) "TestAdapterAdmissionInDependencyBoundaries must pass")
    (assert (TestTask46105GroundedInPhase461) "TestTask46105GroundedInPhase461 must pass")
    true))
