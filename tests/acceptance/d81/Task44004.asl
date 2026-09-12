(module tests/acceptance/d81/Task44004
  :d "Acceptance fixture for Task44004: Verify self-hosted gates using independent negative controls under ADR-0081."
  :x [RunTests
      TestVerificationContractSpecification
      TestAslGatesPackageIntegrity
      TestForeignBoundaryAuditAndNegativeControls
      TestFailurePreservationAndExitCodeIntegrity]
  :i [])

(df TestVerificationContractSpecification [] -> Bool
  :d "Verifies verification contract defines negative controls, failure preservation, and reachability rules"
  (let [(c-res (file-read "asl/grammar/verification-contract.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl/grammar/verification-contract.asn must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src ":rule :id assertionReachability") "Must define assertionReachability rule")
      (assert (string-contains? src ":rule :id failurePreservation") "Must define failurePreservation rule")
      (assert (string-contains? src ":rule :id emptySuiteRejection") "Must define emptySuiteRejection rule")
      (assert (string-contains? src ":rule :id explicitCoverageObligations") "Must define explicitCoverageObligations rule")
      (assert (string-contains? src ":rule :id claimEvidenceGrounding") "Must define claimEvidenceGrounding rule")
      (assert (string-contains? src ":rule :id emptyCatalogRejection") "Must define emptyCatalogRejection rule")
      true)))

(df TestAslGatesPackageIntegrity [] -> Bool
  :d "Verifies that asl/packages/asl-gates implements self-hosted gate runner and modules"
  (let [(m-res (file-read "asl/packages/asl-gates/manifest.asn"))
        (g-res (file-read "asl/packages/asl-gates/grammar.asn"))]
    (assert (= (.-_tag m-res) "ok") "asl/packages/asl-gates/manifest.asn must exist")
    (assert (= (.-_tag g-res) "ok") "asl/packages/asl-gates/grammar.asn must exist")
    (let [(m-src (.-value m-res))
          (g-src (.-value g-res))]
      (assert (string-contains? m-src "(:package asl-gates") "manifest must declare package asl-gates")
      (assert (string-contains? g-src "run-suite") "grammar must declare run-suite")
      (assert (string-contains? g-src "audit-claim") "grammar must declare audit-claim")
      (assert (string-contains? g-src "standard-claims") "grammar must declare standard-claims")
      (assert (string-contains? g-src "GateReport") "grammar must declare GateReport")
      true)))

(df TestForeignBoundaryAuditAndNegativeControls [] -> Bool
  :d "Verifies foreign-boundary audit rules and rejection of undeclared dependencies"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist")
    (let [(src (.-value d-res))]
      (assert (string-contains? src ":hostAdapter (:path \"asl/tools/asl.c\"") "Host adapter path must be declared")
      (assert (string-contains? src ":tier :id \"deployed\"") "Deployed tier must be declared")
      (assert (string-contains? src "zero host external runtime requirements") "Must reject external runtime deps")
      true)))

(df TestFailurePreservationAndExitCodeIntegrity [] -> Bool
  :d "Verifies that SuperviseGate.sh enforces exit codes and rejects missing fixtures or corrupt tasks"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src "set -e") "SuperviseGate must use set -e to prevent failure masking")
      (assert (string-contains? src "--strict-falsify") "SuperviseGate must enforce --strict-falsify")
      (assert (string-contains? src "audit gates") "SuperviseGate must invoke audit gates")
      (assert (string-contains? src "audit consistency") "SuperviseGate must invoke audit consistency")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44004 supervisor acceptance tests"
  (do
    (assert (TestVerificationContractSpecification) "TestVerificationContractSpecification must pass")
    (assert (TestAslGatesPackageIntegrity) "TestAslGatesPackageIntegrity must pass")
    (assert (TestForeignBoundaryAuditAndNegativeControls) "TestForeignBoundaryAuditAndNegativeControls must pass")
    (assert (TestFailurePreservationAndExitCodeIntegrity) "TestFailurePreservationAndExitCodeIntegrity must pass")
    true))
