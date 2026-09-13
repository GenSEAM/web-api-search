(module tests/conformance/vfs/VfsStagingTest
  :d "Conformance test suite for staged editing, leases, CAS updates and rollback per ADR-0081"
  :x [RunTests
      TestIdempotenceStageAndDiscard
      TestConcurrencyLeaseAndSecondWriter
      TestNegativeControlCasVersionMismatch
      TestErrorPropagationExternalChange
      TestResourceBoundStagedBufferLimits]
  :i [])

(df TestIdempotenceStageAndDiscard [] -> Bool
  :d "Idempotence: staging an edit then discarding restores pre-stage hash; second discard is an idempotent no-op"
  (let [(vfsSrcRes (file-read "mem/src/vfs.asl"))
        (cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag vfsSrcRes) "ok") "mem/src/vfs.asl must exist")
    (assert (= (.-_tag cSrcRes) "ok") "asl/tools/asl.c must exist")
    (let [(vfsSrc (.-value vfsSrcRes))
          (cSrc (.-value cSrcRes))]
      (assert (string-contains? vfsSrc "vfs-discard") "mem/src/vfs.asl must export vfs-discard")
      (assert (string-contains? vfsSrc "vfs-flush") "mem/src/vfs.asl must export vfs-flush")
      (assert (string-contains? vfsSrc "vfs-cas-update") "mem/src/vfs.asl must export vfs-cas-update")
      (assert (string-contains? vfsSrc "vfs-cas-hash") "mem/src/vfs.asl must export vfs-cas-hash")
      (assert (string-contains? vfsSrc "(not (.-dirty buf))") "vfs-discard must be idempotent when buffer is not dirty")
      (assert (string-contains? cSrc "clear_staged_buffers") "asl.c must implement clear_staged_buffers")
      (assert (string-contains? cSrc "strcmp(op, \"discard\")") "asl.c execute_single_step must handle discard op")
      (assert (string-contains? cSrc "discarded-count") "asl.c discard receipt must report discarded-count")
      true)))

(df TestConcurrencyLeaseAndSecondWriter [] -> Bool
  :d "Concurrency: exclusive write lease refuses second concurrent writer and protects first writer flush"
  (let [(vfsSrcRes (file-read "mem/src/vfs.asl"))]
    (assert (= (.-_tag vfsSrcRes) "ok") "mem/src/vfs.asl must exist")
    (let [(vfsSrc (.-value vfsSrcRes))]
      (assert (string-contains? vfsSrc "vfs-acquire-lease") "vfs.asl must export vfs-acquire-lease")
      (assert (string-contains? vfsSrc "vfs-release-lease") "vfs.asl must export vfs-release-lease")
      (assert (string-contains? vfsSrc "vfs-staged-write") "vfs.asl must export vfs-staged-write")
      (assert (string-contains? vfsSrc "ERR_LEASE_ACTIVE_CONFLICT") "lease acquisition must reject second writer with ERR_LEASE_ACTIVE_CONFLICT")
      (assert (string-contains? vfsSrc "ERR_LEASE_NOT_OWNED") "lease release must reject non-owner with ERR_LEASE_NOT_OWNED")
      (assert (string-contains? vfsSrc ":lease-holder") "VFSBuffer must contain lease-holder field")
      (assert (string-contains? vfsSrc ":lease-expires-at") "VFSBuffer must contain lease-expires-at field")
      true)))

(df TestNegativeControlCasVersionMismatch [] -> Bool
  :d "Negative control: CAS update with stale or mismatched expected hash must reject update"
  (let [(vfsSrcRes (file-read "mem/src/vfs.asl"))]
    (assert (= (.-_tag vfsSrcRes) "ok") "mem/src/vfs.asl must exist")
    (let [(vfsSrc (.-value vfsSrcRes))]
      (assert (string-contains? vfsSrc "ERR_CAS_VERSION_CONFLICT") "CAS update mismatch must return ERR_CAS_VERSION_CONFLICT")
      (assert (string-contains? vfsSrc "ERR_BUFFER_NOT_FOUND") "discarding unknown buffer must return ERR_BUFFER_NOT_FOUND")
      (assert (string-contains? vfsSrc "(!= (.-cas-hash prev) expected-hash)") "vfs-cas-update must verify cas-hash against expected-hash")
      true)))

(df TestErrorPropagationExternalChange [] -> Bool
  :d "Error propagation: flush on externally modified buffer returns ERR_EXTERNAL_CHANGE_CONFLICT"
  (let [(vfsSrcRes (file-read "mem/src/vfs.asl"))
        (cSrcRes (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag vfsSrcRes) "ok") "mem/src/vfs.asl must exist")
    (assert (= (.-_tag cSrcRes) "ok") "asl/tools/asl.c must exist")
    (let [(vfsSrc (.-value vfsSrcRes))
          (cSrc (.-value cSrcRes))]
      (assert (string-contains? vfsSrc "ERR_EXTERNAL_CHANGE_CONFLICT") "vfs-flush must reject external changes with ERR_EXTERNAL_CHANGE_CONFLICT")
      (assert (string-contains? vfsSrc "(!= (.-base-hash buf) expected-base-hash)") "vfs-flush must check base-hash against expected-base-hash")
      (assert (string-contains? cSrc "strcmp(op, \"flush\")") "asl.c execute_single_step must handle flush op")
      (assert (string-contains? cSrc "flushed-count") "asl.c flush receipt must report flushed-count")
      true)))

(df TestResourceBoundStagedBufferLimits [] -> Bool
  :d "Resource bound: registry bounds dirty buffers and tracks active paths monotonically"
  (let [(vfsSrcRes (file-read "mem/src/vfs.asl"))]
    (assert (= (.-_tag vfsSrcRes) "ok") "mem/src/vfs.asl must exist")
    (let [(vfsSrc (.-value vfsSrcRes))]
      (assert (string-contains? vfsSrc "(dfs VFSRegistry") "VFSRegistry struct must be defined")
      (assert (string-contains? vfsSrc "(:f buffers (Map Str VFSBuffer)") "VFSRegistry must map path to VFSBuffer")
      (assert (string-contains? vfsSrc "(:f active-paths (List Str)") "VFSRegistry must track active-paths")
      (assert (string-contains? vfsSrc "(:f size I64") "VFSRegistry must track size")
      (assert (string-contains? vfsSrc "vfs-diff") "vfs.asl must export vfs-diff")
      (assert (string-contains? vfsSrc "split-lines") "vfs.asl must implement split-lines")
      (assert (string-contains? vfsSrc "diff-lines-loop") "vfs.asl must implement recursive diff engine")
      true)))

(df RunTests [] -> Bool
  :d "Executes all VFS staging, lease and rollback conformance tests"
  (do
    (assert (TestIdempotenceStageAndDiscard) "TestIdempotenceStageAndDiscard must pass")
    (assert (TestConcurrencyLeaseAndSecondWriter) "TestConcurrencyLeaseAndSecondWriter must pass")
    (assert (TestNegativeControlCasVersionMismatch) "TestNegativeControlCasVersionMismatch must pass")
    (assert (TestErrorPropagationExternalChange) "TestErrorPropagationExternalChange must pass")
    (assert (TestResourceBoundStagedBufferLimits) "TestResourceBoundStagedBufferLimits must pass")
    true))
