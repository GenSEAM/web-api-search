(module tests/acceptance/d81/Task46104
  :d "Acceptance fixture for Task46104: Extension host capability declarations and core enforcement under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestExtensionDeclaredCapabilitiesContract
      TestCapabilityRequirementEnforcement
      TestTask46104GroundedInPhase461]
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

(df TestExtensionDeclaredCapabilitiesContract [] -> Bool
  :d "Verifies language-semantics.asn defines extensionDeclaredCapabilities semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "extensionDeclaredCapabilities") "language-semantics.asn must define extensionDeclaredCapabilities semantic")
      (assert (string-contains? s-src "ERR_UNSATISFIED_HOST_CAPABILITY") "language-semantics.asn must specify ERR_UNSATISFIED_HOST_CAPABILITY failureCode")
      true)))

(df TestCapabilityRequirementEnforcement [] -> Bool
  :d "Verifies capabilities.asn or dependency-boundaries.asn defines extension capability declaration contract"
  (let [(c-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag c-res) "ok") "capabilities.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":extensionCapabilities") "capabilities.asn must specify extensionCapabilities contract")
      (assert (string-contains? c-src "load-time") "capabilities.asn must specify load-time enforcement")
      true)))

(df TestTask46104GroundedInPhase461 [] -> Bool
  :d "Verifies Phase 461 task file grounds extension declared capabilities and load-time enforcement"
  (let [(p-res (file-read ".asl/mem/tasks/Phase461CoreAndInterchangeableExtensions.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 461 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "An extension declares the host capabilities it needs, and the core enforces them") "Phase 461 must state task title")
      (assert (string-contains? p-src "Capability requirements declared per extension") "Phase 461 must state capability requirements outcome")
      (assert (string-contains? p-src "Load-time failure naming extension and capability") "Phase 461 must state load-time failure outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46104 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestExtensionDeclaredCapabilitiesContract) "TestExtensionDeclaredCapabilitiesContract must pass")
    (assert (TestCapabilityRequirementEnforcement) "TestCapabilityRequirementEnforcement must pass")
    (assert (TestTask46104GroundedInPhase461) "TestTask46104GroundedInPhase461 must pass")
    true))
