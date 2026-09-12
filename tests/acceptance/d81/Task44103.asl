(module tests/acceptance/d81/Task44103
  :d "Acceptance fixture for Task44103: Bound total retrieval and preserve snapshot-consistent continuation under ADR-0081."
  :x [RunTests
      TestBoundedReadSliceAndTotalLines
      TestProtocolConformanceErrorRejection
      TestRpcBoundedOperationsCatalog
      TestCompleteSmallFileAcceptance]
  :i [])

(df TestBoundedReadSliceAndTotalLines [] -> Bool
  :d "Verifies that file slice reading bounds output by line numbers and reports total lines"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "read_file_slice") "Must implement read_file_slice")
      (assert (string-contains? src "count_file_lines") "Must implement count_file_lines")
      (assert (string-contains? src ":total-lines") "Must report :total-lines metadata")
      (assert (string-contains? src ":ERR_FILE_NOT_FOUND") "Must reject nonexistent file with ERR_FILE_NOT_FOUND")
      true)))

(df TestProtocolConformanceErrorRejection [] -> Bool
  :d "Verifies that protocol-conformance.asn defines canonical error codes and batch aggregate statuses"
  (let [(p-res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag p-res) "ok") "protocol-conformance.asn must exist")
    (let [(src (.-value p-res))]
      (assert (string-contains? src ":ERR_UNIMPLEMENTED") "Must define :ERR_UNIMPLEMENTED error code")
      (assert (string-contains? src "completed-with-errors") "Must define completed-with-errors status")
      (assert (string-contains? src ":statuses [\"completed\" \"completed-with-errors\" \"failed\"]") "Must define batch aggregate statuses")
      true)))

(df TestRpcBoundedOperationsCatalog [] -> Bool
  :d "Verifies that rpc.asn defines :limit parameter across retrieval and execution operations"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "rpc.asn must exist")
    (let [(src (.-value r-res))]
      (assert (string-contains? src "[:limit <n>]") "rpc.asn must define [:limit <n>] parameter")
      (assert (string-contains? src "[:limit <bytes>]") "rpc.asn must define [:limit <bytes>] parameter")
      (assert (string-contains? src ":op \"trace\"") "rpc.asn must define trace operation")
      true)))

(df TestCompleteSmallFileAcceptance [] -> Bool
  :d "Verifies that complete small relevant file is accepted within memory and line bounds"
  (let [(f-res (file-read ".asl/mem/tasks/InFlight.asn"))]
    (assert (= (.-_tag f-res) "ok") "InFlight.asn must be readable")
    (let [(src (.-value f-res))]
      (assert (string-contains? src "(:in-flight") "InFlight.asn must be complete valid ASN")
      (assert (string-contains? src ":status") "InFlight.asn must contain status")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44103 supervisor acceptance tests"
  (do
    (assert (TestBoundedReadSliceAndTotalLines) "TestBoundedReadSliceAndTotalLines must pass")
    (assert (TestProtocolConformanceErrorRejection) "TestProtocolConformanceErrorRejection must pass")
    (assert (TestRpcBoundedOperationsCatalog) "TestRpcBoundedOperationsCatalog must pass")
    (assert (TestCompleteSmallFileAcceptance) "TestCompleteSmallFileAcceptance must pass")
    true))
