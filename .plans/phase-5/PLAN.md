# Phase 5: P3 Token Economy, Sigil Eradication, Manifest Synchronization, and Zero Stub Certification

## Acceptance Criteria
1. **Invariant C5 (Sigil Eradication)**: Eradicate prohibited `@` and `#` sigils in `intel/src/xref.asl`, `intel/tests/xref_test.asl`, `intel/tests/boundary_test.asl`, `agent/src/tui.asl`, and `agent/tests/tui-test.asl`. Replace `@ref:` with bare `ref:`, `#L` line anchors with `:L`, and `@scout` / `@coder` / `@reviewer` role sigils with `:agent:scout` / `:agent:coder` / `:agent:reviewer` or `:scout` / `:coder` / `:reviewer`.
2. **Invariant STUB-01 (Zero Stub Certification)**: Eradicate `mock-local` fallback mode and `mock_completion` simulation debt from `bin/asl-gateway`. In unconfigured environments (missing upstream credentials), return HTTP 503 unconfigured diagnostic error instead of simulated mock responses.
3. **Invariants MAN-01..05 & C3 (Package Manifest Synchronization)**: Create canonical `asl/web/manifest.asn` conforming to AST validation (`validate_manifest_ast_c`). Synchronize the `:modules` registry across 9 packages (`agent`, `agent-bus`, `agent-core`, `intel`, `pack`, `vdom`, `voice`, `browser-plugin`, `web-api-search`) to catalog 100% of production source modules.
4. **Invariant D51 (Token Efficiency Format)**: Refactor test functions in `intel/tests/xref_test.asl` from kebab-case (`(df test-...)`) to PascalCase (`(df TestParseRefUriTask ...)`, `(df RunTests ...)`), eliminating LLM tokenizer splitting overhead and establishing the canonical reference implementation.
5. **Phase Gate Certification**: Full execution of `./bin/asl gate` succeeds with all 7 verification gates passing cleanly.

---

## Ordered Work Items

### Item 1: Eradicate @ and # Sigils in Intel XRef, Boundary Tests, and Agent TUI (Invariant C5)
- **Path**: `intel/src/xref.asl:26-115`, `intel/tests/xref_test.asl:18-122`, `intel/tests/boundary_test.asl:95-97`, `agent/src/tui.asl:61-74`, `agent/tests/tui-test.asl:104-106`
- **Why**: Invariant C5 strictly prohibits `@` and `#` sigils in ASL source code, test definitions, and URI representations.
  - `intel/src/xref.asl` lines 26, 30, 109, 115 parse and format `@ref:`, and lines 70-71, 93 use `#L` line anchors (`file:...#L42`).
  - `intel/tests/xref_test.asl` lines 18-23, 51, 60, 67-74, 112, 122 test `@ref:` and `#L` URI syntax.
  - `intel/tests/boundary_test.asl` lines 95, 97 test agent ID leakage with `@scout`.
  - `agent/src/tui.asl` lines 61, 64, 71-73 format agent roles as `@alias`, `@scout:`, `@coder:`, `@reviewer:`.
  - `agent/tests/tui-test.asl` lines 104-106 assert on `@scout:`, `@coder:`, `@reviewer:`.
  Replace `@ref:` with bare `ref:`, `#L` line anchors with `:L`, `@scout` in tests with `:agent:scout`, and `@role` in TUI with bare or colon-prefixed `:role:` indicators, updating unit test assertions to match.
- **Gate**:
  ```bash
  python3 -c '
  import re, sys
  files = ["intel/src/xref.asl", "intel/tests/xref_test.asl", "intel/tests/boundary_test.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl"]
  pattern = re.compile(r"(@|#)")
  total = sum(len(pattern.findall(open(f).read())) for f in files)
  print(f"Total prohibited sigil occurrences found: {total}")
  sys.exit(1 if total > 0 else 0)
  ' && ./bin/asl test intel/tests/xref_test.asl intel/tests/boundary_test.asl agent/tests/tui-test.asl
  ```
- **Current Baseline Failure**:
  ```text
  Total prohibited sigil occurrences found: 30
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["intel/src/xref.asl", "intel/tests/xref_test.asl", "intel/tests/boundary_test.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl"]`
- **What breaks if run before prerequisite**: None (independent leaf invariant cleanup).

---

### Item 2: Eradicate Mock Fallback Mode and Certify Zero Stubs in bin/asl-gateway (Invariant STUB-01)
- **Path**: `bin/asl-gateway:163-420`
- **Why**: Invariant STUB-01 & Ground-Truth Invariant: `bin/asl-gateway` lines 163 and 345-420 implement an active fallback mode returning `{ mode: "mock", provider: "mock-local" }` and synthesize fake completion responses with HTTP 200 when upstream credentials are not configured. This simulation debt masks misconfigured runtime environments and violates the zero-stub policy. Remove `mock-local` and `mock_completion` fallback paths; when unconfigured, return HTTP 503 with a diagnostic error payload indicating missing upstream credentials.
- **Gate**:
  ```bash
  python3 -c '
  import sys
  content = open("bin/asl-gateway").read()
  errors = []
  if "mock-local" in content:
      errors.append("STUB-01: mock-local fallback mode present in bin/asl-gateway")
  if "mock_completion" in content:
      errors.append("STUB-01: mock_completion simulation present in bin/asl-gateway")
  if "503" not in content:
      errors.append("STUB-01: 503 unconfigured diagnostic error handler missing in bin/asl-gateway")
  if errors:
      print("\n".join(errors))
      sys.exit(1)
  print("STUB-01: Zero mock/simulation debt certified in bin/asl-gateway")
  '
  ```
- **Current Baseline Failure**:
  ```text
  STUB-01: mock-local fallback mode present in bin/asl-gateway
  STUB-01: mock_completion simulation present in bin/asl-gateway
  STUB-01: 503 unconfigured diagnostic error handler missing in bin/asl-gateway
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["bin/asl-gateway"]`
- **What breaks if run before prerequisite**: None (isolated bash/Node gateway proxy script).

---

### Item 3: Create asl/web Manifest and Synchronize :modules Across 9 Package Manifests (Invariants MAN-01..05)
- **Path**: `asl/web/manifest.asn`, `agent/manifest.asn`, `agent-bus/manifest.asn`, `agent-core/manifest.asn`, `intel/manifest.asn`, `pack/manifest.asn`, `vdom/manifest.asn`, `voice/manifest.asn`, `browser-plugin/manifest.asn`, `web-api-search/manifest.asn`
- **Why**: Invariants MAN-01 through MAN-05 & C3:
  - `asl/web` lacks `manifest.asn` entirely, causing its 38 source modules to be unindexed in package audits.
  - `agent/manifest.asn`, `agent-core/manifest.asn`, `intel/manifest.asn`, `pack/manifest.asn`, `vdom/manifest.asn`, `voice/manifest.asn`, `browser-plugin/manifest.asn`, and `web-api-search/manifest.asn` omit `:modules` declarations.
  - `agent-bus/manifest.asn` declares only 2 of 14 modules.
  Create `asl/web/manifest.asn` with valid AST structure (`(:package ... :version "0.1.0" :dependencies [])`), and populate `:modules` in all 9 package manifests indexing 100% of their production `src/` modules.
- **Gate**:
  ```bash
  python3 -c '
  import os, glob, re, sys

  manifests = {
      "asl/web": "asl/web/manifest.asn",
      "agent": "agent/manifest.asn",
      "agent-bus": "agent-bus/manifest.asn",
      "agent-core": "agent-core/manifest.asn",
      "intel": "intel/manifest.asn",
      "pack": "pack/manifest.asn",
      "vdom": "vdom/manifest.asn",
      "voice": "voice/manifest.asn",
      "browser-plugin": "browser-plugin/manifest.asn",
      "web-api-search": "web-api-search/manifest.asn"
  }

  errors = []
  for pkg, mpath in manifests.items():
      if not os.path.exists(mpath):
          errors.append(f"Missing manifest: {mpath}")
          continue
      content = open(mpath).read()
      if ":modules" not in content:
          errors.append(f"{mpath} missing :modules section")
          continue
      src_files = glob.glob(f"{pkg}/src/**/*.asl", recursive=True)
      m = re.search(r":modules\s+\[(.*?)\]", content, re.DOTALL)
      if not m:
          errors.append(f"{mpath} has malformed :modules")
          continue
      declared = set(re.findall(r"\"([^\"]+)\"", m.group(1)))
      if len(declared) < len(src_files):
          errors.append(f"{mpath} incomplete: declared {len(declared)} of {len(src_files)} modules")

  if errors:
      print("\n".join(errors))
      sys.exit(1)
  print("All 10 package manifests synchronized with :modules registry")
  ' && ./bin/asl gate --only=1
  ```
- **Current Baseline Failure**:
  ```text
  Missing manifest: asl/web/manifest.asn
  agent/manifest.asn missing :modules section
  agent-bus/manifest.asn incomplete: declared 2 of 14 modules
  agent-core/manifest.asn missing :modules section
  intel/manifest.asn missing :modules section
  pack/manifest.asn missing :modules section
  vdom/manifest.asn missing :modules section
  voice/manifest.asn missing :modules section
  browser-plugin/manifest.asn missing :modules section
  web-api-search/manifest.asn missing :modules section
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/web/manifest.asn", "agent/manifest.asn", "agent-bus/manifest.asn", "agent-core/manifest.asn", "intel/manifest.asn", "pack/manifest.asn", "vdom/manifest.asn", "voice/manifest.asn", "browser-plugin/manifest.asn", "web-api-search/manifest.asn"]`
- **What breaks if run before prerequisite**: None (disjoint metadata manifest files).

---

### Item 4: Refactor intel Test Suite to PascalCase Canonical Pattern (Invariant D51)
- **Path**: `intel/tests/xref_test.asl:3-145`
- **Why**: Invariant D51 Token Efficiency Format: LLM tokenizers split kebab-case function names (`test-parse-ref-uri-task`) into 6+ sub-tokens, whereas PascalCase (`TestParseRefUriTask`) reduces token counts by 20-50%. Refactor all 8 test and runner functions in `intel/tests/xref_test.asl` to PascalCase (`TestParseRefUriTask`, `TestParseRefUriAdrAndC`, `TestParseRefUriSymAndChunk`, `TestParseRefUriFileAndFormat`, `TestExtractDocstringRefs`, `TestXrefGraphBidirectionalAndProvenance`, `TestHealthIntegrityAndCycleDetection`, `RunTests`), updating `:x` export symbols and call sites inside `RunTests` to establish the canonical reference implementation.
- **Gate**:
  ```bash
  python3 -c '
  import re, sys
  content = open("intel/tests/xref_test.asl").read()
  pascal_names = [
      "TestParseRefUriTask",
      "TestParseRefUriAdrAndC",
      "TestParseRefUriSymAndChunk",
      "TestParseRefUriFileAndFormat",
      "TestExtractDocstringRefs",
      "TestXrefGraphBidirectionalAndProvenance",
      "TestHealthIntegrityAndCycleDetection",
      "RunTests"
  ]
  kebab_names = [
      "test-parse-ref-uri-task",
      "test-parse-ref-uri-adr-and-c",
      "test-parse-ref-uri-sym-and-chunk",
      "test-parse-ref-uri-file-and-format",
      "test-extract-docstring-refs",
      "test-xref-graph-bidirectional-and-provenance",
      "test-health-integrity-and-cycle-detection",
      "run-tests"
  ]
  missing = [name for name in pascal_names if f"(df {name}" not in content]
  still_kebab = [name for name in kebab_names if f"(df {name}" in content]
  if missing or still_kebab:
      print(f"D51 violation: {len(still_kebab)} kebab test defs remain, {len(missing)} PascalCase defs missing")
      sys.exit(1)
  print("D51: All test functions refactored to PascalCase")
  ' && ./bin/asl test --strict-falsify intel/tests/xref_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  D51 violation: 8 kebab test defs remain, 8 PascalCase defs missing
  ```
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["intel/tests/xref_test.asl"]`
- **What breaks if run before Item 1**: Modifying `intel/tests/xref_test.asl` before Item 1 will create edit collisions with the Item 1 sigil eradication changes (`@ref:` and `#L` removal), leading to lost updates or verification failures.

---

### Item 5: Monorepo Pure ASL Verification Gate Final Audit
- **Path**: Repository audit harness
- **Why**: Validates that all Phase 5 implementations (C5 sigil eradication, STUB-01 zero stub certification, MAN-01..05 manifest synchronization, and D51 test refactor) satisfy acceptance criteria and maintain full system-wide integrity across all 7 verification gates in `./bin/asl gate`.
- **Gate**:
  ```bash
  python3 -c '
  import os, sys, re

  files_c5 = ["intel/src/xref.asl", "intel/tests/xref_test.asl", "intel/tests/boundary_test.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl"]
  pattern = re.compile(r"(@|#)")
  c5_count = sum(len(pattern.findall(open(f).read())) for f in files_c5)

  gw = open("bin/asl-gateway").read()
  stub_violation = ("mock-local" in gw) or ("503" not in gw)

  man_web = os.path.exists("asl/web/manifest.asn")

  xref_test = open("intel/tests/xref_test.asl").read()
  d51_violation = "(df TestParseRefUriTask" not in xref_test

  if c5_count > 0 or stub_violation or not man_web or d51_violation:
      print(f"Phase 5 incomplete: C5={c5_count} sigils, STUB-01={stub_violation}, MAN-01 web manifest={man_web}, D51={d51_violation}")
      sys.exit(1)
  ' && ./bin/asl gate
  ```
- **Current Baseline Failure**:
  ```text
  Phase 5 incomplete: C5=30 sigils, STUB-01=True, MAN-01 web manifest=False, D51=True
  ```
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3", "item-4"]`
- **File ownership (`owns`)**: `[]`
- **What breaks if run before prerequisite**: Fails because C5 sigils (30 occurrences) remain in source/test files, STUB-01 mock fallback exists in `bin/asl-gateway`, `asl/web/manifest.asn` is missing, and test functions remain in kebab-case.

---

## Risks
1. **Agent TUI Test Regression**: In Item 1, changing `@scout: `, `@coder: `, `@reviewer: ` in `agent/src/tui.asl` without updating corresponding string assertions in `agent/tests/tui-test.asl` will break the agent test suite. Both files must be updated atomically within Item 1.
2. **Manifest AST Validation Format**: `validate_manifest_ast_c` in `asl/tools/asl.c:2556` strictly enforces `(:package ...)` or `(package ...)`, `:version`, and bracketed `:dependencies [...]`. Any syntax deviation in newly created `asl/web/manifest.asn` will immediately fail Gate 1.
3. **Submodule Git Boundary Isolation**: The files owned across Items 1-3 span multiple git submodule directories (`intel`, `agent`, `agent-bus`, `agent-core`, `pack`, `vdom`, `voice`, `browser-plugin`, `web-api-search`). Edits and commits must respect submodule boundaries to avoid dirty index states.

---

## Out of Scope
1. **Monorepo-Wide 1,626 Test Function Renaming**: GAPS.asn finding INV-09 identifies 1,626 kebab-case test functions across all 35 packages. Refactoring all 1,626 functions in a single phase carries an excessive blast radius and potential merge collisions. Phase 5 canonically refactors `intel/tests/xref_test.asl` per D51 to establish the standard pattern; automated repository-wide AST migration is staged for subsequent phases.
2. **Agent Internal Subsystem Stubs (STUB-02)**: Deterministic simulation stubs in `agent/src/ffi.asl`, `agent/src/computer_use.asl`, and `agent/src/eddie.asl` require live host OS substrate operations. STUB-01 in Phase 5 is strictly scoped to `bin/asl-gateway` zero stub certification.
3. **Grammar Registry Desynchronization (MAN-06)**: Desynchronized symbols in `grammar.asn` files require grammar regeneration tooling and are handled under separate grammar audit phases.

---

## Opportunities & Suggestions
1. **Automated AST Migration Tool for D51**: Author a dedicated batch refactoring script in `asl/packages/asl-codec` or `asl/packages/asl-compiler` to automate kebab-case to PascalCase test rewriting across all packages once the canonical pattern in `intel/tests/xref_test.asl` is validated.
2. **Dynamic Credential Discovery for Gateway**: Enhance `bin/asl-gateway` with a pluggable credential resolution chain that checks local keychains or secrets managers before falling back to 503 unconfigured errors.
