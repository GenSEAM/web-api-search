(module tests/acceptance/d81/Task-F32
  :d "Acceptance fixture for Task-F32: Unify Core Agent Structs Under Boundary Universalism (C3/D34) under ADR-0081."
  :x [RunTests
      TestUnifiedAgentMessage
      TestUnifiedToolTypes
      TestTaskF32GroundedInPhaseFINSEL]
  :i [(asl-agent-core/types :a ct)
      (asl-agent-bus/types :a bt)
      (asl-agent/types :a at)])

(df TestUnifiedAgentMessage [] -> Bool
  :d "Verifies AgentMessage struct contains unified routing and semantic chat fields across packages"
  (let [(msg (ct/AgentMessage
               :id "msg-001"
               :source "agent-a"
               :target "agent-b"
               :payload "{\"action\":\"sync\"}"
               :timestamp 1789452000000
               :correlation-id "corr-99"
               :role "assistant"
               :content "Processing task item."
               :tool-call-id "call-101"))
        (bus-msg (bt/make-agent-message "msg-002" "sender" "recipient" "hello" 1789452001000 "corr-100" "user" "hello" ""))
        (agent-msg (at/make-agent-message "msg-003" "user-agent" "system" "status" 1789452002000 "corr-101" "system" "status" ""))]
    (assert (= (.-id msg) "msg-001") "AgentMessage id must match")
    (assert (= (.-source msg) "agent-a") "AgentMessage source must match")
    (assert (= (.-target msg) "agent-b") "AgentMessage target must match")
    (assert (= (.-payload msg) "{\"action\":\"sync\"}") "AgentMessage payload must match")
    (assert (= (.-correlation-id msg) "corr-99") "AgentMessage correlation-id must match")
    (assert (= (.-role msg) "assistant") "AgentMessage role must match")
    (assert (= (.-content msg) "Processing task item.") "AgentMessage content must match")
    (assert (= (.-tool-call-id msg) "call-101") "AgentMessage tool-call-id must match")
    (assert (= (.-source bus-msg) "sender") "Bus AgentMessage source must match")
    (assert (= (.-role bus-msg) "user") "Bus AgentMessage role must match")
    (assert (= (.-source agent-msg) "user-agent") "Agent pkg AgentMessage source must match")
    (assert (= (.-role agent-msg) "system") "Agent pkg AgentMessage role must match")
    true))

(df TestUnifiedToolTypes [] -> Bool
  :d "Verifies ToolDef, ToolCall, and ToolResult structs provide canonical interfaces across packages"
  (let [(param (ct/ToolParam :name "file" :type-desc "string" :doc "File path" :required true))
        (tool (ct/ToolDef
                :name "read-file"
                :description "Reads file content"
                :doc "Reads file content from workspace"
                :parameters-spec "{\"type\":\"object\"}"
                :params (list param)))
        (call (ct/ToolCall :id "call-1" :name "read-file" :arguments "{\"file\":\"main.asl\"}"))
        (res (ct/ToolResult
               :call-id "call-1"
               :tool-call-id "call-1"
               :tool-name "read-file"
               :output "file content"
               :payload "file content"
               :ok true
               :is-error false
               :status "OK"))
        (bus-tool (bt/make-tool-def "bus-tool" "Bus tool" "Bus tool doc" "{}" (list param)))
        (agent-res (at/make-tool-result "call-2" "agent-tool" true "agent output" "OK"))]
    (assert (= (.-name tool) "read-file") "ToolDef name must match")
    (assert (= (.-description tool) "Reads file content") "ToolDef description must match")
    (assert (= (.-doc tool) "Reads file content from workspace") "ToolDef doc alias must match")
    (assert (= (list-length (.-params tool)) 1) "ToolDef params length must be 1")
    (assert (= (.-id call) "call-1") "ToolCall id must match")
    (assert (= (.-call-id res) "call-1") "ToolResult call-id must match")
    (assert (= (.-tool-call-id res) "call-1") "ToolResult tool-call-id alias must match")
    (assert (= (.-tool-name res) "read-file") "ToolResult tool-name must match")
    (assert (= (.-output res) "file content") "ToolResult output must match")
    (assert (= (.-payload res) "file content") "ToolResult payload alias must match")
    (assert (.-ok res) "ToolResult ok must be true")
    (assert (not (.-is-error res)) "ToolResult is-error must be false")
    (assert (= (.-name bus-tool) "bus-tool") "Bus ToolDef name must match")
    (assert (.-ok agent-res) "Agent ToolResult ok must be true")
    true))

(df TestTaskF32GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F32 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F32\""))
             (has-title (string-contains? content ":title \"Unify Core Agent Structs Under Boundary Universalism\""))]
         (assert has-id "Task-F32 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F32 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F32"
  (let [(t1 (TestUnifiedAgentMessage))
        (t2 (TestUnifiedToolTypes))
        (t3 (TestTaskF32GroundedInPhaseFINSEL))]
    (and (and t1 t2) t3)))
