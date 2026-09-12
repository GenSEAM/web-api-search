(module tests/acceptance/d81/Task46902
  :d "Acceptance fixture for Task46902: pull-based observability over event spool and condition-triggered push."
  :x [RunTests
      TestPullQueryContractsDeclared
      TestScalarExtractionSupported
      TestConditionPushDeclared]
  :i [(agent-bus/bus :a bus)])

(df TestPullQueryContractsDeclared [] -> Bool
  :d "Verifies that agent-bus/src/bus.asl declares pull-based event querying interfaces and executes query filtering"
  (let [(res (file-read "agent-bus/src/bus.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/bus.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "query-bus-events") (string-contains? src "pull-bus-events") (string-contains? src "query-events"))
              "bus.asl must define pull-based query function over events")
      (let [(m1 (bus/AgentMessage :sender "a1" :target "bus" :payload "(:change :path \"asl/tools/asl.c\")" :timestamp 100))
            (m2 (bus/AgentMessage :sender "a2" :target "bus" :payload "(:change :path \"mem/src/vfs.asl\")" :timestamp 101))
            (events (list m1 m2))
            (q1 (bus/query-bus-events events "change" "asl/tools/asl.c"))
            (q2 (bus/pull-bus-events events "change"))]
        (assert (= (list-length q1) 1) "query-bus-events must return 1 matching event")
        (assert (string-contains? (.-payload (first q1)) "asl/tools/asl.c") "filtered message must contain target path")
        (assert (= (list-length q2) 2) "pull-bus-events must return both change events")
        true))))

(df TestScalarExtractionSupported [] -> Bool
  :d "Verifies that mem/src/pointer.asl exports scalar fact extraction primitives"
  (let [(res (file-read "mem/src/pointer.asl"))]
    (assert (= (.-_tag res) "ok") "mem/src/pointer.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "extract-scalar-fact") "pointer.asl must export extract-scalar-fact")
      (assert (string-contains? src "should-offload?") "pointer.asl must export should-offload?")
      true)))

(df TestConditionPushDeclared [] -> Bool
  :d "Verifies that bus.asl condition-wake structures instantiate and evaluate condition-triggered wakes"
  (let [(res (file-read "agent-bus/src/bus.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/bus.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "ConditionWake") (string-contains? src "ConditionPush") (string-contains? src "condition-wake"))
              "bus.asl must declare condition-wake representation")
      (let [(w0 (bus/make-condition-wake "watch-asl" "asl/tools/asl.c" "supervisor"))
            (m-miss (bus/AgentMessage :sender "worker" :target "bus" :payload "(:change :path \"mem/src/vfs.asl\")" :timestamp 101))
            (m-hit (bus/AgentMessage :sender "worker" :target "bus" :payload "(:change :path \"asl/tools/asl.c\")" :timestamp 102))
            (w-miss (bus/eval-condition-wake w0 m-miss))
            (w-hit (bus/eval-condition-wake w0 m-hit))]
        (assert (= (.-condition-name w0) "watch-asl") "wake condition name must match")
        (assert (= (.-target-agent w0) "supervisor") "wake target agent must match")
        (assert (not (.-triggered w0)) "initial wake must not be triggered")
        (assert (not (.-triggered w-miss)) "wake evaluated against non-matching message must not trigger")
        (assert (.-triggered w-hit) "wake evaluated against matching message must trigger")
        true))))

(df RunTests [] -> Bool
  (and (TestPullQueryContractsDeclared)
       (TestScalarExtractionSupported)
       (TestConditionPushDeclared)))
