(module tests/acceptance/d81/Task48606
  :d "Acceptance fixture for Task48606: Mesh Orchestrator Gate."
  :x [runTests]
  :i [(tests/acceptance/d81/Task48601 :a t1)
      (tests/acceptance/d81/Task48602 :a t2)
      (tests/acceptance/d81/Task48603 :a t3)
      (tests/acceptance/d81/Task48604 :a t4)
      (tests/acceptance/d81/Task48605 :a t5)])

(df runTests [] -> Bool
  (let [(r1 (t1/runTests))
        (r2 (t2/runTests))
        (r3 (t3/runTests))
        (r4 (t4/runTests))
        (r5 (t5/runTests))]
    (assert (and (and (and (and r1 r2) r3) r4) r5) "All Phase 486 Mesh Gates Pass")
    (refute (= 1 2) "Refute sentinel")
    true))
