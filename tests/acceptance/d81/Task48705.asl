(module tests/acceptance/d81/Task48705
  :d "Stage 2 bootstrap execution test for Phase 487 (Task 48705)."
  :x [testParserEmpty]
  :i [(../../../asl/packages/asl-compiler/src/parser :a parser)])

(df testParserEmpty [] -> Bool
  :d "Verifies parser tokenize_asl."
  (let [(tokens (parser/tokenize_asl "test"))]
    (assert (> (count tokens) 0) "Should return tokens")
    (refute (= (count tokens) 0) "Should not be empty list")
    true))
