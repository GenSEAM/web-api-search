(module tests/acceptance/d81/Task50301
  :d "Acceptance fixture for Task50301: Pure ASL Directory Walking and Foreign File Hunter Engine."
  :x [testGate4ZeroForeignExecution
      testGatesUnitTestSuiteExecution
      testMultiFileGateDelimiters
      testRefuteNonexistentFile
      RunTests]
  :i [])

(df testGate4ZeroForeignExecution [] -> Bool
  :d "Dynamically executes Gate 4 (Zero-Foreign Policy) and verifies clean exit and structured reporting."
  (let [(res (sys-exec "bin/asl audit gates --only=4"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) (str "Gate 4 audit must exit 0, stdout: " out))
    (refute (!= code 0) "Gate 4 audit must not fail on clean monorepo")
    (assert (string-contains? out "Zero foreign files across monorepo") "Must report zero foreign files")
    (assert (string-contains? out "ALL 7 VERIFICATION GATES PASSED CLEANLY") "Must report gate pass verdict")
    (refute (string-contains? out "Foreign files detected") "Must not report any foreign file violations")
    true))

(df testGatesUnitTestSuiteExecution [] -> Bool
  :d "Dynamically executes pure ASL gates unit test suite and verifies non-vacuous assertion execution."
  (let [(res (sys-exec "bin/asl test asl/packages/asl-gates/tests/gates_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) (str "gates_test.asl must exit 0, stdout: " out))
    (refute (!= code 0) "gates_test.asl must not exit non-zero")
    (assert (string-contains? out "assertion(s) executed") "Must report executed assertions")
    (refute (string-contains? out "0 assertion(s) executed") "Must not execute zero assertions")
    true))

(df testMultiFileGateDelimiters [] -> Bool
  :d "Dynamically executes CLI gate validator on multiple source files."
  (let [(res (sys-exec "bin/asl gate asl/packages/asl-gates/src/gates.asl asl/packages/asl-gates/src/shebang_audit.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Multi-file gate delimiter check must exit 0")
    (refute (!= code 0) "Multi-file gate check must not fail")
    (assert (string-contains? out "2 file(s) verified cleanly") "Must report exactly 2 files verified")
    true))

(df testRefuteNonexistentFile [] -> Bool
  :d "Negative bound: verifies gate command fails when given a non-existent file target."
  (let [(res (sys-exec "bin/asl gate non_existent_task50301_target.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 1) "Non-existent target must exit with code 1")
    (refute (= code 0) "Non-existent target must refute exit code 0")
    (assert (string-contains? out "Target file not found") "Must report target file not found in output")
    true))

(df RunTests [] -> Bool
  :d "Master acceptance test runner for Task50301."
  (do
    (assert (testGate4ZeroForeignExecution) "testGate4ZeroForeignExecution must pass")
    (assert (testGatesUnitTestSuiteExecution) "testGatesUnitTestSuiteExecution must pass")
    (assert (testMultiFileGateDelimiters) "testMultiFileGateDelimiters must pass")
    (assert (testRefuteNonexistentFile) "testRefuteNonexistentFile must pass")
    true))

(RunTests)
