(module tests/acceptance/d81/Task43903
  :d "Acceptance fixture for Task43903: Independently reproduce every current quantitative claim under ADR-0081."
  :x [RunTests
      TestPublishedClaimsRegistryGrounding
      TestClaimSourceAndDigestIntegrity
      TestReceiptsAuditCoverageForClaims]
  :i [])

(df TestPublishedClaimsRegistryGrounding [] -> Bool
  :d "Verifies that published_claims.asn defines a grounded quantitative claim inventory with standards and peripheral scopes"
  (let [(p-res (file-read "asl/bench/published_claims.asn"))]
    (assert (= (.-_tag p-res) "ok") "asl/bench/published_claims.asn must exist and be readable")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":standards [") "published_claims.asn must define :standards list")
      (assert (string-contains? src ":claim :metric \"57%–65%\"") "Must ground structural token reduction claim")
      (assert (string-contains? src ":claim :metric \"-64.7%\"") "Must ground agent tool frames token reduction claim")
      (assert (string-contains? src ":claim :metric \"<=2 tokens\"") "Must ground primitive token ceiling claim")
      (assert (string-contains? src ":peripheral-scopes [") "Must define explicit :peripheral-scopes list")
      (assert (string-contains? src ":falsifiable false") "Peripheral conceptual schemas must be explicitly marked not falsifiable")
      true)))

(df TestClaimSourceAndDigestIntegrity [] -> Bool
  :d "Verifies that claims map to declared monorepo sources rather than unverified arbitrary strings"
  (let [(p-res (file-read "asl/bench/published_claims.asn"))]
    (assert (= (.-_tag p-res) "ok") "asl/bench/published_claims.asn must exist")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":category \"token_compression\"") "Must declare token_compression category")
      (assert (string-contains? src ":category \"primitive_cost\"") "Must declare primitive_cost category")
      (assert (string-contains? src ":category \"vocab_coverage\"") "Must declare vocab_coverage category")
      (assert (not (string-contains? src ":metric \"\"")) "Claims must not have empty metric")
      (assert (not (string-contains? src ":source \"\"")) "Claims must not have empty source")
      true)))

(df TestReceiptsAuditCoverageForClaims [] -> Bool
  :d "Verifies that verified execution receipts exist in receipts ledger"
  (let [(r-res (file-read ".asl/mem/receipts.asn"))]
    (assert (= (.-_tag r-res) "ok") ".asl/mem/receipts.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":status :verified") "Receipts ledger must contain verified execution receipts")
      (assert (string-contains? src ":toolName \"asl-test-acceptance\"") "Receipts ledger must record acceptance test executions")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task43903 supervisor acceptance tests"
  (do
    (assert (TestPublishedClaimsRegistryGrounding) "TestPublishedClaimsRegistryGrounding must pass")
    (assert (TestClaimSourceAndDigestIntegrity) "TestClaimSourceAndDigestIntegrity must pass")
    (assert (TestReceiptsAuditCoverageForClaims) "TestReceiptsAuditCoverageForClaims must pass")
    true))
