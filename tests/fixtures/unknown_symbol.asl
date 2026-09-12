(module tests/fixtures/unknown-symbol
  :d "Adversarial fixture with deliberate unknown symbol to prove loud evaluator failure."
  :x [run-tests]
  :i [])

(df run-tests [] -> Bool
  :d "Attempts to evaluate undefined symbol to trigger loud failure."
  (do
    (non-existent-symbol-target)
    (assert false "unreachable after unbound symbol error")
    true))
