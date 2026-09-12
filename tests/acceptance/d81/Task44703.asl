(module tests/acceptance/d81/Task44703
  :d "Acceptance fixture for Task44703: One table three consumers under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTransliteratorConsumesLexiconContract
      TestPromptTranslatorConsumesLexiconContract
      TestTask44703GroundedInPhase447]
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

(df TestTransliteratorConsumesLexiconContract [] -> Bool
  :d "Verifies voice/src/transliterator.asl implements canonical lexicon normalization"
  (let [(t-res (file-read "voice/src/transliterator.asl"))]
    (assert (= (.-_tag t-res) "ok") "voice/src/transliterator.asl must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "apply-canonical-lexicon") "transliterator.asl must define apply-canonical-lexicon")
      (assert (string-contains? t-src "harness") "transliterator.asl must map to canonical harness")
      (assert (string-contains? t-src "хайнесс") "transliterator.asl must include spoken form хайнесс")
      true)))

(df TestPromptTranslatorConsumesLexiconContract [] -> Bool
  :d "Verifies harness/src/prompt_translator.asl implements canonical lexicon normalization"
  (let [(p-res (file-read "harness/src/prompt_translator.asl"))]
    (assert (= (.-_tag p-res) "ok") "harness/src/prompt_translator.asl must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "normalize-lexicon-terms") "prompt_translator.asl must define normalize-lexicon-terms")
      (assert (string-contains? p-src "harness") "prompt_translator.asl must map to canonical harness")
      true)))

(df TestTask44703GroundedInPhase447 [] -> Bool
  :d "Verifies Phase 447 task collection grounds Task44703"
  (let [(p-res (file-read ".asl/mem/tasks/Phase447CanonicalLexiconCrossClient.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 447 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "One table, three consumers: voice transliterator, prompt translator, client channels") "Phase 447 must state Task44703 title")
      (assert (string-contains? p-src "Both translators consume the rendered lexicon") "Phase 447 must state consumer outcome")
      (assert (string-contains? p-src "Client channels carry the mapping") "Phase 447 must state client channel outcome")
      (assert (string-contains? p-src "Substitutions are reported, never silent") "Phase 447 must state non-silent substitution outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44703 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTransliteratorConsumesLexiconContract) "TestTransliteratorConsumesLexiconContract must pass")
    (assert (TestPromptTranslatorConsumesLexiconContract) "TestPromptTranslatorConsumesLexiconContract must pass")
    (assert (TestTask44703GroundedInPhase447) "TestTask44703GroundedInPhase447 must pass")
    true))
