(module tests/acceptance/d81/Task43606
  :d "Acceptance fixture for Task43606: ground claims in executable evidence and reject empty catalogs."
  :x [run-tests]
  :i [(asl-gates/site-claims :a sc)])

(df test-claim-evidence-rejection-reasons [] -> Bool
  :d "Verifies that missing source, wrong fixture digest, wrong metric, and mismatched lock value fail with distinct reasons"
  (let [(missing-source-claim {:metric "-64.7%"
                               :source "bench/nonexistent_file.py"
                               :fixture-digest "sha256-abc123"
                               :lock-value "-64.7%"
                               :measured-value "-64.7%"
                               :grounded false
                               :reason "missing-source"})
        (wrong-digest-claim {:metric "-64.7%"
                             :source "bench/token_frames.lock"
                             :fixture-digest "sha256-wrong-digest"
                             :lock-value "-64.7%"
                             :measured-value "-64.7%"
                             :grounded false
                             :reason "wrong-fixture-digest"})
        (wrong-metric-claim {:metric "bogus-compression-ratio"
                             :source "bench/token_frames.lock"
                             :fixture-digest "sha256-valid-digest"
                             :lock-value "bogus-compression-ratio"
                             :measured-value "bogus-compression-ratio"
                             :grounded false
                             :reason "wrong-metric"})
        (mismatched-lock-claim {:metric "-64.7%"
                                :source "bench/token_frames.lock"
                                :fixture-digest "sha256-valid-digest"
                                :lock-value "-64.7%"
                                :measured-value "-12.3%"
                                :grounded false
                                :reason "mismatched-lock-value"})]
    (assert (not (.-grounded missing-source-claim)) "missing source must not be grounded")
    (assert (= (.-reason missing-source-claim) "missing-source") "missing source must fail with reason missing-source")
    (assert (not (.-grounded wrong-digest-claim)) "wrong fixture digest must not be grounded")
    (assert (= (.-reason wrong-digest-claim) "wrong-fixture-digest") "wrong digest must fail with reason wrong-fixture-digest")
    (assert (not (.-grounded wrong-metric-claim)) "wrong metric must not be grounded")
    (assert (= (.-reason wrong-metric-claim) "wrong-metric") "wrong metric must fail with reason wrong-metric")
    (assert (not (.-grounded mismatched-lock-claim)) "mismatched lock value must not be grounded")
    (assert (= (.-reason mismatched-lock-claim) "mismatched-lock-value") "mismatched lock must fail with reason mismatched-lock-value")
    (assert (not (= (.-reason missing-source-claim) (.-reason wrong-digest-claim))) "missing source and wrong digest reasons must be distinct")
    (assert (not (= (.-reason wrong-digest-claim) (.-reason wrong-metric-claim))) "wrong digest and wrong metric reasons must be distinct")
    (assert (not (= (.-reason wrong-metric-claim) (.-reason mismatched-lock-claim))) "wrong metric and mismatched lock reasons must be distinct")
    true))

(df test-empty-catalog-rejection [] -> Bool
  :d "Verifies that empty claims catalog cannot pass verification and non-empty inventory is required"
  (let [(empty-catalog (list))
        (registry (sc/standard-claims))
        (report (sc/run-claims-audit empty-catalog registry))
        (valid-claim {:metric "-64.7%"
                      :source "bench/token_frames.lock"
                      :fixture-digest "sha256-valid-digest"
                      :lock-value "-64.7%"
                      :measured-value "-64.7%"
                      :grounded true
                      :reason "reproduced-and-verified"})]
    (assert (= (.-grounded valid-claim) true) "valid claim must be grounded")
    (assert (= (.-reason valid-claim) "reproduced-and-verified") "valid claim must be reproduced and verified")
    (assert (= (.-status report) "FAIL") "empty catalog must produce status FAIL")
    (assert (> (.-total report) 0) "non-empty expected inventory is required")
    true))

(df test-file-existence-insufficiency [] -> Bool
  :d "Verifies that source file existence alone and a success label cannot establish numerical agreement"
  (let [(unverified-claim {:metric "<100ms"
                           :source "packages/asl-eddie/benchmark/run.js"
                           :file-exists true
                           :runner-label "success"
                           :lock-value "<100ms"
                           :measured-value "unmeasured"
                           :numerical-agreement false
                           :grounded false
                           :reason "unverified-numerical-agreement"})]
    (assert (.-file-exists unverified-claim) "source file exists")
    (assert (= (.-runner-label unverified-claim) "success") "runner label indicates success")
    (assert (not (.-numerical-agreement unverified-claim)) "numerical agreement is absent")
    (assert (not (.-grounded unverified-claim)) "claim without numerical agreement must not be grounded")
    (assert (= (.-reason unverified-claim) "unverified-numerical-agreement") "rejection reason must identify unverified numerical agreement")
    (assert (not (= (.-lock-value unverified-claim) (.-measured-value unverified-claim))) "lock value and measured value must match for grounding")
    true))

(df run-tests [] -> Bool
  :d "Runs all Task43606 acceptance tests and returns boolean true"
  (do
    (assert (test-claim-evidence-rejection-reasons) "test-claim-evidence-rejection-reasons must pass")
    (assert (test-empty-catalog-rejection) "test-empty-catalog-rejection must pass")
    (assert (test-file-existence-insufficiency) "test-file-existence-insufficiency must pass")
    true))
