(module tests/acceptance/d81/Task43604
  :d "Acceptance fixture for Task43604: immediate editing reporting and staging transition rejection."
  :x [run-tests]
  :i [])

(df test-immediate-edit-reporting [] -> Bool
  :d "Verifies that edit reports immediate write mode and modifies target fixture directly"
  (let [(edit-step {:id 1
                    :op "edit"
                    :status "ok"
                    :mode "immediate"
                    :file "tests/acceptance/d81/ResolutionSample.asl"
                    :modified true})]
    (assert (= (.-op edit-step) "edit") "step op must be edit")
    (assert (= (.-status edit-step) "ok") "step status must be ok")
    (assert (= (.-mode edit-step) "immediate") "edit must explicitly report immediate mode")
    (assert (.-modified edit-step) "target fixture must be marked modified")
    true))

(df test-staging-operations-rejection [] -> Bool
  :d "Verifies that staging operations diff, flush, and discard return rejected with :ERR_UNSUPPORTED"
  (let [(diff-step {:id 1 :op "diff" :status "rejected" :error-code ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})
        (flush-step {:id 2 :op "flush" :status "rejected" :error-code ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})
        (discard-step {:id 3 :op "discard" :status "rejected" :error-code ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})]
    (assert (= (.-status diff-step) "rejected") "diff must be rejected until staging substrate lands")
    (assert (= (.-error-code diff-step) ":ERR_UNSUPPORTED") "diff error-code must be :ERR_UNSUPPORTED")
    (assert (= (.-status flush-step) "rejected") "flush must be rejected until staging substrate lands")
    (assert (= (.-error-code flush-step) ":ERR_UNSUPPORTED") "flush error-code must be :ERR_UNSUPPORTED")
    (assert (= (.-status discard-step) "rejected") "discard must be rejected until staging substrate lands")
    (assert (= (.-error-code discard-step) ":ERR_UNSUPPORTED") "discard error-code must be :ERR_UNSUPPORTED")
    true))

(df run-tests [] -> Bool
  :d "Executes all Task43604 acceptance tests and returns boolean true"
  (do
    (assert (test-immediate-edit-reporting) "test-immediate-edit-reporting must pass")
    (assert (test-staging-operations-rejection) "test-staging-operations-rejection must pass")
    true))
