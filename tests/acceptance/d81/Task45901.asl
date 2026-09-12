(module tests/acceptance/d81/Task45901
  :d "Acceptance fixture for Task45901: One name per concept decided in grammar and checked before new builtins."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestPredicateNamingSemanticRule
      TestConstructorNamingSemanticRule
      TestConversionNamingSemanticRule
      TestTokenConventionsContract]
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

(df TestPredicateNamingSemanticRule [] -> Bool
  :d "Verifies language-semantics.asn defines canonical predicate naming rule ending in question mark and rejecting is prefix"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "predicateNaming") "language-semantics.asn must define predicateNaming semantic")
      (assert (string-contains? s-src "ERR_RETIRED_PREDICATE_FORM") "language-semantics.asn must specify ERR_RETIRED_PREDICATE_FORM failureCode")
      true)))

(df TestConstructorNamingSemanticRule [] -> Bool
  :d "Verifies language-semantics.asn defines canonical constructor naming rule with make prefix"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "constructorNaming") "language-semantics.asn must define constructorNaming semantic")
      (assert (string-contains? s-src "ERR_RETIRED_CONSTRUCTOR_FORM") "language-semantics.asn must specify ERR_RETIRED_CONSTRUCTOR_FORM failureCode")
      true)))

(df TestConversionNamingSemanticRule [] -> Bool
  :d "Verifies language-semantics.asn defines canonical conversion naming rule source-to-target"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "conversionNaming") "language-semantics.asn must define conversionNaming semantic")
      (assert (string-contains? s-src "ERR_RETIRED_CONVERSION_FORM") "language-semantics.asn must specify ERR_RETIRED_CONVERSION_FORM failureCode")
      true)))

(df TestTokenConventionsContract [] -> Bool
  :d "Verifies TOKEN_CONVENTIONS.md documents one name per concept policy for predicates, constructors and conversions"
  (let [(t-res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag t-res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "One Name per Concept") "TOKEN_CONVENTIONS.md must have One Name per Concept section")
      (assert (string-contains? t-src "empty?") "TOKEN_CONVENTIONS.md must specify empty? as sanctioned predicate form")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45901 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestPredicateNamingSemanticRule) "TestPredicateNamingSemanticRule must pass")
    (assert (TestConstructorNamingSemanticRule) "TestConstructorNamingSemanticRule must pass")
    (assert (TestConversionNamingSemanticRule) "TestConversionNamingSemanticRule must pass")
    (assert (TestTokenConventionsContract) "TestTokenConventionsContract must pass")
    true))
