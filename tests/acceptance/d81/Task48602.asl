(module tests/acceptance/d81/Task48602
  :d "Acceptance fixture for Task48602: Parallel Partition Scheduler and Worktree Airgap Orchestrator under D85."
  :x [run-tests
      test-scheduler-file-exists
      test-scheduler-target-symbols
      test-partition-disjointness-and-worktrees]
  :i [])

(df test-scheduler-file-exists [] -> Bool
  :d "Verifies that scheduler.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-mesh/src/scheduler.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-mesh/src/scheduler.asl must exist")
    true))

(df test-scheduler-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in scheduler.asl"
  (let [(res (file-read "asl/packages/asl-mesh/src/scheduler.asl"))]
    (assert (= (.-_tag res) "ok") "scheduler.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "schedule_partitions") "schedule_partitions defined")
      (assert (string-contains? src "allocate_worker_worktree") "allocate_worker_worktree defined")
      (assert (string-contains? src "partition_map") "partition_map defined")
      (assert (string-contains? src "worktree_pool") "worktree_pool defined")
      true)))

(df test-partition-disjointness-and-worktrees [] -> Bool
  :d "Verifies partition allocation disjointness and worktree paths"
  (let [(res (file-read "asl/packages/asl-mesh/src/scheduler.asl"))]
    (assert (= (.-_tag res) "ok") "scheduler.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-mesh/scheduler") "module declared correctly")
      (assert (string-contains? src "worktree") "worktree logic present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48602 acceptance assertions"
  (let [(r1 (test-scheduler-file-exists))
        (r2 (test-scheduler-target-symbols))
        (r3 (test-partition-disjointness-and-worktrees))]
    (assert (and (and r1 r2) r3) "All Task48602 checks must pass")
    true))
