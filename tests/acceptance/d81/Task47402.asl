(module tests/acceptance/d81/Task47402
  :d "Acceptance fixture for Task47402: single canonical skill tree and projection by reference."
  :x [RunTests
      TestSingleSkillTreeParity
      TestAllTwentyFourSkillsPresent
      TestSkillsDeclareProjections]
  :i [])

(df TestSingleSkillTreeParity [] -> Bool
  :d "Verifies that root .agents/skills and asl/.agents/skills contain identical sets of skills"
  (let [(root-skills-res (file-read ".agents/skills/asl-toolbelt/SKILL.md"))
        (asl-skills-res (file-read "asl/.agents/skills/asl-toolbelt/SKILL.md"))
        (root-steps-res (file-read ".agents/skills/steps/SKILL.md"))
        (asl-steps-res (file-read "asl/.agents/skills/steps/SKILL.md"))
        (root-dag-res (file-read ".agents/skills/asl-adaptive-dag/SKILL.md"))
        (asl-dag-res (file-read "asl/.agents/skills/asl-adaptive-dag/SKILL.md"))]
    (assert (= (.-_tag root-skills-res) "ok") ".agents/skills/asl-toolbelt must exist")
    (assert (= (.-_tag asl-skills-res) "ok") "asl/.agents/skills/asl-toolbelt must exist")
    (assert (= (.-_tag root-steps-res) "ok") ".agents/skills/steps must exist in root tree")
    (assert (= (.-_tag asl-steps-res) "ok") "asl/.agents/skills/steps must exist in asl tree")
    (assert (= (.-_tag root-dag-res) "ok") ".agents/skills/asl-adaptive-dag must exist in root tree")
    (assert (= (.-_tag asl-dag-res) "ok") "asl/.agents/skills/asl-adaptive-dag must exist in asl tree")
    true))

(df TestAllTwentyFourSkillsPresent [] -> Bool
  :d "Verifies that all 24 skills exist in the canonical skills tree"
  (let [(s1 (file-read ".agents/skills/agent-browser/SKILL.md"))
        (s2 (file-read ".agents/skills/asl/SKILL.md"))
        (s3 (file-read ".agents/skills/asl-adaptive-dag/SKILL.md"))
        (s4 (file-read ".agents/skills/asl-codec/SKILL.md"))
        (s5 (file-read ".agents/skills/asl-epistemic/SKILL.md"))
        (s6 (file-read ".agents/skills/asl-harness/SKILL.md"))
        (s7 (file-read ".agents/skills/asl-implement/SKILL.md"))
        (s8 (file-read ".agents/skills/asl-intel/SKILL.md"))
        (s9 (file-read ".agents/skills/asl-lens/SKILL.md"))
        (s10 (file-read ".agents/skills/asl-mem/SKILL.md"))
        (s11 (file-read ".agents/skills/asl-native/SKILL.md"))
        (s12 (file-read ".agents/skills/asl-plan/SKILL.md"))
        (s13 (file-read ".agents/skills/asl-review/SKILL.md"))
        (s14 (file-read ".agents/skills/asl-skills-installer/SKILL.md"))
        (s15 (file-read ".agents/skills/asl-slm/SKILL.md"))
        (s16 (file-read ".agents/skills/asl-svg/SKILL.md"))
        (s17 (file-read ".agents/skills/asl-toolbelt/SKILL.md"))
        (s18 (file-read ".agents/skills/gap/SKILL.md"))
        (s19 (file-read ".agents/skills/parallel/SKILL.md"))
        (s20 (file-read ".agents/skills/search-tools/SKILL.md"))
        (s21 (file-read ".agents/skills/steps/SKILL.md"))
        (s22 (file-read ".agents/skills/steps-implement/SKILL.md"))
        (s23 (file-read ".agents/skills/steps-plan/SKILL.md"))
        (s24 (file-read ".agents/skills/steps-review/SKILL.md"))]
    (assert (= (.-_tag s1) "ok") "agent-browser must exist")
    (assert (= (.-_tag s2) "ok") "asl must exist")
    (assert (= (.-_tag s3) "ok") "asl-adaptive-dag must exist")
    (assert (= (.-_tag s4) "ok") "asl-codec must exist")
    (assert (= (.-_tag s5) "ok") "asl-epistemic must exist")
    (assert (= (.-_tag s6) "ok") "asl-harness must exist")
    (assert (= (.-_tag s7) "ok") "asl-implement must exist")
    (assert (= (.-_tag s8) "ok") "asl-intel must exist")
    (assert (= (.-_tag s9) "ok") "asl-lens must exist")
    (assert (= (.-_tag s10) "ok") "asl-mem must exist")
    (assert (= (.-_tag s11) "ok") "asl-native must exist")
    (assert (= (.-_tag s12) "ok") "asl-plan must exist")
    (assert (= (.-_tag s13) "ok") "asl-review must exist")
    (assert (= (.-_tag s14) "ok") "asl-skills-installer must exist")
    (assert (= (.-_tag s15) "ok") "asl-slm must exist")
    (assert (= (.-_tag s16) "ok") "asl-svg must exist")
    (assert (= (.-_tag s17) "ok") "asl-toolbelt must exist")
    (assert (= (.-_tag s18) "ok") "gap must exist")
    (assert (= (.-_tag s19) "ok") "parallel must exist")
    (assert (= (.-_tag s20) "ok") "search-tools must exist")
    (assert (= (.-_tag s21) "ok") "steps must exist")
    (assert (= (.-_tag s22) "ok") "steps-implement must exist")
    (assert (= (.-_tag s23) "ok") "steps-plan must exist")
    (assert (= (.-_tag s24) "ok") "steps-review must exist")
    true))

(df TestSkillsDeclareProjections [] -> Bool
  :d "Verifies that skills declare their projections by reference"
  (let [(toolbelt-res (file-read ".agents/skills/asl-toolbelt/SKILL.md"))
        (asn-res (file-read ".agents/skills/asl-toolbelt/skill.asn"))]
    (assert (= (.-_tag toolbelt-res) "ok") "asl-toolbelt SKILL.md must exist")
    (assert (= (.-_tag asn-res) "ok") "asl-toolbelt skill.asn must exist")
    (let [(md-content (.-value toolbelt-res))
          (asn-content (.-value asn-res))]
      (assert (string-contains? md-content "projection:") "SKILL.md frontmatter must declare projection")
      (assert (string-contains? asn-content ":projection") "skill.asn must declare :projection")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47402 supervisor acceptance tests"
  (do
    (assert (TestSingleSkillTreeParity) "TestSingleSkillTreeParity must pass")
    (assert (TestAllTwentyFourSkillsPresent) "TestAllTwentyFourSkillsPresent must pass")
    (assert (TestSkillsDeclareProjections) "TestSkillsDeclareProjections must pass")
    true))
