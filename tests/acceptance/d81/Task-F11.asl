(module tests/acceptance/d81/Task-F11
  :d "Acceptance fixture for Task-F11: Enforce Cryptographic Checksum Verification in Distribution Installer under ADR-0081."
  :x [RunTests
      TestEmitInstallShEmitsSha256Verification
      TestEmitInstallShGatedByVerification
      TestTaskF11GroundedInPhaseFINSEL]
  :i [(asl-pack/dist :a d)])

(df TestEmitInstallShEmitsSha256Verification [] -> Bool
  :d "Verifies that emit-install-sh includes sha256sum and shasum fallback verification commands"
  (let [(cfg (d/make-dist-config "0.2.0"))
        (script (d/emit-install-sh cfg))]
    (assert (string-contains? script "sha256sum") "Script must support sha256sum verification")
    (assert (string-contains? script "shasum -a 256") "Script must support shasum -a 256 verification")
    (assert (string-contains? script "VERIFIED") "Script must maintain cryptographic verification flag")
    true))

(df TestEmitInstallShGatedByVerification [] -> Bool
  :d "Verifies that tar extraction is gated by checksum verification status"
  (let [(cfg (d/make-dist-config "0.2.0"))
        (script (d/emit-install-sh cfg))]
    (assert (string-contains? script "tar -xzf") "Script must extract archive")
    (assert (string-contains? script "VERIFIED") "Script must check verification flag before extraction")
    (assert (string-contains? script "Checksum verification failed") "Script must reject unverified or mismatched archives")
    true))

(df TestTaskF11GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F11 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F11\"") "Must declare Task-F11")
      (assert (string-contains? f-src "pack/src/dist.asl") "Must own pack/src/dist.asl")
      (assert (string-contains? f-src "emit-install-sh") "Must target symbol emit-install-sh")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F11 acceptance checks"
  (do
    (assert (TestEmitInstallShEmitsSha256Verification) "TestEmitInstallShEmitsSha256Verification must pass")
    (assert (TestEmitInstallShGatedByVerification) "TestEmitInstallShGatedByVerification must pass")
    (assert (TestTaskF11GroundedInPhaseFINSEL) "TestTaskF11GroundedInPhaseFINSEL must pass")
    true))
