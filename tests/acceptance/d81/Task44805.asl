(module tests/acceptance/d81/Task44805
  :d "Acceptance fixture for Task44805: Derive audience-specific component patterns under ADR-0082."
  :x [RunTests
      TestHeroAudiencePatterns
      TestAgentWireProtocolPatterns
      TestDocsAndBlogEditorialPatterns
      TestHorizontalScrollContainmentAcrossCodePanels]
  :i [])

(df TestHeroAudiencePatterns [] -> Bool
  :d "Verifies Hero exposes one primary action, one evidence affordance, and explicit capability states"
  (let [(h-res (file-read "asl/web/src/components/Hero.asl"))]
    (assert (= (.-_tag h-res) "ok") "Hero.asl must exist and be readable")
    (let [(h-src (.-value h-res))]
      (assert (string-contains? h-src "install-input") "Hero must provide primary install action")
      (assert (string-contains? h-src "Verified Compile Targets") "Hero must provide compile targets evidence")
      (assert (string-contains? h-src "Core &amp; Wire Protocol: Stable") "Hero must mark stable protocol")
      (assert (string-contains? h-src "Under Development") "Hero must mark under-development capabilities")
      true)))

(df TestAgentWireProtocolPatterns [] -> Bool
  :d "Verifies AgentWireProtocol adopts max-w-shell, overflow containment, and wire evidence"
  (let [(w-res (file-read "asl/web/src/components/AgentWireProtocol.asl"))]
    (assert (= (.-_tag w-res) "ok") "AgentWireProtocol.asl must exist and be readable")
    (let [(w-src (.-value w-res))]
      (assert (string-contains? w-src "max-w-shell") "AgentWireProtocol must use max-w-shell")
      (assert (string-contains? w-src "overflow-x-auto") "AgentWireProtocol must enable horizontal scroll")
      (assert (string-contains? w-src "Agent-to-Agent Mesh Protocol") "AgentWireProtocol must define title")
      true)))

(df TestDocsAndBlogEditorialPatterns [] -> Bool
  :d "Verifies Docs, Blog, and ArticleDetail views adopt max-w-shell and prose spine"
  (let [(d-res (file-read "asl/web/src/views/DocsView.asl"))
        (b-res (file-read "asl/web/src/views/BlogView.asl"))
        (a-res (file-read "asl/web/src/views/ArticleDetailView.asl"))]
    (assert (= (.-_tag d-res) "ok") "DocsView.asl must exist and be readable")
    (assert (= (.-_tag b-res) "ok") "BlogView.asl must exist and be readable")
    (assert (= (.-_tag a-res) "ok") "ArticleDetailView.asl must exist and be readable")
    (let [(d-src (.-value d-res))
          (b-src (.-value b-res))
          (a-src (.-value a-res))]
      (assert (string-contains? d-src "max-w-shell") "DocsView must adopt max-w-shell")
      (assert (string-contains? b-src "max-w-shell") "BlogView must adopt max-w-shell")
      (assert (string-contains? a-src "max-w-shell") "ArticleDetailView must adopt max-w-shell")
      (assert (string-contains? a-src "max-w-prose") "ArticleDetailView must adopt max-w-prose")
      true)))

(df TestHorizontalScrollContainmentAcrossCodePanels [] -> Bool
  :d "Verifies code panels across docs and wire protocol specify overflow-x-auto"
  (let [(d-res (file-read "asl/web/src/views/DocsView.asl"))
        (w-res (file-read "asl/web/src/components/AgentWireProtocol.asl"))]
    (assert (= (.-_tag d-res) "ok") "DocsView.asl must exist and be readable")
    (assert (= (.-_tag w-res) "ok") "AgentWireProtocol.asl must exist and be readable")
    (let [(d-src (.-value d-res))
          (w-src (.-value w-res))]
      (assert (string-contains? d-src "overflow-x-auto") "DocsView must contain code overflow")
      (assert (string-contains? w-src "overflow-x-auto") "AgentWireProtocol must contain code overflow")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44805 acceptance tests"
  (do
    (assert (TestHeroAudiencePatterns) "TestHeroAudiencePatterns must pass")
    (assert (TestAgentWireProtocolPatterns) "TestAgentWireProtocolPatterns must pass")
    (assert (TestDocsAndBlogEditorialPatterns) "TestDocsAndBlogEditorialPatterns must pass")
    (assert (TestHorizontalScrollContainmentAcrossCodePanels) "TestHorizontalScrollContainmentAcrossCodePanels must pass")
    true))
