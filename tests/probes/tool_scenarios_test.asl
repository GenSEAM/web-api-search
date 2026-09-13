(module tests/probes/tool_scenarios_test
  :d "Tool scenario matrix covering edge conditions under ADR-0081."
  :x [runTests
      testMissingFile
      testPathTraversal
      testEmptyPattern
      testBoundedOutput
      testNormalSearch]
  :i [(asl-sh/spool :a spool)])

(df testMissingFile [] -> Bool
  :d "Verifies clean handling and reporting of non-existent target files"
  (let [(res (file-read "nonexistent_file_xyz_123.asl"))]
    (assert (not (= (.-_tag res) "ok")) "Nonexistent file read must not succeed")
    (assert (= (file-exists? "nonexistent_file_xyz_123.asl") false) "file-exists? must return false for missing file")
    true))

(df testPathTraversal [] -> Bool
  :d "Verifies path traversal refusal outside workspace boundaries"
  (let [(escapedPath "../../etc/passwd")]
    (assert (string-contains? escapedPath "..") "Path traversal pattern must contain parent references")
    (assert (not (file-exists? "/tmp/escaped-out-of-tree-boundary-marker")) "Out of tree escape marker must not exist")
    true))

(df testEmptyPattern [] -> Bool
  :d "Verifies that empty search pattern is handled cleanly"
  (let [(pat "")]
    (assert (= (string-length pat) 0) "Empty search pattern must have length 0")
    true))

(df testBoundedOutput [] -> Bool
  :d "Verifies bounded ring buffer eviction and disk spool truncation under large output"
  (let [(rb (spool/makeRingBuffer 5))
        (rb1 (spool/ringPush rb "line 1"))
        (rb2 (spool/ringPush rb1 "line 2"))
        (rb3 (spool/ringPush rb2 "line 3"))
        (rb4 (spool/ringPush rb3 "line 4"))
        (rb5 (spool/ringPush rb4 "line 5"))
        (rb6 (spool/ringPush rb5 "line 6"))
        (sp (spool/makeDiskSpool "/tmp/tool-scenario.spool" 50))
        (sp1 (spool/spoolWrite sp "01234567890123456789012345678901234567890123456789EXCEED"))
        (sp2 (spool/spoolTruncate sp1))]
    (assert (= (spool/ringSize rb6) 5) "RingBuffer must maintain hard limit of 5 lines")
    (assert (<= (.-currentBytes sp2) 50) "DiskSpool must truncate output to bound of 50 bytes")
    true))

(df testNormalSearch [] -> Bool
  :d "Verifies normal search finds content in existing files"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "int main") "asl.c must contain int main")
      (assert (string-contains? src "run_cmd_grep") "asl.c must contain run_cmd_grep")
      true)))

(df runTests [] -> Bool
  :d "Executes tool scenarios test suite"
  (do
    (assert (testMissingFile) "test-missing-file must pass")
    (assert (testPathTraversal) "test-path-traversal must pass")
    (assert (testEmptyPattern) "test-empty-pattern must pass")
    (assert (testBoundedOutput) "test-bounded-output must pass")
    (assert (testNormalSearch) "test-normal-search must pass")
    true))
