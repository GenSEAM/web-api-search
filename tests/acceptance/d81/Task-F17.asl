(module tests/acceptance/d81/Task-F17
  :d "Acceptance fixture for Task-F17: Implement True AST Symbol Extraction in Intel Engine under ADR-0081."
  :x [RunTests
      TestExtractAslSymbolsDefinitions
      TestExtractAslSymbolsReferences
      TestTaskF17GroundedInPhaseFINSEL]
  :i [(asl-intel/extractor :a ext)])

(df TestExtractAslSymbolsDefinitions [] -> Bool
  :d "Verifies extract-asl-symbols extracts function, schema, and enum definitions from ASL source"
  (let [(src (str "(module test-pkg\n"
                  "  :x [compute-value])\n\n"
                  "(df compute-value [(x I64)] -> I64\n"
                  "  :d \"Computes value\"\n"
                  "  (math/double x))\n\n"
                  "(dfs Config\n"
                  "  (:f timeout I64 \"timeout\"))\n\n"
                  "(dfe Result\n"
                  "  (:c success [] \"ok\")\n"
                  "  (:c failure [] \"err\"))\n"))
        (r (ext/extract-asl-symbols "src/test_pkg.asl" src))]
    (assert (= (.-language r) "asl") "language must be asl")
    (assert (>= (list-length (.-symbols r)) 3) "must extract at least 3 symbol definitions")
    (let [(sym-names (map (fn [(s ext/SymbolDef)] -> Str (.-name s)) (.-symbols r)))
          (all-names (string-join sym-names " "))]
      (assert (string-contains? all-names "compute-value") "must contain compute-value function")
      (assert (string-contains? all-names "Config") "must contain Config record")
      (assert (string-contains? all-names "Result") "must contain Result enum")
      true)))

(df TestExtractAslSymbolsReferences [] -> Bool
  :d "Verifies extract-asl-symbols extracts symbol references and caller context from ASL source"
  (let [(src (str "(module test-pkg\n"
                  "  :x [run])\n\n"
                  "(df run [] -> Unit\n"
                  "  (service/start!)\n"
                  "  (logger/info \"done\"))\n"))
        (r (ext/extract-asl-symbols "src/test_pkg.asl" src))]
    (assert (> (list-length (.-refs r)) 0) "must extract at least one symbol reference")
    (let [(ref-names (map (fn [(rf ext/SymbolRef)] -> Str (.-name rf)) (.-refs r)))
          (all-refs (string-join ref-names " "))]
      (assert (string-contains? all-refs "service/start!") "must capture service/start! call reference")
      true)))

(df TestTaskF17GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F17 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F17\"") "Must declare Task-F17")
      (assert (string-contains? f-src "intel/src/extractor.asl") "Must own extractor.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F17 acceptance checks"
  (do
    (assert (TestExtractAslSymbolsDefinitions) "TestExtractAslSymbolsDefinitions must pass")
    (assert (TestExtractAslSymbolsReferences) "TestExtractAslSymbolsReferences must pass")
    (assert (TestTaskF17GroundedInPhaseFINSEL) "TestTaskF17GroundedInPhaseFINSEL must pass")
    true))
