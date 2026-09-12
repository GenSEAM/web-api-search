(module tests/acceptance/d81/Task44105
  :d "Acceptance fixture for Task44105: Protect hidden acceptance across every tool path under ADR-0081."
  :x [RunTests
      TestHiddenAcceptanceRuleInRulesAsn
      TestSessionContractProtectedEvaluationRule
      TestAgentProfilesSpecification
      TestHostAdapterSafePathBoundaryEnforcement
      TestClaudeAgentProfilesDefinitions]
  :i [])

(df TestHiddenAcceptanceRuleInRulesAsn [] -> Bool
  :d "Verifies that rules.asn declares hiddenTests as an invariant enforced by owns rather than prompt"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":rule :id hiddenTests :force :invariant") "Must declare hiddenTests invariant")
      (assert (string-contains? src "the implementer cannot modify grader-owned acceptance tests") "Must state implementer cannot modify acceptance tests")
      (assert (string-contains? src "enforced by :owns in the engine and tool allowlists, not by prompt") "Must state enforcement by owns and allowlists")
      (assert (string-contains? src "ImpossibleBench") "Must cite ImpossibleBench evidence")
      true)))

(df TestSessionContractProtectedEvaluationRule [] -> Bool
  :d "Verifies that session-contract.asn declares protectedHiddenEvaluation rule and isolation schema"
  (let [(s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":rule :id protectedHiddenEvaluation") "Must define protectedHiddenEvaluation rule")
      (assert (string-contains? src "hidden acceptance") "Must specify hidden acceptance protection")
      (assert (string-contains? src ":roleProfileSchema [") "Must define roleProfileSchema")
      (assert (string-contains? src ":field :id \"roleId\"") "Must bind roleId field")
      (assert (string-contains? src ":field :id \"canReadHiddenAcceptance\"") "Must bind canReadHiddenAcceptance field")
      (assert (string-contains? src ":field :id \"canWriteProduction\"") "Must bind canWriteProduction field")
      true)))

(df TestAgentProfilesSpecification [] -> Bool
  :d "Verifies that .asl/profiles.asn defines scout, implementer, and grader isolation profiles"
  (let [(p-res (file-read ".asl/profiles.asn"))]
    (assert (= (.-_tag p-res) "ok") ".asl/profiles.asn must exist and be readable")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":id \"scout\"") "Must define scout profile")
      (assert (string-contains? src ":id \"implementer\"") "Must define implementer profile")
      (assert (string-contains? src ":id \"grader\"") "Must define grader profile")
      (assert (string-contains? src ":deniedReadPaths") "Must define deniedReadPaths")
      (assert (string-contains? src ":deniedWritePaths") "Must define deniedWritePaths")
      (assert (string-contains? src ":isolationContract") "Must define isolationContract")
      true)))

(df TestHostAdapterSafePathBoundaryEnforcement [] -> Bool
  :d "Verifies that asl.c enforces safe path boundaries and rejects traversal or boundary escapes"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "is_safe_path") "Must implement is_safe_path")
      (assert (string-contains? src "normalize_path_components") "Must normalize path components")
      (assert (string-contains? src ":ERR_BOUNDARY_VIOLATION") "Must define ERR_BOUNDARY_VIOLATION error code")
      true)))

(df TestClaudeAgentProfilesDefinitions [] -> Bool
  :d "Verifies that .claude/agents definitions declare teleological roles and tool capabilities"
  (let [(s-res (file-read ".claude/agents/scout.md"))
        (i-res (file-read ".claude/agents/implementer.md"))
        (g-res (file-read ".claude/agents/grader.md"))]
    (assert (= (.-_tag s-res) "ok") ".claude/agents/scout.md must exist and be readable")
    (assert (= (.-_tag i-res) "ok") ".claude/agents/implementer.md must exist and be readable")
    (assert (= (.-_tag g-res) "ok") ".claude/agents/grader.md must exist and be readable")
    (let [(s-text (.-value s-res))
          (i-text (.-value i-res))
          (g-text (.-value g-res))]
      (assert (string-contains? s-text "Scout") "scout.md must declare Scout archetype")
      (assert (string-contains? i-text "Implementer") "implementer.md must declare Implementer archetype")
      (assert (string-contains? g-text "Grader") "grader.md must declare Grader archetype")
      (assert (string-contains? i-text "hidden acceptance") "implementer.md must prohibit hidden acceptance modification")
      (assert (string-contains? g-text "clean context") "grader.md must mandate clean context verification")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44105 supervisor acceptance tests"
  (do
    (assert (TestHiddenAcceptanceRuleInRulesAsn) "TestHiddenAcceptanceRuleInRulesAsn must pass")
    (assert (TestSessionContractProtectedEvaluationRule) "TestSessionContractProtectedEvaluationRule must pass")
    (assert (TestAgentProfilesSpecification) "TestAgentProfilesSpecification must pass")
    (assert (TestHostAdapterSafePathBoundaryEnforcement) "TestHostAdapterSafePathBoundaryEnforcement must pass")
    (assert (TestClaudeAgentProfilesDefinitions) "TestClaudeAgentProfilesDefinitions must pass")
    true))
