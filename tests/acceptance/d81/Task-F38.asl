(module tests/acceptance/d81/Task-F38
  :d "Acceptance fixture for Task-F38: Restore Invariant C2 (Zero Emojis) Across Gate Runners and Tests under ADR-0081."
  :x [RunTests
      TestZeroUnicodeInGateRunner
      TestZeroUnicodeInRegistryTest
      TestGateRunnerSummaryAscii
      TestTaskF38GroundedInPhaseFINSEL]
  :i [(gate-runner :a gr)])

(df verify-no-unicode-mark [(file-path Str)] -> Bool
  :d "Verifies that file-path does not contain raw checkmark or cross glyphs"
  (let [(res (file-read file-path))]
    (mt res
      ((ok content)
       (let [(has-check (string-contains? content "✓"))
             (has-cross (string-contains? content "✗"))
             (clean (and (not has-check) (not has-cross)))]
         (assert clean (str file-path " must not contain Unicode checkmark or cross glyphs"))
         clean))
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestZeroUnicodeInGateRunner [] -> Bool
  :d "Verifies zero checkmark or cross glyphs in gate_runner.asl"
  (verify-no-unicode-mark "asl/packages/asl-gates/src/gate_runner.asl"))

(df TestZeroUnicodeInRegistryTest [] -> Bool
  :d "Verifies zero checkmark or cross glyphs in registry_test.asl"
  (verify-no-unicode-mark "asl/packages/asl-registry/tests/registry_test.asl"))

(df TestGateRunnerSummaryAscii [] -> Bool
  :d "Verifies that format-gate-summary outputs ASCII :ok and :fail instead of Unicode glyphs"
  (let [(s-clean (gr/run-all-gates 34 673 12 0 212 3223 29))
        (s-fail (gr/run-all-gates 0 0 0 1 0 0 0))
        (rep-clean (gr/format-gate-summary s-clean))
        (rep-fail (gr/format-gate-summary s-fail))
        (c-clean (not (string-contains? rep-clean "✓")))
        (c-fail (not (string-contains? rep-fail "✗")))
        (has-ok (string-contains? rep-clean ":ok"))
        (has-fail (string-contains? rep-fail ":fail"))]
    (assert c-clean "format-gate-summary clean report must not contain Unicode checkmark")
    (assert c-fail "format-gate-summary failed report must not contain Unicode cross")
    (assert has-ok "format-gate-summary clean report must contain :ok")
    (assert has-fail "format-gate-summary failed report must contain :fail")
    (and (and c-clean c-fail) (and has-ok has-fail))))

(df TestTaskF38GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F38 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F38\""))
             (has-title (string-contains? content ":title \"Restore Invariant C2 (Zero Emojis) Across Gate Runners and Tests\""))]
         (assert has-id "Task-F38 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F38 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F38"
  (let [(t1 (TestZeroUnicodeInGateRunner))
        (t2 (TestZeroUnicodeInRegistryTest))
        (t3 (TestGateRunnerSummaryAscii))
        (t4 (TestTaskF38GroundedInPhaseFINSEL))]
    (and (and t1 t2) (and t3 t4))))
