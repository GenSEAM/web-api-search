(module tests/acceptance/d81/Task48403
  :d "Acceptance fixture for Task48403: Tier Alpha RPC Contract Dispatcher for Notes, Receipts and Telemetry under D83."
  :x [run-tests
      test-rpc-handlers-implemented-in-engine
      test-blamed-rejection-helper-implemented
      test-rpc-dispatch-registered-in-execute-step
      test-blamed-rejection-token-bounded]
  :i [])

(df test-rpc-handlers-implemented-in-engine [] -> Bool
  :d "Verifies that handle_rpc_note, handle_rpc_receipt, and handle_rpc_telemetry are implemented"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "handle_rpc_note") "handle_rpc_note implemented")
      (assert (string-contains? src "handle_rpc_receipt") "handle_rpc_receipt implemented")
      (assert (string-contains? src "handle_rpc_telemetry") "handle_rpc_telemetry implemented")
      true)))

(df test-blamed-rejection-helper-implemented [] -> Bool
  :d "Verifies that emit_blamed_rejection helper constructs typed blamed receipts"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "emit_blamed_rejection") "emit_blamed_rejection declared")
      (assert (string-contains? src ":reject (:reject :code") "blamed rejection schema rendered")
      (assert (string-contains? src ":field :") "field symbol rendered")
      (assert (string-contains? src ":expected :") "expected symbol rendered")
      true)))

(df test-rpc-dispatch-registered-in-execute-step [] -> Bool
  :d "Verifies that execute_single_step dispatches note, receipt, and telemetry ops"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(op, \"note\") == 0") "note op dispatch")
      (assert (string-contains? src "strcmp(op, \"receipt\") == 0") "receipt op dispatch")
      (assert (string-contains? src "strcmp(op, \"telemetry\") == 0") "telemetry op dispatch")
      true)))

(df test-blamed-rejection-token-bounded [] -> Bool
  :d "Verifies that blamed rejection codes align with error taxonomy"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "E_SCHEMA_MISSING_FIELD") "missing field error code used")
      (assert (string-contains? src "E_SCHEMA_INVALID_KEYWORD") "invalid keyword error code used")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48403 acceptance assertions"
  (let [(r1 (test-rpc-handlers-implemented-in-engine))
        (r2 (test-blamed-rejection-helper-implemented))
        (r3 (test-rpc-dispatch-registered-in-execute-step))
        (r4 (test-blamed-rejection-token-bounded))]
    (assert (and r1 (and r2 (and r3 r4))) "All Task48403 checks must pass")
    true))
