(module asl-web-api-search/router
  :d "Open-First Resilient Search Router with quota failover and multi-runtime dispatch"
  :x [SearchRoutingDecision is-open-engine? select-engine-cascade route-search-query]
  :i [(config :a cfg) (transport :a tr) (quota :a q)])

(dfs SearchRoutingDecision
  (:f selected-engine Str "Chosen primary search engine")
  (:f fallback-engines (List Str) "Ordered failover engine candidates")
  (:f transport tr/TransportStrategy "Selected network transport strategy")
  (:f is-deep-research Bool "True if keyed deep research enabled")
  (:f reason Str "Operational justification for routing choice"))

(df is-open-engine? [(engine Str)] -> Bool
  :d "Identifies whether target search engine operates without required API credentials"
  (let [(e (string-lower engine))]
    (or (= e "ddg")
        (or (= e "wikipedia")
            (or (= e "github")
                (or (= e "arxiv")
                    (or (= e "hackernews")
                        (= e "searxng"))))))))

(df select-engine-cascade [(deep-research Bool) (has-keys Bool)] -> (List Str)
  :d "Constructs prioritized cascade of engines according to open-first and research flags"
  (if (and deep-research has-keys)
      (list "brave" "tavily" "ddg" "wikipedia" "arxiv")
      (list "ddg" "wikipedia" "hackernews" "github" "arxiv" "brave")))

(df find-first-available-engine [(cascade (List Str)) (quotas (List q/EngineQuota))] -> Str
  (if (list-empty? cascade)
      "ddg"
      (let [(eng (option-or (list-head cascade) "ddg"))
            (rest (option-or (list-tail cascade) (list)))]
        (if (is-open-engine? eng)
            eng
            (let [(matching-quota (filter (fn [(qu q/EngineQuota)] -> Bool
                                            (= (.-engine-name qu) eng))
                                          quotas))]
              (if (and (not (list-empty? matching-quota))
                       (q/is-quota-available? (option-or (list-head matching-quota)
                                                         (q/inspect-engine-quota eng false 0))))
                  eng
                  (find-first-available-engine rest quotas)))))))

(df route-search-query [(query Str) (runtime tr/RuntimeKind) (has-extension Bool) (deep-research Bool) (tracker q/QuotaTracker)] -> SearchRoutingDecision
  :d "Computes deterministic search engine and transport routing decision using QuotaTracker telemetry"
  (let [(quotas (.-quotas tracker))
        (transport (tr/resolve-runtime-strategy runtime has-extension false))]
    (mt runtime
      ((tr/RuntimeKind:airgap-sandbox)
       (SearchRoutingDecision
         :selected-engine "memory"
         :fallback-engines (list)
         :transport (tr/TransportStrategy:memory-cache-only)
         :is-deep-research false
         :reason "Airgap environment detected: routing to resident memory cache"))
      ((tr/RuntimeKind:browser-webpage)
       (if has-extension
           (let [(has-keys (any? (map (fn [(qu q/EngineQuota)] -> Bool
                                        (and (not (is-open-engine? (.-engine-name qu)))
                                             (q/is-quota-available? qu)))
                                      quotas)))
                 (cascade (select-engine-cascade deep-research has-keys))
                 (primary (find-first-available-engine cascade quotas))]
             (SearchRoutingDecision
               :selected-engine primary
               :fallback-engines (list "wikipedia" "ddg")
               :transport (tr/TransportStrategy:extension-relay)
               :is-deep-research (and deep-research has-keys)
               :reason "Browser WebExtension relay active: full CORS neutralization enabled"))
           (SearchRoutingDecision
             :selected-engine "wikipedia"
             :fallback-engines (list "searxng")
             :transport (tr/TransportStrategy:cors-safe-direct)
             :is-deep-research false
             :reason "Browser webpage without extension: restricted to CORS-safe endpoints")))
      (:else
       (let [(has-keys (any? (map (fn [(qu q/EngineQuota)] -> Bool
                                    (and (not (is-open-engine? (.-engine-name qu)))
                                         (q/is-quota-available? qu)))
                                  quotas)))
             (cascade (select-engine-cascade deep-research has-keys))
             (primary (find-first-available-engine cascade quotas))]
         (SearchRoutingDecision
           :selected-engine primary
           :fallback-engines (filter (fn [e] (!= e primary)) cascade)
           :transport transport
           :is-deep-research (and deep-research has-keys)
           :reason (if (and deep-research has-keys)
                       "Deep research flagged with available keyed quotas"
                       "Open-first default policy active to conserve API quotas")))))))

