(module tests/acceptance/d81/Task48605
  :d "Acceptance fixture for Task48605: Emitter tests."
  :x [runTests]
  :i [(aslMesh/emitter :a emit)])

(df testEmitterWrite [] -> Bool
  (let [(rec {:defectId "D1" :path "f.asl" :lineNumber 10})
        (link {:phase "P486" :task "T1" :adr "A1"})
        (res (emit/emit_gap_ledger "/tmp" (list rec) link))]
    (assert (= (map-get res :emittedRecords) 1) "One record emitted")
    (refute (= (map-get res :emittedRecords) 0) "Not zero")
    (assert (= (map-get res :status) "emitted") "Status emitted")
    true))

(df runTests [] -> Bool
  (assert (testEmitterWrite) "Emitter tests pass")
  true)
