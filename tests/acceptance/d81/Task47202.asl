(module tests/acceptance/d81/Task47202
  :d "Acceptance fixture for Task47202: boundary check on every path including JS bridge under ADR-0081."
  :x [RunTests
      TestBoundaryCheckInFindAndGrep
      TestBoundaryCheckInJsBridge]
  :i [])

(df TestBoundaryCheckInFindAndGrep [] -> Bool
  :d "Verifies that op_find and op_grep check is_safe_path"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "if (!is_safe_path(ws_root, search_base))")
              "asl.c must check is_safe_path for find search_base")
      (assert (string-contains? c-src "if (!is_safe_path(ws_root, search_target))")
              "asl.c must check is_safe_path for grep search_target")
      true)))

(df TestBoundaryCheckInJsBridge [] -> Bool
  :d "Verifies that JS filesystem bridge checks is_safe_path"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "js_fs_is_safe")
              "asl.c must check path safety in JS fs bridge")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47202 supervisor acceptance tests"
  (do
    (assert (TestBoundaryCheckInFindAndGrep) "TestBoundaryCheckInFindAndGrep must pass")
    (assert (TestBoundaryCheckInJsBridge) "TestBoundaryCheckInJsBridge must pass")
    true))
