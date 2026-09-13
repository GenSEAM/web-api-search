(module tests/acceptance/d81/Task-F05
  :d "Acceptance fixture for Task-F05: Eliminate Indiscriminate Quote Stripping in Shell Transpiler under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestNoIndiscriminateQuoteStripping
      TestPreserveQuotesInShForm
      TestPreserveQuotedArgsInCmdForm
      TestTaskF05GroundedInPhaseFINSEL]
  :i [(asl-codec/sh-transpile :a sh)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestNoIndiscriminateQuoteStripping [] -> Bool
  :d "Verifies that sh-transpile.asl has eliminated indiscriminate global quote stripping"
  (let [(c-res (file-read "asl/packages/asl-codec/src/sh-transpile.asl"))]
    (assert (= (.-_tag c-res) "ok") "sh-transpile.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (not (string-contains? c-src "(string-replace s6 \"\\\"\" \"\")")) "Must eliminate indiscriminate quote stripping at s6")
      (assert (not (string-contains? c-src "(\"\\\"\" \"\")")) "Must not perform indiscriminate quote replacement")
      true)))

(df TestPreserveQuotesInShForm [] -> Bool
  :d "Verifies that asn-to-sh preserves quotes in (:sh ...) expressions"
  (let [(res (sh/asn-to-sh "(:sh \"echo \\\"hello world\\\"\")"))]
    (assert (.-success res) "Transpilation of :sh form must succeed")
    (let [(out (.-output res))]
      (assert (string-contains? out "\"hello world\"") "Output must preserve quotes in hello world")
      true)))

(df TestPreserveQuotedArgsInCmdForm [] -> Bool
  :d "Verifies that asn-to-sh preserves quotes and spaces in (:cmd ...) args"
  (let [(res (sh/asn-to-sh "(:cmd \"echo\" :args [\"\\\"hello world\\\"\"])"))]
    (assert (.-success res) "Transpilation of :cmd form with quoted arg must succeed")
    (let [(out (.-output res))]
      (assert (string-contains? out "\"hello world\"") "Output must preserve quoted argument")
      true)))

(df TestTaskF05GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F05 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F05\"") "Must declare Task-F05")
      (assert (string-contains? f-src "asl/packages/asl-codec/src/sh-transpile.asl") "Must own sh-transpile.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F05 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestNoIndiscriminateQuoteStripping) "TestNoIndiscriminateQuoteStripping must pass")
    (assert (TestPreserveQuotesInShForm) "TestPreserveQuotesInShForm must pass")
    (assert (TestPreserveQuotedArgsInCmdForm) "TestPreserveQuotedArgsInCmdForm must pass")
    (assert (TestTaskF05GroundedInPhaseFINSEL) "TestTaskF05GroundedInPhaseFINSEL must pass")
    true))
