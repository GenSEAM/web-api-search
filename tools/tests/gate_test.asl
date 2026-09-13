(module aslTools/gateTest
  :d "Unit tests for gate.asl"
  :x [runTests]
  :i [(gate :a g)])

(df testGateConfig [] -> Bool
  :d "Verifies make-gate-config."
  (let [(cfg (g/makeGateConfig "." 100 true false))]
    (assert (= (.-targetDir cfg) ".") "Target dir")
    (assert (= (.-tokensBaseline cfg) 100) "Baseline")
    (assert (.-strictMode cfg) "Strict mode")
    true))

(df testGateVerdict [] -> Bool
  :d "Verifies gate verdict creation."
  (let [(v (g/makeVerdict 1 "Test Gate" true "Passed test"))]
    (assert (= (.-gateNum v) 1) "Gate num")
    (assert (.-passed v) "Passed")
    true))

(df runTests [] -> Bool
  :d "Executes gate test suites."
  (do
    (assert (testGateConfig) "test-gate-config must pass")
    true))
