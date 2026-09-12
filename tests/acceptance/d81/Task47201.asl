(module tests/acceptance/d81/Task47201
  :d "Acceptance fixture for Task47201: no shell commands built from request input under ADR-0081."
  :x [RunTests
      TestGitCommitSafeInAslC
      TestNoShellInterpolationInCommit]
  :i [])

(df TestGitCommitSafeInAslC [] -> Bool
  :d "Verifies that asl/tools/asl.c uses argument vector or safe execution for git commit instead of system(cmd) with interpolated user message"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (or (string-contains? c-src "run_git_commit_safe") (string-contains? c-src "run_git_commit_argv"))
              "asl.c must implement safe argv-based git commit execution")
      true)))

(df TestNoShellInterpolationInCommit [] -> Bool
  :d "Verifies that asl/tools/asl.c does not format user msg into shell string for system()"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (not (string-contains? c-src "git -C \"%s\" commit -m \"%s\""))
              "asl.c must not format commit message directly into shell command string")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47201 supervisor acceptance tests"
  (do
    (assert (TestGitCommitSafeInAslC) "TestGitCommitSafeInAslC must pass")
    (assert (TestNoShellInterpolationInCommit) "TestNoShellInterpolationInCommit must pass")
    true))
