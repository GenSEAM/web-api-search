(module tests/acceptance/d81/Task-F20
  :d "Acceptance fixture for Task-F20: Connect Ablation Study Runner to Genuine Model Inference Harness under ADR-0081."
  :x [RunTests
      TestGetDiscriminatorTasks
      TestEvaluateTask
      TestComputePassRate
      TestComputeEmpiricalStdDev
      TestRunAblationStudyEmpirical
      TestVerifyConvergenceThresholds
      TestTaskF20GroundedInPhaseFINSEL]
  :i [(bench.aep.ablation :a abl)])

(df TestGetDiscriminatorTasks [] -> Bool
  :d "Verifies all 12 canonical discriminator tasks are cataloged"
  (let [(tasks (abl/get-discriminator-tasks))]
    (assert (= (list-length tasks) 12) "Discriminator tasks length must be exactly 12")
    (assert (not (list-empty? tasks)) "Discriminator tasks must not be empty")
    true))

(df TestEvaluateTask [] -> Bool
  :d "Verifies evaluate-task checks task outcome under a specific quadrant configuration"
  (let [(task (option-unwrap (list-head (abl/get-discriminator-tasks))))
        (cfg-a (abl/quadrant-a-baseline))
        (cfg-d (abl/quadrant-d-full-reflex))
        (res-a (abl/evaluate-task task cfg-a))
        (res-d (abl/evaluate-task task cfg-d))]
    (assert (not res-a) "First task should fail under Quadrant A baseline")
    (assert res-d "First task should pass under Quadrant D full reflex")
    true))

(df TestComputePassRate [] -> Bool
  :d "Verifies compute-pass-rate calculates empirical pass rate for a quadrant configuration"
  (let [(tasks (abl/get-discriminator-tasks))
        (cfg-a (abl/quadrant-a-baseline))
        (cfg-b (abl/quadrant-b-reformulate))
        (cfg-c (abl/quadrant-c-plan-verify))
        (cfg-d (abl/quadrant-d-full-reflex))
        (rate-a (abl/compute-pass-rate cfg-a tasks))
        (rate-b (abl/compute-pass-rate cfg-b tasks))
        (rate-c (abl/compute-pass-rate cfg-c tasks))
        (rate-d (abl/compute-pass-rate cfg-d tasks))]
    (assert (<= rate-a 0.20) "Quadrant A pass rate must be <= 0.20")
    (assert (> rate-b rate-a) "Quadrant B pass rate must exceed Quadrant A")
    (assert (> rate-c rate-b) "Quadrant C pass rate must exceed Quadrant B")
    (assert (>= rate-d 0.90) "Quadrant D pass rate must be >= 0.90")
    true))

(df TestComputeEmpiricalStdDev [] -> Bool
  :d "Verifies standard deviation calculation across quadrant pass rates"
  (let [(rates (list 0.0 0.416 0.833 1.0))
        (sd (abl/compute-empirical-std-dev rates))]
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

(df TestTaskF20GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F20 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F20\""))
             (has-title (string-contains? content ":title \"Connect Ablation Study Runner to Genuine Model Inference Harness\""))]
         (assert has-id "Task-F20 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F20 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F20"
  (let [(t1 (TestGetDiscriminatorTasks))
        (t2 (TestEvaluateTask))
        (t3 (TestComputePassRate))
        (t4 (TestComputeEmpiricalStdDev))
        (t5 (TestRunAblationStudyEmpirical))
        (t6 (TestVerifyConvergenceThresholds))
        (t7 (TestTaskF20GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 (and t4 (and t5 (and t6 t7))))))))
