(module tests/acceptance/d81/Task48702
  :d "Test real Mach-O output structure for Phase 487 (Task 48702)."
  :x [testMachoOutput]
  :i [(../../../asl/packages/asl-compiler/src/macho :a macho)])

(df testMachoOutput [] -> Bool
  :d "Verifies the structure returned by emit_macho_arm64."
  (let [(res (macho/emit_macho_arm64 (list)))]
    (assert (= (get res :target) "darwin-arm64") "Mach-O emitter should target darwin-arm64")
    (refute (= (get res :status) :error) "Status must not be error")
    true))
