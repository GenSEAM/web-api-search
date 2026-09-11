(module bench.aep.acceptance-test
  :d "AEP Synthetic Acceptance Test Suite verifying Contradiction Recall, Circularity Detection, and Zero Hallucination across 12 discriminator tasks."
  :x [test-synthetic-acceptance
      test-ablation-quadrant-progression
      test-discriminator-task-coverage
      test-12-discriminators-adaptive-routing
      run-tests]
  :i [(ablation :a abl)
      (meta-controller :a mc)])

(dfs CalibrationTask
  (:f task-id Str "Unique task ID")
  (:f n-files I64 "Files touched")
  (:f domain-score F64 "Domain complexity score")
  (:f ambiguity F64 "Ambiguity score")
  (:f security-crit F64 "Security criticality"))

(df get-calibration-tasks [] -> (List CalibrationTask)
  :d "Returns the 12 calibration tasks mapped to complexity attributes."
  (list
    (CalibrationTask :task-id "pytorch-model-cli" :n-files 1 :domain-score 0.2 :ambiguity 0.2 :security-crit 0.1)
    (CalibrationTask :task-id "log-summary-date-ranges" :n-files 1 :domain-score 0.2 :ambiguity 0.2 :security-crit 0.1)
    (CalibrationTask :task-id "merge-diff-arc-agi-task" :n-files 2 :domain-score 0.6 :ambiguity 0.5 :security-crit 0.2)
    (CalibrationTask :task-id "break-filter-js-from-html" :n-files 2 :domain-score 0.5 :ambiguity 0.4 :security-crit 0.6)
    (CalibrationTask :task-id "reshard-c4-data" :n-files 2 :domain-score 0.6 :ambiguity 0.4 :security-crit 0.3)
    (CalibrationTask :task-id "winning-avg-corewars" :n-files 1 :domain-score 0.2 :ambiguity 0.1 :security-crit 0.1)
    (CalibrationTask :task-id "password-recovery" :n-files 2 :domain-score 0.6 :ambiguity 0.4 :security-crit 0.4)
    (CalibrationTask :task-id "regex-chess" :n-files 1 :domain-score 0.3 :ambiguity 0.2 :security-crit 0.1)
    (CalibrationTask :task-id "torch-tensor-parallelism" :n-files 4 :domain-score 0.9 :ambiguity 0.8 :security-crit 0.9)
    (CalibrationTask :task-id "distribution-search" :n-files 1 :domain-score 0.2 :ambiguity 0.2 :security-crit 0.1)
    (CalibrationTask :task-id "caffe-cifar-10" :n-files 1 :domain-score 0.3 :ambiguity 0.2 :security-crit 0.1)
    (CalibrationTask :task-id "adaptive-rejection-sampler" :n-files 3 :domain-score 0.9 :ambiguity 0.8 :security-crit 0.7)))

(df tier-to-stages [(tier Str)] -> I64
  :d "Maps execution tier to stage count: fast-path runs 2 stages, balanced runs 6 stages, deep-reflex runs 7 stages."
  (cond
    ((= tier "fast-path") 2)
    ((= tier "balanced") 6)
    (:else 7)))

(df test-synthetic-acceptance [] -> Bool
  :d "Verifies Contradiction Recall >= 98%, Circularity Detection = 100%, and Hallucination = 0% across 12 discriminator tasks."
  (let [(result (abl/run-ablation-study))]
    (do
      (assert (>= (.-contradiction-recall result) 0.98))
      (assert (= (.-circularity-detection result) 1.0))
      (assert (= (.-hallucination-rate result) 0.0))
      (assert (= (.-tasks-evaluated result) 12))
      (assert (= (.-tasks-passed result) 12))
      (assert (>= (.-quadrant-d-pass-rate result) 0.90))
      (assert (<= (.-quadrant-a-pass-rate result) 0.20))
      (assert (abl/verify-convergence-thresholds result))
      true)))

(df test-ablation-quadrant-progression [] -> Bool
  :d "Verifies monotonic pass rate lift across Quadrants A -> B -> C -> D."
  (let [(qa (abl/quadrant-a-baseline))
        (qb (abl/quadrant-b-reformulate))
        (qc (abl/quadrant-c-plan-verify))
        (qd (abl/quadrant-d-full-reflex))]
    (do
      (assert (< (.-expected-pass-rate qa) (.-expected-pass-rate qb)))
      (assert (< (.-expected-pass-rate qb) (.-expected-pass-rate qc)))
      (assert (< (.-expected-pass-rate qc) (.-expected-pass-rate qd)))
      (assert (not (.-has-intent-gate qa)))
      (assert (.-has-intent-gate qb))
      (assert (.-has-plan-gate qc))
      (assert (.-has-post-verify qd))
      true)))

(df test-discriminator-task-coverage [] -> Bool
  :d "Verifies all 12 Terminal-Bench 4.0 discriminator tasks are represented."
  (let [(tasks (abl/get-discriminator-tasks))]
    (do
      (assert (= (list-length tasks) 12))
      (assert (not (list-empty? tasks)))
      true)))

(df test-12-discriminators-adaptive-routing [] -> Bool
  :d "Evaluates adaptive routing across 12 discriminator tasks asserting profile distribution and >= 40% token savings over static Deep-Reflex."
  (let [(tasks (get-calibration-tasks))
        (static-stages (* (list-length tasks) 7))
        (adaptive-stages (fold-left (fn [(acc I64) (t CalibrationTask)] -> I64
                                      (let [(h (mc/compute-task-entropy (.-n-files t) (.-domain-score t) (.-ambiguity t) (.-security-crit t)))
                                            (tier (mc/select-execution-tier h))]
                                        (+ acc (tier-to-stages tier))))
                                    0
                                    tasks))
        (fast-count (fold-left (fn [(acc I64) (t CalibrationTask)] -> I64
                                 (let [(h (mc/compute-task-entropy (.-n-files t) (.-domain-score t) (.-ambiguity t) (.-security-crit t)))]
                                   (if (< h 1.5) (+ acc 1) acc)))
                               0
                               tasks))
        (bal-count (fold-left (fn [(acc I64) (t CalibrationTask)] -> I64
                                (let [(h (mc/compute-task-entropy (.-n-files t) (.-domain-score t) (.-ambiguity t) (.-security-crit t)))]
                                  (if (and (>= h 1.5) (< h 4.0)) (+ acc 1) acc)))
                              0
                              tasks))
        (deep-count (fold-left (fn [(acc I64) (t CalibrationTask)] -> I64
                                 (let [(h (mc/compute-task-entropy (.-n-files t) (.-domain-score t) (.-ambiguity t) (.-security-crit t)))]
                                   (if (>= h 4.0) (+ acc 1) acc)))
                               0
                               tasks))
        (token-savings (/ (float-from-int64 (- static-stages adaptive-stages))
                          (float-from-int64 static-stages)))]
    (do
      (assert (= (list-length tasks) 12))
      (assert (= fast-count 6))
      (assert (= bal-count 4))
      (assert (= deep-count 2))
      (assert (= (+ (+ fast-count bal-count) deep-count) 12))
      (assert (= static-stages 84))
      (assert (= adaptive-stages 50))
      (assert (>= token-savings 0.40))
      (assert (= (mc/select-execution-tier (mc/compute-task-entropy 1 0.2 0.2 0.1)) "fast-path"))
      (assert (= (mc/select-execution-tier (mc/compute-task-entropy 2 0.6 0.5 0.2)) "balanced"))
      (assert (= (mc/select-execution-tier (mc/compute-task-entropy 4 0.9 0.8 0.9)) "deep-reflex"))
      (assert (= (mc/select-execution-profile (mc/compute-task-entropy 4 0.9 0.8 0.9)) "deep-reflex"))
      true)))

(df run-tests [] -> Bool
  :d "Executes synthetic acceptance test suite under strict falsification."
  (do
    (assert (test-synthetic-acceptance))
    (assert (test-ablation-quadrant-progression))
    (assert (test-discriminator-task-coverage))
    (assert (test-12-discriminators-adaptive-routing))
    true))
