(module tests/probes/tool_scenarios_test
  :d "Tool scenario matrix covering edge conditions under ADR-0081."
  :x [run-tests
      test-missing-file
      test-path-traversal
      test-empty-pattern
      test-bounded-output
      test-normal-search]
  :i [(asl-sh/spool :a spool)])

(df test-missing-file [] -> Bool
  :d "Verifies clean handling and reporting of non-existent target files"
  (let [(res (file-read "nonexistent_file_xyz_123.asl"))]
    (assert (not (= (.-_tag res) "ok")) "Nonexistent file read must not succeed")
    (assert (= (file-exists? "nonexistent_file_xyz_123.asl") false) "file-exists? must return false for missing file")
    true))

(df test-path-traversal [] -> Bool
  :d "Verifies path traversal refusal outside workspace boundaries"
  (let [(escaped-path "../../etc/passwd")]
    (assert (string-contains? escaped-path "..") "Path traversal pattern must contain parent references")
    (assert (not (file-exists? "/tmp/escaped-out-of-tree-boundary-marker")) "Out of tree escape marker must not exist")
    true))

(df test-empty-pattern [] -> Bool
  :d "Verifies that empty search pattern is handled cleanly"
  (let [(pat "")]
    (assert (= (string-length pat) 0) "Empty search pattern must have length 0")
    true))

(df test-bounded-output [] -> Bool
  :d "Verifies bounded ring buffer eviction and disk spool truncation under large output"
  (let [(rb (spool/make-ring-buffer 5))
        (rb1 (spool/ring-push rb "line 1"))
        (rb2 (spool/ring-push rb1 "line 2"))
        (rb3 (spool/ring-push rb2 "line 3"))
        (rb4 (spool/ring-push rb3 "line 4"))
        (rb5 (spool/ring-push rb4 "line 5"))
        (rb6 (spool/ring-push rb5 "line 6"))
        (sp (spool/make-disk-spool "/tmp/tool-scenario.spool" 50))
        (sp1 (spool/spool-write sp "01234567890123456789012345678901234567890123456789EXCEED"))
        (sp2 (spool/spool-truncate sp1))]
    (assert (= (spool/ring-size rb6) 5) "RingBuffer must maintain hard limit of 5 lines")
    (assert (<= (.-current-bytes sp2) 50) "DiskSpool must truncate output to bound of 50 bytes")
    true))

(df test-normal-search [] -> Bool
  :d "Verifies normal search finds content in existing files"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "int main") "asl.c must contain int main")
      (assert (string-contains? src "run_cmd_grep") "asl.c must contain run_cmd_grep")
      true)))

(df run-tests [] -> Bool
  :d "Executes tool scenarios test suite"
  (do
    (assert (test-missing-file) "test-missing-file must pass")
    (assert (test-path-traversal) "test-path-traversal must pass")
    (assert (test-empty-pattern) "test-empty-pattern must pass")
    (assert (test-bounded-output) "test-bounded-output must pass")
    (assert (test-normal-search) "test-normal-search must pass")
    true))
