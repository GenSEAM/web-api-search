(module tests/acceptance/d81/Task-F08
  :d "Acceptance fixture for Task-F08: Ground Site Claims Verification Against Live Measurements under ADR-0081."
  :x [RunTests
      TestSiteClaimsSourceEliminatesTautology
      TestClaimsRegistryReadsDisk
      TestVerifyClaimsGroundingPassesOnValidDisk
      TestTaskF08GroundedInPhaseFINSEL]
  :i [(asl-gates/site-claims :a sc)])

(df TestSiteClaimsSourceEliminatesTautology [] -> Bool
  :d "Verifies site-claims.asl does not execute tautological self-comparison"
  (let [(c-res (file-read "asl/packages/asl-gates/src/site-claims.asl"))]
    (assert (= (.-_tag c-res) "ok") "site-claims.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (not (string-contains? c-src "(run-claims-audit claims claims)"))
              "site-claims.asl must not perform tautological self-audit (run-claims-audit claims claims)")
      (assert (string-contains? c-src "published_claims.asn")
              "site-claims.asl must reference published_claims.asn on disk")
      true)))

(df ! TestClaimsRegistryReadsDisk [] -> Bool
  :d "Verifies published claims can be read directly from disk"
  (let [(p-res (file-read "asl/bench/published_claims.asn"))]
    (assert (= (.-_tag p-res) "ok") "published_claims.asn must exist on disk")
    (let [(p-src (.-value p-res))
          (claims (sc/standard-claims))]
      (assert (>= (list-length claims) 12) "Standard claims must contain at least 12 metrics")
      (fold (fn [(acc Bool) (m Str)] -> Bool
              (assert (string-contains? p-src m) (str "Published claims on disk must contain metric " m))
              true)
            true
            claims))))

(df ! TestVerifyClaimsGroundingPassesOnValidDisk [] -> Bool
  :d "Verifies verify-claims-grounding returns true against disk claims registry"
  (assert (sc/verify-claims-grounding) "verify-claims-grounding must pass against disk claims")
  true)

(df TestTaskF08GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F08 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F08\"") "Must declare Task-F08")
      (assert (string-contains? f-src "site-claims.asl") "Must own site-claims.asl")
      true)))

(df ! RunTests [] -> Bool
  :d "Runs all Task-F08 acceptance checks"
  (do
    (assert (TestSiteClaimsSourceEliminatesTautology) "TestSiteClaimsSourceEliminatesTautology must pass")
    (assert (TestClaimsRegistryReadsDisk) "TestClaimsRegistryReadsDisk must pass")
    (assert (TestVerifyClaimsGroundingPassesOnValidDisk) "TestVerifyClaimsGroundingPassesOnValidDisk must pass")
    (assert (TestTaskF08GroundedInPhaseFINSEL) "TestTaskF08GroundedInPhaseFINSEL must pass")
    true))
