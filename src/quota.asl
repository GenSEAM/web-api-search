(module asl-web-api-search/quota
  :d "Search engine API quota inspection, rate limit telemetry, and credential status"
  :x [EngineQuota QuotaTier QuotaTracker inspect-engine-quota parse-quota-headers is-quota-available? track-request make-quota-tracker]
  :i [])

(dfe QuotaTier
  (:c always-available [] "Free, keyless, public rate limit tier")
  (:c keyed-free [] "Free tier with API key and quota ceiling")
  (:c keyed-metered [] "Metered paid API tier"))

(dfs EngineQuota
  (:f engine-name Str "Provider: ddg | wiki | github | arxiv | hn | brave | tavily | serper")
  (:f tier QuotaTier "Quota tier")
  (:f has-key Bool "True if valid API key is present")
  (:f remaining-quota I64 "Remaining requests in current cycle (-1 if unlimited/unknown)")
  (:f reset-time-sec I64 "Seconds until rate limit reset")
  (:f is-exhausted Bool "True if quota is depleted"))

(dfs QuotaTracker
  (:f quotas (List EngineQuota) "Registered engine quotas")
  (:f default-tier QuotaTier "Fallback quota tier")
  (:f total-requests I64 "Total requests processed")
  (:f last-updated I64 "Timestamp of most recent quota update"))

(df make-quota-tracker [(quotas (List EngineQuota))] -> QuotaTracker
  :d "Constructs baseline QuotaTracker initialized with engine quotas"
  (QuotaTracker
    :quotas quotas
    :default-tier (QuotaTier:always-available)
    :total-requests 0
    :last-updated 0))

(df inspect-engine-quota [(engine Str) (has-key Bool) (remaining I64)] -> EngineQuota
  :d "Constructs EngineQuota telemetry record for specified engine"
  (let [(e (string-lower engine))
        (is-open (or (= e "ddg")
                     (or (= e "wikipedia")
                         (or (= e "github")
                             (or (= e "arxiv")
                                 (or (= e "hackernews")
                                     (= e "searxng")))))))]
    (if is-open
        (EngineQuota
          :engine-name engine
          :tier (QuotaTier:always-available)
          :has-key true
          :remaining-quota -1
          :reset-time-sec 0
          :is-exhausted false)
        (EngineQuota
          :engine-name engine
          :tier (QuotaTier:keyed-free)
          :has-key has-key
          :remaining-quota remaining
          :reset-time-sec 0
          :is-exhausted (or (not has-key) (= remaining 0))))))

(df parse-quota-headers [(headers (List Str))] -> I64
  :d "Parses rate limit remaining requests from response header lines"
  (if (list-empty? headers)
      -1
      (let [(h (option-or (list-head headers) ""))
            (rest (option-or (list-tail headers) (list)))
            (lower-h (string-lower h))]
        (if (or (string-starts-with? lower-h "x-ratelimit-remaining:")
                (string-starts-with? lower-h "ratelimit-remaining:"))
            (let [(parts (string-split h ":"))
                  (val-part (if (> (list-length parts) 1)
                                (string-trim (option-or (list-head (list-drop parts 1)) ""))
                                ""))]
              (option-or (string-to-int64 val-part) -1))
            (parse-quota-headers rest)))))

(df is-quota-available? [(quota EngineQuota)] -> Bool
  :d "Evaluates whether target engine has available request capacity"
  (and (.-has-key quota) (not (.-is-exhausted quota))))

(df track-request [(tracker QuotaTracker) (engine Str)] -> QuotaTracker
  :d "Updates quota usage counters and flags exhausted search engine capacity"
  (let [(updated-quotas (map (fn [(q EngineQuota)] -> EngineQuota
                               (if (= (.-engine-name q) engine)
                                   (let [(rem (.-remaining-quota q))
                                         (new-rem (if (> rem 0) (- rem 1) rem))
                                         (exhausted (or (.-is-exhausted q) (and (> rem 0) (= new-rem 0))))]
                                     (EngineQuota
                                       :engine-name (.-engine-name q)
                                       :tier (.-tier q)
                                       :has-key (.-has-key q)
                                       :remaining-quota new-rem
                                       :reset-time-sec (.-reset-time-sec q)
                                       :is-exhausted exhausted))
                                   q))
                             (.-quotas tracker)))]
    (QuotaTracker
      :quotas updated-quotas
      :default-tier (.-default-tier tracker)
      :total-requests (+ (.-total-requests tracker) 1)
      :last-updated (.-last-updated tracker))))

