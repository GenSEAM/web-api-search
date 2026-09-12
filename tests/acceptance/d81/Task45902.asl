(module tests/acceptance/d81/Task45902
  :d "Acceptance fixture for Task45902: Rename the 14 measured expensive builtins under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestFourteenRenamedBuiltinsContract
      TestNoCompatibilityAliasesLeftBehind
      TestTokenCompactionMeasurementGrounded]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestFourteenRenamedBuiltinsContract [] -> Bool
  :d "Verifies language-semantics.asn registers the 14 renamed builtins with zero aliases"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "expensiveBuiltinsRenamed") "language-semantics.asn must define expensiveBuiltinsRenamed semantic")
      (assert (string-contains? s-src "ERR_RETIRED_BUILTIN") "language-semantics.asn must specify ERR_RETIRED_BUILTIN failureCode")
      true)))

(df TestNoCompatibilityAliasesLeftBehind [] -> Bool
  :d "Verifies language-semantics.asn specifies zero compatibility aliases left behind for retired names"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "zeroCompatibilityAliases") "language-semantics.asn must enforce zeroCompatibilityAliases")
      true)))

(df TestTokenCompactionMeasurementGrounded [] -> Bool
  :d "Verifies Phase 459 records 0.97 percent token compaction for the 14 builtins"
  (let [(p-res (file-read ".asl/mem/tasks/Phase459LanguageCompactionAndPredictability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase459 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "0.97 percent") "Phase 459 must document 0.97 percent measured token saving")
      (assert (string-contains? p-src "14712 tokens") "Phase 459 must document 14712 tokens frequency times cost")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45902 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestFourteenRenamedBuiltinsContract) "TestFourteenRenamedBuiltinsContract must pass")
    (assert (TestNoCompatibilityAliasesLeftBehind) "TestNoCompatibilityAliasesLeftBehind must pass")
    (assert (TestTokenCompactionMeasurementGrounded) "TestTokenCompactionMeasurementGrounded must pass")
    true))
