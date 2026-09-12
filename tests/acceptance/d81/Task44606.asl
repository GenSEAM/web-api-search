(module tests/acceptance/d81/Task44606
  :d "Acceptance fixture for Task44606: camelCase across the wire and ledgers, enforced not asserted under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestKeyMappingRecordedSource
      TestKeyMappingModuleContract
      TestKeyMappingBidirectionalTranslation
      TestCheckerRejectsKebabCaseEmitter
      TestCheckerAcceptsCamelCaseEmitter
      TestTelemetryLedgerConvergence
      TestWireFramesAndLedgerRecordsKeyStyle
      TestGateIntegrationContract
      TestTask44606GroundedInPhase446]
  :i [("../../../harness/src/key_mapping" :a km)
      ("../../../agent-bus/src/wire" :a w)
      ("../../../agent-bus/src/mesh" :a mesh)
      ("../../../harness/src/trace_recorder" :a tr)
      ("../../../harness/src/llm_client" :a lc)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestKeyMappingRecordedSource [] -> Bool
  :d "Verifies key-mapping.asn exists in telemetry directory and records canonical key migration mappings"
  (let [(m-res (file-read ".asl/mem/telemetry/key-mapping.asn"))]
    (assert (= (.-_tag m-res) "ok") "key-mapping.asn must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src ":telemetryKeyMapping") "Must declare :telemetryKeyMapping form")
      (assert (string-contains? m-src "TelemetryKeyMapping20260913") "Must have canonical id")
      (assert (string-contains? m-src ":legacy \"exit-code\" :canonical \"exitCode\"") "Must map exit-code to exitCode")
      (assert (string-contains? m-src ":legacy \"latency-ms\" :canonical \"latencyMs\"") "Must map latency-ms to latencyMs")
      (assert (string-contains? m-src ":legacy \"duration-ms\" :canonical \"durationMs\"") "Must map duration-ms to durationMs")
      (assert (string-contains? m-src ":legacy \"error-code\" :canonical \"errorCode\"") "Must map error-code to errorCode")
      (assert (string-contains? m-src ":legacy \"session-id\" :canonical \"sessionId\"") "Must map session-id to sessionId")
      (assert (string-contains? m-src ":legacy \"tokens-out\" :canonical \"tokensOut\"") "Must map tokens-out to tokensOut")
      (assert (string-contains? m-src ":legacy \"orig-len\" :canonical \"origLen\"") "Must map orig-len to origLen")
      true)))

(df TestKeyMappingModuleContract [] -> Bool
  :d "Verifies harness/src/key_mapping.asl exists and grammar registers its symbols"
  (let [(m-res (file-read "harness/src/key_mapping.asl"))
        (g-res (file-read "harness/grammar.asn"))]
    (assert (= (.-_tag m-res) "ok") "key_mapping.asl must exist and be readable")
    (assert (= (.-_tag g-res) "ok") "grammar.asn must exist and be readable")
    (let [(m-src (.-value m-res))
          (g-src (.-value g-res))]
      (assert (string-contains? m-src "KeyMappingEntry") "Must define KeyMappingEntry")
      (assert (string-contains? m-src "normalize-to-canonical-key") "Must define normalize-to-canonical-key")
      (assert (string-contains? m-src "translate-to-legacy-key") "Must define translate-to-legacy-key")
      (assert (string-contains? m-src "audit-emitted-asn-keys") "Must define audit-emitted-asn-keys")
      (assert (string-contains? g-src ":name \"KeyMappingEntry\"") "grammar must register KeyMappingEntry")
      (assert (string-contains? g-src ":name \"normalize-to-canonical-key\"") "grammar must register normalize-to-canonical-key")
      (assert (string-contains? g-src ":name \"translate-to-legacy-key\"") "grammar must register translate-to-legacy-key")
      (assert (string-contains? g-src ":name \"audit-emitted-asn-keys\"") "grammar must register audit-emitted-asn-keys")
      true)))

(df TestKeyMappingBidirectionalTranslation [] -> Bool
  :d "Verifies bidirectional translation between legacy and canonical keys and record translation"
  (do
    (assert (km/RunTests) "Module internal tests must pass")
    (assert (= (km/normalize-to-canonical-key "exit-code") "exitCode") "exit-code normalizes to exitCode")
    (assert (= (km/normalize-to-canonical-key ":duration-ms") ":durationMs") ":duration-ms normalizes to :durationMs")
    (assert (= (km/normalize-to-canonical-key "tokens-out") "tokensOut") "tokens-out normalizes to tokensOut")
    (assert (= (km/translate-to-legacy-key "exitCode") "exit-code") "exitCode translates to exit-code")
    (assert (= (km/translate-to-legacy-key ":durationMs") ":duration-ms") ":durationMs translates to :duration-ms")
    (let [(raw-legacy "(:entry :exit-code 0 :duration-ms 25 :session-id \"sess1\")")
          (expected-canonical "(:entry :exitCode 0 :durationMs 25 :sessionId \"sess1\")")]
      (assert (= (km/normalize-asn-record-keys raw-legacy) expected-canonical) "normalize-asn-record-keys converts legacy to canonical")
      (assert (= (km/translate-asn-record-to-legacy expected-canonical) raw-legacy) "translate-asn-record-to-legacy converts canonical to legacy")
      true)))

(df TestCheckerRejectsKebabCaseEmitter [] -> Bool
  :d "Verifies that an emitter producing a kebab-case key fails the checker"
  (do
    (assert (not (km/audit-emitted-asn-keys "(:trace-entry :duration-ms 10)")) "kebab duration-ms must fail checker")
    (assert (not (km/audit-emitted-asn-keys "(:result :exit-code 1 :error-code \":ERR_FAIL\")")) "kebab exit-code must fail checker")
    (assert (not (km/audit-emitted-asn-keys "(:wire :orig-len 120)")) "kebab orig-len must fail checker")
    (assert (not (km/audit-emitted-asn-keys "(:telemetry :tokens-out 25 :tokens-in 50 :tok-sec 10.0)")) "kebab tokens-out must fail checker")
    (assert (not (km/audit-emitted-asn-keys "(:session :session-id \"s1\")")) "kebab session-id must fail checker")
    true))

(df TestCheckerAcceptsCamelCaseEmitter [] -> Bool
  :d "Verifies that an emitter producing canonical camelCase keys passes the checker"
  (do
    (assert (km/audit-emitted-asn-keys "(:trace-entry :durationMs 10 :sessionId \"s1\")") "camelCase durationMs and sessionId pass checker")
    (assert (km/audit-emitted-asn-keys "(:result :exitCode 0 :errorCode \"\")") "camelCase exitCode and errorCode pass checker")
    (assert (km/audit-emitted-asn-keys "(:wire :origLen 120)") "camelCase origLen passes checker")
    (assert (km/audit-emitted-asn-keys "(:interaction-trace :traceId \"t1\" :tokensIn 50 :tokensOut 25 :tokSec 10.0)") "camelCase telemetry passes checker")
    true))

(df TestTelemetryLedgerConvergence [] -> Bool
  :d "Verifies all telemetry files in .asl/mem/telemetry conform to camelCase keys"
  (let [(m-res (file-read ".asl/mem/telemetry/mesh-trace.asn"))
        (c-res (file-read ".asl/mem/telemetry/CollisionReduction20260912.asn"))]
    (assert (= (.-_tag m-res) "ok") "mesh-trace.asn must exist")
    (assert (= (.-_tag c-res) "ok") "CollisionReduction20260912.asn must exist")
    (let [(m-src (.-value m-res))
          (c-src (.-value c-res))]
      (assert (km/audit-emitted-asn-keys m-src) "mesh-trace.asn must pass D51 audit")
      (assert (km/audit-emitted-asn-keys c-src) "CollisionReduction20260912.asn must pass D51 audit")
      (assert (string-contains? m-src ":durationMs") "mesh-trace.asn must use :durationMs")
      (assert (not (string-contains? m-src ":duration-ms")) "mesh-trace.asn must not use :duration-ms")
      (assert (string-contains? c-src ":lostWrites") "CollisionReduction20260912.asn must use :lostWrites")
      (assert (not (string-contains? c-src ":lost-writes ")) "CollisionReduction20260912.asn must not use :lost-writes")
      true)))

(df TestWireFramesAndLedgerRecordsKeyStyle [] -> Bool
  :d "Verifies wire frames and ledger records use the identical camelCase key style"
  (let [(frame (w/CanonicalWireFrame
                 :identity "frame-c01"
                 :sessionId "sess-wire-01"
                 :causality "root"
                 :payload "(:action :gate)"
                 :digest "d-wire-01"))
        (wire-str (w/encode-canonical-frame frame))
        (trace-f (mesh/CausalTraceFrame
                   :timestamp 1789439200000
                   :sequence 1
                   :session-id "sess-wire-01"
                   :runtime-target "local"
                   :parent-digest ""
                   :op "gate"
                   :target "asl/tools/asl.c"
                   :status "ok"
                   :digest "d-wire-01"))
        (trace-str (mesh/format-frame-for-reflect trace-f))
        (opts (lc/ModelOptions :model "gemma-4-31b-it" :max-tokens 100 :temperature 0.0 :top-p 1.0))
        (res (lc/CompletionResult :text "ok" :input-tokens 50 :output-tokens 25 :duration-ms 100 :tok-sec 25.0))
        (itrace (tr/record-interaction-trace "t-wire-01" 1789439200000 opts res "ok"))
        (telemetry-str (tr/format-trace-asn itrace))]
    (assert (km/audit-emitted-asn-keys wire-str) "Encoded canonical wire frame must pass D51 audit")
    (assert (string-contains? wire-str ":sessionId \"sess-wire-01\"") "Wire frame must emit :sessionId")
    (assert (km/audit-emitted-asn-keys trace-str) "Mesh trace frame must pass D51 audit")
    (assert (string-contains? trace-str ":sessionId \"sess-wire-01\"") "Mesh trace frame must emit :sessionId")
    (assert (string-contains? trace-str ":durationMs 0") "Mesh trace frame must emit :durationMs")
    (assert (km/audit-emitted-asn-keys telemetry-str) "Interaction trace telemetry must pass D51 audit")
    (assert (string-contains? telemetry-str ":traceId \"t-wire-01\"") "Interaction trace must emit :traceId")
    (assert (string-contains? telemetry-str ":tokensIn 50") "Interaction trace must emit :tokensIn")
    (assert (string-contains? telemetry-str ":tokensOut 25") "Interaction trace must emit :tokensOut")
    (assert (string-contains? telemetry-str ":tokSec 25.0") "Interaction trace must emit :tokSec")
    true))

(df TestGateIntegrationContract [] -> Bool
  :d "Verifies asl/tools/asl.c wires check_d51_convergence and check_emitted_asn_string into gates"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_d51_convergence") "asl.c must declare check_d51_convergence")
      (assert (string-contains? c-src "check_emitted_asn_string") "asl.c must declare check_emitted_asn_string")
      (assert (string-contains? c-src "run_gate_6_grammar") "asl.c must wire checker in run_gate_6_grammar")
      (assert (string-contains? c-src "asl audit naming") "asl.c must implement asl audit naming subcommand")
      true)))

(df TestTask44606GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44606"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Task44606") "Phase 446 must contain Task44606")
      (assert (string-contains? p-src "camelCase across the wire and the ledgers, enforced not asserted") "Phase 446 must state Task44606 title")
      (assert (string-contains? p-src "All emitters produce camelCase keys") "Phase 446 must state camelCase outcome")
      (assert (string-contains? p-src "Checker covers emitted output, not only source") "Phase 446 must state checker outcome")
      (assert (string-contains? p-src "Existing kebab-case telemetry keys migrated with a recorded mapping") "Phase 446 must state migration mapping outcome")
      (assert (string-contains? p-src "SuperviseGate.sh Task44606") "Phase 446 must configure SuperviseGate.sh")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44606 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestKeyMappingRecordedSource) "TestKeyMappingRecordedSource must pass")
    (assert (TestKeyMappingModuleContract) "TestKeyMappingModuleContract must pass")
    (assert (TestKeyMappingBidirectionalTranslation) "TestKeyMappingBidirectionalTranslation must pass")
    (assert (TestCheckerRejectsKebabCaseEmitter) "TestCheckerRejectsKebabCaseEmitter must pass")
    (assert (TestCheckerAcceptsCamelCaseEmitter) "TestCheckerAcceptsCamelCaseEmitter must pass")
    (assert (TestTelemetryLedgerConvergence) "TestTelemetryLedgerConvergence must pass")
    (assert (TestWireFramesAndLedgerRecordsKeyStyle) "TestWireFramesAndLedgerRecordsKeyStyle must pass")
    (assert (TestGateIntegrationContract) "TestGateIntegrationContract must pass")
    (assert (TestTask44606GroundedInPhase446) "TestTask44606GroundedInPhase446 must pass")
    true))
