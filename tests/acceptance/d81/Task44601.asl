(module tests/acceptance/d81/Task44601
  :d "Acceptance fixture for Task44601: Reclassify relay surfaces from removal candidates to runtime targets under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTask43807AmendedWithRetainedRuntimeTargets
      TestComponentRegistryRetainedEntryPoints
      TestComponentRegistryAndTaskListDispositionAgreement
      TestTask44601GroundedInPhase446]
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

(df TestTask43807AmendedWithRetainedRuntimeTargets [] -> Bool
  :d "Verifies Task43807 explicitly retains relay surfaces as runtime targets with entry points"
  (let [(t-res (file-read ".asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn"))]
    (assert (= (.-_tag t-res) "ok") "Phase438 tasks file must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "agent-bus") "Task43807 must retain agent-bus")
      (assert (string-contains? t-src "browser-plugin") "Task43807 must retain browser-plugin")
      (assert (string-contains? t-src "asl/packages/asl-bridge") "Task43807 must retain asl-bridge")
      (assert (string-contains? t-src "asl-gateway") "Task43807 must retain asl-gateway")
      (assert (string-contains? t-src "vdom") "Task43807 must retain vdom")
      (assert (string-contains? t-src "runtime targets") "Task43807 must designate packages as runtime targets")
      true)))

(df TestComponentRegistryRetainedEntryPoints [] -> Bool
  :d "Verifies component registry declares entry points for every retained relay surface"
  (let [(c-res (file-read ".asl/mem/components.asn"))]
    (assert (= (.-_tag c-res) "ok") "components.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "comp-agent-bus-relay") "Must register comp-agent-bus-relay")
      (assert (string-contains? c-src "comp-browser-plugin-relay") "Must register comp-browser-plugin-relay")
      (assert (string-contains? c-src "comp-asl-bridge-relay") "Must register comp-asl-bridge-relay")
      (assert (string-contains? c-src "comp-asl-gateway-relay") "Must register comp-asl-gateway-relay")
      (assert (string-contains? c-src "comp-vdom-relay") "Must register comp-vdom-relay")
      (assert (string-contains? c-src "agent-bus/src") "agent-bus must have declared entry point")
      (assert (string-contains? c-src "browser-plugin/src") "browser-plugin must have declared entry point")
      true)))

(df TestComponentRegistryAndTaskListDispositionAgreement [] -> Bool
  :d "Verifies component registry and task list agree on disposition of all thirteen packages"
  (let [(c-res (file-read ".asl/mem/components.asn"))
        (p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag c-res) "ok") "components.asn must exist")
    (assert (= (.-_tag p-res) "ok") "Phase446 tasks file must exist")
    (let [(c-src (.-value c-res))
          (p-src (.-value p-res))]
      (assert (string-contains? p-src "Reclassify the relay surfaces from removal candidates to runtime targets") "Phase 446 must state Task44601 title")
      (assert (string-contains? p-src ":lane \"topology\"") "Phase 446 must specify topology lane")
      (assert (string-contains? c-src ":status :active") "Retained components must have active status")
      true)))

(df TestTask44601GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44601"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Task44601") "Phase 446 must define Task44601")
      (assert (string-contains? p-src "run_gate_1") "Phase 446 must target run_gate_1")
      (assert (string-contains? p-src ".asl/mem/components.asn") "Phase 446 must own components.asn")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44601 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTask43807AmendedWithRetainedRuntimeTargets) "TestTask43807AmendedWithRetainedRuntimeTargets must pass")
    (assert (TestComponentRegistryRetainedEntryPoints) "TestComponentRegistryRetainedEntryPoints must pass")
    (assert (TestComponentRegistryAndTaskListDispositionAgreement) "TestComponentRegistryAndTaskListDispositionAgreement must pass")
    (assert (TestTask44601GroundedInPhase446) "TestTask44601GroundedInPhase446 must pass")
    true))
