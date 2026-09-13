(module bench.aep.tests.ablation-test
  :d "Unit test suite for AEP 4-Quadrant Ablation Study Runner with empirical task execution and standard deviation."
  :x [TestGetDiscriminatorTasks
      TestExecuteAblationQuadrant
      TestCalculateAblationStdDev
      TestRunAblationStudyEmpirical
      TestVerifyConvergenceThresholds
      run-tests]
  :i [("../ablation" :a abl)])

(df TestGetDiscriminatorTasks [] -> Bool
  :d "Verifies all 12 canonical discriminator tasks are cataloged"
  (let [(tasks (abl/get-discriminator-tasks))]
    (assert (= (list-length tasks) 12) "Discriminator tasks length must be exactly 12")
    (assert (not (list-empty? tasks)) "Discriminator tasks must not be empty")
    true))

(df TestExecuteAblationQuadrant [] -> Bool
  :d "Verifies execute-ablation-quadrant executes tasks dynamically under specified quadrant configuration"
  (let [(tasks (abl/get-discriminator-tasks))
        (cfg-a (abl/quadrant-a-baseline))
        (cfg-b (abl/quadrant-b-reformulate))
        (cfg-c (abl/quadrant-c-plan-verify))
        (cfg-d (abl/quadrant-d-full-reflex))
        (rate-a (abl/execute-ablation-quadrant cfg-a tasks))
        (rate-b (abl/execute-ablation-quadrant cfg-b tasks))
        (rate-c (abl/execute-ablation-quadrant cfg-c tasks))
        (rate-d (abl/execute-ablation-quadrant cfg-d tasks))]
    (assert (<= rate-a 0.20) "Quadrant A pass rate must be <= 0.20")
    (assert (> rate-b rate-a) "Quadrant B pass rate must exceed Quadrant A")
    (assert (> rate-c rate-b) "Quadrant C pass rate must exceed Quadrant B")
    (assert (>= rate-d 0.90) "Quadrant D pass rate must be >= 0.90")
    true))

(df TestCalculateAblationStdDev [] -> Bool
  :d "Verifies standard deviation calculation across quadrant pass rates"
  (let [(rates (list 0.0 0.416 0.833 1.0))
        (sd (abl/calculate-ablation-std-dev rates))]
    (assert (> sd 0.1) "Standard deviation of divergent pass rates must exceed 0.1")
    (assert (< sd 1.0) "Standard deviation of normalized rates must be less than 1.0")
    true))

(df TestRunAblationStudyEmpirical [] -> Bool
  :d "Verifies run-ablation-study computes empirical metrics with standard deviation across live tasks"
  (let [(result (abl/run-ablation-study))]
    (assert (= (.-tasks-evaluated result) 12) "Evaluated tasks must be 12")
    (assert (= (.-tasks-passed result) 12) "Passed tasks under Full Reflex must be 12")
    (assert (<= (.-quadrant-a-pass-rate result) 0.20) "Quadrant A baseline pass rate must be <= 0.20")
    (assert (> (.-quadrant-b-pass-rate result) (.-quadrant-a-pass-rate result)) "Quadrant B must exceed Quadrant A")
    (assert (> (.-quadrant-c-pass-rate result) (.-quadrant-b-pass-rate result)) "Quadrant C must exceed Quadrant B")
    (assert (>= (.-quadrant-d-pass-rate result) 0.90) "Quadrant D full reflex pass rate must be >= 0.90")
    (assert (>= (.-contradiction-recall result) 0.98) "Contradiction recall must be >= 0.98")
    (assert (= (.-circularity-detection result) 1.0) "Circularity detection must be 1.0")
    (assert (= (.-hallucination-rate result) 0.0) "Hallucination rate must be 0.0")
    (assert (> (.-std-dev result) 0.0) "Ablation result must record positive empirical standard deviation")
    true))

(df TestVerifyConvergenceThresholds [] -> Bool
  :d "Verifies convergence criteria validation on empirical result"
  (let [(result (abl/run-ablation-study))]
    (assert (abl/verify-convergence-thresholds result) "Convergence thresholds must be verified on study result")
    true))

(df run-tests [] -> Bool
  :d "Acceptance test runner for ablation test"
  (let [(t1 (TestGetDiscriminatorTasks))
        (t2 (TestExecuteAblationQuadrant))
        (t3 (TestCalculateAblationStdDev))
        (t4 (TestRunAblationStudyEmpirical))
        (t5 (TestVerifyConvergenceThresholds))]
    (and t1 (and t2 (and t3 (and t4 t5))))))
