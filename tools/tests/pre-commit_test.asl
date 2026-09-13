(module aslTools/preCommitTest
  :d "Unit tests for pre-commit.asl"
  :x [runTests]
  :i [(preCommit :a pc)])

(df testDashedIdentifier [] -> Bool
  :d "Verifies dashed identifier detection."
  (let [(diff "+(df test-dashed-name [] -> Bool true)")]
    (assert (= (pc/countDashedIdentifiers diff) 1) "Dashed identifier")
    (assert (= (pc/countDashedIdentifiers "+(df testName [] -> Bool true)") 0) "No dashed identifier")
    true))

(df testUncompensatedSagas [] -> Bool
  :d "Verifies saga verification."
  (let [(diff1 "+(:saga (run-task))")
        (diff2 "+(:saga (run-task)) \n :compensate (undo)")]
    (assert (= (pc/countUncompensatedSagas diff1) 1) "Uncompensated saga")
    (assert (= (pc/countUncompensatedSagas diff2) 0) "Compensated saga")
    true))

(df runTests [] -> Bool
  :d "Executes pre-commit test suites."
  (do
    (assert (testDashedIdentifier) "test-dashed-identifier must pass")
    (assert (testUncompensatedSagas) "test-uncompensated-sagas must pass")
    true))
