(module bench.aep.acceptanceTest
  :d "AEP Synthetic Acceptance Test Suite verifying Contradiction Recall, Circularity Detection, and Zero Hallucination across 12 discriminator tasks."
  :x [testSyntheticAcceptance
      testAblationQuadrantProgression
      testDiscriminatorTaskCoverage
      test12DiscriminatorsAdaptiveRouting
      runTests]
  :i [(ablation :a abl)
      (metaController :a mc)])

(dfs CalibrationTask
  (:f taskId Str "Unique task ID")
  (:f nFiles I64 "Files touched")
  (:f domainScore F64 "Domain complexity score")
  (:f ambiguity F64 "Ambiguity score")
  (:f securityCrit F64 "Security criticality"))

(df getCalibrationTasks [] -> (List CalibrationTask)
  :d "Returns the 12 calibration tasks mapped to complexity attributes."
  (list
    (CalibrationTask :taskId "pytorch-model-cli" :nFiles 1 :domainScore 0.2 :ambiguity 0.2 :securityCrit 0.1)
    (CalibrationTask :taskId "log-summary-date-ranges" :nFiles 1 :domainScore 0.2 :ambiguity 0.2 :securityCrit 0.1)
    (CalibrationTask :taskId "merge-diff-arc-agi-task" :nFiles 2 :domainScore 0.6 :ambiguity 0.5 :securityCrit 0.2)
    (CalibrationTask :taskId "break-filter-js-from-html" :nFiles 2 :domainScore 0.5 :ambiguity 0.4 :securityCrit 0.6)
    (CalibrationTask :taskId "reshard-c4-data" :nFiles 2 :domainScore 0.6 :ambiguity 0.4 :securityCrit 0.3)
    (CalibrationTask :taskId "winning-avg-corewars" :nFiles 1 :domainScore 0.2 :ambiguity 0.1 :securityCrit 0.1)
    (CalibrationTask :taskId "password-recovery" :nFiles 2 :domainScore 0.6 :ambiguity 0.4 :securityCrit 0.4)
    (CalibrationTask :taskId "regex-chess" :nFiles 1 :domainScore 0.3 :ambiguity 0.2 :securityCrit 0.1)
    (CalibrationTask :taskId "torch-tensor-parallelism" :nFiles 4 :domainScore 0.9 :ambiguity 0.8 :securityCrit 0.9)
    (CalibrationTask :taskId "distribution-search" :nFiles 1 :domainScore 0.2 :ambiguity 0.2 :securityCrit 0.1)
    (CalibrationTask :taskId "caffe-cifar-10" :nFiles 1 :domainScore 0.3 :ambiguity 0.2 :securityCrit 0.1)
    (CalibrationTask :taskId "adaptive-rejection-sampler" :nFiles 3 :domainScore 0.9 :ambiguity 0.8 :securityCrit 0.7)))

(df tierToStages [(tier Str)] -> I64
  :d "Maps execution tier to stage count: fast-path runs 2 stages, balanced runs 6 stages, deep-reflex runs 7 stages."
  (cond
    ((= tier "fast-path") 2)
    ((= tier "balanced") 6)
    (:else 7)))

(df testSyntheticAcceptance [] -> Bool
  :d "Verifies Contradiction Recall >= 98%, Circularity Detection = 100%, and Hallucination = 0% across 12 discriminator tasks."
  (let [(result (abl/runAblationStudy))]
    (do
      (assert (>= (.-contradictionRecall result) 0.98))
      (assert (= (.-circularityDetection result) 1.0))
      (assert (= (.-hallucinationRate result) 0.0))
      (assert (= (.-tasksEvaluated result) 12))
      (assert (= (.-tasksPassed result) 12))
      (assert (>= (.-quadrantDPassRate result) 0.90))
      (assert (<= (.-quadrantAPassRate result) 0.20))
      (assert (abl/verifyConvergenceThresholds result))
      true)))

(df testAblationQuadrantProgression [] -> Bool
  :d "Verifies monotonic pass rate lift across Quadrants A -> B -> C -> D."
  (let [(qa (abl/quadrantABaseline))
        (qb (abl/quadrantBReformulate))
        (qc (abl/quadrantCPlanVerify))
        (qd (abl/quadrantDFullReflex))]
    (do
      (assert (< (.-expectedPassRate qa) (.-expectedPassRate qb)))
      (assert (< (.-expectedPassRate qb) (.-expectedPassRate qc)))
      (assert (< (.-expectedPassRate qc) (.-expectedPassRate qd)))
      (assert (not (.-hasIntentGate qa)))
      (assert (.-hasIntentGate qb))
      (assert (.-hasPlanGate qc))
      (assert (.-hasPostVerify qd))
      true)))

(df testDiscriminatorTaskCoverage [] -> Bool
  :d "Verifies all 12 Terminal-Bench 4.0 discriminator tasks are represented."
  (let [(tasks (abl/getDiscriminatorTasks))]
    (do
      (assert (= (list-length tasks) 12))
      (assert (not (list-empty? tasks)))
      true)))

(df test12DiscriminatorsAdaptiveRouting [] -> Bool
  :d "Evaluates adaptive routing across 12 discriminator tasks asserting profile distribution and >= 40% token savings over static Deep-Reflex."
  (let [(tasks (getCalibrationTasks))
        (staticStages (* (list-length tasks) 7))
        (adaptiveStages (foldLeft (fn [(acc I64) (t CalibrationTask)] -> I64
                                      (let [(h (mc/computeTaskEntropy (.-nFiles t) (.-domainScore t) (.-ambiguity t) (.-securityCrit t)))
                                            (tier (mc/selectExecutionTier h))]
                                        (+ acc (tierToStages tier))))
                                    0
                                    tasks))
        (fastCount (foldLeft (fn [(acc I64) (t CalibrationTask)] -> I64
                                 (let [(h (mc/computeTaskEntropy (.-nFiles t) (.-domainScore t) (.-ambiguity t) (.-securityCrit t)))]
                                   (if (< h 1.5) (+ acc 1) acc)))
                               0
                               tasks))
        (balCount (foldLeft (fn [(acc I64) (t CalibrationTask)] -> I64
                                (let [(h (mc/computeTaskEntropy (.-nFiles t) (.-domainScore t) (.-ambiguity t) (.-securityCrit t)))]
                                  (if (and (>= h 1.5) (< h 4.0)) (+ acc 1) acc)))
                              0
                              tasks))
        (deepCount (foldLeft (fn [(acc I64) (t CalibrationTask)] -> I64
                                 (let [(h (mc/computeTaskEntropy (.-nFiles t) (.-domainScore t) (.-ambiguity t) (.-securityCrit t)))]
                                   (if (>= h 4.0) (+ acc 1) acc)))
                               0
                               tasks))
        (tokenSavings (/ (floatFromInt64 (- staticStages adaptiveStages))
                          (floatFromInt64 staticStages)))]
    (do
      (assert (= (list-length tasks) 12))
      (assert (= fastCount 6))
      (assert (= balCount 4))
      (assert (= deepCount 2))
      (assert (= (+ (+ fastCount balCount) deepCount) 12))
      (assert (= staticStages 84))
      (assert (= adaptiveStages 50))
      (assert (>= tokenSavings 0.40))
      (assert (= (mc/selectExecutionTier (mc/computeTaskEntropy 1 0.2 0.2 0.1)) "fast-path"))
      (assert (= (mc/selectExecutionTier (mc/computeTaskEntropy 2 0.6 0.5 0.2)) "balanced"))
      (assert (= (mc/selectExecutionTier (mc/computeTaskEntropy 4 0.9 0.8 0.9)) "deep-reflex"))
      (assert (= (mc/selectExecutionProfile (mc/computeTaskEntropy 4 0.9 0.8 0.9)) "deep-reflex"))
      true)))

(df runTests [] -> Bool
  :d "Executes synthetic acceptance test suite under strict falsification."
  (do
    (assert (testSyntheticAcceptance))
    (assert (testAblationQuadrantProgression))
    (assert (testDiscriminatorTaskCoverage))
    (assert (test12DiscriminatorsAdaptiveRouting))
    true))
