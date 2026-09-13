(module tests/acceptance/d81/Task48601
  :d "Acceptance fixture for Task48601: Multi-Model Mesh Protocol and Defect Taxonomy Schema under D85."
  :x [run-tests
      test-mesh-grammar-exists
      test-mesh-worker-and-defect-schemas
      test-consensus-receipt-and-taxonomy-schemas
      test-target-symbols-declared]
  :i [])

(df test-mesh-grammar-exists [] -> Bool
  :d "Verifies that asl/grammar/mesh.asn exists and is readable"
  (let [(res (file-read "asl/grammar/mesh.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/mesh.asn must exist and be readable")
    true))

(df test-mesh-worker-and-defect-schemas [] -> Bool
  :d "Verifies that meshWorker and defectRecord schemas are defined in mesh.asn"
  (let [(res (file-read "asl/grammar/mesh.asn"))]
    (assert (= (.-_tag res) "ok") "mesh.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "meshWorker") "meshWorker schema defined")
      (assert (string-contains? src "defectRecord") "defectRecord schema defined")
      (assert (string-contains? src ":workerId") "workerId field defined")
      (assert (string-contains? src ":partitionScope") "partitionScope field defined")
      (assert (string-contains? src ":severity") "severity field defined")
      true)))

(df test-consensus-receipt-and-taxonomy-schemas [] -> Bool
  :d "Verifies that consensusReceipt and defectTaxonomy schemas are defined in mesh.asn"
  (let [(res (file-read "asl/grammar/mesh.asn"))]
    (assert (= (.-_tag res) "ok") "mesh.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "consensusReceipt") "consensusReceipt schema defined")
      (assert (string-contains? src "defectTaxonomy") "defectTaxonomy schema defined")
      (assert (string-contains? src "syntax-malformation") "syntax-malformation category defined")
      (assert (string-contains? src "boundary-violation") "boundary-violation category defined")
      true)))

(df test-target-symbols-declared [] -> Bool
  :d "Verifies that target and related symbols are declared in mesh.asn"
  (let [(res (file-read "asl/grammar/mesh.asn"))]
    (assert (= (.-_tag res) "ok") "mesh.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "mesh_protocol_schema") "mesh_protocol_schema declared")
      (assert (string-contains? src "defect_taxonomy") "defect_taxonomy declared")
      (assert (string-contains? src "consensus_receipt") "consensus_receipt declared")
      (assert (string-contains? src "worker_spec") "worker_spec declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48601 acceptance assertions"
  (let [(r1 (test-mesh-grammar-exists))
        (r2 (test-mesh-worker-and-defect-schemas))
        (r3 (test-consensus-receipt-and-taxonomy-schemas))
        (r4 (test-target-symbols-declared))]
    (assert (and (and (and r1 r2) r3) r4) "All Task48601 checks must pass")
    true))
