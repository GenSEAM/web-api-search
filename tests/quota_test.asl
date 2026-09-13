(module asl-web-api-search/quota-test
  :d "Comprehensive test suite for Search Credentials, Multi-Runtime Transport, Quota Telemetry, and Open-First Routing"
  :x [test-config-resolution
      test-transport-strategy
      test-quota-telemetry
      test-open-first-router
      test-hybrid-merger
      run-tests]
  :i [(config :a cfg)
      (transport :a tr)
      (quota :a q)
      (router :a rt)
      (hybrid :a hyb)
      (engine :a eng)])

(df test-config-resolution [] -> Bool
  :d "Verifies credential discovery, default values, and engine key retrieval"
  (let [(def-cfg (cfg/make-default-search-config))]
    (assert (= (.-open-first-default def-cfg) true) "default open-first should be true")
    (assert (= (.-brave-key def-cfg) (none)) "default brave key should be none")
    (assert (= (cfg/is-engine-configured? def-cfg "brave") false) "default brave should not be configured")
    (let [(resolved (cfg/resolve-search-config (some "brave-xyz") (none) (some "serper-abc") (some "http://localhost:8888") false))]
      (assert (= (.-open-first-default resolved) false) "resolved open-first mismatch")
      (assert (= (cfg/get-engine-key resolved "brave") (some "brave-xyz")) "brave key retrieval mismatch")
      (assert (= (cfg/get-engine-key resolved "serper") (some "serper-abc")) "serper key retrieval mismatch")
      (assert (= (cfg/get-engine-key resolved "tavily") (none)) "tavily key should be none")
      (assert (= (cfg/get-engine-key resolved "searxng") (some "http://localhost:8888")) "searxng url mismatch")
      (assert (= (cfg/is-engine-configured? resolved "brave") true) "resolved brave should be configured")
      (assert (= (cfg/is-engine-configured? resolved "tavily") false) "resolved tavily should not be configured")
      (assert (= (cfg/is-engine-configured? resolved "serper") true) "resolved serper should be configured")
      true)))

(df test-transport-strategy [] -> Bool
  :d "Verifies multi-runtime network transport and CORS strategy resolution"
  (do
    (assert (= (tr/is-cors-restricted? (tr/RuntimeKind:browser-webpage)) true) "webpage is cors restricted")
    (assert (= (tr/is-cors-restricted? (tr/RuntimeKind:airgap-sandbox)) true) "airgap is cors restricted")
    (assert (= (tr/is-cors-restricted? (tr/RuntimeKind:desktop-host)) false) "host is not cors restricted")
    (assert (= (tr/is-cors-restricted? (tr/RuntimeKind:browser-extension)) false) "extension is not cors restricted")
    (assert (= (tr/is-offline-transport? (tr/TransportStrategy:memory-cache-only)) true) "memory-cache-only must be offline")
    (assert (= (tr/is-offline-transport? (tr/TransportStrategy:direct-curl)) false) "direct-curl must not be offline")
    (assert (= (tr/is-offline-transport? (tr/TransportStrategy:extension-relay)) false) "extension-relay must not be offline")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:airgap-sandbox) false false) (tr/TransportStrategy:memory-cache-only)) "airgap must use memory cache")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:desktop-host) false false) (tr/TransportStrategy:direct-curl)) "desktop must use direct curl")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:browser-extension) true false) (tr/TransportStrategy:extension-relay)) "extension must use relay")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:browser-webpage) true false) (tr/TransportStrategy:extension-relay)) "webpage with extension must use relay")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:browser-webpage) false true) (tr/TransportStrategy:cors-safe-direct)) "webpage cors-safe must use cors-safe-direct")
    (assert (= (tr/resolve-runtime-strategy (tr/RuntimeKind:browser-webpage) false false) (tr/TransportStrategy:local-daemon-bridge)) "webpage without extension must use daemon bridge")
    (let [(cmd (tr/build-transport-fetch-cmd (tr/TransportStrategy:direct-curl) "https://example.com" (list "Authorization: Bearer test")))]
      (assert (> (list-length cmd) 3) "curl command vector too short")
      (assert (= (option-or (list-head cmd) "") "curl") "curl binary missing"))
    true))

(df test-quota-telemetry [] -> Bool
  :d "Verifies rate limit header parsing, tier assignment, and quota exhaustion evaluation"
  (let [(wiki-q (q/inspect-engine-quota "wikipedia" false 0))
        (brave-ok (q/inspect-engine-quota "brave" true 50))
        (brave-depleted (q/inspect-engine-quota "brave" true 0))
        (brave-nokey (q/inspect-engine-quota "brave" false 100))]
    (assert (= (q/is-quota-available? wiki-q) true) "open engine wikipedia must be available")
    (assert (= (.-tier wiki-q) (q/QuotaTier:always-available)) "wikipedia should be always-available tier")
    (assert (= (q/is-quota-available? brave-ok) true) "brave with quota must be available")
    (assert (= (.-tier brave-ok) (q/QuotaTier:keyed-free)) "brave should be keyed-free tier")
    (assert (= (q/is-quota-available? brave-depleted) false) "depleted brave quota must not be available")
    (assert (= (q/is-quota-available? brave-nokey) false) "keyless brave must not be available")
    (let [(headers (list "Date: Tue, 08 Sep 2026 00:00:00 GMT" "X-RateLimit-Remaining: 84" "Content-Type: application/json"))
          (rem (q/parse-quota-headers headers))]
      (assert (= rem 84) "parsed quota remaining mismatch"))
    (let [(bad-headers (list "Server: nginx" "Content-Type: text/html"))
          (rem2 (q/parse-quota-headers bad-headers))]
      (assert (= rem2 -1) "missing quota header should return -1"))
    (let [(direct-tracker (q/QuotaTracker
                            :quotas (list brave-ok wiki-q)
                            :default-tier (q/QuotaTier:always-available)
                            :total-requests 0
                            :last-updated 0))]
      (assert (= (.-total-requests direct-tracker) 0) "direct QuotaTracker record construction should have 0 requests")
      (assert (= (list-length (.-quotas direct-tracker)) 2) "direct QuotaTracker should hold registered quotas"))
    (let [(tracker (q/make-quota-tracker (list brave-ok wiki-q)))
          (tracked-1 (q/track-request tracker "brave"))]
      (assert (= (.-total-requests tracked-1) 1) "total requests after 1 track should be 1")
      (let [(b-quota (option-or (list-head (.-quotas tracked-1)) brave-ok))]
        (assert (= (.-remaining-quota b-quota) 49) "remaining quota should decrement to 49")
        (assert (= (.-is-exhausted b-quota) false) "brave should not be exhausted at 49 requests")))
    (let [(tracker-depleting (q/make-quota-tracker (list (q/inspect-engine-quota "serper" true 1))))
          (tracked-dep (q/track-request tracker-depleting "serper"))]
      (let [(s-quota (option-or (list-head (.-quotas tracked-dep)) (q/inspect-engine-quota "serper" false 0)))]
        (assert (= (.-remaining-quota s-quota) 0) "remaining quota should reach 0")
        (assert (= (.-is-exhausted s-quota) true) "serper should be exhausted when quota hits 0")))
    true))

(df test-open-first-router [] -> Bool
  :d "Verifies open-first cascade selection, deep-research upgrade, and failover routing"
  (do
    (assert (= (rt/is-open-engine? "ddg") true) "ddg is open")
    (assert (= (rt/is-open-engine? "wikipedia") true) "wikipedia is open")
    (assert (= (rt/is-open-engine? "github") true) "github is open")
    (assert (= (rt/is-open-engine? "brave") false) "brave is keyed")
    (assert (= (rt/is-open-engine? "tavily") false) "tavily is keyed")
    (let [(open-cascade (rt/select-engine-cascade false true))]
      (assert (= (option-or (list-head open-cascade) "") "ddg") "standard cascade must start with ddg"))
    (let [(deep-cascade (rt/select-engine-cascade true true))]
      (assert (= (option-or (list-head deep-cascade) "") "brave") "deep research cascade must start with brave"))
    (let [(tracker (q/make-quota-tracker (list (q/inspect-engine-quota "brave" true 100) (q/inspect-engine-quota "ddg" true -1))))
          (dec-open (rt/route-search-query "asl agents" (tr/RuntimeKind:desktop-host) false false tracker))]
      (assert (= (.-selected-engine dec-open) "ddg") "open-first should select ddg")
      (assert (= (.-is-deep-research dec-open) false) "deep-research should be false"))
    (let [(tracker2 (q/make-quota-tracker (list (q/inspect-engine-quota "brave" true 100) (q/inspect-engine-quota "ddg" true -1))))
          (dec-deep (rt/route-search-query "sub-millisecond wasm sandboxes" (tr/RuntimeKind:desktop-host) false true tracker2))]
      (assert (= (.-selected-engine dec-deep) "brave") "deep research with key should select brave")
      (assert (= (.-is-deep-research dec-deep) true) "deep-research should be true"))
    (let [(dec-airgap (rt/route-search-query "test query" (tr/RuntimeKind:airgap-sandbox) false false (q/make-quota-tracker (list))))]
      (assert (= (.-selected-engine dec-airgap) "memory") "airgap must route to memory")
      (assert (= (.-transport dec-airgap) (tr/TransportStrategy:memory-cache-only)) "airgap transport mismatch"))
    (let [(empty-tracker (q/make-quota-tracker (list)))
          (dec-empty (rt/route-search-query "empty tracker query" (tr/RuntimeKind:desktop-host) false false empty-tracker))]
      (assert (= (.-selected-engine dec-empty) "ddg") "empty tracker should default to ddg")
      (assert (= (.-is-deep-research dec-empty) false) "empty tracker should have deep-research false"))
    (let [(exhausted-tracker (q/make-quota-tracker (list (q/inspect-engine-quota "brave" true 0) (q/inspect-engine-quota "ddg" true -1))))
          (dec-fallback (rt/route-search-query "exhausted query" (tr/RuntimeKind:desktop-host) false true exhausted-tracker))]
      (assert (= (.-selected-engine dec-fallback) "ddg") "exhausted keyed quota should degrade to ddg")
      (assert (= (.-is-deep-research dec-fallback) false) "deep-research should degrade to false when keyed quotas exhausted"))
    true))

(df test-hybrid-merger [] -> Bool
  :d "Verifies RRF scoring calculations, URL deduplication, and multi-engine stream blending"
  (let [(score1 (hyb/calculate-rrf-score 1 60))
        (score2 (hyb/calculate-rrf-score 2 60))]
    (assert (> score1 0.015) "rrf score 1 too low")
    (assert (< score1 0.017) "rrf score 1 too high")
    (assert (> score1 score2) "rrf rank 1 score must exceed rank 2")
    (let [(res1 (eng/SearchResult :title "ASL 1" :url "https://agentscript.org/docs?utm_source=test" :snippet "docs" :engine "ddg" :score 0.9))
          (res2 (eng/SearchResult :title "ASL 1 Dup" :url "https://agentscript.org/docs" :snippet "docs longer" :engine "brave" :score 0.85))
          (res3 (eng/SearchResult :title "ASL 2" :url "https://agentscript.org/blog" :snippet "blog" :engine "wikipedia" :score 0.7))
          (deduped (hyb/deduplicate-serp-results (list res1 res2 res3)))]
      (assert (= (list-length deduped) 2) "deduplicated list must contain 2 items"))
    (let [(stream-a (list (eng/SearchResult :title "Title A" :url "https://example.com/a" :snippet "snip a" :engine "ddg" :score 1.0)))
          (stream-b (list (eng/SearchResult :title "Title A Dup" :url "https://example.com/a?ref=test" :snippet "snip a extended" :engine "brave" :score 0.95)
                          (eng/SearchResult :title "Title B" :url "https://example.com/b" :snippet "snip b" :engine "brave" :score 0.8)))
          (merged (hyb/merge-serp-streams stream-a stream-b))]
      (assert (= (list-length merged) 2) "merged stream must have 2 unique URLs"))
    (let [(item-low (eng/SearchResult :title "Low" :url "https://example.com/low" :snippet "low" :engine "ddg" :score 0.01))
          (item-high (eng/SearchResult :title "High" :url "https://example.com/high" :snippet "high" :engine "brave" :score 0.99))
          (item-mid (eng/SearchResult :title "Mid" :url "https://example.com/mid" :snippet "mid" :engine "searxng" :score 0.50))
          (ranked (hyb/rank-serp-results (list item-low item-high item-mid)))
          (first-item (option-or (list-head ranked) item-low))
          (last-item (option-or (list-head (list-drop ranked 2)) item-high))]
      (assert (= (list-length ranked) 3) "ranked results count should be 3")
      (assert (= (.-title first-item) "High") "highest scoring item must be first")
      (assert (= (.-title last-item) "Low") "lowest scoring item must be last"))
    true))

(df run-tests [] -> Bool
  :d "Executes complete quota, transport, router, and hybrid verification test suite"
  (and (test-config-resolution)
       (test-transport-strategy)
       (test-quota-telemetry)
       (test-open-first-router)
       (test-hybrid-merger)))

