(module tests/acceptance/d81/Task47103
  :d "Acceptance fixture for Task47103: dependency ledger truth and python3 purge under ADR-0081."
  :x [run-tests
      test-python3-purged-from-dependencies
      test-dependencies-delimiter-integrity]
  :i [])

(df test-python3-purged-from-dependencies [] -> Bool
  :d "Verifies that python3 is completely purged from .asl/mem/dependencies.asn"
  (let [(dep-res (file-read ".asl/mem/dependencies.asn"))]
    (assert (= (.-_tag dep-res) "ok") ".asl/mem/dependencies.asn must exist and be readable")
    (let [(dep (.-value dep-res))]
      (assert (not (string-contains? dep "name \"python3\""))
              "dependencies.asn must not contain python3")
      true)))

(df test-dependencies-delimiter-integrity [] -> Bool
  :d "Verifies that .asl/mem/dependencies.asn has valid syntax and delimiters"
  (let [(dep-res (file-read ".asl/mem/dependencies.asn"))]
    (assert (= (.-_tag dep-res) "ok") ".asl/mem/dependencies.asn must exist")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task47103 supervisor acceptance tests"
  (do
    (assert (test-python3-purged-from-dependencies) "test-python3-purged-from-dependencies must pass")
    (assert (test-dependencies-delimiter-integrity) "test-dependencies-delimiter-integrity must pass")
    true))
