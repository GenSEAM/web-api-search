(module tests/acceptance/d81/Task48703
  :d "Acceptance fixture for Task48703: Mach-O ARM64 Binary Emitter in Pure ASL under D86."
  :x [run-tests
      test-macho-emitter-exists
      test-macho-target-symbols
      test-macho-header-generation]
  :i [])

(df test-macho-emitter-exists [] -> Bool
  :d "Verifies that asl/packages/asl-compiler/src/macho.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-compiler/src/macho.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-compiler/src/macho.asl must exist")
    true))

(df test-macho-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in macho.asl"
  (let [(res (file-read "asl/packages/asl-compiler/src/macho.asl"))]
    (assert (= (.-_tag res) "ok") "macho.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "emit_macho_arm64") "emit_macho_arm64 defined")
      (assert (string-contains? src "write_macho_headers") "write_macho_headers defined")
      (assert (string-contains? src "arm64_instructions") "arm64_instructions defined")
      (assert (string-contains? src "macho_sections") "macho_sections defined")
      true)))

(df test-macho-header-generation [] -> Bool
  :d "Verifies that macho.asl implements Mach-O 64-bit header generation"
  (let [(res (file-read "asl/packages/asl-compiler/src/macho.asl"))]
    (assert (= (.-_tag res) "ok") "macho.asl readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-compiler/macho") "module declared")
      (assert (string-contains? src "MH_MAGIC_64") "Mach-O 64-bit magic present")
      (assert (string-contains? src "CPU_TYPE_ARM64") "ARM64 CPU type present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48703 acceptance assertions"
  (let [(r1 (test-macho-emitter-exists))
        (r2 (test-macho-target-symbols))
        (r3 (test-macho-header-generation))]
    (assert (and (and r1 r2) r3) "All Task48703 checks must pass")
    true))
