(module tests/acceptance/d81/Task50603
  :d "Acceptance fixture for Task 50603: Pure ASL WebAssembly MVP Opcode Matrix & Instruction Assembly"
  :x [testOpcodesDynamicExecution
      testInstructionMatrixInvariants
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasm :a w)])

(df testOpcodesDynamicExecution [] -> Bool
  :d "Dynamically runs the wasm_opcodes_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasm_opcodes_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasm_opcodes_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasm_opcodes_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasm_opcodes_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasm_opcodes_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasm_opcodes_test must not fail assertions")
    true))

(df testInstructionMatrixInvariants [] -> Bool
  :d "Directly verifies WebAssembly MVP opcode matrix and instruction assembly invariants"
  (let [(cCall (w/wasmOpcode "call"))
        (cAdd (w/wasmOpcode "i64.add"))
        (instrConst32 (w/emitInstrConstI32 42))
        (instrConst64 (w/emitInstrConstI64 42))
        (instrGet (w/emitInstrLocalGet 0))
        (instrSet (w/emitInstrLocalSet 1))
        (instrCall (w/emitInstrCall 2))
        (instrOp32 (w/emitInstrBinaryOp "+" "i32"))
        (instrOp64 (w/emitInstrBinaryOp "+" "i64"))
        (instrIf (w/emitInstrIf 126 (w/emitInstrConstI64 42) (w/emitInstrConstI64 50)))]
    (assert (= cCall 16) "call opcode must be 16")
    (assert (= cAdd 124) "i64.add opcode must be 124")
    (refute (= cAdd 106) "i64.add opcode must not be 32-bit 106")
    (assert (= instrConst32 (list 65 42)) "emitInstrConstI32 42 must be [65 42]")
    (assert (= instrConst64 (list 66 42)) "emitInstrConstI64 42 must be [66 42]")
    (assert (= instrGet (list 32 0)) "emitInstrLocalGet 0 must be [32 0]")
    (assert (= instrSet (list 33 1)) "emitInstrLocalSet 1 must be [33 1]")
    (assert (= instrCall (list 16 2)) "emitInstrCall 2 must be [16 2]")
    (assert (= instrOp32 (list 106)) "emitInstrBinaryOp + i32 must be [106]")
    (assert (= instrOp64 (list 124)) "emitInstrBinaryOp + i64 must be [124]")
    (refute (= instrOp64 (list 106)) "emitInstrBinaryOp + i64 must not be [106]")
    (assert (= instrIf (list 4 126 66 42 5 66 50 11)) "emitInstrIf structure must match spec")
    (refute (= (list-length instrIf) 0) "emitInstrIf must not be empty")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50603 acceptance tests"
  (do
    (assert (testOpcodesDynamicExecution) "testOpcodesDynamicExecution must pass")
    (assert (testInstructionMatrixInvariants) "testInstructionMatrixInvariants must pass")
    true))
