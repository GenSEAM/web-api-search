(module tests/acceptance/d81/Task-F23
  :d "Acceptance fixture for Task-F23: Fix Sequential String Unescaping Order of Operations under ADR-0081."
  :x [RunTests
      TestUnescapeAsnPreservesEscapedBackslashN
      TestUnescapeJsonPreservesEscapedBackslashN
      TestUnescapeNdAsnPreservesEscapedBackslashN
      TestEscapeUnescapeRoundtripComprehensive
      TestTaskF23GroundedInPhaseFINSEL]
  :i [(asl-text/escape :a esc)
      (agent-bus/nd-asn :a nd)])

(df TestUnescapeAsnPreservesEscapedBackslashN [] -> Bool
  :d "Verifies unescape-asn-str does not turn escaped backslash followed by n into a newline"
  (let [(escaped "\\\\n")
        (unescaped (esc/unescape-asn-str escaped))]
    (assert (not (string-contains? unescaped "\n")) "unescape-asn-str must not turn \\\\n into newline")
    (assert (string-contains? unescaped "\\n") "unescape-asn-str must preserve literal \\n")
    (assert (= (string-length unescaped) 2) "unescaped length must be 2")
    true))

(df TestUnescapeJsonPreservesEscapedBackslashN [] -> Bool
  :d "Verifies unescape-json-str does not turn escaped backslash followed by n into a newline"
  (let [(escaped "\\\\n")
        (unescaped (esc/unescape-json-str escaped))]
    (assert (not (string-contains? unescaped "\n")) "unescape-json-str must not turn \\\\n into newline")
    (assert (string-contains? unescaped "\\n") "unescape-json-str must preserve literal \\n")
    (assert (= (string-length unescaped) 2) "unescaped length must be 2")
    true))

(df TestUnescapeNdAsnPreservesEscapedBackslashN [] -> Bool
  :d "Verifies ND-ASN deserialization preserves payload containing escaped backslash followed by n"
  (let [(payload "\\n")
        (frame (nd/nd-asn-frame "test" 1 100 payload (map-empty)))
        (serialized (nd/nd-asn-serialize (list frame)))
        (deserialized-list (nd/nd-asn-deserialize serialized))]
    (assert (= (list-length deserialized-list) 1) "Must deserialize 1 frame")
    (let [(frame-res (option-or (list-head deserialized-list) (err "missing")))
          (f (result-or frame-res frame))]
      (assert (is-ok? frame-res) "Frame deserialization must succeed")
      (assert (not (string-contains? (.-payload f) "\n")) "Payload must not contain literal newline")
      (assert (= (.-payload f) payload) "Payload must match original \\n")
      true)))

(df TestEscapeUnescapeRoundtripComprehensive [] -> Bool
  :d "Verifies comprehensive roundtrip escaping fidelity across ASN and JSON"
  (let [(raw-cases (list "hello world"
                         "line 1\nline 2"
                         "tab\there"
                         "\"quotes\""
                         "\\slash\\"
                         "\\\\n"
                         "path\\to\\file"
                         "multi\nline\twith \"quotes\" and \\slashes\\"))]
    (let [(all-asn-ok (fold (fn [(ok Bool) (s Str)] -> Bool
                              (let [(escaped (esc/escape-asn-str s))
                                    (unescaped (esc/unescape-asn-str escaped))]
                                (and ok (= unescaped s))))
                            true
                            raw-cases))
          (all-json-ok (fold (fn [(ok Bool) (s Str)] -> Bool
                               (let [(escaped (esc/escape-json-str s))
                                     (unescaped (esc/unescape-json-str escaped))]
                                 (and ok (= unescaped s))))
                             true
                             raw-cases))]
      (assert all-asn-ok "All ASN escape roundtrips must succeed")
      (assert all-json-ok "All JSON escape roundtrips must succeed")
      true)))

(df TestTaskF23GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F23 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F23\""))
             (has-title (string-contains? content ":title \"Fix Sequential String Unescaping Order of Operations\""))]
         (assert has-id "Task-F23 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F23 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F23"
  (let [(t1 (TestUnescapeAsnPreservesEscapedBackslashN))
        (t2 (TestUnescapeJsonPreservesEscapedBackslashN))
        (t3 (TestUnescapeNdAsnPreservesEscapedBackslashN))
        (t4 (TestEscapeUnescapeRoundtripComprehensive))
        (t5 (TestTaskF23GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 (and t4 t5))))))
