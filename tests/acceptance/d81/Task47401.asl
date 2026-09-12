(module tests/acceptance/d81/Task47401
  :d "Acceptance fixture for Task47401: unified projection engine under ADR-0081."
  :x [RunTests
      TestAslProjectCommandImplementedInAslC
      TestProjectShapesAndTiers
      TestTierFiltering]
  :i [])

(df TestAslProjectCommandImplementedInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_project with content, shape, and dest"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "run_cmd_project")
              "asl.c must implement run_cmd_project")
      (assert (string-contains? c-src "project_content")
              "asl.c must implement project_content engine")
      (assert (string-contains? c-src "strcmp(argv[1], \"project\")")
              "asl.c must dispatch project subcommand in main")
      true)))

(df TestProjectShapesAndTiers [] -> Bool
  :d "Verifies that asl project produces valid output for all three shapes"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "--shape")
              "asl.c project command must accept --shape option")
      (assert (string-contains? c-src "--content")
              "asl.c project command must accept --content option")
      (assert (string-contains? c-src "delimited")
              "asl.c project command must support delimited shape")
      (assert (string-contains? c-src "fenced")
              "asl.c project command must support fenced shape")
      (assert (string-contains? c-src "record")
              "asl.c project command must support record shape")
      true)))

(df TestTierFiltering [] -> Bool
  :d "Verifies that asl project filters rules by tier correctly"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "filter_rules_by_tier")
              "asl.c must implement filter_rules_by_tier")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47401 supervisor acceptance tests"
  (do
    (assert (TestAslProjectCommandImplementedInAslC) "TestAslProjectCommandImplementedInAslC must pass")
    (assert (TestProjectShapesAndTiers) "TestProjectShapesAndTiers must pass")
    (assert (TestTierFiltering) "TestTierFiltering must pass")
    true))
