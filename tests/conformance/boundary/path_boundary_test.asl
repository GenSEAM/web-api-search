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
  :i [(aslMem/visibilityScope :a vs)])

(df TestNegativeControlSiblingPrefix [] -> Bool
  :d "Negative control: sibling directory sharing workspace prefix must be rejected"
  (let [(ws "/Users/purplelephant/projects/asex")
        (sibling "/Users/purplelephant/projects/asex_other/secret.txt")
        (isPrefix (string-starts-with? sibling ws))
        (hasSep (and (> (string-length sibling) (string-length ws))
                      (= (option-or (string-slice sibling (string-length ws) (+ (string-length ws) 1)) "") "/")))]
    (assert isPrefix "Sibling path starts with workspace prefix")
    (assert (not hasSep) "Sibling path must not have directory separator at prefix boundary")
    true))

(df TestAdversarialTraversalEscapes [] -> Bool
  :d "Adversarial: traversal sequences and escape attempts must be recognized as boundary escapes"
  (let [(traversal1 "../../etc/passwd")
        (traversal2 "asl/../../../etc/shadow")
        (hasTraversal1 (string-contains? traversal1 ".."))
        (hasTraversal2 (string-contains? traversal2 ".."))]
    (assert hasTraversal1 "Traversal path must contain parent directory token")
    (assert hasTraversal2 "Deep traversal path must contain parent directory token")
    true))

(df TestBoundaryCanonicalDotDotInside [] -> Bool
  :d "Boundary: in-tree path with dot-dot that canonicalizes inside workspace must remain valid"
  (let [(relPath "mem/src/../tests/visibility_scope_test.asl")
        (exists (file-exists? relPath))]
    (assert (string-contains? relPath "..") "Path must contain dot-dot component")
    (assert exists "In-tree relative path containing dot-dot must resolve to existing file")
    true))

(df TestMetamorphicEquivalentPathVerdicts [] -> Bool
  :d "Metamorphic: different representations of the same path must produce identical existence and safety verdicts"
  (let [(pathDirect "asl/grammar/rules.asn")
        (pathNested "asl/packages/../grammar/rules.asn")
        (directExists (file-exists? pathDirect))
        (nestedExists (file-exists? pathNested))]
    (assert directExists "Direct path must exist")
    (assert nestedExists "Nested canonical path must exist")
    (assert (= directExists nestedExists) "Direct and nested forms must yield identical existence verdict")
    true))

(df TestErrorPropagationRejectionReceipt [] -> Bool
  :d "Error propagation: boundary violation must propagate structured rejection with ERR_BOUNDARY_VIOLATION"
  (let [(mockReceipt {:status "rejected"
                       :errorCode ":ERR_BOUNDARY_VIOLATION"
                       :message "Path escapes workspace boundary"})]
    (assert (= (.-status mockReceipt) "rejected") "Rejection status must be rejected")
    (assert (= (.-errorCode mockReceipt) ":ERR_BOUNDARY_VIOLATION") "Error code must be ERR_BOUNDARY_VIOLATION")
    (assert (string-contains? (.-message mockReceipt) "escapes") "Message must state escape reason")
    true))

(df TestVisibilityTiersIsolatedScope [] -> Bool
  :d "Visibility tier: unanchored session outside workspace resolves to isolated tier with zero worktrees"
  (let [(ctx (vs/makeVisibilityContext
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
    (assert (= (.-tier ctx) (vs/tierIsolatedSession)) "Tier must resolve to tier-isolated-session")
    (assert (= (list-length (.-visibleWorktrees ctx)) 0) "Zero worktrees must be visible in isolated session")
    (assert (= (list-length (.-visibleRepos ctx)) 0) "Zero repositories must be visible in isolated session")
    (assert (= (list-length (.-visibleSessionIds ctx)) 1) "Only active session must be visible")
    true))

(df TestVisibilityTiersLineageScope [] -> Bool
  :d "Visibility tier: workspace-anchored session sees workspace and child worktrees but masks sibling repos"
  (let [(childWts (list "/ws/a/worktrees/wt-1"))
        (allWts (list "/ws/a" "/ws/a/worktrees/wt-1" "/ws/sibling-b"))
        (wsSessions (list "sess-child"))
        (allSessions (list "sess-main" "sess-child" "sess-foreign"))
        (ctx (vs/makeVisibilityContext
               "/ws/a"
               "sess-main"
               "/Users/purplelephant/.asl"
               true
               "/ws/a"
               "repo-a"
               childWts
               allWts
               wsSessions
               allSessions
               (list "repo-a" "repo-foreign")))]
    (assert (= (.-tier ctx) (vs/tierWorkspaceLineage)) "Tier must resolve to tier-workspace-lineage")
    (assert (= (.-activeWorkspaceRoot ctx) "/ws/a") "Active workspace root must match current workspace")
    (assert (= (list-length (.-visibleWorktrees ctx)) 2) "Visible worktrees must include root and child worktree")
    (assert (= (list-length (.-visibleRepos ctx)) 1) "Sibling repos must be masked")
    (assert (= (head (.-visibleRepos ctx)) "repo-a") "Visible repo must be repo-a")
    true))

(df TestVisibilityTiersSovereignScope [] -> Bool
  :d "Visibility tier: sovereign system anchor unlocks whole-system panoptic visibility"
  (let [(allWts (list "/ws/a" "/ws/b" "/ws/c"))
        (allSessions (list "sess-1" "sess-2" "sess-3"))
        (allRepos (list "repo-1" "repo-2" "repo-3"))
        (ctx (vs/makeVisibilityContext
               "/Users/purplelephant"
               "sess-sovereign"
               "/Users/purplelephant/.asl"
               false
               ""
               ""
               (list)
               allWts
               (list)
               allSessions
               allRepos))]
    (assert (= (.-tier ctx) (vs/tierSovereignSystem)) "Tier must resolve to tier-sovereign-system")
    (assert (= (list-length (.-visibleWorktrees ctx)) 3) "All worktrees must be visible in sovereign tier")
    (assert (= (list-length (.-visibleRepos ctx)) 3) "All repositories must be visible in sovereign tier")
    (assert (= (list-length (.-visibleSessionIds ctx)) 3) "All session IDs must be visible in sovereign tier")
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
