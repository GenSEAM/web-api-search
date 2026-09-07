(module asl-web-api-search/config
  :d "Resolves search engine credentials from environment variables and .asl.config.asn"
  :x [SearchConfig resolve-search-config get-engine-key make-default-search-config is-engine-configured?]
  :i [])

(dfs SearchConfig
  (:f open-first-default Bool "True if open engines are prioritized")
  (:f brave-key (Option Str) "Brave Search API Key")
  (:f tavily-key (Option Str) "Tavily AI Search Key")
  (:f serper-key (Option Str) "Serper Google API Key")
  (:f searxng-url (Option Str) "Custom SearXNG Instance URL"))

(df make-default-search-config [] -> SearchConfig
  :d "Constructs baseline SearchConfig with open-first prioritization enabled"
  (SearchConfig
    :open-first-default true
    :brave-key (none)
    :tavily-key (none)
    :serper-key (none)
    :searxng-url (none)))

(df get-key-from-map [(m Any) (k Str)] -> (Option Str)
  :d "Extracts optional string key from map structure"
  (if (or (= m nil) (= m null))
      (none)
      (let [(val (.-brave-key m))]
        (cond
          ((= k "brave")
           (if (and (!= (.-brave-key m) nil) (!= (.-brave-key m) ""))
               (some (.-brave-key m))
               (none)))
          ((= k "tavily")
           (if (and (!= (.-tavily-key m) nil) (!= (.-tavily-key m) ""))
               (some (.-tavily-key m))
               (none)))
          ((= k "serper")
           (if (and (!= (.-serper-key m) nil) (!= (.-serper-key m) ""))
               (some (.-serper-key m))
               (none)))
          ((= k "searxng")
           (if (and (!= (.-searxng-url m) nil) (!= (.-searxng-url m) ""))
               (some (.-searxng-url m))
               (none)))
          (:else (none))))))

(df resolve-search-config [(brave (Option Str)) (tavily (Option Str)) (serper (Option Str)) (searxng (Option Str)) (open-first Bool)] -> SearchConfig
  :d "Constructs fully-resolved SearchConfig from discovered parameters"
  (SearchConfig
    :open-first-default open-first
    :brave-key brave
    :tavily-key tavily
    :serper-key serper
    :searxng-url searxng))

(df get-engine-key [(cfg SearchConfig) (engine Str)] -> (Option Str)
  :d "Retrieves configured API key for the target engine"
  (let [(e (string-lower engine))]
    (cond
      ((= e "brave") (.-brave-key cfg))
      ((= e "tavily") (.-tavily-key cfg))
      ((= e "serper") (.-serper-key cfg))
      ((= e "searxng") (.-searxng-url cfg))
      (:else (none)))))

(df is-engine-configured? [(cfg SearchConfig) (engine Str)] -> Bool
  :d "Evaluates whether target search engine has valid active credentials configured"
  (let [(k (get-engine-key cfg engine))]
    (and (option-is-some? k) (!= (option-unwrap k) ""))))

