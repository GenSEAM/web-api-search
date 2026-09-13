(module tests/acceptance/d81/Task-F19
  :d "Acceptance fixture for Task-F19: Hydrate Symbol Graph on Intel Preload under ADR-0081."
  :x [RunTests
      TestDefaultWorkspaceFiles
      TestHydrateGraphFromFileSymbols
      TestHydrateGraphFromSources
      TestHydrateGraphFromFiles
      TestIntelPreloadPopulated
      TestIntelPreloadBudgetTruncation
      TestTaskF19GroundedInPhaseFINSEL]
  :i [(asl-intel/graph :a g)
      (asl-intel/preload :a pr)
      (asl-intel/extractor :a ext)])

(df TestDefaultWorkspaceFiles [] -> Bool
  :d "Verifies default-workspace-files returns non-empty list of canonical ASL files"
  (let [(files (pr/default-workspace-files))]
    (assert (> (list-length files) 0) "Workspace files list must not be empty")
    (assert (list-any? (fn [(f Str)] -> Bool (string-contains? f "intel.asl")) files) "Files list must contain intel.asl")
    (assert (list-any? (fn [(f Str)] -> Bool (string-contains? f "extractor.asl")) files) "Files list must contain extractor.asl")
    (assert (list-any? (fn [(f Str)] -> Bool (string-contains? f "graph.asl")) files) "Files list must contain graph.asl")
    true))

(df TestHydrateGraphFromFileSymbols [] -> Bool
  :d "Verifies hydrate-graph-from-file-symbols populates GraphNodes and GraphEdges"
  (let [(s1 (ext/SymbolDef :name "demo/calc" :kind (ext/sym-fn) :file "demo.asl" :start-line 1 :end-line 5 :signature "(df calc [] -> I64)" :exported true :doc "calc"))
        (s2 (ext/SymbolDef :name "demo/helper" :kind (ext/sym-fn) :file "demo.asl" :start-line 6 :end-line 10 :signature "(df helper [] -> I64)" :exported false :doc "helper"))
        (r1 (ext/SymbolRef :name "demo/helper" :caller "demo/calc" :file "demo.asl" :line 3))
        (fs (ext/FileSymbols :file "demo.asl" :language "asl" :symbols (list s1 s2) :refs (list r1)))
        (g (pr/hydrate-graph-from-file-symbols (list fs)))]
    (let [(nc (g/graph-node-count g))] (assert (= nc 2) (str "Hydrated graph node count was: " (string-from-int64 nc))))
    (assert (= (g/graph-edge-count g) 1) "Hydrated graph must have 1 edge")
    (let [(found (pr/find-target-node (.-nodes g) "demo/calc"))]
      (assert (option-is-some? found) "Target node demo/calc must be present")
      (assert (= (.-name (option-unwrap found)) "calc") "Short name must be calc")
      true)))

(df TestHydrateGraphFromSources [] -> Bool
  :d "Verifies graph hydration from raw code sources with caller and callee edges"
  (let [(s1 (str "(module sample/math\n"
                 "  :x [add double])\n"
                 "(df add [(a I64) (b I64)] -> I64\n"
                 "  (+ a b))\n"
                 "(df double [(x I64)] -> I64\n"
                 "  (sample/math/add x x))\n"))
        (sources (list (tuple "math.asl" s1)))
        (g (pr/hydrate-graph-from-sources sources))]
    (assert (>= (g/graph-node-count g) 2) "Hydrated graph must contain at least 2 nodes")
    (assert (>= (g/graph-edge-count g) 1) "Hydrated graph must contain at least 1 edge")
    (let [(h (pr/intel-preload-graph g "double" 1 10000))]
      (assert (>= (list-length (.-stubs h)) 2) "Preload of double at depth 1 must retrieve double and add")
      true)))

(df TestHydrateGraphFromFiles [] -> Bool
  :d "Verifies hydrate-graph-from-files loads workspace files into a populated SymbolGraph"
  (let [(files (pr/default-workspace-files))
        (g (pr/hydrate-graph-from-files files))]
    (assert (> (g/graph-node-count g) 10) "Hydrated workspace graph must contain more than 10 nodes")
    (assert (> (g/graph-edge-count g) 5) "Hydrated workspace graph must contain more than 5 edges")
    (let [(target (pr/find-target-node (.-nodes g) "intel-version"))]
      (assert (option-is-some? target) "Symbol intel-version must be in hydrated graph")
      true)))

(df TestIntelPreloadPopulated [] -> Bool
  :d "Verifies intel-preload returns populated stubs for a known workspace symbol"
  (let [(h (pr/intel-preload "intel-version" 2 10000))]
    (assert (> (list-length (.-stubs h)) 0) "Preloaded horizon must contain at least 1 stub")
    (assert (> (.-total-tokens h) 0) "Preloaded horizon total tokens must be greater than zero")
    (assert (not (.-truncated h)) "Horizon must not be truncated with 10000 budget")
    (let [(FirstStub (option-or (list-head (.-stubs h)) (pr/stub-create "" (pr/tier-micro-ast) "" "" "" 0)))]
      (assert (string-contains? (.-symbol FirstStub) "intel-version") "First stub must match target symbol")
      (assert (string-equals? (pr/preload-tier-to-string (.-tier FirstStub)) "micro-ast") "Target stub must be micro-ast tier")
      true)))

(df TestIntelPreloadBudgetTruncation [] -> Bool
  :d "Verifies intel-preload respects small token budget ceiling and sets truncated flag"
  (let [(h (pr/intel-preload "intel-version" 2 5))]
    (assert (.-truncated h) "Horizon must be marked truncated when budget is too tight")
    true))

(df TestTaskF19GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F19 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(HasId (string-contains? content ":id \"Task-F19\""))
             (HasTitle (string-contains? content ":title \"Hydrate Symbol Graph on Intel Preload\""))]
         (assert HasId "Task-F19 must be registered in PhaseFINSELRemediation.asn")
         (assert HasTitle "Task-F19 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F19"
  (let [(t1 (TestDefaultWorkspaceFiles))
        (t2 (TestHydrateGraphFromFileSymbols))
        (t3 (TestHydrateGraphFromSources))
        (t4 (TestHydrateGraphFromFiles))
        (t5 (TestIntelPreloadPopulated))
        (t6 (TestIntelPreloadBudgetTruncation))
        (t7 (TestTaskF19GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 (and t4 (and t5 (and t6 t7))))))))
