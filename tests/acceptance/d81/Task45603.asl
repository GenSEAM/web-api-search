(module tests/acceptance/d81/Task45603
  :d "Acceptance fixture for Task45603: Verdict for each of the 270 unreachable modules, subsystem dispositions, and dormant set exclusion under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSubsystemDispositionsAnsweredByEvidence
      TestDormantModulesRequireWakingCondition
      TestCorpusStatisticsExcludeDormantSet
      TestComponentRegistryDormancyAndDispositions
      TestManifestDormancyDispositions
      TestVerificationCasesContract
      TestTask45603GroundedInPhase456]
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

(df TestSubsystemDispositionsAnsweredByEvidence [] -> Bool
  :d "Verifies that subsystem dispositions for voice, agent, browser-plugin, and crawler are declared with evidence"
  (let [(b-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag b-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(b-src (.-value b-res))]
      (assert (string-contains? b-src ":subsystemDispositions") "dependency-boundaries.asn must declare :subsystemDispositions")
      (assert (string-contains? b-src ":id \"browser-plugin\"") "Must declare browser-plugin disposition")
      (assert (string-contains? b-src ":disposition :wired") "browser-plugin must be wired")
      (assert (string-contains? b-src ":id \"agent\"") "Must declare agent disposition")
      (assert (string-contains? b-src ":id \"voice\"") "Must declare voice disposition")
      (assert (string-contains? b-src ":id \"crawler\"") "Must declare crawler disposition")
      (assert (string-contains? b-src ":disposition :dormant") "voice and crawler must have dormant disposition")
      true)))

(df TestDormantModulesRequireWakingCondition [] -> Bool
  :d "Verifies that all dormant module declarations require an explicit non-empty waking condition"
  (let [(b-res (file-read "asl/grammar/dependency-boundaries.asn"))]
    (assert (= (.-_tag b-res) "ok") "dependency-boundaries.asn must exist and be readable")
    (let [(b-src (.-value b-res))]
      (assert (string-contains? b-src ":dormantModules") "dependency-boundaries.asn must declare :dormantModules")
      (assert (string-contains? b-src ":wakingCondition") "dependency-boundaries.asn must specify :wakingCondition")
      (assert (string-contains? b-src "asl/") "Must classify asl/ dormant group")
      (assert (string-contains? b-src "mem/") "Must classify mem/ dormant group")
      (assert (string-contains? b-src "agent/") "Must classify agent/ dormant group")
      (assert (string-contains? b-src "voice/") "Must classify voice/ dormant group")
      (assert (string-contains? b-src "agent-core/") "Must classify agent-core/ dormant group")
      (assert (string-contains? b-src "intel/") "Must classify intel/ dormant group")
      (assert (string-contains? b-src "pack/") "Must classify pack/ dormant group")
      (assert (string-contains? b-src "agent-bus/") "Must classify agent-bus/ dormant group")
      (assert (string-contains? b-src "browser-plugin/") "Must classify browser-plugin/ dormant group")
      (assert (string-contains? b-src "crawler/") "Must classify crawler/ dormant group")
      (assert (string-contains? b-src "editorial-matrix/") "Must classify editorial-matrix/ dormant group")
      true)))

(df TestCorpusStatisticsExcludeDormantSet [] -> Bool
  :d "Verifies that corpus statistics exclude the declared dormant set and explicitly say so"
  (let [(b-res (file-read "asl/grammar/dependency-boundaries.asn"))
        (u-res (file-read ".asl/mem/unreachable-modules.asn"))]
    (assert (= (.-_tag b-res) "ok") "dependency-boundaries.asn must exist")
    (assert (= (.-_tag u-res) "ok") "unreachable-modules.asn must exist and be readable")
    (let [(b-src (.-value b-res))
          (u-src (.-value u-res))]
      (assert (string-contains? b-src ":statExclusion true") "dependency-boundaries.asn must enforce :statExclusion true")
      (assert (string-contains? b-src ":totalDormantBaseline 270") "Must record 270 total dormant baseline")
      (assert (string-contains? u-src ":dormantSetExcluded true") "unreachable-modules.asn must declare :dormantSetExcluded true")
      (assert (string-contains? u-src ":baselineUnreachableModules 270") "unreachable-modules.asn must audit 270 baseline modules")
      (assert (string-contains? u-src "Corpus statistics exclude declared dormant modules") "unreachable-modules.asn must explain dormant exclusion")
      true)))

(df TestComponentRegistryDormancyAndDispositions [] -> Bool
  :d "Verifies that component registry records active agent, dormant voice, and dormant crawler components"
  (let [(c-res (file-read ".asl/mem/components.asn"))]
    (assert (= (.-_tag c-res) "ok") "components.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "comp-browser-plugin-relay") "components.asn must contain comp-browser-plugin-relay")
      (assert (string-contains? c-src "comp-agent-subsystem") "components.asn must contain comp-agent-subsystem")
      (assert (string-contains? c-src "comp-voice-subsystem") "components.asn must contain comp-voice-subsystem")
      (assert (string-contains? c-src "comp-crawler-subsystem") "components.asn must contain comp-crawler-subsystem")
      (assert (string-contains? c-src ":status :dormant") "components.asn must declare :status :dormant for dormant components")
      (assert (string-contains? c-src ":wakingCondition") "components.asn must specify :wakingCondition for dormant components")
      true)))

(df TestManifestDormancyDispositions [] -> Bool
  :d "Verifies package manifests reflect subsystem dispositions and waking conditions"
  (let [(v-res (file-read "voice/manifest.asn"))
        (c-res (file-read "crawler/manifest.asn"))
        (a-res (file-read "agent/manifest.asn"))
        (b-res (file-read "browser-plugin/manifest.asn"))]
    (assert (= (.-_tag v-res) "ok") "voice/manifest.asn must exist")
    (assert (= (.-_tag c-res) "ok") "crawler/manifest.asn must exist")
    (assert (= (.-_tag a-res) "ok") "agent/manifest.asn must exist")
    (assert (= (.-_tag b-res) "ok") "browser-plugin/manifest.asn must exist")
    (let [(v-src (.-value v-res))
          (c-src (.-value c-res))
          (a-src (.-value a-res))
          (b-src (.-value b-res))]
      (assert (string-contains? v-src ":status \"conceptual-schema\"") "voice manifest must declare conceptual-schema status")
      (assert (string-contains? v-src ":wakingCondition") "voice manifest must declare wakingCondition")
      (assert (string-contains? c-src ":disposition :dormant") "crawler manifest must declare dormant disposition")
      (assert (string-contains? c-src ":wakingCondition") "crawler manifest must declare wakingCondition")
      (assert (string-contains? a-src ":entry \"src/agent.asl\"") "agent manifest must declare active entry point")
      (assert (string-contains? b-src ":entry \"src/plugin.asl\"") "browser-plugin manifest must declare active entry point")
      true)))

(df TestVerificationCasesContract [] -> Bool
  :d "Verifies verification cases contract for Task45603 in phase task file"
  (let [(task-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag task-res) "ok") "Phase456 task collection must be readable")
    (let [(task-src (.-value task-res))]
      (assert (string-contains? task-src "A new module with no importer and no dormant declaration fails the check") "Must record verification case 1")
      (assert (string-contains? task-src "A dormant declaration without a waking condition fails") "Must record verification case 2")
      (assert (string-contains? task-src "Statistics computed over the corpus exclude the declared dormant set and say so") "Must record verification case 3")
      true)))

(df TestTask45603GroundedInPhase456 [] -> Bool
  :d "Verifies Task45603 is registered in Phase456 task collection with all mandatory D52 metadata"
  (let [(c-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag c-res) "ok") "Phase456DuplicationDeadCodeAndUnwiredEradication.asn must exist")
    (let [(src (.-value c-res))]
      (assert (string-contains? src ":id \"Task45603\"") "Must declare Task45603")
      (assert (string-contains? src ":gate \"sh tests/acceptance/d81/SuperviseGate.sh Task45603\"") "Must bind gate command")
      (assert (string-contains? src ":owns") "Must declare owned paths")
      (assert (string-contains? src "asl/grammar/dependency-boundaries.asn") "Must own dependency-boundaries.asn")
      (assert (string-contains? src ".asl/mem/components.asn") "Must own components.asn")
      (assert (string-contains? src "voice") "Must own voice")
      (assert (string-contains? src "agent") "Must own agent")
      (assert (string-contains? src "browser-plugin") "Must own browser-plugin")
      (assert (string-contains? src "crawler") "Must own crawler")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45603 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSubsystemDispositionsAnsweredByEvidence) "TestSubsystemDispositionsAnsweredByEvidence must pass")
    (assert (TestDormantModulesRequireWakingCondition) "TestDormantModulesRequireWakingCondition must pass")
    (assert (TestCorpusStatisticsExcludeDormantSet) "TestCorpusStatisticsExcludeDormantSet must pass")
    (assert (TestComponentRegistryDormancyAndDispositions) "TestComponentRegistryDormancyAndDispositions must pass")
    (assert (TestManifestDormancyDispositions) "TestManifestDormancyDispositions must pass")
    (assert (TestVerificationCasesContract) "TestVerificationCasesContract must pass")
    (assert (TestTask45603GroundedInPhase456) "TestTask45603GroundedInPhase456 must pass")
    true))
