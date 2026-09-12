(module tests/acceptance/d81/Task46501
  :d "Acceptance fixture for Task46501: native memory command surface, RPC operations, and task claim under ADR-0081."
  :x [run-tests
      test-asl-tools-command-surface
      test-rpc-registry-memory-ops
      test-notes-module-persistence]
  :i [(asl-mem/notes :a notes)])

(df test-asl-tools-command-surface [] -> Bool
  :d "Verifies that asl/tools/asl.c defines native command handlers for note, task, and queue"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "run_cmd_note") "asl.c must implement run_cmd_note")
      (assert (string-contains? c-src "run_cmd_task") "asl.c must implement run_cmd_task")
      (assert (string-contains? c-src "run_cmd_queue") "asl.c must implement run_cmd_queue")
      (assert (string-contains? c-src "Usage: asl note") "asl.c must document asl note usage")
      (assert (string-contains? c-src "Usage: asl task") "asl.c must document asl task usage")
      true)))

(df test-rpc-registry-memory-ops [] -> Bool
  :d "Verifies that asl/grammar/rpc.asn registers note, task, and queue batch operations"
  (let [(rpc-src-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag rpc-src-res) "ok") "asl/grammar/rpc.asn must exist and be readable")
    (let [(rpc-src (.-value rpc-src-res))]
      (assert (string-contains? rpc-src ":op \"note\"") "rpc.asn must register :note operation")
      (assert (string-contains? rpc-src ":op \"task\"") "rpc.asn must register :task operation")
      (assert (string-contains? rpc-src ":op \"queue\"") "rpc.asn must register :queue operation")
      true)))

(df test-notes-module-persistence [] -> Bool
  :d "Verifies note creation, query matching, and scope attributes directly through asl-mem/notes"
  (let [(n1 (notes/make-note "fact-1" "Working memory command surface established" "surface" (list "tag1") "step"))]
    (assert (= (.-id n1) "fact-1") "note ID must match")
    (assert (= (.-scope n1) "step") "note scope must be step")
    (assert (notes/note-matches-query? n1 "command surface") "query must match note content")
    (assert (notes/note-scope-matches? n1 "step") "scope query must match step")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task46501 supervisor acceptance tests"
  (do
    (assert (test-asl-tools-command-surface) "test-asl-tools-command-surface must pass")
    (assert (test-rpc-registry-memory-ops) "test-rpc-registry-memory-ops must pass")
    (assert (test-notes-module-persistence) "test-notes-module-persistence must pass")
    true))
