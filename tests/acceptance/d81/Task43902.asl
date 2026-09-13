(module tests/acceptance/d81/Task43902
  :d "Acceptance fixture for Task43902: Measure actual cache use and cost per correct task under ADR-0081."
  :x [RunTests
      TestPrefixStabilityClassification
      TestExplicitCostCalculationAndReceipts
      TestTokenBudgetSeparationAndCacheEligibility]
  :i [(aslBench/launchStability :a stab)])

(df TestPrefixStabilityClassification [] -> Bool
  :d "Verifies identical prefixes are stable while deliberate changes are detected"
  (let [(p1 "(:launch-session :client \"agy\" :tier :full)")
        (p2 "(:launch-session :client \"agy\" :tier :full)")
        (p3 "(:launch-session :client \"agy\" :tier :essential)")
        (r1 (stab/makePrefixRecord p1 12))
        (r2 (stab/makePrefixRecord p2 12))
        (r3 (stab/makePrefixRecord p3 10))]
    (assert (= (.-byteCount r1) (.-byteCount r2)) "Identical prefixes must have identical byte count")
    (assert (= (.-tokenCount r1) (.-tokenCount r2)) "Identical prefixes must have identical token count")
    (assert (stab/comparePrefixStability r1 r2) "Identical prefixes must be classified as stable")
    (assert (not (stab/comparePrefixStability r1 r3)) "Changed prefixes must not be classified as stable")
    true))

(df TestExplicitCostCalculationAndReceipts [] -> Bool
  :d "Verifies that uncached and cached token costs use explicit denominators and capture verified receipts"
  (let [(pricing (stab/makeModelPricing 3.0 0.75 15.0))
        (receipt (stab/computeCacheReceipt "claude-3-5-sonnet" 10000 8000 500 pricing 450 true))
        (costAllUncached (stab/estimateSessionCost 10000 0 500 pricing))]
    (assert (= (.-provider receipt) "claude-3-5-sonnet") "Receipt provider must match")
    (assert (= (.-promptTokens receipt) 10000) "Total prompt tokens must be 10000")
    (assert (= (.-cachedTokens receipt) 8000) "Cached tokens must be 8000")
    (assert (= (.-completionTokens receipt) 500) "Completion tokens must be 500")
    (assert (= (.-hitRatio receipt) 0.8) "Cache hit ratio must be exactly 0.8 (80%)")
    (assert (.-hasReceipt receipt) "Receipt flag must be confirmed true")
    (assert (< (.-costUsd receipt) costAllUncached) "Cached session cost must be lower than all-uncached session cost")
    (assert (> (.-costUsd receipt) 0.0) "Cost must be positive non-zero")
    true))

(df TestTokenBudgetSeparationAndCacheEligibility [] -> Bool
  :d "Verifies token budgets and cache eligibility thresholds are checked separately from raw bytes"
  (let [(threshold 1024)
        (smallTokens 512)
        (largeTokens 2048)]
    (assert (not (stab/isCacheEligible? smallTokens threshold))
            "Sub-threshold prompt must not be eligible for prefix caching")
    (assert (stab/isCacheEligible? largeTokens threshold)
            "Super-threshold prompt must be eligible for prefix caching")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task43902 supervisor acceptance tests"
  (do
    (assert (TestPrefixStabilityClassification) "TestPrefixStabilityClassification must pass")
    (assert (TestExplicitCostCalculationAndReceipts) "TestExplicitCostCalculationAndReceipts must pass")
    (assert (TestTokenBudgetSeparationAndCacheEligibility) "TestTokenBudgetSeparationAndCacheEligibility must pass")
    true))
