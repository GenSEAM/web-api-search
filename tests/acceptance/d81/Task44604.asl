(module tests/acceptance/d81/Task44604
  :d "Acceptance fixture for Task44604: Parallel development across runtimes: partitioned ownership and conflict resolution at the relay under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRelayLeaseRegistryContract
      TestRelayWriteValidationAndStaleRejectionContract
      TestDisjointPartitionsProceedWithoutContentionContract
      TestEngineStaleLeaseRejectionContract
      TestTask44604GroundedInPhase446]
  :i [("../../../agent-bus/src/cluster" :a cluster)
      ("../../../agent-bus/src/gateway" :a gateway)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestRelayLeaseRegistryContract [] -> Bool
  :d "Verifies authoritative relay lease registry: first claim succeeds, second claim from different session is refused"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/cluster.asl" "session-alpha" "Task44604" 5000 1000 "d-initial"))]
    (assert (is-ok? c1) "First claimant must acquire lease")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))]
         (assert (= (.-logical-path l1) "src/cluster.asl") "Path is src/cluster.asl")
         (assert (= (.-session-id l1) "session-alpha") "Session is session-alpha")
         (assert (= (.-task-id l1) "Task44604") "Task is Task44604")
         (let [(c2 (cluster/relay-claim-lease reg1 "src/cluster.asl" "session-beta" "Task44605" 5000 2000 "d-other"))]
           (assert (is-err? c2) "Second claimant on active lease must be refused")
           (mt c2
             ((ok _) false)
             ((err e2)
              (assert (= e2 "ERR_LEASE_CONFLICT") "Error must be ERR_LEASE_CONFLICT")
              true))))))))

(df TestRelayWriteValidationAndStaleRejectionContract [] -> Bool
  :d "Verifies write permission validation at relay and gateway: unleased or expired writes rejected with ERR_STALE_LEASE"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/cluster.asl" "session-alpha" "Task44604" 5000 1000 "d-initial"))]
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))]
         (let [(v-alpha (gateway/validate-relay-write-permission reg1 "src/cluster.asl" "session-alpha" 2000))
               (v-beta (gateway/validate-relay-write-permission reg1 "src/cluster.asl" "session-beta" 2000))
               (v-exp (gateway/validate-relay-write-permission reg1 "src/cluster.asl" "session-alpha" 7000))]
           (assert (is-ok? v-alpha) "Current leaseholder write must pass gateway filter")
           (assert (is-err? v-beta) "Unleased session write must be rejected at gateway")
           (mt v-beta
             ((ok _) false)
             ((err e-beta)
              (assert (= e-beta "ERR_STALE_LEASE") "Unleased write rejected with ERR_STALE_LEASE")
              (assert (is-err? v-exp) "Expired lease must fail closed at gateway")
              (mt v-exp
                ((ok _) false)
                ((err e-exp)
                 (assert (= e-exp "ERR_STALE_LEASE") "Expired write rejected with ERR_STALE_LEASE")
                 true))))))))))

(df TestDisjointPartitionsProceedWithoutContentionContract [] -> Bool
  :d "Verifies two agents working disjoint partitions derived from task owns proceed without contention"
  (let [(task-a-owns (list "agent-bus/src/cluster.asl" "agent-bus/src/gateway.asl"))
        (task-b-owns (list "asl/tools/asl.c" ".asl/mem/telemetry/mesh-trace.asn"))
        (task-c-owns (list "agent-bus/src/cluster.asl" "asl/tools/asl.c"))]
    (assert (not (cluster/check-partition-conflicts task-a-owns task-b-owns)) "Disjoint partitions have zero contention")
    (assert (cluster/check-partition-conflicts task-a-owns task-c-owns) "Overlapping partitions correctly detected as conflict")
    (let [(reg0 (cluster/create-relay-lease-registry))
          (cA (cluster/relay-claim-lease reg0 "pathA" "session-A" "TaskA" 10000 1000 "dA"))]
      (mt cA
        ((err _) false)
        ((ok lA)
         (let [(reg1 (cluster/relay-registry-with-lease reg0 lA))
               (cB (cluster/relay-claim-lease reg1 "pathB" "session-B" "TaskB" 10000 1000 "dB"))]
           (assert (is-ok? cB) "Claim on disjoint path must succeed")
           (mt cB
             ((err _) false)
             ((ok lB)
              (let [(reg2 (cluster/relay-registry-with-lease reg1 lB))
                    (vA (cluster/relay-verify-write reg2 "pathA" "session-A" 2000))
                    (vB (cluster/relay-verify-write reg2 "pathB" "session-B" 2000))]
                (assert (is-ok? vA) "Session-A write on pathA succeeds")
                (assert (is-ok? vB) "Session-B write on pathB succeeds without contention")
                true)))))))))

(df TestEngineStaleLeaseRejectionContract [] -> Bool
  :d "Verifies asl.c engine implements ERR_STALE_LEASE rejection and lease staleness checking"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "ERR_STALE_LEASE") "asl.c must implement ERR_STALE_LEASE")
      (assert (string-contains? c-src "check_lease_staleness") "asl.c must implement check_lease_staleness")
      (assert (string-contains? c-src "find_raw_lease_for_path") "asl.c must implement find_raw_lease_for_path")
      (assert (string-contains? c-src "execute_single_step") "asl.c must enforce lease checks in execute_single_step")
      true)))

(df TestTask44604GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44604"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Parallel development across runtimes: partitioned") "Phase 446 must state Task44604 title")
      (assert (string-contains? p-src ":lane \"parallel\"") "Phase 446 must specify parallel lane")
      (assert (string-contains? p-src "agent-bus/src/cluster.asl") "Phase 446 must own cluster.asl")
      (assert (string-contains? p-src "agent-bus/src/gateway.asl") "Phase 446 must own gateway.asl")
      (assert (string-contains? p-src "asl/tools/asl.c") "Phase 446 must own asl.c")
      (assert (string-contains? p-src "execute_single_step") "Phase 446 must target execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44604 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRelayLeaseRegistryContract) "TestRelayLeaseRegistryContract must pass")
    (assert (TestRelayWriteValidationAndStaleRejectionContract) "TestRelayWriteValidationAndStaleRejectionContract must pass")
    (assert (TestDisjointPartitionsProceedWithoutContentionContract) "TestDisjointPartitionsProceedWithoutContentionContract must pass")
    (assert (TestEngineStaleLeaseRejectionContract) "TestEngineStaleLeaseRejectionContract must pass")
    (assert (TestTask44604GroundedInPhase446) "TestTask44604GroundedInPhase446 must pass")
    true))
