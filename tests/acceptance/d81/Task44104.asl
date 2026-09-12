(module tests/acceptance/d81/Task44104
  :d "Acceptance fixture for Task44104: Preserve authorization and evidence across handoff/resume under ADR-0081."
  :x [RunTests
      TestSessionContractHandoffRules
      TestRpcRegistryHandoffOperations
      TestInFlightSessionLedgerHandoffTracking
      TestAslHostHandoffAndResumeOperations]
  :i [])

(df TestSessionContractHandoffRules [] -> Bool
  :d "Verifies that session-contract.asn declares handoff, recall, compaction, and budget schemas and rules"
  (let [(s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":rule :id handoffPreservation") "Must define handoffPreservation rule")
      (assert (string-contains? src ":rule :id adversarialConstraintIntegrity") "Must define adversarialConstraintIntegrity rule")
      (assert (string-contains? src ":rule :id staleReceiptInvalidation") "Must define staleReceiptInvalidation rule")
      (assert (string-contains? src ":rule :id sessionScopedRecall") "Must define sessionScopedRecall rule")
      (assert (string-contains? src ":rule :id explicitTunableThresholds") "Must define explicitTunableThresholds rule")
      (assert (string-contains? src ":handoffSchema [") "Must define handoffSchema")
      (assert (string-contains? src ":field :id \"authoritativeConstraints\"") "Must bind authoritativeConstraints in handoffSchema")
      (assert (string-contains? src ":field :id \"ownedPaths\"") "Must bind ownedPaths in handoffSchema")
      (assert (string-contains? src ":field :id \"unresolvedQuestions\"") "Must bind unresolvedQuestions in handoffSchema")
      (assert (string-contains? src ":field :id \"negativeFindings\"") "Must bind negativeFindings in handoffSchema")
      (assert (string-contains? src ":field :id \"receiptReferences\"") "Must bind receiptReferences in handoffSchema")
      (assert (string-contains? src ":resumeSchema [") "Must define resumeSchema")
      (assert (string-contains? src ":field :id \"receiptsValid\"") "Must bind receiptsValid in resumeSchema")
      (assert (string-contains? src ":budgetSchema [") "Must define budgetSchema")
      (assert (string-contains? src ":field :id \"compactionThreshold\"") "Must bind compactionThreshold in budgetSchema")
      true)))

(df TestRpcRegistryHandoffOperations [] -> Bool
  :d "Verifies that rpc.asn defines handoff, resume, and budget session operations"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "rpc.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":id \"asl-handoff\"") "Must declare asl-handoff op")
      (assert (string-contains? src ":id \"asl-resume\"") "Must declare asl-resume op")
      (assert (string-contains? src ":id \"asl-budget\"") "Must declare asl-budget op")
      (assert (string-contains? src "(:op \"handoff\"") "Must declare handoff op name")
      (assert (string-contains? src "(:op \"resume\"") "Must declare resume op name")
      (assert (string-contains? src "(:op \"budget\"") "Must declare budget op name")
      true)))

(df TestInFlightSessionLedgerHandoffTracking [] -> Bool
  :d "Verifies that InFlight.asn tracks session handoff, constraints, and negative findings"
  (let [(i-res (file-read ".asl/mem/tasks/InFlight.asn"))]
    (assert (= (.-_tag i-res) "ok") "InFlight.asn must exist and be readable")
    (let [(src (.-value i-res))]
      (assert (string-contains? src ":session-id") "Must define :session-id")
      (assert (string-contains? src ":status") "Must define :status")
      (assert (string-contains? src ":handoffId") "Must define :handoffId")
      (assert (string-contains? src ":sourceDigest") "Must define :sourceDigest")
      (assert (string-contains? src ":authoritativeConstraints") "Must define :authoritativeConstraints")
      (assert (string-contains? src ":unresolvedQuestions") "Must define :unresolvedQuestions")
      (assert (string-contains? src ":negativeFindings") "Must define :negativeFindings")
      (assert (string-contains? src ":receiptReferences") "Must define :receiptReferences")
      true)))

(df TestAslHostHandoffAndResumeOperations [] -> Bool
  :d "Verifies that asl.c implements and dispatches handoff, resume, and budget operations"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "op_budget") "Must implement op_budget")
      (assert (string-contains? src "op_handoff") "Must implement op_handoff")
      (assert (string-contains? src "op_resume") "Must implement op_resume")
      (assert (string-contains? src ":ERR_STALE_HANDOFF") "Must define ERR_STALE_HANDOFF rejection")
      (assert (string-contains? src ":ERR_MISSING_HANDOFF_ID") "Must define ERR_MISSING_HANDOFF_ID rejection")
      (assert (string-contains? src "strcmp(op, \"budget\") == 0") "Must dispatch budget in execute_single_step")
      (assert (string-contains? src "strcmp(op, \"handoff\") == 0") "Must dispatch handoff in execute_single_step")
      (assert (string-contains? src "strcmp(op, \"resume\") == 0") "Must dispatch resume in execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44104 supervisor acceptance tests"
  (do
    (assert (TestSessionContractHandoffRules) "TestSessionContractHandoffRules must pass")
    (assert (TestRpcRegistryHandoffOperations) "TestRpcRegistryHandoffOperations must pass")
    (assert (TestInFlightSessionLedgerHandoffTracking) "TestInFlightSessionLedgerHandoffTracking must pass")
    (assert (TestAslHostHandoffAndResumeOperations) "TestAslHostHandoffAndResumeOperations must pass")
    true))
