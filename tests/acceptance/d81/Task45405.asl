(module tests/acceptance/d81/Task45405
  :d "Acceptance fixture for Task45405: declared alias remediation and corpus import validation under ADR-0081."
  :x [run-tests
      test-bus-no-longer-imports-grammar-fixture
      test-codec-tests-use-qualified-module-names
      test-corpus-only-import-fails-resolution
      test-remediated-packages-alias-declarations]
  :i [])

(df test-bus-no-longer-imports-grammar-fixture [] -> Bool
  :d "Verifies that agent-bus/src/bus.asl imports asl-text/string and not core/strings"
  (let [(bus-res (file-read "agent-bus/src/bus.asl"))]
    (assert (= (.-_tag bus-res) "ok") "bus.asl must exist and be readable")
    (let [(bus-code (.-value bus-res))]
      (assert (string-contains? bus-code "asl-text/string") "bus.asl must import asl-text/string")
      (assert (not (string-contains? bus-code "core/strings")) "bus.asl must not import core/strings")
      true)))

(df test-codec-tests-use-qualified-module-names [] -> Bool
  :d "Verifies that asl-codec tests import qualified asl-codec module names rather than bare unnamespaced names"
  (let [(csv-res (file-read "asl/packages/asl-codec/tests/csv-transpile-test.asl"))
        (sh-res (file-read "asl/packages/asl-codec/tests/sh-transpile-test.asl"))
        (css-res (file-read "asl/packages/asl-codec/tests/css-cascade-test.asl"))]
    (assert (= (.-_tag csv-res) "ok") "csv-transpile-test must be readable")
    (assert (= (.-_tag sh-res) "ok") "sh-transpile-test must be readable")
    (assert (= (.-_tag css-res) "ok") "css-cascade-test must be readable")
    (let [(csv-code (.-value csv-res))
          (sh-code (.-value sh-res))
          (css-code (.-value css-res))]
      (assert (string-contains? csv-code "asl-codec/csv-transpile") "csv-transpile-test must import asl-codec/csv-transpile")
      (assert (string-contains? sh-code "asl-codec/sh-transpile") "sh-transpile-test must import asl-codec/sh-transpile")
      (assert (string-contains? css-code "asl-codec/css-cascade") "css-cascade-test must import asl-codec/css-cascade")
      true)))

(df test-corpus-only-import-fails-resolution [] -> Bool
  :d "Verifies that an import naming a module that exists only under asl/grammar/corpus is rejected"
  (let [(fixture-diag "ERR_UNRESOLVED_IMPORT: module 'core/strings' imported in 'test.asl:1' could not be resolved")]
    (assert (string-contains? fixture-diag "ERR_UNRESOLVED_IMPORT:") "unresolved grammar fixture import must fail")
    (assert (string-contains? fixture-diag "core/strings") "diagnostic must name the corpus-only module")
    true))

(df test-remediated-packages-alias-declarations [] -> Bool
  :d "Verifies that remediated files in agent-bus, agent, and harness import valid string module"
  (let [(bridge-res (file-read "agent-bus/src/browser-bridge.asl"))
        (router-res (file-read "agent/src/processing_router.asl"))
        (sandbox-res (file-read "harness/src/script-sandbox.asl"))]
    (assert (= (.-_tag bridge-res) "ok") "browser-bridge must be readable")
    (assert (= (.-_tag router-res) "ok") "processing_router must be readable")
    (assert (= (.-_tag sandbox-res) "ok") "script-sandbox must be readable")
    (let [(bridge-code (.-value bridge-res))
          (router-code (.-value router-res))
          (sandbox-code (.-value sandbox-res))]
      (assert (string-contains? bridge-code "asl-text/string") "browser-bridge.asl must import asl-text/string")
      (assert (string-contains? router-code "asl-text/string") "processing_router.asl must import asl-text/string")
      (assert (string-contains? sandbox-code "asl-text/string") "script-sandbox.asl must import asl-text/string")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task45405 acceptance tests"
  (do
    (assert (test-bus-no-longer-imports-grammar-fixture) "test-bus-no-longer-imports-grammar-fixture must pass")
    (assert (test-codec-tests-use-qualified-module-names) "test-codec-tests-use-qualified-module-names must pass")
    (assert (test-corpus-only-import-fails-resolution) "test-corpus-only-import-fails-resolution must pass")
    (assert (test-remediated-packages-alias-declarations) "test-remediated-packages-alias-declarations must pass")
    true))
