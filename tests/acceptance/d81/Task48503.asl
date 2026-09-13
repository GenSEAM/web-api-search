(module tests/acceptance/d81/Task48503
  :d "Acceptance fixture for Task48503: Deterministic Multi-Client Path Resolver under D84."
  :x [run-tests
      test-resolver-symbols-implemented
      test-path-search-and-manifest-declared
      test-cursor-and-windsurf-resolution-supported]
  :i [])

(df test-resolver-symbols-implemented [] -> Bool
  :d "Verifies that resolve_client_binary and find_executable_path are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "resolve_client_binary") "resolve_client_binary implemented")
      (assert (string-contains? src "find_executable_path") "find_executable_path implemented")
      true)))

(df test-path-search-and-manifest-declared [] -> Bool
  :d "Verifies that path_search and client_manifest concepts are declared in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "path_search") "path_search declared")
      (assert (string-contains? src "client_manifest") "client_manifest declared")
      true)))

(df test-cursor-and-windsurf-resolution-supported [] -> Bool
  :d "Verifies that cursor and windsurf client resolution paths are defined in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(client, \"cursor\") == 0") "cursor client handled")
      (assert (string-contains? src "strcmp(client, \"windsurf\") == 0") "windsurf client handled")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48503 acceptance assertions"
  (let [(r1 (test-resolver-symbols-implemented))
        (r2 (test-path-search-and-manifest-declared))
        (r3 (test-cursor-and-windsurf-resolution-supported))]
    (assert (and (and r1 r2) r3) "All Task48503 checks must pass")
    true))
