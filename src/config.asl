(module aslWebApiSearch/config
  :d "Resolves search engine credentials from environment variables and .asl.config.asn"
  :x [SearchConfig resolveSearchConfig getEngineKey makeDefaultSearchConfig isEngineConfigured?]
  :i [])

(dfs SearchConfig
  (:f openFirstDefault Bool "True if open engines are prioritized")
  (:f braveKey (Option Str) "Brave Search API Key")
  (:f tavilyKey (Option Str) "Tavily AI Search Key")
  (:f serperKey (Option Str) "Serper Google API Key")
  (:f searxngUrl (Option Str) "Custom SearXNG Instance URL"))

(df makeDefaultSearchConfig [] -> SearchConfig
  :d "Constructs baseline SearchConfig with open-first prioritization enabled"
  (SearchConfig
    :openFirstDefault true
    :braveKey (none)
    :tavilyKey (none)
    :serperKey (none)
    :searxngUrl (none)))

(df getKeyFromMap [(m Any) (k Str)] -> (Option Str)
  :d "Extracts optional string key from map structure"
  (if (or (= m nil) (= m null))
      (none)
      (let [(val (.-braveKey m))]
        (cond
          ((= k "brave")
           (if (and (!= (.-braveKey m) nil) (!= (.-braveKey m) ""))
               (some (.-braveKey m))
               (none)))
          ((= k "tavily")
           (if (and (!= (.-tavilyKey m) nil) (!= (.-tavilyKey m) ""))
               (some (.-tavilyKey m))
               (none)))
          ((= k "serper")
           (if (and (!= (.-serperKey m) nil) (!= (.-serperKey m) ""))
               (some (.-serperKey m))
               (none)))
          ((= k "searxng")
           (if (and (!= (.-searxngUrl m) nil) (!= (.-searxngUrl m) ""))
               (some (.-searxngUrl m))
               (none)))
          (:else (none))))))

(df resolveSearchConfig [(brave (Option Str)) (tavily (Option Str)) (serper (Option Str)) (searxng (Option Str)) (openFirst Bool)] -> SearchConfig
  :d "Constructs fully-resolved SearchConfig from discovered parameters"
  (SearchConfig
    :openFirstDefault openFirst
    :braveKey brave
    :tavilyKey tavily
    :serperKey serper
    :searxngUrl searxng))

(df getEngineKey [(cfg SearchConfig) (engine Str)] -> (Option Str)
  :d "Retrieves configured API key for the target engine"
  (let [(e (string-lower engine))]
    (cond
      ((= e "brave") (.-braveKey cfg))
      ((= e "tavily") (.-tavilyKey cfg))
      ((= e "serper") (.-serperKey cfg))
      ((= e "searxng") (.-searxngUrl cfg))
      (:else (none)))))

(df isEngineConfigured? [(cfg SearchConfig) (engine Str)] -> Bool
  :d "Evaluates whether target search engine has valid active credentials configured"
  (let [(k (getEngineKey cfg engine))]
    (and (optionIsSome? k) (!= (option-unwrap k) ""))))

