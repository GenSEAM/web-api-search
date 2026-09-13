(module tests/acceptance/d81/Task50702
  :d "Acceptance fixture for Task 50702: Pure ASL WASI File I/O Primitives & Vectorized Descriptors"
  :x [testWasiIoDynamicExecution
      testWasiIoInvariants
      testWasiIoDualPolarityRefutations
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasi :a wasi)])

(df testWasiIoDynamicExecution [] -> Bool
  :d "Dynamically runs the wasi_io_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasi_io_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasi_io_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasi_io_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasi_io_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasi_io_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasi_io_test must not fail assertions")
    true))

(df testWasiIoInvariants [] -> Bool
  :d "Directly verifies falsifiable WASI I/O invariants and roundtrip behavior"
  (let [(vec (wasi/encodeCiovec 65536 10))
        (path "/tmp/test_task50702_roundtrip.txt")
        (content "Sovereign WASI File I/O Content 12345\n")
        (writeRes (wasi/wasiFileWrite path content))]
    (assert (= (list-length vec) 8) "encodeCiovec must produce strictly 8 bytes")
    (refute (!= (list-length vec) 8) "Vector length must be 8")
    (assert (= (.-_tag writeRes) "ok") "wasiFileWrite must succeed")
    (let [(readRes (wasi/wasiFileRead path))]
      (mt readRes
        ((ok text)
         (do
           (assert (= text content) "wasiFileRead text must match written content")
           (refute (!= text content) "Roundtrip content must not differ")
           true))
        ((err _) false)))))

(df testWasiIoDualPolarityRefutations [] -> Bool
  :d "Verifies dual-polarity refutations under D77"
  (let [(missingPath "/tmp/non_existent_file_acceptance_50702.txt")
        (openRes (wasi/wasiPathOpen 3 missingPath 0))
        (fdWriteNeg (wasi/wasiFdWrite -1 "hello"))
        (fdWriteClosed (wasi/wasiFdWrite 99 "hello"))]
    (assert (not (wasi/wasiFileExists? missingPath)) "Missing file must not exist")
    (refute (wasi/wasiFileExists? missingPath) "wasiFileExists? must return false for missing path")
    (assert (= (.-_tag openRes) "err") "Opening non-existent path without O_CREAT must return error")
    (refute (= (.-_tag openRes) "ok") "Opening non-existent path without O_CREAT must not succeed")
    (mt openRes
      ((ok _) false)
      ((err code) (assert (= code "ENOENT") "Open error code must be ENOENT")))
    (assert (= (.-_tag fdWriteNeg) "err") "Writing to negative fd must return error")
    (refute (= (.-_tag fdWriteNeg) "ok") "Negative fd must not succeed")
    (assert (= (.-_tag fdWriteClosed) "err") "Writing to closed fd 99 must return error")
    (refute (= (.-_tag fdWriteClosed) "ok") "Closed fd must not succeed")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50702 acceptance tests"
  (do
    (assert (testWasiIoDynamicExecution) "testWasiIoDynamicExecution must pass")
    (assert (testWasiIoInvariants) "testWasiIoInvariants must pass")
    (assert (testWasiIoDualPolarityRefutations) "testWasiIoDualPolarityRefutations must pass")
    true))
