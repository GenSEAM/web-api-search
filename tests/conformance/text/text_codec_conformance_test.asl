(module tests/conformance/text/TextCodecConformanceTest
  :d "Conformance test suite for codecs, escaping and text boundaries per ADR-0081"
  :x [RunTests
      TestRoundTripEscapeUnescape
      TestIdempotenceSafeArgAndUnescape
      TestMalformedUnescapeAndDelimiters
      TestBoundaryEmptyAndUnicodeLimits
      TestMetamorphicEquivalence]
  :i [("../../../asl/packages/asl-text/src/escape" :a esc)])

(df TestRoundTripEscapeUnescape [] -> Bool
  :d "Round trip: escape then unescape restores exact input including Unicode and delimiters; double escaping is observable"
  (let [(raw-asn "symbol: (:key \"hello \\ world\" \n \t \r)")
        (raw-unicode "Unicode: 世界 𝄞 🌍 \n\t\"quoted\"")
        (raw-json "{\"metric\": \"78%\", \"path\": \"c:\\\\win\\\\dir\"}")
        (esc-asn (esc/escape-asn-str raw-asn))
        (esc-uni (esc/escape-asn-str raw-unicode))
        (esc-json (esc/escape-json-str raw-json))]
    (assert (= (esc/unescape-asn-str esc-asn) raw-asn) "ASN round trip must restore exact raw string")
    (assert (= (esc/unescape-asn-str esc-uni) raw-unicode) "Unicode ASN round trip must restore exact raw string")
    (assert (= (esc/unescape-json-str esc-json) raw-json) "JSON round trip must restore exact raw string")
    (let [(double-esc (esc/escape-asn-str esc-asn))]
      (assert (!= double-esc esc-asn) "Double escaping must be observable and distinct from single escape")
      (assert (> (string-length double-esc) (string-length esc-asn)) "Double escaping must increase character length")
      true)))

(df TestIdempotenceSafeArgAndUnescape [] -> Bool
  :d "Idempotence: safe shell arguments and plain strings without escapes remain identical under repeated processing"
  (let [(safe-arg "canonical_identifier_123")
        (plain-str "simple text with no escapes")
        (first-sh (esc/escape-sh-compact safe-arg))
        (second-sh (esc/escape-sh-compact first-sh))
        (first-un (esc/unescape-asn-str plain-str))
        (second-un (esc/unescape-asn-str first-un))]
    (assert (= first-sh safe-arg) "Safe shell arg must not be quoted")
    (assert (= second-sh first-sh) "Compact shell escape must be idempotent on safe arguments")
    (assert (= first-un plain-str) "Plain string unescape must leave content identical")
    (assert (= second-un first-un) "Plain string unescape must be idempotent")
    true))

(df TestMalformedUnescapeAndDelimiters [] -> Bool
  :d "Malformed: identifies unsafe shell control characters and handles embedded delimiter sequences safely"
  (let [(unsafe-chars (list "$" "`" "\\" "\"" "'" ";" "&" "|" ">" "<" "(" ")" "*" "?" "!" "~"))
        (complex-sh (esc/escape-sh-arg "arg with 'single' and \"double\" quotes"))]
    (assert (string-contains? complex-sh "'\\''") "Shell escaping must protect embedded single quotes")
    (assert (fold (fn [(acc Bool) (ch Str)] -> Bool
                    (and acc (not (esc/is-sh-safe-arg ch))))
                  true
                  unsafe-chars)
            "All dangerous shell metacharacters must be identified as unsafe")
    true))

(df TestBoundaryEmptyAndUnicodeLimits [] -> Bool
  :d "Boundary: handles empty strings and multi-byte Unicode boundaries cleanly"
  (do
    (assert (= (esc/escape-asn-str "") "") "Empty string ASN escape must be empty")
    (assert (= (esc/unescape-asn-str "") "") "Empty string ASN unescape must be empty")
    (assert (= (esc/escape-json-str "") "") "Empty string JSON escape must be empty")
    (assert (= (esc/unescape-json-str "") "") "Empty string JSON unescape must be empty")
    (assert (= (esc/escape-sh-arg "") "''") "Empty string shell escape must be two single quotes")
    (assert (not (esc/is-sh-safe-arg "")) "Empty string must not be reported as safe shell arg")
    (let [(astral "𝄢 𝄞 𠜎 𠜱")
          (astral-esc (esc/escape-asn-str astral))]
      (assert (= (esc/unescape-asn-str astral-esc) astral) "Astral plane Unicode characters must round trip cleanly")
      true)))

(df TestMetamorphicEquivalence [] -> Bool
  :d "Metamorphic: escaping concatenation equals concatenation of escapes for linear encodings"
  (let [(part-a "prefix: \"val\"")
        (part-b "suffix: \\end\\")
        (combined (str part-a part-b))
        (esc-combined (esc/escape-asn-str combined))
        (esc-separate (str (esc/escape-asn-str part-a) (esc/escape-asn-str part-b)))]
    (assert (= esc-combined esc-separate) "Escaping concatenation must equal concatenated escapes")
    (let [(json-a "key: \"1\"")
          (json-b "val: \"2\"")
          (combined-json (str json-a json-b))]
      (assert (= (esc/escape-json-str combined-json)
                 (str (esc/escape-json-str json-a) (esc/escape-json-str json-b)))
              "JSON escaping concatenation must equal concatenated escapes")
      true)))

(df RunTests [] -> Bool
  :d "Executes all text, codec, and escaping conformance tests"
  (do
    (assert (TestRoundTripEscapeUnescape) "TestRoundTripEscapeUnescape must pass")
    (assert (TestIdempotenceSafeArgAndUnescape) "TestIdempotenceSafeArgAndUnescape must pass")
    (assert (TestMalformedUnescapeAndDelimiters) "TestMalformedUnescapeAndDelimiters must pass")
    (assert (TestBoundaryEmptyAndUnicodeLimits) "TestBoundaryEmptyAndUnicodeLimits must pass")
    (assert (TestMetamorphicEquivalence) "TestMetamorphicEquivalence must pass")
    true))
