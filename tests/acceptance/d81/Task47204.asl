(module tests/acceptance/d81/Task47204
  :d "Acceptance fixture for Task47204: memory bounds and safe allocations under ADR-0081."
  :x [RunTests
      TestEvalArgBoundsInAslC
      TestSbGrowSafeReallocInAslC]
  :i [])

(df TestEvalArgBoundsInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c does not use fixed 16-element stack array for eval args"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (not (string-contains? c-src "char *ev_args[16];"))
              "asl.c must not use fixed 16-element ev_args stack buffer")
      (assert (string-contains? c-src "char **ev_args = (char **)malloc")
              "asl.c must dynamically allocate ev_args based on argc")
      (assert (string-contains? c-src "free(ev_args);")
              "asl.c must free dynamically allocated ev_args")
      true)))

(df TestSbGrowSafeReallocInAslC [] -> Bool
  :d "Verifies that sb_grow returns status and sb_append_len guards against allocation failure"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "static int sb_grow")
              "sb_grow must return status indicating whether allocation succeeded")
      (assert (string-contains? c-src "if (!sb_grow(sb, n)) return;")
              "sb_append_len must guard against failed buffer growth")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47204 supervisor acceptance tests"
  (do
    (assert (TestEvalArgBoundsInAslC) "TestEvalArgBoundsInAslC must pass")
    (assert (TestSbGrowSafeReallocInAslC) "TestSbGrowSafeReallocInAslC must pass")
    true))
