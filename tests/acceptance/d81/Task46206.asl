(module tests/acceptance/d81/Task46206
  :d "Acceptance fixture for Task46206: Standalone portable structures across agents and models under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestStandaloneInterpretableStructureContract
      TestProtocolConformancePortableStructures
      TestTask46206GroundedInPhase462]
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

(df TestStandaloneInterpretableStructureContract [] -> Bool
  :d "Verifies language-semantics.asn defines standaloneInterpretableStructureRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "standaloneInterpretableStructureRule") "language-semantics.asn must define standaloneInterpretableStructureRule semantic")
      (assert (string-contains? s-src "ERR_NON_PORTABLE_STRUCTURE") "language-semantics.asn must specify ERR_NON_PORTABLE_STRUCTURE failureCode")
      true)))

(df TestProtocolConformancePortableStructures [] -> Bool
  :d "Verifies protocol-conformance.asn defines portable structure contract"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":contract :id portableStructures") "protocol-conformance.asn must specify portableStructures contract")
      (assert (string-contains? p-src "standalone") "portableStructures must specify standalone interpretability")
      true)))

(df TestTask46206GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds structure portability"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "A structure carries its own meaning across agents and models") "Phase 462 must state task title")
      (assert (string-contains? p-src "Structures interpretable without sender context") "Phase 462 must state standalone interpretation outcome")
      (assert (string-contains? p-src "One meaning per prefix across every agent and channel") "Phase 462 must state prefix consistency outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46206 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestStandaloneInterpretableStructureContract) "TestStandaloneInterpretableStructureContract must pass")
    (assert (TestProtocolConformancePortableStructures) "TestProtocolConformancePortableStructures must pass")
    (assert (TestTask46206GroundedInPhase462) "TestTask46206GroundedInPhase462 must pass")
    true))
