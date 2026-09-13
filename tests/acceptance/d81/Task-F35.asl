(module tests/acceptance/d81/Task-F35
  :d "Acceptance fixture for Task-F35: Standardize Agent Package Module Namespaces under ADR-0081."
  :x [RunTests
      TestAgentCoreModuleHeadersCanonical
      TestAgentBusModuleHeadersCanonical
      TestTaskF35GroundedInPhaseFINSEL]
  :i [])

(df verify-module-header [(file-path String) (expected-prefix String) (prohibited-prefix String)] -> Bool
  :d "Verifies a source file declares canonical module namespace and does not use prohibited legacy prefix"
  (let [(res (file-read file-path))]
    (mt res
      ((ok content)
       (let [(has-expected (string-contains? content expected-prefix))
             (has-prohibited (string-contains? content prohibited-prefix))]
         (assert has-expected (str file-path " must declare canonical module " expected-prefix))
         (assert (not has-prohibited) (str file-path " must not declare divergent module " prohibited-prefix))
         (and has-expected (not has-prohibited))))
      ((err _)
       (assert false (str file-path " must exist and be readable"))
       false))))

(df TestAgentCoreModuleHeadersCanonical [] -> Bool
  :d "Verifies all agent-core files declare (module asl-agent-core/ and not asl-core/"
  (let [(c1 (verify-module-header "agent-core/src/clarify.asl" "(module asl-agent-core/clarify" "(module asl-core/clarify"))
        (c2 (verify-module-header "agent-core/src/scheduler.asl" "(module asl-agent-core/scheduler" "(module asl-core/scheduler"))
        (c3 (verify-module-header "agent-core/src/tasktypes.asl" "(module asl-agent-core/tasktypes" "(module asl-core/tasktypes"))
        (c4 (verify-module-header "agent-core/src/statemachine.asl" "(module asl-agent-core/statemachine" "(module asl-core/statemachine"))
        (c5 (verify-module-header "agent-core/src/promptpool.asl" "(module asl-agent-core/promptpool" "(module asl-core/promptpool"))
        (c6 (verify-module-header "agent-core/src/dag.asl" "(module asl-agent-core/dag" "(module asl-core/dag"))
        (c7 (verify-module-header "agent-core/src/taskstore.asl" "(module asl-agent-core/taskstore" "(module asl-core/taskstore"))
        (c8 (verify-module-header "agent-core/src/premise.asl" "(module asl-agent-core/premise" "(module asl-core/premise"))
        (c9 (verify-module-header "agent-core/src/compose.asl" "(module asl-agent-core/compose" "(module asl-core/compose"))
        (c10 (verify-module-header "agent-core/src/threads.asl" "(module asl-agent-core/threads" "(module asl-core/threads"))]
    (and (and (and (and c1 c2) (and c3 c4)) (and (and c5 c6) (and c7 c8))) (and c9 c10))))

(df TestAgentBusModuleHeadersCanonical [] -> Bool
  :d "Verifies all agent-bus files declare (module asl-agent-bus/ and not divergent prefixes"
  (let [(b1 (verify-module-header "agent-bus/src/presence.asl" "(module asl-agent-bus/presence" "(module agent-bus/presence"))
        (b2 (verify-module-header "agent-bus/src/nd_asn.asl" "(module asl-agent-bus/nd-asn" "(module agent-bus/nd-asn"))
        (b3 (verify-module-header "agent-bus/src/gateway.asl" "(module asl-agent-bus/gateway" "(module asl-bus/gateway"))
        (b4 (verify-module-header "agent-bus/src/transport.asl" "(module asl-agent-bus/transport" "(module asl-bus/transport"))
        (b5 (verify-module-header "agent-bus/src/bus.asl" "(module asl-agent-bus/bus" "(module agent-bus/bus"))
        (b6 (verify-module-header "agent-bus/src/cluster.asl" "(module asl-agent-bus/cluster" "(module asl-bus/cluster"))
        (b7 (verify-module-header "agent-bus/src/wire.asl" "(module asl-agent-bus/wire" "(module asl-bus/wire"))
        (b8 (verify-module-header "agent-bus/src/proc_telemetry.asl" "(module asl-agent-bus/proc-telemetry" "(module agent-bus/proc-telemetry"))
        (b9 (verify-module-header "agent-bus/src/bridge.asl" "(module asl-agent-bus/bridge" "(module asl-bus/bridge"))
        (b10 (verify-module-header "agent-bus/src/browser-bridge.asl" "(module asl-agent-bus/browser-bridge" "(module asl-bus/browser-bridge"))]
    (and (and (and (and b1 b2) (and b3 b4)) (and (and b5 b6) (and b7 b8))) (and b9 b10))))

(df TestTaskF35GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F35 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F35\""))
             (has-title (string-contains? content ":title \"Standardize Agent Package Module Namespaces\""))]
         (assert has-id "Task-F35 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F35 title must match PhaseFINSELRemediation.asn")
         (and has-id has-title)))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F35"
  (let [(t1 (TestAgentCoreModuleHeadersCanonical))
        (t2 (TestAgentBusModuleHeadersCanonical))
        (t3 (TestTaskF35GroundedInPhaseFINSEL))]
    (and (and t1 t2) t3)))
