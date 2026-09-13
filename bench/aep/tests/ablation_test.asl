(module bench.aep.tests.ablationTest
  :d "Unit test suite for AEP 4-Quadrant Ablation Study Runner with empirical task execution and standard deviation."
  :x [TestGetDiscriminatorTasks
      TestExecuteAblationQuadrant
      TestCalculateAblationStdDev
      TestRunAblationStudyEmpirical
      TestVerifyConvergenceThresholds
      runTests]
  :i [("../ablation" :a abl)])

(df TestGetDiscriminatorTasks [] -> Bool
  :d "Verifies all 12 canonical discriminator tasks are cataloged"
  (let [(tasks (abl/getDiscriminatorTasks))]
    (assert (= (list-length tasks) 12) "Discriminator tasks length must be exactly 12")
    (assert (not (list-empty? tasks)) "Discriminator tasks must not be empty")
    true))

(df TestExecuteAblationQuadrant [] -> Bool
  :d "Verifies execute-ablation-quadrant executes tasks dynamically under specified quadrant configuration"
  (let [(tasks (abl/getDiscriminatorTasks))
        (cfgA (abl/quadrantABaseline))
        (cfgB (abl/quadrantBReformulate))
        (cfgC (abl/quadrantCPlanVerify))
        (cfgD (abl/quadrantDFullReflex))
        (rateA (abl/executeAblationQuadrant cfgA tasks))
        (rateB (abl/executeAblationQuadrant cfgB tasks))
        (rateC (abl/executeAblationQuadrant cfgC tasks))
        (rateD (abl/executeAblationQuadrant cfgD tasks))]
    (assert (<= rateA 0.20) "Quadrant A pass rate must be <= 0.20")
    (assert (> rateB rateA) "Quadrant B pass rate must exceed Quadrant A")
    (assert (> rateC rateB) "Quadrant C pass rate must exceed Quadrant B")
    (assert (>= rateD 0.90) "Quadrant D pass rate must be >= 0.90")
    true))

(df TestCalculateAblationStdDev [] -> Bool
  :d "Verifies standard deviation calculation across quadrant pass rates"
  (let [(rates (list 0.0 0.416 0.833 1.0))
        (sd (abl/calculateAblationStdDev rates))]
    (assert (> sd 0.1) "Standard deviation of divergent pass rates must exceed 0.1")
    (assert (< sd 1.0) "Standard deviation of normalized rates must be less than 1.0")
    true))

(df TestRunAblationStudyEmpirical [] -> Bool
  :d "Verifies run-ablation-study computes empirical metrics with standard deviation across live tasks"
  (let [(result (abl/runAblationStudy))]
    (assert (= (.-tasksEvaluated result) 12) "Evaluated tasks must be 12")
    (assert (= (.-tasksPassed result) 12) "Passed tasks under Full Reflex must be 12")
    (assert (<= (.-quadrantAPassRate result) 0.20) "Quadrant A baseline pass rate must be <= 0.20")
    (assert (> (.-quadrantBPassRate result) (.-quadrantAPassRate result)) "Quadrant B must exceed Quadrant A")
    (assert (> (.-quadrantCPassRate result) (.-quadrantBPassRate result)) "Quadrant C must exceed Quadrant B")
    (assert (>= (.-quadrantDPassRate result) 0.90) "Quadrant D full reflex pass rate must be >= 0.90")
    (assert (>= (.-contradictionRecall result) 0.98) "Contradiction recall must be >= 0.98")
    (assert (= (.-circularityDetection result) 1.0) "Circularity detection must be 1.0")
    (assert (= (.-hallucinationRate result) 0.0) "Hallucination rate must be 0.0")
    (assert (> (.-stdDev result) 0.0) "Ablation result must record positive empirical standard deviation")
    true))

(df TestVerifyConvergenceThresholds [] -> Bool
  :d "Verifies convergence criteria validation on empirical result"
  (let [(result (abl/runAblationStudy))]
    (assert (abl/verifyConvergenceThresholds result) "Convergence thresholds must be verified on study result")
    true))

(df runTests [] -> Bool
  :d "Acceptance test runner for ablation test"
  (let [(t1 (TestGetDiscriminatorTasks))
        (t2 (TestExecuteAblationQuadrant))
        (t3 (TestCalculateAblationStdDev))
        (t4 (TestRunAblationStudyEmpirical))
        (t5 (TestVerifyConvergenceThresholds))]
    (and t1 (and t2 (and t3 (and t4 t5))))))
