(module tests/acceptance/d81/Task46301
  :d "Acceptance fixture for Task46301: Nesting depth tracking and bounded ceiling under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestNestingDepthCeilingContract
      TestNestingDepthTrackingContract
      TestTask46301GroundedInPhase463]
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

(df TestNestingDepthCeilingContract [] -> Bool
  :d "Verifies language-semantics.asn defines nestingDepthCeilingRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "nestingDepthCeilingRule") "language-semantics.asn must define nestingDepthCeilingRule semantic")
      (assert (string-contains? s-src "ERR_EXCESSIVE_NESTING_DEPTH") "language-semantics.asn must specify ERR_EXCESSIVE_NESTING_DEPTH failureCode")
      true)))

(df TestNestingDepthTrackingContract [] -> Bool
  :d "Verifies asl.c tracks nesting depth excluding string literals"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_file_delimiters") "asl.c must implement check_file_delimiters")
      (assert (string-contains? c-src "in_str") "asl.c must exclude string literals from depth tracking")
      (assert (string-contains? c-src "depth") "asl.c must track delimiter depth")
      true)))

(df TestTask46301GroundedInPhase463 [] -> Bool
  :d "Verifies Phase 463 task file grounds nesting depth tracking and ceiling"
  (let [(p-res (file-read ".asl/mem/tasks/Phase463AslFirstBeyondRacket.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 463 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Nesting depth is a bounded, tracked quantity") "Phase 463 must state task title")
      (assert (string-contains? p-src "Depth reported per file and per form") "Phase 463 must state depth report outcome")
      (assert (string-contains? p-src "A ceiling derived from the measured distribution") "Phase 463 must state ceiling outcome")
      (assert (string-contains? p-src "Exceeding forms named individually") "Phase 463 must state exceeding forms outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46301 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestNestingDepthCeilingContract) "TestNestingDepthCeilingContract must pass")
    (assert (TestNestingDepthTrackingContract) "TestNestingDepthTrackingContract must pass")
    (assert (TestTask46301GroundedInPhase463) "TestTask46301GroundedInPhase463 must pass")
    true))
