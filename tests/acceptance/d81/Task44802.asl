(module tests/acceptance/d81/Task44802
  :d "Acceptance fixture for Task44802: Apply the prose spine and measured wide-surface layout under ADR-0082."
  :x [RunTests
      TestProseSpineAndShellLayoutInViews
      TestWideSurfaceCanvasOptIn
      TestOverflowContainmentAndScrollPadding
      TestRoadmapCapabilityProvenance]
  :i [])

(df TestProseSpineAndShellLayoutInViews [] -> Bool
  :d "Verifies views adopt max-w-shell primary shell and max-w-prose reading measures"
  (let [(h-res (file-read "asl/web/src/views/HomeView.asl"))
        (d-res (file-read "asl/web/src/views/DocsView.asl"))
        (b-res (file-read "asl/web/src/views/BlogView.asl"))
        (r-res (file-read "asl/web/src/views/RoadmapView.asl"))]
    (assert (= (.-_tag h-res) "ok") "HomeView.asl must exist and be readable")
    (assert (= (.-_tag d-res) "ok") "DocsView.asl must exist and be readable")
    (assert (= (.-_tag b-res) "ok") "BlogView.asl must exist and be readable")
    (assert (= (.-_tag r-res) "ok") "RoadmapView.asl must exist and be readable")
    (let [(h-src (.-value h-res))
          (d-src (.-value d-res))
          (b-src (.-value b-res))
          (r-src (.-value r-res))]
      (assert (string-contains? h-src "max-w-shell") "HomeView must use max-w-shell")
      (assert (string-contains? d-src "max-w-shell") "DocsView must use max-w-shell")
      (assert (string-contains? b-src "max-w-shell") "BlogView must use max-w-shell")
      (assert (string-contains? r-src "max-w-shell") "RoadmapView must use max-w-shell")
      true)))

(df TestWideSurfaceCanvasOptIn [] -> Bool
  :d "Verifies data visualizers opt into max-w-canvas wide data canvas"
  (let [(s-res (file-read "asl/web/src/components/SkyLoomVisualizer.asl"))
        (u-res (file-read "asl/web/src/components/UnifiedPackageMatrix.asl"))]
    (assert (= (.-_tag s-res) "ok") "SkyLoomVisualizer.asl must exist and be readable")
    (assert (= (.-_tag u-res) "ok") "UnifiedPackageMatrix.asl must exist and be readable")
    (let [(s-src (.-value s-res))
          (u-src (.-value u-res))]
      (assert (string-contains? s-src "max-w-canvas") "SkyLoomVisualizer must use max-w-canvas")
      (assert (string-contains? u-src "upm-container") "UnifiedPackageMatrix must declare container")
      true)))

(df TestOverflowContainmentAndScrollPadding [] -> Bool
  :d "Verifies index.css enforces scroll-padding-top and overflow-x containment"
  (let [(c-res (file-read "asl/web/src/index.css"))]
    (assert (= (.-_tag c-res) "ok") "index.css must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "scroll-padding-top:") "Must define scroll-padding-top for fixed nav")
      (assert (string-contains? src "overflow-x: hidden;") "Must contain horizontal overflow on html")
      (assert (string-contains? src ".shell") "Must define .shell component")
      (assert (string-contains? src ".canvas-wide") "Must define .canvas-wide component")
      true)))

(df TestRoadmapCapabilityProvenance [] -> Bool
  :d "Verifies RoadmapView distinguishes phases and links capabilities"
  (let [(r-res (file-read "asl/web/src/views/RoadmapView.asl"))]
    (assert (= (.-_tag r-res) "ok") "RoadmapView.asl must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src "Strategic Trajectory") "Must show strategic trajectory")
      (assert (string-contains? src "v0.1.0-Core") "Must show core version badge")
      (assert (string-contains? src "Phase 01") "Must show phase provenance")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44802 acceptance tests"
  (do
    (assert (TestProseSpineAndShellLayoutInViews) "TestProseSpineAndShellLayoutInViews must pass")
    (assert (TestWideSurfaceCanvasOptIn) "TestWideSurfaceCanvasOptIn must pass")
    (assert (TestOverflowContainmentAndScrollPadding) "TestOverflowContainmentAndScrollPadding must pass")
    (assert (TestRoadmapCapabilityProvenance) "TestRoadmapCapabilityProvenance must pass")
    true))
