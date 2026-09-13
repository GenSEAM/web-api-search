(module tests/acceptance/d81/Task48605
  :d "Acceptance fixture for Task48605: Automated Gap Ledger Emitter in .asl/mem/gaps/ under D85 and D83."
  :x [run-tests
      test-gap-emitter-exists
      test-gap-target-symbols
      test-gaps-master-ledger]
  :i [])

(df test-gap-emitter-exists [] -> Bool
  :d "Verifies that emitter.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-mesh/src/emitter.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-mesh/src/emitter.asl must exist")
    true))

(df test-gap-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in emitter.asl"
  (let [(res (file-read "asl/packages/asl-mesh/src/emitter.asl"))]
    (assert (= (.-_tag res) "ok") "emitter.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "emit_gap_ledger") "emit_gap_ledger defined")
      (assert (string-contains? src "write_gap_record") "write_gap_record defined")
      (assert (string-contains? src "gap_ledger") "gap_ledger defined")
      (assert (string-contains? src "roadmap_link") "roadmap_link defined")
      true)))

(df test-gaps-master-ledger [] -> Bool
  :d "Verifies that GapsMasterLedger.asn exists and contains valid gap records conforming to D85 schema"
  (let [(res (file-read ".asl/mem/gaps/GapsMasterLedger.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/gaps/GapsMasterLedger.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":gapsMasterLedger") "gapsMasterLedger header present")
      (assert (string-contains? src ":gapRecords") "gapRecords list present")
      (assert (string-contains? src ":roadmapLink") "roadmapLink present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48605 acceptance assertions"
  (let [(r1 (test-gap-emitter-exists))
        (r2 (test-gap-target-symbols))
        (r3 (test-gaps-master-ledger))]
    (assert (and (and r1 r2) r3) "All Task48605 checks must pass")
    true))
