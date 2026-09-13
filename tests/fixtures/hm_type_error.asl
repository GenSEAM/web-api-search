(module tests/fixtures/hmTypeError
  :d "Inferred polymorphic type mismatch fixture verifying genuine HM checker rejection."
  :x [typeMismatch]
  :i [])

(df helper [] -> String
  :d "Helper returning a string value."
  "mismatch")

(df typeMismatch [] -> Int64
  :d "Attempts to return string result from helper when declared as Int64."
  (helper))
