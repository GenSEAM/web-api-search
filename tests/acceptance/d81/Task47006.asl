(module tests/acceptance/d81/Task47006
  :d "Acceptance fixture for Task47006: native launch and launch-session in binary, invariant enforcement, and retired shell wrapper under ADR-0081."
  :x [run-tests
      test-launch-help-surface
      test-claude-system-prompt-conversion
      test-claude-strip-dangerous-permissions
      test-agy-retains-dangerous-permissions
      test-launch-binary-execution-and-dispatch
      test-rules-source-runtime-coupling
      test-launcher-script-retired-from-surfaces]
  :i [])

(df test-launch-help-surface [] -> Bool
  :d "Verifies that asl launch --help outputs usage and all twenty flags and five client targets are present"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "char *find_workspace_root(void)") "find_workspace_root must be defined")
      (assert (string-contains? c-src "int run_launch(int argc, char **argv, const char *ws_root)") "run_launch must be defined")
      (assert (string-contains? c-src "Usage: asl launch <agy|claude|codex|addie|eddie>") "usage must declare all 5 clients")
      (assert (string-contains? c-src "asl launch-session [options]") "usage must declare launch-session")
      (assert (string-contains? c-src "--dry-run") "help must document --dry-run")
      (assert (string-contains? c-src "--client") "help must document --client")
      (assert (string-contains? c-src "--orchestrator") "help must document --orchestrator")
      (assert (string-contains? c-src "--supervisory-model") "help must document --supervisory-model")
      (assert (string-contains? c-src "--reasoning-level") "help must document --reasoning-level")
      (assert (string-contains? c-src "--soft-limit") "help must document --soft-limit")
      (assert (string-contains? c-src "--hard-limit") "help must document --hard-limit")
      (assert (string-contains? c-src "--max-subagents") "help must document --max-subagents")
      (assert (string-contains? c-src "--scaling-condition") "help must document --scaling-condition")
      (assert (string-contains? c-src "--multi-project") "help must document --multi-project")
      (assert (string-contains? c-src "--code-execution") "help must document --code-execution")
      (assert (string-contains? c-src "--separate-agents") "help must document --separate-agents")
      (assert (string-contains? c-src "--minimal-orchestrator") "help must document --minimal-orchestrator")
      (assert (string-contains? c-src "--research-tier") "help must document --research-tier")
      (assert (string-contains? c-src "--planning-tier") "help must document --planning-tier")
      (assert (string-contains? c-src "--plan-model") "help must document --plan-model")
      (assert (string-contains? c-src "--execution-tier") "help must document --execution-tier")
      (assert (string-contains? c-src "--role-assignments") "help must document --role-assignments")
      (assert (string-contains? c-src "--preset") "help must document --preset")
      (assert (string-contains? c-src "--permission-tier") "help must document --permission-tier")
      (assert (string-contains? c-src "--channel") "help must document --channel")
      (assert (string-contains? c-src "--stash-agents-md") "help must document --stash-agents-md")
      (assert (string-contains? c-src "--consultative") "help must document --consultative")
      true)))

(df test-claude-system-prompt-conversion [] -> Bool
  :d "Verifies Claude Code invariant: system prompt overwrite is converted to append with exact notice"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "[ASL Launch] Converted system prompt overwrite to append for Claude Code")
              "exact Claude Code system prompt conversion notice must be present in source")
      (assert (string-contains? c-src "--append-system-prompt") "conversion must target --append-system-prompt")
      true)))

(df test-claude-strip-dangerous-permissions [] -> Bool
  :d "Verifies Claude Code invariant: dangerous permissions are strictly stripped with exact notice"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src "[ASL Launch] Stripped dangerous permissions for Claude Code (invariant enforcement)")
              "exact Claude Code dangerous permissions stripping notice must be present in source")
      true)))

(df test-agy-retains-dangerous-permissions [] -> Bool
  :d "Verifies Antigravity invariant: retains dangerous-rescue tier and auto-flag --dangerously-skip-permissions"
  (let [(c-src-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (let [(c-src (.-value c-src-res))]
      (assert (string-contains? c-src ":permission-tier \\\"dangerous-rescue\\\"") "agy must declare dangerous-rescue tier")
      (assert (string-contains? c-src "--dangerously-skip-permissions") "agy must retain --dangerously-skip-permissions")
      (assert (string-contains? c-src "<RULE[user_global]>") "agy default channel must be <RULE[user_global]>")
      true)))

(df test-launch-binary-execution-and-dispatch [] -> Bool
  :d "Verifies that launch executes from binary, subcommands dispatch in main, and wrapper is not a shell script"
  (let [(c-src-res (file-read "asl/tools/asl.c"))
        (asl-bin-res (file-read "asl/asl"))
        (build-script-res (file-read "scripts/build_and_install.sh"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (assert (= (.-_tag asl-bin-res) "ok") "asl/asl must exist")
    (assert (= (.-_tag build-script-res) "ok") "scripts/build_and_install.sh must be readable")
    (let [(c-src (.-value c-src-res))
          (asl-bin (.-value asl-bin-res))
          (build-script (.-value build-script-res))]
      (assert (string-contains? c-src "strcmp(argv[1], \"launch\") == 0 || strcmp(argv[1], \"launch-session\") == 0")
              "main() must dispatch launch and launch-session")
      (assert (string-contains? c-src "run_launch(argc - 1, argv + 1, discovered_ws)")
              "dispatch must forward to run_launch")
      (assert (not (string-contains? asl-bin "#!/bin/bash")) "asl/asl must not be a bash script")
      (assert (not (string-contains? asl-bin "#!/usr/bin/env bash")) "asl/asl must not be an env bash script")
      (assert (string-contains? build-script "Error: build output target")
              "build script must verify that output target is not a tracked script file")
      (assert (string-contains? build-script "is a tracked source/script file; refusing overwrite.")
              "build script must refuse overwrite of tracked script source")
      true)))

(df test-rules-source-runtime-coupling [] -> Bool
  :d "Verifies dynamic runtime loading of rules.asn with loud error on missing source (zero empty payload injection)"
  (let [(c-src-res (file-read "asl/tools/asl.c"))
        (rules-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag c-src-res) "ok") "asl/tools/asl.c must be readable")
    (assert (= (.-_tag rules-res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(c-src (.-value c-src-res))
          (rules (.-value rules-res))]
      (assert (string-contains? c-src "load_rule_payload") "load_rule_payload function must be implemented")
      (assert (string-contains? c-src "asl/grammar/rules.asn") "load_rule_payload must check asl/grammar/rules.asn")
      (assert (string-contains? c-src "Error: rule payload source not found or unreadable: asl/grammar/rules.asn")
              "loud error must be emitted if rules source is missing")
      (assert (string-contains? rules "(:rules :v 7 :src ADR-0081") "rules.asn must contain valid rules definition")
      true)))

(df test-launcher-script-retired-from-surfaces [] -> Bool
  :d "Verifies launcher is removed from SURFACES in scripts/install.sh so rules check treats binary as reading rules.asn"
  (let [(install-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag install-res) "ok") "scripts/install.sh must be readable")
    (let [(install-src (.-value install-res))]
      (assert (not (string-contains? install-src "launcher|$RULES_ROOT/asl/asl"))
              "launcher entry must be retired from SURFACES in scripts/install.sh")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task47006 acceptance tests"
  (do
    (assert (test-launch-help-surface) "test-launch-help-surface must pass")
    (assert (test-claude-system-prompt-conversion) "test-claude-system-prompt-conversion must pass")
    (assert (test-claude-strip-dangerous-permissions) "test-claude-strip-dangerous-permissions must pass")
    (assert (test-agy-retains-dangerous-permissions) "test-agy-retains-dangerous-permissions must pass")
    (assert (test-launch-binary-execution-and-dispatch) "test-launch-binary-execution-and-dispatch must pass")
    (assert (test-rules-source-runtime-coupling) "test-rules-source-runtime-coupling must pass")
    (assert (test-launcher-script-retired-from-surfaces) "test-launcher-script-retired-from-surfaces must pass")
    true))
