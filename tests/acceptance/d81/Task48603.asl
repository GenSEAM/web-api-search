(module tests/acceptance/d81/Task48603
  :d "Acceptance fixture for Task48603: Synthesis tests."
  :x [runTests]
  :i [(aslMesh/synthesis :a synth)])

(df testSynthesisConsensus [] -> Bool
  (let [(f1 {:id "1" :confidence 0.9 :status "verified"})
        (f2 {:id "2" :confidence 0.5 :status "unverified"})
        (filtered (synth/consensus_filter (list f1 f2) 0.8))
        (receipt (synth/synthesize_defects (list "pkg1") (list f1 f2)))]
    (assert (= (list-length filtered) 1) "Filtered one finding")
    (refute (= (list-length filtered) 2) "Did not keep both")
    (assert (= (map-get receipt :agreementRate) 0.5) "50% agreement")
    (refute (= (map-get receipt :agreementRate) 1.0) "Not 1.0 agreement")
    true))

(df testSynthesisTriangulate [] -> Bool
  (let [(l1 (list {:id "1"}))
        (l2 (list {:id "2"}))
        (l3 (list {:id "3"}))
        (all (synth/triangulate_findings l1 l2 l3))]
    (assert (= (list-length all) 3) "Combined length is 3")
    (refute (= (list-length all) 0) "Not empty")
    true))

(df runTests [] -> Bool
  (let [(r1 (testSynthesisConsensus))
        (r2 (testSynthesisTriangulate))]
    (assert (and r1 r2) "All synthesis tests pass")
    true))
