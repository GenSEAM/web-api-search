(module tests/acceptance/d81/Task-F34
  :d "Acceptance fixture for Task-F34: Remove Redundant Shadow Files and Naming Collisions under ADR-0081."
  :x [RunTests
      TestShadowFilesDeleted
      TestCanonicalFilesExist
      TestGatesManifestClean
      TestTaskF34GroundedInPhaseFINSEL]
  :i [])

(df verify-file-missing [(file-path String)] -> Bool
  :d "Verifies that a redundant shadow file does not exist on disk"
  (let [(res (file-read file-path))]
    (mt res
      ((ok _)
       (assert false (str file-path " must be deleted"))
       false)
      ((err _)
       (assert true (str file-path " is cleanly absent"))
       true))))

(df verify-file-exists [(file-path String)] -> Bool
  :d "Verifies that a canonical file exists on disk and is readable"
  (let [(res (file-read file-path))]
    (mt res
      ((ok _)
       (assert true (str file-path " exists cleanly"))
       true)
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestShadowFilesDeleted [] -> Bool
  :d "Verifies that all redundant shadow files have been removed from disk"
  (let [(f1 (verify-file-missing "asl/packages/asl-gates/src/runner.asl"))
        (f2 (verify-file-missing "agent/tests/agent_test.asl"))
        (f3 (verify-file-missing "asl/packages/asl-bridge/src/schema_bridge.asl"))]
    (and (and f1 f2) f3)))

(df TestCanonicalFilesExist [] -> Bool
  :d "Verifies that canonical counterparts exist on disk"
  (let [(f1 (verify-file-exists "asl/packages/asl-gates/src/gate_runner.asl"))
        (f2 (verify-file-exists "agent/tests/agent-test.asl"))
        (f3 (verify-file-exists "asl/packages/asl-bridge/src/schema-bridge.asl"))]
    (and (and f1 f2) f3)))

(df TestGatesManifestClean [] -> Bool
  :d "Verifies that asl-gates manifest references gate-runner and not runner"
  (let [(res (file-read "asl/packages/asl-gates/manifest.asn"))]
    (mt res
      ((ok content)
       (let [(has-canonical (string-contains? content "\"asl-gates/gate-runner\""))
             (has-shadow (string-contains? content "\"asl-gates/runner\""))]
         (assert has-canonical "asl-gates manifest must include canonical gate-runner")
         (assert (not has-shadow) "asl-gates manifest must not include shadow runner")
         (and has-canonical (not has-shadow))))
      ((err _)
       (assert false "asl-gates manifest must be readable")
       false))))

(df TestTaskF34GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F34 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F34\""))
             (has-title (string-contains? content ":title \"Remove Redundant Shadow Files and Naming Collisions\""))]
         (assert has-id "Task-F34 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F34 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F34"
  (let [(t1 (TestShadowFilesDeleted))
        (t2 (TestCanonicalFilesExist))
        (t3 (TestGatesManifestClean))
        (t4 (TestTaskF34GroundedInPhaseFINSEL))]
    (and (and (and t1 t2) t3) t4)))
