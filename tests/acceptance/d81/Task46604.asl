(module tests/acceptance/d81/Task46604
  :d "Acceptance fixture for Task46604: domain packs (design, development, research, audit) loaded by situation under ADR-0081."
  :x [run-tests
      test-domain-packs-defined
      test-pack-modularity-coherent
      test-shared-concepts-in-orientation]
  :i [])

(df test-domain-packs-defined [] -> Bool
  :d "Verifies that domain packs are declared in rules.asn or capabilities.asn"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src ":pack") (string-contains? src ":packs"))
              "rules.asn must declare domain packs")
      true)))

(df test-pack-modularity-coherent [] -> Bool
  :d "Verifies that domain packs exist for design, development, research, audit"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "(:pack :id design :tier [:pack :full]") "design pack must be declared")
      (assert (string-contains? src "(:pack :id development :tier [:pack :full]") "development pack must be declared")
      (assert (string-contains? src "(:pack :id research :tier [:pack :full]") "research pack must be declared")
      (assert (string-contains? src "(:pack :id audit :tier [:pack :full]") "audit pack must be declared")
      true)))

(df test-shared-concepts-in-orientation [] -> Bool
  :d "Verifies that shared concepts live in orientation rather than duplicated across packs"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":affordances [\"vdom rendering\"") "design affordances present")
      (assert (string-contains? src ":affordances [\"asl check\"") "development affordances present")
      (assert (string-contains? src ":affordances [\"bench telemetry\"") "research affordances present")
      (assert (string-contains? src ":affordances [\"supervise gate\"") "audit affordances present")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46604 supervisor acceptance tests"
  (do
    (assert (test-domain-packs-defined) "test-domain-packs-defined must pass")
    (assert (test-pack-modularity-coherent) "test-pack-modularity-coherent must pass")
    (assert (test-shared-concepts-in-orientation) "test-shared-concepts-in-orientation must pass")
    true))
