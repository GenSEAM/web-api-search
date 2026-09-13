(module tests/acceptance/d81/Task-F25
  :d "Acceptance fixture for Task-F25: Eliminate Phantom Dirty Overwrites in Software Transactional Memory under ADR-0081."
  :x [RunTests
      TestUnreadWriteDoesNotSetBaseHashZero
      TestUnreadWriteExistingFileResolvesDiskBase
      TestUnreadWriteDetectsTrunkCollisionOnCommit
      TestTaskF25GroundedInPhaseFINSEL]
  :i [(asl-mem/stm :a s)
      (asl-mem/vfs :a v)])

(df TestUnreadWriteDoesNotSetBaseHashZero [] -> Bool
  :d "Verifies stm-write on unread file does not set base-hash to phantom literal 0"
  (let [(tx0 (s/stm-begin "tx-f25-1" "test-agent" 1))
        (tx1 (s/stm-write tx0 "non_existent_file.asl" "(df f [] -> I64 42)"))
        (snap-opt (s/stm-get-snapshot tx1 "non_existent_file.asl"))]
    (mt snap-opt
      ((none) (assert false "Snapshot must exist after stm-write") false)
      ((some snap)
       (let [(b-hash (.-base-hash snap))]
         (assert (not (= b-hash "0")) "Base hash must not be phantom zero")
         (assert (> (string-length b-hash) 1) "Base hash must be valid CAS digest")
         (assert (= b-hash (v/vfs-cas-hash "")) "New file base-hash must equal CAS hash of empty string")
         true)))))

(df TestUnreadWriteExistingFileResolvesDiskBase [] -> Bool
  :d "Verifies stm-write on existing file resolves true disk base content and CAS hash"
  (let [(target "mem/src/stm.asl")
        (tx0 (s/stm-begin "tx-f25-2" "test-agent" 2))
        (tx1 (s/stm-write tx0 target "(module mutated :x [])"))
        (snap-opt (s/stm-get-snapshot tx1 target))]
    (mt snap-opt
      ((none) (assert false "Snapshot must exist") false)
      ((some snap)
       (let [(base-txt (.-base-content snap))
             (base-h (.-base-hash snap))]
         (assert (not (string-empty? base-txt)) "Base content must be populated from disk")
         (assert (string-contains? base-txt "asl-mem/stm") "Base content must match disk content")
         (assert (= base-h (v/vfs-cas-hash base-txt)) "Base hash must match CAS hash of disk content")
         true)))))

(df TestUnreadWriteDetectsTrunkCollisionOnCommit [] -> Bool
  :d "Verifies unread write with conflicting trunk changes aborts rather than silently overwriting"
  (let [(path "lib.asl")
        (base-code "(df foo [] -> I64 1)")
        (agent-code "(df foo [] -> I64 999)")
        (trunk-code "(df foo [] -> I64 888)")
        (tx0 (s/stm-begin "tx-f25-3" "test-agent" 3))
        (tx1 (s/stm-read tx0 path base-code))
        (tx2 (s/stm-write tx1 path agent-code))
        (trunk-paths (list path))
        (trunk-contents (list (str path ":" trunk-code)))
        (res (s/stm-validate-and-merge tx2 trunk-paths trunk-contents))]
    (assert (not (.-committed res)) "Transaction must abort on AST collision")
    (assert (= (list-length (.-conflicted-files res)) 1) "Conflicted files must have length 1")
    (assert (list-contains? (.-conflicted-files res) path) "Conflicted files must include lib.asl")
    true))

(df TestTaskF25GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F25 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F25\""))
             (has-title (string-contains? content ":title \"Eliminate Phantom Dirty Overwrites in Software Transactional Memory\""))]
         (assert has-id "Task-F25 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F25 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F25"
  (let [(t1 (TestUnreadWriteDoesNotSetBaseHashZero))
        (t2 (TestUnreadWriteExistingFileResolvesDiskBase))
        (t3 (TestUnreadWriteDetectsTrunkCollisionOnCommit))
        (t4 (TestTaskF25GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 t4)))))
