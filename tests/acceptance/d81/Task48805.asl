(module phase488/task5
  :d "Test DuckDB Analytical Telemetry Query Engine Adapter"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm duckdb 'SELECT count(*)'"))]
    (assert (= (.-exitCode res) 0) "DuckDB query should succeed")
    (assert (string-contains? (.-stdout res) ":action :duckdb") "Action is duckdb")
    (refute (= (.-exitCode res) 127) "Should not be 127")
    true))
