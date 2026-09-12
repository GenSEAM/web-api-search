(module tests/acceptance/d81/Task47404
  :d "Acceptance fixture for Task47404: Gate 7 currency checking and tree parity audit."
  :x [RunTests
      TestGate7CurrencyCheckInAslC
      TestGate7AuditsBothTrees
      TestGate7ReportsCheckedAgainstExisting]
  :i [])

(df TestGate7CurrencyCheckInAslC [] -> Bool
  :d "Verifies that asl.c implements projection currency verification in run_gate_7_skills"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_gate_7_skills")
              "asl.c must implement run_gate_7_skills")
      (assert (string-contains? c-src "verify_skill_projection_currency")
              "asl.c must implement verify_skill_projection_currency")
      true)))

(df TestGate7AuditsBothTrees [] -> Bool
  :d "Verifies that run_gate_7_skills checks both .agents/skills and asl/.agents/skills"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "asl/.agents/skills")
              "asl.c must reference asl/.agents/skills")
      (assert (string-contains? c-src ".agents/skills")
              "asl.c must reference .agents/skills")
      (assert (string-contains? c-src "Skill tree mismatch")
              "asl.c must detect and report skill tree mismatch")
      true)))

(df TestGate7ReportsCheckedAgainstExisting [] -> Bool
  :d "Verifies that Gate 7 reports checked count against existing count"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "Audited %d/%d modular skills")
              "Gate 7 must report audited checked count against existing count (%d/%d)")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47404 supervisor acceptance tests"
  (do
    (assert (TestGate7CurrencyCheckInAslC) "TestGate7CurrencyCheckInAslC must pass")
    (assert (TestGate7AuditsBothTrees) "TestGate7AuditsBothTrees must pass")
    (assert (TestGate7ReportsCheckedAgainstExisting) "TestGate7ReportsCheckedAgainstExisting must pass")
    true))
