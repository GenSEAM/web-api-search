(module tests/acceptance/d81/Task44103
  :d "Acceptance fixture for Task44103: Bound total retrieval and preserve snapshot-consistent continuation under ADR-0081."
  :x [RunTests
      TestSessionContractBoundedRetrievalRule
      TestProtocolConformanceBoundedRetrievalContract
      TestReadingOperationsDeclaredInRpcRegistry
      TestPathBoundaryAndHiddenPathProtection]
  :i [])

(df TestSessionContractBoundedRetrievalRule [] -> Bool
  :d "Verifies that session-contract.asn declares boundedRetrieval and continuationSchema"
  (let [(s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "session-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":rule :id boundedRetrieval") "Must define boundedRetrieval rule")
      (assert (string-contains? src ":continuationSchema [") "Must define continuationSchema")
      (assert (string-contains? src ":field :id \"cursor\"") "Must bind cursor field")
      (assert (string-contains? src ":field :id \"sessionId\"") "Must bind sessionId field")
      (assert (string-contains? src ":field :id \"snapshotDigest\"") "Must bind snapshotDigest field")
      (assert (string-contains? src ":field :id \"hasMore\"") "Must bind hasMore field")
      (assert (string-contains? src ":field :id \"budgetRemaining\"") "Must bind budgetRemaining field")
      true)))

(df TestProtocolConformanceBoundedRetrievalContract [] -> Bool
  :d "Verifies that protocol-conformance.asn defines boundedRetrieval contract"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist and be readable")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":contract :id boundedRetrieval") "Must define boundedRetrieval contract")
      (assert (string-contains? src ":limits [") "Must define default retrieval limits")
      (assert (string-contains? src ":defaultPageLines 50") "Must define defaultPageLines")
      (assert (string-contains? src ":maxBatchBytes 65536") "Must define maxBatchBytes ceiling")
      true)))

(df TestReadingOperationsDeclaredInRpcRegistry [] -> Bool
  :d "Verifies that rpc.asn defines progressive reading operations: read, sec, out, ls"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "rpc.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":id \"asl-intel-ast\"") "Must declare outline operation")
      (assert (string-contains? src ":id \"asl-intel-read\"") "Must declare read slice operation")
      (assert (string-contains? src ":id \"asl-intel-sec\"") "Must declare section extraction operation")
      (assert (string-contains? src ":id \"asl-intel-ls\"") "Must declare ls directory operation")
      (assert (string-contains? src "Polyglot AST outline extraction") "Must describe outline purpose")
      true)))

(df TestPathBoundaryAndHiddenPathProtection [] -> Bool
  :d "Verifies that path boundary violations and escaping paths are rejected cleanly"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "is_safe_path") "Must implement is_safe_path")
      (assert (string-contains? src ":ERR_BOUNDARY_VIOLATION") "Must define ERR_BOUNDARY_VIOLATION error code")
      (assert (string-contains? src "normalize_path_components") "Must normalize path components")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44103 supervisor acceptance tests"
  (do
    (assert (TestSessionContractBoundedRetrievalRule) "TestSessionContractBoundedRetrievalRule must pass")
    (assert (TestProtocolConformanceBoundedRetrievalContract) "TestProtocolConformanceBoundedRetrievalContract must pass")
    (assert (TestReadingOperationsDeclaredInRpcRegistry) "TestReadingOperationsDeclaredInRpcRegistry must pass")
    (assert (TestPathBoundaryAndHiddenPathProtection) "TestPathBoundaryAndHiddenPathProtection must pass")
    true))
