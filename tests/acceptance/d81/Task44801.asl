(module tests/acceptance/d81/Task44801
  :d "Acceptance fixture for Task44801: Freeze the Instrumented Editorial frame and token contract under ADR-0082."
  :x [RunTests
      TestSingleSignalAccentInStylesAsn
      TestMeasuredWidthPolicyAndCanvasOptIn
      TestGeneratedCssAndTailwindSync
      TestRestrainedElevationAndGeometry]
  :i [])

(df TestSingleSignalAccentInStylesAsn [] -> Bool
  :d "Verifies styles.asn declares a single signal accent and light/dark theme roles"
  (let [(s-res (file-read "asl/web/styles.asn"))]
    (assert (= (.-_tag s-res) "ok") "styles.asn must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src ":signal ") "Must define signal token")
      (assert (string-contains? src ":signal-soft ") "Must define signal-soft token")
      (assert (string-contains? src ":ground ") "Must define ground token")
      (assert (string-contains? src ":surface ") "Must define surface token")
      (assert (string-contains? src ":ink ") "Must define ink token")
      (assert (not (string-contains? src ":accent-2")) "Must not declare a second accent")
      (assert (not (string-contains? src ":accent-secondary")) "Must not declare a secondary accent")
      true)))

(df TestMeasuredWidthPolicyAndCanvasOptIn [] -> Bool
  :d "Verifies width policy specifies 72rem primary shell and 80rem wide canvas opt-in"
  (let [(s-res (file-read "asl/web/styles.asn"))
        (t-res (file-read "asl/web/tailwind.config.js"))]
    (assert (= (.-_tag s-res) "ok") "styles.asn must exist and be readable")
    (assert (= (.-_tag t-res) "ok") "tailwind.config.js must exist and be readable")
    (let [(s-src (.-value s-res))
          (t-src (.-value t-res))]
      (assert (string-contains? s-src "72rem") "styles.asn must declare 72rem primary shell")
      (assert (string-contains? s-src "80rem") "styles.asn must declare 80rem data canvas")
      (assert (string-contains? s-src "68ch") "styles.asn must declare 68ch prose measure")
      (assert (string-contains? t-src "shell: '72rem'") "tailwind.config.js must export shell 72rem")
      (assert (string-contains? t-src "canvas: '80rem'") "tailwind.config.js must export canvas 80rem")
      (assert (string-contains? t-src "prose: '68ch'") "tailwind.config.js must export prose 68ch")
      true)))

(df TestGeneratedCssAndTailwindSync [] -> Bool
  :d "Verifies index.css mirrors styles.asn tokens and enforces clean CSS variable definitions"
  (let [(c-res (file-read "asl/web/src/index.css"))]
    (assert (= (.-_tag c-res) "ok") "index.css must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "--ground:") "index.css must define --ground")
      (assert (string-contains? src "--surface:") "index.css must define --surface")
      (assert (string-contains? src "--signal:") "index.css must define --signal")
      (assert (string-contains? src "--signal-soft:") "index.css must define --signal-soft")
      (assert (string-contains? src ".shell") "index.css must define .shell class")
      (assert (string-contains? src ".canvas-wide") "index.css must define .canvas-wide class")
      true)))

(df TestRestrainedElevationAndGeometry [] -> Bool
  :d "Verifies styles.asn declares restrained elevation policy and geometry"
  (let [(s-res (file-read "asl/web/styles.asn"))
        (a-res (file-read ".asl/mem/decisions/Adr0082InstrumentedEditorialWebDesignSystem.asn"))]
    (assert (= (.-_tag s-res) "ok") "styles.asn must exist and be readable")
    (assert (= (.-_tag a-res) "ok") "ADR-0082 must exist and be readable")
    (let [(s-src (.-value s-res))
          (a-src (.-value a-res))]
      (assert (string-contains? s-src ":shadow-strength") "styles.asn must define shadow-strength")
      (assert (string-contains? a-src ":id frame") "ADR-0082 must settle frame choice")
      (assert (string-contains? a-src ":id width") "ADR-0082 must settle width choice")
      (assert (string-contains? a-src ":id palette") "ADR-0082 must settle palette choice")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44801 acceptance tests"
  (do
    (assert (TestSingleSignalAccentInStylesAsn) "TestSingleSignalAccentInStylesAsn must pass")
    (assert (TestMeasuredWidthPolicyAndCanvasOptIn) "TestMeasuredWidthPolicyAndCanvasOptIn must pass")
    (assert (TestGeneratedCssAndTailwindSync) "TestGeneratedCssAndTailwindSync must pass")
    (assert (TestRestrainedElevationAndGeometry) "TestRestrainedElevationAndGeometry must pass")
    true))
