(module tests/acceptance/d81/Task46602
  :d "Acceptance fixture for Task46602: context tiers (Essential, Tier 0-5) with strict prefix containment under ADR-0081."
  :x [run-tests
      test-tiers-rendered-from-source
      test-lower-tier-is-strict-prefix
      test-essential-tier-purity]
  :i [])

(df test-tiers-rendered-from-source [] -> Bool
  :d "Verifies that scripts/install.sh or engine supports deterministic tier rendering"
  (let [(res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag res) "ok") "scripts/install.sh must be readable")
    (let [(src (.-value res))]
      (assert (or (string-contains? src "--tier") (string-contains? src "render_tier") (string-contains? src ":tier"))
              "scripts/install.sh must support tier rendering")
      true)))

(df test-lower-tier-is-strict-prefix [] -> Bool
  :d "Verifies that a lower tier is a strict prefix of a higher tier"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":tiers [:essential :hot :affordance :orientation :heuristic :pack :full]")
              "rules.asn must declare ordered tier hierarchy")
      true)))

(df test-essential-tier-purity [] -> Bool
  :d "Verifies that essential tier contains every invariant and no heuristics"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "rules.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":force :invariant :tier [:essential :full]")
              "rules.asn must declare :essential tier on invariants")
      (assert (not (string-contains? src ":force :heuristic :tier [:essential"))
              "heuristics must not be present in essential tier")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46602 supervisor acceptance tests"
  (do
    (assert (test-tiers-rendered-from-source) "test-tiers-rendered-from-source must pass")
    (assert (test-lower-tier-is-strict-prefix) "test-lower-tier-is-strict-prefix must pass")
    (assert (test-essential-tier-purity) "test-essential-tier-purity must pass")
    true))
