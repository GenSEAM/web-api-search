(module tests/acceptance/d81/Task44108
  :d "Acceptance fixture for Task44108: Handle uncovered steps with reversible containment and escalation under ADR-0081."
  :x [RunTests
      TestEdgeRuleSpecificationInRulesAsn
      TestSessionContractEdgeEscalationRuleAndSchema
      TestEdgeScenarioFixtures
      TestHostAdapterEscalateOperation]
  :i [])

(df TestEdgeRuleSpecificationInRulesAsn [] -> Bool
  :d "Verifies that rules.asn declares the canonical edge procedure and declared bias"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":rule :id edge :force :orientation") "Must define edge rule as orientation")
      (assert (string-contains? src "preserve optionality") "Must specify preserve optionality")
      (assert (string-contains? src "smallest diff inside :owns") "Must specify containment inside owns")
      (assert (string-contains? src "run the cheapest thing that would prove you wrong") "Must specify cheap refutation")
      (assert (string-contains? src "reversibility over optimality") "Must specify declared bias")
      true)))

(df TestSessionContractEdgeEscalationRuleAndSchema [] -> Bool
  :d "Verifies that session-contract.asn declares edgeEscalation rule and escalationSchema"
  (let [(s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":rule :id edgeEscalation") "Must define edgeEscalation rule")
      (assert (string-contains? src ":escalationSchema [") "Must define escalationSchema")
      (assert (string-contains? src ":field :id \"escalationId\"") "Must bind escalationId field")
      (assert (string-contains? src ":field :id \"seen\"") "Must bind seen field")
      (assert (string-contains? src ":field :id \"tried\"") "Must bind tried field")
      (assert (string-contains? src ":field :id \"fork\"") "Must bind fork field")
      (assert (string-contains? src ":field :id \"resolves\"") "Must bind resolves field")
      (assert (string-contains? src ":field :id \"marksCompleted\"") "Must bind marksCompleted field")
      true)))

(df TestEdgeScenarioFixtures [] -> Bool
  :d "Verifies that edge_scenario.asn defines uncovered, unauthorized, refutation, and escalation scenarios"
  (let [(f-res (file-read "tests/fixtures/edge_scenario.asn"))]
    (assert (= (.-_tag f-res) "ok") "tests/fixtures/edge_scenario.asn must exist and be readable")
    (let [(src (.-value f-res))]
      (assert (string-contains? src ":scenario :id \"uncoveredStep\"") "Must define uncoveredStep scenario")
      (assert (string-contains? src ":scenario :id \"unauthorizedMutation\"") "Must define unauthorizedMutation scenario")
      (assert (string-contains? src ":scenario :id \"cheapRefutation\"") "Must define cheapRefutation scenario")
      (assert (string-contains? src ":scenario :id \"escalationReceipt\"") "Must define escalationReceipt scenario")
      (assert (string-contains? src ":marksCompleted false") "Escalation must never mark task completed")
      true)))

(df TestHostAdapterEscalateOperation [] -> Bool
  :d "Verifies that rpc.asn and asl.c implement typed escalate operation with non-completion guarantee"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag r-res) "ok") "rpc.asn must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(r-src (.-value r-res))
          (c-src (.-value c-res))]
      (assert (string-contains? r-src ":id \"asl-escalate\"") "Must declare asl-escalate operation")
      (assert (string-contains? c-src "op_escalate") "Must implement op_escalate in host adapter")
      (assert (string-contains? c-src ":marksCompleted false") "Host adapter must emit marksCompleted false")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44108 supervisor acceptance tests"
  (do
    (assert (TestEdgeRuleSpecificationInRulesAsn) "TestEdgeRuleSpecificationInRulesAsn must pass")
    (assert (TestSessionContractEdgeEscalationRuleAndSchema) "TestSessionContractEdgeEscalationRuleAndSchema must pass")
    (assert (TestEdgeScenarioFixtures) "TestEdgeScenarioFixtures must pass")
    (assert (TestHostAdapterEscalateOperation) "TestHostAdapterEscalateOperation must pass")
    true))
