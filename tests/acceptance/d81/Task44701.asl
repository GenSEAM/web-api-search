(module tests/acceptance/d81/Task44701
  :d "Acceptance fixture for Task44701: Canonical lexicon as single source rendered to clients under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLexiconSingleSourceContract
      TestInstallScriptLexiconRendererContract
      TestTask44701GroundedInPhase447]
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

(df TestLexiconSingleSourceContract [] -> Bool
  :d "Verifies asl/grammar/lexicon.asn defines canonical spoken-to-canonical mappings"
  (let [(l-res (file-read "asl/grammar/lexicon.asn"))]
    (assert (= (.-_tag l-res) "ok") "asl/grammar/lexicon.asn must exist and be readable")
    (let [(l-src (.-value l-res))]
      (assert (string-contains? l-src ":canonical \"harness\"") "lexicon.asn must map to canonical harness")
      (assert (string-contains? l-src "хайнесс") "lexicon.asn must include spoken form хайнесс")
      (assert (string-contains? l-src "ханес") "lexicon.asn must include spoken form ханес")
      (assert (string-contains? l-src ":canonical \"asex\"") "lexicon.asn must include canonical asex")
      (assert (string-contains? l-src ":canonical \"shrody\"") "lexicon.asn must include canonical shrody")
      (assert (string-contains? l-src ":canonical \"pcp\"") "lexicon.asn must include canonical pcp")
      (assert (string-contains? l-src ":scope") "lexicon.asn entries must define :scope")
      (assert (string-contains? l-src ":why") "lexicon.asn entries must define :why rationale")
      true)))

(df TestInstallScriptLexiconRendererContract [] -> Bool
  :d "Verifies scripts/install.sh implements --render-lexicon and --check-lexicon CLI surfaces"
  (let [(i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(i-src (.-value i-res))]
      (assert (string-contains? i-src "--render-lexicon") "install.sh must provide --render-lexicon option")
      (assert (string-contains? i-src "--check-lexicon") "install.sh must provide --check-lexicon option")
      (assert (string-contains? i-src "lexicon.asn") "install.sh must reference lexicon.asn")
      true)))

(df TestTask44701GroundedInPhase447 [] -> Bool
  :d "Verifies Phase 447 task collection grounds canonical lexicon single source contract"
  (let [(p-res (file-read ".asl/mem/tasks/Phase447CanonicalLexiconCrossClient.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 447 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Canonical lexicon as a single source, rendered to every client") "Phase 447 must state task title")
      (assert (string-contains? p-src "asl/grammar/lexicon.asn with multiple spoken forms per term") "Phase 447 must state multiple spoken forms outcome")
      (assert (string-contains? p-src "Rendered into every client channel and both translators") "Phase 447 must state renderer outcome")
      (assert (string-contains? p-src "--check-lexicon gates divergence") "Phase 447 must state drift checker outcome")
      (assert (string-contains? p-src "хайнесс maps to harness") "Phase 447 must state acoustic mishearing resolution outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44701 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLexiconSingleSourceContract) "TestLexiconSingleSourceContract must pass")
    (assert (TestInstallScriptLexiconRendererContract) "TestInstallScriptLexiconRendererContract must pass")
    (assert (TestTask44701GroundedInPhase447) "TestTask44701GroundedInPhase447 must pass")
    true))
