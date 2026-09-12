(module tests/acceptance/d81/Task46002
  :d "Acceptance fixture for Task46002: Adopt Racket binding shape and decline cheaper Clojure one under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRacketBindingShapeContract
      TestClojureBindingShapeRejectionContract
      TestRacketBindingTradeGroundedInPhase460]
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

(df TestRacketBindingShapeContract [] -> Bool
  :d "Verifies language-semantics.asn defines racketBindingShape semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "racketBindingShape") "language-semantics.asn must define racketBindingShape semantic")
      (assert (string-contains? s-src "ERR_INVALID_BINDING_SHAPE") "language-semantics.asn must specify ERR_INVALID_BINDING_SHAPE failureCode")
      true)))

(df TestClojureBindingShapeRejectionContract [] -> Bool
  :d "Verifies language-semantics.asn defines clojureBindingShapeRejection semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "clojureBindingShapeRejection") "language-semantics.asn must define clojureBindingShapeRejection semantic")
      (assert (string-contains? s-src "ERR_UNALIGNED_BINDING_SHAPE") "language-semantics.asn must specify ERR_UNALIGNED_BINDING_SHAPE failureCode")
      true)))

(df TestRacketBindingTradeGroundedInPhase460 [] -> Bool
  :d "Verifies Phase 460 task file records 0.69 percent rejected savings and 5249 uses"
  (let [(p-res (file-read ".asl/mem/tasks/Phase460SchemeAlignmentAndRacketConcepts.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 460 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "0.69 percent") "Phase 460 must document 0.69 percent rejected savings")
      (assert (string-contains? p-src "5249") "Phase 460 must document 5249 uses")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46002 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRacketBindingShapeContract) "TestRacketBindingShapeContract must pass")
    (assert (TestClojureBindingShapeRejectionContract) "TestClojureBindingShapeRejectionContract must pass")
    (assert (TestRacketBindingTradeGroundedInPhase460) "TestRacketBindingTradeGroundedInPhase460 must pass")
    true))
