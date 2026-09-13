# ADR-0083: Runtime Targets & Optional Native Tier

## Context & Constraints
Following the WASI transition (ADR-0082), the execution targets for pure ASL have been prioritized:
1. **Browser Runtime (Primary):** Tools must be adapted to execute within browser environments. Large portions of the build process should be able to run directly in the browser.
2. **Mobile Runtime:** Mobile environments are officially a target runtime.
3. **Native Tier (Optional):** The Mach-O/ELF binary emitters are an *optional* tier. Pure ASL in the browser/Wasm is the baseline.
4. **Windows Deferred:** Windows native support is deferred to a much later roadmap stage.
5. **Release Deferred:** Focus entirely on completing Phases 506-510. No premature release tasks.
6. **Full Test Coverage:** Native ASL must have full dynamic test coverage within the two-tier architecture.
