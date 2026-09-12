(module tests/acceptance/d81/Task44605
  :d "Acceptance fixture for Task44605: In-browser runtime with OPFS boundary policy, capability registry, and mesh trace integration."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTask44605GroundedInPhase446
      TestOpfsWorkspaceBoundaryAllowedPaths
      TestOpfsWorkspaceBoundaryEscapeRejection
      TestBrowserCapabilityRegistryReporting
      TestBrowserWasmEngineExecutionAndRejection
      TestBrowserRuntimeEmitsMeshFrames
      TestBrowserTraceMergesIntoCrossRuntimeMesh
      TestAslNativeDoctorBrowserRuntimeReporting]
  :i [("../../../browser-plugin/src/runtime" :a bpr)
      ("../../../agent-bus/src/browser-bridge" :a bridge)
      ("../../../agent-bus/src/mesh" :a mesh)])

(df TestOpfsWorkspaceBoundaryAllowedPaths [] -> Bool
  :d "Verifies legitimate relative and OPFS-rooted paths are allowed within OPFS workspace"
  (let [(root "opfs://workspace")
        (safe-rel-1 (bpr/is-safe-opfs-path? root "src/main.asl"))
        (safe-rel-2 (bpr/is-safe-opfs-path? root "index.html"))
        (safe-abs-1 (bpr/is-safe-opfs-path? root "opfs://workspace/src/main.asl"))
        (safe-abs-2 (bpr/is-safe-opfs-path? root "opfs://workspace"))
        (safe-bridge-1 (bridge/is-bridge-opfs-path-safe? root "src/main.asl"))
        (safe-bridge-2 (bridge/is-bridge-opfs-path-safe? root "opfs://workspace/data/store.asn"))]
    (assert safe-rel-1 "Relative path inside OPFS workspace must be permitted")
    (assert safe-rel-2 "Root file inside OPFS workspace must be permitted")
    (assert safe-abs-1 "Fully-qualified matching OPFS URI must be permitted")
    (assert safe-abs-2 "Root OPFS URI must be permitted")
    (assert safe-bridge-1 "Bridge must permit relative OPFS path")
    (assert safe-bridge-2 "Bridge must permit matching OPFS URI")
    true))

(df TestOpfsWorkspaceBoundaryEscapeRejection [] -> Bool
  :d "Verifies paths escaping OPFS workspace are rejected by the boundary policy"
  (let [(root "opfs://workspace")
        (esc-posix-1 (bpr/is-safe-opfs-path? root "/etc/passwd"))
        (esc-posix-2 (bpr/is-safe-opfs-path? root "/var/log/system.log"))
        (esc-traversal-1 (bpr/is-safe-opfs-path? root "../outside.txt"))
        (esc-traversal-2 (bpr/is-safe-opfs-path? root "src/../../secret.key"))
        (esc-alien-root (bpr/is-safe-opfs-path? root "opfs://alien-workspace/leak.txt"))
        (bridge-posix (bridge/is-bridge-opfs-path-safe? root "/bin/sh"))
        (bridge-traversal (bridge/is-bridge-opfs-path-safe? root "../config.json"))
        (bridge-alien (bridge/is-bridge-opfs-path-safe? root "opfs://other/store.asn"))]
    (assert (not esc-posix-1) "Host POSIX absolute path /etc/passwd must be rejected")
    (assert (not esc-posix-2) "Host POSIX absolute path /var/log must be rejected")
    (assert (not esc-traversal-1) "Parent directory traversal must be rejected")
    (assert (not esc-traversal-2) "Multi-level directory traversal escape must be rejected")
    (assert (not esc-alien-root) "Alien OPFS root URI must be rejected")
    (assert (not bridge-posix) "Bridge must reject POSIX absolute path")
    (assert (not bridge-traversal) "Bridge must reject directory traversal")
    (assert (not bridge-alien) "Bridge must reject alien OPFS root URI")
    true))

(df TestBrowserCapabilityRegistryReporting [] -> Bool
  :d "Verifies capability registry reports works for browser capabilities and named fallbacks for absent capabilities"
  (let [(cap-path (bpr/query-browser-capability "pathBoundary"))
        (cap-wasm (bpr/query-browser-capability "wasmBatchRpc"))
        (cap-vdom (bpr/query-browser-capability "vdomRender"))
        (cap-ast (bpr/query-browser-capability "astParse"))
        (cap-cmd (bpr/query-browser-capability "runCommand"))
        (cap-proc (bpr/query-browser-capability "procSpawn"))
        (cap-net (bpr/query-browser-capability "netSocket"))
        (cap-fs (bpr/query-browser-capability "nativeFs"))
        (bridge-cmd (bridge/query-browser-bridge-capability "runCommand"))
        (bridge-net (bridge/query-browser-bridge-capability "netSocket"))
        (bridge-fs (bridge/query-browser-bridge-capability "nativeFs"))]
    (assert (is-some? cap-path) "pathBoundary capability must be reported")
    (assert (is-some? cap-wasm) "wasmBatchRpc capability must be reported")
    (assert (is-some? cap-vdom) "vdomRender capability must be reported")
    (assert (is-some? cap-ast) "astParse capability must be reported")
    (assert (is-some? cap-cmd) "runCommand capability must be reported")
    (assert (is-some? cap-proc) "procSpawn capability must be reported")
    (assert (is-some? cap-net) "netSocket capability must be reported")
    (assert (is-some? cap-fs) "nativeFs capability must be reported")
    (mt cap-path
      ((none) false)
      ((some c)
       (assert (= (.-status c) "works") "pathBoundary status must be works")
       (mt cap-cmd
         ((none) false)
         ((some cmd)
          (assert (= (.-status cmd) "absent") "runCommand status must be absent")
          (assert (string-contains? (.-fallback cmd) "delegate to local or relay runtime") "runCommand fallback must name delegation")
          (mt cap-net
            ((none) false)
            ((some net)
             (assert (= (.-status net) "absent") "netSocket status must be absent")
             (assert (string-contains? (.-fallback net) "browser-bridge") "netSocket fallback must name browser-bridge")
             (mt cap-fs
               ((none) false)
               ((some fs)
                (assert (= (.-status fs) "absent") "nativeFs status must be absent")
                (assert (string-contains? (.-fallback fs) "OPFS workspace") "nativeFs fallback must name OPFS workspace")
                (mt bridge-cmd
                  ((none) false)
                  ((some fb-cmd)
                   (assert (string-contains? fb-cmd "delegate to local or relay") "Bridge runCommand fallback matches")
                   (mt bridge-net
                     ((none) false)
                     ((some fb-net)
                      (assert (string-contains? fb-net "browser-bridge") "Bridge netSocket fallback matches")
                      (mt bridge-fs
                        ((none) false)
                        ((some fb-fs)
                         (assert (string-contains? fb-fs "OPFS workspace") "Bridge nativeFs fallback matches")
                         true))))))))))))))))

(df TestBrowserWasmEngineExecutionAndRejection [] -> Bool
  :d "Verifies in-browser wasm engine executes steps over OPFS and rejects boundary escapes"
  (let [(ws (bpr/make-opfs-workspace "opfs://workspace" 67108864))
        (bridge-rpc (bpr/make-wasm-rpc-bridge "asl_wasm_engine" 1048576))
        (engine (bpr/make-browser-wasm-engine "asl_wasm_engine" ws bridge-rpc "sess-browser-01"))
        (step-ok (bpr/dispatch-browser-wasm-step engine "read" "src/app.asl" ""))
        (step-esc (bpr/dispatch-browser-wasm-step engine "write" "/etc/passwd" "malicious"))
        (step-trav (bpr/dispatch-browser-wasm-step engine "edit" "../outside.asl" "patch"))]
    (assert (= (.-module-name engine) "asl_wasm_engine") "Engine module name matches")
    (assert (= (.-active-session-id engine) "sess-browser-01") "Session id matches")
    (assert (string-contains? step-ok ":status \"completed\"") "Legitimate step in OPFS must succeed")
    (assert (string-contains? step-esc ":ERR_BOUNDARY_VIOLATION") "Escaping POSIX path must be rejected with ERR_BOUNDARY_VIOLATION")
    (assert (string-contains? step-trav ":ERR_BOUNDARY_VIOLATION") "Directory traversal escape must be rejected with ERR_BOUNDARY_VIOLATION")
    true))

(df TestBrowserRuntimeEmitsMeshFrames [] -> Bool
  :d "Verifies browser runtime emits frames carrying runtime-target browser"
  (let [(f1 (bpr/make-browser-trace-frame "f-b01" "sess-cross-01" "browser-agent" "" 1 10 1789439500000 "read" "src/view.asl" "ok" "d-b01"))
        (f2 (bridge/emit-browser-trace-frame "f-b02" "sess-cross-01" "browser-agent" "d-b01" 2 20 1789439501000 "vdom" "src/view.asl" "ok" "d-b02"))]
    (assert (= (.-runtime-target f1) "browser") "Runtime target of f1 must be browser")
    (assert (= (.-frame-id f1) "f-b01") "Frame id f1 must match")
    (assert (= (.-session-id f1) "sess-cross-01") "Session id f1 must match")
    (assert (= (.-sequence f1) 1) "Sequence f1 must be 1")
    (assert (= (.-causal-clock f1) 10) "Causal clock f1 must be 10")
    (assert (= (.-runtime-target f2) "browser") "Runtime target of f2 must be browser")
    (assert (= (.-frame-id f2) "f-b02") "Frame id f2 must match")
    (assert (= (.-parent-digest f2) "d-b01") "Parent digest f2 must be d-b01")
    (assert (= (.-sequence f2) 2) "Sequence f2 must be 2")
    (assert (= (.-causal-clock f2) 20) "Causal clock f2 must be 20")
    true))

(df TestBrowserTraceMergesIntoCrossRuntimeMesh [] -> Bool
  :d "Verifies browser frames merge cleanly into cross-runtime mesh trace spanning local, server, relay and browser"
  (let [(fb1 (bridge/emit-browser-trace-frame "fb-1" "sess-mesh-all" "browser-worker" "" 1 1 1000 "read" "opfs://workspace/src/ui.asl" "ok" "d-b1"))
        (fl1 (mesh/make-causal-trace-frame "fl-1" "sess-mesh-all" "local" "local-runner" "d-b1" 1 2 2000 "compile" "src/ui.asl" "ok" "d-l1"))
        (fs1 (mesh/make-causal-trace-frame "fs-1" "sess-mesh-all" "server" "server-worker" "d-l1" 1 3 3000 "test" "src/ui_test.asl" "ok" "d-s1"))
        (fr1 (mesh/make-causal-trace-frame "fr-1" "sess-mesh-all" "relay" "relay-hub" "d-s1" 1 4 4000 "publish" "pkg/ui.tar" "ok" "d-r1"))
        (merged (mesh/merge-mesh-traces (list (list fs1 fb1 fr1 fl1))))
        (frames (.-frames merged))
        (gaps (.-gaps merged))
        (text (mesh/format-mesh-trace-for-reflect merged))]
    (assert (= (.-total-frames merged) 4) "Merged trace total frames must be 4")
    (assert (= (list-length frames) 4) "Merged trace must contain all 4 frames")
    (assert (= (.-gap-count merged) 0) "Contiguous causal trace must have 0 gaps")
    (let [(first-f (option-or (list-head frames) (mesh/empty-causal-trace-frame)))
          (last-f (option-or (list-head (list-reverse frames)) (mesh/empty-causal-trace-frame)))]
      (assert (= (.-frame-id first-f) "fb-1") "First causal frame must be browser frame fb-1")
      (assert (= (.-runtime-target first-f) "browser") "First frame runtime target must be browser")
      (assert (= (.-frame-id last-f) "fr-1") "Last causal frame must be relay frame fr-1")
      (assert (string-contains? text "(:trace-entry") "Formatted trace must contain :trace-entry header")
      (assert (string-contains? text ":runtimeTarget \"browser\"") "Formatted trace must reflect browser runtime")
      (assert (string-contains? text ":runtimeTarget \"relay\"") "Formatted trace must reflect relay runtime")
      true)))

(df TestAslNativeDoctorBrowserRuntimeReporting [] -> Bool
  :d "Verifies native engine supports opfs path checking and reports browser runtime capabilities via doctor"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "opfs://") "is_safe_path must support opfs://")
      (assert (string-contains? c-src "--runtime=browser") "run_doctor must handle --runtime=browser switch")
      (assert (string-contains? c-src "pathBoundary") "doctor must report pathBoundary on opfs")
      (assert (string-contains? c-src "wasmBatchRpc") "doctor must report wasmBatchRpc with zeroSocket")
      (assert (string-contains? c-src "runCommand") "doctor must report runCommand absent with fallback")
      (assert (string-contains? c-src "nativeFs") "doctor must report nativeFs absent with fallback")
      true)))

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTask44605GroundedInPhase446 [] -> Bool
  :d "Verifies Phase 446 task collection grounds Task44605"
  (let [(p-res (file-read ".asl/mem/tasks/Phase446MultiRuntimeRelayAndObservability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 446 tasks file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "In-browser runtime: wasm engine with OPFS-backed workspace") "Must contain Task44605 title")
      (assert (string-contains? p-src ":lane \"browser\"") "Must specify browser lane")
      (assert (string-contains? p-src "browser-plugin/src") "Must own browser-plugin/src")
      (assert (string-contains? p-src "agent-bus/src/browser-bridge.asl") "Must own browser-bridge.asl")
      (assert (string-contains? p-src "asl/tools/asl.c") "Must own asl.c")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44605 supervisor acceptance test cases"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTask44605GroundedInPhase446) "TestTask44605GroundedInPhase446 must pass")
    (assert (TestOpfsWorkspaceBoundaryAllowedPaths) "TestOpfsWorkspaceBoundaryAllowedPaths must pass")
    (assert (TestOpfsWorkspaceBoundaryEscapeRejection) "TestOpfsWorkspaceBoundaryEscapeRejection must pass")
    (assert (TestBrowserCapabilityRegistryReporting) "TestBrowserCapabilityRegistryReporting must pass")
    (assert (TestBrowserWasmEngineExecutionAndRejection) "TestBrowserWasmEngineExecutionAndRejection must pass")
    (assert (TestBrowserRuntimeEmitsMeshFrames) "TestBrowserRuntimeEmitsMeshFrames must pass")
    (assert (TestBrowserTraceMergesIntoCrossRuntimeMesh) "TestBrowserTraceMergesIntoCrossRuntimeMesh must pass")
    (assert (TestAslNativeDoctorBrowserRuntimeReporting) "TestAslNativeDoctorBrowserRuntimeReporting must pass")
    true))
