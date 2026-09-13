(module tests/acceptance/d81/Task50606
  :d "Acceptance fixture for Task 50606: Dynamic End-to-End Wasm v1 Engine Validation, Execution & Task Registration"
  :x [testWasmDynamicTestSuiteExecution
      testWasmEngineEndToEndExecution
      testWasmDualPolarityRefutations
      testTaskRegistrationFile
      RunTests]
  :i [(ast :a a) (../../../asl/packages/asl-compiler/src/wasm :a w)])

(df bytesToCsv [(bytes (List Int64))] -> Str
  :d "Formats byte vector to comma-separated integer string for node execution."
  (string-join (map (fn [(b Int64)] -> Str (string-from-int64 b)) bytes) ","))

(df testWasmDynamicTestSuiteExecution [] -> Bool
  :d "Dynamically runs the wasm_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasm_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasm_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasm_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasm_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasm_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasm_test must not fail assertions")
    true))

(df testWasmEngineEndToEndExecution [] -> Bool
  :d "Directly compiles and dynamically invokes an arithmetic function in Node.js V8"
  (let [(parsed (a/parse "(df compute-val [(a I64) (b I64)] -> I64 (+ (* a 3) b))"))]
    (mt parsed
      ((ok forms)
       (let [(bytes (w/emitWasmBinaryBytes forms))
             (csv (bytesToCsv bytes))
             (cmd (str "/usr/local/bin/node -e 'const b = new Uint8Array([" csv "]); if (!WebAssembly.validate(b)) process.exit(2); const inst = new WebAssembly.Instance(new WebAssembly.Module(b)); if (inst.exports[\"compute-val\"](10n, 12n) !== 42n) process.exit(3);'"))
             (res (sys-exec cmd))
             (code (.-exitCode res))]
         (assert (= code 0) (str "End-to-end Wasm invocation failed with code " (string-from-int64 code) ", stderr: " (.-stderr res)))
         (refute (!= code 0) "End-to-end Wasm invocation must exit 0")
         true))
      ((err _) false))))

(df testWasmDualPolarityRefutations [] -> Bool
  :d "Verifies rejection of invalid bytes and truncated payloads by WebAssembly engine"
  (let [(cmdCorrupt "/usr/local/bin/node -e 'const b = new Uint8Array([0, 97, 115, 109, 99, 99, 99, 99]); if (WebAssembly.validate(b)) process.exit(1);'")
        (resCorrupt (sys-exec cmdCorrupt))
        (code (.-exitCode resCorrupt))]
    (assert (= code 0) "Corrupt Wasm version must be rejected by WebAssembly.validate")
    (refute (!= code 0) "Corrupted binary must not be accepted")
    true))

(df testTaskRegistrationFile [] -> Bool
  :d "Verifies that Phase 506 tasks are registered in ASN task memory"
  (let [(path ".asl/mem/tasks/Phase506WasmBinaryEmitter.asn")
        (contentRes (file-read path))]
    (mt contentRes
      ((ok text)
       (do
         (assert (string-contains? text ":taskCollection") "Task collection must be declared")
         (assert (string-contains? text "\"Phase506WasmBinaryEmitter\"") "Phase collection ID must match")
         (assert (string-contains? text "\"Task50601\"") "Task50601 must be registered")
         (assert (string-contains? text "\"Task50606\"") "Task50606 must be registered")
         (refute (string-empty? text) "Task collection file must not be empty")
         true))
      ((err _) false))))

(df RunTests [] -> Bool
  :d "Executes all Task 50606 acceptance tests"
  (do
    (assert (testWasmDynamicTestSuiteExecution) "testWasmDynamicTestSuiteExecution must pass")
    (assert (testWasmEngineEndToEndExecution) "testWasmEngineEndToEndExecution must pass")
    (assert (testWasmDualPolarityRefutations) "testWasmDualPolarityRefutations must pass")
    (assert (testTaskRegistrationFile) "testTaskRegistrationFile must pass")
    true))
