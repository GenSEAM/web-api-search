(module aslWebApiSearch/router
  :d "Open-First Resilient Search Router with quota failover and multi-runtime dispatch"
  :x [SearchRoutingDecision isOpenEngine? selectEngineCascade routeSearchQuery]
  :i [(config :a cfg) (transport :a tr) (quota :a q)])

(dfs SearchRoutingDecision
  (:f selectedEngine Str "Chosen primary search engine")
  (:f fallbackEngines (List Str) "Ordered failover engine candidates")
  (:f transport tr/TransportStrategy "Selected network transport strategy")
  (:f isDeepResearch Bool "True if keyed deep research enabled")
  (:f reason Str "Operational justification for routing choice"))

(df isOpenEngine? [(engine Str)] -> Bool
  :d "Identifies whether target search engine operates without required API credentials"
  (let [(e (string-lower engine))]
    (or (= e "ddg")
        (or (= e "wikipedia")
            (or (= e "github")
                (or (= e "arxiv")
                    (or (= e "hackernews")
                        (= e "searxng"))))))))

(df selectEngineCascade [(deepResearch Bool) (hasKeys Bool)] -> (List Str)
  :d "Constructs prioritized cascade of engines according to open-first and research flags"
  (if (and deepResearch hasKeys)
      (list "brave" "tavily" "ddg" "wikipedia" "arxiv")
      (list "ddg" "wikipedia" "hackernews" "github" "arxiv" "brave")))

(df findFirstAvailableEngine [(cascade (List Str)) (quotas (List q/EngineQuota))] -> Str
  (if (list-empty? cascade)
      "ddg"
      (let [(eng (option-or (list-head cascade) "ddg"))
            (rest (option-or (list-tail cascade) (list)))]
        (if (isOpenEngine? eng)
            eng
            (let [(matchingQuota (filter (fn [(qu q/EngineQuota)] -> Bool
                                            (= (.-engineName qu) eng))
                                          quotas))]
              (if (and (not (list-empty? matchingQuota))
                       (q/isQuotaAvailable? (option-or (list-head matchingQuota)
                                                         (q/inspectEngineQuota eng false 0))))
                  eng
                  (findFirstAvailableEngine rest quotas)))))))

(df routeSearchQuery [(query Str) (runtime tr/RuntimeKind) (hasExtension Bool) (deepResearch Bool) (tracker q/QuotaTracker)] -> SearchRoutingDecision
  :d "Computes deterministic search engine and transport routing decision using QuotaTracker telemetry"
  (let [(quotas (.-quotas tracker))
        (transport (tr/resolveRuntimeStrategy runtime hasExtension false))]
    (mt runtime
      ((tr/RuntimeKind:airgapSandbox)
       (SearchRoutingDecision
         :selectedEngine "memory"
         :fallbackEngines (list)
         :transport (tr/TransportStrategy:memoryCacheOnly)
         :isDeepResearch false
         :reason "Airgap environment detected: routing to resident memory cache"))
      ((tr/RuntimeKind:browserWebpage)
       (if hasExtension
           (let [(hasKeys (any? (map (fn [(qu q/EngineQuota)] -> Bool
                                        (and (not (isOpenEngine? (.-engineName qu)))
                                             (q/isQuotaAvailable? qu)))
                                      quotas)))
                 (cascade (selectEngineCascade deepResearch hasKeys))
                 (primary (findFirstAvailableEngine cascade quotas))]
             (SearchRoutingDecision
               :selectedEngine primary
               :fallbackEngines (list "wikipedia" "ddg")
               :transport (tr/TransportStrategy:extensionRelay)
               :isDeepResearch (and deepResearch hasKeys)
               :reason "Browser WebExtension relay active: full CORS neutralization enabled"))
           (SearchRoutingDecision
             :selectedEngine "wikipedia"
             :fallbackEngines (list "searxng")
             :transport (tr/TransportStrategy:corsSafeDirect)
             :isDeepResearch false
             :reason "Browser webpage without extension: restricted to CORS-safe endpoints")))
      (:else
       (let [(hasKeys (any? (map (fn [(qu q/EngineQuota)] -> Bool
                                    (and (not (isOpenEngine? (.-engineName qu)))
                                         (q/isQuotaAvailable? qu)))
                                  quotas)))
             (cascade (selectEngineCascade deepResearch hasKeys))
             (primary (findFirstAvailableEngine cascade quotas))]
         (SearchRoutingDecision
           :selectedEngine primary
           :fallbackEngines (filter (fn [e] (!= e primary)) cascade)
           :transport transport
           :isDeepResearch (and deepResearch hasKeys)
           :reason (if (and deepResearch hasKeys)
                       "Deep research flagged with available keyed quotas"
                       "Open-first default policy active to conserve API quotas")))))))

