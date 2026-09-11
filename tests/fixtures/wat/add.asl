(module tests/fixtures/wat/add
  :d "Pure AgentScript addition fixture for WebAssembly Text lowering."
  :x [add]
  :i [])

(df add [(a I32) (b I32)] -> I32
  :d "Adds two 32-bit integers."
  (+ a b))
