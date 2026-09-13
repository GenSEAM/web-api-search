(module tests/acceptance/d81/Task48604
  :d "Acceptance fixture for Task48604: Mesh general integration."
  :x [runTests]
  :i [(aslMesh/scheduler :a sched)
      (aslMesh/synthesis :a synth)])

(df testMeshIntegration [] -> Bool
  (let [(pool (sched/worktree_pool "/tmp" 2))
        (receipt (synth/synthesize_defects (list "pkgA") (list {:status "verified"})))]
    (assert (= (list-length pool) 2) "Pool created")
    (refute (= (list-length pool) 0) "Pool not empty")
    (assert (= (map-get receipt :agreementRate) 1.0) "Full agreement")
    true))

(df runTests [] -> Bool
  (assert (testMeshIntegration) "Mesh integration passes")
  true)
