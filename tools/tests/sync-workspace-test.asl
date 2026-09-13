(module asl-tools-tests/sync-workspace-test
  :d "Unit tests for pure ASL workspace synchronizer"
  :x [test-make-repo-sync-status
      test-audit-workspace-all-clean
      test-audit-workspace-dirty
      test-format-workspace-report
      test-inspect-submodule-real-fs
      test-inspect-submodule-missing
      run-tests]
  :i [(asl-tools/sync-workspace :a sw)])

(df test-make-repo-sync-status [] -> Bool
  (let [(st (sw/make-repo-sync-status "asl" true "main" true))]
    (assert (== (.-repo-name st) "asl") "repo-name must equal asl")
    (assert (.-is-clean st) "repo must be clean")
    (assert (== (.-branch st) "main") "branch must equal main")
    (assert (.-exists st) "repo must exist")
    true))

(df test-audit-workspace-all-clean [] -> Bool
  (let [(st1 (sw/make-repo-sync-status "asl" true "main" true))
        (st2 (sw/make-repo-sync-status "harness" true "main" true))
        (report (sw/audit-workspace-repos (list st1 st2)))]
    (assert (== (.-total-repos report) 2) "total-repos must equal 2")
    (assert (== (.-clean-repos report) 2) "clean-repos must equal 2")
    (assert (.-is-all-clean report) "is-all-clean must be true")
    true))

(df test-audit-workspace-dirty [] -> Bool
  (let [(st1 (sw/make-repo-sync-status "asl" true "main" true))
        (st2 (sw/make-repo-sync-status "harness" false "main" true))
        (report (sw/audit-workspace-repos (list st1 st2)))]
    (assert (== (.-total-repos report) 2) "total-repos must equal 2")
    (assert (== (.-clean-repos report) 1) "clean-repos must equal 1")
    (assert (not (.-is-all-clean report)) "is-all-clean must be false")
    true))

(df test-format-workspace-report [] -> Bool
  (let [(st1 (sw/make-repo-sync-status "asl" true "main" true))
        (report (sw/audit-workspace-repos (list st1)))
        (text (sw/format-workspace-report report))]
    (assert (string-contains? text "Multi-Repo Workspace Synchronizer") "Report must contain title")
    (assert (string-contains? text "Clean: 1/1") "Report must contain Clean: 1/1")
    (assert (string-contains? text "ALL REPOSITORIES CLEAN") "Report must contain ALL REPOSITORIES CLEAN")
    true))

(df test-inspect-submodule-real-fs [] -> Bool
  (let [(st (sw/inspect-submodule "asl"))]
    (assert (.-exists st) "asl must exist")
    (assert (.-is-clean st) "asl must be clean")
    (assert (string-equals? (.-branch st) "main") "asl branch must be main")
    true))

(df test-inspect-submodule-missing [] -> Bool
  (let [(st (sw/inspect-submodule "nonexistent-missing-submodule"))]
    (assert (not (.-exists st)) "Missing module must not exist")
    (assert (not (.-is-clean st)) "Missing module must not be clean")
    true))

(df run-tests [] -> Bool
  (do
    (assert (test-make-repo-sync-status) "test-make-repo-sync-status must pass")
    (assert (test-audit-workspace-all-clean) "test-audit-workspace-all-clean must pass")
    (assert (test-audit-workspace-dirty) "test-audit-workspace-dirty must pass")
    (assert (test-format-workspace-report) "test-format-workspace-report must pass")
    (assert (test-inspect-submodule-real-fs) "test-inspect-submodule-real-fs must pass")
    (assert (test-inspect-submodule-missing) "test-inspect-submodule-missing must pass")
    true))
