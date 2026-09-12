(module tests/acceptance/d81/Task46903
  :d "Acceptance fixture for Task46903: room residency decision, single-agent zero overhead, and daemonless mesh."
  :x [RunTests
      TestResidencyDecisionRecorded
      TestProtocolConformanceDeclared
      TestMeshLifecycleDefined]
  :i [])

(df TestResidencyDecisionRecorded [] -> Bool
  :d "Verifies that .asl/mem/decisions records architectural choice on room residency and rejected daemon"
  (let [(res (file-read ".asl/mem/decisions.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/decisions.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "residency") (string-contains? src "daemon") (string-contains? src "swarm-room"))
              "decisions.asn must reference swarm room residency decision")
      true)))

(df TestProtocolConformanceDeclared [] -> Bool
  :d "Verifies that asl/grammar/protocol-conformance.asn declares swarm residency requirements"
  (let [(res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/protocol-conformance.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "swarm") (string-contains? src "presence") (string-contains? src "residency"))
              "protocol-conformance.asn must declare swarm or presence protocol conformance")
      true)))

(df TestMeshLifecycleDefined [] -> Bool
  :d "Verifies that agent-bus/src/mesh.asl exists and exports mesh cluster functions"
  (let [(res (file-read "agent-bus/src/mesh.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/src/mesh.asl must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "AgentMeshNode") "mesh.asl must declare AgentMeshNode")
      (assert (string-contains? src "join-mesh-cluster") "mesh.asl must declare join-mesh-cluster")
      true)))

(df RunTests [] -> Bool
  (and (TestResidencyDecisionRecorded)
       (TestProtocolConformanceDeclared)
       (TestMeshLifecycleDefined)))
