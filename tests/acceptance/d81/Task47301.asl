(module tests/acceptance/d81/Task47301
  :d "Acceptance fixture for Task47301: registry symbols must exist in declaring package under ADR-0081."
  :x [RunTests
      TestGate6ChecksSymbolExistenceInAslC
      TestNoPhantomSymbolsInRegistries
      TestGate6DetectsMisplacedSymbols]
  :i [])

(df TestGate6ChecksSymbolExistenceInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c enforces symbol existence and placement in Gate 6"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "check_registry_symbols")
              "asl.c must implement check_registry_symbols for Gate 6")
      (assert (string-contains? c-src "Phantom symbol")
              "asl.c Gate 6 must report phantom symbols")
      (assert (string-contains? c-src "Misplaced symbol")
              "asl.c Gate 6 must report misplaced symbols")
      true)))

(df TestNoPhantomSymbolsInRegistries [] -> Bool
  :d "Verifies that known phantom symbols are resolved and removed from grammar registries"
  (let [(pack-reg-res (file-read "pack/grammar.asn"))
        (harness-reg-res (file-read "harness/grammar.asn"))
        (agent-core-reg-res (file-read "agent-core/grammar.asn"))
        (crawler-reg-res (file-read "crawler/grammar.asn"))]
    (assert (= (.-_tag pack-reg-res) "ok") "pack/grammar.asn must be readable")
    (assert (= (.-_tag harness-reg-res) "ok") "harness/grammar.asn must be readable")
    (assert (= (.-_tag agent-core-reg-res) "ok") "agent-core/grammar.asn must be readable")
    (assert (= (.-_tag crawler-reg-res) "ok") "crawler/grammar.asn must be readable")
    (let [(pack-txt (.-value pack-reg-res))
          (harness-txt (.-value harness-reg-res))
          (agent-core-txt (.-value agent-core-reg-res))
          (crawler-txt (.-value crawler-reg-res))]
      (assert (not (string-contains? pack-txt "LashLaminationSpec"))
              "pack/grammar.asn must not declare phantom LashLaminationSpec")
      (assert (not (string-contains? pack-txt "EyeInstance"))
              "pack/grammar.asn must not declare phantom EyeInstance")
      (assert (not (string-contains? harness-txt "DaemonConfig"))
              "harness/grammar.asn must not declare phantom DaemonConfig")
      (assert (not (string-contains? agent-core-txt "pipeline-execute"))
              "agent-core/grammar.asn must not declare phantom pipeline-execute")
      (assert (not (string-contains? crawler-txt "CacheProvider"))
              "crawler/grammar.asn must not declare phantom CacheProvider")
      true)))

(df TestGate6DetectsMisplacedSymbols [] -> Bool
  :d "Verifies that intel/grammar.asn does not claim symbols implemented in mem package"
  (let [(intel-reg-res (file-read "intel/grammar.asn"))]
    (assert (= (.-_tag intel-reg-res) "ok") "intel/grammar.asn must be readable")
    (let [(intel-txt (.-value intel-reg-res))]
      (assert (not (string-contains? intel-txt "XRefEdge"))
              "intel/grammar.asn must not declare XRefEdge which belongs to mem package")
      (assert (not (string-contains? intel-txt "XRefGraph"))
              "intel/grammar.asn must not declare XRefGraph which belongs to mem package")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47301 supervisor acceptance tests"
  (do
    (assert (TestGate6ChecksSymbolExistenceInAslC) "TestGate6ChecksSymbolExistenceInAslC must pass")
    (assert (TestNoPhantomSymbolsInRegistries) "TestNoPhantomSymbolsInRegistries must pass")
    (assert (TestGate6DetectsMisplacedSymbols) "TestGate6DetectsMisplacedSymbols must pass")
    true))
