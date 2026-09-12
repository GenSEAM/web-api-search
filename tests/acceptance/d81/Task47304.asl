(module tests/acceptance/d81/Task47304
  :d "Acceptance fixture for Task47304: workspace and coverage paths describe actual repository shape under ADR-0081."
  :x [RunTests
      TestPnpmWorkspaceMatchesActualPackages
      TestAslSubmoduleCoveragePackagesExist
      TestRootConfigCoveragePackagesExist]
  :i [])

(df TestPnpmWorkspaceMatchesActualPackages [] -> Bool
  :d "Verifies that pnpm-workspace.yaml only includes packages with existing package.json manifests"
  (let [(ws-res (file-read "pnpm-workspace.yaml"))]
    (assert (= (.-_tag ws-res) "ok") "pnpm-workspace.yaml must exist and be readable")
    (let [(ws (.-value ws-res))]
      (assert (string-contains? ws "asl") "pnpm-workspace.yaml must include asl")
      (assert (string-contains? ws "asl/web") "pnpm-workspace.yaml must include asl/web")
      (assert (not (string-contains? ws "crawler"))
              "pnpm-workspace.yaml must not include non-JS crawler")
      (assert (not (string-contains? ws "harness"))
              "pnpm-workspace.yaml must not include non-JS harness")
      (assert (not (string-contains? ws "agent-core"))
              "pnpm-workspace.yaml must not include non-JS agent-core")
      (assert (not (string-contains? ws "mem"))
              "pnpm-workspace.yaml must not include non-JS mem")
      true)))

(df TestAslSubmoduleCoveragePackagesExist [] -> Bool
  :d "Verifies that asl/.asl.config.asn coverage core-packages only lists paths existing in asl submodule"
  (let [(cfg-res (file-read "asl/.asl.config.asn"))]
    (assert (= (.-_tag cfg-res) "ok") "asl/.asl.config.asn must exist and be readable")
    (let [(cfg (.-value cfg-res))]
      (assert (string-contains? cfg "\"packages/asl-compiler\"")
              "asl/.asl.config.asn must include packages/asl-compiler")
      (assert (string-contains? cfg "\"packages/asl-parser\"")
              "asl/.asl.config.asn must include packages/asl-parser")
      (assert (not (string-contains? cfg "\"agent-core\""))
              "asl/.asl.config.asn must not name nonexistent agent-core")
      (assert (not (string-contains? cfg "\"crawler\""))
              "asl/.asl.config.asn must not name nonexistent crawler")
      (assert (not (string-contains? cfg "\"browser-plugin\""))
              "asl/.asl.config.asn must not name nonexistent browser-plugin")
      (assert (not (string-contains? cfg "\"web-api-search\""))
              "asl/.asl.config.asn must not name nonexistent web-api-search")
      true)))

(df TestRootConfigCoveragePackagesExist [] -> Bool
  :d "Verifies that root .asl.config.asn coverage core-packages all exist in monorepo"
  (let [(cfg-res (file-read ".asl.config.asn"))]
    (assert (= (.-_tag cfg-res) "ok") ".asl.config.asn must exist and be readable")
    (let [(cfg (.-value cfg-res))]
      (assert (string-contains? cfg "\"agent-core\"")
              ".asl.config.asn must include agent-core")
      (assert (string-contains? cfg "\"asl/packages/asl-compiler\"")
              ".asl.config.asn must include asl/packages/asl-compiler")
      (assert (string-contains? cfg "\"asl/packages/asl-parser\"")
              ".asl.config.asn must include asl/packages/asl-parser")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47304 supervisor acceptance tests"
  (do
    (assert (TestPnpmWorkspaceMatchesActualPackages) "TestPnpmWorkspaceMatchesActualPackages must pass")
    (assert (TestAslSubmoduleCoveragePackagesExist) "TestAslSubmoduleCoveragePackagesExist must pass")
    (assert (TestRootConfigCoveragePackagesExist) "TestRootConfigCoveragePackagesExist must pass")
    true))
