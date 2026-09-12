(module tests/acceptance/d81/Task46503
  :d "Acceptance fixture for Task46503: note scope lifecycles, promotion, and retirement under ADR-0081."
  :x [run-tests
      test-notes-scope-definitions
      test-scope-close-and-promotion]
  :i [(asl-mem/notes :a notes)])

(df test-notes-scope-definitions [] -> Bool
  :d "Verifies that notes module defines explicit scope handling and scope promotion functions"
  (let [(src-res (file-read "mem/src/notes.asl"))]
    (assert (= (.-_tag src-res) "ok") "mem/src/notes.asl must exist and be readable")
    (let [(src (.-value src-res))]
      (assert (string-contains? src "note-promote-to-task") "notes.asl must define note-promote-to-task")
      (assert (string-contains? src "note-promote-to-adr") "notes.asl must define note-promote-to-adr")
      (assert (string-contains? src "note-close-scope") "notes.asl must define note-close-scope")
      true)))

(df test-scope-close-and-promotion [] -> Bool
  :d "Verifies that closing a step scope retires step notes while preserving task notes"
  (let [(n-step (notes/make-note "s1" "Step observation" "step-topic" (list "tag1") "step"))
        (n-task (notes/make-note "t1" "Task observation" "task-topic" (list "tag2") "task"))]
    (assert (= (.-scope n-step) "step") "step note scope must be step")
    (assert (= (.-scope n-task) "task") "task note scope must be task")
    (assert (notes/note-scope-matches? n-step "step") "n-step must match step")
    (assert (notes/note-scope-matches? n-task "task") "n-task must match task")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task46503 supervisor acceptance tests"
  (do
    (assert (test-notes-scope-definitions) "test-notes-scope-definitions must pass")
    (assert (test-scope-close-and-promotion) "test-scope-close-and-promotion must pass")
    true))
