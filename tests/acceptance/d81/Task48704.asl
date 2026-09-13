(module tests/acceptance/d81/Task48704
  :d "Test compiler toolchain structure for Phase 487 (Task 48704)."
  :x [testCompilerTools]
  :i [(../../../asl/packages/asl-compiler/src/parser :a parser)
      (../../../asl/packages/asl-compiler/src/macho :a macho)])

(df testCompilerTools [] -> Bool
  :d "Verifies the integration of parser and emitter modules"
  (let [(ast (parser/parse_asl_source "(df x [] 1)"))
        (bin (macho/emit_macho_arm64 (list ast)))]
    (assert (= (get ast :valid) true) "Should be valid AST")
    (assert (= (get bin :target) "darwin-arm64") "Should have correct target")
    (refute (= (get ast :pipeline) "stub") "Should not be a vacuous stub")
    true))
