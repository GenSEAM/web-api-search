(module tests/acceptance/d81/Task44005
  :d "Acceptance fixture for Task44005: Publish only settled measured self-hosting and language claims under ADR-0081."
  :x [RunTests
      TestPublishedClaimsStandardsGrounding
      TestSelfHostingStagesDocumentation
      TestPeripheralScopesTruthfulness
      TestSettledChoicesAndReceiptsBinding]
  :i [])

(df TestPublishedClaimsStandardsGrounding [] -> Bool
  :d "Verifies published_claims.asn grounds quantitative claims with declared sources"
  (let [(p-res (file-read "asl/bench/published_claims.asn"))]
    (assert (= (.-_tag p-res) "ok") "published_claims.asn must exist and be readable")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":standards [") "Must define standards list")
      (assert (string-contains? src ":metric \"57%–65%\"") "Must ground structural token compression")
      (assert (string-contains? src ":metric \"-64.7%\"") "Must ground tool frame compression")
      (assert (string-contains? src ":metric \"<=2 tokens\"") "Must ground primitive token cost ceiling")
      (assert (string-contains? src ":metric \"107/107\"") "Must ground vocab coverage")
      (assert (string-contains? src ":metric \"0.038ms\"") "Must ground wasm launch latency")
      (assert (string-contains? src ":metric \"<0.04ms\"") "Must ground bus latency")
      true)))

(df TestSelfHostingStagesDocumentation [] -> Bool
  :d "Verifies that self-hosting contract documents stage0, stage1, stage2, and WASM stages accurately"
  (let [(s-res (file-read "asl/grammar/self-hosting-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "self-hosting-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":stage :id 0") "Must document stage 0 seed")
      (assert (string-contains? src ":stage :id 1") "Must document stage 1 compiler")
      (assert (string-contains? src ":stage :id 2") "Must document stage 2 autonomous native tool")
      (assert (string-contains? src ":stage :id \"wasm\"") "Must document WASM compilation target")
      (assert (string-contains? src "bootstrap-closure") "Must declare bootstrap closure claim")
      (assert (string-contains? src "declared-boundaries") "Must declare host boundaries claim")
      true)))

(df TestPeripheralScopesTruthfulness [] -> Bool
  :d "Verifies peripheral scopes explicitly mark conceptual schemas as non-falsifiable"
  (let [(p-res (file-read "asl/bench/published_claims.asn"))]
    (assert (= (.-_tag p-res) "ok") "published_claims.asn must exist")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":peripheral-scopes [") "Must define peripheral scopes")
      (assert (string-contains? src ":package \"asl-quantum\"") "Must scope quantum package")
      (assert (string-contains? src ":package \"asl-arduino\"") "Must scope arduino package")
      (assert (string-contains? src ":package \"asl-voice\"") "Must scope voice package")
      (assert (string-contains? src ":falsifiable false") "Must mark non-falsifiable")
      true)))

(df TestSettledChoicesAndReceiptsBinding [] -> Bool
  :d "Verifies that ADR-0081 and receipts ledger document settled choices without unsupported claims"
  (let [(a-res (file-read ".asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn"))
        (r-res (file-read ".asl/mem/receipts.asn"))]
    (assert (= (.-_tag a-res) "ok") "ADR-0081 must exist and be readable")
    (assert (= (.-_tag r-res) "ok") "receipts.asn must exist and be readable")
    (let [(a-src (.-value a-res))
          (r-src (.-value r-res))]
      (assert (string-contains? a-src ":settledChoices") "ADR-0081 must define :settledChoices")
      (assert (string-contains? a-src ":dependencyClasses") "ADR-0081 must define :dependencyClasses")
      (assert (string-contains? a-src ":choice :id nativeArtifact") "Must define nativeArtifact settled choice")
      (assert (string-contains? r-src ":status :verified") "Receipts ledger must record verified receipts")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44005 supervisor acceptance tests"
  (do
    (assert (TestPublishedClaimsStandardsGrounding) "TestPublishedClaimsStandardsGrounding must pass")
    (assert (TestSelfHostingStagesDocumentation) "TestSelfHostingStagesDocumentation must pass")
    (assert (TestPeripheralScopesTruthfulness) "TestPeripheralScopesTruthfulness must pass")
    (assert (TestSettledChoicesAndReceiptsBinding) "TestSettledChoicesAndReceiptsBinding must pass")
    true))
