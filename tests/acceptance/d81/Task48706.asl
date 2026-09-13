(module tests/acceptance/d81/Task48706
  :d "Final verification test for Phase 487 (Task 48706)."
  :x [testElfHeaders]
  :i [(../../../asl/packages/asl-compiler/src/elf :a elf)])

(df testElfHeaders [] -> Bool
  :d "Verifies ELF emitter header generation."
  (let [(headers (elf/write_elf_headers 1234))]
    (assert (= (get headers :magic) "ELF_MAGIC") "Should have correct magic")
    (refute (= (get headers :e_machine) "unknown") "Should have correct machine")
    true))
