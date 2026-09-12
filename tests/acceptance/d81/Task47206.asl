(module tests/acceptance/d81/Task47206
  :d "Acceptance fixture for Task47206: verified residue of whole repository audit under ADR-0081."
  :x [RunTests
      TestAuditFindingsDisposition
      TestCliCommandsCoverageAndSkill]
  :i [])

(df TestAuditFindingsDisposition [] -> Bool
  :d "Verifies that D83WholeRepositoryAudit20260912 exists and contains 8 findings"
  (let [(audit-res (file-read ".asl/mem/reviews/D83WholeRepositoryAudit20260912.asn"))]
    (assert (= (.-_tag audit-res) "ok") "D83WholeRepositoryAudit20260912.asn must exist and be readable")
    (let [(content (.-value audit-res))]
      (assert (string-contains? content "D83-F01") "Finding D83-F01 must exist")
      (assert (string-contains? content "D83-F07") "Finding D83-F07 must exist")
      (assert (string-contains? content "D83-F08") "Finding D83-F08 must exist")
      true)))

(df TestCliCommandsCoverageAndSkill [] -> Bool
  :d "Verifies that asl CLI supports coverage and skill subcommands"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "Subsystem Coverage Audit") "asl.c must contain coverage subcommand")
      (assert (string-contains? c-src "Skills Management") "asl.c must contain skill subcommand")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47206 supervisor acceptance tests"
  (do
    (assert (TestAuditFindingsDisposition) "TestAuditFindingsDisposition must pass")
    (assert (TestCliCommandsCoverageAndSkill) "TestCliCommandsCoverageAndSkill must pass")
    true))
