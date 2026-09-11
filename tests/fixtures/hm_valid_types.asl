(module tests/fixtures/hm-valid-types
  :d "Valid typed functions and expressions demonstrating clean static type checking."
  :x [identity add-one concat-msg check-logic]
  :i [])

(df identity [(x Int64)] -> Int64
  :d "Returns argument as is."
  x)

(df add-one [(n Int64)] -> Int64
  :d "Increments integer by one."
  (+ n 1))

(df concat-msg [(prefix String) (name String)] -> String
  :d "Concatenates two strings."
  (str prefix name))

(df check-logic [(flag Bool)] -> Bool
  :d "Performs boolean logic."
  (not flag))
