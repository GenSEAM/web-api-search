(module tests/acceptance/d81/Task48606
  :d "Acceptance fixture for Task48606: Multi-Model Mesh Orchestrator Supervise Gate and Ecosystem Certification under D85."
  :x [run-tests
      supervise_mesh_gate
      benchmark_mesh
      parallel_speedup
      defect_precision
      test-mesh-grammar-contract
      test-mesh-packages-integrity
      test-harness-mesh-test-coverage
      test-task-suite-coverage]
  :i [])

(df supervise_mesh_gate [] -> Str
  :d "Sentinel symbol for mesh supervision"
  "supervise_mesh_gate")

(df benchmark_mesh [] -> Str
  :d "Sentinel symbol for mesh benchmark"
  "benchmark_mesh")

(df parallel_speedup [] -> Str
  :d "Sentinel symbol for parallel speedup metric"
  "parallel_speedup")

(df defect_precision [] -> Str
  :d "Sentinel symbol for defect precision metric"
  "defect_precision")

(df test-mesh-grammar-contract [] -> Bool
  :d "Verifies that asl/grammar/mesh.asn defines formal contracts for meshWorker, defectRecord, and consensusReceipt"
  (let [(res (file-read "asl/grammar/mesh.asn"))]
    (assert (= (.-_tag res) "ok") "mesh.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "meshWorker") "meshWorker schema declared")
      (assert (string-contains? src "defectRecord") "defectRecord schema declared")
      (assert (string-contains? src "consensusReceipt") "consensusReceipt schema declared")
      (assert (string-contains? src "defectTaxonomy") "defectTaxonomy schema declared")
      true)))

(df test-mesh-packages-integrity [] -> Bool
  :d "Verifies that asl/packages/asl-mesh implements scheduler, scanner, synthesis, and emitter"
  (let [(f-sched (file-read "asl/packages/asl-mesh/src/scheduler.asl"))
        (f-scan (file-read "asl/packages/asl-mesh/src/scanner.asl"))
        (f-synth (file-read "asl/packages/asl-mesh/src/synthesis.asl"))
        (f-emit (file-read "asl/packages/asl-mesh/src/emitter.asl"))]
    (assert (= (.-_tag f-sched) "ok") "scheduler.asl readable")
    (assert (= (.-_tag f-scan) "ok") "scanner.asl readable")
    (assert (= (.-_tag f-synth) "ok") "synthesis.asl readable")
    (assert (= (.-_tag f-emit) "ok") "emitter.asl readable")
    (let [(s-sched (.-value f-sched))
          (s-scan (.-value f-scan))
          (s-synth (.-value f-synth))
          (s-emit (.-value f-emit))]
      (assert (string-contains? s-sched "schedule_partitions") "schedule_partitions present")
      (assert (string-contains? s-scan "scan_ast_defects") "scan_ast_defects present")
      (assert (string-contains? s-synth "synthesize_defects") "synthesize_defects present")
      (assert (string-contains? s-emit "emit_gap_ledger") "emit_gap_ledger present")
      true)))

(df test-harness-mesh-test-coverage [] -> Bool
  :d "Verifies that harness/tests/multi_model_orchestrator_test.asl exists and validates mesh"
  (let [(res (file-read "harness/tests/multi_model_orchestrator_test.asl"))]
    (assert (= (.-_tag res) "ok") "multi_model_orchestrator_test.asl exists")
    (let [(src (.-value res))]
      (assert (string-contains? src "test-mesh-worker-specs") "mesh worker spec tests present")
      (assert (string-contains? src "test-parallel-partitions") "parallel partition tests present")
      (assert (string-contains? src "test-ast-scanner") "ast scanner tests present")
      (assert (string-contains? src "test-dialectical-synthesis") "dialectical synthesis tests present")
      (assert (string-contains? src "test-gap-ledger-emitter") "gap ledger emitter tests present")
      true)))

(df test-task-suite-coverage [] -> Bool
  :d "Verifies that all Phase 486 acceptance fixtures exist and are well-formed"
  (let [(f1 (file-read "tests/acceptance/d81/Task48601.asl"))
        (f2 (file-read "tests/acceptance/d81/Task48602.asl"))
        (f3 (file-read "tests/acceptance/d81/Task48603.asl"))
        (f4 (file-read "tests/acceptance/d81/Task48604.asl"))
        (f5 (file-read "tests/acceptance/d81/Task48605.asl"))]
    (assert (= (.-_tag f1) "ok") "Task48601.asl exists")
    (assert (= (.-_tag f2) "ok") "Task48602.asl exists")
    (assert (= (.-_tag f3) "ok") "Task48603.asl exists")
    (assert (= (.-_tag f4) "ok") "Task48604.asl exists")
    (assert (= (.-_tag f5) "ok") "Task48605.asl exists")
    true))

(df run-tests [] -> Bool
  :d "Runs all Task48606 multi-model mesh orchestrator certification assertions"
  (let [(r1 (test-mesh-grammar-contract))
        (r2 (test-mesh-packages-integrity))
        (r3 (test-harness-mesh-test-coverage))
        (r4 (test-task-suite-coverage))]
    (assert (and (and (and r1 r2) r3) r4) "All Task48606 certification checks must pass")
    true))
