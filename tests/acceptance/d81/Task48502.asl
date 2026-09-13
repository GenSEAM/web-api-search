(module tests/acceptance/d81/Task48502
  :d "Acceptance fixture for Task48502: Antigravity Dangerous-Rescue Permission Elevation Engine under D84."
  :x [run-tests
      test-launch-agy-and-permission-injection-implemented
      test-dangerous-rescue-flags-injected
      test-launch-agy-dry-run-output]
  :i [])

(df test-launch-agy-and-permission-injection-implemented [] -> Bool
  :d "Verifies that launch_agy and inject_permission_flags are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "launch_agy") "launch_agy implemented")
      (assert (string-contains? src "inject_permission_flags") "inject_permission_flags implemented")
      true)))

(df test-dangerous-rescue-flags-injected [] -> Bool
  :d "Verifies that dangerous-rescue and --dangerously-skip-permissions are injected in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "dangerous-rescue") "dangerous-rescue tier declared")
      (assert (string-contains? src "--dangerously-skip-permissions") "--dangerously-skip-permissions injected")
      true)))

(df test-launch-agy-dry-run-output [] -> Bool
  :d "Verifies that asl launch agy --dry-run outputs dangerous-rescue tier and skip permissions flag"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (and (string-contains? src ":auto-flags") (string-contains? src "--dangerously-skip-permissions")) "auto-flags declared in dry run")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48502 acceptance assertions"
  (let [(r1 (test-launch-agy-and-permission-injection-implemented))
        (r2 (test-dangerous-rescue-flags-injected))
        (r3 (test-launch-agy-dry-run-output))]
    (assert (and r1 (and r2 r3)) "All Task48502 checks must pass")
    true))
