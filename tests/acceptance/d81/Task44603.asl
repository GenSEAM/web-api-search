(module tests/acceptance/d81/Task44603
  :d "Acceptance fixture for Task44603: Cross-runtime observability with causal trace across runtimes."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTask44603GroundedInPhase446
      TestCausalTraceFrameCreation
      TestClockSkewCausalPrecedence
      TestSequenceGapDetection
      TestMissingParentDigestDetection
      TestMultiRuntimeInterleavedMesh
      TestFormatMeshTraceForReflect
      TestPeerTraceAttachmentInPresence
      TestAslRpcMeshTraceExecution]
  :i [("../../../agent-bus/src/mesh" :a mesh)
      ("../../../agent-bus/src/presence" :a presence)])

(df TestCausalTraceFrameCreation [] -> Bool
  :d "Verifies creation and field projection of CausalTraceFrame"
  (let [(f (mesh/make-causal-trace-frame
             "frm-101"
             "sess-mesh-alpha"
             "browser"
             "agent-scout"
             "digest-parent-00"
             1
             10
             1789439200000
             "read"
             "agent-bus/src/wire.asl"
             "ok"
             "digest-frm-101"))]
    (assert (= (.-frame-id f) "frm-101") "frame-id must match")
    (assert (= (.-session-id f) "sess-mesh-alpha") "session-id must match")
    (assert (= (.-runtime-target f) "browser") "runtime-target must match")
    (assert (= (.-sender-id f) "agent-scout") "sender-id must match")
    (assert (= (.-parent-digest f) "digest-parent-00") "parent-digest must match")
    (assert (= (.-sequence f) 1) "sequence must match")
    (assert (= (.-causal-clock f) 10) "causal-clock must match")
    (assert (= (.-timestamp f) 1789439200000) "timestamp must match")
    (assert (= (.-op f) "read") "op must match")
    (assert (= (.-target f) "agent-bus/src/wire.asl") "target must match")
    (assert (= (.-status f) "ok") "status must match")
    (assert (= (.-digest f) "digest-frm-101") "digest must match")
    true))

(df TestClockSkewCausalPrecedence [] -> Bool
  :d "Verifies that causal links override clock skew when merging traces from different runtimes"
  (let [(frame-a (mesh/make-causal-trace-frame
                   "frm-a"
                   "sess-skew"
                   "browser"
                   "browser-agent"
                   ""
                   1
                   1
                   9999000
                   "read"
                   "agent-bus/src/wire.asl"
                   "ok"
                   "digest-a"))
        (frame-b (mesh/make-causal-trace-frame
                   "frm-b"
                   "sess-skew"
                   "server"
                   "server-agent"
                   "digest-a"
                   1
                   2
                   1111000
                   "write"
                   "agent-bus/src/mesh.asl"
                   "ok"
                   "digest-b"))]
    (assert (> (.-timestamp frame-a) (.-timestamp frame-b)) "clock skew simulated: frame-a timestamp is greater")
    (assert (mesh/frame-causally-precedes? frame-a frame-b) "frame-a must causally precede frame-b because frame-b depends on digest-a")
    (assert (not (mesh/frame-causally-precedes? frame-b frame-a)) "frame-b must not precede frame-a")
    (let [(merged (mesh/merge-mesh-traces (list (list frame-b) (list frame-a))))
          (frames (.-frames merged))]
      (assert (= (list-length frames) 2) "merged trace must contain exactly two frames")
      (assert (= (.-total-frames merged) 2) "total-frames must report 2")
      (assert (= (.-gap-count merged) 0) "clean dependency must have zero gaps")
      (let [(first-f (option-or (list-head frames) (mesh/empty-causal-trace-frame)))
            (tail-list (option-or (list-tail frames) (list)))
            (second-f (option-or (list-head tail-list) (mesh/empty-causal-trace-frame)))]
        (assert (= (.-frame-id first-f) "frm-a") "frame-a must precede frame-b despite clock skew")
        (assert (= (.-frame-id second-f) "frm-b") "frame-b must follow frame-a")
        true))))

(df TestSequenceGapDetection [] -> Bool
  :d "Verifies explicit reporting of dropped frames without silent renumbering"
  (let [(frame-1 (mesh/make-causal-trace-frame
                   "frm-s1"
                   "sess-gap"
                   "server"
                   "server-worker"
                   ""
                   1
                   1
                   1000
                   "read"
                   "agent-bus/src/wire.asl"
                   "ok"
                   "digest-s1"))
        (frame-3 (mesh/make-causal-trace-frame
                   "frm-s3"
                   "sess-gap"
                   "server"
                   "server-worker"
                   "digest-s1"
                   3
                   3
                   3000
                   "write"
                   "agent-bus/src/mesh.asl"
                   "ok"
                   "digest-s3"))
        (merged (mesh/merge-mesh-traces (list (list frame-1 frame-3))))]
    (assert (= (.-total-frames merged) 2) "total frames is 2")
    (assert (= (.-gap-count merged) 1) "gap-count must detect dropped sequence 2")
    (let [(gaps (.-gaps merged))]
      (assert (= (list-length gaps) 1) "gaps list has 1 entry")
      (let [(gap (option-or (list-head gaps) (mesh/make-causal-trace-gap "" "" 0 0 "")))]
        (assert (= (.-session-id gap) "sess-gap") "gap session matches")
        (assert (= (.-runtime-target gap) "server") "gap runtime matches")
        (assert (= (.-expected-sequence gap) 2) "expected sequence was 2")
        (assert (= (.-found-sequence gap) 3) "found sequence was 3")
        (assert (= (.-reason gap) "sequence-gap-detected") "reason is sequence-gap-detected")
        true))))

(df TestMissingParentDigestDetection [] -> Bool
  :d "Verifies detection of missing causal parent digest reference"
  (let [(orphan-frame (mesh/make-causal-trace-frame
                        "frm-orphan"
                        "sess-orphan"
                        "relay"
                        "relay-proxy"
                        "non-existent-parent-sha"
                        1
                        1
                        2000
                        "route"
                        "agent-bus/src/wire.asl"
                        "ok"
                        "digest-orphan"))
        (merged (mesh/merge-mesh-traces (list (list orphan-frame))))]
    (assert (= (.-total-frames merged) 1) "total-frames is 1")
    (assert (= (.-gap-count merged) 1) "gap-count must report missing parent")
    (let [(gap (option-or (list-head (.-gaps merged)) (mesh/make-causal-trace-gap "" "" 0 0 "")))]
      (assert (= (.-session-id gap) "sess-orphan") "gap session-id matches")
      (assert (= (.-runtime-target gap) "relay") "gap runtime-target matches")
      (assert (= (.-reason gap) "missing-parent-digest-non-existent-parent-sha") "gap reason names missing digest")
      true)))

(df TestMultiRuntimeInterleavedMesh [] -> Bool
  :d "Verifies four-runtime interleaved causal trace merging across browser, local, server and relay"
  (let [(f-browser-1 (mesh/make-causal-trace-frame "f-b1" "sess-4rt" "browser" "client" "" 1 1 5000 "read" "agent-bus/src/wire.asl" "ok" "d-b1"))
        (f-server-1 (mesh/make-causal-trace-frame "f-s1" "sess-4rt" "server" "srv" "d-b1" 1 2 2000 "write" "agent-bus/src/mesh.asl" "ok" "d-s1"))
        (f-relay-1 (mesh/make-causal-trace-frame "f-r1" "sess-4rt" "relay" "rly" "d-s1" 1 3 3000 "route" "agent-bus/src/wire.asl" "ok" "d-r1"))
        (f-local-1 (mesh/make-causal-trace-frame "f-l1" "sess-4rt" "local" "eng" "d-r1" 1 4 4000 "gate" "asl/tools/asl.c" "ok" "d-l1"))
        (f-browser-2 (mesh/make-causal-trace-frame "f-b2" "sess-4rt" "browser" "client" "d-l1" 2 5 6000 "read" "agent-bus/src/presence.asl" "ok" "d-b2"))
        (f-server-2 (mesh/make-causal-trace-frame "f-s2" "sess-4rt" "server" "srv" "d-b2" 2 6 1500 "edit" "agent-bus/src/presence.asl" "ok" "d-s2"))
        (merged (mesh/merge-mesh-traces (list (list f-server-2 f-browser-2)
                                              (list f-local-1 f-relay-1)
                                              (list f-server-1 f-browser-1))))
        (frames (.-frames merged))]
    (assert (= (.-total-frames merged) 6) "total frames is 6")
    (assert (= (.-gap-count merged) 0) "zero gaps across complete causal mesh chain")
    (let [(f1 (option-or (list-head frames) (mesh/empty-causal-trace-frame)))
          (t1 (option-or (list-tail frames) (list)))
          (f2 (option-or (list-head t1) (mesh/empty-causal-trace-frame)))
          (t2 (option-or (list-tail t1) (list)))
          (f3 (option-or (list-head t2) (mesh/empty-causal-trace-frame)))
          (t3 (option-or (list-tail t2) (list)))
          (f4 (option-or (list-head t3) (mesh/empty-causal-trace-frame)))
          (t4 (option-or (list-tail t3) (list)))
          (f5 (option-or (list-head t4) (mesh/empty-causal-trace-frame)))
          (t5 (option-or (list-tail t4) (list)))
          (f6 (option-or (list-head t5) (mesh/empty-causal-trace-frame)))]
      (assert (= (.-frame-id f1) "f-b1") "f-b1 first in causal chain")
      (assert (= (.-frame-id f2) "f-s1") "f-s1 second in causal chain")
      (assert (= (.-frame-id f3) "f-r1") "f-r1 third in causal chain")
      (assert (= (.-frame-id f4) "f-l1") "f-l1 fourth in causal chain")
      (assert (= (.-frame-id f5) "f-b2") "f-b2 fifth in causal chain")
      (assert (= (.-frame-id f6) "f-s2") "f-s2 sixth in causal chain")
      true)))

(df TestFormatMeshTraceForReflect [] -> Bool
  :d "Verifies formatted mesh trace compatibility with asl reflect S-expression ingestion"
  (let [(f1 (mesh/make-causal-trace-frame "f-fmt-1" "sess-fmt" "browser" "node1" "" 1 1 1000 "read" "agent-bus/src/wire.asl" "ok" "d-fmt-1"))
        (f2 (mesh/make-causal-trace-frame "f-fmt-2" "sess-fmt" "server" "node2" "d-fmt-1" 1 2 1100 "write" "agent-bus/src/mesh.asl" "ok" "d-fmt-2"))
        (merged (mesh/merge-mesh-traces (list (list f1 f2))))
        (formatted (mesh/format-mesh-trace-for-reflect merged))]
    (assert (string-contains? formatted "(:trace-entry") "output contains trace-entry header")
    (assert (string-contains? formatted ":sessionId \"sess-fmt\"") "output contains sessionId")
    (assert (string-contains? formatted ":runtimeTarget \"browser\"") "output contains browser runtimeTarget")
    (assert (string-contains? formatted ":runtimeTarget \"server\"") "output contains server runtimeTarget")
    (assert (string-contains? formatted ":parentDigest \"d-fmt-1\"") "output contains parentDigest")
    (assert (string-contains? formatted ":op \"write\"") "output contains write op")
    (assert (string-contains? formatted ":target \"agent-bus/src/mesh.asl\"") "output contains target path")
    true))

(df TestPeerTraceAttachmentInPresence [] -> Bool
  :d "Verifies peer trace attachment packaging in swarm room presence"
  (let [(f (mesh/make-causal-trace-frame "f-att" "sess-att" "browser" "agent-1" "" 1 1 1000 "read" "agent-bus/src/wire.asl" "ok" "d-att"))
        (att (presence/make-peer-trace-attachment "peer-worker-1" "sess-att" "browser" (list f)))]
    (assert (= (.-peer-id att) "peer-worker-1") "peer-id matches")
    (assert (= (.-session-id att) "sess-att") "session-id matches")
    (assert (= (.-runtime-target att) "browser") "runtime-target matches")
    (assert (= (list-length (.-trace-frames att)) 1) "trace-frames count is 1")
    true))

(df TestAslRpcMeshTraceExecution [] -> Bool
  :d "Verifies telemetry storage and RPC mesh trace query execution"
  (let [(read-res (file-read ".asl/mem/telemetry/mesh-trace.asn"))]
    (assert (= (.-_tag read-res) "ok") "mesh-trace.asn file exists and is readable")
    (let [(content (.-value read-res))]
      (assert (string-contains? content ":meshTraceTelemetry") "telemetry header present")
      (assert (string-contains? content "\"browser\" \"local\" \"server\" \"relay\"") "all four runtimes present")
      (assert (string-contains? content "mesh-sess-01") "session identifier present")
      (assert (string-contains? content "d-browser-01") "browser digest present")
      (assert (string-contains? content "d-server-01") "server digest present")
      (assert (string-contains? content ":seq 3") "sequence gap vector present")
      true)))

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTask44603GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44603"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Cross-runtime observability: one trace spanning") "Phase 446 must state Task44603 title")
      (assert (string-contains? p-src ":lane \"observability\"") "Phase 446 must specify observability lane")
      (assert (string-contains? p-src "agent-bus/src/mesh.asl") "Phase 446 must own mesh.asl")
      (assert (string-contains? p-src "agent-bus/src/presence.asl") "Phase 446 must own presence.asl")
      (assert (string-contains? p-src "asl/tools/asl.c") "Phase 446 must own asl.c")
      (assert (string-contains? p-src ".asl/mem/telemetry") "Phase 446 must own telemetry")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44603 supervisor acceptance test cases"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTask44603GroundedInPhase446) "TestTask44603GroundedInPhase446 must pass")
    (assert (TestCausalTraceFrameCreation) "TestCausalTraceFrameCreation must pass")
    (assert (TestClockSkewCausalPrecedence) "TestClockSkewCausalPrecedence must pass")
    (assert (TestSequenceGapDetection) "TestSequenceGapDetection must pass")
    (assert (TestMissingParentDigestDetection) "TestMissingParentDigestDetection must pass")
    (assert (TestMultiRuntimeInterleavedMesh) "TestMultiRuntimeInterleavedMesh must pass")
    (assert (TestFormatMeshTraceForReflect) "TestFormatMeshTraceForReflect must pass")
    (assert (TestPeerTraceAttachmentInPresence) "TestPeerTraceAttachmentInPresence must pass")
    (assert (TestAslRpcMeshTraceExecution) "TestAslRpcMeshTraceExecution must pass")
    true))
