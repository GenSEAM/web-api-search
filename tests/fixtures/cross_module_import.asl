(module tests/fixtures/cross-module-import
  :d "Positive cross-module import test fixture."
  :x [run-tests]
  :i [(asl-text/escape :a esc)])

(df run-tests [] -> Bool
  :d "Verifies cross-module function call succeeds."
  (let [(res (esc/escape-asn-str "sample"))]
    (assert (= res "sample") "cross-module import must resolve and execute")
    true))
