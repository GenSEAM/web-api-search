(module tests/acceptance/d81/Task50101
  :d "Acceptance fixture for Task 50101: OS Syscall Prelude & Checker Signatures"
  :x [testTypesDynamicExecution testResolveDynamicExecution testPreludeDynamicRegistry RunTests]
  :i [])

(df testTypesDynamicExecution [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-checker/tests/types_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "asl-checker types_test passes cleanly")
    (refute (!= code 0) "asl-checker types_test must exit 0")
    (assert (string-contains? out "assertion(s) executed") "types_test executed assertions")
    (refute (string-contains? out "0 assertion(s) executed") "types_test assertions must not be 0")
    true))

(df testResolveDynamicExecution [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-checker/tests/resolve_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "asl-checker resolve_test passes cleanly")
    (refute (!= code 0) "asl-checker resolve_test must exit 0")
    (assert (string-contains? out "assertion(s) executed") "resolve_test executed assertions")
    (refute (string-contains? out "0 assertion(s) executed") "resolve_test assertions must not be 0")
    true))

(df testPreludeDynamicRegistry [] -> Bool
  (let [(resSymbols (sys-exec "grep -E '\"dirList\"|\"execCmd\"|\"fileStat\"|\"pathCanonicalize\"' asl/prelude/prelude.asn"))
        (codeSymbols (.-exitCode resSymbols))
        (outSymbols (.-stdout resSymbols))]
    (assert (= codeSymbols 0) "prelude.asn contains all 4 syscall symbol names")
    (refute (!= codeSymbols 0) "prelude.asn must declare syscall builtins")
    (assert (string-contains? outSymbols "dirList") "prelude contains dirList")
    (refute (not (string-contains? outSymbols "dirList")) "dirList must be declared in prelude")
    (assert (string-contains? outSymbols "execCmd") "prelude contains execCmd")
    (refute (not (string-contains? outSymbols "execCmd")) "execCmd must be declared in prelude")
    (assert (string-contains? outSymbols "fileStat") "prelude contains fileStat")
    (refute (not (string-contains? outSymbols "fileStat")) "fileStat must be declared in prelude")
    (assert (string-contains? outSymbols "pathCanonicalize") "prelude contains pathCanonicalize")
    (refute (not (string-contains? outSymbols "pathCanonicalize")) "pathCanonicalize must be declared in prelude")

    (let [(resTypes (sys-exec "grep -A 2 -E ':name \"(dirList|execCmd|fileStat|pathCanonicalize)\"' asl/prelude/prelude.asn"))
          (outTypes (.-stdout resTypes))]
      (assert (string-contains? outTypes "(Result (List String) IoError)") "prelude has dirList signature")
      (refute (not (string-contains? outTypes "(Result (List String) IoError)")) "dirList signature must match")
      (assert (string-contains? outTypes "ProcessOutput") "prelude has execCmd signature")
      (refute (not (string-contains? outTypes "ProcessOutput")) "execCmd signature must match")
      (assert (string-contains? outTypes "(Result FileStat IoError)") "prelude has fileStat signature")
      (refute (not (string-contains? outTypes "(Result FileStat IoError)")) "fileStat signature must match")
      (assert (string-contains? outTypes "(Result String IoError)") "prelude has pathCanonicalize signature")
      (refute (not (string-contains? outTypes "(Result String IoError)")) "pathCanonicalize signature must match")
      true)))

(df RunTests [] -> Bool
  (do
    (assert (testTypesDynamicExecution) "testTypesDynamicExecution passes")
    (assert (testResolveDynamicExecution) "testResolveDynamicExecution passes")
    (assert (testPreludeDynamicRegistry) "testPreludeDynamicRegistry passes")
    true))
