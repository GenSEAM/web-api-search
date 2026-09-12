(module tests/acceptance/d81/Task46802
  :d "Acceptance fixture for Task46802: reconstructibility threshold governing durable memory writes under ADR-0081."
  :x [RunTests
      TestRulesDeclareReconstructibilityThreshold
      TestPrinciplesDeclareReconstructibilityTest
      TestReconstructibleRecordRefusalNamesCommand
      TestRejectedAlternativeAcceptedWithoutTopicEnumeration]
  :i [])

(df TestRulesDeclareReconstructibilityThreshold [] -> Bool
  :d "Verifies that asl/grammar/rules.asn defines the reconstructibility write threshold rule"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":rule :id threshold")
                  (or (string-contains? src ":rule :id writeThreshold")
                      (string-contains? src ":rule :id reconstructibility")))
              "rules.asn must define write threshold rule")
      (assert (string-contains? src "reconstruct")
              "rules.asn must state reconstructibility test")
      true)))

(df TestPrinciplesDeclareReconstructibilityTest [] -> Bool
  :d "Verifies that .asl/mem/principles.asn defines the reconstructibility principle"
  (let [(res (file-read ".asl/mem/principles.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/principles.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "Reconstructibility")
                  (string-contains? src "WriteThreshold"))
              "principles.asn must declare reconstructibility principle")
      (assert (string-contains? src "reconstruct")
              "principles.asn must state reconstructibility threshold")
      true)))

(df TestReconstructibleRecordRefusalNamesCommand [] -> Bool
  :d "Verifies that restating what a command reports is refused and names the command"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "refused")
              "rules.asn must specify refusal for reconstructible records")
      (assert (string-contains? src "names the command")
              "rules.asn must require refusal to name reporting command")
      true)))

(df TestRejectedAlternativeAcceptedWithoutTopicEnumeration [] -> Bool
  :d "Verifies that rejected alternatives are accepted and rule does not enumerate acceptable topics"
  (let [(res (file-read ".asl/mem/principles.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/principles.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "rejected alternative")
              "principles.asn must declare rejected alternatives acceptable")
      (assert (not (string-contains? src ":acceptableTopics"))
              "principles.asn must not enumerate acceptable topics")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46802 supervisor acceptance tests"
  (do
    (assert (TestRulesDeclareReconstructibilityThreshold) "TestRulesDeclareReconstructibilityThreshold must pass")
    (assert (TestPrinciplesDeclareReconstructibilityTest) "TestPrinciplesDeclareReconstructibilityTest must pass")
    (assert (TestReconstructibleRecordRefusalNamesCommand) "TestReconstructibleRecordRefusalNamesCommand must pass")
    (assert (TestRejectedAlternativeAcceptedWithoutTopicEnumeration) "TestRejectedAlternativeAcceptedWithoutTopicEnumeration must pass")
    true))
