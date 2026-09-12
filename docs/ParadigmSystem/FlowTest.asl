(module paradigm-system/flow-test
  :d "Development tests for reference decisions, not measurements of LLM cognition."
  :x [run-tests]
  :i [(Flow :a flow)])

(df Review [(taskChanged Bool) (artifactChanged Bool) (evidence I64) (conflicts I64) (unresolved I64) (criteria I64) (covered I64) (attempts I64) (bound Bool)] -> Str
  (flow/NextAction (flow/ReviewState :taskChanged taskChanged :artifactChanged artifactChanged :evidenceCount evidence :contradictionCount conflicts :unresolvedCount unresolved :criteriaCount criteria :coveredCount covered :attemptsRemaining attempts :boundVerification bound)))

(df Budget [(window I64) (host I64) (tools I64) (task I64) (evidence I64) (output I64) (essential I64) (optional I64)] -> flow/BudgetDecision
  (flow/AllocateContext (flow/ContextBudget :window window :host host :tools tools :task task :evidence evidence :output output :essential essential :optional optional)))

(df TestReview [] -> Bool
  (assert (= (Review false false 1 0 1 1 0 0 true) "pause") "Exhaustion with unresolved work never passes")
  (assert (= (Review false false 1 1 0 1 1 0 true) "pause") "Exhaustion preserves unresolved contradictions")
  (assert (= (Review true false 1 0 0 1 1 1 true) "re-ground") "Changed task invalidates prior evidence")
  (assert (= (Review false true 1 0 0 1 1 1 true) "re-ground") "Changed artifact invalidates prior evidence")
  (assert (= (Review true false 1 0 0 1 1 0 true) "pause") "Stale snapshot cannot complete on exhaustion")
  (assert (= (Review false false 0 0 0 1 1 1 true) "inspect") "Receipt flag cannot replace missing observations")
  (assert (= (Review false false 1 1 0 1 1 1 true) "reconcile") "Contradictions precede apparent coverage")
  (assert (= (Review false false 1 0 1 1 1 1 true) "act") "Known defect blocks completion")
  (assert (= (Review false false 1 0 0 2 1 1 true) "act") "Partial coverage blocks completion")
  (assert (= (Review false false 1 0 0 1 1 1 false) "verify") "Coverage still requires external verification")
  (assert (= (Review false false 1 0 0 1 1 0 false) "pause") "Exhaustion without verification is unresolved")
  (assert (= (Review false false 1 0 0 1 1 0 true) "complete") "Already verified result needs no extra attempt")
  (assert (= (Review false false 1 0 0 1 1 1 true) "complete") "Fresh bound verification and full coverage permit completion")
  (assert (= (Review false false -1 0 0 1 1 1 true) "invalid") "Negative evidence rejected")
  (assert (= (Review false false 1 -1 0 1 1 1 true) "invalid") "Negative contradictions rejected")
  (assert (= (Review false false 1 0 -1 1 1 1 true) "invalid") "Negative unresolved rejected")
  (assert (= (Review false false 1 0 0 0 0 1 true) "invalid") "Empty criteria cannot prove completion")
  (assert (= (Review false false 1 0 0 1 -1 1 true) "invalid") "Negative coverage rejected")
  (assert (= (Review false false 1 0 0 1 2 1 true) "invalid") "Excess coverage rejected")
  (assert (= (Review false false 1 0 0 1 1 -1 true) "invalid") "Negative attempts rejected")
  true)

(df TestBudget [] -> Bool
  (let [(fit (Budget 1000 100 80 120 150 200 250 100))
        (overflow (Budget 1000 100 80 120 150 200 250 101))
        (essentialOverflow (Budget 1000 100 80 120 150 200 351 0))]
    (assert (= (.-status fit) "fit") "Whole window fits exactly")
    (assert (= (.-required fit) 900) "All six mandatory reservations count")
    (assert (= (.-optionalAllowance fit) 100) "Remaining space accounted")
    (assert (= (.-status overflow) "reduce-optional") "Optional overflow requests smaller selection")
    (assert (= (.-optionalAllowance overflow) 100) "Optional overflow never evicts essential")
    (assert (= (.-status essentialOverflow) "insufficient") "Mandatory overflow preserves kernel")
    (assert (= (.-required essentialOverflow) 1001) "Deficit remains observable")
    (assert (= (.-optionalAllowance essentialOverflow) 0) "No optional space on mandatory overflow")
    (assert (= (.-status (Budget 0 0 0 0 0 0 1 0)) "invalid") "Zero window rejected")
    (assert (= (.-status (Budget -1 0 0 0 0 0 1 0)) "invalid") "Negative window rejected")
    (assert (= (.-status (Budget 1000 -1 0 0 0 0 1 0)) "invalid") "Negative host rejected")
    (assert (= (.-status (Budget 1000 0 -1 0 0 0 1 0)) "invalid") "Negative tools rejected")
    (assert (= (.-status (Budget 1000 0 0 -1 0 0 1 0)) "invalid") "Negative task rejected")
    (assert (= (.-status (Budget 1000 0 0 0 -1 0 1 0)) "invalid") "Negative evidence rejected")
    (assert (= (.-status (Budget 1000 0 0 0 0 -1 1 0)) "invalid") "Negative output rejected")
    (assert (= (.-status (Budget 1000 0 0 0 0 0 -1 0)) "invalid") "Negative essential rejected")
    (assert (= (.-status (Budget 1000 0 0 0 0 0 0 0)) "invalid") "Missing kernel rejected")
    (assert (= (.-status (Budget 1000 0 0 0 0 0 1 -1)) "invalid") "Negative optional rejected")
    true))

(df run-tests [] -> Bool
  (assert (TestReview) "Review cases execute")
  (assert (TestBudget) "Budget cases execute")
  true)
