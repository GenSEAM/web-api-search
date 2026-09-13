(module tests/acceptance/d81/Task50501
  :d "Acceptance fixture for Task 50501: asl-text Emoji Guard Line Index Fix per C2 and D77"
  :x [testEmojiGuardDynamicExecution
      RunTests]
  :i [])

(df testEmojiGuardDynamicExecution [] -> Bool
  :d "Dynamically runs the emoji guard test suite via bin/asl CLI to verify accurate line indexing from the outside"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-text/tests/emoji_guard_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "asl-text emoji_guard_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "asl-text emoji_guard_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "Emoji guard test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "Emoji guard test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "Emoji guard test must not encounter assertion failures")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50501 acceptance tests"
  (do
    (assert (testEmojiGuardDynamicExecution) "testEmojiGuardDynamicExecution must pass")
    true))
