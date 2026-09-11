(module tests/fixtures/hm-type-error
  :d "Inferred polymorphic type mismatch fixture verifying genuine HM checker rejection."
  :x [type-mismatch]
  :i [])

(df helper [] -> String
  :d "Helper returning a string value."
  "mismatch")

(df type-mismatch [] -> Int64
  :d "Attempts to return string result from helper when declared as Int64."
  (helper))
