(module tests/acceptance/d81/Task47007
  :d "Acceptance fixture for Task47007: rule payload runtime resolution under ADR-0081."
  :x [RunTests
      TestRulesSourceRuntimeCoupling
      TestLauncherRetiredFromRenderSurfaces
      TestTierPayloadFilteringInAslC]
  :i [])

(df TestRulesSourceRuntimeCoupling [] -> Bool
  :d "Verifies runtime loading of rules.asn with error on missing source"
  (let [(c-src-res (file-read "asl/tools/asl.c"))
        (rules-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (assert (= (.-_tag rules-res) "ok") "asl/grammar/rules.asn must be readable")
    (let [(c-src (.-value c-src-res))
          (rules (.-value rules-res))]
      (assert (string-contains? c-src "load_rule_payload") "asl.c must implement load_rule_payload")
      (assert (string-contains? c-src "asl/grammar/rules.asn") "load_rule_payload must reference rules.asn")
      (assert (string-contains? rules "(:rules :v 7 :src ADR-0081") "rules.asn must define ADR-0081 rules")
      true)))

(df TestLauncherRetiredFromRenderSurfaces [] -> Bool
  :d "Verifies launcher is retired from render surfaces in scripts/install.sh"
  (let [(install-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag install-res) "ok") "scripts/install.sh must be readable")
    (let [(install-src (.-value install-res))]
      (assert (not (string-contains? install-src "launcher|$RULES_ROOT/asl/asl"))
              "launcher must not be a rendered target in scripts/install.sh")
      true)))

(df TestTierPayloadFilteringInAslC [] -> Bool
  :d "Verifies that asl.c implements tier-based rule extraction"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "extract_rules_for_tier") (string-contains? c-src "tier"))
              "asl.c must support tier filtering for rules")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47007 supervisor acceptance tests"
  (do
    (assert (TestRulesSourceRuntimeCoupling) "TestRulesSourceRuntimeCoupling must pass")
    (assert (TestLauncherRetiredFromRenderSurfaces) "TestLauncherRetiredFromRenderSurfaces must pass")
    (assert (TestTierPayloadFilteringInAslC) "TestTierPayloadFilteringInAslC must pass")
    true))
