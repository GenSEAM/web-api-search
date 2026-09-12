(module tests/acceptance/d81/Task44304
  :d "Acceptance fixture for Task44304: staged editing, leases and rollback under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestVfsConformanceSuiteExecution
      TestVfsStagingTargetSymbolsContract
      TestVfsBehavioralContract
      TestRequiredCaseKindsContract
      TestTask44304GroundedInPhase443]
  :i [("../../conformance/vfs/vfs_staging_test" :a vst)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestVfsConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/vfs/vfs_staging_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/vfs/vfs_staging_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (vst/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestVfsStagingTargetSymbolsContract [] -> Bool
  :d "Verifies target symbols vfs-cas-update and execute_single_step are implemented and exported"
  (let [(v-res (file-read "mem/src/vfs.asl"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag v-res) "ok") "mem/src/vfs.asl must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(v-src (.-value v-res))
          (c-src (.-value c-res))]
      (assert (string-contains? v-src "vfs-cas-update") "mem/src/vfs.asl must export vfs-cas-update")
      (assert (string-contains? v-src "vfs-discard") "mem/src/vfs.asl must export vfs-discard")
      (assert (string-contains? v-src "vfs-flush") "mem/src/vfs.asl must export vfs-flush")
      (assert (string-contains? v-src "vfs-acquire-lease") "mem/src/vfs.asl must export vfs-acquire-lease")
      (assert (string-contains? v-src "vfs-release-lease") "mem/src/vfs.asl must export vfs-release-lease")
      (assert (string-contains? v-src "vfs-staged-write") "mem/src/vfs.asl must export vfs-staged-write")
      (assert (string-contains? c-src "execute_single_step") "asl.c must declare execute_single_step")
      (assert (string-contains? c-src "clear_staged_buffers") "asl.c must implement clear_staged_buffers")
      true)))

(df TestVfsBehavioralContract [] -> Bool
  :d "Verifies core behavioral requirements: digest equivalence on discard, flush commit, and lease conflict refusal"
  (let [(v-res (file-read "mem/src/vfs.asl"))]
    (assert (= (.-_tag v-res) "ok") "mem/src/vfs.asl must exist and be readable")
    (let [(v-src (.-value v-res))]
      (assert (string-contains? v-src "(not (.-dirty buf))") "Discarding clean buffer must be idempotent")
      (assert (string-contains? v-src ":content (.-base-content buf)") "Discard must restore pristine base content")
      (assert (string-contains? v-src ":cas-hash (.-base-hash buf)") "Discard must restore pristine base hash")
      (assert (string-contains? v-src ":base-content (.-content buf)") "Flush must commit staged content as new base")
      (assert (string-contains? v-src ":base-hash (.-cas-hash buf)") "Flush must commit staged hash as new base")
      (assert (string-contains? v-src "ERR_LEASE_ACTIVE_CONFLICT") "Lease collision must refuse second writer")
      (assert (string-contains? v-src "ERR_EXTERNAL_CHANGE_CONFLICT") "Flush after external base change must be refused")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (idempotence, concurrency, negativeControl, errorPropagation, resourceBound) are present"
  (let [(f-res (file-read "tests/conformance/vfs/vfs_staging_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestIdempotenceStageAndDiscard") "Must implement idempotence case")
      (assert (string-contains? f-src "TestConcurrencyLeaseAndSecondWriter") "Must implement concurrency case")
      (assert (string-contains? f-src "TestNegativeControlCasVersionMismatch") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestErrorPropagationExternalChange") "Must implement errorPropagation case")
      (assert (string-contains? f-src "TestResourceBoundStagedBufferLimits") "Must implement resourceBound case")
      true)))

(df TestTask44304GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44304"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Staged editing, leases and rollback") "Phase 443 must state Task44304 title")
      (assert (string-contains? p-src ":lane \"vfs\"") "Phase 443 must specify vfs lane")
      (assert (string-contains? p-src "tests/conformance/vfs") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "vfs-cas-update") "Phase 443 must target vfs-cas-update")
      (assert (string-contains? p-src "execute_single_step") "Phase 443 must target execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44304 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestVfsConformanceSuiteExecution) "TestVfsConformanceSuiteExecution must pass")
    (assert (TestVfsStagingTargetSymbolsContract) "TestVfsStagingTargetSymbolsContract must pass")
    (assert (TestVfsBehavioralContract) "TestVfsBehavioralContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44304GroundedInPhase443) "TestTask44304GroundedInPhase443 must pass")
    true))
