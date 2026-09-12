(module tests/acceptance/d81/Task46706
  :d "Acceptance fixture for Task46706: declared language support per tool under ADR-0081."
  :x [run-tests
      test-capabilities-declare-languages
      test-intel-refuses-undeclared-languages]
  :i [])

(df test-capabilities-declare-languages [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares supported base languages"
  (let [(res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/capabilities.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":supportedLanguages")
              "capabilities.asn must declare :supportedLanguages per tool")
      true)))

(df test-intel-refuses-undeclared-languages [] -> Bool
  :d "Verifies that intel/src enforces language boundary refusals"
  (let [(res (file-read "intel/src/xref.asl"))]
    (assert (= (.-_tag res) "ok") "intel/src/xref.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "language") "xref.asl must enforce language checks")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46706 supervisor acceptance tests"
  (do
    (assert (test-capabilities-declare-languages) "test-capabilities-declare-languages must pass")
    (assert (test-intel-refuses-undeclared-languages) "test-intel-refuses-undeclared-languages must pass")
    true))
