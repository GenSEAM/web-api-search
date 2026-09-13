(module tests/acceptance/d81/Task50604
  :d "Acceptance fixture for Task 50604: ASL AST Lowering to WebAssembly MVP Bytecode & Function Bodies"
  :x [testCodegenDynamicExecution
      testLoweringInvariants
      RunTests]
  :i [(ast :a a) (../../../asl/packages/asl-compiler/src/wasm :a w)])

(df testCodegenDynamicExecution [] -> Bool
  :d "Dynamically runs the wasm_codegen_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasm_codegen_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasm_codegen_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasm_codegen_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasm_codegen_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasm_codegen_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasm_codegen_test must not fail assertions")
    true))

(df testLoweringInvariants [] -> Bool
  :d "Directly verifies AST lowering functions, type index map, and bytecode emission invariants"
  (let [(src "(df sub [(x I64) (y I64)] -> I64 (- x y))")
        (parsed (a/parse src))]
    (mt parsed
      ((ok forms)
       (let [(idxMap (w/buildFunctionTypeIndex forms))
             (fnNode (option-or (list-head (fold (fn [(acc (List a/DefunNode)) (f a/TopForm)]
                                                   (mt f ((topDefun d) (list-append acc (list d))) (:else acc)))
                                                 (list)
                                                 forms))
                               (a/DefunNode :name "" :typeVars (list) :isExported false :effect false :params (list) :retType "I64" :docstring "" :body (list))))
             (fnBody (w/lowerAstFunction fnNode idxMap))
             (modBytes (w/lowerAstTopForms forms))
             (hdr (w/wasmMagicHeader))]
         (assert (= (option-or (map-get idxMap "sub") -1) 0) "sub function index must be 0")
         (refute (= (option-or (map-get idxMap "sub") -1) -1) "sub function index must be present in map")
         (assert (> (list-length fnBody) 5) "lowerAstFunction must emit non-empty body")
         (assert (= (option-or (list-slice modBytes 0 8) (list)) hdr) "Module must start with Wasm magic header")
         (refute (list-empty? modBytes) "Module bytecode must not be empty")
         (assert (> (list-length modBytes) 25) "Module bytecode length must exceed header + section overhead")
         true))
      ((err _) false))))

(df RunTests [] -> Bool
  :d "Executes all Task 50604 acceptance tests"
  (do
    (assert (testCodegenDynamicExecution) "testCodegenDynamicExecution must pass")
    (assert (testLoweringInvariants) "testLoweringInvariants must pass")
    true))
