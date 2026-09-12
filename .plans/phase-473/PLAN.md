# Phase 473 Plan: Configuration and Distribution Truth

## Status
- **Phase**: Phase473ConfigurationAndDistributionTruth
- **Priority**: Developer Tooling & Verification Ground Truth (Top priority per user instruction)
- **Status**: in-progress

## Context & Baseline Findings

1. **Task47301 (A registry may not name a symbol that does not exist)**:
   - **Baseline**: 63 phantom and misplaced symbols exist across 8 grammar registries (`pack`, `harness`, `web-api-search`, `intel`, `agent-core`, `crawler`, `mem`, `vdom`).
   - `Gate 6` in `asl/tools/asl.c` (`run_gate_6_grammar`) only counts symbols, rationales, checks delimiters, and checks emoji invariant (`c-0002`). It never checks whether a declared symbol exists in the package defining it or if it is misplaced.
   - For example: `pipeline-execute`, `DaemonConfig`, `LashLaminationSpec`, `EyeInstance`, `CacheProvider` exist in `grammar.asn` registries with 0 definitions across the repository.
   - Symbols like `XRefEdge`, `XRefGraph`, `make-xref-graph` are defined in package `mem` but declared in `intel/grammar.asn` (misplaced).
   - **Remedy**:
     1. Enhance `run_gate_6_grammar` in `asl/tools/asl.c` to parse all declared symbols in each package's `grammar.asn` and verify their definitions exist within that package's `.asl` files (via AST definitions `(df...`, `(dfs...`, `(dfe...`, `(dfp...`, enum constructors `(:c...`, or module exports `:x [...]`).
     2. If a symbol is defined in a different package, report it as misplaced with the actual defining package and fail.
     3. If a symbol has no definition anywhere, report it as phantom and fail.
     4. Prune/resolve all 63 phantom and misplaced symbols across the 8 registries.

2. **Task47302 (Configuration is read or it is removed)**:
   - **Baseline**: `.asl/hyness.config.asn` maps spoken form `асекс` to `asex`, while `voice/src/hyness_profile.asl:50` maps it to `genseam`, and `voice/tests/audio_bridge_test.asl` asserts `genseam`. The config declares `purplelephant-workstation` while source uses `hyness-workstation`. No loader reads `.asl/hyness.config.asn`.
   - Tool plane block declares 42 lines including gateway key bindings that nothing consumes.
   - **Remedy**:
     1. Reconcile `.asl/hyness.config.asn` to match the canonical lexicon source (`genseam`).
     2. Ensure every configuration key is consumed or remove inert configuration.

3. **Task47303 (A distribution contains what its name promises)**:
   - **Baseline**: `dist/v0.1.0/SHA256SUMS` gave one identical digest `4279e64f` for 4 platform archives (`darwin-arm64`, `darwin-x64`, `linux-arm64`, `linux-x64`), indicating identical uncompiled mock files.
   - **Remedy**:
     1. In `scripts/build_and_install.sh` and packaging scripts, ensure platform archives are compiled for the host architecture or separate archives are built/verified.
     2. Ensure the installer installs into a scratch location and verifies binary execution.

4. **Task47304 (A workspace file describes the workspace)**:
   - **Baseline**: `pnpm-workspace.yaml` names 19 entries of which 17 have no manifest. `.asl.config.asn` coverage core-packages list points to non-existent directories.
   - **Remedy**:
     1. Clean up `pnpm-workspace.yaml` so every entry matches an existing package with valid manifest or remove dead entries.
     2. Fix `.asl.config.asn` coverage paths to target actual existing core packages.

## Ordered Implementation DAG

1. **Task47301**:
   - Verification Fixture: `tests/acceptance/d81/Task47301.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47301`
   - Baseline Failure: Fixture fails because Gate 6 does not check symbol existence and phantom symbols exist.
   - Implementation: Update `asl/tools/asl.c` Gate 6 to enforce symbol existence and placement; clean up 8 grammar registries.
   - Target: Gate passes cleanly with executed assertions.

2. **Task47302**:
   - Verification Fixture: `tests/acceptance/d81/Task47302.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47302`
   - Baseline Failure: Fixture fails on unread/conflicting configuration keys.
   - Implementation: Reconcile `.asl/hyness.config.asn`, remove inert keys, align with voice source.

3. **Task47303**:
   - Verification Fixture: `tests/acceptance/d81/Task47303.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47303`
   - Baseline Failure: Multi-platform archive digests identical or unverified.
   - Implementation: Build-and-install verification with execution check.

4. **Task47304**:
   - Verification Fixture: `tests/acceptance/d81/Task47304.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47304`
   - Baseline Failure: `pnpm-workspace.yaml` and `.asl.config.asn` paths invalid.
   - Implementation: Align workspace definitions and coverage scopes with actual tree.
