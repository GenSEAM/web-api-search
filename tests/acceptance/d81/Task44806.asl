(module tests/acceptance/d81/Task44806
  :d "Acceptance fixture for Task44806: Run visual evidence, viewport and design-cost review under ADR-0082."
  :x [RunTests
      TestSuperviseGateDispatchAndRejectionContract
      TestViewportGeometryAndReadingMeasures
      TestWcagContrastAndFocusVisiblePolicy
      TestCapabilityProvenanceAndStateIntegrity
      TestDesignCostTokenizerAndCorpusContract]
  :i [])

(df TestSuperviseGateDispatchAndRejectionContract [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict-falsify execution, and multi-stage audits"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src "TASK_DEFINITIONS") "SuperviseGate.sh must verify unique task registration")
      (assert (string-contains? src "test --strict-falsify") "SuperviseGate.sh must run tests under strict falsify")
      (assert (string-contains? src "audit gates") "SuperviseGate.sh must run pure ASL audit gates")
      (assert (string-contains? src "audit consistency") "SuperviseGate.sh must run consistency audit")
      true)))

(df TestViewportGeometryAndReadingMeasures [] -> Bool
  :d "Verifies primary shell is 72rem, data canvas opt-in is 80rem, prose measure is 68ch, and overflow is contained"
  (let [(c-res (file-read "asl/web/src/index.css"))
        (t-res (file-read "asl/web/tailwind.config.js"))
        (s-res (file-read "asl/web/styles.asn"))
        (h-res (file-read "asl/web/index.html"))]
    (assert (= (.-_tag c-res) "ok") "index.css readable")
    (assert (= (.-_tag t-res) "ok") "tailwind.config.js readable")
    (assert (= (.-_tag s-res) "ok") "styles.asn readable")
    (assert (= (.-_tag h-res) "ok") "index.html readable")
    (let [(c-src (.-value c-res))
          (t-src (.-value t-res))
          (s-src (.-value s-res))
          (h-src (.-value h-res))]
      (assert (string-contains? c-src "max-width: 72rem;") "index.css must define shell 72rem")
      (assert (string-contains? c-src "max-width: 80rem;") "index.css must define canvas 80rem")
      (assert (string-contains? c-src "overflow-x: hidden;") "index.css must contain overflow on html")
      (assert (string-contains? t-src "shell: '72rem'") "tailwind must define shell 72rem")
      (assert (string-contains? t-src "canvas: '80rem'") "tailwind must define canvas 80rem")
      (assert (string-contains? t-src "prose: '68ch'") "tailwind must define prose 68ch")
      (assert (string-contains? s-src "72rem") "styles.asn must define 72rem shell")
      (assert (string-contains? s-src "80rem") "styles.asn must define 80rem canvas")
      (assert (string-contains? s-src "68ch") "styles.asn must define 68ch prose")
      (assert (string-contains? h-src "viewport") "index.html must define viewport meta")
      (assert (not (string-contains? h-src "user-scalable=no")) "index.html must not disable user zoom")
      true)))

(df TestWcagContrastAndFocusVisiblePolicy [] -> Bool
  :d "Verifies tokens satisfy WCAG 2.2 AA contrast standards, explicit focus-visible outline, and reduced-motion rule"
  (let [(c-res (file-read "asl/web/src/index.css"))
        (s-res (file-read "asl/web/styles.asn"))]
    (assert (= (.-_tag c-res) "ok") "index.css readable")
    (assert (= (.-_tag s-res) "ok") "styles.asn readable")
    (let [(c-src (.-value c-res))
          (s-src (.-value s-res))]
      (assert (string-contains? c-src ":focus-visible") "index.css must define focus-visible")
      (assert (string-contains? c-src "outline: 2px solid") "focus-visible must provide 2px solid outline")
      (assert (string-contains? c-src "prefers-reduced-motion") "index.css must respect prefers-reduced-motion")
      (assert (string-contains? s-src ":signal \"126 34 206\"") "styles.asn light signal token")
      (assert (string-contains? s-src ":signal \"176 96 255\"") "styles.asn dark signal token")
      (assert (string-contains? s-src ":ink \"24 18 36\"") "styles.asn light ink token")
      (assert (string-contains? s-src ":ink \"246 244 255\"") "styles.asn dark ink token")
      true)))

(df TestCapabilityProvenanceAndStateIntegrity [] -> Bool
  :d "Verifies capability claims expose provenance and differentiate planned from verified states"
  (let [(h-res (file-read "asl/web/src/components/Hero.asl"))
        (r-res (file-read "asl/web/src/views/RoadmapView.asl"))]
    (assert (= (.-_tag h-res) "ok") "Hero.asl readable")
    (assert (= (.-_tag r-res) "ok") "RoadmapView.asl readable")
    (let [(h-src (.-value h-res))
          (r-src (.-value r-res))]
      (assert (string-contains? h-src "Core &amp; Wire Protocol: Stable") "Hero must disclose core protocol status")
      (assert (string-contains? h-src "Extended Tools: Under Development") "Hero must disclose extended tools status")
      (assert (string-contains? r-src "Strategic Trajectory") "Roadmap must show strategic trajectory")
      (assert (string-contains? r-src "v0.1.0-Core") "Roadmap must show version badge")
      true)))

(df TestDesignCostTokenizerAndCorpusContract [] -> Bool
  :d "Verifies ADR-0082 settles design system choices and audit requirements"
  (let [(a-res (file-read ".asl/mem/decisions/Adr0082InstrumentedEditorialWebDesignSystem.asn"))
        (d-res (file-read ".asl/mem/reviews/D82DesignPlanReview.asn"))]
    (assert (= (.-_tag a-res) "ok") "ADR-0082 readable")
    (assert (= (.-_tag d-res) "ok") "D82DesignPlanReview.asn readable")
    (let [(a-src (.-value a-res))
          (d-src (.-value d-res))]
      (assert (string-contains? a-src "Instrumented Editorial") "ADR-0082 must settle Instrumented Editorial frame")
      (assert (string-contains? a-src "(:choice :id width") "ADR-0082 must settle width choice")
      (assert (string-contains? a-src "(:choice :id palette") "ADR-0082 must settle palette choice")
      (assert (string-contains? a-src "(:choice :id evidence") "ADR-0082 must settle evidence choice")
      (assert (string-contains? d-src ":verdict :approve") "D82DesignPlanReview must approve design plan")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44806 visual evidence, viewport, and design-cost acceptance tests"
  (do
    (assert (TestSuperviseGateDispatchAndRejectionContract) "TestSuperviseGateDispatchAndRejectionContract must pass")
    (assert (TestViewportGeometryAndReadingMeasures) "TestViewportGeometryAndReadingMeasures must pass")
    (assert (TestWcagContrastAndFocusVisiblePolicy) "TestWcagContrastAndFocusVisiblePolicy must pass")
    (assert (TestCapabilityProvenanceAndStateIntegrity) "TestCapabilityProvenanceAndStateIntegrity must pass")
    (assert (TestDesignCostTokenizerAndCorpusContract) "TestDesignCostTokenizerAndCorpusContract must pass")
    true))
