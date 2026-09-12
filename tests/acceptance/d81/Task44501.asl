(module tests/acceptance/d81/Task44501
  :d "Acceptance fixture for Task44501: Every rule names its checker; advisory rules visibly marked under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRulesAsnEveryRuleHasCheck
      TestAslDoctorRuleClassification
      TestGate7RejectsPhantomCheckerContract
      TestInstallScriptRulesRendering
      TestTask44501GroundedInPhase445]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestRulesAsnEveryRuleHasCheck [] -> Bool
  :d "Verifies that every rule in asl/grammar/rules.asn carries a :check field"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src ":rule :id semantics") "rules.asn must define semantics rule")
      (assert (string-contains? r-src ":rule :id gates") "rules.asn must define gates rule")
      (assert (string-contains? r-src ":rule :id ssot") "rules.asn must define ssot rule")
      (assert (string-contains? r-src ":check \"./bin/asl audit gates\"") "semantics must carry audit gates check")
      (assert (string-contains? r-src ":check \"./scripts/install.sh --check-rules\"") "ssot must carry check-rules check")
      (assert (string-contains? r-src ":check \"./bin/asl doctor\"") "capabilities must carry doctor check")
      (assert (string-contains? r-src ":check :none") "advisory rules must carry :check :none")
      true)))

(df TestAslDoctorRuleClassification [] -> Bool
  :d "Verifies asl/tools/asl.c run_doctor emits structured rule classification with enforced and advisory statuses"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_doctor") "asl.c must define run_doctor")
      (assert (string-contains? c-src ":rules [") "run_doctor must emit :rules section")
      (assert (string-contains? c-src "":enforced"") "run_doctor must classify enforced rules")
      (assert (string-contains? c-src "":advisory"") "run_doctor must classify advisory rules")
      true)))

(df TestGate7RejectsPhantomCheckerContract [] -> Bool
  :d "Verifies asl/tools/asl.c gate 7 invokes check_rule_checkers to reject phantom checkers"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_rule_checkers") "asl.c must define check_rule_checkers")
      (assert (string-contains? c-src "if (check_rule_checkers(ws_root) != 0)") "gate 7 must call check_rule_checkers")
      true)))

(df TestInstallScriptRulesRendering [] -> Bool
  :d "Verifies scripts/install.sh implements rules check and render modes"
  (let [(i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(i-src (.-value i-res))]
      (assert (string-contains? i-src "--render-rules") "install.sh must implement --render-rules")
      (assert (string-contains? i-src "--check-rules") "install.sh must implement --check-rules")
      (assert (string-contains? i-src "rules: all surfaces identical") "install.sh must report surface identity")
      true)))

(df TestTask44501GroundedInPhase445 [] -> Bool
  :d "Verifies Phase 445 task collection grounds Task44501"
  (let [(p-res (file-read ".asl/mem/tasks/Phase445StaticConfirmationCoverage.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 445 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Every rule names its checker; an unchecked rule is visibly advisory") "Phase 445 must state Task44501 title")
      (assert (string-contains? p-src "Every rule carries :check") "Phase 445 must state :check outcome")
      (assert (string-contains? p-src "Advisory rules are marked as such in the rendered payload") "Phase 445 must state advisory outcome")
      (assert (string-contains? p-src "doctor verifies each checker exists and can fail") "Phase 445 must state doctor outcome")
      (assert (string-contains? p-src "Gate 7 rejects a phantom checker") "Phase 445 must state gate 7 outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44501 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRulesAsnEveryRuleHasCheck) "TestRulesAsnEveryRuleHasCheck must pass")
    (assert (TestAslDoctorRuleClassification) "TestAslDoctorRuleClassification must pass")
    (assert (TestGate7RejectsPhantomCheckerContract) "TestGate7RejectsPhantomCheckerContract must pass")
    (assert (TestInstallScriptRulesRendering) "TestInstallScriptRulesRendering must pass")
    (assert (TestTask44501GroundedInPhase445) "TestTask44501GroundedInPhase445 must pass")
    true))
