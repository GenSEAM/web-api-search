(module tests/acceptance/d81/Task-F28
  :d "Acceptance fixture for Task-F28: Resolve Asymmetric Intent Contradiction in MVCC Bus under ADR-0081."
  :x [RunTests
      TestSymmetricVerdictContradictionDetection
      TestMvccBusMergeRejectsOpposingVerdictsBothOrders
      TestTaskF28GroundedInPhaseFINSEL]
  :i [(asl-agent-bus/mvcc-bus :a mb)])

(df TestSymmetricVerdictContradictionDetection [] -> Bool
  :d "Verifies detect-intent-contradiction behaves symmetrically regardless of branch order"
  (let [(c-app-rej (mb/detect-intent-contradiction "(:verdict :approve)" "(:verdict :reject)"))
        (c-rej-app (mb/detect-intent-contradiction "(:verdict :reject)" "(:verdict :approve)"))
        (c-ok-fail (mb/detect-intent-contradiction "(:status :ok)" "(:status :failed)"))
        (c-fail-ok (mb/detect-intent-contradiction "(:status :failed)" "(:status :ok)"))
        (c-app-app (mb/detect-intent-contradiction "(:verdict :approve)" "(:verdict :approve)"))]
    (assert c-app-rej "(approve, reject) must be detected as contradiction")
    (assert c-rej-app "(reject, approve) must be detected as contradiction symmetrically")
    (assert c-ok-fail "(ok, failed) must be detected as contradiction")
    (assert c-fail-ok "(failed, ok) must be detected as contradiction")
    (assert (not c-app-app) "(approve, approve) must not be a contradiction")
    true))

(df TestMvccBusMergeRejectsOpposingVerdictsBothOrders [] -> Bool
  :d "Verifies 3-way intent merge aborts with IntentConflict in both branch orderings"
  (let [(bus0 (mb/mvcc-bus-create))
        (base-id "review-base-1")
        (bus1 (mb/mvcc-bus-publish bus0 "lead" "audit" "(:review :target \"item-x\")" (list) 1 100))
        (bus2 (mb/mvcc-bus-publish bus1 "ag-a" "audit" "(:review :target \"item-x\" :verdict :reject)" (list base-id) 2 100))
        (bus3 (mb/mvcc-bus-publish bus2 "ag-b" "audit" "(:review :target \"item-x\" :verdict :approve)" (list base-id) 2 100))
        (id-a "audit-ag-a-2")
        (id-b "audit-ag-b-2")
        (intent-forward (mb/mvcc-bus-merge-intents bus3 "audit" base-id id-b id-a))
        (intent-reverse (mb/mvcc-bus-merge-intents bus3 "audit" base-id id-a id-b))]
    (assert (not (.-clean intent-forward)) "Forward merge (approve, reject) must produce conflict")
    (assert (= (list-length (.-conflicts intent-forward)) 1) "Forward merge must have exactly 1 conflict")
    (assert (not (.-clean intent-reverse)) "Reverse merge (reject, approve) must produce conflict symmetrically")
    (assert (= (list-length (.-conflicts intent-reverse)) 1) "Reverse merge must have exactly 1 conflict")
    true))

(df TestTaskF28GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F28 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F28\""))
             (has-title (string-contains? content ":title \"Resolve Asymmetric Intent Contradiction in MVCC Bus\""))]
         (assert has-id "Task-F28 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F28 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F28"
  (let [(t1 (TestSymmetricVerdictContradictionDetection))
        (t2 (TestMvccBusMergeRejectsOpposingVerdictsBothOrders))
        (t3 (TestTaskF28GroundedInPhaseFINSEL))]
    (and t1 (and t2 t3))))
