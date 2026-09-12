(module tests/acceptance/d81/Task44205
  :d "Acceptance fixture for Task44205: semantic recall over ledgers (:q) on resident BM25 index."
  :x [RunTests
      TestQOperatorImplementedInAslC
      TestQOperatorDeclaredInRpcAsn
      TestBm25ReferenceImplementationInMem]
  :i [])

(df TestQOperatorImplementedInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c implements :q op in execute_single_step"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "strcmp(op, \"q\")")
              "asl.c must handle :q op")
      (assert (string-contains? c-src "op_q")
              "asl.c must implement op_q")
      (assert (string-contains? c-src "doc_stats[i].tf")
              "asl.c must count term frequencies")
      (assert (string-contains? c-src "term_dfs")
              "asl.c must compute document frequencies")
      (assert (string-contains? c-src ":count 0 :hits []")
              "asl.c must return :count 0 :hits [] on zero hits")
      (assert (string-contains? c-src ":ERR_UNSUPPORTED")
              "asl.c must return :ERR_UNSUPPORTED on unsupported scope")
      true)))

(df TestQOperatorDeclaredInRpcAsn [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn declares :id asl-q"
  (let [(rpc-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-res) "ok") "asl/grammar/rpc.asn must exist")
    (let [(rpc-src (.-value rpc-res))]
      (assert (string-contains? rpc-src ":id \"asl-q\"")
              "rpc.asn must declare asl-q op")
      (assert (string-contains? rpc-src "(:q :query")
              "rpc.asn must declare (:q :query ...) syntax")
      true)))

(df TestBm25ReferenceImplementationInMem [] -> Bool
  :d "Verifies that mem/src/bm25.asl exports reference BM25 functions"
  (let [(m-res (file-read "mem/src/bm25.asl"))]
    (assert (= (.-_tag m-res) "ok") "mem/src/bm25.asl must exist")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "make-bm25-index")
              "bm25.asl must export make-bm25-index")
      (assert (string-contains? m-src "sort-bm25-scores")
              "bm25.asl must export sort-bm25-scores")
      (assert (string-contains? m-src "rank-bm25")
              "bm25.asl must export rank-bm25")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44205 supervisor acceptance tests"
  (do
    (assert (TestQOperatorImplementedInAslC) "TestQOperatorImplementedInAslC must pass")
    (assert (TestQOperatorDeclaredInRpcAsn) "TestQOperatorDeclaredInRpcAsn must pass")
    (assert (TestBm25ReferenceImplementationInMem) "TestBm25ReferenceImplementationInMem must pass")
    true))
