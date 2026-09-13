(module phase488/task1 :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm run test.wasm"))]
    (assert (= (.-exitCode res) 0) (str "WASM run should succeed, but exitCode=" (.-exitCode res) " stdout=" (.-stdout res) " stderr=" (.-stderr res)))
    (assert (string-contains? (.-stdout res) ":action :run") "Output must indicate wasm run")
    (refute (string-contains? (.-stdout res) "Error") "No error")
    true))
