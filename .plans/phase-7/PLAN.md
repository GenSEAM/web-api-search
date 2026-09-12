# Phase 7: Repository Hygiene, Configuration Truth & Full Corpus Gate Scope (Причёсывание репозиториев)

## Acceptance Criteria
1. **Invariant D81 & Task47304 (Workspace & Coverage Configuration Truth)**:
   - In `pnpm-workspace.yaml`, restrict package declarations to actual workspace packages with manifests (`asl` and `asl/web`), eliminating 17 phantom package entries.
   - In `.asl.config.asn` (line 70) and `asl/.asl.config.asn` (line 37), correct `:core-packages` paths from nonexistent `"asl/asl-compiler"` and `"asl/asl-parser"` to existing `"asl/packages/asl-compiler"` and `"asl/packages/asl-parser"`.
   - Structural balance and syntax verification confirmed by `./bin/asl check .asl.config.asn` and `./bin/asl check asl/.asl.config.asn`.
2. **Invariant C1, D81 & Task47302 (Configuration Read, Comment Eradication & Lexicon Sync)**:
   - In `.asl/hyness.config.asn` (lines 12-18), synchronize the local phonetic alias table with canonical `asl/grammar/lexicon.asn` by replacing the acoustic mishearing `"hyness"` with `"harness"`, and adding the spoken variant `"ханес"` -> `"harness"`.
   - In `.addie/config.asn`, eradicate all 7 comment lines (`;;`), restoring 100% compliance with Invariant C1 (zero comments in machine ASN).
   - Structural balance verified via `./bin/asl check .asl/hyness.config.asn` and `./bin/asl check .addie/config.asn`.
3. **Invariant D81 & Task47001 (Gate 5 Scope Restoration to Entire Workspace)**:
   - In `asl/tools/asl.c` (`run_gate_5_suites`, lines 2775 and 2784), ensure test suite discovery covers the full workspace root (`"."` / `""`).
   - Recompile `bin/asl`, `asl/bin/asl`, and `asl/asl` so that `./asl/bin/asl audit gates` (and `./bin/asl audit gates`) executes and audits all 312+ native test suites with zero failures.
4. **Invariant D81 & Task47303 (Binary & Distribution Truth)**:
   - Reconcile `bin/asl`, `asl/bin/asl`, and `asl/asl` so all three binaries are freshly compiled, executable, and byte-identical, reporting identical SHA-256 digests.
5. **Phase Gate Certification (Master Verification)**:
   - Full execution of `./bin/asl gate` passes all 7 tiers cleanly with full 312-suite coverage in Tier 5.
   - Repository-wide consistency and bidirectional links audit `./bin/asl audit consistency` passes with 0 defects across all 5 dimensions.

---

## Ordered Work Items

### Item 1: Restrict Workspace Packages and Fix Coverage Paths (Task47304)
- **Path**: `pnpm-workspace.yaml:1-21`, `.asl.config.asn:70`, `asl/.asl.config.asn:37`
- **Why**: Invariants D34, D81, and Task47304:
  - `pnpm-workspace.yaml` declares 19 package entries, of which 17 contain no package manifest (`package.json`), presenting a misleading picture of repository architecture to external tooling and agents. Only `asl` and `asl/web` contain package manifests (`asl/package.json:1-18`, `asl/web/package.json:1-23`). Restrict packages to `['asl', 'asl/web']`.
  - `.asl.config.asn:70` and `asl/.asl.config.asn:37` declare `:core-packages` referencing `"asl/asl-compiler"` and `"asl/asl-parser"`. Neither directory exists at the repository root; the actual directories are `"asl/packages/asl-compiler"` and `"asl/packages/asl-parser"`. Asserting 100% coverage over nonexistent directories causes coverage metrics to evaluate empty file sets.
  - Update both configuration files with correct relative package paths and verify ASN syntax conformance via `./bin/asl check`.
- **Gate**:
  ```bash
  python3 -c '
  import os, sys, yaml
  ws = yaml.safe_load(open("pnpm-workspace.yaml"))
  pkgs = ws.get("packages", [])
  if set(pkgs) != {"asl", "asl/web"}:
      print(f"Error: pnpm-workspace.yaml should only contain asl and asl/web, got {pkgs}")
      sys.exit(1)
  for p in pkgs:
      if not os.path.exists(os.path.join(p, "package.json")):
          print(f"Error: missing package.json in {p}")
          sys.exit(1)
  for fpath in [".asl.config.asn", "asl/.asl.config.asn"]:
      c = open(fpath).read()
      if "asl/asl-compiler" in c or "asl/asl-parser" in c:
          print(f"Error: nonexistent package paths in {fpath}")
          sys.exit(1)
  print("Item 1 passed: workspace and coverage configuration verified")
  ' && ./bin/asl check .asl.config.asn && ./bin/asl check asl/.asl.config.asn
  ```
- **Current Baseline Failure**:
  ```text
  Error: pnpm-workspace.yaml should only contain asl and asl/web, got ['asl', 'asl/web', 'harness', 'agent-core', 'mem', 'web-api-search', 'agent-bus', 'browser-plugin', 'agent', 'vdom', 'voice', 'editorial-matrix', 'pack', 'intel', 'crawler', 'asl-arduino', 'asl-contracts', 'asl-quantum', 'asl-gateway']
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["pnpm-workspace.yaml", ".asl.config.asn", "asl/.asl.config.asn"]`
- **What breaks if run before prerequisite**: None (self-contained configuration and workspace manifest hygiene).

---

### Item 2: Synchronize Local Lexicon and Eradicate Comments (Task47302)
- **Path**: `.asl/hyness.config.asn:12-18`, `.addie/config.asn:1,4-9`
- **Why**: Invariants C1, D81, and Task47302:
  - In `.asl/hyness.config.asn:14`, spoken alias `"хайнесс"` maps to `"hyness"` instead of canonical `"harness"`, enshrining an acoustic ASR mishearing in local configuration and contradicting canonical `asl/grammar/lexicon.asn:5`. Additionally, phonetic variant `"ханес"` is absent from `:local-lexicon`. Update `"хайнесс"` to map to `"harness"` and add `(:alias :spoken "ханес" :maps-to "harness")`.
  - In `.addie/config.asn:1,4-9`, seven lines contain `;;` comments, violating Invariant C1 (zero comments in machine ASN). Eradicate all `;;` comments while preserving structure.
  - Verify syntax and delimiter balance via `./bin/asl check .asl/hyness.config.asn` and `./bin/asl check .addie/config.asn`.
- **Gate**:
  ```bash
  python3 -c '
  import sys
  hyness = open(".asl/hyness.config.asn").read()
  if "maps-to \"hyness\"" in hyness:
      print("Error: .asl/hyness.config.asn still contains hyness mishearing")
      sys.exit(1)
  if "maps-to \"harness\"" not in hyness:
      print("Error: .asl/hyness.config.asn missing harness mapping")
      sys.exit(1)
  if "spoken \"ханес\"" not in hyness:
      print("Error: .asl/hyness.config.asn missing spoken alias ханес")
      sys.exit(1)
  addie = open(".addie/config.asn").read()
  if ";;" in addie:
      print("Error: .addie/config.asn contains forbidden comments")
      sys.exit(1)
  print("Item 2 passed: configuration and lexicon synchronized")
  ' && ./bin/asl check .asl/hyness.config.asn && ./bin/asl check .addie/config.asn
  ```
- **Current Baseline Failure**:
  ```text
  Error: .asl/hyness.config.asn still contains hyness mishearing
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `[".asl/hyness.config.asn", ".addie/config.asn"]`
- **What breaks if run before prerequisite**: None (disjoint configuration files; synchronizes with upstream canonical `asl/grammar/lexicon.asn:5` established in Phase 6).

---

### Item 3: Restore Gate 5 Scope to Entire Workspace (Task47001)
- **Path**: `asl/tools/asl.c:2775,2784`, `asl/bin/asl`
- **Why**: Invariant D81 and Task47001:
  - In `asl/tools/asl.c:2775,2784`, test suite discovery was historically narrowed to `"asl/packages/asl-gates/tests"`. While lines 2775 and 2784 in `asl/tools/asl.c` were edited to point to `.` and `""`, the installed binary `./asl/bin/asl` remains uncompiled from the old build (digest `949f597b...`), auditing only 5 native test suites.
  - Recompile `asl/bin/asl` (and `bin/asl`, `asl/asl`) so that `./asl/bin/asl audit gates` executes and audits all 312+ test suites across the monorepo cleanly.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys, re
  out = subprocess.check_output(["./asl/bin/asl", "audit", "gates"], text=True)
  m = re.search(r"Audited (\d+) native test suites", out)
  if not m or int(m.group(1)) < 312:
      print("Error: asl/bin/asl does not audit full 312 suites: " + out)
      sys.exit(1)
  print(f"Item 3 passed: asl/bin/asl audits full {m.group(1)} suites")
  '
  ```
- **Current Baseline Failure**:
  ```text
  Error: asl/bin/asl does not audit full 312 suites:     [Config] Loaded hierarchical configuration (1 level(s)): .asl.config.asn
  ================================================================================
            AgentScript Pure ASL Verification Gate & Continuous Audit             
      [Config] Selective filter active: only=[1,2,3,4,5,6,7], skip=[]
  ================================================================================
  --> [1/7] Verifying package manifests and module structure...
      ✓ Verified 36 package manifests cleanly.
  --> [2/7] Auditing pure ASL syntax and S-expression form balance...
      ✓ All 904 ASL source files are well-formed and structurally balanced.
      ✓ Pure ASL zero-comment invariant (c-0001) verified across production packages.
  --> [3/7] Auditing site claims grounding against benchmark registry...
      ✓ Grounded 12 benchmark claims across published registry.
  --> [4/7] Enforcing Zero-Foreign File Policy (:asl-first active in .asl.config.asn)...
      [Boundary] Enforcing pure monorepo rules: packages, scripts whitelist, comment-free .aslignore...
      ✓ Declared host boundary: asl/tools/asl.c (native macOS/POSIX C bootstrap adapter, non-third-party).
      ✓ Zero foreign files across monorepo (100% pure AgentScript conforming to ASL-first invariant).
  --> [5/7] Executing pure ASL gate test suites...
      ✓ Audited 5 native test suites: 5 asserting suites (171 evaluated assertions verified across suites).
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/tools/asl.c", "asl/bin/asl"]`
- **What breaks if run before prerequisite**: None.

---

### Item 4: Reconcile Installed and Built Engine Binaries (Task47303)
- **Path**: `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Why**: Invariant D81 and Task47303:
  - Currently `bin/asl` (digest `9c435a97...`), `asl/bin/asl` (digest `949f597b...`), and `asl/asl` (digest `949f597b...`) diverge, creating ambiguity regarding which binary is executed by agent toolbelts versus local CLI calls.
  - Following the compilation in Item 3, ensure `bin/asl`, `asl/bin/asl`, and `asl/asl` are byte-identical copies with identical SHA-256 digests and executable permissions.
- **Gate**:
  ```bash
  python3 -c '
  import hashlib, sys
  h_bin = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h_asl_bin = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h_asl_asl = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h_bin == h_asl_bin == h_asl_asl):
      print(f"Error: binary divergence: bin/asl={h_bin[:8]}, asl/bin/asl={h_asl_bin[:8]}, asl/asl={h_asl_asl[:8]}")
      sys.exit(1)
  print("Item 4 passed: all binaries are reconciled and identical")
  ' && ./bin/asl --help > /dev/null
  ```
- **Current Baseline Failure**:
  ```text
  Error: binary divergence: bin/asl=9c435a97, asl/bin/asl=949f597b, asl/asl=949f597b
  ```
- **Prerequisites (`depends_on`)**: `["item-3"]`
- **File ownership (`owns`)**: `["bin/asl", "asl/bin/asl", "asl/asl"]`
- **What breaks if run before prerequisite**: Modifying `asl/tools/asl.c` in Item 3 requires binary recompilation; if Item 4 executes before Item 3, the binaries would diverge again during Item 3's compilation.

---

### Item 5: Master Verification (Full Gate & Consistency Audit)
- **Path**: Entire repository verification harness
- **Why**: Validates that all Phase 7 hygiene changes (workspace narrowing, coverage path correction, lexicon synchronization, comment removal, Gate 5 scope restoration, and 3-way binary synchronization) are integrated cleanly and that monorepo integrity is confirmed by `./bin/asl gate` (all 7 tiers, including 312 test suites in Tier 5) and `./bin/asl audit consistency` (all 5 epistemic dimensions).
- **Gate**:
  ```bash
  python3 -c '
  import os, sys, yaml, hashlib, subprocess, re

  # Verify Item 1
  ws = yaml.safe_load(open("pnpm-workspace.yaml"))
  pkgs = ws.get("packages", [])
  if set(pkgs) != {"asl", "asl/web"}:
      sys.exit(f"Item 1 incomplete: pnpm-workspace.yaml packages mismatch {pkgs}")
  for p in pkgs:
      if not os.path.exists(os.path.join(p, "package.json")):
          sys.exit(f"Item 1 incomplete: missing package.json in {p}")
  for fpath in [".asl.config.asn", "asl/.asl.config.asn"]:
      c = open(fpath).read()
      if "asl/asl-compiler" in c or "asl/asl-parser" in c:
          sys.exit(f"Item 1 incomplete: nonexistent package paths in {fpath}")

  # Verify Item 2
  hyness = open(".asl/hyness.config.asn").read()
  if "maps-to \"hyness\"" in hyness:
      sys.exit("Item 2 incomplete: .asl/hyness.config.asn still contains hyness mishearing")
  if "maps-to \"harness\"" not in hyness:
      sys.exit("Item 2 incomplete: .asl/hyness.config.asn missing harness mapping")
  if "spoken \"ханес\"" not in hyness:
      sys.exit("Item 2 incomplete: .asl/hyness.config.asn missing spoken alias ханес")
  addie = open(".addie/config.asn").read()
  if ";;" in addie:
      sys.exit("Item 2 incomplete: .addie/config.asn contains forbidden comments")

  # Verify Item 3
  out = subprocess.check_output(["./asl/bin/asl", "audit", "gates"], text=True)
  m = re.search(r"Audited (\d+) native test suites", out)
  if not m or int(m.group(1)) < 312:
      sys.exit(f"Item 3 incomplete: asl/bin/asl did not audit full test suites: {out}")

  # Verify Item 4
  h_bin = hashlib.sha256(open("bin/asl", "rb").read()).hexdigest()
  h_asl_bin = hashlib.sha256(open("asl/bin/asl", "rb").read()).hexdigest()
  h_asl_asl = hashlib.sha256(open("asl/asl", "rb").read()).hexdigest()
  if not (h_bin == h_asl_bin == h_asl_asl):
      sys.exit(f"Item 4 incomplete: binary divergence bin/asl={h_bin[:8]}, asl/bin/asl={h_asl_bin[:8]}, asl/asl={h_asl_asl[:8]}")

  print("Master verification pre-checks passed cleanly")
  ' && ./bin/asl gate && ./bin/asl audit consistency
  ```
- **Current Baseline Failure**:
  ```text
  Item 1 incomplete: pnpm-workspace.yaml packages mismatch ['asl', 'asl/web', 'harness', 'agent-core', 'mem', 'web-api-search', 'agent-bus', 'browser-plugin', 'agent', 'vdom', 'voice', 'editorial-matrix', 'pack', 'intel', 'crawler', 'asl-arduino', 'asl-contracts', 'asl-quantum', 'asl-gateway']
  ```
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3", "item-4"]`
- **File ownership (`owns`)**: `[]`
- **What breaks if run before prerequisite**: Fails immediately because Items 1-4 are unapplied (coverage paths point to nonexistent directories, lexicon carries acoustic mishearings, comments exist in `.addie/config.asn`, Gate 5 audits only 5 test suites on `asl/bin/asl`, and binaries are diverged).

---

## Risks
1. **Gate 5 Test Execution Time**:
   Restoring Gate 5 to audit all 312 test suites across the monorepo increases Gate 5 runtime from ~0.2s (5 suites) to ~6s (312 suites under Node parallel test runner). Verified that `bash scripts/run-gate-tests.sh bin/asl node .` currently completes in ~6s with 312 passed and 0 failures. If timeout issues arise on resource-constrained environments, `scripts/run-gate-tests.sh` parallel worker count can be adjusted.
2. **Binary Overwrite Protection in Build Script**:
   `scripts/build_and_install.sh:14-21` checks whether `asl/asl`, `bin/asl`, or `asl/bin/asl` is a tracked source/script file (with `#!`) before overwriting. The implementer must ensure compilation targets are binary executables and not shell scripts to avoid tripping this guard.
3. **C Bootstrap Compilation Flags**:
   `asl/tools/asl.c` requires linking with `-framework JavaScriptCore` on macOS (`clang -O2 -framework JavaScriptCore -o bin/asl asl/tools/asl.c && cp -f bin/asl asl/bin/asl && cp -f bin/asl asl/asl`). Direct invocations of `cc` must include this framework flag.

---

## Out of Scope
1. **Registry Phantom Symbol Cleanup (Task47301)**:
   Task47301 identifies 57 phantom symbols declared in `grammar.asn` files without corresponding implementations (e.g. `pipeline-execute`, `EyeInstance`). Eradication or implementation of phantom registry symbols is part of Phase 473 Wave 2 and deferred from Phase 7.
2. **Closure of Remaining 7 Module Names (Task47002)**:
   Resolving unresolved imports (`posts`, `core/process`, `mem/src/xref`, `examples/blink`, `daemon`, etc.) is staged under dedicated module binding tasks (Phase 470 Task47002) and is distinct from Gate 5 scope restoration.
3. **Complete Subsystem Renaming from Hyness to Harness**:
   Renaming the `.asl/hyness.config.asn` filename itself or renaming `HynessProfile` / `HynessPhoneticAlias` structs across the codebase carries wide blast radius and is tracked under Task44702/Task47302 full scope. Phase 7 specifically focuses on local configuration lexicon synchronization (`"хайнесс"` -> `"harness"` and `"ханес"` -> `"harness"`).
4. **Compiler Self-Hosting, Token Research & Benchmarking**:
   Explicitly excluded per orchestrator directive.

---

## Opportunities & Suggestions
1. **Automated Workspace Manifest Drift Guard**:
   Add a check to Gate 1 (Manifest & Module Structure) that verifies every directory listed in `pnpm-workspace.yaml` contains a valid `package.json` file, preventing phantom packages from accumulating in workspace configurations.
2. **Automated Comment Linter for ASN Files in Gate 2**:
   Add a check in `./bin/asl audit gates` Tier 2 that asserts zero `;;` comments in all `.asn` files (such as `.addie/config.asn` and `.asl.config.asn`), systematically enforcing Invariant C1 across configuration files.
3. **Automated Binary Sync Check in Gate 4**:
   Add an automated assertion in Gate 4 (or a pre-commit check) comparing the SHA-256 digest of `bin/asl`, `asl/bin/asl`, and `asl/asl` to prevent silent binary divergence during development.

