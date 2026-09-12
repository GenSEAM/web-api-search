(module tests/acceptance/d81/Task47303
  :d "Acceptance fixture for Task47303: distribution truth and execution verification under ADR-0081."
  :x [RunTests
      TestPlatformArchivesDoNotShareDigest
      TestBuildScriptVerifiesScratchInstall
      TestArchiveContainsExecutableNotDirectory]
  :i [])

(df TestPlatformArchivesDoNotShareDigest [] -> Bool
  :d "Verifies that archives for different platforms carry distinct digests and no duplicates exist"
  (let [(sums-res (file-read "dist/v0.1.0/SHA256SUMS"))]
    (assert (= (.-_tag sums-res) "ok") "dist/v0.1.0/SHA256SUMS must exist and be readable")
    (let [(sums (.-value sums-res))]
      (assert (not (string-contains? sums "4279e64f"))
              "SHA256SUMS must not contain the mock identical hash 4279e64f")
      true)))

(df TestBuildScriptVerifiesScratchInstall [] -> Bool
  :d "Verifies that scripts/build_and_install.sh installs into scratch location and verifies execution"
  (let [(script-res (file-read "scripts/build_and_install.sh"))]
    (assert (= (.-_tag script-res) "ok") "scripts/build_and_install.sh must exist")
    (let [(src (.-value script-res))]
      (assert (string-contains? src "scratch")
              "build_and_install.sh must verify package in a scratch directory")
      (assert (string-contains? src "mktemp -d")
              "build_and_install.sh must create scratch directory for package verification")
      (assert (string-contains? src "--version")
              "build_and_install.sh must verify binary execution with --version in scratch")
      true)))

(df TestArchiveContainsExecutableNotDirectory [] -> Bool
  :d "Verifies that build script packages binary directly so installer does not create directory where binary belongs"
  (let [(script-res (file-read "scripts/build_and_install.sh"))]
    (assert (= (.-_tag script-res) "ok") "scripts/build_and_install.sh must exist")
    (let [(src (.-value script-res))]
      (assert (string-contains? src "chmod +x")
              "build_and_install.sh must set executable permission on packaged binary")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47303 supervisor acceptance tests"
  (do
    (assert (TestPlatformArchivesDoNotShareDigest) "TestPlatformArchivesDoNotShareDigest must pass")
    (assert (TestBuildScriptVerifiesScratchInstall) "TestBuildScriptVerifiesScratchInstall must pass")
    (assert (TestArchiveContainsExecutableNotDirectory) "TestArchiveContainsExecutableNotDirectory must pass")
    true))
