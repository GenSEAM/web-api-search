(module tests/probes/language_matrix_test
  :d "Language scenario matrix verifying declared language support and undeclared language refusal under ADR-0081."
  :x [run-tests
      test-supported-languages-matrix
      test-unsupported-language-refusal
      test-xref-language-validation]
  :i [(asl-intel/xref :a xref)])

(df test-supported-languages-matrix [] -> Bool
  :d "Verifies that core declared languages are recognized"
  (do
    (assert (xref/is-supported-language? "asl") "asl must be supported")
    (assert (xref/is-supported-language? "asn") "asn must be supported")
    (assert (xref/is-supported-language? "ts") "ts must be supported")
    (assert (xref/is-supported-language? "js") "js must be supported")
    (assert (xref/is-supported-language? "py") "py must be supported")
    (assert (xref/is-supported-language? "go") "go must be supported")
    (assert (xref/is-supported-language? "rs") "rs must be supported")
    (assert (xref/is-supported-language? "php") "php must be supported")
    (assert (xref/is-supported-language? "md") "md must be supported")
    (assert (xref/is-supported-language? "c") "c must be supported")
    true))

(df test-unsupported-language-refusal [] -> Bool
  :d "Verifies that undeclared foreign extensions are refused"
  (do
    (assert (not (xref/is-supported-language? "xyz")) "xyz must be refused")
    (assert (not (xref/is-supported-language? "foo")) "foo must be refused")
    (assert (not (xref/is-supported-language? "bar")) "bar must be refused")
    (assert (not (xref/is-supported-language? "unknown")) "unknown must be refused")
    true))

(df test-xref-language-validation [] -> Bool
  :d "Verifies capabilities declaration in capabilities.asn"
  (let [(res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag res) "ok") "capabilities.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":supportedLanguages") "capabilities.asn must declare :supportedLanguages")
      true)))

(df run-tests [] -> Bool
  :d "Executes all language matrix probe tests"
  (do
    (assert (test-supported-languages-matrix) "test-supported-languages-matrix must pass")
    (assert (test-unsupported-language-refusal) "test-unsupported-language-refusal must pass")
    (assert (test-xref-language-validation) "test-xref-language-validation must pass")
    true))
