(module tests/acceptance/d81/Task44002
  :d "Acceptance fixture for Task44002: Close native and WASM compiler bootstrap generations under ADR-0081."
  :x [RunTests
      TestBootstrapContractSpecification
      TestDependencyBoundariesDeclared
      TestCodegenBackendsAvailable
      TestBootstrapRebuildModule]
  :i [])

(df TestBootstrapContractSpecification [] -> Bool
  :d "Verifies that bootstrap-contract.asn defines the stage0-to-stage1-to-stage2 and WASM bootstrap chain"
  (let [(b-res (file-read "asl/grammar/bootstrap-contract.asn"))]
    (assert (= (.-_tag b-res) "ok") "asl/grammar/bootstrap-contract.asn must exist and be readable")
    (let [(src (.-value b-res))]
      (assert (string-contains? src ":bootstrapContract") "Must declare :bootstrapContract")
      (assert (string-contains? src ":stage :id 0") "Must define stage 0 seed")
      (assert (string-contains? src ":stage :id 1") "Must define stage 1 compiler")
      (assert (string-contains? src ":stage :id 2") "Must define stage 2 self-hosted binary")
      (assert (string-contains? src ":stage :id \"wasm\"") "Must define WASM target stage")
      true)))

(df TestDependencyBoundariesDeclared [] -> Bool
  :d "Verifies that dependency-boundaries.asn declares host boundaries and forbids undeclared runtime deps"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "asl/grammar/dependency-boundaries.asn must exist")
    (let [(src (.-value d-res))]
      (assert (string-contains? src ":hostAdapter") "Must declare host adapter")
      (assert (string-contains? src ":tier :id \"deployed\"") "Must define deployed tier constraints")
      (assert (string-contains? src "zero host external runtime requirements") "Must enforce zero runtime requirements")
      true)))

(df TestCodegenBackendsAvailable [] -> Bool
  :d "Verifies that asl-codegen provides C and WAT emission backends for native and WASM closure"
  (let [(c-res (file-read "asl/packages/asl-codegen/src/emit-c.asl"))
        (w-res (file-read "asl/packages/asl-codegen/src/emit_wat.asl"))]
    (assert (= (.-_tag c-res) "ok") "emit-c.asl must exist")
    (assert (= (.-_tag w-res) "ok") "emit_wat.asl must exist")
    (let [(c-src (.-value c-res))
          (w-src (.-value w-res))]
      (assert (string-contains? c-src "emit") "emit-c must define emission routines")
      (assert (string-contains? w-src "emit") "emit_wat must define emission routines")
      true)))

(df TestBootstrapRebuildModule [] -> Bool
  :d "Verifies that asl/bench/bootstrap_rebuild.asl implements closure verification"
  (let [(r-res (file-read "asl/bench/bootstrap_rebuild.asl"))]
    (assert (= (.-_tag r-res) "ok") "asl/bench/bootstrap_rebuild.asl must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src "module asl-bench/bootstrap-rebuild")
              "bootstrap_rebuild.asl must declare module asl-bench/bootstrap-rebuild")
      (assert (string-contains? src "verify-bootstrap-closure")
              "Must define verify-bootstrap-closure function")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44002 supervisor acceptance tests"
  (do
    (assert (TestBootstrapContractSpecification) "TestBootstrapContractSpecification must pass")
    (assert (TestDependencyBoundariesDeclared) "TestDependencyBoundariesDeclared must pass")
    (assert (TestCodegenBackendsAvailable) "TestCodegenBackendsAvailable must pass")
    (assert (TestBootstrapRebuildModule) "TestBootstrapRebuildModule must pass")
    true))
