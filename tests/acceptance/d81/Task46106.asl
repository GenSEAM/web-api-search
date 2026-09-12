(module tests/acceptance/d81/Task46106
  :d "Acceptance fixture for Task46106: Unidirectional dependency direction under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestUnidirectionalDependencyDirectionContract
      TestDependencyDirectionInBoundaries
      TestTask46106GroundedInPhase461]
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

(df TestUnidirectionalDependencyDirectionContract [] -> Bool
  :d "Verifies language-semantics.asn defines unidirectionalDependencyDirection semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "unidirectionalDependencyDirection") "language-semantics.asn must define unidirectionalDependencyDirection semantic")
      (assert (string-contains? s-src "ERR_INVERTED_CORE_DEPENDENCY") "language-semantics.asn must specify ERR_INVERTED_CORE_DEPENDENCY failureCode")
      true)))

(df TestDependencyDirectionInBoundaries [] -> Bool
  :d "Verifies dependency-boundaries.asn defines strict unidirectional dependency direction"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src ":dependencyDirection") "dependency-boundaries.asn must specify dependencyDirection")
      (assert (string-contains? d-src "unidirectional") "dependency-boundaries.asn must enforce unidirectional flow")
      true)))

(df TestTask46106GroundedInPhase461 [] -> Bool
  :d "Verifies Phase 461 task file grounds unidirectional dependency direction"
  (let [(p-res (file-read ".asl/mem/tasks/Phase461CoreAndInterchangeableExtensions.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 461 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Dependency direction: core never depends on an extension") "Phase 461 must state task title")
      (assert (string-contains? p-src "One-way dependency enforced over the resolved module graph") "Phase 461 must state one-way dependency outcome")
      (assert (string-contains? p-src "Any extension removable without touching core") "Phase 461 must state extension removability outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46106 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestUnidirectionalDependencyDirectionContract) "TestUnidirectionalDependencyDirectionContract must pass")
    (assert (TestDependencyDirectionInBoundaries) "TestDependencyDirectionInBoundaries must pass")
    (assert (TestTask46106GroundedInPhase461) "TestTask46106GroundedInPhase461 must pass")
    true))
