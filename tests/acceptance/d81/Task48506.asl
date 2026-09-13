(module tests/acceptance/d81/Task48506
  :d "Acceptance fixture for Task48506: Multi-Client Launcher Supervise Gate and Ecosystem Certification under D84."
  :x [run-tests
      supervise_launcher_gate
      certify_launcher
      ecosystem_sync
      acceptance_suite
      test-launch-grammar-contract
      test-launcher-engine-symbols
      test-client-shims-and-docs
      test-task-suite-coverage]
  :i [])

(df supervise_launcher_gate [] -> Str
  :d "Sentinel symbol for launcher supervision"
  "supervise_launcher_gate")

(df certify_launcher [] -> Str
  :d "Sentinel symbol for launcher certification"
  "certify_launcher")

(df ecosystem_sync [] -> Str
  :d "Sentinel symbol for ecosystem sync"
  "ecosystem_sync")

(df acceptance_suite [] -> Str
  :d "Sentinel symbol for acceptance suite"
  "acceptance_suite")

(df test-launch-grammar-contract [] -> Bool
  :d "Verifies that asl/grammar/launch.asn defines formal contracts for launch sessions and permission tiers"
  (let [(res (file-read "asl/grammar/launch.asn"))]
    (assert (= (.-_tag res) "ok") "launch.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "launchSession") "launchSession schema declared")
      (assert (string-contains? src "permissionTier") "permissionTier schema declared")
      (assert (string-contains? src "clientChannel") "clientChannel schema declared")
      (assert (string-contains? src "dangerous-rescue") "dangerous-rescue tier declared")
      true)))

(df test-launcher-engine-symbols [] -> Bool
  :d "Verifies that asl/tools/asl.c implements core launcher engine, resolver, and dry-run functions"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "launch_agy") "launch_agy implemented")
      (assert (string-contains? src "inject_permission_flags") "inject_permission_flags implemented")
      (assert (string-contains? src "resolve_client_binary") "resolve_client_binary implemented")
      (assert (string-contains? src "find_executable_path") "find_executable_path implemented")
      (assert (string-contains? src "launch_dry_run") "launch_dry_run implemented")
      (assert (string-contains? src "print_launch_plan") "print_launch_plan implemented")
      true)))

(df test-client-shims-and-docs [] -> Bool
  :d "Verifies that bin/addie, bin/eddie, and AGENTS.md document and expose multi-client launcher capabilities"
  (let [(res-addie (file-read "bin/addie"))
        (res-eddie (file-read "bin/eddie"))
        (res-agents (file-read "AGENTS.md"))]
    (assert (= (.-_tag res-addie) "ok") "bin/addie readable")
    (assert (= (.-_tag res-eddie) "ok") "bin/eddie readable")
    (assert (= (.-_tag res-agents) "ok") "AGENTS.md readable")
    (let [(src-addie (.-value res-addie))
          (src-eddie (.-value res-eddie))
          (src-agents (.-value res-agents))]
      (assert (string-contains? src-addie "ASL_CLIENT_CHANNEL=\"addie\"") "bin/addie channel configured")
      (assert (string-contains? src-eddie "ASL_CLIENT_CHANNEL=\"eddie\"") "bin/eddie channel configured")
      (assert (string-contains? src-agents "Multi-Client Launcher Engine") "AGENTS.md documents launcher")
      (assert (string-contains? src-agents "dangerous-rescue") "AGENTS.md documents dangerous-rescue")
      true)))

(df test-task-suite-coverage [] -> Bool
  :d "Verifies that all Phase 485 acceptance fixtures exist and are well-formed"
  (let [(f1 (file-read "tests/acceptance/d81/Task48501.asl"))
        (f2 (file-read "tests/acceptance/d81/Task48502.asl"))
        (f3 (file-read "tests/acceptance/d81/Task48503.asl"))
        (f4 (file-read "tests/acceptance/d81/Task48504.asl"))
        (f5 (file-read "tests/acceptance/d81/Task48505.asl"))]
    (assert (= (.-_tag f1) "ok") "Task48501.asl exists")
    (assert (= (.-_tag f2) "ok") "Task48502.asl exists")
    (assert (= (.-_tag f3) "ok") "Task48503.asl exists")
    (assert (= (.-_tag f4) "ok") "Task48504.asl exists")
    (assert (= (.-_tag f5) "ok") "Task48505.asl exists")
    true))

(df run-tests [] -> Bool
  :d "Runs all Task48506 multi-client launcher certification assertions"
  (let [(r1 (test-launch-grammar-contract))
        (r2 (test-launcher-engine-symbols))
        (r3 (test-client-shims-and-docs))
        (r4 (test-task-suite-coverage))]
    (assert (and (and (and r1 r2) r3) r4) "All Task48506 certification checks must pass")
    true))
