(module tests/acceptance/d81/Task43809
  :d "Acceptance fixture for Task43809: workspace boundary policy under ADR-0081."
  :x [RunTests
      TestPathBoundaryCanonicalizationInAslC
      TestPathBoundaryCapabilityStatusWorks]
  :i [])

(df TestPathBoundaryCanonicalizationInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements canonical path resolution in is_safe_path"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "is_safe_path") "asl.c must implement is_safe_path")
      (assert (or (string-contains? c-src "realpath") (string-contains? c-src "canonicalize_path") (string-contains? c-src "norm_path"))
              "asl.c must canonicalize paths in is_safe_path")
      true)))

(df TestPathBoundaryCapabilityStatusWorks [] -> Bool
  :d "Verifies that asl/grammar/capabilities.asn declares pathBoundary as works"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist and be readable")
    (let [(cap-txt (.-value cap-res))]
      (assert (string-contains? cap-txt "(:cap :id pathBoundary :use \"paths are canonicalised and checked against workspace, worktrees and scratch roots\" :status :works")
              "capabilities.asn must declare pathBoundary as works")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43809 supervisor acceptance tests"
  (do
    (assert (TestPathBoundaryCanonicalizationInAslC) "TestPathBoundaryCanonicalizationInAslC must pass")
    (assert (TestPathBoundaryCapabilityStatusWorks) "TestPathBoundaryCapabilityStatusWorks must pass")
    true))
