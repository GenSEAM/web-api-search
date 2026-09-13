(module tests/acceptance/d81/Task50104
  :d "Acceptance fixture for Task 50104: Syscall Builtin Conformance Suite"
  :x [testSyscallConformance RunTests]
  :i [])

(df testSyscallConformance [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify tests/conformance/syscalls/os_syscalls_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))
        (err (.-stderr res))]
    (assert (= code 0) (str "os_syscalls_test.asl passes cleanly, stdout=" out " stderr=" err))
    (refute (!= code 0) "os_syscalls_test.asl must exit 0")
    (assert (string-contains? out "assertion(s) executed") "assertions were executed")
    (refute (string-contains? out "0 assertion(s) executed") "assertions executed must be non-zero")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testSyscallConformance) "testSyscallConformance passes")
    true))
