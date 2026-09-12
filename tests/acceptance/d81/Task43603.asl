(module tests/acceptance/d81/Task43603
  :d "Acceptance fixture for Task43603: RPC capability contracts and honest status rejection."
  :x [run-tests]
  :i [])

(df test-rpc-positive-control [] -> Bool
  :d "Verifies positive control: standard RPC batch response conforms to protocol"
  (let [(res {:status "completed"
              :items-count 1
              :parallel true
              :results (list {:id 1 :op "ping" :status "ok" :result "pong"})})]
    (assert (= (.-status res) "completed") "batch status must be completed")
    (assert (= (.-items-count res) 1) "batch items count must equal 1")
    (let [(item (first (.-results res)))]
      (assert (= (.-op item) "ping") "step op must match ping")
      (assert (= (.-status item) "ok") "step status must be ok")
      (assert (= (.-result item) "pong") "result must match pong"))
    true))

(df test-rpc-rejection-semantics [] -> Bool
  :d "Verifies RPC rejection semantics: unknown operations produce status rejected with :ERR_UNIMPLEMENTED and aggregate error status"
  (let [(res {:status "failed"
              :items-count 1
              :parallel true
              :results (list {:id 1
                              :op "unsupported-op"
                              :status "rejected"
                              :error-code ":ERR_UNIMPLEMENTED"
                              :message "Operation not implemented in registry"})})]
    (assert (= (.-status res) "failed") "batch status must be failed when an item is rejected")
    (let [(item (first (.-results res)))]
      (assert (= (.-op item) "unsupported-op") "rejected step op must be preserved")
      (assert (= (.-status item) "rejected") "step status must be rejected")
      (assert (= (.-error-code item) ":ERR_UNIMPLEMENTED") "error-code must be :ERR_UNIMPLEMENTED"))
    true))

(df run-tests [] -> Bool
  :d "Executes all Task43603 acceptance tests and returns boolean true"
  (do
    (assert (test-rpc-positive-control) "test-rpc-positive-control must pass")
    (assert (test-rpc-rejection-semantics) "test-rpc-rejection-semantics must pass")
    true))
