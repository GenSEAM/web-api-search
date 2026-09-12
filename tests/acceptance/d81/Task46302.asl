(module tests/acceptance/d81/Task46302
  :d "Acceptance fixture for Task46302: Flattening forms admitted only on a measured double win under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestFlatteningFormDoubleWinRuleContract
      TestFlatteningDoubleWinRequirements
      TestTask46302GroundedInPhase463]
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

(df TestFlatteningFormDoubleWinRuleContract [] -> Bool
  :d "Verifies language-semantics.asn defines flatteningFormDoubleWinRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "flatteningFormDoubleWinRule") "language-semantics.asn must define flatteningFormDoubleWinRule semantic")
      (assert (string-contains? s-src "ERR_FLATTENING_WITHOUT_DOUBLE_WIN") "language-semantics.asn must specify ERR_FLATTENING_WITHOUT_DOUBLE_WIN failureCode")
      true)))

(df TestFlatteningDoubleWinRequirements [] -> Bool
  :d "Verifies language-semantics.asn requires lowering both depth and token count"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "double win") "language-semantics.asn must mandate double win")
      (assert (string-contains? s-src "nesting depth") "language-semantics.asn must specify nesting depth reduction")
      (assert (string-contains? s-src "token count") "language-semantics.asn must specify token count reduction")
      true)))

(df TestTask46302GroundedInPhase463 [] -> Bool
  :d "Verifies Phase 463 task file grounds flattening forms double win"
  (let [(p-res (file-read ".asl/mem/tasks/Phase463AslFirstBeyondRacket.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 463 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Flattening forms, adopted only on a measured double win") "Phase 463 must state task title")
      (assert (string-contains? p-src "Flattening forms admitted on a measured double win") "Phase 463 must state double win outcome")
      (assert (string-contains? p-src "Rejected candidates recorded with both numbers") "Phase 463 must state rejected candidates outcome")
      (assert (string-contains? p-src "Depth tail reduced measurably rather than stylistically") "Phase 463 must state depth tail outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46302 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestFlatteningFormDoubleWinRuleContract) "TestFlatteningFormDoubleWinRuleContract must pass")
    (assert (TestFlatteningDoubleWinRequirements) "TestFlatteningDoubleWinRequirements must pass")
    (assert (TestTask46302GroundedInPhase463) "TestTask46302GroundedInPhase463 must pass")
    true))
