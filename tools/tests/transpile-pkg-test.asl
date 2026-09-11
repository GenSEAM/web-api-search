(module asl-tools-tests/transpile-pkg-test
  :d "Unit tests for pure ASL package transpiler"
  :x [test-create-package-spec
      test-format-package-json
      test-run-transpile-audit
      run-tests]
  :i [(asl-tools/transpile-pkg :a tp)])

(df test-create-package-spec [] -> Bool
  (let [(scripts (list (tp/PackageEntry :key "dev" :val "vite")))
        (deps (list (tp/PackageEntry :key "react" :val "^19.0.0")))
        (dev-deps (list (tp/PackageEntry :key "vite" :val "^6.0.3")))
        (spec (tp/create-package-spec "web" "0.1.0" true "MIT" "module" scripts deps dev-deps))]
    (assert (== (.-name spec) "web") "name must equal web")
    (assert (== (.-version spec) "0.1.0") "version must equal 0.1.0")
    (assert (.-is-private spec) "is-private must be true")
    (assert (== (.-license spec) "MIT") "license must equal MIT")
    (assert (== (.-pkg-type spec) "module") "pkg-type must equal module")
    (assert (== (list-length (.-scripts spec)) 1) "scripts length must be 1")
    (assert (== (list-length (.-dependencies spec)) 1) "dependencies length must be 1")
    (assert (== (list-length (.-dev-dependencies spec)) 1) "dev-dependencies length must be 1")
    true))

(df test-format-package-json [] -> Bool
  (let [(scripts (list (tp/PackageEntry :key "build" :val "vite build")))
        (deps (list (tp/PackageEntry :key "lucide-react" :val "^1.16.0")))
        (dev-deps (list (tp/PackageEntry :key "tailwindcss" :val "^3.4.17")))
        (spec (tp/create-package-spec "agentscript-showcase" "0.1.0" true "MIT OR Apache-2.0" "module" scripts deps dev-deps))
        (json-str (tp/format-package-json spec))]
    (assert (string-contains? json-str "\"name\": \"agentscript-showcase\"") "json-str must contain name")
    (assert (string-contains? json-str "\"private\": true") "json-str must contain private")
    (assert (string-contains? json-str "\"lucide-react\": \"^1.16.0\"") "json-str must contain lucide-react")
    (assert (string-contains? json-str "\"tailwindcss\": \"^3.4.17\"") "json-str must contain tailwindcss")
    true))

(df test-run-transpile-audit [] -> Bool
  (do
    (assert (tp/run-transpile-audit) "run-transpile-audit must pass")
    (assert (not (nil? (tp/run-transpile-audit))) "transpile audit must not be nil")
    true))

(df run-tests [] -> Bool
  (do
    (assert (test-create-package-spec) "test-create-package-spec must pass")
    (assert (test-format-package-json) "test-format-package-json must pass")
    (assert (test-run-transpile-audit) "test-run-transpile-audit must pass")
    true))
