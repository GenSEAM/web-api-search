(module tests/acceptance/d81/Task48407
  :d "Acceptance fixture for Task48407: Reactive Mutation Event Bus and Observability Stream under D83 and D71."
  :x [run-tests
      test-events-grammar-schema-exists
      test-mutation-event-emitter-implemented
      test-event-bus-and-observability-hooks-declared]
  :i [])

(df test-events-grammar-schema-exists [] -> Bool
  :d "Verifies that asl/grammar/events.asn exists and defines mutationEvent and eventStreamConfig schemas"
  (let [(res (file-read "asl/grammar/events.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/events.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "mutationEvent") "mutationEvent schema defined")
      (assert (string-contains? src "eventStreamConfig") "eventStreamConfig schema defined")
      (assert (string-contains? src ":eventBus") "eventBus section defined")
      true)))

(df test-mutation-event-emitter-implemented [] -> Bool
  :d "Verifies that emit_mutation_event and event_stream_init are implemented in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "emit_mutation_event") "emit_mutation_event implemented")
      (assert (string-contains? src "event_stream_init") "event_stream_init implemented")
      true)))

(df test-event-bus-and-observability-hooks-declared [] -> Bool
  :d "Verifies that event_bus and observability_hook concepts are declared in asl.c"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "event_bus") "event_bus declared")
      (assert (string-contains? src "observability_hook") "observability_hook declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48407 acceptance assertions"
  (let [(r1 (test-events-grammar-schema-exists))
        (r2 (test-mutation-event-emitter-implemented))
        (r3 (test-event-bus-and-observability-hooks-declared))]
    (assert (and r1 (and r2 r3)) "All Task48407 checks must pass")
    true))
