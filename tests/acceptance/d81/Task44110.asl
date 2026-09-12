(module tests/acceptance/d81/Task44110
  :d "Acceptance fixture for Task44110: Use justified domain profiles over common mechanical roles under ADR-0081."
  :x [RunTests
      TestJustifiedProfilesRegistry
      TestClientAgentProfilesConsistency
      TestAgentMatchAndProfileProjectionInInstall
      TestPartitionConcurrencyAndStepIntegrity]
  :i [])

(df TestJustifiedProfilesRegistry [] -> Bool
  :d "Verifies .asl/profiles.asn defines justified profiles with strict path and capability boundaries"
  (let [(p-res (file-read ".asl/profiles.asn"))]
    (assert (= (.-_tag p-res) "ok") ".asl/profiles.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":id \"scout\"") "Must define scout profile")
      (assert (string-contains? p-src ":id \"implementer\"") "Must define implementer profile")
      (assert (string-contains? p-src ":id \"grader\"") "Must define grader profile")
      (assert (string-contains? p-src ":id \"planner\"") "Must define planner profile")
      (assert (string-contains? p-src ":id \"auditor\"") "Must define auditor profile")
      (assert (string-contains? p-src "tests/acceptance/*") "Implementer must deny write to acceptance fixtures")
      (assert (string-contains? p-src "packages/*") "Grader must deny write to packages")
      (assert (string-contains? p-src ":hiddenEvaluationProtection true") "Must declare hiddenEvaluationProtection")
      true)))

(df TestClientAgentProfilesConsistency [] -> Bool
  :d "Verifies client agent profiles reflect strict authorization boundaries"
  (let [(i-res (file-read ".claude/agents/implementer.md"))
        (g-res (file-read ".claude/agents/grader.md"))
        (s-res (file-read ".claude/agents/scout.md"))
        (p-res (file-read ".claude/agents/planner.md"))
        (a-res (file-read ".claude/agents/auditor.md"))]
    (assert (= (.-_tag i-res) "ok") "implementer.md must exist")
    (assert (= (.-_tag g-res) "ok") "grader.md must exist")
    (assert (= (.-_tag s-res) "ok") "scout.md must exist")
    (assert (= (.-_tag p-res) "ok") "planner.md must exist")
    (assert (= (.-_tag a-res) "ok") "auditor.md must exist")
    (let [(i-src (.-value i-res))
          (g-src (.-value g-res))]
      (assert (string-contains? i-src "Cannot read or modify hidden acceptance fixtures") "Implementer must not touch hidden acceptance")
      (assert (string-contains? g-src "Cannot edit production source") "Grader must not edit production source")
      true)))

(df TestAgentMatchAndProfileProjectionInInstall [] -> Bool
  :d "Verifies install.sh defines agent_match and asl.c handles profile projection"
  (let [(i-res (file-read "scripts/install.sh"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(i-src (.-value i-res))
          (c-src (.-value c-res))]
      (assert (string-contains? i-src "agent_match()") "install.sh must define agent_match")
      (assert (string-contains? c-src "profiles") "asl.c must contain profiles handling")
      true)))

(df TestPartitionConcurrencyAndStepIntegrity [] -> Bool
  :d "Verifies partition concurrency and separation of duties in rules and contracts"
  (let [(r-res (file-read "asl/grammar/rules.asn"))
        (s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(r-src (.-value r-res))
          (s-src (.-value s-res))]
      (assert (string-contains? r-src ":rule :id grading") "rules.asn must enforce grading separation")
      (assert (string-contains? r-src "the writer never grades its own work") "Writer must never grade its own work")
      (assert (string-contains? r-src ":rule :id parallel") "rules.asn must define parallel rule")
      (assert (string-contains? r-src "one writer per owned partition") "Must enforce one writer per owned partition")
      (assert (string-contains? s-src "leaseIsolation") "session-contract must enforce leaseIsolation")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44110 acceptance tests"
  (do
    (assert (TestJustifiedProfilesRegistry) "TestJustifiedProfilesRegistry must pass")
    (assert (TestClientAgentProfilesConsistency) "TestClientAgentProfilesConsistency must pass")
    (assert (TestAgentMatchAndProfileProjectionInInstall) "TestAgentMatchAndProfileProjectionInInstall must pass")
    (assert (TestPartitionConcurrencyAndStepIntegrity) "TestPartitionConcurrencyAndStepIntegrity must pass")
    true))
