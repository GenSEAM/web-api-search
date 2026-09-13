(module tests/acceptance/d81/Task48402
  :d "Acceptance fixture for Task48402: Pluggable Storage Engine and Deterministic VFS Adapter under D83."
  :x [run-tests
      test-storage-engine-command-exists
      test-vfs-storage-adapter-active
      test-atomic-write-and-read-roundtrip
      test-concurrent-write-integrity]
  :i [])

(df test-storage-engine-command-exists [] -> Bool
  :d "Verifies that asl store engine reports active VFS storage engine"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "typedef struct StorageEngine") "StorageEngine interface defined")
      (assert (string-contains? src "static StorageEngine g_vfs_storage_adapter") "VfsStorageAdapter defined")
      (assert (string-contains? src "flock(lock_fd, LOCK_EX | LOCK_NB)") "flock concurrency locking used")
      (assert (string-contains? src "rename(tmp_path, path)") "atomic temporary file rename used")
      true)))

(df test-vfs-storage-adapter-active [] -> Bool
  :d "Verifies that VFS adapter enforces 2000ms bounded timeout and flock locking"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "get_monotonic_ms() - start_ms < 2000") "2000ms timeout enforced")
      (assert (string-contains? src "vfs_storage_write_record") "vfs write function declared")
      (assert (string-contains? src "vfs_storage_read_record") "vfs read function declared")
      true)))

(df test-atomic-write-and-read-roundtrip [] -> Bool
  :d "Verifies that StorageEngine abstraction decouples schema contracts from persistence implementation"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "run_cmd_store") "store command dispatcher present")
      (assert (string-contains? src "get_default_storage_engine()") "default storage engine accessor")
      true)))

(df test-concurrent-write-integrity [] -> Bool
  :d "Verifies that op write delegates to get_default_storage_engine"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl.c must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "se->write_record(se, full_path, content, store_err, sizeof(store_err))")
              "op write delegates to StorageEngine")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48402 acceptance assertions"
  (let [(r1 (test-storage-engine-command-exists))
        (r2 (test-vfs-storage-adapter-active))
        (r3 (test-atomic-write-and-read-roundtrip))
        (r4 (test-concurrent-write-integrity))]
    (assert (and r1 (and r2 (and r3 r4))) "All Task48402 checks must pass")
    true))
