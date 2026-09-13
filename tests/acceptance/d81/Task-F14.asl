(module tests/acceptance/d81/Task-F14
  :d "Acceptance fixture for Task-F14: Connect Agent Dispatcher to Genuine Engine Tools under ADR-0081."
  :x [RunTests
      TestDispatchAstPatchGenuine
      TestDispatchDepsResolveGenuine
      TestDispatchKnowledgeLoadGenuineVmm
      TestDispatchKnowledgeOffloadGenuineVmm
      TestTaskF14GroundedInPhaseFINSEL]
  :i [(asl-agent/dispatch :a disp) (policy :a pol)])

(df TestDispatchAstPatchGenuine [] -> Bool
  :d "Verifies ast-patch executes genuine patching rather than returning hardcoded with replacement"
  (let [(r (disp/dispatch-canonical-tool "ast-patch" "agent/manifest.asn" "(module test)" (pol/level-auto)))]
    (assert (.-success r) "ast-patch must succeed on valid target")
    (assert (not (string-contains? (.-payload r) "with replacement"))
            "ast-patch must not return hardcoded with replacement mock")
    true))

(df TestDispatchDepsResolveGenuine [] -> Bool
  :d "Verifies deps-resolve inspects genuine module dependencies rather than returning mock"
  (let [(r (disp/dispatch-canonical-tool "deps-resolve" "agent/src/dispatch.asl" "" (pol/level-auto)))]
    (assert (.-success r) "deps-resolve must succeed")
    (assert (not (string-contains? (.-payload r) "Resolved signature for"))
            "deps-resolve must not return hardcoded signature mock")
    (assert (string-contains? (.-payload r) "dependencies")
            "deps-resolve must report grounded dependency analysis")
    true))

(df TestDispatchKnowledgeLoadGenuineVmm [] -> Bool
  :d "Verifies knowledge-load executes VMM memory hydration rather than returning mock"
  (let [(r (disp/dispatch-canonical-tool "knowledge-load" "zod@3" "export class Zod" (pol/level-auto)))]
    (assert (.-success r) "knowledge-load must succeed")
    (assert (not (string-contains? (.-payload r) "Loaded JIT knowledge into slot-pinned for"))
            "knowledge-load must not return hardcoded mock string")
    (assert (string-contains? (.-payload r) "Hydrated")
            "knowledge-load must return grounded VMM hydration receipt")
    true))

(df TestDispatchKnowledgeOffloadGenuineVmm [] -> Bool
  :d "Verifies knowledge-offload executes VMM eviction and receipt minting rather than returning mock"
  (let [(r (disp/dispatch-canonical-tool "knowledge-offload" "zod@3" "anchor-hash-123" (pol/level-auto)))]
    (assert (.-success r) "knowledge-offload must succeed")
    (assert (not (string-contains? (.-payload r) "Offloaded knowledge and minted receipt for"))
            "knowledge-offload must not return hardcoded mock string")
    (assert (string-contains? (.-payload r) ":receipt")
            "knowledge-offload must return rendered VMM prompt containing minted receipt")
    true))

(df TestTaskF14GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F14 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F14\"") "Must declare Task-F14")
      (assert (string-contains? f-src "agent/src/dispatch.asl") "Must own agent/src/dispatch.asl")
      (assert (string-contains? f-src "dispatch-canonical-tool") "Must target symbol dispatch-canonical-tool")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F14 acceptance checks"
  (do
    (assert (TestDispatchAstPatchGenuine) "TestDispatchAstPatchGenuine must pass")
    (assert (TestDispatchDepsResolveGenuine) "TestDispatchDepsResolveGenuine must pass")
    (assert (TestDispatchKnowledgeLoadGenuineVmm) "TestDispatchKnowledgeLoadGenuineVmm must pass")
    (assert (TestDispatchKnowledgeOffloadGenuineVmm) "TestDispatchKnowledgeOffloadGenuineVmm must pass")
    (assert (TestTaskF14GroundedInPhaseFINSEL) "TestTaskF14GroundedInPhaseFINSEL must pass")
    true))
