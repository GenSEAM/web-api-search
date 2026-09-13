(module tests/acceptance/d81/Task45401
  :d "Acceptance fixture for Task45401: manifest-driven module graph resolution under ADR-0081."
  :x [runTests
      testDeclaredManifestResolution
      testWorkspaceModuleResolution]
  :i [(d81Sample/resolutionSample :a smp)
      (aslMem/math :a mmath)])

(df testDeclaredManifestResolution [] -> Bool
  :d "Verifies that a module in a path absent from the old guess ladder resolves by its declared header"
  (let [(token (smp/sampleIdentityValue))]
    (assert (= token "sample-manifest-resolution-success") "module must resolve and execute via declared name")
    true))

(df testWorkspaceModuleResolution [] -> Bool
  :d "Verifies workspace module declared as asl-mem/math resolves to its declaring file"
  (let [(dot (mmath/vectorDot (list 1.0 2.0) (list 3.0 4.0)))]
    (assert (= dot 11.0) "vector-dot must evaluate correctly on resolved module")
    true))

(df runTests [] -> Bool
  :d "Executes all Task45401 acceptance tests"
  (do
    (assert (testDeclaredManifestResolution) "test-declared-manifest-resolution must pass")
    (assert (testWorkspaceModuleResolution) "test-workspace-module-resolution must pass")
    true))
