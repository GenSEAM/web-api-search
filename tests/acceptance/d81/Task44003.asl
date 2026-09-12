(module tests/acceptance/d81/Task44003
  :d "Acceptance fixture for Task44003: Route all tooling through the self-hosted native artifact under ADR-0081."
  :x [RunTests
      TestCliCapabilityDispatchAndHelp
      TestDependencyBoundariesAndDeclaredHostAdapter
      TestPackageReachabilityAndLint
      TestHostAdapterDeclaredBoundary]
  :i [])

(df TestCliCapabilityDispatchAndHelp [] -> Bool
  :d "Verifies that asl-cli implements native CLI capability dispatch, usage help, and command routing"
  (let [(c-res (file-read "asl/packages/asl-cli/src/cli.asl"))]
    (assert (= (.-_tag c-res) "ok") "asl/packages/asl-cli/src/cli.asl must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "module asl-cli/cli") "cli.asl must declare module asl-cli/cli")
      (assert (string-contains? src "format-version") "cli.asl must define format-version")
      (assert (string-contains? src "format-help") "cli.asl must define format-help")
      (assert (string-contains? src "dispatch-cmd") "cli.asl must define dispatch-cmd")
      (assert (string-contains? src "execute-cli") "cli.asl must define execute-cli")
      (assert (string-contains? src "check <file>") "cli.asl help must document check command")
      (assert (string-contains? src "lint <file>") "cli.asl help must document lint command")
      (assert (string-contains? src "gate [files]") "cli.asl help must document gate command")
      true)))

(df TestDependencyBoundariesAndDeclaredHostAdapter [] -> Bool
  :d "Verifies dependency boundaries and zero undeclared runtime requirement in deployed tier"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "asl/grammar/dependency-boundaries.asn must exist")
    (let [(src (.-value d-res))]
      (assert (string-contains? src ":hostAdapter (:path \"asl/tools/asl.c\"") "Must declare asl.c as host adapter")
      (assert (string-contains? src ":tier :id \"deployed\"") "Must declare deployed tier")
      (assert (string-contains? src "zero host external runtime requirements") "Must enforce zero runtime deps")
      (assert (string-contains? src ":tier :id \"bootstrap\"") "Must declare bootstrap tier")
      (assert (string-contains? src ":tier :id \"build\"") "Must declare build tier")
      (assert (string-contains? src ":tier :id \"test\"") "Must declare test tier")
      true)))

(df TestPackageReachabilityAndLint [] -> Bool
  :d "Verifies that core toolchain packages including asl-lint remain reachable pure ASL packages"
  (let [(l-res (file-read "asl/packages/asl-lint/manifest.asn"))
        (k-res (file-read "asl/packages/asl-checker/manifest.asn"))
        (g-res (file-read "asl/packages/asl-gates/manifest.asn"))
        (c-res (file-read "asl/packages/asl-cli/manifest.asn"))]
    (assert (= (.-_tag l-res) "ok") "asl-lint manifest must exist")
    (assert (= (.-_tag k-res) "ok") "asl-checker manifest must exist")
    (assert (= (.-_tag g-res) "ok") "asl-gates manifest must exist")
    (assert (= (.-_tag c-res) "ok") "asl-cli manifest must exist")
    (let [(l-src (.-value l-res))
          (k-src (.-value k-res))
          (g-src (.-value g-res))
          (c-src (.-value c-res))]
      (assert (string-contains? l-src "(:package asl-lint") "Must declare package asl-lint")
      (assert (string-contains? k-src "(:package asl-checker") "Must declare package asl-checker")
      (assert (string-contains? g-src "(:package asl-gates") "Must declare package asl-gates")
      (assert (string-contains? c-src "(:package asl-cli") "Must declare package asl-cli")
      true)))

(df TestHostAdapterDeclaredBoundary [] -> Bool
  :d "Verifies that host adapter source exists at declared boundary"
  (let [(a-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag a-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value a-res))]
      (assert (string-contains? src "ASL_SOURCE_DIGEST") "Host adapter must embed source digest")
      (assert (string-contains? src "run_evaluator") "Host adapter must provide execution boundary")
      (assert (string-contains? src "find_ws_root") "Host adapter must discover workspace root")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44003 supervisor acceptance tests"
  (do
    (assert (TestCliCapabilityDispatchAndHelp) "TestCliCapabilityDispatchAndHelp must pass")
    (assert (TestDependencyBoundariesAndDeclaredHostAdapter) "TestDependencyBoundariesAndDeclaredHostAdapter must pass")
    (assert (TestPackageReachabilityAndLint) "TestPackageReachabilityAndLint must pass")
    (assert (TestHostAdapterDeclaredBoundary) "TestHostAdapterDeclaredBoundary must pass")
    true))
