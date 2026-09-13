(module test_parse_tags_test
  :d "Unit tests for XML/HTML tag parsing and self-closing tags (GATE-01)"
  :x [RunTests
      TestSelfClosingTags
      TestPruneTags
      TestComponentTags]
  :i [(aslVdom/vdom :a v) (aslVdom/polyglot :a p)])

(df TestSelfClosingTags [] -> Bool
  :d "Verifies self closing HTML tag recognition"
  (do
    (assert (p/isSelfClosing? "img") "img must be self-closing")
    (assert (p/isSelfClosing? "input") "input must be self-closing")
    (assert (p/isSelfClosing? "br") "br must be self-closing")
    (assert (p/isSelfClosing? "hr") "hr must be self-closing")
    (assert (not (p/isSelfClosing? "div")) "div must not be self-closing")
    (assert (not (p/isSelfClosing? "span")) "span must not be self-closing")
    true))

(df TestPruneTags [] -> Bool
  :d "Verifies non-semantic tag pruning"
  (do
    (assert (v/shouldPruneTag? "script") "script must be pruned")
    (assert (v/shouldPruneTag? "style") "style must be pruned")
    (assert (v/shouldPruneTag? "noscript") "noscript must be pruned")
    (assert (not (v/shouldPruneTag? "h1")) "h1 must not be pruned")
    (assert (not (v/shouldPruneTag? "p")) "p must not be pruned")
    true))

(df TestComponentTags [] -> Bool
  :d "Verifies custom component tag recognition"
  (do
    (assert (v/isComponentTag? "UserProfile") "UserProfile must be recognized as component")
    (assert (v/isComponentTag? "NavBar") "NavBar must be recognized as component")
    (assert (not (v/isComponentTag? "button")) "button must not be component")
    (assert (not (v/isComponentTag? "div")) "div must not be component")
    true))

(df RunTests [] -> Bool
  :d "Executes tag parsing test suite"
  (do
    (assert (TestSelfClosingTags) "TestSelfClosingTags must pass")
    (assert (TestPruneTags) "TestPruneTags must pass")
    (assert (TestComponentTags) "TestComponentTags must pass")
    true))
