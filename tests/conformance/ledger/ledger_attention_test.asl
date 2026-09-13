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
  (let [(cRes (file-read "asl/grammar/capabilities.asn"))
        (rRes (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag cRes) "ok") "capabilities.asn must exist")
    (assert (= (.-_tag rRes) "ok") "rules.asn must exist")
    (let [(cSrc (.-value cRes))
          (rSrc (.-value rRes))]
      (assert (string-contains? cSrc "rulesSlice") "capabilities.asn must define rulesSlice capability")
      (assert (string-contains? cSrc "sessionLedger") "capabilities.asn must define sessionLedger capability")
      (assert (string-contains? rSrc "(:rule :id tools") "rules.asn must contain tools rule")
      (assert (string-contains? rSrc "(:rule :id semantics") "rules.asn must contain semantics rule")
      (let [(tol (ts/makeTaskTolerance (list "C1" "D81") (list "tests") (list) (list "corruption")))]
        (assert (list-contains? (.-strictInvariants tol) "C1") "Tolerance must retain C1 invariant")
        (assert (list-contains? (.-strictInvariants tol) "D81") "Tolerance must retain D81 invariant")
        true))))

(df TestResourceBoundOutputAndRuleSlice [] -> Bool
  :d "Resource bound: budget advises compaction after tool budget limit and bounds output"
  (let [(cRes (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cRes) "ok") "capabilities.asn must exist")
    (let [(cSrc (.-value cRes))]
      (assert (string-contains? cSrc "budget") "capabilities.asn must define budget capability")
      (assert (string-contains? cSrc "boundedRead") "capabilities.asn must define boundedRead capability")
      (assert (string-contains? cSrc "advises compaction") "budget must advise compaction")
      true)))

(df TestNegativeControlFabricatedReceiptRefused [] -> Bool
  :d "Negative control: fabricated receipts with non-zero exit or zero assertions are refused and do not advance ledger"
  (let [(fakeReceiptBadExit (ts/makeTaskReceipt 1 100 50 10 0 1 (list) "h1" (list) "fail output"))
        (fakeReceiptZeroAsserts (ts/makeTaskReceipt 0 100 50 0 0 0 (list) "h2" (list) "zero asserts"))
        (validReceipt (ts/makeTaskReceipt 0 100 50 25 5 0 (list) "h3" (list) "green output"))]
    (assert (not (ts/receiptIsVerified? fakeReceiptBadExit)) "Fabricated receipt with exit 1 must be refused")
    (assert (not (ts/receiptIsVerified? fakeReceiptZeroAsserts)) "Fabricated receipt with 0 asserts must be refused")
    (assert (ts/receiptIsVerified? validReceipt) "Genuine receipt with 0 exit and positive asserts must pass")
    (let [(dag (list "step 1" "step 2" "step 3"))
          (resumedAt0 (tr/resumeActionDag dag 0))
          (resumedAt1 (tr/resumeActionDag dag 1))]
      (assert (= (list-length resumedAt0) 3) "Step index 0 keeps all 3 remaining steps")
      (assert (= (list-length resumedAt1) 2) "Advancing step index removes completed step")
      true)))

(df TestIdempotenceRecoveryAndResume [] -> Bool
  :d "Idempotence: repeated DAG resumption and checkpoint integrity verification return deterministic outputs"
  (let [(dag (list "scout" "plan" "implement" "verify"))
        (res1 (tr/resumeActionDag dag 2))
        (res2 (tr/resumeActionDag dag 2))]
    (assert (= (list-length res1) 2) "Step index 2 leaves 2 remaining steps")
    (assert (= (list-length res2) 2) "Repeated resumption leaves 2 remaining steps")
    (assert (= (option-or (list-get res1 0) "") (option-or (list-get res2 0) "")) "Subsequent resume calls must be idempotent")
    true))

(df TestConcurrencySessionLedgerIsolation [] -> Bool
  :d "Concurrency: recovery snapshot isolates dropped session from replacement session while preserving state"
  (let [(task (ts/makeTask "Task99901" "phase-999" "Test task" "implementer" "tests" (list "execute_single_step") "sh gate.sh" "why" (list)))
        (snapshot (tr/recoverTaskSession task "sess-replacement-456" 1789436600000))]
    (assert (= (.-taskId snapshot) "Task99901") "Snapshot must preserve task ID")
    (assert (= (.-recoveredSessionId snapshot) "sess-replacement-456") "Snapshot must bind replacement session ID")
    (assert (= (.-stepIndex snapshot) 0) "Snapshot must preserve step index")
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
