(module tests/fixtures/typeError
  :d "Adversarial fixture with deliberate static type mismatch to prove type checker falsifiability."
  :x [typeMismatch]
  :i [])

(df typeMismatch [(x Int64)] -> Int64
  :d "Returns String instead of declared Int64 to trigger type checker rejection."
  "invalid-string-return")
