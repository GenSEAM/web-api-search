(module tests/acceptance/d81/Task50601
  :d "Acceptance fixture for Task 50601: Pure ASL Byte Vector Primitives & LEB128 Integer Encoders"
  :x [testLeb128DynamicExecution
      testLeb128Invariants
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasm :a w)])

(df testLeb128DynamicExecution [] -> Bool
  :d "Dynamically runs the wasm_leb128_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasm_leb128_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasm_leb128_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasm_leb128_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasm_leb128_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasm_leb128_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasm_leb128_test must not fail assertions")
    true))

(df testLeb128Invariants [] -> Bool
  :d "Directly verifies falsifiable LEB128 invariants and dual-polarity bounds"
  (let [(u0 (w/leb128EncodeU32 0))
        (uBig (w/leb128EncodeU32 624485))
        (iNeg1 (w/leb128EncodeI32 -1))
        (iNeg128 (w/leb128EncodeI32 -128))]
    (assert (= u0 (list 0)) "leb128EncodeU32 0 must produce [0]")
    (refute (list-empty? u0) "leb128EncodeU32 0 must not be empty")
    (refute (= (option-or (list-get u0 0) -1) 128) "Single-byte 0 must not set continuation bit")
    (assert (= uBig (list 229 142 38)) "leb128EncodeU32 624485 must produce [229 142 38]")
    (refute (= (list-length uBig) 2) "leb128EncodeU32 624485 must not fit in 2 bytes")
    (assert (= iNeg1 (list 127)) "leb128EncodeI32 -1 must produce [127]")
    (refute (= iNeg1 (list 255)) "leb128EncodeI32 -1 must not produce [255]")
    (assert (= iNeg128 (list 128 127)) "leb128EncodeI32 -128 must produce [128 127]")
    (refute (= (list-length iNeg128) 1) "leb128EncodeI32 -128 cannot fit in single byte")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50601 acceptance tests"
  (do
    (assert (testLeb128DynamicExecution) "testLeb128DynamicExecution must pass")
    (assert (testLeb128Invariants) "testLeb128Invariants must pass")
    true))
