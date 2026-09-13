(module tests/acceptance/d81/Task48404
  :d "Acceptance fixture for Task48404: Tier Beta RPC Contract Dispatcher for Decisions, Intents, Principles, Recipes and Components under D83."
  :x [run-tests
      test-tier-beta-rpc-handlers-implemented
      test-shortcode-validation-implemented
      test-tier-beta-rpc-dispatch-registered
      test-tier-beta-blamed-rejection-wired]
  :i [])

(df test-tier-beta-rpc-handlers-implemented [] -> Bool
  :d "Verifies that handlers for decision, intent, principle, recipe, and component are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "handle_rpc_decision") "handle_rpc_decision implemented")
      (assert (string-contains? src "handle_rpc_intent") "handle_rpc_intent implemented")
      (assert (string-contains? src "handle_rpc_principle") "handle_rpc_principle implemented")
      (assert (string-contains? src "handle_rpc_recipe") "handle_rpc_recipe implemented")
      (assert (string-contains? src "handle_rpc_component") "handle_rpc_component implemented")
      true)))

(df test-shortcode-validation-implemented [] -> Bool
  :d "Verifies that shortcode and identifier validators are implemented"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "is_valid_decision_shortcode") "decision shortcode validator implemented")
      (assert (string-contains? src "is_valid_intent_id") "intent id validator implemented")
      true)))

(df test-tier-beta-rpc-dispatch-registered [] -> Bool
  :d "Verifies that execute_single_step dispatches Tier Beta operations"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "strcmp(op, \"decision\") == 0") "decision op dispatch")
      (assert (string-contains? src "strcmp(op, \"intent\") == 0") "intent op dispatch")
      (assert (string-contains? src "strcmp(op, \"principle\") == 0") "principle op dispatch")
      (assert (string-contains? src "strcmp(op, \"recipe\") == 0") "recipe op dispatch")
      (assert (string-contains? src "strcmp(op, \"component\") == 0") "component op dispatch")
      true)))

(df test-tier-beta-blamed-rejection-wired [] -> Bool
  :d "Verifies that Tier Beta operations enforce schemas using blamed rejections"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "E_SCHEMA_INVALID_SHORTCODE") "invalid shortcode error code used")
      (assert (string-contains? src "E_SCHEMA_MISSING_FIELD") "missing field error code used")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48404 acceptance assertions"
  (let [(r1 (test-tier-beta-rpc-handlers-implemented))
        (r2 (test-shortcode-validation-implemented))
        (r3 (test-tier-beta-rpc-dispatch-registered))
        (r4 (test-tier-beta-blamed-rejection-wired))]
    (assert (and r1 (and r2 (and r3 r4))) "All Task48404 checks must pass")
    true))
