(module tests/acceptance/d81/Task-F09
  :d "Acceptance fixture for Task-F09: Sanitize Crawler CLI Arguments & Enforce SSRF Defenses under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTaskF09GroundedInPhaseFINSEL
      TestCrawlerSourceEnforcesIsolation
      TestCrawlerExportsUrlValidator]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTaskF09GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F09 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F09\"") "Must declare Task-F09")
      (assert (string-contains? f-src "crawler/src/crawler.asl") "Must own crawler/src/crawler.asl")
      true)))

(df TestCrawlerSourceEnforcesIsolation [] -> Bool
  :d "Verifies crawler.asl includes argument isolation -- before target URL"
  (let [(c-res (file-read "crawler/src/crawler.asl"))]
    (assert (= (.-_tag c-res) "ok") "crawler.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "\"--\"") "crawler.asl must isolate URL with -- in curl-args")
      true)))

(df TestCrawlerExportsUrlValidator [] -> Bool
  :d "Verifies crawler.asl defines and exports is-valid-crawl-url? for SSRF defense"
  (let [(c-res (file-read "crawler/src/crawler.asl"))]
    (assert (= (.-_tag c-res) "ok") "crawler.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "is-valid-crawl-url?") "crawler.asl must define is-valid-crawl-url?")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F09 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTaskF09GroundedInPhaseFINSEL) "TestTaskF09GroundedInPhaseFINSEL must pass")
    (assert (TestCrawlerSourceEnforcesIsolation) "TestCrawlerSourceEnforcesIsolation must pass")
    (assert (TestCrawlerExportsUrlValidator) "TestCrawlerExportsUrlValidator must pass")
    true))
