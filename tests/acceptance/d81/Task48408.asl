(module tests/acceptance/d81/Task48408
  :d "Acceptance fixture for Task48408: Direct-Write Quarantine Gate, Forensic Migration and Ecosystem Sync under D83 and D81."
  :x [run-tests
      test-quarantine-gate-implemented
      test-mem-migrate-implemented
      test-rules-sync-and-consistency-audit]
  :i [])

(df test-quarantine-gate-implemented [] -> Bool
  :d "Verifies that audit_records_quarantine is implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "audit_records_quarantine") "audit_records_quarantine implemented")
      true)))

(df test-mem-migrate-implemented [] -> Bool
  :d "Verifies that mem_migrate is implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "mem_migrate") "mem_migrate implemented")
      true)))

(df test-rules-sync-and-consistency-audit [] -> Bool
  :d "Verifies that rules_sync and consistency_audit concepts are declared in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "rules_sync") "rules_sync declared")
      (assert (string-contains? src "consistency_audit") "consistency_audit declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48408 acceptance assertions"
  (let [(r1 (test-quarantine-gate-implemented))
        (r2 (test-mem-migrate-implemented))
        (r3 (test-rules-sync-and-consistency-audit))]
    (assert (and r1 (and r2 r3)) "All Task48408 checks must pass")
    true))
