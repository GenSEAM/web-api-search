(module test_parse_tags_test
  :d "Unit tests for XML/HTML tag parsing and self-closing tags (GATE-01)"
  :x [RunTests
      TestSelfClosingTags
      TestPruneTags
      TestComponentTags]
  :i [(asl-vdom/vdom :a v) (asl-vdom/polyglot :a p)])

(df TestSelfClosingTags [] -> Bool
  :d "Verifies self closing HTML tag recognition"
  (do
    (assert (p/is-self-closing? "img") "img must be self-closing")
    (assert (p/is-self-closing? "input") "input must be self-closing")
    (assert (p/is-self-closing? "br") "br must be self-closing")
    (assert (p/is-self-closing? "hr") "hr must be self-closing")
    (assert (not (p/is-self-closing? "div")) "div must not be self-closing")
    (assert (not (p/is-self-closing? "span")) "span must not be self-closing")
    true))

(df TestPruneTags [] -> Bool
  :d "Verifies non-semantic tag pruning"
  (do
    (assert (v/should-prune-tag? "script") "script must be pruned")
    (assert (v/should-prune-tag? "style") "style must be pruned")
    (assert (v/should-prune-tag? "noscript") "noscript must be pruned")
    (assert (not (v/should-prune-tag? "h1")) "h1 must not be pruned")
    (assert (not (v/should-prune-tag? "p")) "p must not be pruned")
    true))

(df TestComponentTags [] -> Bool
  :d "Verifies custom component tag recognition"
  (do
    (assert (v/is-component-tag? "UserProfile") "UserProfile must be recognized as component")
    (assert (v/is-component-tag? "NavBar") "NavBar must be recognized as component")
    (assert (not (v/is-component-tag? "button")) "button must not be component")
    (assert (not (v/is-component-tag? "div")) "div must not be component")
    true))

(df RunTests [] -> Bool
  :d "Executes tag parsing test suite"
  (do
    (assert (TestSelfClosingTags) "TestSelfClosingTags must pass")
    (assert (TestPruneTags) "TestPruneTags must pass")
    (assert (TestComponentTags) "TestComponentTags must pass")
    true))
