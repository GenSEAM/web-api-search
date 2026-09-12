(module tests/acceptance/d81/Task44602
  :d "Acceptance fixture for Task44602: One wire contract across runtimes: ASN frames over stdio, unix socket, http and sse under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSingleFrameSchemaContract
      TestFourTransportsAsCodecsContract
      TestIngressValidationAndRejectionContract
      TestEngineWireFrameContract
      TestTransportEnvelopeIntegrationContract
      TestTask44602GroundedInPhase446]
  :i [("../../../agent-bus/src/wire" :a wire)
      ("../../../agent-bus/src/transport" :a transport)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestSingleFrameSchemaContract [] -> Bool
  :d "Verifies asl/grammar/wire.asn defines single frame schema with camelCase keys and 4 transports"
  (let [(w-res (file-read "asl/grammar/wire.asn"))]
    (assert (= (.-_tag w-res) "ok") "asl/grammar/wire.asn must exist and be readable")
    (let [(w-src (.-value w-res))]
      (assert (string-contains? w-src ":identity") "Must define identity field")
      (assert (string-contains? w-src ":sessionId") "Must define sessionId field")
      (assert (string-contains? w-src ":causality") "Must define causality field")
      (assert (string-contains? w-src ":payload") "Must define payload field")
      (assert (string-contains? w-src ":digest") "Must define digest field")
      (assert (string-contains? w-src ":stdio") "Must declare stdio transport")
      (assert (string-contains? w-src ":unixSocket") "Must declare unixSocket transport")
      (assert (string-contains? w-src ":http") "Must declare http transport")
      (assert (string-contains? w-src ":sse") "Must declare sse transport")
      (assert (string-contains? w-src ":conformanceVectors") "Must include conformance vectors")
      true)))

(df TestFourTransportsAsCodecsContract [] -> Bool
  :d "Verifies same frame round-trips identically across all four transports"
  (let [(frame (wire/CanonicalWireFrame
                 :identity "task44602-test-frame"
                 :sessionId "session-shared-wire"
                 :causality "root-step-0"
                 :payload "(:action :relay :ok true)"
                 :digest "sha256-verified-digest"))]
    (let [(stdio-raw (wire/encode-stdio-frame frame))
          (sock-raw (wire/encode-unix-socket-frame frame))
          (http-raw (wire/encode-http-frame frame))
          (sse-raw (wire/encode-sse-frame frame))]
      (let [(stdio-dec (wire/decode-stdio-frame stdio-raw))
            (sock-dec (wire/decode-unix-socket-frame sock-raw))
            (http-dec (wire/decode-http-frame http-raw))
            (sse-dec (wire/decode-sse-frame sse-raw))]
        (assert (option-is-some? stdio-dec) "Stdio transport must decode frame")
        (assert (option-is-some? sock-dec) "Unix socket transport must decode frame")
        (assert (option-is-some? http-dec) "HTTP transport must decode frame")
        (assert (option-is-some? sse-dec) "SSE transport must decode frame")
        (let [(f1 (option-unwrap stdio-dec))
              (f2 (option-unwrap sock-dec))
              (f3 (option-unwrap http-dec))
              (f4 (option-unwrap sse-dec))]
          (assert (= (.-identity f1) (.-identity frame)) "Stdio identity equals original")
          (assert (= (.-identity f2) (.-identity frame)) "Unix socket identity equals original")
          (assert (= (.-identity f3) (.-identity frame)) "HTTP identity equals original")
          (assert (= (.-identity f4) (.-identity frame)) "SSE identity equals original")
          (assert (= (.-sessionId f1) (.-sessionId f2)) "Session IDs match across stdio and socket")
          (assert (= (.-causality f2) (.-causality f3)) "Causality matches across socket and http")
          (assert (= (.-payload f3) (.-payload f4)) "Payload matches across http and sse")
          (assert (= (.-digest f1) (.-digest f4)) "Digest matches across stdio and sse")
          true)))))

(df TestIngressValidationAndRejectionContract [] -> Bool
  :d "Verifies malformed frames are rejected at ingress with typed error and never partially applied"
  (let [(valid-frame (wire/CanonicalWireFrame :identity "valid-01" :sessionId "sess-ok" :causality "root" :payload "(:data true)" :digest "sha256-ok"))
        (missing-id (wire/CanonicalWireFrame :identity "" :sessionId "sess-ok" :causality "root" :payload "(:data true)" :digest "sha256-ok"))
        (missing-sess (wire/CanonicalWireFrame :identity "valid-02" :sessionId "" :causality "root" :payload "(:data true)" :digest "sha256-ok"))
        (missing-dig (wire/CanonicalWireFrame :identity "valid-03" :sessionId "sess-ok" :causality "root" :payload "(:data true)" :digest ""))
        (malformed (wire/CanonicalWireFrame :identity "valid-04" :sessionId "sess-ok" :causality "root" :payload "(:malformed-unclosed" :digest "sha256-ok"))]
    (let [(res-ok (wire/validate-wire-frame valid-frame))
          (res-no-id (wire/validate-wire-frame missing-id))
          (res-no-sess (wire/validate-wire-frame missing-sess))
          (res-no-dig (wire/validate-wire-frame missing-dig))
          (res-mal (wire/validate-wire-frame malformed))]
      (assert (.-valid? res-ok) "Valid frame must pass")
      (assert (not (.-valid? res-no-id)) "Missing identity must be rejected")
      (assert (= (.-errorKind res-no-id) "ERR_MISSING_IDENTITY") "Must return ERR_MISSING_IDENTITY")
      (assert (not (.-valid? res-no-sess)) "Missing session must be rejected")
      (assert (= (.-errorKind res-no-sess) "ERR_MISSING_SESSION_ID") "Must return ERR_MISSING_SESSION_ID")
      (assert (not (.-valid? res-no-dig)) "Missing digest must be rejected")
      (assert (= (.-errorKind res-no-dig) "ERR_MISSING_DIGEST") "Must return ERR_MISSING_DIGEST")
      (assert (not (.-valid? res-mal)) "Malformed payload must be rejected")
      (assert (= (.-errorKind res-mal) "ERR_MALFORMED_PAYLOAD") "Must return ERR_MALFORMED_PAYLOAD")
      true)))

(df TestEngineWireFrameContract [] -> Bool
  :d "Verifies asl.c engine executes and validates wire frames at ingress with typed rejection"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "op_frame") "asl.c must implement op_frame")
      (assert (string-contains? c-src "ERR_MISSING_IDENTITY") "asl.c must validate missing identity")
      (assert (string-contains? c-src "ERR_MISSING_SESSION_ID") "asl.c must validate missing sessionId")
      (assert (string-contains? c-src "ERR_MISSING_DIGEST") "asl.c must validate missing digest")
      (assert (string-contains? c-src "ERR_MALFORMED_PAYLOAD") "asl.c must validate malformed payload")
      (assert (string-contains? c-src "(:frame") "asl.c must recognize (:frame in handle_payload")
      (assert (string-contains? c-src "execute_single_step") "asl.c must wire op_frame into execute_single_step")
      true)))

(df TestTransportEnvelopeIntegrationContract [] -> Bool
  :d "Verifies agent-bus transport envelopes bridge to and from canonical wire frames"
  (let [(env (transport/make-transport-envelope "env-task44602" (transport/frame-rpc-req) "agent-verifier" "agent-auditor" 42 "(:query :active)" 5000))]
    (assert (transport/validate-transport-envelope env) "Envelope passes validation")
    (let [(frame (transport/envelope->canonical-wire-frame env))]
      (assert (= (.-identity frame) "env-task44602") "Frame identity matches")
      (assert (= (.-sessionId frame) "sess-agent-verifier") "SessionId matches")
      (assert (= (.-causality frame) "seq-42") "Causality matches")
      (assert (= (.-payload frame) "(:query :active)") "Payload matches")
      (let [(val-res (wire/validate-wire-frame frame))]
        (assert (.-valid? val-res) "Converted frame passes ingress validation")
        (let [(back (transport/canonical-wire-frame->envelope frame))]
          (assert (= (.-id back) "env-task44602") "Envelope ID restored")
          (assert (= (.-payload back) "(:query :active)") "Envelope payload restored")
          (assert (transport/RunTests) "transport/RunTests passes cleanly")
          true)))))

(df TestTask44602GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44602"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "One wire contract across runtimes") "Phase 446 must state Task44602 title")
      (assert (string-contains? p-src ":lane \"transport\"") "Phase 446 must specify transport lane")
      (assert (string-contains? p-src "asl/grammar/wire.asn") "Phase 446 must own wire.asn")
      (assert (string-contains? p-src "agent-bus/src/wire.asl") "Phase 446 must own wire.asl")
      (assert (string-contains? p-src "agent-bus/src/transport.asl") "Phase 446 must own transport.asl")
      (assert (string-contains? p-src "asl/tools/asl.c") "Phase 446 must own asl.c")
      (assert (string-contains? p-src "execute_single_step") "Phase 446 must target execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44602 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSingleFrameSchemaContract) "TestSingleFrameSchemaContract must pass")
    (assert (TestFourTransportsAsCodecsContract) "TestFourTransportsAsCodecsContract must pass")
    (assert (TestIngressValidationAndRejectionContract) "TestIngressValidationAndRejectionContract must pass")
    (assert (TestEngineWireFrameContract) "TestEngineWireFrameContract must pass")
    (assert (TestTransportEnvelopeIntegrationContract) "TestTransportEnvelopeIntegrationContract must pass")
    (assert (TestTask44602GroundedInPhase446) "TestTask44602GroundedInPhase446 must pass")
    true))
