(module tests/acceptance/d81/Task48405
  :d "Acceptance fixture for Task48405: Tier Gamma RPC Contract Dispatcher for Tasks D52, Phases and Plans under D83."
  :x [run-tests
      test-tier-gamma-rpc-handlers-implemented
      test-tier-gamma-rpc-dispatch-registered
      test-d52-gate-and-actiondag-validation]
  :i [])

(df test-tier-gamma-rpc-handlers-implemented [] -> Bool
  :d "Verifies that handle_rpc_task, handle_rpc_phase, handle_rpc_plan, and validate_d52_schema are implemented"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "handle_rpc_task") "handle_rpc_task implemented")
      (assert (string-contains? src "handle_rpc_phase") "handle_rpc_phase implemented")
      (assert (string-contains? src "handle_rpc_plan") "handle_rpc_plan implemented")
      (assert (string-contains? src "validate_d52_schema") "validate_d52_schema implemented")
      true)))

(df test-tier-gamma-rpc-dispatch-registered [] -> Bool
  :d "Verifies that execute_single_step dispatches task, phase, and plan operations"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(op, \"task\") == 0") "task op dispatch")
      (assert (string-contains? src "strcmp(op, \"phase\") == 0") "phase op dispatch")
      (assert (string-contains? src "strcmp(op, \"plan\") == 0") "plan op dispatch")
      true)))

(df test-d52-gate-and-actiondag-validation [] -> Bool
  :d "Verifies that validate_d52_schema enforces gate and actionDag with blamed rejections"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "Task must define verification gate (:gate)") "gate validation message")
      (assert (string-contains? src "Task must define action DAG (:actionDag)") "actionDag validation message")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48405 acceptance assertions"
  (let [(r1 (test-tier-gamma-rpc-handlers-implemented))
        (r2 (test-tier-gamma-rpc-dispatch-registered))
        (r3 (test-d52-gate-and-actiondag-validation))]
    (assert (and r1 (and r2 r3)) "All Task48405 checks must pass")
    true))
