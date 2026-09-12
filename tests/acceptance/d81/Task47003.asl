(module tests/acceptance/d81/Task47003
  :d "Acceptance fixture for Task47003: The installed binary is the built binary under ADR-0081."
  :x [RunTests
      TestEmbedSourceDigestInAslC
      TestDivergenceDetectionInAslC
      TestBuildScriptsPassDigest]
  :i [])

(df TestEmbedSourceDigestInAslC [] -> Bool
  :d "Verifies that asl.c embeds the source digest and reports it in version"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "ASL_SOURCE_DIGEST")
              "asl.c must declare or use ASL_SOURCE_DIGEST macro")
      (assert (string-contains? c-src "source digest:")
              "asl.c version output must report the embedded source digest")
      true)))

(df TestDivergenceDetectionInAslC [] -> Bool
  :d "Verifies that asl.c detects and announces source/binary divergence"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_source_divergence")
              "asl.c must implement check_source_divergence")
      (assert (string-contains? c-src "[divergence]")
              "asl.c must announce divergence explicitly on invocation")
      true)))

(df TestBuildScriptsPassDigest [] -> Bool
  :d "Verifies that build and install scripts compute and pass ASL_SOURCE_DIGEST"
  (let [(b-res (file-read "scripts/build_and_install.sh"))
        (i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag b-res) "ok") "scripts/build_and_install.sh must exist")
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist")
    (let [(b-src (.-value b-res))
          (i-src (.-value i-res))]
      (assert (string-contains? b-src "ASL_SOURCE_DIGEST")
              "build_and_install.sh must pass ASL_SOURCE_DIGEST to compiler")
      (assert (string-contains? i-src "ASL_SOURCE_DIGEST")
              "install.sh must pass ASL_SOURCE_DIGEST to compiler")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47003 supervisor acceptance tests"
  (do
    (assert (TestEmbedSourceDigestInAslC) "TestEmbedSourceDigestInAslC must pass")
    (assert (TestDivergenceDetectionInAslC) "TestDivergenceDetectionInAslC must pass")
    (assert (TestBuildScriptsPassDigest) "TestBuildScriptsPassDigest must pass")
    true))
