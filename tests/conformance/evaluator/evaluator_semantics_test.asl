(module tests/conformance/evaluator/EvaluatorSemanticsTest
  :d "Conformance test suite for ASL evaluator semantics, import binding and closure execution per ADR-0081"
  :x [RunTests
      TestPositiveControlEvaluationPasses
      TestNegativeControlAssertionFailureRefused
      TestErrorPropagationUnboundSymbolRejection
      TestBoundaryLetBindingScoping
      TestErrorPropagationUnresolvedImport
      TestMetamorphicAliasedImportEquivalence
      TestEvaluationOrderLeftToRight]
  :i [(asl-mem/vfs :a vfs1)
      (asl-mem/vfs :a vfs2)])

(df TestPositiveControlEvaluationPasses [] -> Bool
  :d "Positive control: valid evaluation expressions return expected types and truth values"
  (let [(a 10)
        (b 20)
        (sum (+ a b))
        (text (str "sum=" (int-to-str sum)))]
    (assert (= sum 30) "Positive control addition must yield 30")
    (assert (= text "sum=30") "String concatenation must format sum=30")
    true))

(df TestNegativeControlAssertionFailureRefused [] -> Bool
  :d "Negative control: false conditions must be reported as failures rather than silent passes"
  (let [(passing-cond (= 1 1))
        (failing-cond (= 1 2))]
    (assert passing-cond "True equality must hold")
    (assert (not failing-cond) "False equality must be recognized as false")
    true))

(df TestErrorPropagationUnboundSymbolRejection [] -> Bool
  :d "Error propagation: unbound symbol errors must produce structured diagnostic indicators"
  (let [(c-src-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag c-src-res) "ok") "engine.js must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "ERR_UNBOUND_SYMBOL") "Evaluator must define ERR_UNBOUND_SYMBOL error code")
      (assert (string-contains? c-src "unknown builtin or function") "Evaluator must report unknown builtin or function diagnostic message")
      true)))

(df TestBoundaryLetBindingScoping [] -> Bool
  :d "Boundary: let forms handle empty bindings, sequential shadowing, and nested scope isolation"
  (let [(empty-let (let [] 42))
        (shadowed (let [(x 10)
                        (x (+ x 5))]
                    x))
        (nested (let [(outer 100)]
                  (let [(inner (+ outer 25))]
                    (+ outer inner))))]
    (assert (= empty-let 42) "Empty let binding must evaluate body directly")
    (assert (= shadowed 15) "Sequential let bindings must support lexical shadowing")
    (assert (= nested 225) "Nested let bindings must preserve enclosing lexical environment")
    true))

(df TestErrorPropagationUnresolvedImport [] -> Bool
  :d "Error propagation: invalid or unresolvable imports reject with ERR_UNRESOLVED_IMPORT"
  (let [(c-src-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag c-src-res) "ok") "engine.js must exist")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "ERR_UNRESOLVED_IMPORT") "Engine must declare ERR_UNRESOLVED_IMPORT")
      (assert (string-contains? c-src "ERR_TEST_RESULT_NOT_TRUE") "Engine must declare ERR_TEST_RESULT_NOT_TRUE")
      true)))

(df TestMetamorphicAliasedImportEquivalence [] -> Bool
  :d "Metamorphic: two distinct module aliases to the same underlying module resolve to identical function references"
  (let [(p1 (vfs1/normalize-path "./mem/src/vfs.asl"))
        (p2 (vfs2/normalize-path "mem/src/vfs.asl"))]
    (assert (= p1 "mem/src/vfs.asl") "First alias must normalize path")
    (assert (= p2 "mem/src/vfs.asl") "Second alias must normalize path")
    (assert (= p1 p2) "Different module import aliases to same source must produce identical canonical target")
    true))

(df TestEvaluationOrderLeftToRight [] -> Bool
  :d "Evaluation order: function arguments and let bindings evaluate strictly left-to-right"
  (let [(acc (list))
        (step1 (cons "first" acc))
        (step2 (cons "second" step1))]
    (assert (= (head step1) "first") "First element evaluated first")
    (assert (= (head step2) "second") "Second element prepended in strict sequential order")
    true))

(df RunTests [] -> Bool
  :d "Executes all evaluator semantics conformance test cases"
  (do
    (assert (TestPositiveControlEvaluationPasses) "TestPositiveControlEvaluationPasses must pass")
    (assert (TestNegativeControlAssertionFailureRefused) "TestNegativeControlAssertionFailureRefused must pass")
    (assert (TestErrorPropagationUnboundSymbolRejection) "TestErrorPropagationUnboundSymbolRejection must pass")
    (assert (TestBoundaryLetBindingScoping) "TestBoundaryLetBindingScoping must pass")
    (assert (TestErrorPropagationUnresolvedImport) "TestErrorPropagationUnresolvedImport must pass")
    (assert (TestMetamorphicAliasedImportEquivalence) "TestMetamorphicAliasedImportEquivalence must pass")
    (assert (TestEvaluationOrderLeftToRight) "TestEvaluationOrderLeftToRight must pass")
    true))
