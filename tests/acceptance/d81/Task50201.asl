(module tests/acceptance/d81/Task50201
  :d "Acceptance fixture for Task50201: asnCmd eradication, manifest hygiene, and grammar cleanup."
  :x [testAsnCmdEradication testManifestHygiene testGrammarCleanliness testCliIntegrity RunTests]
  :i [])

(df testAsnCmdEradication [] -> Bool
  (let [(res (sys-exec "sh -c 'test ! -f asl/packages/asl-cli/src/asn_cmd.asl'"))
        (code (.-exitCode res))]
    (assert (= code 0) "asn_cmd.asl must not exist on disk")
    (refute (!= code 0) "asn_cmd.asl deletion must be verified")
    true))

(df testManifestHygiene [] -> Bool
  (let [(res (sys-exec "sh -c 'cat asl/packages/asl-cli/manifest.asn'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "manifest.asn exists and is readable")
    (refute (!= code 0) "manifest.asn read must exit 0")
    (assert (string-contains? out "(:package asl-cli") "manifest.asn declares asl-cli package")
    (refute (string-contains? out "asl-codec") "manifest.asn must not depend on asl-codec")
    true))

(df testGrammarCleanliness [] -> Bool
  (let [(res (sys-exec "sh -c 'cat asl/packages/asl-cli/grammar.asn'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "grammar.asn exists and is readable")
    (refute (!= code 0) "grammar.asn read must exit 0")
    (assert (string-contains? out "(:grammar") "grammar.asn declares grammar")
    (refute (string-contains? out "dispatchAsn") "grammar.asn must purge dispatchAsn")
    (refute (string-contains? out "runCheck") "grammar.asn must purge runCheck")
    (refute (string-contains? out "asnToJsonValue") "grammar.asn must purge asnToJsonValue")
    (refute (string-contains? out "formatAsnHelp") "grammar.asn must purge formatAsnHelp")
    (refute (string-contains? out "runFromJson") "grammar.asn must purge runFromJson")
    (refute (string-contains? out "runToJson") "grammar.asn must purge runToJson")
    true))

(df testCliIntegrity [] -> Bool
  (let [(chkRes (sys-exec "bin/asl check asl/packages/asl-cli/src/cli.asl"))
        (gateRes (sys-exec "bin/asl gate asl/packages/asl-cli/src/cli.asl"))]
    (assert (= (.-exitCode chkRes) 0) "cli.asl delimiter balance and syntax check cleanly")
    (refute (!= (.-exitCode chkRes) 0) "cli.asl check must exit 0")
    (assert (= (.-exitCode gateRes) 0) "cli.asl passes monorepo gate verification")
    (refute (!= (.-exitCode gateRes) 0) "cli.asl gate must exit 0")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testAsnCmdEradication) "testAsnCmdEradication passes")
    (assert (testManifestHygiene) "testManifestHygiene passes")
    (assert (testGrammarCleanliness) "testGrammarCleanliness passes")
    (assert (testCliIntegrity) "testCliIntegrity passes")
    true))
