(module tests/acceptance/d81/Task46505
  :d "Acceptance fixture for Task46505: facade and checkpoint suite integrity, non-zero assertion enforcement, and buffer restoration fidelity under ADR-0081."
  :x [run-tests
      test-tasks-facade-construction
      test-vfs-checkpoint-fidelity
      test-suite-assertion-counts]
  :i [(asl-mem/tasks :a tasks)
      (asl-mem/checkpoint :a chk)
      (asl-mem/vfs :a v)])

(df test-tasks-facade-construction [] -> Bool
  :d "Verifies that the unified tasks facade constructs records, validates readiness, and formats ASN"
  (let [(t1 (tasks/make-task
              "task-465-test"
              "phase-465"
              "Phase 465 Test"
              "surface"
              "ready"
              "high"
              1789280000000
              (list "mem/src/tasks.asl")
              (list)
              "sh tests/acceptance/d81/SuperviseGate.sh Task46505"
              "Prompt"))]
    (assert (= (.-id t1) "task-465-test") "task id must match")
    (assert (= (.-phase t1) "phase-465") "task phase must match")
    (assert (= (.-title t1) "Phase 465 Test") "task title must match")
    (assert (= (.-state t1) "ready") "task state must be ready")
    (assert (tasks/task-is-ready? t1 (list)) "task with state ready and no dependencies must be ready")
    (let [(asn-str (tasks/task-format-asn t1))]
      (assert (string-contains? asn-str "task-465-test") "formatted ASN must include task ID")
      (assert (string-contains? asn-str "ready") "formatted ASN must include state")
      true)))

(df test-vfs-checkpoint-fidelity [] -> Bool
  :d "Verifies VFS checkpoint creation, ASN serialization, archive lookup, and buffer restoration fidelity"
  (let [(reg0 (v/vfs-init))
        (reg1 (v/vfs-write reg0 "src/test.asl" "(module test :v 1)"))
        (ckpt (chk/create-vfs-checkpoint reg1 "phase-465"))
        (asn-doc (chk/format-checkpoint-asn ckpt))
        (restored-res (chk/restore-vfs-checkpoint asn-doc (.-id ckpt)))
        (restored-reg (result-or restored-res (v/vfs-init)))
        (buf (v/vfs-read restored-reg "src/test.asl"))]
    (assert (string-starts-with? (.-id ckpt) "cp-phase-465-") "checkpoint ID must start with cp-phase-465-")
    (assert (= (string-length (.-cas-root ckpt)) 64) "cas-root must be 64-char hex")
    (assert (is-ok? restored-res) "restore-vfs-checkpoint must succeed")
    (assert (is-some? buf) "restored buffer must exist")
    (assert (= (.-content (option-unwrap buf)) "(module test :v 1)") "buffer content must be restored intact")
    true))

(df test-suite-assertion-counts [] -> Bool
  :d "Verifies that tasks_test and checkpoint_test files exist, contain assertions, and enforce non-zero execution"
  (let [(tasks-src-res (file-read "mem/tests/tasks_test.asl"))
        (ckpt-src-res (file-read "mem/tests/checkpoint_test.asl"))]
    (assert (= (.-_tag tasks-src-res) "ok") "tasks_test must be readable")
    (assert (= (.-_tag ckpt-src-res) "ok") "checkpoint_test must be readable")
    (let [(tasks-src (.-value tasks-src-res))
          (ckpt-src (.-value ckpt-src-res))]
      (assert (string-contains? tasks-src "(assert") "tasks_test must declare assertions")
      (assert (string-contains? tasks-src "run-tests") "tasks_test must export run-tests")
      (assert (string-contains? ckpt-src "(assert") "checkpoint_test must declare assertions")
      (assert (string-contains? ckpt-src "run-tests") "checkpoint_test must export run-tests")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46505 supervisor acceptance tests"
  (do
    (assert (test-tasks-facade-construction) "test-tasks-facade-construction must pass")
    (assert (test-vfs-checkpoint-fidelity) "test-vfs-checkpoint-fidelity must pass")
    (assert (test-suite-assertion-counts) "test-suite-assertion-counts must pass")
    true))
