(module tests/acceptance/d81/Task46904
  :d "Acceptance fixture for Task46904: branching causal message DAG and semantic intent merge connected to VFS writes."
  :x [RunTests
      TestMvccExportSyntax
      TestIntentConflictDeclared
      TestVfsBranchCausalLinkage
      TestVfsBranchIntentMergeConnected]
  :i [])

(df TestMvccExportSyntax [] -> Bool
  :d "Verifies that agent-bus/src/mvcc_bus.asl uses canonical :x export keyword instead of :exports"
  (let [(res (file-read "agent-bus/src/mvcc_bus.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/mvcc_bus.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src ":exports"))
              "mvcc_bus.asl must not use deprecated :exports keyword")
      (assert (string-contains? src ":x")
              "mvcc_bus.asl must use canonical :x export keyword")
      true)))

(df TestIntentConflictDeclared [] -> Bool
  :d "Verifies that mvcc_bus.asl exports IntentConflict and MergedIntent structures"
  (let [(res (file-read "agent-bus/src/mvcc_bus.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/mvcc_bus.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "IntentConflict") "mvcc_bus.asl must declare IntentConflict")
      (assert (string-contains? src "MergedIntent") "mvcc_bus.asl must declare MergedIntent")
      (assert (string-contains? src "mvcc-bus-merge-intents") "mvcc_bus.asl must define mvcc-bus-merge-intents")
      true)))

(df TestVfsBranchCausalLinkage [] -> Bool
  :d "Verifies that mem/src/vfs_fork.asl VFSBranch links speculative branch writes to causal intent messages"
  (let [(res (file-read "mem/src/vfs_fork.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/vfs_fork.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "causal-id") (string-contains? src "intent-id") (string-contains? src "causal-message"))
              "vfs_fork.asl VFSBranch must declare causal-id or intent linkage")
      true)))

(df TestVfsBranchIntentMergeConnected [] -> Bool
  :d "Verifies that vfs merging connects AST structural integration to causal intent resolution"
  (let [(res (file-read "mem/src/vfs_merge.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/vfs_merge.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "causal") (string-contains? src "intent") (string-contains? src "IntentConflict"))
              "vfs_merge.asl must integrate causal intent or intent conflict handling")
      true)))

(df RunTests [] -> Bool
  (and (TestMvccExportSyntax)
       (TestIntentConflictDeclared)
       (TestVfsBranchCausalLinkage)
       (TestVfsBranchIntentMergeConnected)))
