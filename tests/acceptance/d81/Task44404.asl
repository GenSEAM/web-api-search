(module tests/acceptance/d81/Task44404
  :d "Acceptance fixture for Task44404: Mutation strategy under a budget: selection, equivalence and incrementality under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestMutationCorpusFixedByVerifier
      TestSelectionRuleAndSeedReproducibilityContract
      TestEquivalentMutantTriageContract
      TestIncrementalCacheByDigestContract
      TestTask44404GroundedInPhase444]
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

(df TestMutationCorpusFixedByVerifier [] -> Bool
  :d "Verifies that verifier fixed a mutation corpus with a known killable and a known equivalent mutant"
  (let [(c-res (file-read "asl/bench/tasks/mutation_corpus.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl/bench/tasks/mutation_corpus.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":mutation-corpus") "Corpus must declare :mutation-corpus")
      (assert (string-contains? c-src "mut-kill-01") "Corpus must contain known killable mutant mut-kill-01")
      (assert (string-contains? c-src ":expectedOutcome :killed") "Corpus must specify expectedOutcome :killed")
      (assert (string-contains? c-src "mut-equiv-01") "Corpus must contain known equivalent mutant mut-equiv-01")
      (assert (string-contains? c-src ":expectedOutcome :equivalent") "Corpus must specify expectedOutcome :equivalent")
      (assert (string-contains? c-src ":justification") "Equivalent mutant must carry explicit justification")
      true)))

(df TestSelectionRuleAndSeedReproducibilityContract [] -> Bool
  :d "Verifies selection rule with recorded seed across core packages and changed symbols"
  (let [(b-res (file-read "asl/bench/mutation_strategy.asl"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag b-res) "ok") "asl/bench/mutation_strategy.asl must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(b-src (.-value b-res))
          (c-src (.-value c-res))]
      (assert (string-contains? b-src "SelectMutants") "mutation_strategy.asl must implement SelectMutants")
      (assert (string-contains? b-src "record-seed") "mutation_strategy.asl must track recorded seed")
      (assert (string-contains? b-src "core-tier") "mutation_strategy.asl must select core-tier package assertions")
      (assert (string-contains? c-src "run_cmd_mutate") "asl.c must implement run_cmd_mutate")
      (assert (string-contains? c-src "--seed") "asl.c must support --seed option")
      (assert (string-contains? c-src "--budget-ms") "asl.c must support --budget-ms option")
      true)))

(df TestEquivalentMutantTriageContract [] -> Bool
  :d "Verifies that surviving mutants are triaged into killed, equivalent with justification, and surviving"
  (let [(b-res (file-read "asl/bench/mutation_strategy.asl"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag b-res) "ok") "asl/bench/mutation_strategy.asl must exist")
    (assert (= (.-_tag c-res) "ok") "asl.c must exist")
    (let [(b-src (.-value b-res))
          (c-src (.-value c-res))]
      (assert (string-contains? b-src "TriageMutant") "mutation_strategy.asl must implement TriageMutant")
      (assert (string-contains? b-src "CalculateMutationScore") "mutation_strategy.asl must compute mutation score")
      (assert (string-contains? b-src ":equivalent") "mutation_strategy.asl must categorize equivalent mutants")
      (assert (string-contains? c-src ":equivalent") "asl.c mutation report must categorize equivalent mutants")
      (assert (string-contains? c-src ":justification") "asl.c mutation report must include justification for equivalent mutants")
      true)))

(df TestIncrementalCacheByDigestContract [] -> Bool
  :d "Verifies incremental caching keyed by source digest for repeat runs"
  (let [(b-res (file-read "asl/bench/mutation_strategy.asl"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag b-res) "ok") "mutation_strategy.asl must exist")
    (assert (= (.-_tag c-res) "ok") "asl.c must exist")
    (let [(b-src (.-value b-res))
          (c-src (.-value c-res))]
      (assert (string-contains? b-src "DigestCacheLookup") "mutation_strategy.asl must implement DigestCacheLookup")
      (assert (string-contains? b-src ":fromCache") "mutation_strategy.asl must record :fromCache flag")
      (assert (string-contains? c-src ":fromCache") "asl.c must report :fromCache flag")
      (assert (string-contains? c-src ":sourceDigest") "asl.c must key cache by sourceDigest")
      true)))

(df TestTask44404GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44404"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Mutation strategy under a budget") "Phase 444 must state Task44404 title")
      (assert (string-contains? p-src ":lane \"mutation\"") "Phase 444 must specify mutation lane")
      (assert (string-contains? p-src "run_gate_5") "Phase 444 must target run_gate_5")
      (assert (string-contains? p-src "asl/tools/asl.c") "Phase 444 must own asl/tools/asl.c")
      (assert (string-contains? p-src "asl/bench") "Phase 444 must own asl/bench")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44404 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestMutationCorpusFixedByVerifier) "TestMutationCorpusFixedByVerifier must pass")
    (assert (TestSelectionRuleAndSeedReproducibilityContract) "TestSelectionRuleAndSeedReproducibilityContract must pass")
    (assert (TestEquivalentMutantTriageContract) "TestEquivalentMutantTriageContract must pass")
    (assert (TestIncrementalCacheByDigestContract) "TestIncrementalCacheByDigestContract must pass")
    (assert (TestTask44404GroundedInPhase444) "TestTask44404GroundedInPhase444 must pass")
    true))
