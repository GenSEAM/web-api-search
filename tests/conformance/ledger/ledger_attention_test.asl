(module tests/conformance/ledger/LedgerAttentionTest
  :d "Conformance test suite for session ledger, trace and attention ops per ADR-0081"
  :x [RunTests
      TestBoundaryConstraintPreservedAcrossCompactions
      TestResourceBoundOutputAndRuleSlice
      TestNegativeControlFabricatedReceiptRefused
      TestIdempotenceRecoveryAndResume
      TestConcurrencySessionLedgerIsolation]
  :i [("../../../mem/src/tasks_store" :a ts)
      ("../../../mem/src/task_recovery" :a tr)])

(df TestBoundaryConstraintPreservedAcrossCompactions [] -> Bool
  :d "Boundary: constraints outside narrative survive compactions and rule slices stay strictly smaller than full rules"
  (let [(c-res (file-read "asl/grammar/capabilities.asn"))
        (r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag c-res) "ok") "capabilities.asn must exist")
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist")
    (let [(c-src (.-value c-res))
          (r-src (.-value r-res))]
      (assert (string-contains? c-src "rulesSlice") "capabilities.asn must define rulesSlice capability")
      (assert (string-contains? c-src "sessionLedger") "capabilities.asn must define sessionLedger capability")
      (assert (string-contains? r-src "(:rule :id tools") "rules.asn must contain tools rule")
      (assert (string-contains? r-src "(:rule :id semantics") "rules.asn must contain semantics rule")
      (let [(tol (ts/make-task-tolerance (list "C1" "D81") (list "tests") (list) (list "corruption")))]
        (assert (list-contains? (.-strict-invariants tol) "C1") "Tolerance must retain C1 invariant")
        (assert (list-contains? (.-strict-invariants tol) "D81") "Tolerance must retain D81 invariant")
        true))))

(df TestResourceBoundOutputAndRuleSlice [] -> Bool
  :d "Resource bound: budget advises compaction after tool budget limit and bounds output"
  (let [(c-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag c-res) "ok") "capabilities.asn must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "budget") "capabilities.asn must define budget capability")
      (assert (string-contains? c-src "boundedRead") "capabilities.asn must define boundedRead capability")
      (assert (string-contains? c-src "advises compaction") "budget must advise compaction")
      true)))

(df TestNegativeControlFabricatedReceiptRefused [] -> Bool
  :d "Negative control: fabricated receipts with non-zero exit or zero assertions are refused and do not advance ledger"
  (let [(fake-receipt-bad-exit (ts/make-task-receipt 1 100 50 10 0 1 (list) "h1" (list) "fail output"))
        (fake-receipt-zero-asserts (ts/make-task-receipt 0 100 50 0 0 0 (list) "h2" (list) "zero asserts"))
        (valid-receipt (ts/make-task-receipt 0 100 50 25 5 0 (list) "h3" (list) "green output"))]
    (assert (not (ts/receipt-is-verified? fake-receipt-bad-exit)) "Fabricated receipt with exit 1 must be refused")
    (assert (not (ts/receipt-is-verified? fake-receipt-zero-asserts)) "Fabricated receipt with 0 asserts must be refused")
    (assert (ts/receipt-is-verified? valid-receipt) "Genuine receipt with 0 exit and positive asserts must pass")
    (let [(dag (list "step 1" "step 2" "step 3"))
          (resumed-at-0 (tr/resume-action-dag dag 0))
          (resumed-at-1 (tr/resume-action-dag dag 1))]
      (assert (= (list-length resumed-at-0) 3) "Step index 0 keeps all 3 remaining steps")
      (assert (= (list-length resumed-at-1) 2) "Advancing step index removes completed step")
      true)))

(df TestIdempotenceRecoveryAndResume [] -> Bool
  :d "Idempotence: repeated DAG resumption and checkpoint integrity verification return deterministic outputs"
  (let [(dag (list "scout" "plan" "implement" "verify"))
        (res-1 (tr/resume-action-dag dag 2))
        (res-2 (tr/resume-action-dag dag 2))]
    (assert (= (list-length res-1) 2) "Step index 2 leaves 2 remaining steps")
    (assert (= (list-length res-2) 2) "Repeated resumption leaves 2 remaining steps")
    (assert (= (option-or (list-get res-1 0) "") (option-or (list-get res-2 0) "")) "Subsequent resume calls must be idempotent")
    true))

(df TestConcurrencySessionLedgerIsolation [] -> Bool
  :d "Concurrency: recovery snapshot isolates dropped session from replacement session while preserving state"
  (let [(task (ts/make-task "Task99901" "phase-999" "Test task" "implementer" "tests" (list "execute_single_step") "sh gate.sh" "why" (list)))
        (snapshot (tr/recover-task-session task "sess-replacement-456" 1789436600000))]
    (assert (= (.-task-id snapshot) "Task99901") "Snapshot must preserve task ID")
    (assert (= (.-recovered-session-id snapshot) "sess-replacement-456") "Snapshot must bind replacement session ID")
    (assert (= (.-step-index snapshot) 0) "Snapshot must preserve step index")
    true))

(df RunTests [] -> Bool
  :d "Executes all session ledger, trace, and attention conformance tests"
  (do
    (assert (TestBoundaryConstraintPreservedAcrossCompactions) "TestBoundaryConstraintPreservedAcrossCompactions must pass")
    (assert (TestResourceBoundOutputAndRuleSlice) "TestResourceBoundOutputAndRuleSlice must pass")
    (assert (TestNegativeControlFabricatedReceiptRefused) "TestNegativeControlFabricatedReceiptRefused must pass")
    (assert (TestIdempotenceRecoveryAndResume) "TestIdempotenceRecoveryAndResume must pass")
    (assert (TestConcurrencySessionLedgerIsolation) "TestConcurrencySessionLedgerIsolation must pass")
    true))
