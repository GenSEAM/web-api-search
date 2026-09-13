(module tests/acceptance/d81/Task-F21
  :d "Acceptance fixture for Task-F21: Replace Faked Synchronization and Pre-Commit Status Checks under ADR-0081."
  :x [RunTests
      TestInspectSubmoduleRealFs
      TestInspectSubmoduleMissing
      TestVerifyRealFsNonFaked
      TestPreCommitCountDashedIdentifiers
      TestPreCommitEvaluateCommitDiffBlocked
      TestPreCommitEvaluateCommitDiffClean
      TestTaskF21GroundedInPhaseFINSEL]
  :i [(asl-tools/sync-workspace :a sw)
      (asl-tools/pre-commit :a pc)])

(df TestInspectSubmoduleRealFs [] -> Bool
  :d "Verifies inspect-submodule inspects genuine on-disk submodules for existence and HEAD branch"
  (let [(st-asl (sw/inspect-submodule "asl"))
        (st-intel (sw/inspect-submodule "intel"))]
    (assert (.-exists st-asl) "Submodule asl must exist on disk")
    (assert (.-is-clean st-asl) "Submodule asl must report clean")
    (assert (= (.-branch st-asl) "main") "Submodule asl branch must be main")
    (assert (.-exists st-intel) "Submodule intel must exist on disk")
    (assert (.-is-clean st-intel) "Submodule intel must report clean")
    (assert (= (.-branch st-intel) "main") "Submodule intel branch must be main")
    true))

(df TestInspectSubmoduleMissing [] -> Bool
  :d "Verifies inspect-submodule returns false exists and dirty status for missing repository"
  (let [(st-missing (sw/inspect-submodule "nonexistent-fake-submodule-xyz"))]
    (assert (not (.-exists st-missing)) "Missing submodule must not exist")
    (assert (not (.-is-clean st-missing)) "Missing submodule must not be marked clean")
    (assert (= (.-branch st-missing) "") "Missing submodule must have empty branch")
    true))

(df TestVerifyRealFsNonFaked [] -> Bool
  :d "Verifies verify-real-fs inspects real submodules from disk rather than hardcoding true"
  (let [(report (sw/inspect-workspace-all))]
    (assert (> (.-total-repos report) 10) "Workspace report must scan more than 10 repositories")
    (assert (> (.-clean-repos report) 10) "Workspace report must find clean existing repositories")
    (assert (not (list-empty? (.-statuses report))) "Workspace report statuses must not be empty")
    true))

(df TestPreCommitCountDashedIdentifiers [] -> Bool
  :d "Verifies count-dashed-identifiers detects kebab-case identifiers in added diff lines"
  (let [(bad-diff (str "--- a/src/core.asl\n"
                       "+++ b/src/core.asl\n"
                       "@@ -1,3 +1,5 @@\n"
                       "+(df calculate-user-score [(id Str)] -> I64\n"
                       "+  10)\n"))
        (good-diff (str "--- a/src/core.asl\n"
                        "+++ b/src/core.asl\n"
                        "@@ -1,3 +1,5 @@\n"
                        "+(df CalculateUserScore [(id Str)] -> I64\n"
                        "+  10)\n"))
        (bad-count (pc/count-dashed-identifiers bad-diff))
        (good-count (pc/count-dashed-identifiers good-diff))]
    (assert (= bad-count 1) "Bad diff with dashed function name must count 1 dashed identifier")
    (assert (= good-count 0) "Good diff with CamelCase must count 0 dashed identifiers")
    true))

(df TestPreCommitEvaluateCommitDiffBlocked [] -> Bool
  :d "Verifies evaluate-commit-diff blocks commits that introduce dashed identifiers under strict tokens"
  (let [(cfg (pc/PreCommitConfig :strictTokens true :checkConsistency true :maxComplexity 15))
        (bad-diff (str "--- a/src/core.asl\n"
                       "+++ b/src/core.asl\n"
                       "@@ -1,3 +1,5 @@\n"
                       "+(df bad-dashed-identifier [] -> Bool true)\n"))
        (res (pc/evaluate-commit-diff bad-diff cfg))]
    (assert (string-contains? res ":status :blocked") "Commit with dashed identifiers must be blocked")
    (assert (string-contains? res ":thresholds :failed") "Commit with dashed identifiers must fail thresholds")
    true))

(df TestPreCommitEvaluateCommitDiffClean [] -> Bool
  :d "Verifies evaluate-commit-diff allows clean commits adhering to token invariants"
  (let [(cfg (pc/PreCommitConfig :strictTokens true :checkConsistency true :maxComplexity 15))
        (clean-diff (str "--- a/src/core.asl\n"
                         "+++ b/src/core.asl\n"
                         "@@ -1,3 +1,5 @@\n"
                         "+(df CleanCommitFunction [] -> Bool true)\n"))
        (res (pc/evaluate-commit-diff clean-diff cfg))]
    (assert (string-contains? res ":status :clean") "Clean commit must be marked clean")
    (assert (string-contains? res ":thresholds :passed") "Clean commit must pass thresholds")
    true))

(df TestTaskF21GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F21 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F21\""))
             (has-title (string-contains? content ":title \"Replace Faked Synchronization and Pre-Commit Status Checks\""))]
         (assert has-id "Task-F21 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F21 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F21"
  (let [(t1 (TestInspectSubmoduleRealFs))
        (t2 (TestInspectSubmoduleMissing))
        (t3 (TestVerifyRealFsNonFaked))
        (t4 (TestPreCommitCountDashedIdentifiers))
        (t5 (TestPreCommitEvaluateCommitDiffBlocked))
        (t6 (TestPreCommitEvaluateCommitDiffClean))
        (t7 (TestTaskF21GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 (and t4 (and t5 (and t6 t7))))))))
