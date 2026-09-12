(module tests/acceptance/d81/Task46204
  :d "Acceptance fixture for Task46204: The human reads a decoder, never the source under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestHumanDecoderSeparationContract
      TestDecoderContractSpecification
      TestTask46204GroundedInPhase462]
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

(df TestHumanDecoderSeparationContract [] -> Bool
  :d "Verifies language-semantics.asn defines humanDecoderSeparation semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "humanDecoderSeparation") "language-semantics.asn must define humanDecoderSeparation semantic")
      (assert (string-contains? s-src "ERR_DECODER_OUTPUT_REENTRY") "language-semantics.asn must specify ERR_DECODER_OUTPUT_REENTRY failureCode")
      true)))

(df TestDecoderContractSpecification [] -> Bool
  :d "Verifies protocol-conformance.asn defines decoder tool contracts"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":contract :id decoderTool") "protocol-conformance.asn must define decoderTool contract")
      (assert (string-contains? p-src "human-readable") "decoderTool must specify human-readable output")
      (assert (string-contains? p-src "no-reentry") "decoderTool must enforce no-reentry as source")
      true)))

(df TestTask46204GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds human decoder tool outcomes"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "The human reads a decoder, never the source") "Phase 462 must state task title")
      (assert (string-contains? p-src "A decoder covering source, forms, prefixes and expansions") "Phase 462 must state decoder coverage outcome")
      (assert (string-contains? p-src "Decoder output never re-enters as source") "Phase 462 must state no-reentry outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46204 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestHumanDecoderSeparationContract) "TestHumanDecoderSeparationContract must pass")
    (assert (TestDecoderContractSpecification) "TestDecoderContractSpecification must pass")
    (assert (TestTask46204GroundedInPhase462) "TestTask46204GroundedInPhase462 must pass")
    true))
