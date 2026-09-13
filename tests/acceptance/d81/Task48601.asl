(module tests/acceptance/d81/Task48601
  :d "Acceptance fixture for Task48601: Scheduler tests."
  :x [runTests]
  :i [(aslMesh/scheduler :a sched)])

(df testSchedulerWorktreePool [] -> Bool
  (let [(pool (sched/worktree_pool "/tmp/mesh" 3))]
    (assert (= (list-length pool) 3) "Pool must have 3 elements")
    (assert (= (option-or (list-get pool 0) "") "/tmp/mesh/worker-0") "First worker path")
    (refute (= (option-or (list-get pool 0) "") "/tmp/mesh/worker-1") "First worker path is not worker-1")
    true))

(df testSchedulerSchedulePartitions [] -> Bool
  (let [(pkgs (list "pkg1" "pkg2"))
        (workers (list {:workerId "w1" :tier "pro"} {:workerId "w2" :tier "flash"}))
        (parts (sched/schedule_partitions pkgs workers))
        (firstPart (option-or (list-get parts 0) map-empty))]
    (assert (= (list-length parts) 2) "Parts must match workers")
    (assert (= (option-or (map-get firstPart :worker) "") "w1") "First part worker is w1")
    (refute (= (option-or (map-get firstPart :worker) "") "w2") "First part worker is not w2")
    true))

(df runTests [] -> Bool
  (let [(r1 (testSchedulerWorktreePool))
        (r2 (testSchedulerSchedulePartitions))]
    (assert (and r1 r2) "All scheduler tests pass")
    true))
