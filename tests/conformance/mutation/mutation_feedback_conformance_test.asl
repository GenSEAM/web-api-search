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
  (let [(c (mpl/ProposedCase :id "cand-01" :target-symbol "eval-sub" :target-mutant "mut-sub-01" :case-source "(assert true)" :target-path "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c false true false false false))]
      (assert (= (.-disposition ev) "discarded") "Non-killing proposal must be discarded")
      (assert (not (.-kills-mutant? ev)) "Must flag kills-mutant? false")
      true)))

(df TestAdversarialGraderPathModificationRefused [] -> Bool
  :d "Adversarial: attempt to write or edit grader-owned acceptance path must be refused by ownership enforcement"
  (let [(c (mpl/ProposedCase :id "cand-grader" :target-symbol "gate-supervise" :target-mutant "mut-gate-01" :case-source "(assert false)" :target-path "tests/acceptance/d81/Task44406.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false false true))]
      (assert (= (.-disposition ev) "refused") "Grader path target must be refused")
      (assert (.-targets-grader-path? ev) "Must flag targets-grader-path? true")
      true)))

(df TestAdversarialExistingAssertionEditRefused [] -> Bool
  :d "Adversarial: attempt to modify existing assertions must be refused by ownership enforcement"
  (let [(c (mpl/ProposedCase :id "cand-mod" :target-symbol "eval-core" :target-mutant "mut-core-01" :case-source "(assert true)" :target-path "asl/packages/asl-gates/tests/gates_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false true false))]
      (assert (= (.-disposition ev) "refused") "Existing assertion edit must be refused")
      (assert (.-modifies-existing-assert? ev) "Must flag modifies-existing-assert? true")
      true)))

(df TestIdempotenceDuplicateProposalDiscarded [] -> Bool
  :d "Idempotence: candidate that duplicates an existing test must be discarded"
  (let [(c (mpl/ProposedCase :id "cand-dup" :target-symbol "eval-add" :target-mutant "mut-add-01" :case-source "(assert (= (+ 1 2) 3))" :target-path "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true true false false))]
      (assert (= (.-disposition ev) "discarded") "Duplicate proposal must be discarded")
      (assert (.-is-duplicate? ev) "Must flag is-duplicate? true")
      true)))

(df TestValidKillingAndNonVacuousProposalKept [] -> Bool
  :d "Valid: candidate that kills target mutant and is non-vacuous must be kept"
  (let [(c (mpl/ProposedCase :id "cand-ok" :target-symbol "eval-mult" :target-mutant "mut-mult-01" :case-source "(assert (= (* 2 3) 6))" :target-path "tests/conformance/eval_test.asl"))]
    (let [(ev (mpl/EvaluateProposedCase c true true false false false))]
      (assert (= (.-disposition ev) "kept") "Valid mutant-killing proposal must be kept")
      (assert (.-kills-mutant? ev) "Must flag kills-mutant? true")
      (assert (.-non-vacuous? ev) "Must flag non-vacuous? true")
      true)))

(df TestProposerBudgetAndCostAccounting [] -> Bool
  :d "Resource bounds: token budget and dollar cost must be calculated and tracked"
  (let [(cost (mpl/CalculateProposerCost 100000 3))]
    (assert (= cost "$0.30") "100k tokens at $3/M must equal $0.30")
    (let [(report (mpl/ProposerSessionReport
                    :package "asl-eval"
                    :budget-tokens 500000
                    :tokens-consumed 100000
                    :cost-usd cost
                    :proposed-count 10
                    :kept-count 3
                    :discarded-count 6
                    :refused-count 1))]
      (assert (= (.-proposed-count report) 10) "Proposed count must be 10")
      (assert (= (.-kept-count report) 3) "Kept count must be 3")
      (assert (= (.-discarded-count report) 6) "Discarded count must be 6")
      (assert (= (.-refused-count report) 1) "Refused count must be 1")
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
