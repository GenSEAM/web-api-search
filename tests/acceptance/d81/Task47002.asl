(module tests/acceptance/d81/Task47002
  :d "Acceptance fixture for Task47002: Close the seven remaining module names under ADR-0081."
  :x [RunTests
      TestNoRelativePathImports
      TestRetiredDaemonRejected
      TestCanonicalModuleNamesUsed
      TestSevenDecisionsRecorded]
  :i [])

(df TestNoRelativePathImports [] -> Bool
  :d "Verifies that relative paths are no longer used as module names in imports"
  (let [(f-gpio (file-read "asl-arduino/tests/gpio-test.asl"))
        (f-blog (file-read "asl/web/tests/blog_parity_test.asl"))
        (f-gen (file-read "asl/web/asl-src/tests/generator-test.asl"))
        (f-sh (file-read "asl/packages/asl-sh/src/process.asl"))]
    (assert (= (.-_tag f-gpio) "ok") "gpio-test.asl must exist")
    (assert (= (.-_tag f-blog) "ok") "blog_parity_test.asl must exist")
    (assert (= (.-_tag f-gen) "ok") "generator-test.asl must exist")
    (assert (= (.-_tag f-sh) "ok") "process.asl must exist")
    (let [(c-gpio (.-value f-gpio))
          (c-blog (.-value f-blog))
          (c-gen (.-value f-gen))
          (c-sh (.-value f-sh))]
      (assert (not (string-contains? c-gpio "../examples/blink"))
              "gpio-test.asl must not use relative path ../examples/blink as module name")
      (assert (not (string-contains? c-blog "../src/data/blog/posts"))
              "blog_parity_test.asl must not use relative path ../src/data/blog/posts as module name")
      (assert (not (string-contains? c-gen "../api/packages"))
              "generator-test.asl must not use relative path ../api/packages as module name")
      (assert (not (string-contains? c-sh "(core/process :a cp)"))
              "process.asl must not import core/process as module name")
      true)))

(df TestRetiredDaemonRejected [] -> Bool
  :d "Verifies that daemon is retired into engine and prohibited as module import"
  (let [(res (file-read ".asl/mem/module-resolutions.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/module-resolutions.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src "daemon")
              "module-resolutions.asn must document daemon disposition")
      (assert (string-contains? src ":status :retired")
              "daemon must be marked retired")
      true)))

(df TestCanonicalModuleNamesUsed [] -> Bool
  :d "Verifies canonical module names are used in place of paths and collisions"
  (let [(f-cr (file-read "asl/packages/asl-compiler/tests/compact_rewrite_test.asl"))
        (f-sh-core (file-read "asl/packages/asl-sh/src/core/process.asl"))]
    (assert (= (.-_tag f-cr) "ok") "compact_rewrite_test.asl must exist")
    (assert (= (.-_tag f-sh-core) "ok") "core/process.asl must exist")
    (let [(c-cr (.-value f-cr))
          (c-sh-core (.-value f-sh-core))]
      (assert (not (string-contains? c-cr "(compact_rewrite :a cr)"))
              "compact_rewrite_test.asl must use canonical module name asl-compiler/compact-rewrite")
      (assert (string-contains? c-sh-core "asl-sh/core-process")
              "core/process.asl must declare module asl-sh/core-process to eliminate collision")
      true)))

(df TestSevenDecisionsRecorded [] -> Bool
  :d "Verifies all seven module name resolutions have an explicit recorded decision"
  (let [(res (file-read ".asl/mem/module-resolutions.asn"))]
    (assert (= (.-_tag res) "ok") ".asl/mem/module-resolutions.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src "\"posts\"") "Decision for posts must be recorded")
      (assert (string-contains? src "\"core/process\"") "Decision for core/process must be recorded")
      (assert (string-contains? src "\"mem/src/xref\"") "Decision for mem/src/xref must be recorded")
      (assert (string-contains? src "\"examples/blink\"") "Decision for examples/blink must be recorded")
      (assert (string-contains? src "\"daemon\"") "Decision for daemon must be recorded")
      (assert (string-contains? src "\"asl/packages/asl-compiler/src/compact_rewrite\"") "Decision for compact_rewrite path must be recorded")
      (assert (string-contains? src "\"api/packages\"") "Decision for api/packages must be recorded")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47002 supervisor acceptance tests"
  (do
    (assert (TestNoRelativePathImports) "TestNoRelativePathImports must pass")
    (assert (TestRetiredDaemonRejected) "TestRetiredDaemonRejected must pass")
    (assert (TestCanonicalModuleNamesUsed) "TestCanonicalModuleNamesUsed must pass")
    (assert (TestSevenDecisionsRecorded) "TestSevenDecisionsRecorded must pass")
    true))
