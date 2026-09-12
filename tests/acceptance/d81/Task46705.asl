(module tests/acceptance/d81/Task46705
  :d "Acceptance fixture for Task46705: engine session and process model specification under ADR-0081."
  :x [run-tests
      test-engine-process-model-doc-exists
      test-engine-protocol-conformance]
  :i [])

(df test-engine-process-model-doc-exists [] -> Bool
  :d "Verifies that docs/ENGINE_PROCESS_MODEL.md exists and documents engine residency"
  (let [(res (file-read "docs/ENGINE_PROCESS_MODEL.md"))]
    (assert (= (.-_tag res) "ok") "docs/ENGINE_PROCESS_MODEL.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "JavaScriptCore") "doc must document JSC bootstrap engine")
      (assert (string-contains? src "discovered_ws") "doc must document workspace root resolution")
      true)))

(df test-engine-protocol-conformance [] -> Bool
  :d "Verifies that protocol-conformance.asn documents host engine interfaces"
  (let [(res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/protocol-conformance.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":engine") "protocol-conformance must define :engine protocol")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46705 supervisor acceptance tests"
  (do
    (assert (test-engine-process-model-doc-exists) "test-engine-process-model-doc-exists must pass")
    (assert (test-engine-protocol-conformance) "test-engine-protocol-conformance must pass")
    true))
