(module tests/acceptance/d81/Task44003
  :d "Acceptance fixture for Task44003: Route all tooling through the self-hosted native artifact under ADR-0081."
  :x [RunTests
      TestNativeToolingDispatchCoverage
      TestDeclaredHostBoundariesAndZeroRuntimeDeps
      TestPlatformAdapterContract
      TestToolingPackagesReachability]
  :i [])

(df TestNativeToolingDispatchCoverage [] -> Bool
  :d "Verifies that native toolchain specifies dispatch and released capabilities without third-party runtime"
  (let [(c-res (file-read "asl/packages/asl-cli/src/cli.asl"))
        (m-res (file-read "asl/packages/asl-cli/manifest.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl-cli/src/cli.asl must exist and be readable")
    (assert (= (.-_tag m-res) "ok") "asl-cli/manifest.asn must exist and be readable")
    (let [(src (.-value c-res))
          (m-src (.-value m-res))]
      (assert (string-contains? src "dispatch-cmd") "CLI must provide dispatch-cmd")
      (assert (string-contains? src "execute-cli") "CLI must provide execute-cli")
      (assert (string-contains? src "format-help") "CLI must provide format-help")
      (assert (string-contains? src "format-version") "CLI must provide format-version")
      (assert (string-contains? m-src ":asl-first true") "asl-cli must be :asl-first true")
      true)))

(df TestDeclaredHostBoundariesAndZeroRuntimeDeps [] -> Bool
  :d "Verifies that dependency-boundaries.asn enforces zero external runtime requirements"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist")
    (let [(src (.-value d-res))]
      (assert (string-contains? src ":hostAdapter") "Must declare hostAdapter boundary")
      (assert (string-contains? src ":tier :id \"deployed\"") "Must define deployed tier")
      (assert (string-contains? src "zero host external runtime requirements")
              "Deployed tier must forbid external runtimes")
      true)))

(df TestPlatformAdapterContract [] -> Bool
  :d "Verifies that asl/tools/platform/platform-adapter.asn declares OS/ABI capabilities and target formats"
  (let [(p-res (file-read "asl/tools/platform/platform-adapter.asn"))]
    (assert (= (.-_tag p-res) "ok") "platform-adapter.asn must exist and be readable")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":platformAdapter") "Must declare :platformAdapter")
      (assert (string-contains? src ":format \"Mach-O\"") "Must support Mach-O format")
      (assert (string-contains? src ":format \"ELF\"") "Must support ELF format")
      (assert (string-contains? src ":format \"PE\"") "Must support PE format")
      (assert (string-contains? src ":format \"WASM\"") "Must support WASM format")
      (assert (string-contains? src ":capabilities") "Must declare OS capabilities")
      true)))

(df TestToolingPackagesReachability [] -> Bool
  :d "Verifies that required tooling packages including asl-lint, asl-checker, and asl-codegen exist and are reachable"
  (let [(l-res (file-read "asl/packages/asl-lint/manifest.asn"))
        (chk-res (file-read "asl/packages/asl-checker/manifest.asn"))
        (cg-res (file-read "asl/packages/asl-codegen/manifest.asn"))
        (cp-res (file-read "asl/packages/asl-compiler/manifest.asn"))]
    (assert (= (.-_tag l-res) "ok") "asl-lint manifest must exist")
    (assert (= (.-_tag chk-res) "ok") "asl-checker manifest must exist")
    (assert (= (.-_tag cg-res) "ok") "asl-codegen manifest must exist")
    (assert (= (.-_tag cp-res) "ok") "asl-compiler manifest must exist")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task44003 supervisor acceptance tests"
  (do
    (assert (TestNativeToolingDispatchCoverage) "TestNativeToolingDispatchCoverage must pass")
    (assert (TestDeclaredHostBoundariesAndZeroRuntimeDeps) "TestDeclaredHostBoundariesAndZeroRuntimeDeps must pass")
    (assert (TestPlatformAdapterContract) "TestPlatformAdapterContract must pass")
    (assert (TestToolingPackagesReachability) "TestToolingPackagesReachability must pass")
    true))
