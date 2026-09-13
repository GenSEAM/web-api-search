(module tests/fixtures/crossModuleImport
  :d "Positive cross-module import test fixture."
  :x [runTests]
  :i [(asl-text/escape :a esc)])

(df runTests [] -> Bool
  :d "Verifies cross-module function call succeeds."
  (let [(res (esc/escapeAsnStr "sample"))]
    (assert (= res "sample") "cross-module import must resolve and execute")
    true))
