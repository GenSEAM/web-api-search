(module tests/acceptance/d81/Task48504
  :d "Acceptance fixture for Task48504: Native Wrapper Scaffolding for bin/addie and bin/eddie under D84."
  :x [run-tests
      test-forwarder-files-exist
      test-forwarder-content-and-symbols
      test-forwarder-execution]
  :i [])

(df test-forwarder-files-exist [] -> Bool
  :d "Verifies that bin/addie and bin/eddie exist as executable forwarder files"
  (let [(res-addie (file-read "bin/addie"))
        (res-eddie (file-read "bin/eddie"))]
    (assert (= (.-_tag res-addie) "ok") "bin/addie must exist and be readable")
    (assert (= (.-_tag res-eddie) "ok") "bin/eddie must exist and be readable")
    true))

(df test-forwarder-content-and-symbols [] -> Bool
  :d "Verifies that bin/addie and bin/eddie forward to bin/asl with appropriate client channels"
  (let [(res-addie (file-read "bin/addie"))
        (res-eddie (file-read "bin/eddie"))]
    (assert (= (.-_tag res-addie) "ok") "bin/addie must be readable")
    (assert (= (.-_tag res-eddie) "ok") "bin/eddie must be readable")
    (let [(src-addie (.-value res-addie))
          (src-eddie (.-value res-eddie))]
      (assert (string-contains? src-addie "bin/asl") "bin/addie forwards to bin/asl")
      (assert (string-contains? src-addie "addie_wrapper") "bin/addie declares addie_wrapper")
      (assert (string-contains? src-eddie "bin/asl") "bin/eddie forwards to bin/asl")
      (assert (string-contains? src-eddie "eddie_wrapper") "bin/eddie declares eddie_wrapper")
      true)))

(df test-forwarder-execution [] -> Bool
  :d "Verifies that forwarders run and emit clean output when invoked"
  (let [(res-addie (file-read "bin/addie"))
        (res-eddie (file-read "bin/eddie"))]
    (assert (= (.-_tag res-addie) "ok") "addie exists")
    (assert (= (.-_tag res-eddie) "ok") "eddie exists")
    (let [(src-addie (.-value res-addie))
          (src-eddie (.-value res-eddie))]
      (assert (string-contains? src-addie "#!/bin/sh") "bin/addie has sh shebang")
      (assert (string-contains? src-eddie "#!/bin/sh") "bin/eddie has sh shebang")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48504 acceptance assertions"
  (let [(r1 (test-forwarder-files-exist))
        (r2 (test-forwarder-content-and-symbols))
        (r3 (test-forwarder-execution))]
    (assert (and (and r1 r2) r3) "All Task48504 checks must pass")
    true))
