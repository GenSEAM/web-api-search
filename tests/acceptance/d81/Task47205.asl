(module tests/acceptance/d81/Task47205
  :d "Acceptance fixture for Task47205: error paths may not report success under ADR-0081."
  :x [RunTests
      TestWriteFileSyncRaisesOnFailure]
  :i [])

(df TestWriteFileSyncRaisesOnFailure [] -> Bool
  :d "Verifies that js_fs_writeFileSync sets an exception on fopen or write failure"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "failed to open file for writing")
              "js_fs_writeFileSync must raise an exception when fopen fails")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47205 supervisor acceptance tests"
  (do
    (assert (TestWriteFileSyncRaisesOnFailure) "TestWriteFileSyncRaisesOnFailure must pass")
    true))
