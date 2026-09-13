(module tests/acceptance/d81/Task-F10
  :d "Acceptance fixture for Task-F10: Defend VDOM Attribute Sanitization Against Stored XSS under ADR-0081."
  :x [RunTests
      TestFilterAttributesStripsDangerousXss
      TestIsSafeAttrValueRejectsXss
      TestDownsampleNodeStripsXssAttributes
      TestTaskF10GroundedInPhaseFINSEL]
  :i [(vdom :a v)])

(df TestFilterAttributesStripsDangerousXss [] -> Bool
  :d "Verifies filter-attributes strips dangerous URI schemes from href and src attributes"
  (let [(bad-href (map-set (map-empty) "href" "javascript:alert('xss')"))
        (bad-src (map-set (map-empty) "src" "data:text/html,<script>alert(1)</script>"))
        (bad-vbs (map-set (map-empty) "href" "vbscript:msgbox(1)"))
        (good-href (map-set (map-empty) "href" "https://example.com/dashboard"))
        (good-src (map-set (map-empty) "src" "/static/images/logo.png"))
        (filtered-bad-href (v/filter-attributes bad-href))
        (filtered-bad-src (v/filter-attributes bad-src))
        (filtered-bad-vbs (v/filter-attributes bad-vbs))
        (filtered-good-href (v/filter-attributes good-href))
        (filtered-good-src (v/filter-attributes good-src))]
    (assert (= (map-size filtered-bad-href) 0) "javascript: href must be stripped by filter-attributes")
    (assert (= (map-size filtered-bad-src) 0) "data:text/html src must be stripped by filter-attributes")
    (assert (= (map-size filtered-bad-vbs) 0) "vbscript: href must be stripped by filter-attributes")
    (assert (= (map-size filtered-good-href) 1) "Safe https href must be retained")
    (assert (= (map-size filtered-good-src) 1) "Safe path src must be retained")
    true))

(df TestIsSafeAttrValueRejectsXss [] -> Bool
  :d "Verifies is-safe-attr-value? validates URI schemes"
  (do
    (assert (not (v/is-safe-attr-value? "href" "javascript:alert(1)")) "javascript: must be rejected")
    (assert (not (v/is-safe-attr-value? "HREF" "JAVASCRIPT:alert(1)")) "Case-insensitive javascript: must be rejected")
    (assert (not (v/is-safe-attr-value? "href" "  javascript:evil()")) "Leading whitespace javascript: must be rejected")
    (assert (not (v/is-safe-attr-value? "src" "data:text/html;base64,PHNjcmlwdD5hbGVydCgxKTwvc2NyaXB0Pg==")) "data:text/html must be rejected")
    (assert (v/is-safe-attr-value? "href" "https://secure.example.com") "https: must be accepted")
    (assert (v/is-safe-attr-value? "src" "/images/avatar.jpg") "Relative path must be accepted")
    (assert (v/is-safe-attr-value? "id" "javascript-id") "Attribute non-href/src must allow values")
    true))

(df TestDownsampleNodeStripsXssAttributes [] -> Bool
  :d "Verifies downsample-node strips XSS attributes during AST downsampling"
  (let [(attrs (map-set (map-set (map-empty) "id" "safe-link") "href" "javascript:alert(1)"))
        (child (v/text "Click Me"))
        (node (v/elem "a" attrs (list child)))
        (downsampled-opt (v/downsample-node node))]
    (mt downsampled-opt
      ((some clean-node)
       (let [(res-attrs (v/vnode-attrs clean-node))]
         (assert (map-has? res-attrs "id") "Safe id attribute must be retained")
         (assert (not (map-has? res-attrs "href")) "Dangerous href attribute must be removed")
         true))
      ((none) false))))

(df TestTaskF10GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F10 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F10\"") "Must declare Task-F10")
      (assert (string-contains? f-src "vdom/src/vdom.asl") "Must own vdom/src/vdom.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F10 acceptance checks"
  (do
    (assert (TestFilterAttributesStripsDangerousXss) "TestFilterAttributesStripsDangerousXss must pass")
    (assert (TestIsSafeAttrValueRejectsXss) "TestIsSafeAttrValueRejectsXss must pass")
    (assert (TestDownsampleNodeStripsXssAttributes) "TestDownsampleNodeStripsXssAttributes must pass")
    (assert (TestTaskF10GroundedInPhaseFINSEL) "TestTaskF10GroundedInPhaseFINSEL must pass")
    true))
