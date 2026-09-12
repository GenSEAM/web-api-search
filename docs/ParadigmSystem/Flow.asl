(module paradigm-system/flow
  :d "Reference policy over adapter-supplied state; neither provenance verification nor certification of semantic understanding."
  :x [ReviewState ContextBudget BudgetDecision NextAction AllocateContext]
  :i [])

(dfs ReviewState
  (:f taskChanged Bool "Task identity differs from the evidence snapshot")
  (:f artifactChanged Bool "Artifact identity differs from the evidence snapshot")
  (:f evidenceCount I64 "Available relevant observations, not a measure of truth")
  (:f contradictionCount I64 "Unresolved conflicts identified by comparison")
  (:f unresolvedCount I64 "Open requirements or defects")
  (:f criteriaCount I64 "Nonempty acceptance set defined outside this reducer")
  (:f coveredCount I64 "Criteria with adapter-validated coverage")
  (:f attemptsRemaining I64 "Remaining authorized review or action attempts")
  (:f boundVerification Bool "Trusted adapter input: verification valid and bound to this task, artifact and acceptance set; a model-supplied Boolean provides no such trust"))

(dfs ContextBudget
  (:f window I64 "Whole context capacity in the target model tokenizer")
  (:f host I64 "System and host instruction tokens")
  (:f tools I64 "Tool schema and wire framing tokens")
  (:f task I64 "Current task and critical constraints")
  (:f evidence I64 "Reserved current observations and corrective feedback")
  (:f output I64 "Reserved generated output")
  (:f essential I64 "Indivisible conceptual kernel tokens")
  (:f optional I64 "Requested additional concept material"))

(dfs BudgetDecision
  (:f status Str "invalid, insufficient, fit, or reduce-optional")
  (:f required I64 "Mandatory whole-window demand excluding optional material")
  (:f optionalAllowance I64 "Maximum optional tokens; actual modules must fit atomically"))

(df NextAction [(state ReviewState)] -> Str
  (cond
    ((or (< (.-evidenceCount state) 0)
         (or (< (.-contradictionCount state) 0)
             (or (< (.-unresolvedCount state) 0)
                 (or (<= (.-criteriaCount state) 0)
                     (or (< (.-coveredCount state) 0)
                         (or (> (.-coveredCount state) (.-criteriaCount state))
                             (< (.-attemptsRemaining state) 0))))))) "invalid")
    ((or (.-taskChanged state) (.-artifactChanged state))
     (if (= (.-attemptsRemaining state) 0) "pause" "re-ground"))
    ((and (.-boundVerification state)
          (and (> (.-evidenceCount state) 0)
               (and (= (.-contradictionCount state) 0)
                    (and (= (.-unresolvedCount state) 0)
                         (= (.-coveredCount state) (.-criteriaCount state)))))) "complete")
    ((= (.-attemptsRemaining state) 0) "pause")
    ((= (.-evidenceCount state) 0) "inspect")
    ((> (.-contradictionCount state) 0) "reconcile")
    ((or (> (.-unresolvedCount state) 0)
         (< (.-coveredCount state) (.-criteriaCount state))) "act")
    (:else "verify")))

(df AllocateContext [(budget ContextBudget)] -> BudgetDecision
  (if (or (<= (.-window budget) 0)
          (or (< (.-host budget) 0)
              (or (< (.-tools budget) 0)
                  (or (< (.-task budget) 0)
                      (or (< (.-evidence budget) 0)
                          (or (< (.-output budget) 0)
                              (or (<= (.-essential budget) 0)
                                  (< (.-optional budget) 0))))))))
    (BudgetDecision :status "invalid" :required 0 :optionalAllowance 0)
    (let [(required (+ (.-host budget)
                      (+ (.-tools budget)
                         (+ (.-task budget)
                            (+ (.-evidence budget)
                               (+ (.-output budget) (.-essential budget)))))))
          (available (- (.-window budget) required))]
      (cond
        ((< available 0)
         (BudgetDecision :status "insufficient" :required required :optionalAllowance 0))
        ((> (.-optional budget) available)
         (BudgetDecision :status "reduce-optional" :required required :optionalAllowance available))
        (:else
         (BudgetDecision :status "fit" :required required :optionalAllowance available))))))
