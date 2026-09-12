(module tests/acceptance/d81/Task44704
  :d "Acceptance fixture for Task44704: Lexicon checker: no orphan alias, no local table, no mishearing in artifacts under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLexiconGateModuleContract
      TestLexiconManifestAndGrammarContract
      TestInstallScriptLexiconCheckerContract
      TestAslNativeGateLexiconAuditContract
      TestTask44704GroundedInPhase447]
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

(df TestLexiconGateModuleContract [] -> Bool
  :d "Verifies asl/packages/asl-gates/src/lexicon_gate.asl defines canonical lexicon audit contracts"
  (let [(m-res (file-read "asl/packages/asl-gates/src/lexicon_gate.asl"))]
    (assert (= (.-_tag m-res) "ok") "lexicon_gate.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "asl-gates/lexicon-gate") "Must declare module asl-gates/lexicon-gate")
      (assert (string-contains? m-src "LexiconTerm") "Must export LexiconTerm")
      (assert (string-contains? m-src "LexiconRegistry") "Must export LexiconRegistry")
      (assert (string-contains? m-src "audit-lexicon-terms") "Must export audit-lexicon-terms")
      (assert (string-contains? m-src "check-local-alias-tables") "Must export check-local-alias-tables")
      (assert (string-contains? m-src "verify-canonical-referents") "Must export verify-canonical-referents")
      (assert (string-contains? m-src "is-spoken-mishearing?") "Must export is-spoken-mishearing?")
      true)))

(df TestLexiconManifestAndGrammarContract [] -> Bool
  :d "Verifies manifest.asn and grammar.asn register lexicon gate module and symbols"
  (let [(man-res (file-read "asl/packages/asl-gates/manifest.asn"))
        (gram-res (file-read "asl/packages/asl-gates/grammar.asn"))]
    (assert (= (.-_tag man-res) "ok") "asl-gates/manifest.asn must exist and be readable")
    (assert (= (.-_tag gram-res) "ok") "asl-gates/grammar.asn must exist and be readable")
    (let [(man-src (.-value man-res))
          (gram-src (.-value gram-res))]
      (assert (string-contains? man-src "asl-gates/lexicon-gate") "manifest must register lexicon-gate")
      (assert (string-contains? gram-src ":name \"LexiconTerm\"") "grammar must register LexiconTerm")
      (assert (string-contains? gram-src ":name \"LexiconRegistry\"") "grammar must register LexiconRegistry")
      (assert (string-contains? gram-src ":name \"audit-lexicon-terms\"") "grammar must register audit-lexicon-terms")
      (assert (string-contains? gram-src ":name \"check-local-alias-tables\"") "grammar must register check-local-alias-tables")
      (assert (string-contains? gram-src ":name \"verify-canonical-referents\"") "grammar must register verify-canonical-referents")
      true)))

(df TestInstallScriptLexiconCheckerContract [] -> Bool
  :d "Verifies scripts/install.sh implements the 4 static lexicon checks under --check-lexicon"
  (let [(i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(i-src (.-value i-res))]
      (assert (string-contains? i-src "--check-lexicon") "install.sh must provide --check-lexicon")
      (assert (string-contains? i-src "alias_table") "install.sh must audit local alias tables")
      (assert (string-contains? i-src "harness") "install.sh must verify canonical harness referent")
      (assert (string-contains? i-src "0 orphan aliases, 0 local tables, 0 mishearings") "install.sh must report zero defects summary")
      true)))

(df TestAslNativeGateLexiconAuditContract [] -> Bool
  :d "Verifies asl/tools/asl.c integrates lexicon source verification in run_gate_6_grammar"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "asl/grammar/lexicon.asn") "asl.c must reference lexicon.asn in gate 6")
      (assert (string-contains? c-src "run_gate_6_grammar") "asl.c must define run_gate_6_grammar")
      true)))

(df TestTask44704GroundedInPhase447 [] -> Bool
  :d "Verifies Phase 447 task collection grounds Task44704"
  (let [(p-res (file-read ".asl/mem/tasks/Phase447CanonicalLexiconCrossClient.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 447 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Lexicon checker: no orphan alias, no local table, no mishearing in artifacts") "Phase 447 must state Task44704 title")
      (assert (string-contains? p-src "Divergence across surfaces reported") "Phase 447 must state divergence outcome")
      (assert (string-contains? p-src "Local alias tables reported") "Phase 447 must state local alias outcome")
      (assert (string-contains? p-src "Spoken form appearing as an artifact name reported") "Phase 447 must state artifact mishearing outcome")
      (assert (string-contains? p-src "Canonical value with no referent reported") "Phase 447 must state canonical referent outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44704 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLexiconGateModuleContract) "TestLexiconGateModuleContract must pass")
    (assert (TestLexiconManifestAndGrammarContract) "TestLexiconManifestAndGrammarContract must pass")
    (assert (TestInstallScriptLexiconCheckerContract) "TestInstallScriptLexiconCheckerContract must pass")
    (assert (TestAslNativeGateLexiconAuditContract) "TestAslNativeGateLexiconAuditContract must pass")
    (assert (TestTask44704GroundedInPhase447) "TestTask44704GroundedInPhase447 must pass")
    true))
