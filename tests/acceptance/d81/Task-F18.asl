(module tests/acceptance/d81/Task-F18
  :d "Acceptance fixture for Task-F18: Implement Dynamic AST Traversal and Blast Radius Reachability under ADR-0081."
  :x [RunTests
      TestQueryCallers
      TestQueryImpactTransitive
      TestQueryCallees
      TestTaskF18GroundedInPhaseFINSEL]
  :i [(asl-intel/graph :a g)
      (asl-intel/query :a q)])

(df make-test-node [(id Str) (name Str)] -> g/GraphNode
  (g/GraphNode :id id :name name :kind "fn" :file "test.asl" :start-line 1 :end-line 5 :signature "() -> Unit" :exported true))

(df make-test-edge [(src Str) (dst Str)] -> g/GraphEdge
  (g/GraphEdge :src src :dst dst :kind (g/edge-calls) :file "test.asl" :line 2))

(df build-sample-graph [] -> g/SymbolGraph
  (let [(g0 (g/graph-create))
        (g1 (g/graph-add-node g0 (make-test-node "core/base" "base")))
        (g2 (g/graph-add-node g1 (make-test-node "service/mid" "mid")))
        (g3 (g/graph-add-node g2 (make-test-node "app/top" "top")))
        (g4 (g/graph-add-node g3 (make-test-node "app/other" "other")))
        (g5 (g/graph-add-edge g4 (make-test-edge "service/mid" "core/base")))
        (g6 (g/graph-add-edge g5 (make-test-edge "app/top" "service/mid")))
        (g7 (g/graph-add-edge g6 (make-test-edge "app/other" "core/base")))]
    g7))

(df TestQueryCallers [] -> Bool
  :d "Verifies query-callers returns immediate direct callers of a target symbol"
  (let [(graph (build-sample-graph))
        (res (q/query-callers graph "core/base"))]
    (assert (= (.-total res) 2) "core/base must have exactly 2 callers")
    (let [(names (map (fn [(item q/ImpactItem)] -> Str (.-symbol-id item)) (.-items res)))
          (all-names (string-join names " "))]
      (assert (string-contains? all-names "service/mid") "callers must contain service/mid")
      (assert (string-contains? all-names "app/other") "callers must contain app/other")
      true)))

(df TestQueryImpactTransitive [] -> Bool
  :d "Verifies query-impact computes multi-level transitive blast radius"
  (let [(graph (build-sample-graph))
        (res (q/query-impact graph "core/base" 3))]
    (assert (>= (.-total res) 3) "core/base impact must reach at least 3 transitive callers")
    (let [(names (map (fn [(item q/ImpactItem)] -> Str (.-symbol-id item)) (.-items res)))
          (all-names (string-join names " "))]
      (assert (string-contains? all-names "service/mid") "impact must contain direct caller mid")
      (assert (string-contains? all-names "app/top") "impact must contain transitive caller top")
      (assert (string-contains? all-names "app/other") "impact must contain caller other")
      true)))

(df TestQueryCallees [] -> Bool
  :d "Verifies query-callees returns outgoing dependencies of a symbol"
  (let [(graph (build-sample-graph))
        (res (q/query-callees graph "app/top"))]
    (assert (= (.-total res) 1) "app/top must have exactly 1 callee")
    (let [(first-item (option-or (list-head (.-items res)) (q/ImpactItem :symbol-id "" :name "" :file "" :depth 0)))]
      (assert (= (.-symbol-id first-item) "service/mid") "app/top callee must be service/mid")
      true)))

(df TestTaskF18GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F18 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F18\"") "Must declare Task-F18")
      (assert (string-contains? f-src "intel/src/graph.asl") "Must own graph.asl")
      (assert (string-contains? f-src "intel/src/query.asl") "Must own query.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F18 acceptance checks"
  (do
    (assert (TestQueryCallers) "TestQueryCallers must pass")
    (assert (TestQueryImpactTransitive) "TestQueryImpactTransitive must pass")
    (assert (TestQueryCallees) "TestQueryCallees must pass")
    (assert (TestTaskF18GroundedInPhaseFINSEL) "TestTaskF18GroundedInPhaseFINSEL must pass")
    true))
