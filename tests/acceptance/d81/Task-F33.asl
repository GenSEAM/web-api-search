(module tests/acceptance/d81/Task-F33
  :d "Acceptance fixture for Task-F33: Deduplicate Token Estimation Helper Across Monorepo (C3/D34) under ADR-0081."
  :x [RunTests
      TestCanonicalEstimateTokens
      TestZeroDuplicateEstimateTokensInMonorepo
      TestTaskF33GroundedInPhaseFINSEL]
  :i [(asl-text/text :a txt)])

(df verify-no-local-estimate-tokens [(file-path String)] -> Bool
  :d "Verifies a source file does not define a private duplicate of estimate-tokens"
  (let [(res (file-read file-path))]
    (mt res
      ((ok content)
       (let [(has-duplicate (string-contains? content "(df estimate-tokens "))]
         (assert (not has-duplicate) (str file-path " must not contain private duplicate (df estimate-tokens)"))
         (not has-duplicate)))
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestCanonicalEstimateTokens [] -> Bool
  :d "Verifies canonical estimate-tokens behavior in asl-text/text"
  (assert (= (txt/estimate-tokens "") 0) "Empty text must estimate to 0 tokens")
  (assert (= (txt/estimate-tokens "asl") 1) "Short text <= 4 chars must estimate to 1 token")
  (assert (= (txt/estimate-tokens "1234") 1) "4-char text must estimate to 1 token")
  (assert (> (txt/estimate-tokens "Hello world, this is a test.") 1) "Long text must estimate to > 1 tokens")
  true)

(df TestZeroDuplicateEstimateTokensInMonorepo [] -> Bool
  :d "Verifies all identified duplicate locations have eliminated local (df estimate-tokens"
  (let [(f1 (verify-no-local-estimate-tokens "harness/src/stream_demuxer.asl"))
        (f2 (verify-no-local-estimate-tokens "harness/src/context_assembler.asl"))
        (f3 (verify-no-local-estimate-tokens "harness/src/tool-transpiler.asl"))
        (f4 (verify-no-local-estimate-tokens "agent-core/src/prompt_tree.asl"))
        (f5 (verify-no-local-estimate-tokens "intel/src/preload.asl"))
        (f6 (verify-no-local-estimate-tokens "asl/packages/asl-plugin/src/dynamic_tool.asl"))
        (f7 (verify-no-local-estimate-tokens "asl/packages/asl-sh/src/process.asl"))
        (f8 (verify-no-local-estimate-tokens "asl/packages/asl-sh/src/core/process.asl"))]
    (and (and (and f1 f2) (and f3 f4)) (and (and f5 f6) (and f7 f8)))))

(df TestTaskF33GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F33 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F33\""))
             (has-title (string-contains? content ":title \"Deduplicate Token Estimation Helper Across Monorepo\""))]
         (assert has-id "Task-F33 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F33 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F33"
  (let [(t1 (TestCanonicalEstimateTokens))
        (t2 (TestZeroDuplicateEstimateTokensInMonorepo))
        (t3 (TestTaskF33GroundedInPhaseFINSEL))]
    (and (and t1 t2) t3)))
