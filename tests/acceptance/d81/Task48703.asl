(module tests/acceptance/d81/Task48703
  :d "Test real ELF output structure for Phase 487 (Task 48703)."
  :x [testElfOutput]
  :i [(../../../asl/packages/asl-compiler/src/elf :a elf)])

(df testElfOutput [] -> Bool
  :d "Verifies the structure returned by emit_elf64."
  (let [(res (elf/emit_elf64 (list)))]
    (assert (= (get res :target) "linux-x86_64") "ELF emitter should target linux-x86_64")
    (refute (= (get res :status) :error) "Status must not be error")
    true))
