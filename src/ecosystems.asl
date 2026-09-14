(module aslWebApiSearch/ecosystems
  :d "Package ecosystem search, code library intelligence, and deep link traversal in ASL Nano."
  :x [PackageInfo PackageEcosystem DeepLinkTarget buildEcosystemUrl buildPackageCurlCmd formatPackageMarkdown formatEcosystemRag createDeepTargets]
  :i [(engine :a eng)])

(dfs PackageInfo
  (:f name Str "Package or library name")
  (:f ecosystem Str "Ecosystem identifier (npm, pypi, crates, go, github, c)")
  (:f version Str "Latest or specified version string")
  (:f description Str "Package summary description")
  (:f repoUrl Str "Repository or package URL")
  (:f popularity I64 "Stars, downloads, or score metric"))

(dfe PackageEcosystem
  (:c npm [] "Node/npm ecosystem")
  (:c pypi [] "Python/PyPI ecosystem")
  (:c crates [] "Rust/crates.io ecosystem")
  (:c go [] "Go packages ecosystem")
  (:c github [] "GitHub repositories")
  (:c clib [] "C/C++ systems libraries"))

(dfs DeepLinkTarget
  (:f url Str "Target web page URL")
  (:f parentQuery Str "Source search query")
  (:f depth I64 "Crawl depth level"))

(df buildEcosystemUrl [(eco Str) (query Str) (limit I64)] -> Str
  :d "Constructs search API endpoint for the target package registry."
  (let [(q1 (string-replace query "%" "%25"))
        (q2 (string-replace q1 " " "+"))
        (q3 (string-replace q2 "&" "%26"))
        (q4 (string-replace q3 "?" "%3F"))
        (q5 (string-replace q4 "#" "%23"))
        (q6 (string-replace q5 "/" "%2F"))
        (cleanQ q6)
        (limStr (string-from-int64 limit))]
    (cond
      ((= eco "npm")
       (str "https://registry.npmjs.org/-/v1/search?text=" cleanQ "&size=" limStr))
      ((= eco "crates")
       (str "https://crates.io/api/v1/crates?q=" cleanQ "&per_page=" limStr))
      ((= eco "pypi")
       (str "https://pypi.org/search/?q=" cleanQ))
      ((= eco "go")
       (str "https://pkg.go.dev/search?q=" cleanQ))
      ((= eco "c")
       (str "https://api.github.com/search/repositories?q=" cleanQ "+language:C&per_page=" limStr))
      (:else
       (str "https://api.github.com/search/repositories?q=" cleanQ "&per_page=" limStr)))))

(df buildPackageCurlCmd [(eco Str) (query Str) (limit I64)] -> eng/CurlCommand
  :d "Constructs typed curl command vector with registry-specific headers."
  (let [(url (buildEcosystemUrl eco query limit))
        (ua (cond
              ((= eco "crates") "ASL-AgentSearch/1.0 (https://aslang.dev)")
              ((= eco "github") "ASL-AgentSearch/1.0")
              (:else "Mozilla/5.0 (ASL-Agent/1.0)")))
        (headers (cond
                   ((= eco "npm") (list "-H" "Accept: application/json" "-H" (str "User-Agent: " ua)))
                   ((= eco "github") (list "-H" "Accept: application/vnd.github.v3+json" "-H" (str "User-Agent: " ua)))
                   (:else (list "-H" (str "User-Agent: " ua)))))]
    (eng/CurlCommand
      :bin "curl"
      :args (list-append (list "-s" "--max-time" "5")
                         (list-append headers (list "--" url)))
      :url url)))

(df formatPackageMarkdown [(pkg PackageInfo)] -> Str
  :d "Formats single package record as markdown citation."
  (str "**[" (.-name pkg) "](" (.-repoUrl pkg) ")**  `[" (.-ecosystem pkg) " - v" (.-version pkg) "]` (stars/dl: " (string-from-int64 (.-popularity pkg)) ")\n   "
       (.-description pkg) "\n"))

(df formatEcosystemRag [(query Str) (packages (List PackageInfo))] -> Str
  :d "Formats list of ecosystem packages into RAG prompt context."
  (let [(header (str "## Ecosystem Packages for: '" query "' (" (string-from-int64 (list-length packages)) " packages)\n\n"))
        (rows (map formatPackageMarkdown packages))]
    (str header (string-join rows "\n"))))

(df createDeepTargets [(results (List eng/SearchResult)) (maxDepth I64)] -> (List DeepLinkTarget)
  :d "Extracts target URLs from top search results for deep crawling."
  (map (fn [(r eng/SearchResult)] -> DeepLinkTarget
         (DeepLinkTarget
           :url (.-url r)
           :parentQuery (.-title r)
           :depth maxDepth))
       results))
