(module tests/acceptance/d81/Task46805
  :d "Acceptance fixture for Task46805: unified memory query and write surface, lineage preservation, and path-independent search under ADR-0081."
  :x [RunTests
      TestAslCImplementsMemCommand
      TestRpcAsnRegistersMemOp
      TestPromotionPreservesLineageHistory
      TestQueryRetrievesWithoutPathKnowledge
      TestWritesToCanonicalLedgerFiles]
  :i [])

(df TestAslCImplementsMemCommand [] -> Bool
  :d "Verifies that asl/tools/asl.c implements run_cmd_mem for unified memory query and write"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_mem") "asl.c must implement run_cmd_mem")
      (assert (string-contains? src "asl mem") "asl.c must document asl mem command")
      (assert (string-contains? src "strcmp(argv[1], \"mem\") == 0")
              "asl.c must dispatch mem subcommand in main")
      true)))

(df TestRpcAsnRegistersMemOp [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn registers unified mem batch operation"
  (let [(res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":op \"mem\"")
                  (string-contains? src ":op :id \"asl-mem\""))
              "rpc.asn must register mem batch operation")
      true)))

(df TestPromotionPreservesLineageHistory [] -> Bool
  :d "Verifies that promoting a record between kinds preserves lineage and history"
  (let [(res (file-read "mem/src/notes.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/notes.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "note-promote-to-task") "notes.asl must define note-promote-to-task")
      (assert (string-contains? src "note-promote-to-adr") "notes.asl must define note-promote-to-adr")
      (assert (or (string-contains? src "Promoted to")
                  (string-contains? src ":lineage"))
              "notes.asl must preserve promotion lineage")
      true)))

(df TestQueryRetrievesWithoutPathKnowledge [] -> Bool
  :d "Verifies that memory retrieval uses query search rather than requiring path knowledge"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (spool-res (file-read "mem/src/spool_search.asl"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (assert (= (.-_tag spool-res) "ok") "mem/src/spool_search.asl must exist and be readable")
    (let [(c-src (.-value c-res))
          (spool-src (.-value spool-res))]
      (assert (string-contains? spool-src "spool-query-bm25") "spool_search.asl must export spool-query-bm25")
      (assert (or (string-contains? c-src "query_mem_records")
                  (string-contains? c-src "mem query"))
              "asl.c must implement path-independent memory query")
      true)))

(df TestWritesToCanonicalLedgerFiles [] -> Bool
  :d "Verifies that the unified write surface writes directly to canonical ledger files"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ".asl/mem/intent.asn")
                  (string-contains? src ".asl/mem/practices.asn"))
              "asl.c mem write must target canonical memory files")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46805 supervisor acceptance tests"
  (do
    (assert (TestAslCImplementsMemCommand) "TestAslCImplementsMemCommand must pass")
    (assert (TestRpcAsnRegistersMemOp) "TestRpcAsnRegistersMemOp must pass")
    (assert (TestPromotionPreservesLineageHistory) "TestPromotionPreservesLineageHistory must pass")
    (assert (TestQueryRetrievesWithoutPathKnowledge) "TestQueryRetrievesWithoutPathKnowledge must pass")
    (assert (TestWritesToCanonicalLedgerFiles) "TestWritesToCanonicalLedgerFiles must pass")
    true))
