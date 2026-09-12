(module tests/acceptance/d81/Task44406
  :d "Acceptance fixture for Task44406: LLM case proposal inside a mutation-feedback loop, never as the oracle under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestMutationProposerLoopContract
      TestDiscardingNonKillingOrDuplicateProposals
      TestOwnershipEnforcementGraderPathProtection
      TestBudgetAndCostRecording
      TestTask44406GroundedInPhase444]
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

(df TestMutationProposerLoopContract [] -> Bool
  :d "Verifies asl/bench/mutation_proposer_loop.asl exists and implements mutation feedback loop types"
  (let [(m-res (file-read "asl/bench/mutation_proposer_loop.asl"))]
    (assert (= (.-_tag m-res) "ok") "asl/bench/mutation_proposer_loop.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "EvaluateProposedCase") "Must implement EvaluateProposedCase")
      (assert (string-contains? m-src "ProposedCase") "Must declare ProposedCase")
      (assert (string-contains? m-src "ProposalEvaluation") "Must declare ProposalEvaluation")
      (assert (string-contains? m-src "ProposerSessionReport") "Must declare ProposerSessionReport")
      (assert (string-contains? m-src "never decides pass or fail") "Must enforce model is proposer not judge")
      true)))

(df TestDiscardingNonKillingOrDuplicateProposals [] -> Bool
  :d "Verifies proposed cases that do not kill mutants or duplicate existing tests are discarded"
  (let [(m-res (file-read "asl/bench/mutation_proposer_loop.asl"))]
    (assert (= (.-_tag m-res) "ok") "mutation_proposer_loop.asl must exist")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "discarded") "Must support discarded disposition")
      (assert (string-contains? m-src "is-duplicate?") "Must check duplicate status")
      (assert (string-contains? m-src "kills-mutant?") "Must check mutant kill status")
      (assert (string-contains? m-src "non-vacuous?") "Must check non-vacuity status")
      true)))

(df TestOwnershipEnforcementGraderPathProtection [] -> Bool
  :d "Verifies attempt to modify existing assertions or grader paths is refused by ownership enforcement"
  (let [(m-res (file-read "asl/bench/mutation_proposer_loop.asl"))]
    (assert (= (.-_tag m-res) "ok") "mutation_proposer_loop.asl must exist")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "refused") "Must support refused disposition")
      (assert (string-contains? m-src "targets-grader-path?") "Must check grader path targeting")
      (assert (string-contains? m-src "modifies-existing-assert?") "Must check existing assertion modification")
      (assert (string-contains? m-src "ownership enforcement") "Must name ownership enforcement as defense")
      true)))

(df TestBudgetAndCostRecording [] -> Bool
  :d "Verifies budget per package with recorded token cost is tracked"
  (let [(m-res (file-read "asl/bench/mutation_proposer_loop.asl"))]
    (assert (= (.-_tag m-res) "ok") "mutation_proposer_loop.asl must exist")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "budget-tokens") "Must track package token budget")
      (assert (string-contains? m-src "tokens-consumed") "Must record consumed tokens")
      (assert (string-contains? m-src "cost-usd") "Must record dollar cost")
      true)))

(df TestTask44406GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44406"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "LLM case proposal inside a mutation-feedback loop") "Phase 444 must state Task44406 title")
      (assert (string-contains? p-src ":lane \"llm\"") "Phase 444 must specify llm lane")
      (assert (string-contains? p-src "run_gate_5") "Phase 444 must target run_gate_5")
      (assert (string-contains? p-src "asl/bench") "Phase 444 must own asl/bench")
      (assert (string-contains? p-src "tests/conformance") "Phase 444 must own tests/conformance")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44406 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestMutationProposerLoopContract) "TestMutationProposerLoopContract must pass")
    (assert (TestDiscardingNonKillingOrDuplicateProposals) "TestDiscardingNonKillingOrDuplicateProposals must pass")
    (assert (TestOwnershipEnforcementGraderPathProtection) "TestOwnershipEnforcementGraderPathProtection must pass")
    (assert (TestBudgetAndCostRecording) "TestBudgetAndCostRecording must pass")
    (assert (TestTask44406GroundedInPhase444) "TestTask44406GroundedInPhase444 must pass")
    true))
