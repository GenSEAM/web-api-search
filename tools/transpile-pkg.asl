(module asl-tools/transpile-pkg
  :d "Pure ASL transpiler from ASN package specifications to standard package.json."
  :x [PackageEntry
      PackageSpec
      create-package-spec
      format-package-json
      strip-asn-type-tag
      run-transpile-audit]
  :i [])

(dfs PackageEntry
  (:f key Str "Package property key")
  (:f val Str "Package property value"))

(dfs PackageSpec
  (:f name Str "Package name")
  (:f version Str "Semantic version")
  (:f is-private Bool "Private package flag")
  (:f license Str "Package license")
  (:f pkg-type Str "Module type")
  (:f scripts (List PackageEntry) "Executable script commands")
  (:f dependencies (List PackageEntry) "Production dependencies")
  (:f dev-dependencies (List PackageEntry) "Development dependencies"))

(df create-package-spec [(name Str)
                         (version Str)
                         (is-private Bool)
                         (license Str)
                         (pkg-type Str)
                         (scripts (List PackageEntry))
                         (deps (List PackageEntry))
                         (dev-deps (List PackageEntry))] -> PackageSpec
  :d "Constructs a PackageSpec record."
  (PackageSpec
    :name name
    :version version
    :is-private is-private
    :license license
    :pkg-type pkg-type
    :scripts scripts
    :dependencies deps
    :dev-dependencies dev-deps))

(df format-entry-list [(entries (List PackageEntry)) (indent Str)] -> Str
  :d "Formats a list of key-value pairs as a JSON object."
  (let [(len (list-length entries))]
    (if (== len 0)
        "{}"
        (let [(lines (foldl (fn [(acc Str) (entry PackageEntry)] -> Str
                              (let [(k (.-key entry))
                                    (v (.-val entry))
                                    (line (str indent "    \"" k "\": \"" v "\""))]
                                (if (== acc "")
                                    line
                                    (str acc ",\n" line))))
                            ""
                            entries))]
          (str "{\n" lines "\n" indent "  }")))))

(df format-package-json [(spec PackageSpec)] -> Str
  :d "Formats a PackageSpec into standard pretty-printed JSON string."
  (str "{\n"
       "  \"name\": \"" (.-name spec) "\",\n"
       "  \"private\": " (if (.-is-private spec) "true" "false") ",\n"
       "  \"version\": \"" (.-version spec) "\",\n"
       "  \"license\": \"" (.-license spec) "\",\n"
       "  \"type\": \"" (.-pkg-type spec) "\",\n"
       "  \"scripts\": " (format-entry-list (.-scripts spec) "") ",\n"
       "  \"dependencies\": " (format-entry-list (.-dependencies spec) "") ",\n"
       "  \"devDependencies\": " (format-entry-list (.-dev-dependencies spec) "") "\n"
       "}\n"))

(df strip-asn-type-tag [(raw-json Str)] -> Str
  :d "Removes the synthetic '_type': '...' line from transpiled ASN JSON output."
  (if (string-contains? raw-json "\"_type\":")
    (let [(lines (string-split raw-json "\n"))
          (res (foldl (fn [(acc Str) (line Str)] -> Str
                        (if (string-contains? line "\"_type\":")
                          acc
                          (if (== acc "")
                            line
                            (str acc "\n" line))))
                      ""
                      lines))]
      res)
    raw-json))

(df run-transpile-audit [] -> Bool
  :d "Audits that package spec transpilation satisfies pure ASL criteria."
  (let [(scripts (list (PackageEntry :key "dev" :val "vite")
                       (PackageEntry :key "build" :val "vite build")))
        (deps (list (PackageEntry :key "react" :val "^19.0.0")
                    (PackageEntry :key "react-dom" :val "^19.0.0")))
        (dev-deps (list (PackageEntry :key "vite" :val "^6.0.3")))
        (spec (create-package-spec "agentscript-showcase"
                                   "0.1.0"
                                   true
                                   "MIT OR Apache-2.0"
                                   "module"
                                   scripts
                                   deps
                                   dev-deps))
        (json-out (format-package-json spec))]
    (and (string-contains? json-out "\"name\": \"agentscript-showcase\"")
         (string-contains? json-out "\"react\": \"^19.0.0\"")
         (string-contains? json-out "\"vite\": \"^6.0.3\"")
         (not (string-contains? json-out "\"typescript\"")))))
