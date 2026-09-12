# Phase 456 Plan: Duplication, Dead Code and Unwired Eradication

## Status
- **Phase**: Phase456DuplicationDeadCodeAndUnwiredEradication
- **Priority**: Critical / High
- **Status**: Completed (4/4 tasks certified complete)
- **Wave**: Wave 103

## Context & Objectives
Execute Phase 456 under ADR-0081 and monorepo verification contracts (D81, D52, C1, C2, C3):

1. **Task45601**: Delete the 371 redundant copies now that importing works
   - *Rationale*: Remove redundant copies across package boundaries (estimate-tokens, strip-quotes, strip-colon, extract-between, calc-savings, balance-delimiters, escape-sh-arg), eliminate shadowing in sh-transpile, delegate to canonical packages (asl-text/text, asl-text/escape, asl-parser/balance), and record justified residue under two strikes rule D34 in `.asl/mem/duplication-residue.asn`.
   - *Status*: **Done** (Certified under SuperviseGate.sh with 77 assertions).
2. **Task45602**: Retire the 14 definitions nothing references and the 10 stubs
   - *Rationale*: 14 definitions are referenced nowhere in the corpus, registries, manifests, or tests (including make-svg-node in vdom/src/asn_svg.asl); 10 definitions are constant-returning stubs or carry unresolved markers. Each must be deleted, properly implemented, or declared unimplemented failing explicitly at the call site.
   - *Status*: **Done** (Certified under SuperviseGate.sh with 26 assertions).
3. **Task45603**: A verdict for each of the 270 unreachable modules
   - *Rationale*: Non-test modules never imported and never named outside their own file must receive a clear verdict: wired, deleted, or recorded as deliberately dormant with a declared waking condition. Exclude dormant modules from density and coverage metrics.
   - *Status*: **Planned** (Baseline established: missing fixture).
4. **Task45604**: One install.sh, not four byte copies
   - *Rationale*: Single tracked source at scripts/install.sh; add --check-installers drift checker; eliminate nested dist/dist duplicates; enforce single-source distribution copies via Gate 7 check_distribution_installers in asl.c.
   - *Status*: **Done** (Certified under SuperviseGate.sh with 46 assertions).

## Work Breakdown & Ordered DAG

### Step 1: Task45604 — One install.sh, not four byte copies
- **Fixture**: `tests/acceptance/d81/Task45604.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45604`
- **Owned Files**: `scripts/install.sh`, `asl/tools/asl.c`, `asl/web/public/install.sh`
- **Acceptance Criteria**: Single tracked source; byte-identical distribution copies; zero nested dist directories; Gate 7 enforcement.
- **Verification Status**: **VERIFIED COMPLETE** (Receipt: `rc-task45604-verified-20260913`, Note: `n151`).

### Step 2: Task45601 — Delete redundant copies now that importing works
- **Fixture**: `tests/acceptance/d81/Task45601.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45601`
- **Owned Files**: `asl/packages/asl-codec/src`, `asl/packages/asl-text/src`, `harness/src`, `mem/src`
- **Acceptance Criteria**: Eliminate local helpers across codec (csv, toml, yaml, svg, transpile, asnl, compact_notations, sh-transpile) and harness (normalizer, anti_hallucination); delegate to canonical asl-text and asl-parser; record justified survivors in `.asl/mem/duplication-residue.asn`.
- **Verification Status**: **VERIFIED COMPLETE** (Receipt: `rc-task45601-verified-20260913`, Note: `n152`).

### Step 3: Task45602 — Retire unreferenced definitions and constant stubs
- **Fixture**: `tests/acceptance/d81/Task45602.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45602`
- **Owned Files**: `vdom/src`, `asl-arduino/src`, `asl/web/src`, `asl/packages/asl-sql/src`, `harness/src`, `web-api-search/src`, `agent-core/src`
- **Acceptance Criteria**: Delete dead unreferenced definitions (including make-svg-node in vdom/src/asn_svg.asl); ensure constant-body functions declare explicit intent or fail call sites; reject newly added unreferenced definitions.
- **Verification Status**: **VERIFIED COMPLETE** (Receipt: `rc-task45602-verified-20260913`, Note: `n153`).

### Step 4: Task45603 — Verdict for unreachable modules
- **Fixture**: `tests/acceptance/d81/Task45603.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task45603`
- **Owned Files**: `asl/grammar/dependency-boundaries.asn`, `.asl/mem/components.asn`, `voice`, `agent`, `browser-plugin`, `crawler`
- **Acceptance Criteria**: Audit all unreachable modules; classify as wired, deleted, or recorded dormant with explicit waking conditions; ensure corpus statistics exclude declared dormant modules.
- **Verification Status**: **VERIFIED COMPLETE** (Receipt: `rc-task45603-verified-20260913`, Note: `n154`).
