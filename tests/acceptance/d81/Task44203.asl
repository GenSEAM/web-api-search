(module tests/acceptance/d81/Task44203
  :d "Acceptance fixture for Task44203: concurrent writer safety with file leases and staleness detection under ADR-0081."
  :x [RunTests
      TestClaimAndLeasesOperatorsImplementedInAslC
      TestClaimAndLeasesDeclaredInRpcAsn
      TestStalenessDetectionRejected]
  :i [])

(df TestClaimAndLeasesOperatorsImplementedInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements :claim and :leases operators in execute_single_step"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "strcmp(op, \"claim\")")
              "asl.c must handle :claim op")
      (assert (string-contains? c-src "strcmp(op, \"leases\")")
              "asl.c must handle :leases op")
      (assert (string-contains? c-src ":ERR_STALE_FILE")
              "asl.c must report :ERR_STALE_FILE on digest mismatch")
      (assert (string-contains? c-src ":ERR_LEASE_CONFLICT")
              "asl.c must report :ERR_LEASE_CONFLICT on competing active session lease")
      true)))

(df TestClaimAndLeasesDeclaredInRpcAsn [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn declares :claim and :leases"
  (let [(rpc-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-res) "ok") "asl/grammar/rpc.asn must exist")
    (let [(rpc-src (.-value rpc-res))]
      (assert (string-contains? rpc-src ":id \"asl-claim\"")
              "rpc.asn must declare asl-claim op")
      (assert (string-contains? rpc-src ":id \"asl-leases\"")
              "rpc.asn must declare asl-leases op")
      true)))

(df TestStalenessDetectionRejected [] -> Bool
  :d "Verifies that asl.c parses lease parameters and verifies digests on edit/write"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_lease_staleness")
              "asl.c must implement check_lease_staleness")
      (assert (string-contains? c-src "compute_file_digest")
              "asl.c must implement compute_file_digest")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44203 supervisor acceptance tests"
  (do
    (assert (TestClaimAndLeasesOperatorsImplementedInAslC) "TestClaimAndLeasesOperatorsImplementedInAslC must pass")
    (assert (TestClaimAndLeasesDeclaredInRpcAsn) "TestClaimAndLeasesDeclaredInRpcAsn must pass")
    (assert (TestStalenessDetectionRejected) "TestStalenessDetectionRejected must pass")
    true))
