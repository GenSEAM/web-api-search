(module tests/acceptance/d81/Task44101
  :d "Acceptance fixture for Task44101: Bind session progression to trusted runner receipts under ADR-0081."
  :x [RunTests
      TestSessionContractSpecification
      TestInFlightSessionLedger
      TestRpcWhereOperationDeclared
      TestReceiptProgressionIntegrity]
  :i [])

(df TestSessionContractSpecification [] -> Bool
  :d "Verifies session contract defines trusted runner receipts, source digests, and lease invariants"
  (let [(s-res (file-read "asl/grammar/session-contract.asn"))]
    (assert (= (.-_tag s-res) "ok") "asl/grammar/session-contract.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":rule :id trustedRunnerReceipt") "Must define trustedRunnerReceipt rule")
      (assert (string-contains? src ":rule :id sourceDigestBinding") "Must define sourceDigestBinding rule")
      (assert (string-contains? src ":rule :id leaseIsolation") "Must define leaseIsolation rule")
      (assert (string-contains? src ":rule :id durableStateRecovery") "Must define durableStateRecovery rule")
      (assert (string-contains? src ":receiptSchema [") "Must define receiptSchema")
      (assert (string-contains? src ":field :id \"sourceDigest\"") "Must bind sourceDigest field")
      (assert (string-contains? src ":field :id \"exitCode\"") "Must bind exitCode field")
      true)))

(df TestInFlightSessionLedger [] -> Bool
  :d "Verifies that InFlight.asn tracks active session and status"
  (let [(i-res (file-read ".asl/mem/tasks/InFlight.asn"))]
    (assert (= (.-_tag i-res) "ok") ".asl/mem/tasks/InFlight.asn must exist")
    (let [(src (.-value i-res))]
      (assert (string-contains? src ":session-id") "Must define :session-id")
      (assert (string-contains? src ":status") "Must define :status")
      (assert (string-contains? src ":activeTasks") "Must define :activeTasks")
      true)))

(df TestRpcWhereOperationDeclared [] -> Bool
  :d "Verifies that rpc.asn defines the :where orientation operation"
  (let [(r-res (file-read "asl/grammar/rpc.asn"))]
    (assert (= (.-_tag r-res) "ok") "asl/grammar/rpc.asn must exist")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":op \"where\"") "Must declare where operation")
      (assert (string-contains? src "asl-where") "Must declare asl-where identifier")
      true)))

(df TestReceiptProgressionIntegrity [] -> Bool
  :d "Verifies that receipts ledger records runner receipts with valid exit codes and verified status"
  (let [(r-res (file-read ".asl/mem/receipts.asn"))]
    (assert (= (.-_tag r-res) "ok") ".asl/mem/receipts.asn must exist")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":status :verified") "Receipts must record verified status")
      (assert (string-contains? src ":exitCode 0") "Receipts must record exitCode 0")
      (assert (string-contains? src ":toolName \"asl-test-acceptance\"") "Receipts must name runner tool")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44101 supervisor acceptance tests"
  (do
    (assert (TestSessionContractSpecification) "TestSessionContractSpecification must pass")
    (assert (TestInFlightSessionLedger) "TestInFlightSessionLedger must pass")
    (assert (TestRpcWhereOperationDeclared) "TestRpcWhereOperationDeclared must pass")
    (assert (TestReceiptProgressionIntegrity) "TestReceiptProgressionIntegrity must pass")
    true))
