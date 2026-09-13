(module tests/acceptance/d81/Task50602
  :d "Acceptance fixture for Task 50602: WebAssembly v1 Binary Envelope & Section Framing Assembly"
  :x [testSectionFramingDynamicExecution
      testSectionFramingInvariants
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasm :a w)])

(df testSectionFramingDynamicExecution [] -> Bool
  :d "Dynamically runs the wasm_section_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasm_section_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasm_section_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasm_section_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasm_section_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasm_section_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasm_section_test must not fail assertions")
    true))

(df testSectionFramingInvariants [] -> Bool
  :d "Directly verifies WebAssembly binary envelope and section framing invariants"
  (let [(hdr (w/wasmMagicHeader))
        (typeSec (w/encodeTypeSection (list (w/encodeFuncType (list 126) (list 126)))))
        (funcSec (w/encodeFunctionSection (list 0)))
        (memSec (w/encodeMemorySection 1 256))
        (expSec (w/encodeExportSection (list (w/encodeExportEntry "main" 0 0))))
        (codeSec (w/encodeCodeSection (list (w/encodeFunctionBody (list) (list 11)))))]
    (assert (= (list-length hdr) 8) "Magic header length must be 8 bytes")
    (refute (!= (list-length hdr) 8) "Magic header must not be non-8 bytes")
    (assert (= (option-or (list-get typeSec 0) -1) 1) "Type section ID must be 1")
    (refute (= (option-or (list-get typeSec 0) -1) 0) "Type section ID must not be 0")
    (assert (= (option-or (list-get funcSec 0) -1) 3) "Function section ID must be 3")
    (refute (= (option-or (list-get funcSec 0) -1) 2) "Function section ID must not be 2")
    (assert (= (option-or (list-get memSec 0) -1) 5) "Memory section ID must be 5")
    (refute (= (option-or (list-get memSec 0) -1) 4) "Memory section ID must not be 4")
    (assert (= (option-or (list-get expSec 0) -1) 7) "Export section ID must be 7")
    (refute (= (option-or (list-get expSec 0) -1) 8) "Export section ID must not be 8")
    (assert (= (option-or (list-get codeSec 0) -1) 10) "Code section ID must be 10")
    (refute (= (option-or (list-get codeSec 0) -1) 11) "Code section ID must not be 11")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50602 acceptance tests"
  (do
    (assert (testSectionFramingDynamicExecution) "testSectionFramingDynamicExecution must pass")
    (assert (testSectionFramingInvariants) "testSectionFramingInvariants must pass")
    true))
