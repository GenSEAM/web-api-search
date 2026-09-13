(module tests/acceptance/d81/Task48704
  :d "Acceptance fixture for Task48704: Linux ELF64 Binary Emitter in Pure ASL under D86."
  :x [run-tests
      test-elf-emitter-exists
      test-elf-target-symbols
      test-elf-header-generation]
  :i [])

(df test-elf-emitter-exists [] -> Bool
  :d "Verifies that asl/packages/asl-compiler/src/elf.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-compiler/src/elf.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-compiler/src/elf.asl must exist")
    true))

(df test-elf-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in elf.asl"
  (let [(res (file-read "asl/packages/asl-compiler/src/elf.asl"))]
    (assert (= (.-_tag res) "ok") "elf.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "emit_elf64") "emit_elf64 defined")
      (assert (string-contains? src "write_elf_headers") "write_elf_headers defined")
      (assert (string-contains? src "elf_sections") "elf_sections defined")
      (assert (string-contains? src "sysv_abi") "sysv_abi defined")
      true)))

(df test-elf-header-generation [] -> Bool
  :d "Verifies that elf.asl implements ELF64 magic and header layout"
  (let [(res (file-read "asl/packages/asl-compiler/src/elf.asl"))]
    (assert (= (.-_tag res) "ok") "elf.asl readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-compiler/elf") "module declared")
      (assert (string-contains? src "ELF_MAGIC") "ELF magic present")
      (assert (string-contains? src "EM_X86_64") "x86_64 machine type present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48704 acceptance assertions"
  (let [(r1 (test-elf-emitter-exists))
        (r2 (test-elf-target-symbols))
        (r3 (test-elf-header-generation))]
    (assert (and (and r1 r2) r3) "All Task48704 checks must pass")
    true))
