(module tests/acceptance/d81/Task46103
  :d "Acceptance fixture for Task46103: One engine interface with interchangeable engines under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestInterchangeableEngineInterfaceContract
      TestProtocolConformanceHostInterface
      TestTwoConformingEnginesSpecification
      TestTask46103GroundedInPhase461]
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

(df TestInterchangeableEngineInterfaceContract [] -> Bool
  :d "Verifies language-semantics.asn defines interchangeableEngineInterface semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "interchangeableEngineInterface") "language-semantics.asn must define interchangeableEngineInterface semantic")
      (assert (string-contains? s-src "ERR_CONCRETE_ENGINE_COUPLING") "language-semantics.asn must specify ERR_CONCRETE_ENGINE_COUPLING failureCode")
      true)))

(df TestProtocolConformanceHostInterface [] -> Bool
  :d "Verifies protocol-conformance.asn defines hostInterface covering evaluation, filesystem, network, time, and randomness"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":contract :id hostInterface") "protocol-conformance.asn must define hostInterface contract")
      (assert (string-contains? p-src "evaluation") "hostInterface must cover evaluation")
      (assert (string-contains? p-src "filesystem") "hostInterface must cover filesystem")
      (assert (string-contains? p-src "time") "hostInterface must cover time")
      (assert (string-contains? p-src "randomness") "hostInterface must cover randomness")
      true)))

(df TestTwoConformingEnginesSpecification [] -> Bool
  :d "Verifies protocol-conformance.asn specifies at least two conforming engines"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":conformingEngines") "protocol-conformance.asn must specify conformingEngines")
      (assert (string-contains? p-src "native-host") "must specify native-host engine")
      (assert (string-contains? p-src "portable-wasm") "must specify portable-wasm engine")
      true)))

(df TestTask46103GroundedInPhase461 [] -> Bool
  :d "Verifies Phase 461 task file grounds one engine interface with interchangeable engines"
  (let [(p-res (file-read ".asl/mem/tasks/Phase461CoreAndInterchangeableExtensions.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 461 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "One engine interface, engines interchangeable, the language naming none") "Phase 461 must state task title")
      (assert (string-contains? p-src "Two conforming engines running one unchanged suite") "Phase 461 must state two conforming engines outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46103 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestInterchangeableEngineInterfaceContract) "TestInterchangeableEngineInterfaceContract must pass")
    (assert (TestProtocolConformanceHostInterface) "TestProtocolConformanceHostInterface must pass")
    (assert (TestTwoConformingEnginesSpecification) "TestTwoConformingEnginesSpecification must pass")
    (assert (TestTask46103GroundedInPhase461) "TestTask46103GroundedInPhase461 must pass")
    true))
