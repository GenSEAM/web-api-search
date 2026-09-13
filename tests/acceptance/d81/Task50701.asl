(module tests/acceptance/d81/Task50701
  :d "Acceptance fixture for Task 50701: WebAssembly Import Section Framing & WASI Preview 1 ABI Definition"
  :x [testWasiAbiDynamicExecution
      testWasiAbiInvariants
      testWasiDualPolarityRefutations
      RunTests]
  :i [(ast :a a) (../../../asl/packages/asl-compiler/src/wasm :a w) (../../../asl/packages/asl-compiler/src/wasi :a wasi)])

(df testWasiAbiDynamicExecution [] -> Bool
  :d "Dynamically runs the wasi_abi_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasi_abi_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasi_abi_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasi_abi_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasi_abi_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasi_abi_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasi_abi_test must not fail assertions")
    true))

(df testWasiAbiInvariants [] -> Bool
  :d "Directly verifies falsifiable WASI ABI invariants and section framing"
  (let [(e0 (wasi/wasiErrnoName 0))
        (e44 (wasi/wasiErrnoName 44))
        (entries (wasi/wasiStandardImportEntries))
        (sec (w/encodeImportSection entries))]
    (assert (= e0 "ESUCCESS") "wasiErrnoName 0 must produce ESUCCESS")
    (assert (= e44 "ENOENT") "wasiErrnoName 44 must produce ENOENT")
    (assert (= (option-or (list-get sec 0) -1) 2) "encodeImportSection must emit section ID 2")
    (refute (!= (option-or (list-get sec 0) -1) 2) "encodeImportSection ID must not deviate from 2")
    (assert (> (list-length sec) 2) "encodeImportSection must emit payload with LEB128 size")
    (let [(parsed (a/parse "(df ping [] -> I64 1)"))]
      (mt parsed
        ((ok forms)
         (let [(idxOffset (w/buildFunctionTypeIndexOffset forms 5))]
           (assert (= (option-or (map-get idxOffset "ping") -1) 5) "Function index must be offset by 5 imports")
           (refute (= (option-or (map-get idxOffset "ping") -1) 0) "Function index must not be 0 with 5 imports")
           true))
        ((err _) false)))))

(df testWasiDualPolarityRefutations [] -> Bool
  :d "Verifies dual-polarity refutations under D77"
  (let [(e8 (wasi/wasiErrnoName 8))
        (e63 (wasi/wasiErrnoName 63))
        (entry (w/encodeImportEntry "mod" "fn" 0 0))]
    (refute (= e8 "ESUCCESS") "EBADF must not map to ESUCCESS")
    (refute (= e63 "ESUCCESS") "EPERM must not map to ESUCCESS")
    (refute (= (wasi/wasiErrno "INVALID_ERRNO") 0) "Invalid errno name must not return 0")
    (refute (list-empty? entry) "encodeImportEntry must not return empty byte list")
    (assert (= (option-or (list-get entry 0) -1) 3) "First byte of entry must be module name length (3)")
    (refute (= (option-or (list-get entry 0) -1) 0) "Module name length must not be 0")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50701 acceptance tests"
  (do
    (assert (testWasiAbiDynamicExecution) "testWasiAbiDynamicExecution must pass")
    (assert (testWasiAbiInvariants) "testWasiAbiInvariants must pass")
    (assert (testWasiDualPolarityRefutations) "testWasiDualPolarityRefutations must pass")
    true))
