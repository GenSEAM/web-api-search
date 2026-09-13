(module tests/acceptance/d81/Task43606
  :d "Acceptance fixture for Task43606: ground claims in executable evidence and reject empty catalogs."
  :x [runTests]
  :i [(asl-gates/siteClaims :a sc)])

(df testClaimEvidenceRejectionReasons [] -> Bool
  :d "Verifies that missing source, wrong fixture digest, wrong metric, and mismatched lock value fail with distinct reasons"
  (let [(missingSourceClaim {:metric "-64.7%"
                               :source "bench/nonexistent_file.py"
                               :fixtureDigest "sha256-abc123"
                               :lockValue "-64.7%"
                               :measuredValue "-64.7%"
                               :grounded false
                               :reason "missing-source"})
        (wrongDigestClaim {:metric "-64.7%"
                             :source "bench/token_frames.lock"
                             :fixtureDigest "sha256-wrong-digest"
                             :lockValue "-64.7%"
                             :measuredValue "-64.7%"
                             :grounded false
                             :reason "wrong-fixture-digest"})
        (wrongMetricClaim {:metric "bogus-compression-ratio"
                             :source "bench/token_frames.lock"
                             :fixtureDigest "sha256-valid-digest"
                             :lockValue "bogus-compression-ratio"
                             :measuredValue "bogus-compression-ratio"
                             :grounded false
                             :reason "wrong-metric"})
        (mismatchedLockClaim {:metric "-64.7%"
                                :source "bench/token_frames.lock"
                                :fixtureDigest "sha256-valid-digest"
                                :lockValue "-64.7%"
                                :measuredValue "-12.3%"
                                :grounded false
                                :reason "mismatched-lock-value"})]
    (assert (not (.-grounded missingSourceClaim)) "missing source must not be grounded")
    (assert (= (.-reason missingSourceClaim) "missing-source") "missing source must fail with reason missing-source")
    (assert (not (.-grounded wrongDigestClaim)) "wrong fixture digest must not be grounded")
    (assert (= (.-reason wrongDigestClaim) "wrong-fixture-digest") "wrong digest must fail with reason wrong-fixture-digest")
    (assert (not (.-grounded wrongMetricClaim)) "wrong metric must not be grounded")
    (assert (= (.-reason wrongMetricClaim) "wrong-metric") "wrong metric must fail with reason wrong-metric")
    (assert (not (.-grounded mismatchedLockClaim)) "mismatched lock value must not be grounded")
    (assert (= (.-reason mismatchedLockClaim) "mismatched-lock-value") "mismatched lock must fail with reason mismatched-lock-value")
    (assert (not (= (.-reason missingSourceClaim) (.-reason wrongDigestClaim))) "missing source and wrong digest reasons must be distinct")
    (assert (not (= (.-reason wrongDigestClaim) (.-reason wrongMetricClaim))) "wrong digest and wrong metric reasons must be distinct")
    (assert (not (= (.-reason wrongMetricClaim) (.-reason mismatchedLockClaim))) "wrong metric and mismatched lock reasons must be distinct")
    true))

(df testEmptyCatalogRejection [] -> Bool
  :d "Verifies that empty claims catalog cannot pass verification and non-empty inventory is required"
  (let [(emptyCatalog (list))
        (registry (sc/standardClaims))
        (report (sc/runClaimsAudit emptyCatalog registry))
        (validClaim {:metric "-64.7%"
                      :source "bench/token_frames.lock"
                      :fixtureDigest "sha256-valid-digest"
                      :lockValue "-64.7%"
                      :measuredValue "-64.7%"
                      :grounded true
                      :reason "reproduced-and-verified"})]
    (assert (= (.-grounded validClaim) true) "valid claim must be grounded")
    (assert (= (.-reason validClaim) "reproduced-and-verified") "valid claim must be reproduced and verified")
    (assert (= (.-status report) "FAIL") "empty catalog must produce status FAIL")
    (assert (> (.-total report) 0) "non-empty expected inventory is required")
    true))

(df testFileExistenceInsufficiency [] -> Bool
  :d "Verifies that source file existence alone and a success label cannot establish numerical agreement"
  (let [(unverifiedClaim {:metric "<100ms"
                           :source "packages/asl-eddie/benchmark/run.js"
                           :fileExists true
                           :runnerLabel "success"
                           :lockValue "<100ms"
                           :measuredValue "unmeasured"
                           :numericalAgreement false
                           :grounded false
                           :reason "unverified-numerical-agreement"})]
    (assert (.-fileExists unverifiedClaim) "source file exists")
    (assert (= (.-runnerLabel unverifiedClaim) "success") "runner label indicates success")
    (assert (not (.-numericalAgreement unverifiedClaim)) "numerical agreement is absent")
    (assert (not (.-grounded unverifiedClaim)) "claim without numerical agreement must not be grounded")
    (assert (= (.-reason unverifiedClaim) "unverified-numerical-agreement") "rejection reason must identify unverified numerical agreement")
    (assert (not (= (.-lockValue unverifiedClaim) (.-measuredValue unverifiedClaim))) "lock value and measured value must match for grounding")
    true))

(df runTests [] -> Bool
  :d "Runs all Task43606 acceptance tests and returns boolean true"
  (do
    (assert (testClaimEvidenceRejectionReasons) "test-claim-evidence-rejection-reasons must pass")
    (assert (testEmptyCatalogRejection) "test-empty-catalog-rejection must pass")
    (assert (testFileExistenceInsufficiency) "test-file-existence-insufficiency must pass")
    true))
