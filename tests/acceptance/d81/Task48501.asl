(module tests/acceptance/d81/Task48501
  :d "Acceptance fixture for Task48501: Client Channel Protocol and Launch Session Schema under D84."
  :x [run-tests
      test-launch-grammar-schema-exists
      test-permission-tiers-declared
      test-client-channel-handshake-declared]
  :i [])

(df test-launch-grammar-schema-exists [] -> Bool
  :d "Verifies that asl/grammar/launch.asn exists and defines launchSession schema"
  (let [(res (file-read "asl/grammar/launch.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/launch.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "launchSession") (string-contains? src "launch_session_schema")) "launchSession schema defined")
      (assert (string-contains? src ":client") "client parameter defined")
      (assert (string-contains? src ":channel") "channel parameter defined")
      true)))

(df test-permission-tiers-declared [] -> Bool
  :d "Verifies that permission tiers including dangerous-rescue are declared"
  (let [(res (file-read "asl/grammar/launch.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/launch.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "permissionTier") (string-contains? src "permission_tier")) "permissionTier schema defined")
      (assert (string-contains? src "dangerous-rescue") "dangerous-rescue tier declared")
      (assert (string-contains? src "sandboxed-write") "sandboxed-write tier declared")
      (assert (string-contains? src "read-only") "read-only tier declared")
      true)))

(df test-client-channel-handshake-declared [] -> Bool
  :d "Verifies that clientChannel and capability contracts are declared"
  (let [(res (file-read "asl/grammar/launch.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/launch.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "clientChannel") (string-contains? src "client_channel")) "clientChannel declared")
      (assert (or (string-contains? src "launchFlags") (string-contains? src "launch_flags")) "launchFlags declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48501 acceptance assertions"
  (let [(r1 (test-launch-grammar-schema-exists))
        (r2 (test-permission-tiers-declared))
        (r3 (test-client-channel-handshake-declared))]
    (assert (and r1 (and r2 r3)) "All Task48501 checks must pass")
    true))
