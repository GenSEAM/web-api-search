(module asl-tools/lens-test
  :d "Unit tests for Lens codebase steering engine in pure AgentScript."
  :x [test-lens-steering-directives
      test-lens-onboarding-format
      test-lens-diagnostics-execution
      run-tests]
  :i [(lens :a lens)])

"run: (run-tests)"

(df test-lens-steering-directives [] -> Bool
  (let [(cfg (lens/make-lens-config "claude-code" 50 true))
        (dirs (lens/generate-steering-directives cfg))]
    (assert (>= (string-length (.-negative-constraints dirs)) 40) "negative-constraints must have at least 40 chars")
    (assert (>= (string-length (.-steering-rules dirs)) 40) "steering-rules must have at least 40 chars")
    true))

(df test-lens-onboarding-format [] -> Bool
  (let [(msg (lens/format-onboarding-message))]
    (assert (>= (string-length msg) 50) "onboarding-message must have length >= 50")
    (assert (not (string-contains? msg "deprecated")) "onboarding-message must not contain deprecated")
    true))

(df test-lens-diagnostics-execution [] -> Bool
  (let [(res (lens/run-lens-diagnostics "cursor"))]
    (assert (.-success res) "lens-diagnostics must succeed")
    (assert (== (.-agent (.-directives res)) "cursor") "agent must equal cursor")
    true))

(df run-tests [] -> Bool
  (do
    (assert (test-lens-steering-directives) "test-lens-steering-directives must pass")
    (assert (test-lens-onboarding-format) "test-lens-onboarding-format must pass")
    (assert (test-lens-diagnostics-execution) "test-lens-diagnostics-execution must pass")
    true))
