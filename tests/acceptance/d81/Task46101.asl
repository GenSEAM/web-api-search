(module tests/acceptance/d81/Task46101
  :d "Acceptance fixture for Task46101: The core knows no extension by name under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestZeroExtensionKnowledgeInCoreContract
      TestModuleResolverCollectionRootsContract
      TestCoreSourcesExtensionNameHygiene]
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

(df TestZeroExtensionKnowledgeInCoreContract [] -> Bool
  :d "Verifies language-semantics.asn defines zeroExtensionKnowledgeInCore semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "zeroExtensionKnowledgeInCore") "language-semantics.asn must define zeroExtensionKnowledgeInCore semantic")
      (assert (string-contains? s-src "ERR_CORE_EXTENSION_CONTAMINATION") "language-semantics.asn must specify ERR_CORE_EXTENSION_CONTAMINATION failureCode")
      true)))

(df TestModuleResolverCollectionRootsContract [] -> Bool
  :d "Verifies dependency-boundaries.asn defines collectionRoots and engine.js uses collection roots resolution"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src "collectionRoots") "dependency-boundaries.asn must define collectionRoots")
      (let [(e-res (file-read "asl/tools/engine.js"))]
        (assert (= (.-_tag e-res) "ok") "asl/tools/engine.js must exist and be readable")
        (let [(e-src (.-value e-res))]
          (assert (string-contains? e-src "collectionRoots") "engine.js must reference collectionRoots for module resolution")
          true)))))

(df TestCoreSourcesExtensionNameHygiene [] -> Bool
  :d "Verifies engine.js does not contain hardcoded candidate paths for specific packages like asl-sql or blog data"
  (let [(e-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag e-res) "ok") "asl/tools/engine.js must exist and be readable")
    (let [(e-src (.-value e-res))]
      (assert (not (string-contains? e-src "asl/packages/asl-sql/src/main.asl")) "engine.js must not hardcode asl-sql candidate path")
      (assert (not (string-contains? e-src "data/blog")) "engine.js must not hardcode blog data directory path")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46101 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestZeroExtensionKnowledgeInCoreContract) "TestZeroExtensionKnowledgeInCoreContract must pass")
    (assert (TestModuleResolverCollectionRootsContract) "TestModuleResolverCollectionRootsContract must pass")
    (assert (TestCoreSourcesExtensionNameHygiene) "TestCoreSourcesExtensionNameHygiene must pass")
    true))
