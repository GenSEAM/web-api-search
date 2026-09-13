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
  (let [(rawAsn "symbol: (:key \"hello \\ world\" \n \t \r)")
        (rawUnicode "Unicode: 世界 𝄞 🌍 \n\t\"quoted\"")
        (rawJson "{\"metric\": \"78%\", \"path\": \"c:\\\\win\\\\dir\"}")
        (escAsn (esc/escapeAsnStr rawAsn))
        (escUni (esc/escapeAsnStr rawUnicode))
        (escJson (esc/escapeJsonStr rawJson))]
    (assert (= (esc/unescapeAsnStr escAsn) rawAsn) "ASN round trip must restore exact raw string")
    (assert (= (esc/unescapeAsnStr escUni) rawUnicode) "Unicode ASN round trip must restore exact raw string")
    (assert (= (esc/unescapeJsonStr escJson) rawJson) "JSON round trip must restore exact raw string")
    (let [(doubleEsc (esc/escapeAsnStr escAsn))]
      (assert (!= doubleEsc escAsn) "Double escaping must be observable and distinct from single escape")
      (assert (> (string-length doubleEsc) (string-length escAsn)) "Double escaping must increase character length")
      true)))

(df TestIdempotenceSafeArgAndUnescape [] -> Bool
  :d "Idempotence: safe shell arguments and plain strings without escapes remain identical under repeated processing"
  (let [(safeArg "canonical_identifier_123")
        (plainStr "simple text with no escapes")
        (firstSh (esc/escapeShCompact safeArg))
        (secondSh (esc/escapeShCompact firstSh))
        (firstUn (esc/unescapeAsnStr plainStr))
        (secondUn (esc/unescapeAsnStr firstUn))]
    (assert (= firstSh safeArg) "Safe shell arg must not be quoted")
    (assert (= secondSh firstSh) "Compact shell escape must be idempotent on safe arguments")
    (assert (= firstUn plainStr) "Plain string unescape must leave content identical")
    (assert (= secondUn firstUn) "Plain string unescape must be idempotent")
    true))

(df TestMalformedUnescapeAndDelimiters [] -> Bool
  :d "Malformed: identifies unsafe shell control characters and handles embedded delimiter sequences safely"
  (let [(unsafeChars (list "$" "`" "\\" "\"" "'" ";" "&" "|" ">" "<" "(" ")" "*" "?" "!" "~"))
        (complexSh (esc/escapeShArg "arg with 'single' and \"double\" quotes"))]
    (assert (string-contains? complexSh "'\\''") "Shell escaping must protect embedded single quotes")
    (assert (fold (fn [(acc Bool) (ch Str)] -> Bool
                    (and acc (not (esc/isShSafeArg ch))))
                  true
                  unsafeChars)
            "All dangerous shell metacharacters must be identified as unsafe")
    true))

(df TestBoundaryEmptyAndUnicodeLimits [] -> Bool
  :d "Boundary: handles empty strings and multi-byte Unicode boundaries cleanly"
  (do
    (assert (= (esc/escapeAsnStr "") "") "Empty string ASN escape must be empty")
    (assert (= (esc/unescapeAsnStr "") "") "Empty string ASN unescape must be empty")
    (assert (= (esc/escapeJsonStr "") "") "Empty string JSON escape must be empty")
    (assert (= (esc/unescapeJsonStr "") "") "Empty string JSON unescape must be empty")
    (assert (= (esc/escapeShArg "") "''") "Empty string shell escape must be two single quotes")
    (assert (not (esc/isShSafeArg "")) "Empty string must not be reported as safe shell arg")
    (let [(astral "𝄢 𝄞 𠜎 𠜱")
          (astralEsc (esc/escapeAsnStr astral))]
      (assert (= (esc/unescapeAsnStr astralEsc) astral) "Astral plane Unicode characters must round trip cleanly")
      true)))

(df TestMetamorphicEquivalence [] -> Bool
  :d "Metamorphic: escaping concatenation equals concatenation of escapes for linear encodings"
  (let [(partA "prefix: \"val\"")
        (partB "suffix: \\end\\")
        (combined (str partA partB))
        (escCombined (esc/escapeAsnStr combined))
        (escSeparate (str (esc/escapeAsnStr partA) (esc/escapeAsnStr partB)))]
    (assert (= escCombined escSeparate) "Escaping concatenation must equal concatenated escapes")
    (let [(jsonA "key: \"1\"")
          (jsonB "val: \"2\"")
          (combinedJson (str jsonA jsonB))]
      (assert (= (esc/escapeJsonStr combinedJson)
                 (str (esc/escapeJsonStr jsonA) (esc/escapeJsonStr jsonB)))
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
