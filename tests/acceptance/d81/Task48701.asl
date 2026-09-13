(module tests/acceptance/d81/Task48701
  :d "Test real parser output structure for Phase 487 (Task 48701)."
  :x [testParserOutput]
  :i [(../../../asl/packages/asl-compiler/src/parser :a parser)])

(df testParserOutput [] -> Bool
  :d "Verifies the structure returned by parse_asl_source contains valid AST tree."
  (let [(res (parser/parse_asl_source "(df x [] 1)"))]
    (assert (= (get res :valid) true) "Parser should return a valid AST")
    (refute (= (get res :pipeline) "stub") "Pipeline must not be vacuous")
    true))
