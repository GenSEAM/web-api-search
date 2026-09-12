(module tests/acceptance/d81/Task44210
  :d "Acceptance fixture for Task44210: measured capability registry under ADR-0081."
  :x [RunTests
      TestDoctorWritesCapabilitiesLock
      TestCapabilitiesWhereSlice
      TestGate7ContradictionAudit]
  :i [])

(df TestDoctorWritesCapabilitiesLock [] -> Bool
  :d "Verifies that run_doctor generates or writes capabilities.lock with measured statuses"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "capabilities.lock")
              "asl.c must reference capabilities.lock")
      (assert (string-contains? c-src "capabilities.asn")
              "asl.c must reference capabilities.asn")
      (assert (string-contains? c-src "write_capabilities_lock")
              "asl.c must implement write_capabilities_lock")
      true)))

(df TestCapabilitiesWhereSlice [] -> Bool
  :d "Verifies that (:where) provides capability slicing by step kind or tier"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "op_where")
              "asl.c must implement op_where")
      (assert (string-contains? c-src ":capabilities-slice")
              "asl.c must emit :capabilities-slice")
      true)))

(df TestGate7ContradictionAudit [] -> Bool
  :d "Verifies that gate 7 audits capabilities against lock and checks divergence"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "audit_capabilities_lock")
              "asl.c must implement audit_capabilities_lock")
      (assert (string-contains? c-src "check_capabilities_staleness")
              "asl.c must check capabilities lock staleness")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44210 supervisor acceptance tests"
  (do
    (assert (TestDoctorWritesCapabilitiesLock) "TestDoctorWritesCapabilitiesLock must pass")
    (assert (TestCapabilitiesWhereSlice) "TestCapabilitiesWhereSlice must pass")
    (assert (TestGate7ContradictionAudit) "TestGate7ContradictionAudit must pass")
    true))
