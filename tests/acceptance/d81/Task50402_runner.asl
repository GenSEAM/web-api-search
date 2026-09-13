(module tests/acceptance/d81/Task50402_runner
  :d "Subprocess runner for checking m.asl and validating rule-8 enforcement"
  :x [RunTests]
  :i [(../../../asl/packages/asl-checker/src/check :a c)])

(df RunTests [] -> Bool
  :d "Validates that m.asl without docstring produces rule-8 diagnostic in checkSource"
  (let [(diags (c/checkSource "(module m :d \"d\" :x [f]) (df f [] -> Int64 42)" (map-empty) "m.asl"))]
    (assert (not (list-empty? diags)) "m.asl without docstring produces diagnostics")
    (refute (list-empty? diags) "m.asl without docstring must not have empty diagnostics")
    (assert (= (.-code (list-first diags)) "rule-8") "m.asl diagnostic code must be rule-8")
    true))
