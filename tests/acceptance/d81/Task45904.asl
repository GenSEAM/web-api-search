(module tests/acceptance/d81/Task45904
  :d "Acceptance fixture for Task45904: Retire opaque aliases and pay 0.74 percent under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLegibleAliasLengthContract
      TestGlobalPrefixUniquenessContract
      TestSelfContainedSliceResolutionContract
      TestDeliberateTokenCostGrounded]
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

(df TestLegibleAliasLengthContract [] -> Bool
  :d "Verifies language-semantics.asn defines legibleAliasLength requiring aliases >= 3 characters"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "legibleAliasLength") "language-semantics.asn must define legibleAliasLength semantic")
      (assert (string-contains? s-src "ERR_OPAQUE_ALIAS") "language-semantics.asn must specify ERR_OPAQUE_ALIAS failureCode")
      true)))

(df TestGlobalPrefixUniquenessContract [] -> Bool
  :d "Verifies language-semantics.asn defines globalPrefixUniqueness semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "globalPrefixUniqueness") "language-semantics.asn must define globalPrefixUniqueness semantic")
      (assert (string-contains? s-src "ERR_AMBIGUOUS_PREFIX") "language-semantics.asn must specify ERR_AMBIGUOUS_PREFIX failureCode")
      true)))

(df TestSelfContainedSliceResolutionContract [] -> Bool
  :d "Verifies language-semantics.asn defines selfContainedSliceResolution semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "selfContainedSliceResolution") "language-semantics.asn must define selfContainedSliceResolution semantic")
      true)))

(df TestDeliberateTokenCostGrounded [] -> Bool
  :d "Verifies Phase 459 records 0.74 percent token cost and 11132 extra tokens"
  (let [(p-res (file-read ".asl/mem/tasks/Phase459LanguageCompactionAndPredictability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase459 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "0.74 percent") "Phase 459 must document 0.74 percent deliberate token cost")
      (assert (string-contains? p-src "11132") "Phase 459 must document 11132 extra tokens")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45904 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLegibleAliasLengthContract) "TestLegibleAliasLengthContract must pass")
    (assert (TestGlobalPrefixUniquenessContract) "TestGlobalPrefixUniquenessContract must pass")
    (assert (TestSelfContainedSliceResolutionContract) "TestSelfContainedSliceResolutionContract must pass")
    (assert (TestDeliberateTokenCostGrounded) "TestDeliberateTokenCostGrounded must pass")
    true))
