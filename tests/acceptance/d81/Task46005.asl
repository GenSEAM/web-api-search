(module tests/acceptance/d81/Task46005
  :d "Acceptance fixture for Task46005: Contracts that assign blame under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestContractBlameSemantics
      TestVerificationContractBlameRules
      TestContractBlameGroundedInPhase460]
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

(df TestContractBlameSemantics [] -> Bool
  :d "Verifies language-semantics.asn defines contractBlameAttribution semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "contractBlameAttribution") "language-semantics.asn must define contractBlameAttribution semantic")
      (assert (string-contains? s-src "ERR_CONTRACT_BLAME_VIOLATION") "language-semantics.asn must specify ERR_CONTRACT_BLAME_VIOLATION failureCode")
      true)))

(df TestVerificationContractBlameRules [] -> Bool
  :d "Verifies verification-contract.asn defines blame assignment and deferred check rules"
  (let [(c-res (file-read "asl/grammar/verification-contract.asn"))]
    (assert (= (.-_tag c-res) "ok") "verification-contract.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "contractBlameAttribution") "verification-contract.asn must define contractBlameAttribution rule")
      (assert (string-contains? c-src "caller") "verification-contract.asn must specify caller blame")
      (assert (string-contains? c-src "definition") "verification-contract.asn must specify definition blame")
      (assert (string-contains? c-src "unchecked") "verification-contract.asn must handle unchecked status")
      true)))

(df TestContractBlameGroundedInPhase460 [] -> Bool
  :d "Verifies Phase 460 task file grounds contracts that assign blame"
  (let [(p-res (file-read ".asl/mem/tasks/Phase460SchemeAlignmentAndRacketConcepts.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 460 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Contracts that assign blame") "Phase 460 must contain task title")
      (assert (string-contains? p-src "violated precondition blames the caller") "Phase 460 must specify precondition blame")
      (assert (string-contains? p-src "violated postcondition blames the definition") "Phase 460 must specify postcondition blame")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46005 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestContractBlameSemantics) "TestContractBlameSemantics must pass")
    (assert (TestVerificationContractBlameRules) "TestVerificationContractBlameRules must pass")
    (assert (TestContractBlameGroundedInPhase460) "TestContractBlameGroundedInPhase460 must pass")
    true))
