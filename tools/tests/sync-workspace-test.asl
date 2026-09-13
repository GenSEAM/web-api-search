(module aslToolsTests/syncWorkspaceTest
  :d "Unit tests for pure ASL workspace synchronizer"
  :x [testMakeRepoSyncStatus
      testAuditWorkspaceAllClean
      testAuditWorkspaceDirty
      testFormatWorkspaceReport
      testInspectSubmoduleRealFs
      testInspectSubmoduleMissing
      runTests]
  :i [(aslTools/syncWorkspace :a sw)])

(df testMakeRepoSyncStatus [] -> Bool
  (let [(st (sw/makeRepoSyncStatus "asl" true "main" true))]
    (assert (== (.-repoName st) "asl") "repo-name must equal asl")
    (assert (.-isClean st) "repo must be clean")
    (assert (== (.-branch st) "main") "branch must equal main")
    (assert (.-exists st) "repo must exist")
    true))

(df testAuditWorkspaceAllClean [] -> Bool
  (let [(st1 (sw/makeRepoSyncStatus "asl" true "main" true))
        (st2 (sw/makeRepoSyncStatus "harness" true "main" true))
        (report (sw/auditWorkspaceRepos (list st1 st2)))]
    (assert (== (.-totalRepos report) 2) "total-repos must equal 2")
    (assert (== (.-cleanRepos report) 2) "clean-repos must equal 2")
    (assert (.-isAllClean report) "is-all-clean must be true")
    true))

(df testAuditWorkspaceDirty [] -> Bool
  (let [(st1 (sw/makeRepoSyncStatus "asl" true "main" true))
        (st2 (sw/makeRepoSyncStatus "harness" false "main" true))
        (report (sw/auditWorkspaceRepos (list st1 st2)))]
    (assert (== (.-totalRepos report) 2) "total-repos must equal 2")
    (assert (== (.-cleanRepos report) 1) "clean-repos must equal 1")
    (assert (not (.-isAllClean report)) "is-all-clean must be false")
    true))

(df testFormatWorkspaceReport [] -> Bool
  (let [(st1 (sw/makeRepoSyncStatus "asl" true "main" true))
        (report (sw/auditWorkspaceRepos (list st1)))
        (text (sw/formatWorkspaceReport report))]
    (assert (string-contains? text "Multi-Repo Workspace Synchronizer") "Report must contain title")
    (assert (string-contains? text "Clean: 1/1") "Report must contain Clean: 1/1")
    (assert (string-contains? text "ALL REPOSITORIES CLEAN") "Report must contain ALL REPOSITORIES CLEAN")
    true))

(df testInspectSubmoduleRealFs [] -> Bool
  (let [(st (sw/inspectSubmodule "asl"))]
    (assert (.-exists st) "asl must exist")
    (assert (.-isClean st) "asl must be clean")
    (assert (stringEquals? (.-branch st) "main") "asl branch must be main")
    true))

(df testInspectSubmoduleMissing [] -> Bool
  (let [(st (sw/inspectSubmodule "nonexistent-missing-submodule"))]
    (assert (not (.-exists st)) "Missing module must not exist")
    (assert (not (.-isClean st)) "Missing module must not be clean")
    true))

(df runTests [] -> Bool
  (do
    (assert (testMakeRepoSyncStatus) "test-make-repo-sync-status must pass")
    (assert (testAuditWorkspaceAllClean) "test-audit-workspace-all-clean must pass")
    (assert (testAuditWorkspaceDirty) "test-audit-workspace-dirty must pass")
    (assert (testFormatWorkspaceReport) "test-format-workspace-report must pass")
    (assert (testInspectSubmoduleRealFs) "test-inspect-submodule-real-fs must pass")
    (assert (testInspectSubmoduleMissing) "test-inspect-submodule-missing must pass")
    true))
