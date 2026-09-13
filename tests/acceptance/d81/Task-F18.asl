(module tests/acceptance/d81/Task-F18
  :d "Acceptance fixture for Task-F18: Implement Dynamic AST Traversal and Blast Radius Reachability under ADR-0081."
  :x [RunTests
      TestQueryCallers
      TestQueryImpactTransitive
      TestQueryCallees
      TestTaskF18GroundedInPhaseFINSEL]
  :i [(asl-intel/graph :a g)
      (asl-intel/query :a q)])

(df MakeTestNode [(id Str) (name Str)] -> g/GraphNode
  (g/GraphNode :id id :name name :kind "fn" :file "test.asl" :start-line 1 :end-line 5 :signature "() -> Unit" :exported true))

(df MakeTestEdge [(src Str) (dst Str)] -> g/GraphEdge
  (g/GraphEdge :src src :dst dst :kind (g/edge-calls) :file "test.asl" :line 2))

(df BuildSampleGraph [] -> g/SymbolGraph
  (let [(g0 (g/graph-create))
        (g1 (g/graph-add-node g0 (MakeTestNode "core/base" "base")))
        (g2 (g/graph-add-node g1 (MakeTestNode "service/mid" "mid")))
        (g3 (g/graph-add-node g2 (MakeTestNode "app/top" "top")))
        (g4 (g/graph-add-node g3 (MakeTestNode "app/other" "other")))
        (g5 (g/graph-add-edge g4 (MakeTestEdge "service/mid" "core/base")))
        (g6 (g/graph-add-edge g5 (MakeTestEdge "app/top" "service/mid")))
        (g7 (g/graph-add-edge g6 (MakeTestEdge "app/other" "core/base")))]
    g7))

(df TestQueryCallers [] -> Bool
  :d "Verifies query-callers returns immediate direct callers of a target symbol"
  (let [(graph (BuildSampleGraph))
        (res (q/query-callers graph "core/base"))]
    (assert (= (.-total res) 2) "core/base must have exactly 2 callers")
    (let [(names (map (fn [(item q/ImpactItem)] -> Str (.-symbol-id item)) (.-items res)))
          (AllNames (string-join names " "))]
      (assert (string-contains? AllNames "service/mid") "callers must contain service/mid")
      (assert (string-contains? AllNames "app/other") "callers must contain app/other")
      true)))

(df TestQueryImpactTransitive [] -> Bool
  :d "Verifies query-impact computes multi-level transitive blast radius"
  (let [(graph (BuildSampleGraph))
        (res (q/query-impact graph "core/base" 3))]
    (assert (>= (.-total res) 3) "core/base impact must reach at least 3 transitive callers")
    (let [(names (map (fn [(item q/ImpactItem)] -> Str (.-symbol-id item)) (.-items res)))
          (AllNames (string-join names " "))]
      (assert (string-contains? AllNames "service/mid") "impact must contain direct caller mid")
      (assert (string-contains? AllNames "app/top") "impact must contain transitive caller top")
      (assert (string-contains? AllNames "app/other") "impact must contain caller other")
      true)))

(df TestQueryCallees [] -> Bool
  :d "Verifies query-callees returns outgoing dependencies of a symbol"
  (let [(graph (BuildSampleGraph))
        (res (q/query-callees graph "app/top"))]
    (assert (= (.-total res) 1) "app/top must have exactly 1 callee")
    (let [(FirstItem (option-or (list-head (.-items res)) (q/ImpactItem :symbol-id "" :name "" :file "" :depth 0)))]
      (assert (= (.-symbol-id FirstItem) "service/mid") "app/top callee must be service/mid")
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
