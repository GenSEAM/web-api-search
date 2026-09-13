(module tests/fixtures/unknownSymbol
  :d "Adversarial fixture with deliberate unknown symbol to prove loud evaluator failure."
  :x [runTests]
  :i [])

(df runTests [] -> Bool
  :d "Attempts to evaluate undefined symbol to trigger loud failure."
  (do
    (nonExistentSymbolTarget)
    (assert false "unreachable after unbound symbol error")
    true))
