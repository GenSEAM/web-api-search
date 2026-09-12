(module tests/acceptance/d81/Task44604
  :d "Acceptance fixture for Task44604: Partitioned ownership and relay conflict resolution."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTask44604GroundedInPhase446
      TestRelayLeaseRegistryAndClaim
      TestSecondClaimantRefusalAndConflict
      TestRelayVerifyWriteCurrentLease
      TestRelayVerifyWriteUnleasedRejection
      TestExpiredLeaseFailsClosed
      TestExplicitRelayRelease
      TestTaskPartitionDerivationFromOwns
      TestDisjointPartitionsProceedWithoutContention
      TestGatewayWritePermissionIntegration
      TestAslRpcLeaseOperations]
  :i [("../../../agent-bus/src/cluster" :a cluster)
      ("../../../agent-bus/src/gateway" :a gateway)])

(df TestRelayLeaseRegistryAndClaim [] -> Bool
  :d "Verifies initial claim of logical artifact lease at relay"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (res (cluster/relay-claim-lease reg0 "src/compiler.asl" "session-node-1" "Task44604" 10000 1000 "d-initial"))]
    (assert (is-ok? res) "Claim on available path must succeed")
    (mt res
      ((err _) false)
      ((ok lease)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 lease))]
         (assert (= (.-logical-path lease) "src/compiler.asl") "Path must match")
         (assert (= (.-session-id lease) "session-node-1") "Session must match")
         (assert (= (.-task-id lease) "Task44604") "Task must match")
         (assert (= (.-granted-at lease) 1000) "Granted timestamp must match")
         (assert (= (.-ttl-ms lease) 10000) "TTL must match")
         (assert (= (.-digest lease) "d-initial") "Digest must match")
         (let [(v-self (cluster/relay-verify-write reg1 "src/compiler.asl" "session-node-1" 2000))]
           (assert (is-ok? v-self) "Lease holder write must verify successfully")
           true))))))

(df TestSecondClaimantRefusalAndConflict [] -> Bool
  :d "Verifies that second claimant is refused with ERR_LEASE_CONFLICT when lease is active"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/store.asl" "session-node-1" "Task44604" 10000 1000 "d-store-1"))]
    (assert (is-ok? c1) "First claimant must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (c2 (cluster/relay-claim-lease reg1 "src/store.asl" "session-node-2" "Task44699" 10000 2000 "d-store-2"))]
         (assert (is-err? c2) "Second claimant must be refused")
         (mt c2
           ((ok _) false)
           ((err err-msg)
            (assert (= err-msg "ERR_LEASE_CONFLICT") "Error code must be ERR_LEASE_CONFLICT")
            true)))))))

(df TestRelayVerifyWriteCurrentLease [] -> Bool
  :d "Verifies relay write verification allows authorized session with current lease"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/bus.asl" "session-node-1" "Task44604" 5000 1000 "d-bus"))]
    (assert (is-ok? c1) "Claim must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (v-check (cluster/relay-verify-write reg1 "src/bus.asl" "session-node-1" 3000))]
         (assert (is-ok? v-check) "Write within TTL from lease holder must pass")
         (mt v-check
           ((err _) false)
           ((ok passed)
            (assert passed "Result must be true")
            true)))))))

(df TestRelayVerifyWriteUnleasedRejection [] -> Bool
  :d "Verifies relay rejects write without lease or from unleased session"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/kernel.asl" "session-node-1" "Task44604" 5000 1000 "d-kernel"))]
    (assert (is-ok? c1) "Claim must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (v-wrong (cluster/relay-verify-write reg1 "src/kernel.asl" "session-node-2" 2000))
             (v-none (cluster/relay-verify-write reg1 "src/unclaimed.asl" "session-node-1" 2000))]
         (assert (is-err? v-wrong) "Write from wrong session must be rejected")
         (mt v-wrong
           ((ok _) false)
           ((err e-wrong)
            (assert (= e-wrong "ERR_STALE_LEASE") "Rejection code must be ERR_STALE_LEASE")
            (assert (is-err? v-none) "Write to unclaimed path must be rejected")
            (mt v-none
              ((ok _) false)
              ((err e-none)
               (assert (= e-none "ERR_STALE_LEASE") "Unclaimed rejection code must be ERR_STALE_LEASE")
               true)))))))))

(df TestExpiredLeaseFailsClosed [] -> Bool
  :d "Verifies expired lease fails closed rather than being renewed implicitly"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/ephemeral.asl" "session-node-1" "Task44604" 4000 1000 "d-eph"))]
    (assert (is-ok? c1) "Initial claim must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (is-exp-before (cluster/is-relay-lease-expired? l1 3000))
             (is-exp-after (cluster/is-relay-lease-expired? l1 5000))]
         (assert (not is-exp-before) "Must not be expired before TTL")
         (assert is-exp-after "Must be expired after TTL")
         (let [(v-exp (cluster/relay-verify-write reg1 "src/ephemeral.asl" "session-node-1" 6000))]
           (assert (is-err? v-exp) "Write against expired lease must be rejected")
           (mt v-exp
             ((ok _) false)
             ((err e-exp)
              (assert (= e-exp "ERR_STALE_LEASE") "Expired write error must be ERR_STALE_LEASE")
              true))))))))

(df TestExplicitRelayRelease [] -> Bool
  :d "Verifies explicit lease release and post-release reacquisition"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/shared.asl" "session-node-1" "Task44604" 10000 1000 "d-shared"))]
    (assert (is-ok? c1) "Claim must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (rel-err (cluster/relay-release-lease reg1 "src/shared.asl" "session-node-2"))]
         (assert (is-err? rel-err) "Release by non-holder must be refused")
         (mt rel-err
           ((ok _) false)
           ((err e-rel)
            (assert (= e-rel "ERR_NOT_LEASE_HOLDER") "Error must be ERR_NOT_LEASE_HOLDER")
            (let [(rel-ok (cluster/relay-release-lease reg1 "src/shared.asl" "session-node-1"))]
              (assert (is-ok? rel-ok) "Release by holder must succeed")
              (mt rel-ok
                ((err _) false)
                ((ok reg2)
                 (let [(v-post (cluster/relay-verify-write reg2 "src/shared.asl" "session-node-1" 2000))]
                   (assert (is-err? v-post) "Write after release must fail")
                   (let [(c2 (cluster/relay-claim-lease reg2 "src/shared.asl" "session-node-2" "Task44605" 10000 3000 "d-shared-2"))]
                     (assert (is-ok? c2) "New claimant must succeed after release")
                     true))))))))))))

(df TestTaskPartitionDerivationFromOwns [] -> Bool
  :d "Verifies derivation of task partition boundaries from task owns declaration"
  (let [(p1 (cluster/derive-partition-from-task "Task44604" "sess-a" (list "agent-bus/src/cluster.asl" "agent-bus/src/gateway.asl")))
        (in-1 (cluster/is-path-in-partition? p1 "agent-bus/src/cluster.asl"))
        (in-2 (cluster/is-path-in-partition? p1 "asl/tools/asl.c"))]
    (assert (= (.-task-id p1) "Task44604") "Task id must match")
    (assert (= (.-session-id p1) "sess-a") "Session id must match")
    (assert (= (list-length (.-owns p1)) 2) "Owns count must be 2")
    (assert in-1 "cluster.asl must be in partition")
    (assert (not in-2) "asl.c must not be in partition")
    true))

(df TestDisjointPartitionsProceedWithoutContention [] -> Bool
  :d "Verifies two agents working disjoint partitions have zero conflict"
  (let [(p-alpha (cluster/derive-partition-from-task "TaskA" "sess-a" (list "src/ui.asl" "src/render.asl")))
        (p-beta (cluster/derive-partition-from-task "TaskB" "sess-b" (list "src/db.asl" "src/sql.asl")))
        (p-gamma (cluster/derive-partition-from-task "TaskC" "sess-c" (list "src/db.asl" "src/cache.asl")))
        (disjoint-ab (cluster/partitions-disjoint? p-alpha p-beta))
        (disjoint-bc (cluster/partitions-disjoint? p-beta p-gamma))
        (conflict-ab (cluster/check-partition-conflicts (.-owns p-alpha) (.-owns p-beta)))
        (conflict-bc (cluster/check-partition-conflicts (.-owns p-beta) (.-owns p-gamma)))]
    (assert disjoint-ab "Partitions with no shared paths must be disjoint")
    (assert (not disjoint-bc) "Partitions sharing src/db.asl must not be disjoint")
    (assert (not conflict-ab) "Disjoint partitions have zero conflict")
    (assert conflict-bc "Overlapping partitions flag conflict")
    true))

(df TestGatewayWritePermissionIntegration [] -> Bool
  :d "Verifies cognitive gateway ingress filter enforces relay lease"
  (let [(reg0 (cluster/create-relay-lease-registry))
        (c1 (cluster/relay-claim-lease reg0 "src/vfs.asl" "session-gw-1" "Task44604" 8000 1000 "d-vfs"))]
    (assert (is-ok? c1) "Claim must succeed")
    (mt c1
      ((err _) false)
      ((ok l1)
       (let [(reg1 (cluster/relay-registry-with-lease reg0 l1))
             (perm-ok (gateway/validate-relay-write-permission reg1 "src/vfs.asl" "session-gw-1" 2000))
             (perm-bad (gateway/validate-relay-write-permission reg1 "src/vfs.asl" "session-gw-2" 2000))]
         (assert (is-ok? perm-ok) "Valid lease must pass gateway write permission check")
         (assert (is-err? perm-bad) "Unleased session must fail gateway write permission check")
         (mt perm-bad
           ((ok _) false)
           ((err e)
            (assert (= e "ERR_STALE_LEASE") "Gateway must return ERR_STALE_LEASE")
            true)))))))

(df TestAslRpcLeaseOperations [] -> Bool
  :d "Verifies native C engine lease operations via RPC claim, leases, and release in asl.c and rpc.asn"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (rpc-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (assert (= (.-_tag rpc-res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(c-src (.-value c-res))
          (rpc-src (.-value rpc-res))]
      (assert (string-contains? c-src "op_release") "asl.c must implement op_release")
      (assert (string-contains? c-src "check_lease_staleness") "asl.c must implement check_lease_staleness")
      (assert (string-contains? c-src ":ERR_STALE_LEASE") "asl.c must report :ERR_STALE_LEASE")
      (assert (string-contains? c-src ":ERR_LEASE_CONFLICT") "asl.c must report :ERR_LEASE_CONFLICT")
      (assert (string-contains? rpc-src ":id \"asl-claim\"") "rpc.asn must declare asl-claim")
      (assert (string-contains? rpc-src ":id \"asl-leases\"") "rpc.asn must declare asl-leases")
      (assert (string-contains? rpc-src ":id \"asl-release\"") "rpc.asn must declare asl-release")
      true)))

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTask44604GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44604"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Parallel development across runtimes: partitioned ownership") "Must contain Task44604 title")
      (assert (string-contains? p-src ":lane \"parallel\"") "Must specify parallel lane")
      (assert (string-contains? p-src "agent-bus/src/cluster.asl") "Must own cluster.asl")
      (assert (string-contains? p-src "agent-bus/src/gateway.asl") "Must own gateway.asl")
      (assert (string-contains? p-src "asl/tools/asl.c") "Must own asl.c")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44604 supervisor acceptance test cases"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTask44604GroundedInPhase446) "TestTask44604GroundedInPhase446 must pass")
    (assert (TestRelayLeaseRegistryAndClaim) "TestRelayLeaseRegistryAndClaim must pass")
    (assert (TestSecondClaimantRefusalAndConflict) "TestSecondClaimantRefusalAndConflict must pass")
    (assert (TestRelayVerifyWriteCurrentLease) "TestRelayVerifyWriteCurrentLease must pass")
    (assert (TestRelayVerifyWriteUnleasedRejection) "TestRelayVerifyWriteUnleasedRejection must pass")
    (assert (TestExpiredLeaseFailsClosed) "TestExpiredLeaseFailsClosed must pass")
    (assert (TestExplicitRelayRelease) "TestExplicitRelayRelease must pass")
    (assert (TestTaskPartitionDerivationFromOwns) "TestTaskPartitionDerivationFromOwns must pass")
    (assert (TestDisjointPartitionsProceedWithoutContention) "TestDisjointPartitionsProceedWithoutContention must pass")
    (assert (TestGatewayWritePermissionIntegration) "TestGatewayWritePermissionIntegration must pass")
    (assert (TestAslRpcLeaseOperations) "TestAslRpcLeaseOperations must pass")
    true))
