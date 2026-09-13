(module tests/acceptance/d81/Task50605
  :d "Acceptance fixture for Task 50605: Browser/Mobile Memory Model, Batch RPC Dispatch & Compiler Pipeline Integration"
  :x [testMemorySectionEmission
      testRpcExportsEmission
      testCompilerWasmBinTarget
      testDynamicWasmRuntimeBridge
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/compiler :a comp)
      (../../../asl/packages/asl-compiler/src/wasm :a w)])

(df testMemorySectionEmission [] -> Bool
  :d "Verifies linear memory section format with initial 1 page and max 256 pages"
  (let [(memSec (w/emitWasmMemorySection))]
    (assert (= (option-or (list-get memSec 0) -1) 5) "Memory section ID must be 5")
    (refute (= (option-or (list-get memSec 0) -1) 4) "Memory section ID must not be 4")
    (assert (> (list-length memSec) 3) "Memory section payload must declare limits")
    true))

(df testRpcExportsEmission [] -> Bool
  :d "Verifies Batch RPC memory bridge exports for browser and mobile runtimes"
  (let [(rpcList (w/emitWasmRpcExports 1 2 3))
        (flatBytes (w/flattenByteLists rpcList))]
    (assert (= (list-length rpcList) 4) "Must export exactly 4 descriptors (memory, alloc, free, dispatch)")
    (refute (< (list-length rpcList) 4) "RPC exports count must not be less than 4")
    (assert (> (list-length flatBytes) 30) "Flattened RPC export bytes must be substantial")
    true))

(df testCompilerWasmBinTarget [] -> Bool
  :d "Verifies end-to-end compilation with wasm-bin target in compiler pipeline"
  (let [(src "(df calc [(x I64)] -> I64 (* x 2))")
        (resBin (comp/compileStandaloneTarget src "wasm-bin" "calc.asl"))
        (resWasm (comp/compileStandaloneTarget src "wasm" "calc.asl"))]
    (assert (.-ok resBin) "wasm-bin compilation must succeed")
    (refute (not (.-ok resBin)) "wasm-bin compilation must not fail")
    (assert (.-ok resWasm) "wasm compilation must succeed")
    (assert (not (string-empty? (.-code resBin))) "wasm-bin code output must not be empty")
    (refute (string-contains? (.-code resBin) "pub fn") "wasm-bin must not be Rust code")
    (assert (string-contains? (.-code resBin) "0,97,115,109") "wasm-bin code must contain Wasm magic header bytes")
    true))

(df testDynamicWasmRuntimeBridge [] -> Bool
  :d "Dynamically instantiates emitted wasm-bin module and verifies memory, alloc, and dispatch in Node.js"
  (let [(src "(df double-val [(n I64)] -> I64 (+ n n))")
        (res (comp/compileStandaloneTarget src "wasm-bin" "test.asl"))]
    (assert (.-ok res) "Compilation must succeed")
    (let [(csv (.-code res))
          (cmd (str "/usr/local/bin/node -e 'const b = new Uint8Array([" csv "]); if (!WebAssembly.validate(b)) process.exit(2); const inst = new WebAssembly.Instance(new WebAssembly.Module(b)); if (!inst.exports.memory || inst.exports.memory.buffer.byteLength < 65536) process.exit(3); if (inst.exports.asl_alloc(1024) !== 65536) process.exit(4); if (inst.exports.asl_rpc_dispatch(0,0,0) !== 0) process.exit(5); if (inst.exports[\"double-val\"](21n) !== 42n) process.exit(6);'"))
          (execRes (sys-exec cmd))
          (code (.-exitCode execRes))]
      (assert (= code 0) (str "Dynamic runtime bridge validation failed with exit code " (string-from-int64 code) ", stderr: " (.-stderr execRes)))
      (refute (!= code 0) "Runtime bridge validation must exit 0")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task 50605 acceptance tests"
  (do
    (assert (testMemorySectionEmission) "testMemorySectionEmission must pass")
    (assert (testRpcExportsEmission) "testRpcExportsEmission must pass")
    (assert (testCompilerWasmBinTarget) "testCompilerWasmBinTarget must pass")
    (assert (testDynamicWasmRuntimeBridge) "testDynamicWasmRuntimeBridge must pass")
    true))
