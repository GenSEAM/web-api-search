(module tests/acceptance/d81/Task-F37
  :d "Acceptance fixture for Task-F37: Restore Invariant C1 (Zero Comments) Across Monorepo under ADR-0081."
  :x [RunTests
      TestZeroCommentsInAslGrammar
      TestZeroCommentsInHarnessAsn
      TestZeroCommentsInMemGrammar
      TestZeroForeignTsComments
      TestTaskF37GroundedInPhaseFINSEL]
  :i [])

(df verify-no-comment [(file-path String) (token String)] -> Bool
  :d "Verifies that file-path does not contain the specified comment token"
  (let [(res (file-read file-path))]
    (mt res
      ((ok content)
       (let [(has-tok (string-contains? content token))]
         (assert (not has-tok) (str file-path " must not contain comment token " token))
         (not has-tok)))
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestZeroCommentsInAslGrammar [] -> Bool
  :d "Verifies zero ;; comments in asl/grammar/*.asn files"
  (let [(f1 (verify-no-comment "asl/grammar/cases.asn" ";;"))
        (f2 (verify-no-comment "asl/grammar/grammar.asn" ";;"))
        (f3 (verify-no-comment "asl/grammar/rpc.asn" ";;"))]
    (and (and f1 f2) f3)))

(df TestZeroCommentsInHarnessAsn [] -> Bool
  :d "Verifies zero ;; comments in harness/*.asn files"
  (let [(f1 (verify-no-comment "harness/grammar.asn" ";;"))
        (f2 (verify-no-comment "harness/audit-playbook.asn" ";;"))
        (f3 (verify-no-comment "harness/audit-protocols.asn" ";;"))]
    (and (and f1 f2) f3)))

(df TestZeroCommentsInMemGrammar [] -> Bool
  :d "Verifies zero ;; comments in mem/grammar.asn"
  (verify-no-comment "mem/grammar.asn" ";;"))

(df TestZeroForeignTsComments [] -> Bool
  :d "Verifies zero // @ts comments in asl-codegen"
  (verify-no-comment "asl/packages/asl-codegen/src/emit_jsx.asl" "// @ts"))

(df TestTaskF37GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F37 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F37\""))
             (has-title (string-contains? content ":title \"Restore Invariant C1 (Zero Comments) Across Monorepo\""))]
         (assert has-id "Task-F37 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F37 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F37"
  (let [(t1 (TestZeroCommentsInAslGrammar))
        (t2 (TestZeroCommentsInHarnessAsn))
        (t3 (TestZeroCommentsInMemGrammar))
        (t4 (TestZeroForeignTsComments))
        (t5 (TestTaskF37GroundedInPhaseFINSEL))]
    (and (and (and t1 t2) (and t3 t4)) t5)))
