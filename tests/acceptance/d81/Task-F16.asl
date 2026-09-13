(module tests/acceptance/d81/Task-F16
  :d "Acceptance fixture for Task-F16: Replace Multi-Target Codegen Dummy Stubs in ASL Compiler under ADR-0081."
  :x [RunTests
      TestCompileWasmGenuineAdd
      TestCompileGoGenuineAdd
      TestCompileCGenuineAdd
      TestCompileArduinoGenuine
      TestTaskF16GroundedInPhaseFINSEL]
  :i [(asl-compiler/compiler :a comp)])

(df TestCompileWasmGenuineAdd [] -> Bool
  :d "Verifies wasm/wat target generates genuine function body from AST rather than dummy stub"
  (let [(src "(df add [(a I64) (b I64)] -> I64 (+ a b))")
        (r (comp/compile-standalone-target src "wasm" "math.asl"))]
    (assert (.-ok r) "wasm compilation must succeed")
    (assert (string-contains? (.-code r) "$add") "wasm output must contain $add function")
    (assert (string-contains? (.-code r) "i64.add") "wasm output must contain i64.add instruction from AST")
    true))

(df TestCompileGoGenuineAdd [] -> Bool
  :d "Verifies go target generates genuine function and expression lowering from AST rather than dummy stub"
  (let [(src "(df add [(a I64) (b I64)] -> I64 (+ a b))")
        (r (comp/compile-standalone-target src "go" "math.asl"))]
    (assert (.-ok r) "go compilation must succeed")
    (assert (string-contains? (.-code r) "func Add") "go output must contain func Add")
    (assert (string-contains? (.-code r) "a + b") "go output must contain binary expression lowering")
    true))

(df TestCompileCGenuineAdd [] -> Bool
  :d "Verifies c target generates genuine function definitions rather than dummy comment stub"
  (let [(src "(df add [(a I64) (b I64)] -> I64 (+ a b))")
        (r (comp/compile-standalone-target src "c" "math.asl"))]
    (assert (.-ok r) "c compilation must succeed")
    (assert (string-contains? (.-code r) "<stdint.h>") "c output must include stdint.h")
    (assert (string-contains? (.-code r) "add(void)") "c output must define add function")
    (assert (string-contains? (.-code r) "a + b") "c output must lower arithmetic body expression")
    (assert (not (string-contains? (.-code r) "/* ASL Embedded C Target */")) "c output must not be dummy stub")
    true))

(df TestCompileArduinoGenuine [] -> Bool
  :d "Verifies arduino target generates genuine Arduino sketch and functions"
  (let [(src "(df blink [] -> Unit ())")
        (r (comp/compile-standalone-target src "arduino" "blink.asl"))]
    (assert (.-ok r) "arduino compilation must succeed")
    (assert (string-contains? (.-code r) "<Arduino.h>") "arduino output must include Arduino.h")
    (assert (string-contains? (.-code r) "blink") "arduino output must declare blink function")
    (assert (not (string-contains? (.-code r) "/* ASL Embedded C Target */")) "arduino output must not be dummy stub")
    true))

(df TestTaskF16GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F16 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F16\"") "Must declare Task-F16")
      (assert (string-contains? f-src "asl/packages/asl-compiler/src/compiler.asl") "Must own compiler.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F16 acceptance checks"
  (do
    (assert (TestCompileWasmGenuineAdd) "TestCompileWasmGenuineAdd must pass")
    (assert (TestCompileGoGenuineAdd) "TestCompileGoGenuineAdd must pass")
    (assert (TestCompileCGenuineAdd) "TestCompileCGenuineAdd must pass")
    (assert (TestCompileArduinoGenuine) "TestCompileArduinoGenuine must pass")
    (assert (TestTaskF16GroundedInPhaseFINSEL) "TestTaskF16GroundedInPhaseFINSEL must pass")
    true))
