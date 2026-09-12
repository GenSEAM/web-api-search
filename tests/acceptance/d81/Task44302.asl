(module tests/acceptance/d81/Task44302
  :d "Acceptance fixture for Task44302: Evaluator semantics and module resolution under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestEvaluatorConformanceSuiteExecution
      TestEvaluatorCoreSymbolsContract
      TestEvaluatorErrorCodesContract
      TestRequiredCaseKindsContract
      TestTask44302GroundedInPhase443]
  :i [("../../conformance/evaluator/evaluator_semantics_test" :a est)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestEvaluatorConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/evaluator/evaluator_semantics_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/evaluator/evaluator_semantics_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (est/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestEvaluatorCoreSymbolsContract [] -> Bool
  :d "Verifies asl/tools/engine.js implements evalNode, loadModuleImports, and invokeClosure"
  (let [(c-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/engine.js must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "evalNode") "engine.js must declare evalNode")
      (assert (string-contains? c-src "loadModuleImports") "engine.js must declare loadModuleImports")
      (assert (string-contains? c-src "invokeClosure") "engine.js must declare invokeClosure")
      true)))

(df TestEvaluatorErrorCodesContract [] -> Bool
  :d "Verifies asl/tools/engine.js implements mandatory diagnostic error codes"
  (let [(c-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/engine.js must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "ERR_UNBOUND_SYMBOL") "engine.js must define ERR_UNBOUND_SYMBOL")
      (assert (string-contains? c-src "ERR_UNRESOLVED_IMPORT") "engine.js must define ERR_UNRESOLVED_IMPORT")
      (assert (string-contains? c-src "ERR_TEST_RESULT_NOT_TRUE") "engine.js must define ERR_TEST_RESULT_NOT_TRUE")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (negativeControl, errorPropagation, boundary, malformed/unresolved, metamorphic) are present"
  (let [(f-res (file-read "tests/conformance/evaluator/evaluator_semantics_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestPositiveControlEvaluationPasses") "Must implement positive control")
      (assert (string-contains? f-src "TestNegativeControlAssertionFailureRefused") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestErrorPropagationUnboundSymbolRejection") "Must implement errorPropagation case")
      (assert (string-contains? f-src "TestBoundaryLetBindingScoping") "Must implement boundary case")
      (assert (string-contains? f-src "TestErrorPropagationUnresolvedImport") "Must implement malformed/unresolved import case")
      (assert (string-contains? f-src "TestMetamorphicAliasedImportEquivalence") "Must implement metamorphic case")
      true)))

(df TestTask44302GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44302"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Evaluator semantics and module resolution") "Phase 443 must state Task44302 title")
      (assert (string-contains? p-src ":lane \"runtime\"") "Phase 443 must specify runtime lane")
      (assert (string-contains? p-src "tests/conformance/evaluator") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "evalNode") "Phase 443 must target evalNode")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44302 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestEvaluatorConformanceSuiteExecution) "TestEvaluatorConformanceSuiteExecution must pass")
    (assert (TestEvaluatorCoreSymbolsContract) "TestEvaluatorCoreSymbolsContract must pass")
    (assert (TestEvaluatorErrorCodesContract) "TestEvaluatorErrorCodesContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44302GroundedInPhase443) "TestTask44302GroundedInPhase443 must pass")
    true))
