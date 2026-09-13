(module tests/acceptance/d81/Task50302
  :d "Acceptance fixture for Task50302: Honest Monorepo Filesystem Scanner and Dynamic Gate Runner."
  :x [testDynamicMultiGateAuditExecution
      testSelectiveFilterAuditExecution
      testSiteClaimsGroundingExecution
      testRefuteMalformedInvocation
      RunTests]
  :i [])

(df testDynamicMultiGateAuditExecution [] -> Bool
  :d "Dynamically executes continuous verification gates 1-4 and verifies filesystem-driven reporting."
  (let [(res (sys-exec "bin/asl audit gates --only=1,2,3,4"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) (str "audit gates --only=1,2,3,4 must exit 0, stdout: " out))
    (refute (!= code 0) "Dynamic gate runner must exit 0 on clean repository")
    (assert (string-contains? out "Verified 40 package manifests cleanly") "Gate 1 must verify 40 manifests on disk")
    (refute (string-contains? out "Verified 5 package manifests") "Gate 1 must refute legacy hardcoded 5 manifests")
    (assert (string-contains? out "ASL source files are well-formed") "Gate 2 must verify all ASL source files on disk")
    (refute (string-contains? out "across 4 ") "Gate 2 must refute legacy hardcoded 4 source files")
    (assert (string-contains? out "Grounded 12 benchmark claims across published registry") "Gate 3 must ground 12 benchmark claims")
    (assert (string-contains? out "Zero foreign files across monorepo") "Gate 4 must enforce zero foreign files")
    (assert (string-contains? out "ALL 7 VERIFICATION GATES PASSED CLEANLY") "Report must show passing verdict")
    true))

(df testSelectiveFilterAuditExecution [] -> Bool
  :d "Verifies that selective filtering executes designated gates and cleanly skips excluded ones."
  (let [(res (sys-exec "bin/asl audit gates --only=1"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Selective filter gate 1 must exit 0")
    (refute (!= code 0) "Selective filter gate 1 must not fail")
    (assert (string-contains? out "only=[1]") "Config header must show selective filter only=[1]")
    (assert (string-contains? out "Verified 40 package manifests cleanly") "Gate 1 must execute")
    (assert (string-contains? out "[Gate 2] Skipped by selective filter") "Gate 2 must be skipped")
    (assert (string-contains? out "[Gate 3] Skipped by selective filter") "Gate 3 must be skipped")
    (assert (string-contains? out "[Gate 4] Skipped by selective filter") "Gate 4 must be skipped")
    true))

(df testSiteClaimsGroundingExecution [] -> Bool
  :d "Dynamically executes Gate 3 independently to verify grounding against benchmark registry."
  (let [(res (sys-exec "bin/asl audit gates --only=3"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Site claims grounding gate must exit 0")
    (refute (!= code 0) "Site claims grounding must not fail")
    (assert (string-contains? out "Grounded 12 benchmark claims across published registry") "Claims must be grounded")
    (refute (string-contains? out "Grounded claims audit failed") "Must not report claims audit failure")
    true))

(df testRefuteMalformedInvocation [] -> Bool
  :d "Negative bound: verifies that an invalid audit subcommand exits non-zero with usage guidance."
  (let [(res (sys-exec "bin/asl audit unknown_subcommand_task50302"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 1) "Invalid audit subcommand must exit 1")
    (refute (= code 0) "Invalid audit subcommand must refute exit code 0")
    (assert (string-contains? out "Usage: asl audit") "Must display valid usage syntax")
    true))

(df RunTests [] -> Bool
  :d "Master acceptance test runner for Task50302."
  (do
    (assert (testDynamicMultiGateAuditExecution) "testDynamicMultiGateAuditExecution must pass")
    (assert (testSelectiveFilterAuditExecution) "testSelectiveFilterAuditExecution must pass")
    (assert (testSiteClaimsGroundingExecution) "testSiteClaimsGroundingExecution must pass")
    (assert (testRefuteMalformedInvocation) "testRefuteMalformedInvocation must pass")
    true))

(RunTests)
