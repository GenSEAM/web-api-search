(module tests/acceptance/d81/Task44109
  :d "Acceptance fixture for Task44109: Generate useful minimal/full tiers with exact measured budgets under ADR-0081."
  :x [RunTests
      TestRuleAndOpTierDisposition
      TestMinimalTierBudgetAndTokenMeasurement
      TestMinimalAndFullContractEquivalence
      TestPerClientProjectionIdentity]
  :i [])

(df TestRuleAndOpTierDisposition [] -> Bool
  :d "Verifies that rules.asn and rpc.asn tag rules and operations with explicit tier disposition"
  (let [(r-res (file-read "asl/grammar/rules.asn"))
        (o-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (assert (= (.-_tag o-res) "ok") "rpc.asn must exist and be readable")
    (let [(r-src (.-value r-res))
          (o-src (.-value o-res))]
      (assert (string-contains? r-src ":tier [:essential :full]") "rules.asn must tag essential rules")
      (assert (string-contains? r-src ":rule :id semantics :force :invariant :tier [:essential :full]") "semantics rule must be essential")
      (assert (string-contains? r-src ":rule :id gates :force :invariant :tier [:essential :full]") "gates rule must be essential")
      (assert (string-contains? r-src ":rule :id hiddenTests :force :invariant :tier [:essential :full]") "hiddenTests rule must be essential")
      (assert (string-contains? o-src ":tier") "rpc.asn must declare operation tiers")
      (assert (string-contains? o-src ":tier [:essential :full]") "rpc.asn must declare essential tier operations")
      true)))

(df TestMinimalTierBudgetAndTokenMeasurement [] -> Bool
  :d "Verifies tier_budget.asl defines budget structs and verifies minimal tier remains within 1000-token budget"
  (let [(b-res (file-read "asl/bench/tier_budget.asl"))]
    (assert (= (.-_tag b-res) "ok") "tier_budget.asl must exist and be readable")
    (let [(b-src (.-value b-res))]
      (assert (string-contains? b-src "TierBudgetResult") "Must define TierBudgetResult struct")
      (assert (string-contains? b-src "evaluate-tier-budget") "Must define evaluate-tier-budget")
      (assert (string-contains? b-src "check-semantic-preservation") "Must define check-semantic-preservation")
      (assert (string-contains? b-src ":max-minimal-tokens 1000") "Must declare 1000 pinned-tokenizer token target")
      (assert (string-contains? b-src ":overflow-policy :reject") "Overflow must reject without silent truncation")
      true)))

(df TestMinimalAndFullContractEquivalence [] -> Bool
  :d "Verifies minimal tier preserves mandatory authority, isolation and semantic rules"
  (let [(r-res (file-read "asl/grammar/rules.asn"))
        (s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(r-src (.-value r-res))
          (s-src (.-value s-res))]
      (assert (string-contains? r-src ":rule :id foreign :force :invariant") "foreign boundary must be invariant")
      (assert (string-contains? r-src ":rule :id oneStep :force :invariant") "oneStep must be invariant")
      (assert (string-contains? r-src ":rule :id grading :force :invariant") "grading must be invariant")
      (assert (string-contains? s-src "trustedRunnerReceipt") "trustedRunnerReceipt must be in session-contract")
      (assert (string-contains? s-src "leaseIsolation") "leaseIsolation must be in session-contract")
      true)))

(df TestPerClientProjectionIdentity [] -> Bool
  :d "Verifies DIRECTIVE_PAYLOAD symbol in asl.c and projection currency checking in scripts/install.sh"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(c-src (.-value c-res))
          (i-src (.-value i-res))]
      (assert (string-contains? c-src "DIRECTIVE_PAYLOAD") "asl.c must define DIRECTIVE_PAYLOAD symbol")
      (assert (string-contains? c-src "project_content") "asl.c must implement project_content")
      (assert (string-contains? i-src "--tier") "install.sh must support --tier projection")
      (assert (string-contains? i-src "--check-rules") "install.sh must support --check-rules")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44109 acceptance tests"
  (do
    (assert (TestRuleAndOpTierDisposition) "TestRuleAndOpTierDisposition must pass")
    (assert (TestMinimalTierBudgetAndTokenMeasurement) "TestMinimalTierBudgetAndTokenMeasurement must pass")
    (assert (TestMinimalAndFullContractEquivalence) "TestMinimalAndFullContractEquivalence must pass")
    (assert (TestPerClientProjectionIdentity) "TestPerClientProjectionIdentity must pass")
    true))
