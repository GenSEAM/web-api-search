(module tests/acceptance/d81/Task50102
  :d "Acceptance fixture for Task 50102: Native C POSIX Syscall Bridge in asl/tools/asl.c"
  :x [testSyscallBindings RunTests]
  :i [])

(df testSyscallBindings [] -> Bool
  (let [(res (sys-exec "bin/asl eval --check-c-bindings"))
        (code (.-exitCode res))
        (out (.-stdout res))
        (err (.-stderr res))]
    (assert (= code 0) (str "eval --check-c-bindings exits 0, stdout=" out " stderr=" err))
    (refute (!= code 0) "eval --check-c-bindings must not fail")
    (assert (string-contains? out "__sys_dirList") "stdout contains __sys_dirList binding")
    (refute (not (string-contains? out "__sys_dirList")) "__sys_dirList must be present")
    (assert (string-contains? out "__sys_execCmd") "stdout contains __sys_execCmd binding")
    (refute (not (string-contains? out "__sys_execCmd")) "__sys_execCmd must be present")
    (assert (string-contains? out "__sys_fileStat") "stdout contains __sys_fileStat binding")
    (refute (not (string-contains? out "__sys_fileStat")) "__sys_fileStat must be present")
    (assert (string-contains? out "__sys_pathCanonicalize") "stdout contains __sys_pathCanonicalize binding")
    (refute (not (string-contains? out "__sys_pathCanonicalize")) "__sys_pathCanonicalize must be present")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testSyscallBindings) "testSyscallBindings passes")
    true))
