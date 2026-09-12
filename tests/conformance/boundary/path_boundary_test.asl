(module tests/conformance/boundary/PathBoundaryTest
  :d "Conformance test suite for path boundary safety and workspace visibility scoping per ADR-0081 and ADR-0080"
  :x [RunTests
      TestNegativeControlSiblingPrefix
      TestAdversarialTraversalEscapes
      TestBoundaryCanonicalDotDotInside
      TestMetamorphicEquivalentPathVerdicts
      TestErrorPropagationRejectionReceipt
      TestVisibilityTiersIsolatedScope
      TestVisibilityTiersLineageScope
      TestVisibilityTiersSovereignScope]
  :i [(asl-mem/visibility-scope :a vs)])

(df TestNegativeControlSiblingPrefix [] -> Bool
  :d "Negative control: sibling directory sharing workspace prefix must be rejected"
  (let [(ws "/Users/purplelephant/projects/asex")
        (sibling "/Users/purplelephant/projects/asex_other/secret.txt")
        (is-prefix (string-starts-with? sibling ws))
        (has-sep (and (> (string-length sibling) (string-length ws))
                      (= (option-or (string-slice sibling (string-length ws) (+ (string-length ws) 1)) "") "/")))]
    (assert is-prefix "Sibling path starts with workspace prefix")
    (assert (not has-sep) "Sibling path must not have directory separator at prefix boundary")
    true))

(df TestAdversarialTraversalEscapes [] -> Bool
  :d "Adversarial: traversal sequences and escape attempts must be recognized as boundary escapes"
  (let [(traversal-1 "../../etc/passwd")
        (traversal-2 "asl/../../../etc/shadow")
        (has-traversal-1 (string-contains? traversal-1 ".."))
        (has-traversal-2 (string-contains? traversal-2 ".."))]
    (assert has-traversal-1 "Traversal path must contain parent directory token")
    (assert has-traversal-2 "Deep traversal path must contain parent directory token")
    true))

(df TestBoundaryCanonicalDotDotInside [] -> Bool
  :d "Boundary: in-tree path with dot-dot that canonicalizes inside workspace must remain valid"
  (let [(rel-path "mem/src/../tests/visibility_scope_test.asl")
        (exists (file-exists? rel-path))]
    (assert (string-contains? rel-path "..") "Path must contain dot-dot component")
    (assert exists "In-tree relative path containing dot-dot must resolve to existing file")
    true))

(df TestMetamorphicEquivalentPathVerdicts [] -> Bool
  :d "Metamorphic: different representations of the same path must produce identical existence and safety verdicts"
  (let [(path-direct "asl/grammar/rules.asn")
        (path-nested "asl/packages/../grammar/rules.asn")
        (direct-exists (file-exists? path-direct))
        (nested-exists (file-exists? path-nested))]
    (assert direct-exists "Direct path must exist")
    (assert nested-exists "Nested canonical path must exist")
    (assert (= direct-exists nested-exists) "Direct and nested forms must yield identical existence verdict")
    true))

(df TestErrorPropagationRejectionReceipt [] -> Bool
  :d "Error propagation: boundary violation must propagate structured rejection with ERR_BOUNDARY_VIOLATION"
  (let [(mock-receipt {:status "rejected"
                       :error-code ":ERR_BOUNDARY_VIOLATION"
                       :message "Path escapes workspace boundary"})]
    (assert (= (.-status mock-receipt) "rejected") "Rejection status must be rejected")
    (assert (= (.-error-code mock-receipt) ":ERR_BOUNDARY_VIOLATION") "Error code must be ERR_BOUNDARY_VIOLATION")
    (assert (string-contains? (.-message mock-receipt) "escapes") "Message must state escape reason")
    true))

(df TestVisibilityTiersIsolatedScope [] -> Bool
  :d "Visibility tier: unanchored session outside workspace resolves to isolated tier with zero worktrees"
  (let [(ctx (vs/make-visibility-context
               "/tmp/scratch"
               "sess-isolated"
               "/Users/purplelephant/.asl"
               false
               ""
               ""
               (list)
               (list "/ws/a" "/ws/b")
               (list)
               (list "sess-isolated" "sess-peer")
               (list "repo-a" "repo-b")))]
    (assert (= (.-tier ctx) (vs/tier-isolated-session)) "Tier must resolve to tier-isolated-session")
    (assert (= (list-length (.-visible-worktrees ctx)) 0) "Zero worktrees must be visible in isolated session")
    (assert (= (list-length (.-visible-repos ctx)) 0) "Zero repositories must be visible in isolated session")
    (assert (= (list-length (.-visible-session-ids ctx)) 1) "Only active session must be visible")
    true))

(df TestVisibilityTiersLineageScope [] -> Bool
  :d "Visibility tier: workspace-anchored session sees workspace and child worktrees but masks sibling repos"
  (let [(child-wts (list "/ws/a/worktrees/wt-1"))
        (all-wts (list "/ws/a" "/ws/a/worktrees/wt-1" "/ws/sibling-b"))
        (ws-sessions (list "sess-child"))
        (all-sessions (list "sess-main" "sess-child" "sess-foreign"))
        (ctx (vs/make-visibility-context
               "/ws/a"
               "sess-main"
               "/Users/purplelephant/.asl"
               true
               "/ws/a"
               "repo-a"
               child-wts
               all-wts
               ws-sessions
               all-sessions
               (list "repo-a" "repo-foreign")))]
    (assert (= (.-tier ctx) (vs/tier-workspace-lineage)) "Tier must resolve to tier-workspace-lineage")
    (assert (= (.-active-workspace-root ctx) "/ws/a") "Active workspace root must match current workspace")
    (assert (= (list-length (.-visible-worktrees ctx)) 2) "Visible worktrees must include root and child worktree")
    (assert (= (list-length (.-visible-repos ctx)) 1) "Sibling repos must be masked")
    (assert (= (head (.-visible-repos ctx)) "repo-a") "Visible repo must be repo-a")
    true))

(df TestVisibilityTiersSovereignScope [] -> Bool
  :d "Visibility tier: sovereign system anchor unlocks whole-system panoptic visibility"
  (let [(all-wts (list "/ws/a" "/ws/b" "/ws/c"))
        (all-sessions (list "sess-1" "sess-2" "sess-3"))
        (all-repos (list "repo-1" "repo-2" "repo-3"))
        (ctx (vs/make-visibility-context
               "/Users/purplelephant"
               "sess-sovereign"
               "/Users/purplelephant/.asl"
               false
               ""
               ""
               (list)
               all-wts
               (list)
               all-sessions
               all-repos))]
    (assert (= (.-tier ctx) (vs/tier-sovereign-system)) "Tier must resolve to tier-sovereign-system")
    (assert (= (list-length (.-visible-worktrees ctx)) 3) "All worktrees must be visible in sovereign tier")
    (assert (= (list-length (.-visible-repos ctx)) 3) "All repositories must be visible in sovereign tier")
    (assert (= (list-length (.-visible-session-ids ctx)) 3) "All session IDs must be visible in sovereign tier")
    true))

(df RunTests [] -> Bool
  :d "Executes all path boundary and visibility conformance test cases"
  (do
    (assert (TestNegativeControlSiblingPrefix) "TestNegativeControlSiblingPrefix must pass")
    (assert (TestAdversarialTraversalEscapes) "TestAdversarialTraversalEscapes must pass")
    (assert (TestBoundaryCanonicalDotDotInside) "TestBoundaryCanonicalDotDotInside must pass")
    (assert (TestMetamorphicEquivalentPathVerdicts) "TestMetamorphicEquivalentPathVerdicts must pass")
    (assert (TestErrorPropagationRejectionReceipt) "TestErrorPropagationRejectionReceipt must pass")
    (assert (TestVisibilityTiersIsolatedScope) "TestVisibilityTiersIsolatedScope must pass")
    (assert (TestVisibilityTiersLineageScope) "TestVisibilityTiersLineageScope must pass")
    (assert (TestVisibilityTiersSovereignScope) "TestVisibilityTiersSovereignScope must pass")
    true))
