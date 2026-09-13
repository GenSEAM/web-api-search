(module aslTools/transpilePkg
  :d "Pure ASL transpiler from ASN package specifications to standard package.json."
  :x [PackageEntry
      PackageSpec
      createPackageSpec
      formatPackageJson
      stripAsnTypeTag
      runTranspileAudit]
  :i [])

(dfs PackageEntry
  (:f key Str "Package property key")
  (:f val Str "Package property value"))

(dfs PackageSpec
  (:f name Str "Package name")
  (:f version Str "Semantic version")
  (:f isPrivate Bool "Private package flag")
  (:f license Str "Package license")
  (:f pkgType Str "Module type")
  (:f scripts (List PackageEntry) "Executable script commands")
  (:f dependencies (List PackageEntry) "Production dependencies")
  (:f devDependencies (List PackageEntry) "Development dependencies"))

(df createPackageSpec [(name Str)
                         (version Str)
                         (isPrivate Bool)
                         (license Str)
                         (pkgType Str)
                         (scripts (List PackageEntry))
                         (deps (List PackageEntry))
                         (devDeps (List PackageEntry))] -> PackageSpec
  :d "Constructs a PackageSpec record."
  (PackageSpec
    :name name
    :version version
    :isPrivate isPrivate
    :license license
    :pkgType pkgType
    :scripts scripts
    :dependencies deps
    :devDependencies devDeps))

(df formatEntryList [(entries (List PackageEntry)) (indent Str)] -> Str
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

(df formatPackageJson [(spec PackageSpec)] -> Str
  :d "Formats a PackageSpec into standard pretty-printed JSON string."
  (str "{\n"
       "  \"name\": \"" (.-name spec) "\",\n"
       "  \"private\": " (if (.-isPrivate spec) "true" "false") ",\n"
       "  \"version\": \"" (.-version spec) "\",\n"
       "  \"license\": \"" (.-license spec) "\",\n"
       "  \"type\": \"" (.-pkgType spec) "\",\n"
       "  \"scripts\": " (formatEntryList (.-scripts spec) "") ",\n"
       "  \"dependencies\": " (formatEntryList (.-dependencies spec) "") ",\n"
       "  \"devDependencies\": " (formatEntryList (.-devDependencies spec) "") "\n"
       "}\n"))

(df stripAsnTypeTag [(rawJson Str)] -> Str
  :d "Removes the synthetic '_type': '...' line from transpiled ASN JSON output."
  (if (string-contains? rawJson "\"_type\":")
    (let [(lines (string-split rawJson "\n"))
          (res (foldl (fn [(acc Str) (line Str)] -> Str
                        (if (string-contains? line "\"_type\":")
                          acc
                          (if (== acc "")
                            line
                            (str acc "\n" line))))
                      ""
                      lines))]
      res)
    rawJson))

(df runTranspileAudit [] -> Bool
  :d "Audits that package spec transpilation satisfies pure ASL criteria."
  (let [(scripts (list (PackageEntry :key "dev" :val "vite")
                       (PackageEntry :key "build" :val "vite build")))
        (deps (list (PackageEntry :key "react" :val "^19.0.0")
                    (PackageEntry :key "react-dom" :val "^19.0.0")))
        (devDeps (list (PackageEntry :key "vite" :val "^6.0.3")))
        (spec (createPackageSpec "agentscript-showcase"
                                   "0.1.0"
                                   true
                                   "MIT OR Apache-2.0"
                                   "module"
                                   scripts
                                   deps
                                   devDeps))
        (jsonOut (formatPackageJson spec))]
    (and (string-contains? jsonOut "\"name\": \"agentscript-showcase\"")
         (string-contains? jsonOut "\"react\": \"^19.0.0\"")
         (string-contains? jsonOut "\"vite\": \"^6.0.3\"")
         (not (string-contains? jsonOut "\"typescript\"")))))
