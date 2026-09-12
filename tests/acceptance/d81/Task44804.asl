(module tests/acceptance/d81/Task44804
  :d "Acceptance fixture for Task44804: Make navigation, controls and motion responsive and accessible under ADR-0082."
  :x [RunTests
      TestNavbarKeyboardTraversalAndLandmarks
      TestSkipLinkAndAccessibilityInIndexHtml
      TestSearchModalAriaLiveAndKeyboardDismiss
      TestThemeToggleAndAriaLabels
      TestReducedMotionAndFocusVisibleInCss]
  :i [])

(df TestNavbarKeyboardTraversalAndLandmarks [] -> Bool
  :d "Verifies Navbar provides semantic landmarks, aria-labels, max-w-shell, and no transition-all"
  (let [(n-res (file-read "asl/web/src/components/Navbar.asl"))]
    (assert (= (.-_tag n-res) "ok") "Navbar.asl must exist and be readable")
    (let [(n-src (.-value n-res))]
      (assert (string-contains? n-src "<header") "Navbar must use semantic header landmark")
      (assert (string-contains? n-src "Main Navigation") "Navbar must use nav landmark with aria-label")
      (assert (string-contains? n-src "Search documentation") "Search button must carry aria-label")
      (assert (string-contains? n-src "Toggle theme") "Theme button must carry aria-label")
      (assert (string-contains? n-src "max-w-shell") "Navbar must adopt max-w-shell")
      (assert (not (string-contains? n-src "transition-all")) "Navbar must not use transition-all")
      true)))

(df TestSkipLinkAndAccessibilityInIndexHtml [] -> Bool
  :d "Verifies index.html has skip-to-content link and main landmark exists"
  (let [(i-res (file-read "asl/web/index.html"))
        (h-res (file-read "asl/web/src/views/HomeView.asl"))]
    (assert (= (.-_tag i-res) "ok") "index.html must exist and be readable")
    (assert (= (.-_tag h-res) "ok") "HomeView.asl must exist and be readable")
    (let [(i-src (.-value i-res))
          (h-src (.-value h-res))]
      (assert (string-contains? i-src "Skip to main content") "index.html must provide skip link")
      (assert (string-contains? i-src "#main-content") "skip link must target #main-content")
      (assert (string-contains? h-src "main-content") "HomeView must provide id=main-content landmark")
      true)))

(df TestSearchModalAriaLiveAndKeyboardDismiss [] -> Bool
  :d "Verifies SearchModal provides aria-live feedback, keyboard escape, and no transition-all"
  (let [(s-res (file-read "asl/web/src/components/SearchModal.asl"))]
    (assert (= (.-_tag s-res) "ok") "SearchModal.asl must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "aria-live") "SearchModal must provide aria-live region")
      (assert (string-contains? s-src "polite") "SearchModal aria-live must be polite")
      (assert (string-contains? s-src "Escape") "SearchModal must handle Escape key")
      (assert (not (string-contains? s-src "transition-all")) "SearchModal must not use transition-all")
      true)))

(df TestThemeToggleAndAriaLabels [] -> Bool
  :d "Verifies ThemeToggle provides explicit aria-label and clean button semantics"
  (let [(t-res (file-read "asl/web/src/components/ThemeToggle.asl"))]
    (assert (= (.-_tag t-res) "ok") "ThemeToggle.asl must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "Toggle") "ThemeToggle must provide aria-label")
      (assert (not (string-contains? t-src "transition-all")) "ThemeToggle must not use transition-all")
      true)))

(df TestReducedMotionAndFocusVisibleInCss [] -> Bool
  :d "Verifies index.css defines focus-visible and prefers-reduced-motion"
  (let [(c-res (file-read "asl/web/src/index.css"))]
    (assert (= (.-_tag c-res) "ok") "index.css must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":focus-visible") "index.css must define focus-visible")
      (assert (string-contains? c-src "prefers-reduced-motion") "index.css must define prefers-reduced-motion")
      (assert (not (string-contains? c-src "outline: none;")) "index.css must not suppress outline globally without replacement")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44804 acceptance tests"
  (do
    (assert (TestNavbarKeyboardTraversalAndLandmarks) "TestNavbarKeyboardTraversalAndLandmarks must pass")
    (assert (TestSkipLinkAndAccessibilityInIndexHtml) "TestSkipLinkAndAccessibilityInIndexHtml must pass")
    (assert (TestSearchModalAriaLiveAndKeyboardDismiss) "TestSearchModalAriaLiveAndKeyboardDismiss must pass")
    (assert (TestThemeToggleAndAriaLabels) "TestThemeToggleAndAriaLabels must pass")
    (assert (TestReducedMotionAndFocusVisibleInCss) "TestReducedMotionAndFocusVisibleInCss must pass")
    true))
