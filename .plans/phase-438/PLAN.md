# Phase 438: Language Optimization, Staging & Tooling Runtime

## Phase Summary & Context
- **Phase ID**: `Phase438LanguageOptimizationAndPortableCore` (Phase 438)
- **Programme & Decision**: `ADR-0081` (`d81`), Wave 90
- **Roadmap Coordinates**: Recorded in `.asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn` and `.asl/mem/roadmap.asn:141`
- **Measured Baseline**:
  - `asl inventory` reports:
    - `contentSearch`: `:lies`
    - `stagedEdit`: `:lies`
    - `rollback`: `:lies`
    - `sequencedBatch`: `:absent`
    - `pathBoundary`: `:partial`
    - `massRefactor`: `:absent`
  - In `asl/tools/asl.c:1043`, operations `diff`, `flush`, and `discard` are unconditionally rejected with `:ERR_UNSUPPORTED`:
    `"Staging operations unsupported; edits write immediately to disk"`
  - `asl.c:1104` performs immediate unbuffered writes via `fopen(full_path, "w")` on every `:edit` step without staging or rollback capability.
  - `asl/grammar/capabilities.asn` documents `:status :lies` for `stagedEdit` and `rollback` with fallback `"there is no staging: copy the file first, or let git be your rollback"`.
  - Path boundary validation (`is_safe_path`) does not resolve relative dot-dot segments cleanly, occasionally rejecting valid in-tree paths.
- **Phase Purpose**:
  1. Implement truthful content search (`contentSearch` - Task43804) returning line-accurate matches across workspace files via `:grep` and `asl grep`.
  2. Implement in-memory staging table (`stagedEdit`, `rollback` - Task43805) supporting `:edit` with staging, `:diff` against disk original, `:discard` without disk mutation, and `:flush` for atomic commits.
  3. Implement sequenced batch execution (`sequencedBatch` - Task43805) supporting `:seq true` with fail-fast abort upon step failure.
  4. Implement mass refactor (`massRefactor` - Task43808) supporting `:repl` across declared path scopes.
  5. Harden path boundary validation (`pathBoundary` - Task43809) with canonical path resolution.
  6. Synchronize capability registry (`capabilities.asn` and `capabilities.lock`) and re-verify inventory and master gates.

---

## Invariants & Grounded Contracts

| Invariant | Source Location | Enforcement & Meaning |
|:---|:---|:---|
| **C1 (0 Comments)** | `asl/grammar/rules.asn:1` | Zero comments in any ASL or ASN file. |
| **C2 (0 Unicode Emojis)** | `asl/tools/asl.c:4211` | Zero raw unicode emojis across all machine surfaces. |
| **C3 (Boundary Universalism)** | `asl/grammar/rules.asn:36-38` | Shared foundational helpers only; zero duplicate private helpers. |
| **D34 (Host Residency)** | `.asl/mem/decisions/Adr0034HostResidentSubstrate.asn:1` | Sovereign engine residency; zero third-party daemon dependencies. |
| **D51 (CamelCase)** | `.asl/mem/decisions/Adr0051TokenEfficiencyFormatAndCamelcaseConventions.asn:1` | CamelCase for composite identifiers, structs, and test functions. |
| **D81 (Ground Truth & Portability)** | `asl/grammar/rules.asn:10-13` | C host boundary declared; triple binary parity (`bin/asl`, `asl/bin/asl`, `asl/asl`). |
| **Triple Binary Parity** | `asl/tools/asl.c` build pipeline | All 3 binary copies must share identical SHA-256 digests upon recompilation. |

---

## Ordered Work Items & Falsifiable Gates

### Item 1: Truthful Content Search Hardening (Task43804)
- **Title**: Ensure Literal and Scoped Content Search in RPC and CLI
- **Owner**: `implementer`
- **Owns**: `asl/tools/asl.c`, `asl/grammar/capabilities.asn`, `asl/grammar/capabilities.lock`
- **Baseline Failure**:
  ```bash
  ./bin/asl inventory | grep "contentSearch" | grep -q "works"
  ```
  *Fails because contentSearch is currently marked :lies.*
- **Actions**:
  1. Verify `asl grep <pattern> [path]` and RPC `(:batch (:grep "pattern" :path "path"))` execute line-by-line scanning across workspace text files.
  2. Skip binary files, `.git/`, and directories exceeding bounds.
  3. Format output with file path, 1-indexed line number, and trimmed line snippet.
  4. Update `contentSearch` in `asl/grammar/capabilities.asn` and `asl/grammar/capabilities.lock` to `:works`.
- **Completion Gate**:
  ```bash
  ./bin/asl grep "execute_single_step" asl/tools/asl.c | grep -q "asl/tools/asl.c:" && ./bin/asl rpc '(:batch (:grep "execute_single_step" :path "asl/tools/asl.c"))' | grep -q ":status \"ok\""
  ```

---

### Item 2: In-Memory Staging Table & Review Operations (Task43805)
- **Title**: Implement Staged Edits, Diff, Flush, and Discard
- **Owner**: `implementer`
- **Owns**: `asl/tools/asl.c`, `asl/grammar/capabilities.asn`, `asl/grammar/capabilities.lock`
- **Baseline Failure**:
  ```bash
  ./bin/asl rpc '(:batch (:diff))' | grep -q ":ERR_UNSUPPORTED"
  ```
  *Passes baseline check (diff currently returns :ERR_UNSUPPORTED, proving staging is absent).*
- **Actions**:
  1. Declare `StagedBuffer` table in `asl/tools/asl.c` tracking path, original content, staged content, and modification state.
  2. Update `:edit`: when `:stage true` is specified, apply replacement in memory into `staged_content` without touching disk, returning `:status "ok" :mode "staged"`.
  3. Implement `:diff`: compare `orig_content` and `staged_content` across staged files, returning unified diff chunks.
  4. Implement `:discard`: clear staged buffers without modifying disk, returning `:status "ok" :discarded-count <N>`.
  5. Implement `:flush`: atomically write modified staged buffers to disk, clear buffers, returning `:status "ok" :flushed-count <N>`.
  6. Update `stagedEdit` and `rollback` in `capabilities.asn` and `capabilities.lock` to `:works`.
- **Completion Gate**:
  ```bash
  ./bin/asl rpc '(:batch (:diff))' | grep -q ":status \"ok\"" && ./bin/asl rpc '(:batch (:discard))' | grep -q ":status \"ok\""
  ```

---

### Item 3: Sequenced Batches with Fail-Fast Abort (Task43805)
- **Title**: Implement Sequenced Batch Execution Block
- **Owner**: `implementer`
- **Owns**: `asl/tools/asl.c`, `asl/grammar/capabilities.asn`, `asl/grammar/capabilities.lock`
- **Baseline Failure**:
  ```bash
  ./bin/asl inventory | grep "sequencedBatch" | grep -q "works"
  ```
  *Fails because sequencedBatch is currently marked :absent.*
- **Actions**:
  1. In `handle_payload` in `asl/tools/asl.c`, check for `:seq true` or `(:seq ...)` combinator.
  2. In sequenced mode, execute steps in order; if any step returns `:status "rejected"`, abort immediately and mark remaining steps as `:status "aborted" :reason "prior step failed"`.
  3. Update `sequencedBatch` in `capabilities.asn` and `capabilities.lock` to `:works`.
- **Completion Gate**:
  ```bash
  ./bin/asl rpc '(:batch :seq true (:read "nonexistent_file_xyz_123.txt" 1 10) (:read "AGENTS.md" 1 10))' | grep -q "aborted"
  ```

---

### Item 4: Path Boundary Canonicalization (Task43809)
- **Title**: Harden Workspace Boundary Path Canonicalization
- **Owner**: `implementer`
- **Owns**: `asl/tools/asl.c`, `asl/grammar/capabilities.asn`, `asl/grammar/capabilities.lock`
- **Baseline Failure**:
  ```bash
  ./bin/asl inventory | grep "pathBoundary" | grep -q "works"
  ```
  *Fails because pathBoundary is currently marked :partial.*
- **Actions**:
  1. Refactor `is_safe_path` in `asl/tools/asl.c` to canonicalize relative paths containing `.` or `..` without escaping the workspace root.
  2. Reject sibling paths that happen to prefix-match the workspace directory name (e.g. `/ws_sibling` when workspace is `/ws`).
  3. Allow valid in-tree relative paths (e.g. `asl/../AGENTS.md`).
  4. Update `pathBoundary` in `capabilities.asn` and `capabilities.lock` to `:works`.
- **Completion Gate**:
  ```bash
  ./bin/asl rpc '(:batch (:read "asl/../AGENTS.md" 1 5))' | grep -q ":status \"ok\""
  ```

---

### Item 5: Triple Binary Parity Recompilation & Gate Audit
- **Title**: Recompile and Reconcile bin/asl, asl/bin/asl, and asl/asl
- **Owner**: `implementer`
- **Owns**: `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Actions**:
  1. Compile `asl/tools/asl.c` to `/tmp/asl_build_438` via `clang -O2 -Wall -framework JavaScriptCore`.
  2. Copy to `bin/asl`, `asl/bin/asl`, and `asl/asl` with BypassSandbox permissions.
  3. Ad-hoc codesign all 3 binaries via `codesign --force --sign -`.
  4. Verify identical SHA-256 digests across all 3 locations.
  5. Run `./bin/asl gate`, `./bin/asl audit consistency`, and `./bin/asl inventory`.
- **Completion Gate**:
  ```bash
  test "$(shasum -a 256 bin/asl | cut -d' ' -f1)" = "$(shasum -a 256 asl/asl | cut -d' ' -f1)" && ./bin/asl gate
  ```

---

## Phase Verification Summary
Upon completing all items:
1. Staging operations (`:edit :stage true`, `:diff`, `:flush`, `:discard`) execute in memory with zero dirty writes on discard.
2. `asl inventory` reports `works` for `contentSearch`, `stagedEdit`, `rollback`, `sequencedBatch`, and `pathBoundary`.
3. All 7 monorepo master gates (`./bin/asl gate`) pass cleanly.
4. Epistemic consistency (`./bin/asl audit consistency`) confirms 5/5 dimensions reconciled.
