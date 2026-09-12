(module tests/acceptance/d81/Task46901
  :d "Acceptance fixture for Task46901: published path claims and advisory lease visibility."
  :x [RunTests
      TestPresenceClaimContractsDeclared
      TestClaimOperationsDefined
      TestRosterFormatsClaims]
  :i [(agent-bus/presence :a presence)])

(df TestPresenceClaimContractsDeclared [] -> Bool
  :d "Verifies that agent-bus/src/presence.asl declares path claim structures and updates SwarmPeer"
  (let [(res (file-read "agent-bus/src/presence.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/presence.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "PathClaim") (string-contains? src "ClaimRecord"))
              "presence.asl must declare PathClaim structure")
      (assert (or (string-contains? src "ClaimMode") (string-contains? src "claim-mode"))
              "presence.asl must declare ClaimMode enum")
      (assert (or (string-contains? src "claims") (string-contains? src "held-claims"))
              "presence.asl SwarmPeer must declare claims field")
      (let [(p0 (presence/SwarmPeer :agent-id "a1" :role "tester" :room "r1" :status (presence/status-idle) :capabilities (list) :last-ping-epoch 100 :claims (list)))]
        (assert (= (.-agent-id p0) "a1") "SwarmPeer agent-id must match")
        (assert (= (list-length (.-claims p0)) 0) "SwarmPeer initial claims must be empty")
        true))))

(df TestClaimOperationsDefined [] -> Bool
  :d "Verifies functional claim acquisition, lease expiration check, and release"
  (let [(p0 (presence/SwarmPeer :agent-id "worker-1" :role "coder" :room "swarm-room" :status (presence/status-idle) :capabilities (list) :last-ping-epoch 1000 :claims (list)))
        (p1 (presence/claim-path p0 "asl/tools/asl.c" (presence/claim-write) 1000 60))
        (p2 (presence/claim-path p1 "mem/src/vfs.asl" (presence/claim-read) 1000 60))
        (c1 (first (.-claims p1)))
        (p3 (presence/release-claim p2 "asl/tools/asl.c"))]
    (assert (= (list-length (.-claims p1)) 1) "p1 must hold exactly 1 claim")
    (assert (= (list-length (.-claims p2)) 2) "p2 must hold exactly 2 claims")
    (assert (= (.-path c1) "asl/tools/asl.c") "claim path must match")
    (assert (= (.-holder c1) "worker-1") "claim holder must match")
    (assert (not (presence/is-claim-expired? c1 1030)) "claim must not be expired within ttl")
    (assert (presence/is-claim-expired? c1 1070) "claim must be expired after ttl")
    (assert (= (list-length (.-claims p3)) 1) "p3 must hold 1 claim after releasing asl.c")
    (assert (= (.-path (first (.-claims p3))) "mem/src/vfs.asl") "remaining claim must be vfs.asl")
    true))

(df TestRosterFormatsClaims [] -> Bool
  :d "Verifies that format-presence-roster renders claimed paths alongside agent status"
  (let [(p0 (presence/SwarmPeer :agent-id "worker-1" :role "coder" :room "swarm" :status (presence/status-idle) :capabilities (list) :last-ping-epoch 1000 :claims (list)))
        (p1 (presence/claim-path p0 "asl/tools/asl.c" (presence/claim-write) 1000 60))
        (r0 (presence/create-swarm-room "swarm" "Swarm Testing"))
        (r1 (presence/join-swarm-room r0 p1))
        (roster (presence/format-presence-roster r1))]
    (assert (string-contains? roster "worker-1") "roster must contain peer agent id")
    (assert (string-contains? roster "asl/tools/asl.c") "roster must render claimed path")
    (assert (string-contains? roster "coder") "roster must include peer role")
    true))

(df RunTests [] -> Bool
  (and (TestPresenceClaimContractsDeclared)
       (TestClaimOperationsDefined)
       (TestRosterFormatsClaims)))
