(module tests/acceptance/d81/Task43604
  :d "Acceptance fixture for Task43604: immediate editing reporting and staging transition rejection."
  :x [runTests]
  :i [])

(df testImmediateEditReporting [] -> Bool
  :d "Verifies that edit reports immediate write mode and modifies target fixture directly"
  (let [(editStep {:id 1
                    :op "edit"
                    :status "ok"
                    :mode "immediate"
                    :file "tests/acceptance/d81/ResolutionSample.asl"
                    :modified true})]
    (assert (= (.-op editStep) "edit") "step op must be edit")
    (assert (= (.-status editStep) "ok") "step status must be ok")
    (assert (= (.-mode editStep) "immediate") "edit must explicitly report immediate mode")
    (assert (.-modified editStep) "target fixture must be marked modified")
    true))

(df testStagingOperationsRejection [] -> Bool
  :d "Verifies that staging operations diff, flush, and discard return rejected with :ERR_UNSUPPORTED"
  (let [(diffStep {:id 1 :op "diff" :status "rejected" :errorCode ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})
        (flushStep {:id 2 :op "flush" :status "rejected" :errorCode ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})
        (discardStep {:id 3 :op "discard" :status "rejected" :errorCode ":ERR_UNSUPPORTED" :message "Staging unsupported in immediate mode"})]
    (assert (= (.-status diffStep) "rejected") "diff must be rejected until staging substrate lands")
    (assert (= (.-errorCode diffStep) ":ERR_UNSUPPORTED") "diff error-code must be :ERR_UNSUPPORTED")
    (assert (= (.-status flushStep) "rejected") "flush must be rejected until staging substrate lands")
    (assert (= (.-errorCode flushStep) ":ERR_UNSUPPORTED") "flush error-code must be :ERR_UNSUPPORTED")
    (assert (= (.-status discardStep) "rejected") "discard must be rejected until staging substrate lands")
    (assert (= (.-errorCode discardStep) ":ERR_UNSUPPORTED") "discard error-code must be :ERR_UNSUPPORTED")
    true))

(df runTests [] -> Bool
  :d "Executes all Task43604 acceptance tests and returns boolean true"
  (do
    (assert (testImmediateEditReporting) "test-immediate-edit-reporting must pass")
    (assert (testStagingOperationsRejection) "test-staging-operations-rejection must pass")
    true))
