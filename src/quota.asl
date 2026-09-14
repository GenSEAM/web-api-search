(module aslWebApiSearch/quota
  :d "Search engine API quota inspection, rate limit telemetry, and credential status"
  :x [EngineQuota QuotaTier QuotaTracker inspectEngineQuota parseQuotaHeaders isQuotaAvailable? trackRequest makeQuotaTracker]
  :i [])

(dfe QuotaTier
  (:c alwaysAvailable [] "Free, keyless, public rate limit tier")
  (:c keyedFree [] "Free tier with API key and quota ceiling")
  (:c keyedMetered [] "Metered paid API tier"))

(dfs EngineQuota
  (:f engineName Str "Provider: ddg | wiki | github | arxiv | hn | brave | tavily | serper")
  (:f tier QuotaTier "Quota tier")
  (:f hasKey Bool "True if valid API key is present")
  (:f remainingQuota I64 "Remaining requests in current cycle (-1 if unlimited/unknown)")
  (:f resetTimeSec I64 "Seconds until rate limit reset")
  (:f isExhausted Bool "True if quota is depleted"))

(dfs QuotaTracker
  (:f quotas (List EngineQuota) "Registered engine quotas")
  (:f defaultTier QuotaTier "Fallback quota tier")
  (:f totalRequests I64 "Total requests processed")
  (:f lastUpdated I64 "Timestamp of most recent quota update"))

(df makeQuotaTracker [(quotas (List EngineQuota))] -> QuotaTracker
  :d "Constructs baseline QuotaTracker initialized with engine quotas"
  (QuotaTracker
    :quotas quotas
    :defaultTier (QuotaTier:alwaysAvailable)
    :totalRequests 0
    :lastUpdated 0))

(df inspectEngineQuota [(engine Str) (hasKey Bool) (remaining I64)] -> EngineQuota
  :d "Constructs EngineQuota telemetry record for specified engine"
  (let [(e (string-lower engine))
        (isOpen (or (= e "ddg")
                     (or (= e "wikipedia")
                         (or (= e "github")
                             (or (= e "arxiv")
                                 (or (= e "hackernews")
                                     (= e "searxng")))))))]
    (if isOpen
        (EngineQuota
          :engineName engine
          :tier (QuotaTier:alwaysAvailable)
          :hasKey true
          :remainingQuota -1
          :resetTimeSec 0
          :isExhausted false)
        (EngineQuota
          :engineName engine
          :tier (QuotaTier:keyedFree)
          :hasKey hasKey
          :remainingQuota remaining
          :resetTimeSec 0
          :isExhausted (or (not hasKey) (= remaining 0))))))

(df parseQuotaHeaders [(headers (List Str))] -> I64
  :d "Parses rate limit remaining requests from response header lines"
  (if (list-empty? headers)
      -1
      (let [(h (option-or (list-head headers) ""))
            (rest (option-or (list-tail headers) (list)))
            (lowerH (string-lower h))]
        (if (or (string-starts-with? lowerH "x-ratelimit-remaining:")
                (string-starts-with? lowerH "ratelimit-remaining:"))
            (let [(parts (string-split h ":"))
                  (valPart (if (> (list-length parts) 1)
                                (string-trim (option-or (list-head (listDrop parts 1)) ""))
                                ""))]
              (option-or (string-to-int64 valPart) -1))
            (parseQuotaHeaders rest)))))

(df isQuotaAvailable? [(quota EngineQuota)] -> Bool
  :d "Evaluates whether target engine has available request capacity"
  (and (.-hasKey quota) (not (.-isExhausted quota))))

(df trackRequest [(tracker QuotaTracker) (engine Str) (timestamp I64)] -> QuotaTracker
  :d "Updates quota usage counters and flags exhausted search engine capacity"
  (let [(updatedQuotas (map (fn [(q EngineQuota)] -> EngineQuota
                               (if (= (.-engineName q) engine)
                                   (let [(rem (.-remainingQuota q))
                                         (newRem (if (> rem 0) (- rem 1) rem))
                                         (exhausted (or (.-isExhausted q) (and (> rem 0) (= newRem 0))))]
                                     (EngineQuota
                                       :engineName (.-engineName q)
                                       :tier (.-tier q)
                                       :hasKey (.-hasKey q)
                                       :remainingQuota newRem
                                       :resetTimeSec (.-resetTimeSec q)
                                       :isExhausted exhausted))
                                   q))
                             (.-quotas tracker)))]
    (QuotaTracker
      :quotas updatedQuotas
      :defaultTier (.-defaultTier tracker)
      :totalRequests (+ (.-totalRequests tracker) 1)
      :lastUpdated timestamp)))

