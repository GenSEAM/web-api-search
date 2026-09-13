(module tests/acceptance/d81/Task-F39
  :d "Acceptance fixture for Task-F39: Restore Invariant C5 (Zero Sigils) and Syntax Alignment under ADR-0081."
  :x [RunTests
      TestZeroPcpInAgentTriage
      TestZeroPcpInAslShProcess
      TestZeroTemplateSyntaxInDiagram
      TestTaskF39GroundedInPhaseFINSEL]
  :i [])

(df verify-no-pattern [(file-path Str) (pat Str)] -> Bool
  :d "Verifies that file-path does not contain pattern pat"
  (let [(res (file-read file-path))]
    (mt res
      ((ok content)
       (let [(has-pat (string-contains? content pat))]
         (assert (not has-pat) (str file-path " must not contain " pat))
         (not has-pat)))
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestZeroPcpInAgentTriage [] -> Bool
  :d "Verifies zero @pcp: sigils in agent/src/triage.asl"
  (verify-no-pattern "agent/src/triage.asl" "@pcp:"))

(df TestZeroPcpInAslShProcess [] -> Bool
  :d "Verifies zero @pcp: sigils in asl/packages/asl-sh/src/core/process.asl"
  (verify-no-pattern "asl/packages/asl-sh/src/core/process.asl" "@pcp:"))

(df TestZeroTemplateSyntaxInDiagram [] -> Bool
  :d "Verifies zero ${ template string interpolations in vdom/src/diagram.asl"
  (verify-no-pattern "vdom/src/diagram.asl" "${"))

(df TestTaskF39GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F39 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F39\""))
             (has-title (string-contains? content ":title \"Restore Invariant C5 (Zero Sigils) and Syntax Alignment\""))]
         (assert has-id "Task-F39 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F39 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F39"
  (let [(t1 (TestZeroPcpInAgentTriage))
        (t2 (TestZeroPcpInAslShProcess))
        (t3 (TestZeroTemplateSyntaxInDiagram))
        (t4 (TestTaskF39GroundedInPhaseFINSEL))]
    (and (and t1 t2) (and t3 t4))))
