(module tests/fixtures/hmValidTypes
  :d "Valid typed functions and expressions demonstrating clean static type checking."
  :x [identity addOne concatMsg checkLogic]
  :i [])

(df identity [(x Int64)] -> Int64
  :d "Returns argument as is."
  x)

(df addOne [(n Int64)] -> Int64
  :d "Increments integer by one."
  (+ n 1))

(df concatMsg [(prefix String) (name String)] -> String
  :d "Concatenates two strings."
  (str prefix name))

(df checkLogic [(flag Bool)] -> Bool
  :d "Performs boolean logic."
  (not flag))
