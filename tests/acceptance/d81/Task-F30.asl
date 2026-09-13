(module tests/acceptance/d81/Task-F30
  :d "Acceptance fixture for Task-F30: Correct Field Target in Pub/Sub Event Filtering under ADR-0081."
  :x [RunTests
      TestQueryBusEventsFiltersByTargetAddress
      TestQueryBusEventsFiltersCombinedChannelAndTarget
      TestQueryBusEventsIgnoresTargetWhenFilterEmpty
      TestQueryBusEventsNonExistentTargetReturnsEmpty
      TestTaskF30GroundedInPhaseFINSEL]
  :i [(agent-bus/bus :a b)])

(df TestQueryBusEventsFiltersByTargetAddress [] -> Bool
  :d "Verifies query-bus-events checks target address field of AgentMessage rather than searching inside payload"
  (let [(m-lead (b/AgentMessage :sender "auditor" :target "agent-lead" :payload "(:task :state \"executing\")" :timestamp 100))
        (m-worker (b/AgentMessage :sender "auditor" :target "agent-worker" :payload "(:task :state \"executing\" :note \"agent-lead is busy\")" :timestamp 101))
        (events (list m-lead m-worker))
        (results (b/query-bus-events events "" "agent-lead"))]
    (assert (= (list-length results) 1) "query-bus-events matching target 'agent-lead' must return exactly 1 message")
    (let [(found (option-or (list-head results) m-worker))]
      (assert (= (.-target found) "agent-lead") "Matched message target must be 'agent-lead'")
      (assert (= (.-sender found) "auditor") "Matched message sender must be 'auditor'")
      (assert (not (= (.-target found) "agent-worker")) "Worker message must not match target agent-lead")
      true)))

(df TestQueryBusEventsFiltersCombinedChannelAndTarget [] -> Bool
  :d "Verifies query-bus-events filters both payload channel and target address concurrently"
  (let [(m1 (b/AgentMessage :sender "lead" :target "worker-1" :payload "(:change :file \"a.asl\")" :timestamp 100))
        (m2 (b/AgentMessage :sender "lead" :target "worker-2" :payload "(:change :file \"b.asl\")" :timestamp 101))
        (m3 (b/AgentMessage :sender "lead" :target "worker-1" :payload "(:audit :file \"a.asl\")" :timestamp 102))
        (events (list m1 m2 m3))
        (res-change (b/query-bus-events events "change" "worker-1"))
        (res-audit (b/query-bus-events events "audit" "worker-1"))
        (res-w2 (b/query-bus-events events "change" "worker-2"))]
    (assert (= (list-length res-change) 1) "Must find exactly 1 change event for worker-1")
    (assert (= (list-length res-audit) 1) "Must find exactly 1 audit event for worker-1")
    (assert (= (list-length res-w2) 1) "Must find exactly 1 change event for worker-2")
    (let [(found-change (option-or (list-head res-change) m2))]
      (assert (= (.-target found-change) "worker-1") "Target must be worker-1")
      (assert (string-contains? (.-payload found-change) "change") "Payload must contain change")
      true)))

(df TestQueryBusEventsIgnoresTargetWhenFilterEmpty [] -> Bool
  :d "Verifies query-bus-events with empty target filter matches all messages on channel"
  (let [(m1 (b/AgentMessage :sender "s1" :target "t1" :payload "(:event :kind \"test\")" :timestamp 100))
        (m2 (b/AgentMessage :sender "s2" :target "t2" :payload "(:event :kind \"test\")" :timestamp 101))
        (events (list m1 m2))
        (results (b/query-bus-events events "test" ""))]
    (assert (= (list-length results) 2) "Empty target filter must return both messages")
    true))

(df TestQueryBusEventsNonExistentTargetReturnsEmpty [] -> Bool
  :d "Verifies query-bus-events returns empty list when target does not match any message"
  (let [(m1 (b/AgentMessage :sender "s1" :target "agent-alpha" :payload "(:msg 1)" :timestamp 100))
        (m2 (b/AgentMessage :sender "s2" :target "agent-beta" :payload "(:msg 2)" :timestamp 101))
        (events (list m1 m2))
        (results (b/query-bus-events events "" "agent-gamma"))]
    (assert (= (list-length results) 0) "Non-existent target must return empty list")
    true))

(df TestTaskF30GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F30 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F30\""))
             (has-title (string-contains? content ":title \"Correct Field Target in Pub/Sub Event Filtering\""))]
         (assert has-id "Task-F30 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F30 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F30"
  (let [(t1 (TestQueryBusEventsFiltersByTargetAddress))
        (t2 (TestQueryBusEventsFiltersCombinedChannelAndTarget))
        (t3 (TestQueryBusEventsIgnoresTargetWhenFilterEmpty))
        (t4 (TestQueryBusEventsNonExistentTargetReturnsEmpty))
        (t5 (TestTaskF30GroundedInPhaseFINSEL))]
    (and (and t1 t2) (and t3 (and t4 t5)))))
