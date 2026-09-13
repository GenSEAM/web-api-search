(module tests/acceptance/d81/Task-F04
  :d "Acceptance fixture for Task-F04: Defend C Host Buffer Overruns and Command Injections under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestEscapeShellArgDefined
      TestZeroUnsafeStrcpyCalls
      TestTaskF04GroundedInPhaseFINSEL]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestEscapeShellArgDefined [] -> Bool
  :d "Verifies that asl/tools/asl.c defines escape_sh_arg for safe popen execution"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "escape_sh_arg(") "asl.c must define escape_sh_arg function")
      (assert (string-contains? c-src "safe_ws") "asl.c popen calls must use escaped workspace path")
      true)))

(df TestZeroUnsafeStrcpyCalls [] -> Bool
  :d "Verifies that asl/tools/asl.c has replaced all unbounded strcpy calls with bounded snprintf"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (not (string-contains? c-src "strcpy(")) "asl.c must not contain unbounded strcpy calls")
      true)))

(df TestTaskF04GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F04 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F04\"") "Must declare Task-F04")
      (assert (string-contains? f-src "asl/tools/asl.c") "Must own asl/tools/asl.c")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F04 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestEscapeShellArgDefined) "TestEscapeShellArgDefined must pass")
    (assert (TestZeroUnsafeStrcpyCalls) "TestZeroUnsafeStrcpyCalls must pass")
    (assert (TestTaskF04GroundedInPhaseFINSEL) "TestTaskF04GroundedInPhaseFINSEL must pass")
    true))
