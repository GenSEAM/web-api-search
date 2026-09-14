(module aslWebApiSearch/tests/searchTest
  :d "Unit tests for multi-engine API search aggregator, bipolar query generator, and ecosystem intelligence in ASL"
  :x [runTests
      testBipolarQueryGeneration]
  :i [(engine :a eng)
      (ecosystems :a eco)])

(df testUrlBuilders [] -> Bool
  :d "Verifies query endpoint generation for search providers."
  (let [(gh (eng/buildSearchUrl "github" "agent script" 5))
        (ddg (eng/buildSearchUrl "ddg" "agent script" 5))
        (tavily (eng/buildSearchUrl "tavily" "ai agents" 3))
        (searx (eng/buildSearchUrl "searxng" "agents" 5))]
    (assert (= gh "https://api.github.com/search/repositories?q=agent%20script&per_page=5") "GitHub URL must match")
    (assert (= ddg "https://html.duckduckgo.com/html/?q=agent%20script") "DDG URL must match")
    (assert (string-contains? tavily "api.tavily.com") "Tavily URL must contain api domain")
    (assert (string-contains? searx "searx.be") "SearXNG URL must contain domain")
    true))

(df testProviderCurlCmds [] -> Bool
  :d "Verifies authenticated curl commands for search APIs."
  (let [(cmdTavily (eng/buildProviderCurlCmd "tavily" "https://api.tavily.com/search" "tvly-secret" 10))
        (cmdSerper (eng/buildProviderCurlCmd "serper" "https://google.serper.dev/search" "serper-secret" 5))]
    (assert (list-contains? (.-args cmdTavily) "Authorization: Bearer tvly-secret") "Tavily auth header must be present")
    (assert (list-contains? (.-args cmdSerper) "X-API-KEY: serper-secret") "Serper API key must be present")
    true))

(df testUrlCleaning [] -> Bool
  :d "Verifies tracking parameter removal from URLs."
  (let [(cleaned1 (eng/cleanUrl "https://example.com/item?utm_source=twitter&id=42"))
        (cleaned2 (eng/cleanUrl "https://example.com/docs"))]
    (assert (= cleaned1 "https://example.com/item?id=42") "UTM tracking parameters must be stripped")
    (assert (= cleaned2 "https://example.com/docs") "Clean URL must remain unmodified")
    true))

(df testProxyHealth [] -> Bool
  :d "Verifies proxy health check logic."
  (let [(goodProxy (eng/ProxyNode :endpoint "http://proxy1:8080" :state (eng/active) :latencyMs 120.0 :successRate 0.98))
        (slowProxy (eng/ProxyNode :endpoint "http://proxy2:8080" :state (eng/active) :latencyMs 800.0 :successRate 0.95))
        (pool (list goodProxy slowProxy))
        (healthy (eng/selectHealthyProxies pool))]
    (assert (eng/isProxyHealthy goodProxy) "Low-latency high-success proxy must be healthy")
    (assert (not (eng/isProxyHealthy slowProxy)) "High-latency proxy must be unhealthy")
    (assert (= (list-length healthy) 1) "Healthy pool must contain 1 node")
    true))

(df testResultMerge [] -> Bool
  :d "Verifies cross-engine result deduplication and score boosting."
  (let [(r1 (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "Lang" :engine "ddg" :score 1.0))
        (r2 (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "The Missing Seam" :engine "github" :score 1.05))
        (merged (eng/mergeSearchResults (list r1) (list r2)))]
    (assert (= (list-length merged) 1) "Merged results must deduplicate identical URLs")
    (mt (list-head merged)
      ((none) (assert false "Merged head must exist"))
      ((some top)
       (assert (> (.-score top) 2.0) "Boosted score must exceed 2.0")
       (assert (= (.-engine top) "ddg+github") "Combined engines must be ddg+github")))
    true))

(df testRagFormatting [] -> Bool
  :d "Verifies markdown formatting for LLM context injection."
  (let [(r (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "Infrastructure Seam" :engine "github" :score 1.0))
        (md (eng/formatRagContext "asl" (list r)))]
    (assert (string-contains? md "## Search Results for: 'asl' (1 items)") "RAG context header must match")
    (assert (string-contains? md "Infrastructure Seam") "RAG context must contain snippet")
    true))

(df testEcosystems [] -> Bool
  :d "Verifies ecosystem package search URL generation and formatting."
  (let [(npmUrl (eco/buildEcosystemUrl "npm" "agentscript" 5))
        (cratesUrl (eco/buildEcosystemUrl "crates" "serde" 3))
        (pkg (eco/PackageInfo :name "serde" :ecosystem "crates" :version "1.0.210" :description "Serialization" :repoUrl "https://crates.io/crates/serde" :popularity 100000))
        (pkgMd (eco/formatPackageMarkdown pkg))
        (deep (eco/createDeepTargets (list (eng/SearchResult :title "Docs" :url "https://aslang.dev" :snippet "S" :engine "ddg" :score 1.0)) 2))]
    (assert (string-contains? npmUrl "registry.npmjs.org") "NPM search URL must target registry")
    (assert (string-contains? cratesUrl "crates.io/api") "Crates search URL must target API")
    (assert (string-contains? pkgMd "serde") "Package markdown must contain package name")
    (assert (= (list-length deep) 1) "Deep link targets count must be 1")
    true))

(df testBipolarQueryGeneration [] -> Bool
  :d "Verifies dialectical positive and negative query generation across domains."
  (let [(q1 (eng/generateBipolarQuery "AgentScript Wasm sandbox performance" "architecture"))
        (q2 (eng/generateBipolarQuery "contract liability limitation" "legal"))]
    (assert (string-contains? (.-positiveQuery q1) "AgentScript Wasm sandbox performance") "Positive query must retain claim")
    (assert (string-contains? (.-positiveQuery q1) "advantages") "Architecture positive query must include advantages")
    (assert (string-contains? (.-negativeQuery q1) "bottleneck") "Architecture negative query must include bottleneck")
    (assert (string-contains? (.-negativeQuery q1) "-hype") "Architecture negative query must include exclusion token")
    (assert (string-contains? (.-positiveQuery q2) "statute") "Legal positive query must include statute")
    (assert (string-contains? (.-negativeQuery q2) "violation") "Legal negative query must include violation")
    true))

(df runTests [] -> Bool
  :d "Runs all asl-search unit tests."
  (and (testUrlBuilders)
       (and (testProviderCurlCmds)
            (and (testUrlCleaning)
                 (and (testProxyHealth)
                      (and (testResultMerge)
                           (and (testRagFormatting)
                                (and (testEcosystems)
                                     (testBipolarQueryGeneration)))))))))



