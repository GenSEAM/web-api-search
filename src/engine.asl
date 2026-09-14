(module aslWebApiSearch/engine
  :d "Decentralized multi-engine API search aggregator, URL deduplicator, and RAG context compressor in ASL."
  :x [ProxyState ProxyNode SearchEngine SearchQuery SearchResult CurlCommand BipolarQuery isProxyHealthy selectHealthyProxies buildSearchUrl makeCurlCommand buildProviderCurlCmd cleanUrl mergeSearchResults formatResultMarkdown formatRagContext generateBipolarQuery])

(dfe ProxyState
  (:c active [] "active proxy")
  (:c cooldown [] "cooldown proxy")
  (:c dead [] "dead proxy"))

(dfs ProxyNode
  (:f endpoint Str "endpoint url")
  (:f state ProxyState "state")
  (:f latencyMs F64 "latency in ms")
  (:f successRate F64 "success rate"))

(dfe SearchEngine
  (:c ddg [] "DuckDuckGo web search")
  (:c wikipedia [] "Wikipedia OpenSearch")
  (:c github [] "GitHub code & repositories")
  (:c arxiv [] "arXiv scientific papers")
  (:c hackernews [] "HackerNews Algolia")
  (:c brave [] "Brave Search API")
  (:c google [] "Google Custom Search")
  (:c tavily [] "Tavily AI Search"))

(dfs SearchQuery
  (:f text Str "query string")
  (:f maxResults I64 "max results count")
  (:f engines (List Str) "selected search engines"))

(dfs SearchResult
  (:f title Str "title")
  (:f url Str "url")
  (:f snippet Str "snippet")
  (:f engine Str "engine name")
  (:f score F64 "relevance score"))

(dfs CurlCommand
  (:f bin Str "curl executable path")
  (:f args (List Str) "command argument vector")
  (:f url Str "target URL"))

(df isProxyHealthy [(proxy ProxyNode)] -> Bool
  :d "Checks if proxy is healthy based on latency and success rate."
  (and (< (.-latencyMs proxy) 500.0) (> (.-successRate proxy) 0.9)))

(df selectHealthyProxies [(proxies (List ProxyNode))] -> (List ProxyNode)
  :d "Filters proxy pool for active healthy nodes."
  (filter isProxyHealthy proxies))

(df urlEncodeQuery [(q Str)] -> Str
  (let [(q1 (string-replace q "%" "%25"))
        (q2 (string-replace q1 "+" "%2B"))
        (q3 (string-replace q2 " " "%20"))
        (q4 (string-replace q3 "&" "%26"))
        (q5 (string-replace q4 "?" "%3F"))
        (q6 (string-replace q5 "=" "%3D"))
        (q7 (string-replace q6 "\"" "%22"))
        (q8 (string-replace q7 "'" "%27"))]
    q8))

(df buildSearchUrl [(engine Str) (query Str) (limit I64)] -> Str
  :d "Generates target query endpoint for the selected search provider."
  (let [(cleanQ (urlEncodeQuery query))
        (limStr (string-from-int64 limit))]
    (cond
      ((= engine "wikipedia")
       (str "https://en.wikipedia.org/w/api.php?action=opensearch&search=" cleanQ "&limit=" limStr "&namespace=0&format=json"))
      ((= engine "github")
       (str "https://api.github.com/search/repositories?q=" cleanQ "&per_page=" limStr))
      ((= engine "arxiv")
       (str "https://export.arxiv.org/api/query?search_query=all:" cleanQ "&start=0&max_results=" limStr))
      ((= engine "hackernews")
       (str "https://hn.algolia.com/api/v1/search?query=" cleanQ "&tags=story&hitsPerPage=" limStr))
      ((= engine "hn")
       (str "https://hn.algolia.com/api/v1/search?query=" cleanQ "&tags=story&hitsPerPage=" limStr))
      ((= engine "tavily")
       (str "https://api.tavily.com/search?query=" cleanQ "&max_results=" limStr))
      ((= engine "searxng")
       (str "https://searx.be/search?q=" cleanQ "&format=json"))
      ((= engine "serper")
       (str "https://google.serper.dev/search?q=" cleanQ "&num=" limStr))
      ((= engine "brave")
       (str "https://api.search.brave.com/res/v1/web/search?q=" cleanQ "&count=" limStr))
      (:else
       (str "https://html.duckduckgo.com/html/?q=" cleanQ)))))

(df makeCurlCommand [(url Str) (timeoutSec I64) (userAgent Str)] -> CurlCommand
  :d "Builds a safe, typed curl execution vector."
  (let [(safeUrl (if (or (string-starts-with? url "http://") (string-starts-with? url "https://")) url "https://invalid.local"))]
    (CurlCommand
      :bin "curl"
      :args (list "-s" "--max-time" (string-from-int64 timeoutSec) "-H" (str "User-Agent: " userAgent) "--" safeUrl)
      :url safeUrl)))

(df buildProviderCurlCmd [(engine Str) (url Str) (apiKey Str) (timeoutSec I64)] -> CurlCommand
  :d "Builds authenticated curl command for target search API provider."
  (let [(safeUrl (if (or (string-starts-with? url "http://") (string-starts-with? url "https://")) url "https://invalid.local"))
        (authHeader (cond
                       ((= engine "tavily") (str "Authorization: Bearer " apiKey))
                       ((= engine "serper") (str "X-API-KEY: " apiKey))
                       ((= engine "brave") (str "X-Subscription-Token: " apiKey))
                       ((= engine "github") (str "Authorization: token " apiKey))
                       (:else (str "X-API-Key: " apiKey))))
        (args (list "-s" "--max-time" (string-from-int64 timeoutSec)
                    "-H" "Accept: application/json"
                    "-H" authHeader
                    "--"
                    safeUrl))]
    (CurlCommand
      :bin "curl"
      :args args
      :url safeUrl)))

(df isTrackingParam? [(param Str)] -> Bool
  :d "Checks if query parameter is a tracking tag."
  (or (string-starts-with? param "utm_")
      (or (string-starts-with? param "fbclid=")
          (or (string-starts-with? param "gclid=")
              (string-starts-with? param "ref=")))))

(df filterQueryParams [(queryStr Str)] -> Str
  :d "Filters tracking parameters from query string."
  (let [(parts (string-split queryStr "&"))
        (cleanParts (filter (fn [(p Str)] -> Bool (not (isTrackingParam? p))) parts))]
    (string-join cleanParts "&")))

(df cleanUrl [(url Str)] -> Str
  :d "Strips tracking parameters (utm_*, ref, fbclid) from a URL."
  (let [(urlParts (string-split url "?"))]
    (mt (list-head urlParts)
      ((none) url)
      ((some base)
       (mt (list-tail urlParts)
         ((none) base)
         ((some tail)
          (mt (list-head tail)
            ((none) base)
            ((some rawQs)
             (let [(hashParts (string-split rawQs "#"))
                   (pureQs (option-or (list-head hashParts) rawQs))
                   (fragTail (option-or (list-tail hashParts) (list)))
                   (fragment (if (list-empty? fragTail) "" (str "#" (string-join fragTail "#"))))
                   (cleanQs (filterQueryParams pureQs))]
               (if (string-empty? cleanQs)
                   (str base fragment)
                   (str base "?" cleanQs fragment)))))))))))

(df updateItemOrAdd [(acc (List SearchResult)) (item SearchResult)] -> (List SearchResult)
  :d "Appends item or boosts score and combines engine tags if URL already exists."
  (let [(url (.-url item))
        (found (filter (fn [(r SearchResult)] -> Bool (= (.-url r) url)) acc))]
    (if (list-empty? found)
        (list-append acc (list item))
        (map (fn [(r SearchResult)] -> SearchResult
               (if (= (.-url r) url)
                   (SearchResult
                     :title (.-title r)
                     :url (.-url r)
                     :snippet (if (> (string-length (.-snippet item)) (string-length (.-snippet r)))
                                  (.-snippet item)
                                  (.-snippet r))
                     :engine (str (.-engine r) "+" (.-engine item))
                     :score (+ (.-score r) (.-score item)))
                   r))
             acc))))

(df mergeSearchResults [(primary (List SearchResult)) (secondary (List SearchResult))] -> (List SearchResult)
  :d "Merges two result sets with cross-engine deduplication and score boosting."
  (fold (fn [(acc (List SearchResult)) (item SearchResult)] -> (List SearchResult)
          (updateItemOrAdd acc item))
        primary
        secondary))

(df escapeMarkdown [(s Str)] -> Str
  :d "Escapes markdown special characters."
  (let [(s1 (string-replace s "[" "\\["))
        (s2 (string-replace s1 "]" "\\]"))]
    s2))

(df formatResultMarkdown [(index I64) (res SearchResult)] -> Str
  :d "Formats a single search result as markdown for LLM injection."
  (str (string-from-int64 index) ". **[" (escapeMarkdown (.-title res)) "](" (.-url res) ")**  `[" (escapeMarkdown (.-engine res)) "]`\n   " (.-snippet res) "\n"))

(df formatResultsRagHelper [(items (List SearchResult)) (idx I64)] -> (List Str)
  (if (list-empty? items)
      (list)
      (let [(h (option-or (list-head items) (SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail items) (list)))]
        (list-cons (formatResultMarkdown idx h) (formatResultsRagHelper rest (+ idx 1))))))

(df formatRagContext [(query Str) (items (List SearchResult))] -> Str
  :d "Formats full search results as token-efficient markdown context for LLM prompt injection."
  (let [(header (str "## Search Results for: '" query "' (" (string-from-int64 (list-length items)) " items)\n\n"))
        (formattedItems (formatResultsRagHelper items 1))]
    (str header (string-join formattedItems "\n"))))

(dfs BipolarQuery
  (:f positiveQuery Str "Confirmation query seeking supporting evidence")
  (:f negativeQuery Str "Falsification query seeking counter-evidence, failure modes, or criticisms")
  (:f domain Str "Domain category e.g. architecture, legal, security"))

(df generateBipolarQuery [(claim Str) (domain Str)] -> BipolarQuery
  :d "Generates dialectical confirmation and falsification queries to counteract confirmation bias."
  (let [(d (string-lower domain))
        (c (string-trim claim))
        (posSuffix (cond
                      ((= d "architecture") "architecture design advantages performance verified")
                      ((= d "legal") "statute authority ruling precedent compliant")
                      ((= d "security") "audit security certified hardened protection")
                      (:else "evidence proof benefits advantages verified")))
        (negSuffix (cond
                      ((= d "architecture") "bottleneck failure overhead drawbacks anti-pattern -hype")
                      ((= d "legal") "violation exception liability penalty repealed -opinion")
                      ((= d "security") "exploit cve vulnerability bypass flaw -marketing")
                      (:else "failure flaws criticism disadvantages limitations -promo")))]
    (BipolarQuery
      :positiveQuery (str c " " posSuffix)
      :negativeQuery (str c " " negSuffix)
      :domain domain)))
