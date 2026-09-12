# Phase 448 Plan: Instrumented Editorial Web Design

## Status
- **Phase**: Phase448InstrumentedEditorialWebDesign
- **Priority**: Instrumented Editorial Web Design & Visual Token Contract
- **Status**: completed

## Context & Objectives
Execute Phase 448 under ADR-0081 and monorepo verification contracts:

1. **Task44801**: Freeze the Instrumented Editorial frame and token contract
   - *Rationale*: Establish canonical typography, spacing scale, and color tokens in `asl/web/styles.asn` and `index.css`.
2. **Task44802**: Apply the prose spine and measured wide-surface layout
   - *Rationale*: Refactor web application views to adhere to strict layout boundaries and technical hierarchy.
3. **Task44803**: Replace generic gradient surfaces with calm technical hierarchy
   - *Rationale*: Eliminate decorative visual noise in favor of high-SNR data density and clear contrast.
4. **Task44804**: Make navigation, controls and motion responsive and accessible
   - *Rationale*: Enforce WCAG 2.1 AA accessibility standards, responsive breakpoints, and reduced-motion preferences.
5. **Task44805**: Derive audience-specific component patterns from the frame
   - *Rationale*: Unify UI components for developers, system architects, and automated benchmarks under consistent primitives.
6. **Task44806**: Run visual evidence, viewport and design-cost review
   - *Rationale*: Audit rendering performance, VDOM token weight, and visual regressions across viewports.

## Work Breakdown & Ordered DAG

### Step 1: Task44801 — Freeze the Instrumented Editorial frame and token contract
- **Fixture**: `tests/acceptance/d81/Task44801.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44801`
- **Owned Files**: `asl/web/styles.asn`, `asl/web/src/index.css`, `asl/web/tailwind.config.js`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44801`.
  2. Define token schema in `asl/web/styles.asn` and synchronize CSS custom properties.
  3. Execute gate and verify assertions pass.

### Step 2: Task44802 — Apply the prose spine and measured wide-surface layout
- **Fixture**: `tests/acceptance/d81/Task44802.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44802`
- **Owned Files**: `asl/web/src/App.asl`, `asl/web/src/views/HomeView.asl`, `asl/web/src/views/DocsView.asl`, `asl/web/src/views/BlogView.asl`, `asl/web/src/views/RoadmapView.asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44802`.
  2. Implement prose spine container layout across primary documentation and application views.
  3. Execute gate and verify assertions pass.

### Step 3: Task44803 — Replace generic gradient surfaces with calm technical hierarchy
- **Fixture**: `tests/acceptance/d81/Task44803.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44803`
- **Owned Files**: `asl/web/src/components/Hero.asl`, `asl/web/src/components/CosmicLandscapeBackground.asl`, `asl/web/src/components/Ecosystem.asl`, `asl/web/src/components/KeyCapabilities.asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44803`.
  2. Refactor hero, background, and showcase components to use subtle borders and monochrome palettes.
  3. Execute gate and verify assertions pass.

### Step 4: Task44804 — Make navigation, controls and motion responsive and accessible
- **Fixture**: `tests/acceptance/d81/Task44804.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44804`
- **Owned Files**: `asl/web/src/components/Navbar.asl`, `asl/web/src/components/ThemeToggle.asl`, `asl/web/src/components/SearchModal.asl`, `asl/web/src/index.css`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44804`.
  2. Implement keyboard navigation focus rings, ARIA labels, and responsive drawer menus.
  3. Execute gate and verify assertions pass.

### Step 5: Task44805 — Derive audience-specific component patterns from the frame
- **Fixture**: `tests/acceptance/d81/Task44805.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44805`
- **Owned Files**: `asl/web/src/components/Hero.asl`, `asl/web/src/components/Navbar.asl`, `asl/web/src/components/AgentWireProtocol.asl`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44805`.
  2. Implement specialized data cards, wire protocol inspectors, and telemetry panels.
  3. Execute gate and verify assertions pass.

### Step 6: Task44806 — Run visual evidence, viewport and design-cost review
- **Fixture**: `tests/acceptance/d81/Task44806.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44806`
- **Owned Files**: `asl/web/tests`, `asl/web/dist`
- **Implementation**:
  1. Validate baseline failure via `sh tests/acceptance/d81/SuperviseGate.sh Task44806`.
  2. Execute visual regression suite across mobile, tablet, and desktop viewports.
  3. Execute gate and verify assertions pass.
