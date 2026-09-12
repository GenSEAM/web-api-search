(module tests/acceptance/d81/Task44001
  :d "Acceptance fixture for Task44001: Implement the evaluator in ASL under canonical conformance under ADR-0081."
  :x [RunTests
      TestEvaluatorPackageManifestAndStructure
      TestCanonicalLanguageSemanticsContract
      TestEvaluatorCoreExportsAndModuleStructure]
  :i [])

(df TestEvaluatorPackageManifestAndStructure [] -> Bool
  :d "Verifies that asl/packages/asl-eval exists as a canonical pure ASL package"
  (let [(m-res (file-read "asl/packages/asl-eval/manifest.asn"))
        (g-res (file-read "asl/packages/asl-eval/grammar.asn"))]
    (assert (= (.-_tag m-res) "ok") "asl/packages/asl-eval/manifest.asn must exist and be readable")
    (assert (= (.-_tag g-res) "ok") "asl/packages/asl-eval/grammar.asn must exist and be readable")
    (let [(m-src (.-value m-res))
          (g-src (.-value g-res))]
      (assert (string-contains? m-src "(:package asl-eval") "manifest.asn must declare package asl-eval")
      (assert (string-contains? m-src ":asl-first true") "manifest.asn must declare :asl-first true")
      (assert (string-contains? g-src "(:sym :name \"eval-node\"") "grammar.asn must declare eval-node")
      (assert (string-contains? g-src "(:sym :name \"invoke-closure\"") "grammar.asn must declare invoke-closure")
      (assert (string-contains? g-src "(:sym :name \"load-module\"") "grammar.asn must declare load-module")
      true)))

(df TestCanonicalLanguageSemanticsContract [] -> Bool
  :d "Verifies that language-semantics.asn specifies canonical error codes for unbound symbols, imports, and failures"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "asl/grammar/language-semantics.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src "ERR_UNBOUND_SYMBOL") "Must define ERR_UNBOUND_SYMBOL")
      (assert (string-contains? src "ERR_UNRESOLVED_IMPORT") "Must define ERR_UNRESOLVED_IMPORT")
      (assert (string-contains? src "ERR_DUPLICATE_MODULE") "Must define ERR_DUPLICATE_MODULE")
      (assert (string-contains? src "ERR_TEST_RESULT_NOT_TRUE") "Must define ERR_TEST_RESULT_NOT_TRUE")
      true)))

(df TestEvaluatorCoreExportsAndModuleStructure [] -> Bool
  :d "Verifies that asl/packages/asl-eval/src/eval.asl implements eval-node, invoke-closure, and load-module"
  (let [(e-res (file-read "asl/packages/asl-eval/src/eval.asl"))]
    (assert (= (.-_tag e-res) "ok") "asl/packages/asl-eval/src/eval.asl must exist and be readable")
    (let [(src (.-value e-res))]
      (assert (string-contains? src "module asl-eval") "eval.asl must declare module asl-eval")
      (assert (string-contains? src "eval-node") "eval.asl must define eval-node")
      (assert (string-contains? src "invoke-closure") "eval.asl must define invoke-closure")
      (assert (string-contains? src "load-module") "eval.asl must define load-module")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44001 supervisor acceptance tests"
  (do
    (assert (TestEvaluatorPackageManifestAndStructure) "TestEvaluatorPackageManifestAndStructure must pass")
    (assert (TestCanonicalLanguageSemanticsContract) "TestCanonicalLanguageSemanticsContract must pass")
    (assert (TestEvaluatorCoreExportsAndModuleStructure) "TestEvaluatorCoreExportsAndModuleStructure must pass")
    true))
