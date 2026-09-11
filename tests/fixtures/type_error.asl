(module tests/fixtures/type-error
  :d "Adversarial fixture with deliberate static type mismatch to prove type checker falsifiability."
  :x [type-mismatch]
  :i [])

(df type-mismatch [(x Int64)] -> Int64
  :d "Returns String instead of declared Int64 to trigger type checker rejection."
  "invalid-string-return")
