# Phase 482: Capability Corpus Ground Truth, Schema Separation & Harness Selection

## Phase Summary & Context
- **Phase ID**: `Phase482CapabilityCorpusGroundTruthAndSvgPlayground` (Phase 482)
- **Programme & Decision**: `ADR-0072` (`D72`), Wave 129
- **Roadmap Coordinates**: Recorded in `.asl/mem/tasks/Phase482CapabilityCorpusGroundTruthAndSvgPlayground.asn`
- **Measured Baseline**:
  - `harness/results/capability-ground-truth.asn` does not exist (`test -f harness/results/capability-ground-truth.asn` fails exit 1).
  - `harness/src/capabilities.asl` contains only 5 prototype capabilities (`visualHierarchy`, `contrast`, `composition`, `viewBox`, `evidenceLed`), missing 5 grounded capabilities (`responsiveLayout`, `accessibleText`, `functionalColour`, `spacingScale`, `groupSemantics`).
  - `harness/tests/capabilities_test.asl` executes 14 assertions, verifying only the 5-item prototype.
  - Exclusion filtering is unhandled in `capabilityScore` (terms in `excludes` do not suppress selection).
  - `svgPlayground` generates only a single static sketch without parameterized presets for poster, icon, and explanatory diagram, lacking semantic `title`/`desc` accessibility markup.
  - No benchmark evaluation artifact exists in `harness/results/capability-benchmark.asn`.
- **Phase Purpose**:
  1. Lock research ground truth and provenance from W3C SVG, WCAG 2.2, and GOV.UK Design System in `harness/results/capability-ground-truth.asn`.
  2. Separate Capability paradigm schema from legacy SkillPack utility procedures, enforcing zero leakage and CamelCase markers.
  3. Expand the grounded capability corpus in `harness/src/capabilities.asl` to 10 source-backed entries with weighted links and exclusion rules.
  4. Implement conditional loading, exclusion scoring, token budgeting, and explainable selection receipts.
  5. Provide an accessible SVG capability playground with poster, icon, and diagram presets enforcing viewBox and title/desc accessibility.
  6. Measure compactness, latency, and retrieval quality across 4 evaluation arms in `harness/results/capability-benchmark.asn`.

---

## Invariants & Grounded Contracts

| Invariant | Source Location | Enforcement & Meaning |
|:---|:---|:---|
| **C1 (0 Comments)** | `asl/grammar/rules.asn:1`, `TOKEN_CONVENTIONS.md:12` | Zero line/block comments in any ASL or ASN file. Enforced by `./bin/asl lint`. |
| **C2 (0 Unicode Emojis)** | `asl/tools/asl.c:4211` | Zero raw unicode emojis across all machine surfaces. Enforced by Gate 6. |
| **C3 (Boundary Universalism)** | `asl/grammar/rules.asn:36-38` | Shared foundational helpers only; zero duplicate private helpers. |
| **C4 (Lexical Density)** | `AGENTS.md:120-135` | High signal-to-noise ratio, compact ASN representation. |
| **C5 (Sigil Eradication)** | `asl/grammar/rules.asn:1` | Zero @ or # sigils on identifiers. |
| **D34 (Host Residency)** | `.asl/mem/decisions/Adr0034HostResidentSubstrate.asn:1` | Sovereign engine residency; zero third-party daemon dependencies. |
| **D51 (CamelCase Markers)** | `.asl/mem/decisions/Adr0051TokenEfficiencyFormatAndCamelcaseConventions.asn:1` | CamelCase for composite identifiers, structs, and test functions. |
| **D52 (Enriched Task Context)** | `.asl/mem/tasks/Phase482CapabilityCorpusGroundTruthAndSvgPlayground.asn` | Full task context specification with falsifiable gates and action DAG. |
| **D72 (Browser Demo & Presets)**| `.asl/mem/decisions/Adr0072BrowserDemonstrationSystemConfigurableHarnessesAndSpecializedPresets.asn:1` | Grounded capability corpus and specialized presets. |

---

## Ordered Work Items & Falsifiable Gates

### Item 1: Lock Research Ground Truth and Provenance (Task48201)
- **Title**: Lock Research Ground Truth and Provenance in Machine ASN
- **Owner**: `researcher`
- **Owns**: `harness/results/capability-ground-truth.asn`
- **Baseline Failure**:
  ```bash
  test -f harness/results/capability-ground-truth.asn && ./bin/asl check harness/results/capability-ground-truth.asn
  ```
  *Fails with exit code 1 (file missing).*
- **Actions**:
  1. Record primary facts from W3C SVG (viewBox four-number mapping, title/desc text alternatives, semantic g containers).
  2. Record primary facts from WCAG 2.2 (Criterion 1.4.3 Contrast 4.5:1 normal / 3:1 large, Criterion 1.4.11 Non-text Contrast 3:1, Criterion 1.4.4 Resize Text, Criterion 1.4.12 Text Spacing).
  3. Record primary facts from GOV.UK Design System (prose width 65-75 chars, spacing scale 4/8/12/16/24/32/40/48/64, functional color hierarchy).
  4. Write structured machine ASN in `harness/results/capability-ground-truth.asn` with zero comments (C1) and zero emojis (C2).
  5. Validate delimiter balance and syntax with `./bin/asl check harness/results/capability-ground-truth.asn`.
- **Completion Gate**:
  ```bash
  test -f harness/results/capability-ground-truth.asn && ./bin/asl check harness/results/capability-ground-truth.asn
  ```

---

### Item 2: Separate Capability Schema from Legacy SkillPack (Task48202)
- **Title**: Enforce Schema Separation Between Capabilities and SkillPacks
- **Owner**: `implementer`
- **Owns**: `harness/src/capabilities.asl`, `harness/src/skill_packs.asl`, `harness/manifest.asn`, `harness/tests/capabilities_test.asl`, `harness/tests/skill_packs_test.asl`
- **Baseline Failure**:
  Verify baseline executes existing 14 capability assertions and 28 skill-pack assertions cleanly before schema hardening.
- **Actions**:
  1. Inspect `harness/src/capabilities.asl` and `harness/src/skill_packs.asl` to ensure zero cross-module circularity or schema leakage.
  2. Ensure all fields in `Capability` and `CapabilityLink` adhere to CamelCase: `marker`, `principle`, `scope`, `appliesTo`, `excludes`, `links`, `required`, `defaultLoad`, `membership`, `payload`.
  3. Verify `harness/manifest.asn` exports both modules independently without mutual dependencies.
  4. Verify existing 28 SkillPack assertions in `harness/tests/skill_packs_test.asl` and 14 assertions in `harness/tests/capabilities_test.asl`.
- **Completion Gate**:
  ```bash
  ./bin/asl check harness/src/capabilities.asl && ./bin/asl check harness/src/skill_packs.asl && ./bin/asl test harness/tests/capabilities_test.asl && ./bin/asl test harness/tests/skill_packs_test.asl
  ```

---

### Item 3: Expand Grounded Capability Corpus (Task48203)
- **Title**: Expand Capability Corpus from 5 to 10 Grounded Principles
- **Owner**: `implementer`
- **Owns**: `harness/src/capabilities.asl`, `harness/tests/capabilities_test.asl`
- **Baseline Failure**:
  ```bash
  ./bin/asl eval '(do (import harness/capabilities :as cap) (assert (= (list-length (cap/defaultCapabilities)) 10) "ten") true)'
  ```
  *Fails with assertion failure (returns 5 instead of 10).*
- **Actions**:
  1. In `harness/src/capabilities.asl`, expand `defaultCapabilities` to include:
     - `visualHierarchy` (universal, required)
     - `contrast` (universal, required, WCAG 1.4.3 / 1.4.11)
     - `composition` (conditional)
     - `viewBox` (conditional, required for SVG, W3C)
     - `evidenceLed` (universal, required)
     - `responsiveLayout` (conditional)
     - `accessibleText` (universal, required, WCAG 1.4.4 / title-desc)
     - `functionalColour` (conditional)
     - `spacingScale` (conditional)
     - `groupSemantics` (conditional, W3C semantic g)
  2. Provide explicit `appliesTo`, `excludes`, weighted `links` (strength 0..100), `membership`, and compact `payload` for each capability.
  3. Update `harness/tests/capabilities_test.asl` to verify all 10 capabilities, link weights, and universal/conditional partitioning.
- **Completion Gate**:
  ```bash
  ./bin/asl test harness/tests/capabilities_test.asl && ./bin/asl check harness/results/capability-ground-truth.asn
  ```

---

### Item 4: Implement Conditional Loading and Explainable Selection (Task48204)
- **Title**: Implement Exclusion Filtering, Budget Ceilings and Explainable Receipts
- **Owner**: `implementer`
- **Owns**: `harness/src/capabilities.asl`, `harness/tests/capabilities_test.asl`
- **Baseline Failure**:
  ```bash
  ./bin/asl eval '(do (import harness/capabilities :as cap) (let [(caps (cap/defaultCapabilities)) (res (cap/selectCapabilities caps "denseDataTable poster" 10000 true))] (assert (not (cap/containsMarker (.-selected res) "visualHierarchy")) "visualHierarchy must be excluded by denseDataTable") true)'
  ```
  *Fails because exclusion terms are not checked in `capabilityScore`.*
- **Actions**:
  1. Add `countCapabilityExclusions [(excludes (List Str)) (query Str)] -> I64` in `harness/src/capabilities.asl`.
  2. In `capabilityScore [(cap Capability) (query Str)] -> I64`, check if exclusions match; if exclusion hits > 0, return 0 or heavily penalize score.
  3. Support `CapabilitySelectionReceipt` with selected markers, scores, token expenditure, and explainable selection reasons.
  4. Ensure disabled mode (`enabled = false`) returns an empty selection.
  5. Add unit test assertions in `harness/tests/capabilities_test.asl` verifying exclusion filtering, budget truncation, and receipt integrity.
- **Completion Gate**:
  ```bash
  ./bin/asl test harness/tests/capabilities_test.asl && ./bin/asl test harness/tests/skill_packs_test.asl
  ```

---

### Item 5: Build Accessible SVG Capability Playground (Task48205)
- **Title**: Implement Multi-Preset Accessible SVG Playground
- **Owner**: `implementer`
- **Owns**: `harness/src/capabilities.asl`, `harness/tests/capabilities_test.asl`
- **Baseline Failure**:
  ```bash
  ./bin/asl eval '(do (import harness/capabilities :as cap) (assert (string-contains? (cap/svgPlaygroundScenario "icon") ":desc") "icon must contain desc") true)'
  ```
  *Fails because `svgPlaygroundScenario` does not exist.*
- **Actions**:
  1. In `harness/src/capabilities.asl`, implement `svgPlaygroundScenario [(scenario Str)] -> Str` with support for `"poster"`, `"icon"`, and `"diagram"` presets.
  2. Enforce accessible SVG primitives: root `:v` (viewBox), `:title`, `:desc`, semantic `:g` groupings, and high-contrast WCAG 2.2 compliant fill colors.
  3. Export `svgPlaygroundScenario` in module `:x` list.
  4. In `harness/tests/capabilities_test.asl`, add `test-svg-scenarios` verifying all 3 presets generate valid viewBox and accessibility tags.
- **Completion Gate**:
  ```bash
  ./bin/asl test harness/tests/capabilities_test.asl && ./bin/asl test harness/tests/svg-bench-test.asl
  ```

---

### Item 6: Benchmark Corpus Compactness and Retrieval Quality (Task48206)
- **Title**: Record 4-Arm Retrieval Grounding & Compactness Receipt
- **Owner**: `auditor`
- **Owns**: `harness/results/capability-benchmark.asn`
- **Baseline Failure**:
  ```bash
  test -f harness/results/capability-benchmark.asn && ./bin/asl check harness/results/capability-benchmark.asn
  ```
  *Fails with exit code 1 (file missing).*
- **Actions**:
  1. Generate machine ASN benchmark recording the 4 loading arms:
     - `armOff` (0 tokens, 0 latency)
     - `armUniversalOnly` (compact baseline)
     - `armConditionalTargeted` (query-filtered)
     - `armFullLinked` (full graph)
  2. Record token counts, selection latency, relevance metrics, and SVG validation results.
  3. Write `harness/results/capability-benchmark.asn` following C1 (0 comments) and C2 (0 emojis).
  4. Verify syntax and balance via `./bin/asl check harness/results/capability-benchmark.asn`.
- **Completion Gate**:
  ```bash
  ./bin/asl test --strict-falsify harness/tests/capabilities_test.asl && ./bin/asl test --strict-falsify harness/tests/skill_packs_test.asl && test -f harness/results/capability-benchmark.asn && ./bin/asl check harness/results/capability-benchmark.asn
  ```

---

## Phase Verification Summary
Upon completing all 6 items:
1. `harness/results/capability-ground-truth.asn` validates under `asl check`.
2. All 10 grounded capabilities load with exclusion scoring and token budgeting.
3. Accessible SVG playground produces poster, icon, and diagram sketches with full WCAG 2.2 accessibility tags.
4. `capabilities_test.asl` and `skill_packs_test.asl` execute cleanly under `--strict-falsify`.
5. Full master gate (`./bin/asl gate`) passes 7/7 gates.
