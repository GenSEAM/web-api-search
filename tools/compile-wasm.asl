(module asl-tools/compile-wasm
  :d "CLI driver compiling pure ASL sources into WebAssembly bytecode via asl-compiler/wasm."
  :x [main]
  :i [(ast :a a) (wasm :a w)])

(df main [] -> Bool
  (let [(readRes (file-read "asl/packages/asl-eval/src/eval.asl"))]
    (if (!= (.-_tag readRes) "ok")
      false
      (let [(src (.-value readRes))
            (parsed (a/parse src))]
        (mt parsed
          ((ok forms)
           (let [(csv (w/emitWasmBinaryTarget forms))]
             (println csv)
             true))
          ((err _) false))))))
