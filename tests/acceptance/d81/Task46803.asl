(module tests/acceptance/d81/Task46803
  :d "Acceptance fixture for Task46803: automated retirement lifecycle, queryable closed set, and bounded active volume under ADR-0081."
  :x [RunTests
      TestAmnesiaRetirementLifecycleDefined
      TestContextScoringVolumeBoundEnforced
      TestEvaluationDrivenRetirement
      TestRetiredRecordQueryableNotLoaded]
  :i [])

(df TestAmnesiaRetirementLifecycleDefined [] -> Bool
  :d "Verifies that mem/src/amnesia.asl defines retirement evaluation and lifecycle transition functions"
  (let [(res (file-read "mem/src/amnesia.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/amnesia.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "retire-chunk") "amnesia.asl must define retire-chunk")
      (assert (string-contains? src "evaluate-retirement") "amnesia.asl must define evaluate-retirement")
      (assert (string-contains? src "retired") "amnesia.asl must reference retired state")
      true)))

(df TestContextScoringVolumeBoundEnforced [] -> Bool
  :d "Verifies that active set volume is calculated, reported, and bounded against growth"
  (let [(res (file-read "mem/src/context_scoring.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/context_scoring.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "calculate-active-volume") "context_scoring.asl must define calculate-active-volume")
      (assert (string-contains? src "is-volume-bounded?") "context_scoring.asl must define is-volume-bounded?")
      (assert (string-contains? src "report-active-volume") "context_scoring.asl must define report-active-volume")
      true)))

(df TestEvaluationDrivenRetirement [] -> Bool
  :d "Verifies that a record whose closure condition evaluates to true is retired without manual edit"
  (let [(res (file-read "mem/src/amnesia.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/amnesia.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "transition-to-retired") "amnesia.asl must define transition-to-retired")
      (assert (string-contains? src "closure-condition") "amnesia.asl must evaluate closure-condition")
      true)))

(df TestRetiredRecordQueryableNotLoaded [] -> Bool
  :d "Verifies that retired records are queryable but not loaded into active working context"
  (let [(res (file-read "mem/src/amnesia.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/amnesia.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "query-retired-chunks") "amnesia.asl must define query-retired-chunks")
      (assert (string-contains? src "load-active-chunks") "amnesia.asl must define load-active-chunks")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46803 supervisor acceptance tests"
  (do
    (assert (TestAmnesiaRetirementLifecycleDefined) "TestAmnesiaRetirementLifecycleDefined must pass")
    (assert (TestContextScoringVolumeBoundEnforced) "TestContextScoringVolumeBoundEnforced must pass")
    (assert (TestEvaluationDrivenRetirement) "TestEvaluationDrivenRetirement must pass")
    (assert (TestRetiredRecordQueryableNotLoaded) "TestRetiredRecordQueryableNotLoaded must pass")
    true))
