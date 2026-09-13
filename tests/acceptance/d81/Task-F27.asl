(module tests/acceptance/d81/Task-F27
  :d "Acceptance fixture for Task-F27: Hydrate Memory Chunk Before Context Eviction under ADR-0081."
  :x [RunTests
      TestEvictRawContextHydratesMemoryChunk
      TestEvictEmptyRawContextLeavesChunksUnchanged
      TestTaskF27GroundedInPhaseFINSEL]
  :i [(asl-mem/hydration :a h)
      (asl-mem/view_layer :a vl)])

(df TestEvictRawContextHydratesMemoryChunk [] -> Bool
  :d "Verifies evict-raw-context persists uncompressed operational messages into MemoryChunk instead of dropping them"
  (let [(c0 (vl/make-memory-chunk "chunk-pre" 1000 0.90 "pre-existing" (list) (list) (list)))
        (buf (h/make-context-buffer
               "buf-evict-test"
               1500
               (list "fact: agent active"
                     "directive: maintain pure ASL"
                     "session audit started")
               (list c0)))
        (evicted (h/evict-raw-context buf))
        (chunks (.-chunks evicted))]
    (assert (list-empty? (.-messages evicted)) "Evicted buffer must have empty messages list")
    (assert (= (.-active-tokens evicted) 0) "Active tokens must reset to 0")
    (assert (= (list-length chunks) 2) "Evicted buffer must contain both pre-existing and newly persisted chunk")
    (let [(new-chunk (option-or (list-get chunks 1) c0))]
      (assert (string-contains? (.-id new-chunk) "buf-evict-test") "Persisted chunk ID must reference buffer ID")
      (assert (= (list-length (.-facts new-chunk)) 1) "Persisted chunk must extract scalar facts")
      (assert (= (list-length (.-directives new-chunk)) 1) "Persisted chunk must extract directives")
      (assert (string-contains? (.-summary new-chunk) "session audit started") "Persisted chunk summary must retain message content")
      true)))

(df TestEvictEmptyRawContextLeavesChunksUnchanged [] -> Bool
  :d "Verifies evict-raw-context on empty buffer does not fabricate redundant chunks"
  (let [(c0 (vl/make-memory-chunk "chunk-solo" 1000 0.90 "pre" (list) (list) (list)))
        (buf (h/make-context-buffer "buf-empty-evict" 0 (list) (list c0)))
        (evicted (h/evict-raw-context buf))]
    (assert (= (list-length (.-chunks evicted)) 1) "Empty buffer eviction must not create phantom chunks")
    (assert (= (.-active-tokens evicted) 0) "Tokens must remain 0")
    true))

(df TestTaskF27GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F27 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F27\""))
             (has-title (string-contains? content ":title \"Hydrate Memory Chunk Before Context Eviction\""))]
         (assert has-id "Task-F27 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F27 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F27"
  (let [(t1 (TestEvictRawContextHydratesMemoryChunk))
        (t2 (TestEvictEmptyRawContextLeavesChunksUnchanged))
        (t3 (TestTaskF27GroundedInPhaseFINSEL))]
    (and t1 (and t2 t3))))
