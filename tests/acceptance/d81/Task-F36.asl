(module tests/acceptance/d81/Task-F36
  :d "Acceptance fixture for Task-F36: Resolve Tautological Tests in Memory and Acceptance Suites under ADR-0081."
  :x [RunTests
      TestTask45404ZeroTautologicalAsserts
      TestMemTestGenuineDriverTested
      TestTaskF36GroundedInPhaseFINSEL]
  :i [("../../../mem/tests/mem_test" :a mt)])

(df TestTask45404ZeroTautologicalAsserts [] -> Bool
  :d "Verifies Task45404 contains no tautological (= 1 1) or (= 1 2) asserts"
  (let [(res (file-read "tests/acceptance/d81/Task45404.asl"))]
    (mt res
      ((ok content)
       (let [(has-11 (string-contains? content "(= 1 1)"))
             (has-12 (string-contains? content "(= 1 2)"))]
         (assert (not has-11) "Task45404 must not contain tautological (= 1 1)")
         (assert (not has-12) "Task45404 must not contain tautological (= 1 2)")
         (and (not has-11) (not has-12))))
      ((err _)
       (assert false "Task45404.asl must be readable")
       false))))

(df TestMemTestGenuineDriverTested [] -> Bool
  :d "Verifies mem_test exercises genuine driver methods rather than only math helpers"
  (let [(res (file-read "mem/tests/mem_test.asl"))]
    (mt res
      ((ok content)
       (let [(has-create (string-contains? content "(d/create-record"))
             (has-fuse (string-contains? content "(d/fuse-ranks-rrf"))]
         (assert has-create "mem_test must invoke d/create-record")
         (assert has-fuse "mem_test must invoke d/fuse-ranks-rrf")
         (and has-create has-fuse)))
      ((err _)
       (assert false "mem_test.asl must be readable")
       false))))

(df TestTaskF36GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F36 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F36\""))
             (has-title (string-contains? content ":title \"Resolve Tautological Tests in Memory and Acceptance Suites\""))]
         (assert has-id "Task-F36 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F36 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F36"
  (let [(t1 (TestTask45404ZeroTautologicalAsserts))
        (t2 (TestMemTestGenuineDriverTested))
        (t3 (TestTaskF36GroundedInPhaseFINSEL))
        (t4 (mt/run-tests))]
    (assert t4 "mem_test suite must pass cleanly")
    (and (and t1 t2) (and t3 t4))))
