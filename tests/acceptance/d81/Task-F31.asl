(module tests/acceptance/d81/Task-F31
  :d "Acceptance fixture for Task-F31: Add Key Reconciliation to VDOM List Diffing under ADR-0081."
  :x [RunTests
      TestKeyAttributeRetainedByFilter
      TestKeyedReorderingDoesNotMutateNodeContents
      TestKeyedAdditionAndRemoval
      TestTaskF31GroundedInPhaseFINSEL]
  :i [(asl-vdom/vdom :a v)])

(df has-mutation-matching? [(records (List v/MutationRecord)) (expected-val String)] -> Bool
  :d "Checks if any MutationRecord has new-val equal to expected-val"
  (not (list-empty? (filter (fn [(m v/MutationRecord)]
                              (mt m
                                ((mutated _ _ val) (= val expected-val))
                                (_ false)))
                            records))))

(df TestKeyAttributeRetainedByFilter [] -> Bool
  :d "Verifies is-retained-attr? retains key attribute for DOM reconciliation"
  (assert (v/is-retained-attr? "key") "key attribute must be retained by filter-attributes")
  (let [(attrs (map-set (map-set (map-empty) "key" "item-42") "class" "list-item"))
        (filtered (v/filter-attributes attrs))]
    (assert (map-has? filtered "key") "Filtered attributes must retain key")
    (assert (not (map-has? filtered "class")) "Filtered attributes must strip class")
    true))

(df TestKeyedReorderingDoesNotMutateNodeContents [] -> Bool
  :d "Verifies reordering keyed children preserves child identity and does not overwrite child text/id"
  (let [(c1 (v/elem "li" (map-set (map-set (map-empty) "key" "k1") "id" "id-1") (list (v/text "Alpha"))))
        (c2 (v/elem "li" (map-set (map-set (map-empty) "key" "k2") "id" "id-2") (list (v/text "Beta"))))
        (tree-forward (v/elem "ul" (map-empty) (list c1 c2)))
        (tree-reverse (v/elem "ul" (map-empty) (list c2 c1)))
        (diff (v/dom-diff tree-forward tree-reverse "/items"))
        (muts (.-mutated diff))]
    (assert (not (has-mutation-matching? muts "Beta")) "Keyed reordering must not overwrite Alpha text with Beta")
    (assert (not (has-mutation-matching? muts "id-2")) "Keyed reordering must not overwrite id-1 with id-2")
    (assert (= (list-length (.-added diff)) 0) "Keyed reordering of existing children must not create added records")
    (assert (= (list-length (.-removed diff)) 0) "Keyed reordering of existing children must not create removed records")
    true))

(df TestKeyedAdditionAndRemoval [] -> Bool
  :d "Verifies keyed reconciliation correctly identifies removed and added keys"
  (let [(c1 (v/elem "li" (map-set (map-empty) "key" "k1") (list (v/text "Alpha"))))
        (c2 (v/elem "li" (map-set (map-empty) "key" "k2") (list (v/text "Beta"))))
        (c3 (v/elem "li" (map-set (map-empty) "key" "k3") (list (v/text "Gamma"))))
        (tree-old (v/elem "ul" (map-empty) (list c1 c2)))
        (tree-new (v/elem "ul" (map-empty) (list c2 c3)))
        (diff (v/dom-diff tree-old tree-new "/items"))]
    (assert (= (list-length (.-added diff)) 1) "Diff must report exactly 1 added node (k3)")
    (assert (= (list-length (.-removed diff)) 1) "Diff must report exactly 1 removed node (k1)")
    (assert (not (has-mutation-matching? (.-mutated diff) "Beta")) "Preserved key k2 must not mutate contents")
    true))

(df TestTaskF31GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F31 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F31\""))
             (has-title (string-contains? content ":title \"Add Key Reconciliation to VDOM List Diffing\""))]
         (assert has-id "Task-F31 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F31 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F31"
  (let [(t1 (TestKeyAttributeRetainedByFilter))
        (t2 (TestKeyedReorderingDoesNotMutateNodeContents))
        (t3 (TestKeyedAdditionAndRemoval))
        (t4 (TestTaskF31GroundedInPhaseFINSEL))]
    (and (and t1 t2) (and t3 t4))))
