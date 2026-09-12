(module tests/acceptance/d81/Task46102
  :d "Acceptance fixture for Task46102: Syntax extension as library under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSyntaxExtensionHygienicContract
      TestDomainAsLibraryContract
      TestTask46102GroundedInPhase461]
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

(df TestSyntaxExtensionHygienicContract [] -> Bool
  :d "Verifies language-semantics.asn defines syntaxExtensionHygienic semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "syntaxExtensionHygienic") "language-semantics.asn must define syntaxExtensionHygienic semantic")
      (assert (string-contains? s-src "ERR_UNHYGIENIC_EXPANSION") "language-semantics.asn must specify ERR_UNHYGIENIC_EXPANSION failureCode")
      true)))

(df TestDomainAsLibraryContract [] -> Bool
  :d "Verifies language-semantics.asn defines domainAsLibrary semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "domainAsLibrary") "language-semantics.asn must define domainAsLibrary semantic")
      (assert (string-contains? s-src "ERR_DOMAIN_VOCABULARY_IN_CORE") "language-semantics.asn must specify ERR_DOMAIN_VOCABULARY_IN_CORE failureCode")
      true)))

(df TestTask46102GroundedInPhase461 [] -> Bool
  :d "Verifies Phase 461 task file grounds hygienic syntax extension and domain libraries"
  (let [(p-res (file-read ".asl/mem/tasks/Phase461CoreAndInterchangeableExtensions.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 461 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Syntax extension, so a domain is a library and not an engine change") "Phase 461 must state task title")
      (assert (string-contains? p-src "Hygiene, so an expansion cannot capture a user binding") "Phase 461 must state hygiene outcome")
      (assert (string-contains? p-src "Positions preserved through expansion") "Phase 461 must state position preservation outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46102 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSyntaxExtensionHygienicContract) "TestSyntaxExtensionHygienicContract must pass")
    (assert (TestDomainAsLibraryContract) "TestDomainAsLibraryContract must pass")
    (assert (TestTask46102GroundedInPhase461) "TestTask46102GroundedInPhase461 must pass")
    true))
