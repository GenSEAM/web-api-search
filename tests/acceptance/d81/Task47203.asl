(module tests/acceptance/d81/Task47203
  :d "Acceptance fixture for Task47203: path resolution before comparison and safe directory recursion under ADR-0081."
  :x [RunTests
      TestIsSafePathResolvesSymlinks
      TestWalkDirUsesLstat]
  :i [])

(df TestIsSafePathResolvesSymlinks [] -> Bool
  :d "Verifies that is_safe_path in asl/tools/asl.c checks realpath of targets"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "realpath(full, real_f)")
              "is_safe_path must resolve realpath of target path")
      true)))

(df TestWalkDirUsesLstat [] -> Bool
  :d "Verifies that walk_dir_recursive uses lstat to prevent following unbounded directory symlinks"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "lstat(full_entry, &st)")
              "walk_dir_recursive must use lstat rather than stat to avoid following symlinks")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47203 supervisor acceptance tests"
  (do
    (assert (TestIsSafePathResolvesSymlinks) "TestIsSafePathResolvesSymlinks must pass")
    (assert (TestWalkDirUsesLstat) "TestWalkDirUsesLstat must pass")
    true))
