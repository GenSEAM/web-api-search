(module tests/acceptance/d81/Task46205
  :d "Acceptance fixture for Task46205: Lossless code and ASN substrate conversion under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLosslessAsnCodeConversionContract
      TestCodecLosslessSubstrateContract
      TestTask46205GroundedInPhase462]
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

(df TestLosslessAsnCodeConversionContract [] -> Bool
  :d "Verifies language-semantics.asn defines losslessAsnCodeConversion semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "losslessAsnCodeConversion") "language-semantics.asn must define losslessAsnCodeConversion semantic")
      (assert (string-contains? s-src "ERR_LOSSY_SUBSTRATE_CONVERSION") "language-semantics.asn must specify ERR_LOSSY_SUBSTRATE_CONVERSION failureCode")
      true)))

(df TestCodecLosslessSubstrateContract [] -> Bool
  :d "Verifies asl-codec grammar.asn defines lossless conversion preserving positions and escaping"
  (let [(c-res (file-read "asl/packages/asl-codec/grammar.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl-codec grammar.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "lossless") "codec grammar.asn must specify lossless conversion")
      (assert (string-contains? c-src "round trip") "codec grammar.asn must specify round trip property")
      true)))

(df TestTask46205GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds lossless code and ASN conversion"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "One substrate: code and ASN convert without loss") "Phase 462 must state task title")
      (assert (string-contains? p-src "Lossless round trip between form and record") "Phase 462 must state round trip outcome")
      (assert (string-contains? p-src "Positions and escaping preserved") "Phase 462 must state preservation outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46205 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLosslessAsnCodeConversionContract) "TestLosslessAsnCodeConversionContract must pass")
    (assert (TestCodecLosslessSubstrateContract) "TestCodecLosslessSubstrateContract must pass")
    (assert (TestTask46205GroundedInPhase462) "TestTask46205GroundedInPhase462 must pass")
    true))
