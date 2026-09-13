(module aslToolsTests/transpilePkgTest
  :d "Unit tests for pure ASL package transpiler"
  :x [testCreatePackageSpec
      testFormatPackageJson
      testRunTranspileAudit
      runTests]
  :i [(aslTools/transpilePkg :a tp)])

(df testCreatePackageSpec [] -> Bool
  (let [(scripts (list (tp/PackageEntry :key "dev" :val "vite")))
        (deps (list (tp/PackageEntry :key "react" :val "^19.0.0")))
        (devDeps (list (tp/PackageEntry :key "vite" :val "^6.0.3")))
        (spec (tp/createPackageSpec "web" "0.1.0" true "MIT" "module" scripts deps devDeps))]
    (assert (== (.-name spec) "web") "name must equal web")
    (assert (== (.-version spec) "0.1.0") "version must equal 0.1.0")
    (assert (.-isPrivate spec) "is-private must be true")
    (assert (== (.-license spec) "MIT") "license must equal MIT")
    (assert (== (.-pkgType spec) "module") "pkg-type must equal module")
    (assert (== (list-length (.-scripts spec)) 1) "scripts length must be 1")
    (assert (== (list-length (.-dependencies spec)) 1) "dependencies length must be 1")
    (assert (== (list-length (.-devDependencies spec)) 1) "dev-dependencies length must be 1")
    true))

(df testFormatPackageJson [] -> Bool
  (let [(scripts (list (tp/PackageEntry :key "build" :val "vite build")))
        (deps (list (tp/PackageEntry :key "lucide-react" :val "^1.16.0")))
        (devDeps (list (tp/PackageEntry :key "tailwindcss" :val "^3.4.17")))
        (spec (tp/createPackageSpec "agentscript-showcase" "0.1.0" true "MIT OR Apache-2.0" "module" scripts deps devDeps))
        (jsonStr (tp/formatPackageJson spec))]
    (assert (string-contains? jsonStr "\"name\": \"agentscript-showcase\"") "json-str must contain name")
    (assert (string-contains? jsonStr "\"private\": true") "json-str must contain private")
    (assert (string-contains? jsonStr "\"lucide-react\": \"^1.16.0\"") "json-str must contain lucide-react")
    (assert (string-contains? jsonStr "\"tailwindcss\": \"^3.4.17\"") "json-str must contain tailwindcss")
    true))

(df testRunTranspileAudit [] -> Bool
  (do
    (assert (tp/runTranspileAudit) "run-transpile-audit must pass")
    (assert (not (nil? (tp/runTranspileAudit))) "transpile audit must not be nil")
    true))

(df runTests [] -> Bool
  (do
    (assert (testCreatePackageSpec) "test-create-package-spec must pass")
    (assert (testFormatPackageJson) "test-format-package-json must pass")
    (assert (testRunTranspileAudit) "test-run-transpile-audit must pass")
    true))
