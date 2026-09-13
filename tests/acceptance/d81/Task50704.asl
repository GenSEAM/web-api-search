(module tests/acceptance/d81/Task50704
  :d "Acceptance fixture for Task 50704: Pure ASL Sovereign Git VFS Reader (vfs_git.asl)"
  :x [testGitVfsDynamicExecution
      testGitVfsInvariants
      testGitVfsDualPolarityRefutations
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/vfs_git :a vfs)])

(df testGitVfsDynamicExecution [] -> Bool
  :d "Dynamically runs the vfs_git_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/vfs_git_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "vfs_git_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "vfs_git_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "vfs_git_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "vfs_git_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "vfs_git_test must not fail assertions")
    true))

(df testGitVfsInvariants [] -> Bool
  :d "Directly verifies Git VFS reading invariants against active repository"
  (let [(headRes (vfs/gitReadHead ""))
        (branchRes (vfs/gitCurrentBranch ""))
        (commitRes (vfs/gitHeadCommit ""))]
    (assert (= (.-_tag headRes) "ok") "gitReadHead must succeed on active repo")
    (mt headRes
      ((ok headText)
       (do
         (assert (string-starts-with? headText "ref: refs/heads/") "HEAD must reference a heads ref")
         (refute (string-empty? headText) "HEAD must not be empty")
         true))
      ((err _) false))
    (assert (= (.-_tag branchRes) "ok") "gitCurrentBranch must succeed")
    (mt branchRes
      ((ok branch)
       (do
         (assert (> (string-length branch) 0) "Branch name must not be empty")
         (refute (string-empty? branch) "Branch must have length > 0")
         true))
      ((err _) false))
    (assert (= (.-_tag commitRes) "ok") "gitHeadCommit must succeed")
    (mt commitRes
      ((ok sha)
       (do
         (assert (= (string-length sha) 40) "Commit SHA must be exactly 40 characters")
         (refute (!= (string-length sha) 40) "Commit SHA must not deviate from 40 chars")
         true))
      ((err _) false))))

(df testGitVfsDualPolarityRefutations [] -> Bool
  :d "Verifies dual-polarity refutations under D77"
  (let [(missingHead (vfs/gitReadHead "/non_existent_repo_dir_12345"))
        (missingBranch (vfs/gitCurrentBranch "/non_existent_repo_dir_12345"))
        (missingCommit (vfs/gitHeadCommit "/non_existent_repo_dir_12345"))]
    (assert (= (.-_tag missingHead) "err") "Missing repo HEAD must return err")
    (refute (= (.-_tag missingHead) "ok") "Missing repo HEAD must not return ok")
    (assert (= (.-_tag missingBranch) "err") "Missing repo branch must return err")
    (refute (= (.-_tag missingBranch) "ok") "Missing repo branch must not return ok")
    (assert (= (.-_tag missingCommit) "err") "Missing repo commit must return err")
    (refute (= (.-_tag missingCommit) "ok") "Missing repo commit must not return ok")
    (let [(commitRes (vfs/gitHeadCommit ""))]
      (mt commitRes
        ((ok sha)
         (do
           (refute (string-empty? sha) "HEAD commit SHA must not be empty string")
           (refute (< (string-length sha) 40) "Commit SHA must not be truncated")
           true))
        ((err _) false)))))

(df RunTests [] -> Bool
  :d "Executes all Task 50704 acceptance tests"
  (do
    (assert (testGitVfsDynamicExecution) "testGitVfsDynamicExecution must pass")
    (assert (testGitVfsInvariants) "testGitVfsInvariants must pass")
    (assert (testGitVfsDualPolarityRefutations) "testGitVfsDualPolarityRefutations must pass")
    true))
