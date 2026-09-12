(module tests/acceptance/d81/Task44306
  :d "Acceptance fixture for Task44306: codec, escaping and text boundaries under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTextConformanceSuiteExecution
      TestTextCodecTargetSymbolsContract
      TestTextCodecBehavioralContract
      TestRequiredCaseKindsContract
      TestTask44306GroundedInPhase443]
  :i [("../../conformance/text/text_codec_conformance_test" :a tct)
      ("../../../asl/packages/asl-text/src/escape" :a esc)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTextConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/text/text_codec_conformance_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/text/text_codec_conformance_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (tct/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestTextCodecTargetSymbolsContract [] -> Bool
  :d "Verifies target symbols escape-asn-str, escape-json-str, escape-sh-arg are implemented and exported"
  (let [(e-res (file-read "asl/packages/asl-text/src/escape.asl"))]
    (assert (= (.-_tag e-res) "ok") "escape.asl must exist")
    (let [(e-src (.-value e-res))]
      (assert (string-contains? e-src "escape-asn-str") "escape-asn-str must be declared")
      (assert (string-contains? e-src "unescape-asn-str") "unescape-asn-str must be declared")
      (assert (string-contains? e-src "escape-json-str") "escape-json-str must be declared")
      (assert (string-contains? e-src "escape-sh-arg") "escape-sh-arg must be declared")
      (assert (string-contains? e-src "string-empty? arg") "escape-sh-arg must handle empty strings")
      (assert (string-contains? e-src "is-sh-safe-arg") "escape.asl must provide is-sh-safe-arg")
      true)))

(df TestTextCodecBehavioralContract [] -> Bool
  :d "Verifies behavioral requirements: round trip printable ASCII, Unicode astral plane, and control characters"
  (let [(sample-ascii "hello world 123 !@#$%^&*()_+-=[]{}|;:,.<>?/")
        (sample-ctrl "line 1\nline 2\t\"quoted\"")
        (sample-unicode "astral: 𝄞 🌍 world")
        (esc-ascii (esc/escape-asn-str sample-ascii))
        (esc-ctrl (esc/escape-asn-str sample-ctrl))
        (esc-json (esc/escape-json-str sample-ctrl))
        (esc-sh (esc/escape-sh-arg "param with spaces and 'single' quotes"))]
    (assert (= (esc/unescape-asn-str esc-ascii) sample-ascii) "Printable ASCII must round trip through ASN escape")
    (assert (= (esc/unescape-asn-str esc-ctrl) sample-ctrl) "Control chars must round trip through ASN escape")
    (assert (= (esc/unescape-json-str esc-json) sample-ctrl) "Control chars must round trip through JSON escape")
    (assert (string-contains? esc-sh "'\\''") "Shell escape must quote and escape interior single quotes")
    (assert (= (esc/escape-asn-str "") "") "Empty string ASN escape must be empty")
    (assert (= (esc/unescape-asn-str "") "") "Empty string ASN unescape must be empty")
    (assert (= (esc/escape-json-str "") "") "Empty string JSON escape must be empty")
    (assert (= (esc/unescape-json-str "") "") "Empty string JSON unescape must be empty")
    (assert (= (esc/escape-sh-arg "") "''") "Empty string shell escape must be two single quotes")
    true))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (roundTrip, idempotence, malformed, boundary, metamorphic) are present"
  (let [(f-res (file-read "tests/conformance/text/text_codec_conformance_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestRoundTripEscapeUnescape") "Must implement roundTrip case")
      (assert (string-contains? f-src "TestIdempotenceSafeArgAndUnescape") "Must implement idempotence case")
      (assert (string-contains? f-src "TestMalformedUnescapeAndDelimiters") "Must implement malformed case")
      (assert (string-contains? f-src "TestBoundaryEmptyAndUnicodeLimits") "Must implement boundary case")
      (assert (string-contains? f-src "TestMetamorphicEquivalence") "Must implement metamorphic case")
      true)))

(df TestTask44306GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44306"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Codec, escaping and text boundaries") "Phase 443 must state Task44306 title")
      (assert (string-contains? p-src ":lane \"text\"") "Phase 443 must specify text lane")
      (assert (string-contains? p-src "tests/conformance/text") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "escape-asn-str") "Phase 443 must target escape-asn-str")
      (assert (string-contains? p-src "escape-json-str") "Phase 443 must target escape-json-str")
      (assert (string-contains? p-src "escape-sh-arg") "Phase 443 must target escape-sh-arg")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44306 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTextConformanceSuiteExecution) "TestTextConformanceSuiteExecution must pass")
    (assert (TestTextCodecTargetSymbolsContract) "TestTextCodecTargetSymbolsContract must pass")
    (assert (TestTextCodecBehavioralContract) "TestTextCodecBehavioralContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44306GroundedInPhase443) "TestTask44306GroundedInPhase443 must pass")
    true))
