(module tests/acceptance/d81/Task47302
  :d "Acceptance fixture for Task47302: configuration is read or removed under ADR-0081."
  :x [RunTests
      TestHynessConfigMatchesVoiceProfileAndLexicon
      TestToolPlaneRemovedFromAslConfig
      TestInertEddieConfigCleaned]
  :i [])

(df TestHynessConfigMatchesVoiceProfileAndLexicon [] -> Bool
  :d "Verifies that .asl/hyness.config.asn matches voice profile and canonical lexicon"
  (let [(cfg-res (file-read ".asl/hyness.config.asn"))]
    (assert (= (.-_tag cfg-res) "ok") ".asl/hyness.config.asn must exist and be readable")
    (let [(cfg (.-value cfg-res))]
      (assert (string-contains? cfg ":profile-name \"hyness-workstation\"")
              "hyness.config.asn must use canonical profile-name hyness-workstation")
      (assert (not (string-contains? cfg "purplelephant-workstation"))
              "hyness.config.asn must not use stale purplelephant-workstation")
      (assert (string-contains? cfg "(:alias :spoken \"асекс\" :maps-to \"genseam\")")
              "hyness.config.asn must map асекс to genseam matching voice profile")
      (assert (not (string-contains? cfg "(:alias :spoken \"асекс\" :maps-to \"asex\")"))
              "hyness.config.asn must not contradict voice profile by mapping асекс to asex")
      true)))

(df TestToolPlaneRemovedFromAslConfig [] -> Bool
  :d "Verifies that unconsumed 42-line tool-plane block is removed from .asl.config.asn"
  (let [(cfg-res (file-read ".asl.config.asn"))]
    (assert (= (.-_tag cfg-res) "ok") ".asl.config.asn must exist and be readable")
    (let [(cfg (.-value cfg-res))]
      (assert (not (string-contains? cfg ":tool-plane"))
              ".asl.config.asn must not contain inert unconsumed :tool-plane block")
      (assert (not (string-contains? cfg ":dynamic-mounting"))
              ".asl.config.asn must not contain unconsumed :dynamic-mounting")
      (assert (not (string-contains? cfg ":base-meta-tools"))
              ".asl.config.asn must not contain unconsumed :base-meta-tools")
      true)))

(df TestInertEddieConfigCleaned [] -> Bool
  :d "Verifies that inert comment-laden .eddie/config.asn is removed or comment-free"
  (let [(eddie-res (file-read ".eddie/config.asn"))]
    (if (= (.-_tag eddie-res) "ok")
      (let [(eddie-txt (.-value eddie-res))]
        (assert (not (string-contains? eddie-txt ";;"))
                ".eddie/config.asn must not contain comments violating C1")
        true)
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47302 supervisor acceptance tests"
  (do
    (assert (TestHynessConfigMatchesVoiceProfileAndLexicon) "TestHynessConfigMatchesVoiceProfileAndLexicon must pass")
    (assert (TestToolPlaneRemovedFromAslConfig) "TestToolPlaneRemovedFromAslConfig must pass")
    (assert (TestInertEddieConfigCleaned) "TestInertEddieConfigCleaned must pass")
    true))
