(module tests/acceptance/d81/Task45401
  :d "Acceptance fixture for Task45401: manifest-driven module graph resolution under ADR-0081."
  :x [run-tests
      test-declared-manifest-resolution
      test-workspace-module-resolution]
  :i [(d81-sample/resolution-sample :a smp)
      (asl-mem/math :a mmath)])

(df test-declared-manifest-resolution [] -> Bool
  :d "Verifies that a module in a path absent from the old guess ladder resolves by its declared header"
  (let [(token (smp/sample-identity-value))]
    (assert (= token "sample-manifest-resolution-success") "module must resolve and execute via declared name")
    true))

(df test-workspace-module-resolution [] -> Bool
  :d "Verifies workspace module declared as asl-mem/math resolves to its declaring file"
  (let [(dot (mmath/vector-dot (list 1.0 2.0) (list 3.0 4.0)))]
    (assert (= dot 11.0) "vector-dot must evaluate correctly on resolved module")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task45401 acceptance tests"
  (do
    (assert (test-declared-manifest-resolution) "test-declared-manifest-resolution must pass")
    (assert (test-workspace-module-resolution) "test-workspace-module-resolution must pass")
    true))
