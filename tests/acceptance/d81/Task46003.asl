(module tests/acceptance/d81/Task46003
  :d "Acceptance fixture for Task46003: Racket module system design for resolution under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRacketModuleResolutionContract
      TestModuleCycleDetectionContract
      TestSingleModuleInstantiationContract
      TestDependencyBoundariesResolutionContract]
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

(df TestRacketModuleResolutionContract [] -> Bool
  :d "Verifies language-semantics.asn defines racketModuleResolution semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "racketModuleResolution") "language-semantics.asn must define racketModuleResolution semantic")
      (assert (string-contains? s-src "ERR_MODULE_NOT_FOUND") "language-semantics.asn must specify ERR_MODULE_NOT_FOUND failureCode")
      true)))

(df TestModuleCycleDetectionContract [] -> Bool
  :d "Verifies language-semantics.asn defines moduleCycleDetection semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "moduleCycleDetection") "language-semantics.asn must define moduleCycleDetection semantic")
      (assert (string-contains? s-src "ERR_MODULE_CYCLE_DETECTED") "language-semantics.asn must specify ERR_MODULE_CYCLE_DETECTED failureCode")
      true)))

(df TestSingleModuleInstantiationContract [] -> Bool
  :d "Verifies language-semantics.asn defines singleModuleInstantiation semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "singleModuleInstantiation") "language-semantics.asn must define singleModuleInstantiation semantic")
      (assert (string-contains? s-src "ERR_MULTIPLE_INSTANTIATION") "language-semantics.asn must specify ERR_MULTIPLE_INSTANTIATION failureCode")
      true)))

(df TestDependencyBoundariesResolutionContract [] -> Bool
  :d "Verifies dependency-boundaries.asn specifies collection roots for module resolution"
  (let [(b-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag b-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(b-src (.-value b-res))]
      (assert (string-contains? b-src "collectionRoots") "dependency-boundaries.asn must specify collectionRoots")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46003 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRacketModuleResolutionContract) "TestRacketModuleResolutionContract must pass")
    (assert (TestModuleCycleDetectionContract) "TestModuleCycleDetectionContract must pass")
    (assert (TestSingleModuleInstantiationContract) "TestSingleModuleInstantiationContract must pass")
    (assert (TestDependencyBoundariesResolutionContract) "TestDependencyBoundariesResolutionContract must pass")
    true))
