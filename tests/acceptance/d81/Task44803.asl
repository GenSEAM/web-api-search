(module tests/acceptance/d81/Task44803
  :d "Acceptance fixture for Task44803: Replace generic gradient surfaces with calm technical hierarchy under ADR-0082."
  :x [RunTests
      TestNoUnapprovedGradientsInHeroAndEcosystem
      TestCalmHierarchyAndAriaHiddenInCosmicLandscape
      TestSingleSignalAccentAndDividerTreatments
      TestCapabilityStateProvenanceInHero
      TestNoForbiddenAccentsInViewsAndComponents
      TestNoTransitionAllAcrossOwnedSurfaces]
  :i [])

(df TestNoUnapprovedGradientsInHeroAndEcosystem [] -> Bool
  :d "Verifies Hero and Ecosystem do not contain unapproved generic gradients or transition-all"
  (let [(h-res (file-read "asl/web/src/components/Hero.asl"))
        (e-res (file-read "asl/web/src/components/Ecosystem.asl"))]
    (assert (= (.-_tag h-res) "ok") "Hero.asl must exist and be readable")
    (assert (= (.-_tag e-res) "ok") "Ecosystem.asl must exist and be readable")
    (let [(h-src (.-value h-res))
          (e-src (.-value e-res))]
      (assert (not (string-contains? h-src "bg-gradient-")) "Hero.asl must not contain unapproved gradients")
      (assert (not (string-contains? h-src "from-purple-")) "Hero.asl must not contain from-purple- gradient")
      (assert (not (string-contains? h-src "to-indigo-")) "Hero.asl must not contain to-indigo- gradient")
      (assert (not (string-contains? h-src "transition-all")) "Hero.asl must not contain transition-all")
      (assert (not (string-contains? e-src "from-purple-700")) "Ecosystem.asl must not contain from-purple-700 gradient")
      (assert (not (string-contains? e-src "to-indigo-600")) "Ecosystem.asl must not contain to-indigo-600 gradient")
      (assert (not (string-contains? e-src "transition-all")) "Ecosystem.asl must not contain transition-all")
      true)))

(df TestCalmHierarchyAndAriaHiddenInCosmicLandscape [] -> Bool
  :d "Verifies decorative CosmicLandscapeBackground includes aria-hidden and calm hierarchy"
  (let [(c-res (file-read "asl/web/src/components/CosmicLandscapeBackground.asl"))]
    (assert (= (.-_tag c-res) "ok") "CosmicLandscapeBackground.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "aria-hidden") "CosmicLandscapeBackground.asl must mark decorative SVG with aria-hidden")
      (assert (not (string-contains? c-src "text-purple-400")) "CosmicLandscapeBackground.asl must not use text-purple-400")
      (assert (not (string-contains? c-src "bg-purple-600/12")) "CosmicLandscapeBackground.asl must not use bg-purple-600/12")
      (assert (not (string-contains? c-src "bg-indigo-600/10")) "CosmicLandscapeBackground.asl must not use bg-indigo-600/10")
      (assert (not (string-contains? c-src "transition-all")) "CosmicLandscapeBackground.asl must not use transition-all")
      true)))

(df TestSingleSignalAccentAndDividerTreatments [] -> Bool
  :d "Verifies single signal accent and hairline/border divider treatments"
  (let [(h-res (file-read "asl/web/src/components/Hero.asl"))
        (k-res (file-read "asl/web/src/components/KeyCapabilities.asl"))]
    (assert (= (.-_tag h-res) "ok") "Hero.asl must exist and be readable")
    (assert (= (.-_tag k-res) "ok") "KeyCapabilities.asl must exist and be readable")
    (let [(h-src (.-value h-res))
          (k-src (.-value k-res))]
      (assert (string-contains? h-src "text-signal") "Hero.asl must use text-signal accent")
      (assert (string-contains? h-src "border-line") "Hero.asl must use border-line divider")
      (assert (string-contains? k-src "text-signal") "KeyCapabilities.asl must use text-signal accent")
      (assert (not (string-contains? k-src "text-purple-300")) "KeyCapabilities.asl must not use text-purple-300")
      (assert (not (string-contains? k-src "transition-all")) "KeyCapabilities.asl must not use transition-all")
      true)))

(df TestCapabilityStateProvenanceInHero [] -> Bool
  :d "Verifies Hero displays explicit capability state provenance and verified targets"
  (let [(h-res (file-read "asl/web/src/components/Hero.asl"))]
    (assert (= (.-_tag h-res) "ok") "Hero.asl must exist and be readable")
    (let [(h-src (.-value h-res))]
      (assert (string-contains? h-src "Core &amp; Wire Protocol: Stable") "Hero.asl must show stable wire protocol status")
      (assert (string-contains? h-src "Under Development") "Hero.asl must show under development status")
      (assert (string-contains? h-src "Verified Compile Targets") "Hero.asl must show verified targets section")
      true)))

(df TestNoForbiddenAccentsInViewsAndComponents [] -> Bool
  :d "Verifies views and components do not use arbitrary purple/indigo classes"
  (let [(ev-res (file-read "asl/web/src/views/EcosystemView.asl"))
        (pt-res (file-read "asl/web/src/views/playground/PlaygroundTable.asl"))
        (f-res (file-read "asl/web/src/components/Footer.asl"))
        (ps-res (file-read "asl/web/src/components/PolyglotStudio.asl"))]
    (assert (= (.-_tag ev-res) "ok") "EcosystemView.asl must exist and be readable")
    (assert (= (.-_tag pt-res) "ok") "PlaygroundTable.asl must exist and be readable")
    (assert (= (.-_tag f-res) "ok") "Footer.asl must exist and be readable")
    (assert (= (.-_tag ps-res) "ok") "PolyglotStudio.asl must exist and be readable")
    (let [(ev-src (.-value ev-res))
          (pt-src (.-value pt-res))
          (f-src (.-value f-res))
          (ps-src (.-value ps-res))]
      (assert (not (string-contains? ev-src "border-purple-500")) "EcosystemView.asl must not use border-purple-500")
      (assert (not (string-contains? ev-src "text-purple-300")) "EcosystemView.asl must not use text-purple-300")
      (assert (not (string-contains? pt-src "bg-purple-400")) "PlaygroundTable.asl must not use bg-purple-400")
      (assert (not (string-contains? pt-src "text-purple-300")) "PlaygroundTable.asl must not use text-purple-300")
      (assert (not (string-contains? f-src "bg-purple-500")) "Footer.asl must not use bg-purple-500")
      (assert (not (string-contains? ps-src "text-purple-200")) "PolyglotStudio.asl must not use text-purple-200")
      true)))

(df TestNoTransitionAllAcrossOwnedSurfaces [] -> Bool
  :d "Verifies owned components avoid transition-all in favor of targeted transitions"
  (let [(eb-res (file-read "asl/web/src/components/EngineeringBlog.asl"))
        (ht-res (file-read "asl/web/src/components/HarnessToolkit.asl"))
        (iv-res (file-read "asl/web/src/views/InIdeView.asl"))
        (pv-res (file-read "asl/web/src/views/PlaygroundView.asl"))]
    (assert (= (.-_tag eb-res) "ok") "EngineeringBlog.asl must exist and be readable")
    (assert (= (.-_tag ht-res) "ok") "HarnessToolkit.asl must exist and be readable")
    (assert (= (.-_tag iv-res) "ok") "InIdeView.asl must exist and be readable")
    (assert (= (.-_tag pv-res) "ok") "PlaygroundView.asl must exist and be readable")
    (let [(eb-src (.-value eb-res))
          (ht-src (.-value ht-res))
          (iv-src (.-value iv-res))
          (pv-src (.-value pv-res))]
      (assert (not (string-contains? eb-src "transition-all")) "EngineeringBlog.asl must not use transition-all")
      (assert (not (string-contains? ht-src "transition-all")) "HarnessToolkit.asl must not use transition-all")
      (assert (not (string-contains? iv-src "transition-all")) "InIdeView.asl must not use transition-all")
      (assert (not (string-contains? pv-src "transition-all")) "PlaygroundView.asl must not use transition-all")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44803 acceptance tests"
  (do
    (assert (TestNoUnapprovedGradientsInHeroAndEcosystem) "TestNoUnapprovedGradientsInHeroAndEcosystem must pass")
    (assert (TestCalmHierarchyAndAriaHiddenInCosmicLandscape) "TestCalmHierarchyAndAriaHiddenInCosmicLandscape must pass")
    (assert (TestSingleSignalAccentAndDividerTreatments) "TestSingleSignalAccentAndDividerTreatments must pass")
    (assert (TestCapabilityStateProvenanceInHero) "TestCapabilityStateProvenanceInHero must pass")
    (assert (TestNoForbiddenAccentsInViewsAndComponents) "TestNoForbiddenAccentsInViewsAndComponents must pass")
    (assert (TestNoTransitionAllAcrossOwnedSurfaces) "TestNoTransitionAllAcrossOwnedSurfaces must pass")
    true))
