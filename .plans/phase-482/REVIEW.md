# Plan Review: Phase 482 Capability Corpus Ground Truth, Schema Separation & Harness Selection

## Independent Auditor Verdict: APPROVED

### 1. Scope & Falsifiability Analysis
- **Item 1 (Research Ground Truth)**: Baseline `test -f harness/results/capability-ground-truth.asn` currently fails exit 1 as the file is absent. Passing criteria requires valid ASN structure without comments/emojis. Verified falsifiable.
- **Item 2 (Schema Separation)**: Verified distinct modules in `harness/src/capabilities.asl` and `harness/src/skill_packs.asl` with independent exports in `harness/manifest.asn`. Existing 14 capability assertions and 28 skillpack assertions provide a safe regression floor.
- **Item 3 (Expanded Corpus)**: Baseline currently contains only 5 capabilities; target requires 10 distinct grounded entries with explicit link weights and exclusions. Evaluator check for 10 entries fails on current code. Verified falsifiable.
- **Item 4 (Conditional Loading & Exclusions)**: Baseline `capabilityScore` completely ignores the `excludes` field. Adding exclusion scoring and verifying suppression of excluded markers is strictly falsifiable.
- **Item 5 (SVG Playground Scenarios)**: `svgPlaygroundScenario` is completely missing from `capabilities.asl`. Adding poster/icon/diagram scenarios with viewBox and title/desc accessibility is strictly falsifiable.
- **Item 6 (Benchmark Receipt)**: `harness/results/capability-benchmark.asn` does not exist. Writing the 4-arm benchmark artifact satisfies gate verification.

### 2. Monorepo Invariant Verification
- **C1 (Zero Comments)**: Verified no line or block comments in `.asn` or `.asl` targets.
- **C2 (Zero Emojis)**: All markers, prompts, and SVGs use ASCII/alphanumeric tokens only.
- **C3 (Boundary Universalism)**: Canonical schema in `harness/src/capabilities.asl`; zero duplicate private parsing helpers.
- **D51 (CamelCase)**: All structs (`Capability`, `CapabilityLink`, `CapabilitySelection`, `CapabilitySelectionReceipt`) and test functions follow CamelCase.
- **D52 (Enriched Task Context)**: Mapped directly to `.asl/mem/tasks/Phase482CapabilityCorpusGroundTruthAndSvgPlayground.asn`.

### 3. Reviewer Recommendations for Execution
1. Implement Item 1 first to establish the normative source claims before referencing them in code.
2. Ensure `svgPlaygroundScenario` returns balanced S-expressions matching the native ASN vector grammar.
3. Keep the 4-arm benchmark artifact concise and machine-parsable.
