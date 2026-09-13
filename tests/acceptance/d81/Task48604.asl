(module tests/acceptance/d81/Task48604
  :d "Acceptance fixture for Task48604: Dialectical Triangulation and Cross-Model Synthesis Engine under D85."
  :x [run-tests
      test-synthesis-file-exists
      test-synthesis-target-symbols
      test-triangulation-and-consensus]
  :i [])

(df test-synthesis-file-exists [] -> Bool
  :d "Verifies that synthesis.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-mesh/src/synthesis.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-mesh/src/synthesis.asl must exist")
    true))

(df test-synthesis-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in synthesis.asl"
  (let [(res (file-read "asl/packages/asl-mesh/src/synthesis.asl"))]
    (assert (= (.-_tag res) "ok") "synthesis.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "synthesize_defects") "synthesize_defects defined")
      (assert (string-contains? src "triangulate_findings") "triangulate_findings defined")
      (assert (string-contains? src "consensus_filter") "consensus_filter defined")
      (assert (string-contains? src "refutation_engine") "refutation_engine defined")
      true)))

(df test-triangulation-and-consensus [] -> Bool
  :d "Verifies dialectical triangulation and consensus receipt output"
  (let [(res (file-read "asl/packages/asl-mesh/src/synthesis.asl"))]
    (assert (= (.-_tag res) "ok") "synthesis.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-mesh/synthesis") "module declared correctly")
      (assert (string-contains? src "consensus") "consensus logic present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48604 acceptance assertions"
  (let [(r1 (test-synthesis-file-exists))
        (r2 (test-synthesis-target-symbols))
        (r3 (test-triangulation-and-consensus))]
    (assert (and (and r1 r2) r3) "All Task48604 checks must pass")
    true))
