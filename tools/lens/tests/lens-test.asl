(module aslTools/lensTest
  :d "Unit tests for Lens codebase steering engine in pure AgentScript."
  :x [testLensSteeringDirectives
      testLensOnboardingFormat
      testLensDiagnosticsExecution
      runTests]
  :i [(lens :a lens)])

"run: (run-tests)"

(df testLensSteeringDirectives [] -> Bool
  (let [(cfg (lens/makeLensConfig "claude-code" 50 true))
        (dirs (lens/generateSteeringDirectives cfg))]
    (assert (>= (string-length (.-negativeConstraints dirs)) 40) "negative-constraints must have at least 40 chars")
    (assert (>= (string-length (.-steeringRules dirs)) 40) "steering-rules must have at least 40 chars")
    true))

(df testLensOnboardingFormat [] -> Bool
  (let [(msg (lens/formatOnboardingMessage))]
    (assert (>= (string-length msg) 50) "onboarding-message must have length >= 50")
    (assert (not (string-contains? msg "deprecated")) "onboarding-message must not contain deprecated")
    true))

(df testLensDiagnosticsExecution [] -> Bool
  (let [(res (lens/runLensDiagnostics "cursor"))]
    (assert (.-success res) "lens-diagnostics must succeed")
    (assert (== (.-agent (.-directives res)) "cursor") "agent must equal cursor")
    true))

(df runTests [] -> Bool
  (do
    (assert (testLensSteeringDirectives) "test-lens-steering-directives must pass")
    (assert (testLensOnboardingFormat) "test-lens-onboarding-format must pass")
    (assert (testLensDiagnosticsExecution) "test-lens-diagnostics-execution must pass")
    true))
