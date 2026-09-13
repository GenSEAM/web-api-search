(module tests/acceptance/d81/Task-F24
  :d "Acceptance fixture for Task-F24: Prevent Irreversible Context Loss in Memory Pointer Collapse under ADR-0081."
  :x [RunTests
      TestCollapsePointerRetainsVfsRef
      TestRehydratePointerRestoresPayloadLosslessly
      TestOrchestratePointersLosslessRoundtrip
      TestTaskF24GroundedInPhaseFINSEL]
  :i [(asl-mem/pointer-orchestrator :a po)])

(df TestCollapsePointerRetainsVfsRef [] -> Bool
  :d "Verifies collapse-pointer stores VFS reference or payload representation preventing irreversible loss"
  (let [(raw-body "function computeTotal() { return 42; }")
        (p (po/make-pointer-spec "ptr-sym-1" "sym" "computeTotal" 10 "Compute total function"))
        (expanded (po/deref-pointer p raw-body))
        (collapsed (po/collapse-pointer expanded))]
    (assert (not (.-is-expanded collapsed)) "Collapsed pointer must be marked unexpanded")
    (assert (= (.-payload collapsed) "") "Collapsed pointer payload must be empty string for token savings")
    (assert (not (string-empty? (.-vfs-ref collapsed))) "Collapsed pointer must preserve vfs-ref")
    (assert (= (.-vfs-ref collapsed) raw-body) "Preserved vfs-ref must match full content")
    true))

(df TestRehydratePointerRestoresPayloadLosslessly [] -> Bool
  :d "Verifies rehydrate-pointer restores full content from preserved vfs-ref without context loss"
  (let [(raw-body "let activeRegistry = Map.new();")
        (p (po/make-pointer-spec "ptr-chunk-9" "chunk" "registry-chunk" 14 "Active registry chunk"))
        (expanded (po/deref-pointer p raw-body))
        (collapsed (po/collapse-pointer expanded))
        (rehydrated (po/rehydrate-pointer collapsed))]
    (assert (.-is-expanded rehydrated) "Rehydrated pointer must be marked expanded")
    (assert (= (.-payload rehydrated) raw-body) "Rehydrated pointer must match original content losslessly")
    (assert (> (.-expanded-tokens rehydrated) 0) "Expanded tokens must be recalculated")
    true))

(df TestOrchestratePointersLosslessRoundtrip [] -> Bool
  :d "Verifies orchestration budget enforcement collapses and rehydrates pointers losslessly"
  (let [(b1 "module Alpha :x [run] 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789")
        (b2 "module Beta :x [start] 0123456789 0123456789 0123456789 0123456789 0123456789 0123456789")
        (p1 (po/deref-pointer (po/make-pointer-spec "p1" "file" "alpha.asl" 10 "Alpha") b1))
        (p2 (po/deref-pointer (po/make-pointer-spec "p2" "file" "beta.asl" 10 "Beta") b2))
        (orchestrated (po/orchestrate-context-pointers (list p1 p2) 30))
        (last-p (option-or (list-head (list-reverse orchestrated)) p1))]

    (assert (not (.-is-expanded last-p)) "Trailing pointer must be collapsed under tight budget")
    (let [(restored (po/rehydrate-pointer last-p))]
      (assert (.-is-expanded restored) "Restored trailing pointer must be expanded")
      (assert (= (.-payload restored) b2) "Restored trailing pointer payload must match b2")
      true)))

(df TestTaskF24GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F24 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F24\""))
             (has-title (string-contains? content ":title \"Prevent Irreversible Context Loss in Memory Pointer Collapse\""))]
         (assert has-id "Task-F24 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F24 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F24"
  (let [(t1 (TestCollapsePointerRetainsVfsRef))
        (t2 (TestRehydratePointerRestoresPayloadLosslessly))
        (t3 (TestOrchestratePointersLosslessRoundtrip))
        (t4 (TestTaskF24GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 t4)))))
