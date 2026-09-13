# ASL v0.1.0 Release Master Plan

## 1. Release Goals & Target Platforms
- **Version**: `0.1.0`
- **Target Platforms**: `Browser` (WebAssembly), `ARM Mac` (darwin-arm64), `Linux` (linux-x64, via WASI). Windows is explicitly deferred.
- **Goal**: Deliver a maximally efficient agentic runtime that operates via S-expressions (Zero-Shell), distributed via WASM/WASI for cross-platform portability without relying on POSIX or JavaScriptCore outside of macOS.

## 2. Scope Partitioning for Agent Wave

### Scope 1: Sovereign WASM/WASI Transition (Phase 507)
- **Objective**: Finalize WebAssembly/WASI integration to decouple from POSIX and JavaScriptCore.
- **Tasks**:
  1. Implement WASI Preview 1 ABI & Section 2 Import Framing (`asl/packages/asl-compiler/src/wasi.asl` and `wasm.asl`).
  2. Implement pure ASL Git VFS reader (`vfs_git.asl`) for repository auditing without POSIX `git` subprocesses.
  3. Wire the self-hosted evaluator (`asl-eval`) to WASI filesystem closures.

### Scope 2: Agent RPC & Memory Tooling (Phase 484)
- **Objective**: Deliver the core "Zero-Shell" toolkit for agents.
- **Tasks**:
  1. Complete ASN Batch RPC shortcodes (`:out`, `:sec`, `:repl`, `:chk`).
  2. Finalize `asl intel outline` and `asl mem` (In-RAM VFS operations: `replace`, `diff`, `flush`).
  3. Connect these to the CLI (`asl rpc`).

### Scope 3: Multi-Platform Distribution & Packaging
- **Objective**: Package the 0.1.0 release for the target platforms.
- **Tasks**:
  1. Rewrite `scripts/build_and_install.sh` to output:
     - `asl-0.1.0-darwin-arm64.tar.gz`
     - `asl-0.1.0-linux-x64.tar.gz` (wrapping WASM engine like Wasmtime or NodeJS if native C host is unavailable).
     - `asl-0.1.0-browser.tar.gz` (WebAssembly bytecode + JS bridge).
  2. Ensure the build script uses the WASM compiler (`asl/packages/asl-compiler/src/wasm.asl`) for Linux and Browser targets.

## 3. Auditing & Verification Cycle
1. Once implementers finish, a wave of `steps-impl-reviewer` agents will audit each scope.
2. Small fixes will be executed by the orchestration layer.
3. Major falsifications or gaps will trigger a rework routing back to implementers.
4. Final full system audit by all available models.
