(module asl-web-api-search/tests/search-test
  :d "Unit tests for multi-engine API search aggregator, bipolar query generator, and ecosystem intelligence in ASL"
  :x [run-tests
      test-bipolar-query-generation]
  :i [(engine :a eng)
      (ecosystems :a eco)])

(df test-url-builders [] -> Bool
  :d "Verifies query endpoint generation for search providers."
  (let [(gh (eng/build-search-url "github" "agent script" 5))
        (ddg (eng/build-search-url "ddg" "agent script" 5))
        (tavily (eng/build-search-url "tavily" "ai agents" 3))
        (searx (eng/build-search-url "searxng" "agents" 5))]
    (assert (= gh "https://api.github.com/search/repositories?q=agent+script&per_page=5") "GitHub URL must match")
    (assert (= ddg "https://html.duckduckgo.com/html/?q=agent+script") "DDG URL must match")
    (assert (string-contains? tavily "api.tavily.com") "Tavily URL must contain api domain")
    (assert (string-contains? searx "searx.be") "SearXNG URL must contain domain")
    true))

(df test-provider-curl-cmds [] -> Bool
  :d "Verifies authenticated curl commands for search APIs."
  (let [(cmd-tavily (eng/build-provider-curl-cmd "tavily" "https://api.tavily.com/search" "tvly-secret" 10))
        (cmd-serper (eng/build-provider-curl-cmd "serper" "https://google.serper.dev/search" "serper-secret" 5))]
    (assert (list-contains? (.-args cmd-tavily) "Authorization: Bearer tvly-secret") "Tavily auth header must be present")
    (assert (list-contains? (.-args cmd-serper) "X-API-KEY: serper-secret") "Serper API key must be present")
    true))

(df test-url-cleaning [] -> Bool
  :d "Verifies tracking parameter removal from URLs."
  (let [(cleaned1 (eng/clean-url "https://example.com/item?utm_source=twitter&id=42"))
        (cleaned2 (eng/clean-url "https://example.com/docs"))]
    (assert (= cleaned1 "https://example.com/item?id=42") "UTM tracking parameters must be stripped")
    (assert (= cleaned2 "https://example.com/docs") "Clean URL must remain unmodified")
    true))

(df test-proxy-health [] -> Bool
  :d "Verifies proxy health check logic."
  (let [(good-proxy (eng/ProxyNode :endpoint "http://proxy1:8080" :state (eng/active) :latency-ms 120.0 :success-rate 0.98))
        (slow-proxy (eng/ProxyNode :endpoint "http://proxy2:8080" :state (eng/active) :latency-ms 800.0 :success-rate 0.95))
        (pool (list good-proxy slow-proxy))
        (healthy (eng/select-healthy-proxies pool))]
    (assert (eng/is-proxy-healthy good-proxy) "Low-latency high-success proxy must be healthy")
    (assert (not (eng/is-proxy-healthy slow-proxy)) "High-latency proxy must be unhealthy")
    (assert (= (list-length healthy) 1) "Healthy pool must contain 1 node")
    true))

(df test-result-merge [] -> Bool
  :d "Verifies cross-engine result deduplication and score boosting."
  (let [(r1 (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "Lang" :engine "ddg" :score 1.0))
        (r2 (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "The Missing Seam" :engine "github" :score 1.05))
        (merged (eng/merge-search-results (list r1) (list r2)))]
    (assert (= (list-length merged) 1) "Merged results must deduplicate identical URLs")
    (mt (list-head merged)
      ((none) (assert false "Merged head must exist"))
      ((some top)
       (assert (> (.-score top) 2.0) "Boosted score must exceed 2.0")
       (assert (= (.-engine top) "ddg+github") "Combined engines must be ddg+github")))
    true))

(df test-rag-formatting [] -> Bool
  :d "Verifies markdown formatting for LLM context injection."
  (let [(r (eng/SearchResult :title "ASL" :url "https://aslang.dev" :snippet "Infrastructure Seam" :engine "github" :score 1.0))
        (md (eng/format-rag-context "asl" (list r)))]
    (assert (string-contains? md "## Search Results for: 'asl' (1 items)") "RAG context header must match")
    (assert (string-contains? md "Infrastructure Seam") "RAG context must contain snippet")
    true))

(df test-ecosystems [] -> Bool
  :d "Verifies ecosystem package search URL generation and formatting."
  (let [(npm-url (eco/build-ecosystem-url "npm" "agentscript" 5))
        (crates-url (eco/build-ecosystem-url "crates" "serde" 3))
        (pkg (eco/PackageInfo :name "serde" :ecosystem "crates" :version "1.0.210" :description "Serialization" :repo-url "https://crates.io/crates/serde" :popularity 100000))
        (pkg-md (eco/format-package-markdown pkg))
        (deep (eco/create-deep-targets (list (eng/SearchResult :title "Docs" :url "https://aslang.dev" :snippet "S" :engine "ddg" :score 1.0)) 2))]
    (assert (string-contains? npm-url "registry.npmjs.org") "NPM search URL must target registry")
    (assert (string-contains? crates-url "crates.io/api") "Crates search URL must target API")
    (assert (string-contains? pkg-md "serde") "Package markdown must contain package name")
    (assert (= (list-length deep) 1) "Deep link targets count must be 1")
    true))

(df test-bipolar-query-generation [] -> Bool
  :d "Verifies dialectical positive and negative query generation across domains."
  (let [(q1 (eng/generate-bipolar-query "AgentScript Wasm sandbox performance" "architecture"))
        (q2 (eng/generate-bipolar-query "contract liability limitation" "legal"))]
    (assert (string-contains? (.-positive-query q1) "AgentScript Wasm sandbox performance") "Positive query must retain claim")
    (assert (string-contains? (.-positive-query q1) "advantages") "Architecture positive query must include advantages")
    (assert (string-contains? (.-negative-query q1) "bottleneck") "Architecture negative query must include bottleneck")
    (assert (string-contains? (.-negative-query q1) "-hype") "Architecture negative query must include exclusion token")
    (assert (string-contains? (.-positive-query q2) "statute") "Legal positive query must include statute")
    (assert (string-contains? (.-negative-query q2) "violation") "Legal negative query must include violation")
    true))

(df run-tests [] -> Bool
  :d "Runs all asl-search unit tests."
  (and (test-url-builders)
       (and (test-provider-curl-cmds)
            (and (test-url-cleaning)
                 (and (test-proxy-health)
                      (and (test-result-merge)
                           (and (test-rag-formatting)
                                (and (test-ecosystems)
                                     (test-bipolar-query-generation)))))))))



