(module tests/acceptance/d81/Task-F13
  :d "Acceptance fixture for Task-F13: Implement CLI Entrypoint in Agent Package under ADR-0081."
  :x [RunTests
      TestAgentCliDeclaresMain
      TestAgentBinGsaExecutesEval
      TestAgentCliHelpContainsUsage
      TestTaskF13GroundedInPhaseFINSEL]
  :i [(asl-agent/cli :a cli)])

(df TestAgentCliDeclaresMain [] -> Bool
  :d "Verifies that agent/src/cli.asl declares and exports executable main function"
  (let [(c-res (file-read "agent/src/cli.asl"))]
    (assert (= (.-_tag c-res) "ok") "agent/src/cli.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "main") "agent/src/cli.asl export list must include main")
      (assert (string-contains? c-src "(df ! main") "agent/src/cli.asl must define executable main function")
      true)))

(df TestAgentBinGsaExecutesEval [] -> Bool
  :d "Verifies that agent/bin/gsa executes ASL evaluator with CLI entrypoint"
  (let [(b-res (file-read "agent/bin/gsa"))]
    (assert (= (.-_tag b-res) "ok") "agent/bin/gsa must exist and be readable")
    (let [(b-src (.-value b-res))]
      (assert (string-contains? b-src "eval") "agent/bin/gsa must route through asl eval")
      true)))

(df TestAgentCliHelpContainsUsage [] -> Bool
  :d "Verifies that CLI usage help text contains standard usage header"
  (let [(help (cli/format-cli-help))]
    (assert (string-contains? help "Usage: gsa [options]") "Help text must specify Usage: gsa [options]")
    (assert (string-contains? help "--autonomy") "Help text must document --autonomy flag")
    (assert (string-contains? help "--model") "Help text must document --model flag")
    (assert (string-contains? help "--prompt") "Help text must document --prompt flag")
    true))

(df TestTaskF13GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F13 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F13\"") "Must declare Task-F13")
      (assert (string-contains? f-src "agent/src/cli.asl") "Must own agent/src/cli.asl")
      (assert (string-contains? f-src "agent/bin/gsa") "Must own agent/bin/gsa")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F13 acceptance checks"
  (do
    (assert (TestAgentCliDeclaresMain) "TestAgentCliDeclaresMain must pass")
    (assert (TestAgentBinGsaExecutesEval) "TestAgentBinGsaExecutesEval must pass")
    (assert (TestAgentCliHelpContainsUsage) "TestAgentCliHelpContainsUsage must pass")
    (assert (TestTaskF13GroundedInPhaseFINSEL) "TestTaskF13GroundedInPhaseFINSEL must pass")
    true))
