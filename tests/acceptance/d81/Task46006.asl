(module tests/acceptance/d81/Task46006
  :d "Acceptance fixture for Task46006: Racket reference decision and deployment boundary under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRacketReferencePolicyContract
      TestRacketDifferentialOracleContract
      TestAdr0081RacketReferenceDecision
      TestForeignRuleSSOTConsistency]
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

(df TestRacketReferencePolicyContract [] -> Bool
  :d "Verifies dependency-boundaries.asn defines Racket reference boundary with forbidden deployed requirement"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src "racket-reference") "dependency-boundaries.asn must define racket-reference boundary")
      (assert (string-contains? d-src ":status :reference-only") "racket-reference must have status reference-only")
      (assert (string-contains? d-src ":deployedRequirement :forbidden") "racket-reference must have deployedRequirement forbidden")
      true)))

(df TestRacketDifferentialOracleContract [] -> Bool
  :d "Verifies dependency-boundaries.asn records differential oracle with maintenance cost and adopted false"
  (let [(d-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag d-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(d-src (.-value d-res))]
      (assert (string-contains? d-src ":differentialOracle") "dependency-boundaries.asn must record differentialOracle")
      (assert (string-contains? d-src ":adopted false") "differentialOracle must be marked adopted false")
      (assert (string-contains? d-src "maintenanceCost") "differentialOracle must record maintenanceCost")
      true)))

(df TestAdr0081RacketReferenceDecision [] -> Bool
  :d "Verifies Adr0081 records the Racket reference and deployment exclusion choice"
  (let [(a-res (file-read ".asl/mem/decisions/Adr0081LanguageGroundTruthAndSovereignPortabilityProgram.asn"))]
    (assert (= (.-_tag a-res) "ok") "Adr0081 must exist and be readable")
    (let [(a-src (.-value a-res))]
      (assert (string-contains? a-src "racketReferencePolicy") "Adr0081 must record racketReferencePolicy settled choice")
      (assert (string-contains? a-src "differential oracle") "Adr0081 must record differential oracle option")
      true)))

(df TestForeignRuleSSOTConsistency [] -> Bool
  :d "Verifies rules.asn enforces foreign dependency boundaries and no external runtime requirements"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src ":id foreign") "rules.asn must specify foreign rule")
      (assert (string-contains? r-src "no new ecosystem dependency beyond those boundaries") "rules.asn must restrict ecosystem dependencies")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46006 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRacketReferencePolicyContract) "TestRacketReferencePolicyContract must pass")
    (assert (TestRacketDifferentialOracleContract) "TestRacketDifferentialOracleContract must pass")
    (assert (TestAdr0081RacketReferenceDecision) "TestAdr0081RacketReferenceDecision must pass")
    (assert (TestForeignRuleSSOTConsistency) "TestForeignRuleSSOTConsistency must pass")
    true))
