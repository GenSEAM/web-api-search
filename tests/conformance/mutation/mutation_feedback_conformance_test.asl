(module tests/conformance/mutation/MutationFeedbackConformanceTest
  :d "Conformance test suite for LLM case proposal inside a mutation feedback loop under ADR-0081"
  :x [RunTests
      TestNegativeControlNonKillingMutantDiscarded
      TestAdversarialGraderPathModificationRefused
      TestAdversarialExistingAssertionEditRefused
      TestIdempotenceDuplicateProposalDiscarded
      TestValidKillingAndNonVacuousProposalKept
      TestProposerBudgetAndCostAccounting]
  :i [("../../../asl/bench/mutation_proposer_loop" :a mpl)])

(df TestNegativeControlNonKillingMutantDiscarded [] -> Bool
  :d "Negative control: candidate case that passes without killing target mutant must be discarded"
  (let [(c (mpl/ProposedCase :id "cand-01" :targetSymbol "eval-sub" :targetMutant "mut-sub-01" :caseSource "(assert true)" :targetPath "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c false true false false false))]
      (assert (= (.-disposition ev) "discarded") "Non-killing proposal must be discarded")
      (assert (not (.-killsMutant? ev)) "Must flag kills-mutant? false")
      true)))

(df TestAdversarialGraderPathModificationRefused [] -> Bool
  :d "Adversarial: attempt to write or edit grader-owned acceptance path must be refused by ownership enforcement"
  (let [(c (mpl/ProposedCase :id "cand-grader" :targetSymbol "gate-supervise" :targetMutant "mut-gate-01" :caseSource "(assert false)" :targetPath "tests/acceptance/d81/Task44406.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false false true))]
      (assert (= (.-disposition ev) "refused") "Grader path target must be refused")
      (assert (.-targetsGraderPath? ev) "Must flag targets-grader-path? true")
      true)))

(df TestAdversarialExistingAssertionEditRefused [] -> Bool
  :d "Adversarial: attempt to modify existing assertions must be refused by ownership enforcement"
  (let [(c (mpl/ProposedCase :id "cand-mod" :targetSymbol "eval-core" :targetMutant "mut-core-01" :caseSource "(assert true)" :targetPath "asl/packages/asl-gates/tests/gates_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false true false))]
      (assert (= (.-disposition ev) "refused") "Existing assertion edit must be refused")
      (assert (.-modifiesExistingAssert? ev) "Must flag modifies-existing-assert? true")
      true)))

(df TestIdempotenceDuplicateProposalDiscarded [] -> Bool
  :d "Idempotence: candidate that duplicates an existing test must be discarded"
  (let [(c (mpl/ProposedCase :id "cand-dup" :targetSymbol "eval-add" :targetMutant "mut-add-01" :caseSource "(assert (= (+ 1 2) 3))" :targetPath "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true true false false))]
      (assert (= (.-disposition ev) "discarded") "Duplicate proposal must be discarded")
      (assert (.-isDuplicate? ev) "Must flag is-duplicate? true")
      true)))

(df TestValidKillingAndNonVacuousProposalKept [] -> Bool
  :d "Valid: candidate that kills target mutant and is non-vacuous must be kept"
  (let [(c (mpl/ProposedCase :id "cand-ok" :targetSymbol "eval-mult" :targetMutant "mut-mult-01" :caseSource "(assert (= (* 2 3) 6))" :targetPath "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false false false))]
      (assert (= (.-disposition ev) "kept") "Valid mutant-killing proposal must be kept")
      (assert (.-killsMutant? ev) "Must flag kills-mutant? true")
      (assert (.-nonVacuous? ev) "Must flag non-vacuous? true")
      true)))

(df TestProposerBudgetAndCostAccounting [] -> Bool
  :d "Resource bounds: token budget and dollar cost must be calculated and tracked"
  (let [(cost (mpl/CalculateProposerCost 100000 3))]
    (assert (= cost "$0.30") "100k tokens at $3/M must equal $0.30")
    (let [(report (mpl/ProposerSessionReport
                    :package "asl-eval"
                    :budgetTokens 500000
                    :tokensConsumed 100000
                    :costUsd cost
                    :proposedCount 10
                    :keptCount 3
                    :discardedCount 6
                    :refusedCount 1))]
      (assert (= (.-proposedCount report) 10) "Proposed count must be 10")
      (assert (= (.-keptCount report) 3) "Kept count must be 3")
      (assert (= (.-discardedCount report) 6) "Discarded count must be 6")
      (assert (= (.-refusedCount report) 1) "Refused count must be 1")
      true)))

(df RunTests [] -> Bool
  :d "Executes all mutation feedback conformance tests"
  (do
    (assert (TestNegativeControlNonKillingMutantDiscarded) "TestNegativeControlNonKillingMutantDiscarded must pass")
    (assert (TestAdversarialGraderPathModificationRefused) "TestAdversarialGraderPathModificationRefused must pass")
    (assert (TestAdversarialExistingAssertionEditRefused) "TestAdversarialExistingAssertionEditRefused must pass")
    (assert (TestIdempotenceDuplicateProposalDiscarded) "TestIdempotenceDuplicateProposalDiscarded must pass")
    (assert (TestValidKillingAndNonVacuousProposalKept) "TestValidKillingAndNonVacuousProposalKept must pass")
    (assert (TestProposerBudgetAndCostAccounting) "TestProposerBudgetAndCostAccounting must pass")
    true))
