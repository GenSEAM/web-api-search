(module tests/acceptance/d81/Task-F29
  :d "Acceptance fixture for Task-F29: Prevent Permanent Deadlock on Intermediate Task States under ADR-0081."
  :x [RunTests
      TestStaleClarificationReapedByScheduler
      TestStaleReadyReapedByScheduler
      TestStaleVerifyingReapedByScheduler
      TestTerminalAndQueuedStatesNotReaped
      TestTaskF29GroundedInPhaseFINSEL]
  :i [(asl-core/scheduler :a sc)
      (asl-core/taskstore :a ts)
      (asl-core/tasktypes :a tt)])

(df TestStaleClarificationReapedByScheduler [] -> Bool
  :d "Verifies that a task stalled in state-clarification past stale timeout is reaped back to state-queued"
  (let [(cfg (sc/SchedulerConfig :max-concurrent 2 :stale-timeout-ms 5000))
        (store0 (ts/taskstore-create "/tmp/test-tasks-f29-clarify"))
        (t0 (tt/task-record-create "task-clarify-1" "lane-c" "/ws/proj-clarify" (tt/priority-normal) 1000 "payload-c"))
        (store1 (result-or (ts/taskstore-put store0 t0) store0))
        (store-claimed (result-or (ts/taskstore-claim store1 "task-clarify-1") store1))
        (store-clarify (result-or (ts/taskstore-transition store-claimed "task-clarify-1" (tt/state-clarification) 1000) store-claimed))
        (sched (sc/SchedulerState
                 :config cfg
                 :active-projects (list "/ws/proj-clarify")
                 :active-lanes (map-set (map-empty) "lane-c" 1)))
        (reap-res (result-or (sc/scheduler-reap-stale sched store-clarify 7000)
                             (sc/ReapResult :scheduler sched :store store-clarify :reaped-count 0)))]
    (assert (= (.-reaped-count reap-res) 1) "Stale clarification task must be reaped by scheduler")
    (let [(reaped-task (option-or (ts/taskstore-get (.-store reap-res) "task-clarify-1") t0))]
      (assert (= (.-state reaped-task) (tt/state-queued)) "Reaped clarification task must be reset to state-queued")
      (assert (not (list-contains? (.-active-projects (.-scheduler reap-res)) "/ws/proj-clarify")) "Reaping clarification task must release project lock")
      true)))

(df TestStaleReadyReapedByScheduler [] -> Bool
  :d "Verifies that a task stalled in state-ready past stale timeout is reaped back to state-queued"
  (let [(cfg (sc/SchedulerConfig :max-concurrent 2 :stale-timeout-ms 5000))
        (store0 (ts/taskstore-create "/tmp/test-tasks-f29-ready"))
        (t0 (tt/task-record-create "task-ready-1" "lane-r" "/ws/proj-ready" (tt/priority-normal) 1000 "payload-r"))
        (store1 (result-or (ts/taskstore-put store0 t0) store0))
        (store-claimed (result-or (ts/taskstore-claim store1 "task-ready-1") store1))
        (store-ready (result-or (ts/taskstore-transition store-claimed "task-ready-1" (tt/state-ready) 1000) store-claimed))
        (sched (sc/SchedulerState
                 :config cfg
                 :active-projects (list "/ws/proj-ready")
                 :active-lanes (map-set (map-empty) "lane-r" 1)))
        (reap-res (result-or (sc/scheduler-reap-stale sched store-ready 7000)
                             (sc/ReapResult :scheduler sched :store store-ready :reaped-count 0)))]
    (assert (= (.-reaped-count reap-res) 1) "Stale ready task must be reaped by scheduler")
    (let [(reaped-task (option-or (ts/taskstore-get (.-store reap-res) "task-ready-1") t0))]
      (assert (= (.-state reaped-task) (tt/state-queued)) "Reaped ready task must be reset to state-queued")
      (assert (not (list-contains? (.-active-projects (.-scheduler reap-res)) "/ws/proj-ready")) "Reaping ready task must release project lock")
      true)))

(df TestStaleVerifyingReapedByScheduler [] -> Bool
  :d "Verifies that a task stalled in state-verifying past stale timeout is reaped back to state-queued"
  (let [(cfg (sc/SchedulerConfig :max-concurrent 2 :stale-timeout-ms 5000))
        (store0 (ts/taskstore-create "/tmp/test-tasks-f29-verifying"))
        (t0 (tt/task-record-create "task-verify-1" "lane-v" "/ws/proj-verify" (tt/priority-normal) 1000 "payload-v"))
        (store1 (result-or (ts/taskstore-put store0 t0) store0))
        (store-claimed (result-or (ts/taskstore-claim store1 "task-verify-1") store1))
        (store-ready (result-or (ts/taskstore-transition store-claimed "task-verify-1" (tt/state-ready) 1000) store-claimed))
        (store-executing (result-or (ts/taskstore-transition store-ready "task-verify-1" (tt/state-executing) 1000) store-ready))
        (store-verifying (result-or (ts/taskstore-transition store-executing "task-verify-1" (tt/state-verifying) 1000) store-executing))
        (sched (sc/SchedulerState
                 :config cfg
                 :active-projects (list "/ws/proj-verify")
                 :active-lanes (map-set (map-empty) "lane-v" 1)))
        (reap-res (result-or (sc/scheduler-reap-stale sched store-verifying 7000)
                             (sc/ReapResult :scheduler sched :store store-verifying :reaped-count 0)))]
    (assert (= (.-reaped-count reap-res) 1) "Stale verifying task must be reaped by scheduler")
    (let [(reaped-task (option-or (ts/taskstore-get (.-store reap-res) "task-verify-1") t0))]
      (assert (= (.-state reaped-task) (tt/state-queued)) "Reaped verifying task must be reset to state-queued")
      (assert (not (list-contains? (.-active-projects (.-scheduler reap-res)) "/ws/proj-verify")) "Reaping verifying task must release project lock")
      true)))

(df TestTerminalAndQueuedStatesNotReaped [] -> Bool
  :d "Verifies that tasks in state-queued and terminal states are never reaped even after timeout"
  (let [(cfg (sc/SchedulerConfig :max-concurrent 2 :stale-timeout-ms 5000))
        (store0 (ts/taskstore-create "/tmp/test-tasks-f29-term"))
        (t-q (tt/task-record-create "task-q" "lane-t" "/ws/proj-term" (tt/priority-normal) 1000 "q"))
        (store1 (result-or (ts/taskstore-put store0 t-q) store0))
        (sched (sc/SchedulerState
                 :config cfg
                 :active-projects (list)
                 :active-lanes (map-empty)))
        (reap-res (result-or (sc/scheduler-reap-stale sched store1 7000)
                             (sc/ReapResult :scheduler sched :store store1 :reaped-count 0)))]
    (assert (= (.-reaped-count reap-res) 0) "Queued task must not be reaped")
    (let [(task-after (option-or (ts/taskstore-get (.-store reap-res) "task-q") t-q))]
      (assert (= (.-state task-after) (tt/state-queued)) "Task must remain in state-queued")
      true)))

(df TestTaskF29GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F29 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F29\""))
             (has-title (string-contains? content ":title \"Prevent Permanent Deadlock on Intermediate Task States\""))]
         (assert has-id "Task-F29 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F29 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F29"
  (let [(t1 (TestStaleClarificationReapedByScheduler))
        (t2 (TestStaleReadyReapedByScheduler))
        (t3 (TestStaleVerifyingReapedByScheduler))
        (t4 (TestTerminalAndQueuedStatesNotReaped))
        (t5 (TestTaskF29GroundedInPhaseFINSEL))]
    (and (and t1 t2) (and t3 (and t4 t5)))))
