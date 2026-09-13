(module tests/probes/language_matrix_test
  :d "Language scenario matrix verifying declared language support and undeclared language refusal under ADR-0081."
  :x [runTests
      testSupportedLanguagesMatrix
      testUnsupportedLanguageRefusal
      testXrefLanguageValidation]
  :i [(aslIntel/xref :a xref)])

(df testSupportedLanguagesMatrix [] -> Bool
  :d "Verifies that core declared languages are recognized"
  (do
    (assert (xref/isSupportedLanguage? "asl") "asl must be supported")
    (assert (xref/isSupportedLanguage? "asn") "asn must be supported")
    (assert (xref/isSupportedLanguage? "ts") "ts must be supported")
    (assert (xref/isSupportedLanguage? "js") "js must be supported")
    (assert (xref/isSupportedLanguage? "py") "py must be supported")
    (assert (xref/isSupportedLanguage? "go") "go must be supported")
    (assert (xref/isSupportedLanguage? "rs") "rs must be supported")
    (assert (xref/isSupportedLanguage? "php") "php must be supported")
    (assert (xref/isSupportedLanguage? "md") "md must be supported")
    (assert (xref/isSupportedLanguage? "c") "c must be supported")
    true))

(df testUnsupportedLanguageRefusal [] -> Bool
  :d "Verifies that undeclared foreign extensions are refused"
  (do
    (assert (not (xref/isSupportedLanguage? "xyz")) "xyz must be refused")
    (assert (not (xref/isSupportedLanguage? "foo")) "foo must be refused")
    (assert (not (xref/isSupportedLanguage? "bar")) "bar must be refused")
    (assert (not (xref/isSupportedLanguage? "unknown")) "unknown must be refused")
    true))

(df testXrefLanguageValidation [] -> Bool
  :d "Verifies capabilities declaration in capabilities.asn"
  (let [(res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag res) "ok") "capabilities.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":supportedLanguages") "capabilities.asn must declare :supportedLanguages")
      true)))

(df runTests [] -> Bool
  :d "Executes all language matrix probe tests"
  (do
    (assert (testSupportedLanguagesMatrix) "test-supported-languages-matrix must pass")
    (assert (testUnsupportedLanguageRefusal) "test-unsupported-language-refusal must pass")
    (assert (testXrefLanguageValidation) "test-xref-language-validation must pass")
    true))
