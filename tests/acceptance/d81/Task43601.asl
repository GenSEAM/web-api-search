(module tests/acceptance/d81/Task43601
  :d "Acceptance fixture for Task43601: module import resolution and loud evaluator failure."
  :x [run-tests]
  :i [(d81-sample/resolution-sample :a smp)
      (asl-text/escape :a esc)])

(df test-declared-module-resolution [] -> Bool
  :d "Verifies declared module resolution returns expected sample token"
  (let [(val (smp/sample-identity-value))]
    (assert (= val "sample-manifest-resolution-success") "declared module must resolve and return sample token")
    true))

(df test-package-module-resolution [] -> Bool
  :d "Verifies package module import resolution and execution of exported function"
  (let [(val (esc/escape-asn-str "hello \"world\""))]
    (assert (= val "hello \\\"world\\\"") "package module function must return escaped ASN string")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task43601 acceptance tests"
  (do
    (assert (test-declared-module-resolution) "test-declared-module-resolution must pass")
    (assert (test-package-module-resolution) "test-package-module-resolution must pass")
    true))
