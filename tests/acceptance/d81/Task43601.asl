(module tests/acceptance/d81/Task43601
  :d "Acceptance fixture for Task43601: module import resolution and loud evaluator failure."
  :x [runTests]
  :i [(d81Sample/resolutionSample :a smp)
      (asl-text/escape :a esc)])

(df testDeclaredModuleResolution [] -> Bool
  :d "Verifies declared module resolution returns expected sample token"
  (let [(val (smp/sampleIdentityValue))]
    (assert (= val "sample-manifest-resolution-success") "declared module must resolve and return sample token")
    true))

(df testPackageModuleResolution [] -> Bool
  :d "Verifies package module import resolution and execution of exported function"
  (let [(val (esc/escapeAsnStr "hello \"world\""))]
    (assert (= val "hello \\\"world\\\"") "package module function must return escaped ASN string")
    true))

(df runTests [] -> Bool
  :d "Executes all Task43601 acceptance tests"
  (do
    (assert (testDeclaredModuleResolution) "test-declared-module-resolution must pass")
    (assert (testPackageModuleResolution) "test-package-module-resolution must pass")
    true))
