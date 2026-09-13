(module asl-web-api-search/engine
  :d "Decentralized multi-engine API search aggregator, URL deduplicator, and RAG context compressor in ASL."
  :x [ProxyState ProxyNode SearchEngine SearchQuery SearchResult CurlCommand BipolarQuery is-proxy-healthy select-healthy-proxies build-search-url make-curl-command build-provider-curl-cmd clean-url merge-search-results format-result-markdown format-rag-context generate-bipolar-query])

(dfe ProxyState
  (:c active [] "active proxy")
  (:c cooldown [] "cooldown proxy")
  (:c dead [] "dead proxy"))

(dfs ProxyNode
  (:f endpoint Str "endpoint url")
  (:f state ProxyState "state")
  (:f latency-ms F64 "latency in ms")
  (:f success-rate F64 "success rate"))

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
  (:f max-results I64 "max results count")
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

(df is-proxy-healthy [(proxy ProxyNode)] -> Bool
  :d "Checks if proxy is healthy based on latency and success rate."
  (and (< (.-latency-ms proxy) 500.0) (> (.-success-rate proxy) 0.9)))

(df select-healthy-proxies [(proxies (List ProxyNode))] -> (List ProxyNode)
  :d "Filters proxy pool for active healthy nodes."
  (filter is-proxy-healthy proxies))

(df url-encode-query [(q Str)] -> Str
  (let [(q1 (string-replace q "%" "%25"))
        (q2 (string-replace q1 "+" "%2B"))
        (q3 (string-replace q2 " " "%20"))
        (q4 (string-replace q3 "&" "%26"))
        (q5 (string-replace q4 "?" "%3F"))
        (q6 (string-replace q5 "=" "%3D"))
        (q7 (string-replace q6 "\"" "%22"))
        (q8 (string-replace q7 "'" "%27"))]
    q8))

(df build-search-url [(engine Str) (query Str) (limit I64)] -> Str
  :d "Generates target query endpoint for the selected search provider."
  (let [(clean-q (url-encode-query query))
        (lim-str (string-from-int64 limit))]
    (cond
      ((= engine "wikipedia")
       (str "https://en.wikipedia.org/w/api.php?action=opensearch&search=" clean-q "&limit=" lim-str "&namespace=0&format=json"))
      ((= engine "github")
       (str "https://api.github.com/search/repositories?q=" clean-q "&per_page=" lim-str))
      ((= engine "arxiv")
       (str "http://export.arxiv.org/api/query?search_query=all:" clean-q "&start=0&max_results=" lim-str))
      ((= engine "hackernews")
       (str "https://hn.algolia.com/api/v1/search?query=" clean-q "&tags=story&hitsPerPage=" lim-str))
      ((= engine "hn")
       (str "https://hn.algolia.com/api/v1/search?query=" clean-q "&tags=story&hitsPerPage=" lim-str))
      ((= engine "tavily")
       (str "https://api.tavily.com/search?query=" clean-q "&max_results=" lim-str))
      ((= engine "searxng")
       (str "https://searx.be/search?q=" clean-q "&format=json"))
      ((= engine "serper")
       (str "https://google.serper.dev/search?q=" clean-q "&num=" lim-str))
      ((= engine "brave")
       (str "https://api.search.brave.com/res/v1/web/search?q=" clean-q "&count=" lim-str))
      (:else
       (str "https://html.duckduckgo.com/html/?q=" clean-q)))))

(df make-curl-command [(url Str) (timeout-sec I64) (user-agent Str)] -> CurlCommand
  :d "Builds a safe, typed curl execution vector."
  (CurlCommand
    :bin "curl"
    :args (list "-s" "--max-time" (string-from-int64 timeout-sec) "-H" (str "User-Agent: " user-agent) url)
    :url url))

(df build-provider-curl-cmd [(engine Str) (url Str) (api-key Str) (timeout-sec I64)] -> CurlCommand
  :d "Builds authenticated curl command for target search API provider."
  (let [(auth-header (cond
                       ((= engine "tavily") (str "Authorization: Bearer " api-key))
                       ((= engine "serper") (str "X-API-KEY: " api-key))
                       ((= engine "brave") (str "X-Subscription-Token: " api-key))
                       ((= engine "github") (str "Authorization: token " api-key))
                       (:else (str "X-API-Key: " api-key))))
        (args (list "-s" "--max-time" (string-from-int64 timeout-sec)
                    "-H" "Accept: application/json"
                    "-H" auth-header
                    url))]
    (CurlCommand
      :bin "curl"
      :args args
      :url url)))

(df is-tracking-param? [(param Str)] -> Bool
  :d "Checks if query parameter is a tracking tag."
  (or (string-starts-with? param "utm_")
      (or (string-starts-with? param "fbclid=")
          (or (string-starts-with? param "gclid=")
              (string-starts-with? param "ref=")))))

(df filter-query-params [(query-str Str)] -> Str
  :d "Filters tracking parameters from query string."
  (let [(parts (string-split query-str "&"))
        (clean-parts (filter (fn [(p Str)] -> Bool (not (is-tracking-param? p))) parts))]
    (string-join clean-parts "&")))

(df clean-url [(url Str)] -> Str
  :d "Strips tracking parameters (utm_*, ref, fbclid) from a URL."
  (let [(url-parts (string-split url "?"))]
    (mt (list-head url-parts)
      ((none) url)
      ((some base)
       (mt (list-tail url-parts)
         ((none) base)
         ((some tail)
          (mt (list-head tail)
            ((none) base)
            ((some raw-qs)
             (let [(clean-qs (filter-query-params raw-qs))]
               (if (string-empty? clean-qs)
                   base
                   (str base "?" clean-qs)))))))))))

(df update-item-or-add [(acc (List SearchResult)) (item SearchResult)] -> (List SearchResult)
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

(df merge-search-results [(primary (List SearchResult)) (secondary (List SearchResult))] -> (List SearchResult)
  :d "Merges two result sets with cross-engine deduplication and score boosting."
  (fold (fn [(acc (List SearchResult)) (item SearchResult)] -> (List SearchResult)
          (update-item-or-add acc item))
        primary
        secondary))

(df format-result-markdown [(index I64) (res SearchResult)] -> Str
  :d "Formats a single search result as markdown for LLM injection."
  (str (string-from-int64 index) ". **[" (.-title res) "](" (.-url res) ")**  `[" (.-engine res) "]`\n   " (.-snippet res) "\n"))

(df format-results-rag-helper [(items (List SearchResult)) (idx I64)] -> (List Str)
  (if (list-empty? items)
      (list)
      (let [(h (option-or (list-head items) (SearchResult :title "" :url "" :snippet "" :engine "" :score 0.0)))
            (rest (option-or (list-tail items) (list)))]
        (list-cons (format-result-markdown idx h) (format-results-rag-helper rest (+ idx 1))))))

(df format-rag-context [(query Str) (items (List SearchResult))] -> Str
  :d "Formats full search results as token-efficient markdown context for LLM prompt injection."
  (let [(header (str "## Search Results for: '" query "' (" (string-from-int64 (list-length items)) " items)\n\n"))
        (formatted-items (format-results-rag-helper items 1))]
    (str header (string-join formatted-items "\n"))))

(dfs BipolarQuery
  (:f positive-query Str "Confirmation query seeking supporting evidence")
  (:f negative-query Str "Falsification query seeking counter-evidence, failure modes, or criticisms")
  (:f domain Str "Domain category e.g. architecture, legal, security"))

(df generate-bipolar-query [(claim Str) (domain Str)] -> BipolarQuery
  :d "Generates dialectical confirmation and falsification queries to counteract confirmation bias."
  (let [(d (string-lower domain))
        (c (string-trim claim))
        (pos-suffix (cond
                      ((= d "architecture") "architecture design advantages performance verified")
                      ((= d "legal") "statute authority ruling precedent compliant")
                      ((= d "security") "audit security certified hardened protection")
                      (:else "evidence proof benefits advantages verified")))
        (neg-suffix (cond
                      ((= d "architecture") "bottleneck failure overhead drawbacks anti-pattern -hype")
                      ((= d "legal") "violation exception liability penalty repealed -opinion")
                      ((= d "security") "exploit cve vulnerability bypass flaw -marketing")
                      (:else "failure flaws criticism disadvantages limitations -promo")))]
    (BipolarQuery
      :positive-query (str c " " pos-suffix)
      :negative-query (str c " " neg-suffix)
      :domain domain)))
