# Phase 6: Repository Hygiene, Lexicon Truth & Duplication Eradication (Причёсывание репозиториев)

## Acceptance Criteria
1. **Invariant D81 & Task45604 (Single Source Installer & Build Hygiene)**:
   - Nested duplicate build directory `asl/dist/dist` is completely removed (`[ ! -d asl/dist/dist ]`).
   - Distribution installer copies (`asl/dist/install.sh`, `asl/web/dist/install.sh`, `asl/web/public/install.sh`) are byte-synchronized with the canonical renderer in `scripts/install.sh`.
   - All installer scripts pass bash syntax verification (`bash -n`).
2. **Invariant D81 & Task44701 (Canonical Lexicon Single Source of Truth)**:
   - Create `asl/grammar/lexicon.asn` as the single canonical source of spoken-to-canonical phonetic mappings.
   - Catalog Russian speech variants for core project entities (e.g. "хайнесс", "ханес" -> "harness", "асекс" -> "asex", "шроуди" -> "shrody", "пцп" -> "pcp", "эдисон" -> "edison") with required schema fields (`:canonical`, `:scope`, `:why`, `:spoken`).
   - Structural balance and ASN delimiter invariants verified via `./bin/asl check`.
3. **Invariant D81 & Task44702 (Retire ASR Mishearing in Voice Profile)**:
   - In `voice/src/hyness_profile.asl`, eliminate phonetic mapping to the mishearing target "hyness" and correctly map spoken variants "хайнесс" -> "harness" and "ханес" -> "harness".
   - In `voice/tests/audio_bridge_test.asl`, update test assertions to verify that "хайнесс" and "ханес" resolve to canonical "harness".
   - Full suite `./bin/asl test voice/tests/audio_bridge_test.asl` passes cleanly.
4. **Invariant D81 & Task45601 (Eradicate Shadowed Helpers in Codec)**:
   - In `asl/packages/asl-codec/src/sh-transpile.asl`, eliminate redundant local shadowing helper `estimate-tokens` where canonical imported function `txt/estimate-tokens` from `asl-text/text` exists.
   - Direct all token estimation call sites to `(txt/estimate-tokens ...)`.
   - Full unit test suite `./bin/asl test asl/packages/asl-codec/tests/sh-transpile-test.asl` passes cleanly.
5. **Phase Gate Certification (Master Verification)**:
   - Full execution of `./bin/asl gate` passes all 7 verification tiers cleanly.
   - Repository-wide consistency and bidirectional links audit `./bin/asl audit consistency` passes with 0 defects.

---

## Ordered Work Items

### Item 1: Eliminate Nested Build Directory asl/dist/dist and Synchronize Distribution Installers (Task45604)
- **Path**: `asl/dist/dist`, `asl/dist/install.sh:1-324`, `asl/web/dist/install.sh:1-324`, `asl/web/public/install.sh:1-324`, `scripts/install.sh:1-570`
- **Why**: Invariant C3 (Single Source of Truth) and Task45604:
  - `scripts/install.sh` (35,824 bytes) is the canonical universal installer and rule projection engine containing `rules_main` and agent toolbelt configuration.
  - `asl/dist/install.sh`, `asl/web/dist/install.sh`, and `asl/web/public/install.sh` are stale 14,461-byte copies missing the rule synchronization functions and latest installation logic, establishing alternative conflicting truths.
  - The nested directory `asl/dist/dist` contains 23 redundant build artifact files resulting from recursive build output copies, polluting file navigation and repository search indexes.
  Remove `asl/dist/dist` recursively and synchronize `asl/dist/install.sh`, `asl/web/dist/install.sh`, and `asl/web/public/install.sh` directly from canonical `scripts/install.sh`.
- **Gate**:
  ```bash
  python3 -c '
  import os, hashlib, sys

  errors = []
  if os.path.exists("asl/dist/dist"):
      errors.append("Nested build directory exists: asl/dist/dist")

  canonical = "scripts/install.sh"
  with open(canonical, "rb") as f:
      canon_hash = hashlib.sha256(f.read()).hexdigest()

  targets = ["asl/dist/install.sh", "asl/web/dist/install.sh", "asl/web/public/install.sh"]
  for t in targets:
      if not os.path.exists(t):
          errors.append(f"Missing target: {t}")
          continue
      with open(t, "rb") as f:
          thash = hashlib.sha256(f.read()).hexdigest()
      if thash != canon_hash:
          errors.append(f"Desynchronized copy: {t} (hash {thash[:8]} != canonical {canon_hash[:8]})")

  if errors:
      print("\n".join(errors))
      sys.exit(1)
  print("Item 1 passed: asl/dist/dist removed and all install.sh copies synchronized")
  ' && bash -n scripts/install.sh asl/dist/install.sh asl/web/dist/install.sh asl/web/public/install.sh
  ```
- **Current Baseline Failure**:
  ```text
  Nested build directory exists: asl/dist/dist
  Desynchronized copy: asl/dist/install.sh (hash 7a69dce2 != canonical c0c11979)
  Desynchronized copy: asl/web/dist/install.sh (hash 7a69dce2 != canonical c0c11979)
  Desynchronized copy: asl/web/public/install.sh (hash 7a69dce2 != canonical c0c11979)
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/dist/dist", "asl/dist/install.sh", "asl/web/dist/install.sh", "asl/web/public/install.sh"]`
- **What breaks if run before prerequisite**: None (isolated build artifact deletion and shell script synchronization).

---

### Item 2: Establish Canonical Lexicon Single Source of Truth (Task44701)
- **Path**: `asl/grammar/lexicon.asn`
- **Why**: Invariant D81 and Task44701:
  - Spoken-to-canonical mappings currently only exist embedded within the voice module (`voice/src/hyness_profile.asl`) or are absent across client channels.
  - Spoken terms arriving via voice transcription, prompt pasting, or IDE agents (Claude Code, Cursor, Antigravity) diverge because no shared canonical registry exists.
  - Create `asl/grammar/lexicon.asn` as the authoritative machine-readable registry containing structured S-expressions with `:canonical`, `:scope`, `:why`, and an array of `:spoken` variants.
  - Map Russian spoken variants for key concepts:
    - "хайнесс", "ханес", "хайнес" -> "harness"
    - "асекс", "асех" -> "asex"
    - "шроуди", "шроди" -> "shrody"
    - "пцп", "писипи" -> "pcp"
    - "эдисон" -> "edison"
  Verify structural balance and syntax conformance via `./bin/asl check`.
- **Gate**:
  ```bash
  python3 -c '
  import os, sys

  lexicon_path = "asl/grammar/lexicon.asn"
  if not os.path.exists(lexicon_path):
      print(f"Error: missing canonical lexicon file: {lexicon_path}")
      sys.exit(1)

  content = open(lexicon_path).read()
  required_terms = ["harness", "asex", "shrody", "pcp", "edison"]
  required_spoken = ["хайнесс", "ханес", "асекс", "шроуди", "пцп", "эдисон"]

  missing_terms = [t for t in required_terms if t not in content]
  missing_spoken = [s for s in required_spoken if s not in content]

  if missing_terms or missing_spoken:
      print(f"Lexicon incomplete: missing terms {missing_terms}, missing spoken {missing_spoken}")
      sys.exit(1)
  print("Canonical lexicon registry verified")
  ' && ./bin/asl check asl/grammar/lexicon.asn && ./bin/asl check .asl/mem/tasks/Phase447CanonicalLexiconCrossClient.asn
  ```
- **Current Baseline Failure**:
  ```text
  Error: missing canonical lexicon file: asl/grammar/lexicon.asn
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/grammar/lexicon.asn"]`
- **What breaks if run before prerequisite**: None (creates new grammar definition file).

---

### Item 3: Retire ASR Mishearing in Voice Profile and Audio Bridge Tests (Task44702)
- **Path**: `voice/src/hyness_profile.asl:50-55`, `voice/tests/audio_bridge_test.asl:76-98`
- **Why**: Invariant D81 and Task44702:
  - `voice/src/hyness_profile.asl:51` maps spoken "хайнесс" to "hyness" instead of "harness", enshrining an ASR acoustic mishearing as a valid codebase symbol.
  - The voice alias table lacks the alternative phonetic variant "ханес" confirmed in transcript analysis.
  - `voice/tests/audio_bridge_test.asl:76, 81` asserts that "хайнесс" resolves to "hyness".
  - Update `voice/src/hyness_profile.asl` so "хайнесс" maps to "harness", add "ханес" mapping to "harness", and update `audio_bridge_test.asl` assertions to verify that "хайнесс" and "ханес" resolve to "harness" (and update `:alias-count 6` if 6 aliases are present in the default profile).
- **Gate**:
  ```bash
  python3 -c '
  import sys
  prof = open("voice/src/hyness_profile.asl").read()
  test = open("voice/tests/audio_bridge_test.asl").read()
  errors = []
  if "\"хайнесс\" \"harness\"" not in prof:
      errors.append("voice/src/hyness_profile.asl missing mapping for хайнесс -> harness")
  if "\"ханес\" \"harness\"" not in prof:
      errors.append("voice/src/hyness_profile.asl missing mapping for ханес -> harness")
  if "\"хайнесс\" \"hyness\"" in prof:
      errors.append("voice/src/hyness_profile.asl still maps хайнесс to mishearing hyness")
  if "\"harness\"" not in test or "resolves хайнесс to harness" not in test:
      errors.append("voice/tests/audio_bridge_test.asl does not assert хайнесс resolves to harness")
  if errors:
      print("\n".join(errors))
      sys.exit(1)
  ' && ./bin/asl test voice/tests/audio_bridge_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  voice/src/hyness_profile.asl missing mapping for хайнесс -> harness
  voice/src/hyness_profile.asl missing mapping for ханес -> harness
  voice/src/hyness_profile.asl still maps хайнесс to mishearing hyness
  voice/tests/audio_bridge_test.asl does not assert хайнесс resolves to harness
  ```
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **File ownership (`owns`)**: `["voice/src/hyness_profile.asl", "voice/tests/audio_bridge_test.asl"]`
- **What breaks if run before prerequisite**: Item 2 establishes the canonical target mapping ("хайнесс" / "ханес" -> "harness") in `asl/grammar/lexicon.asn`; modifying `voice/src/hyness_profile.asl` before Item 2 causes the voice profile to drift without an upstream single source of truth.

---

### Item 4: Eradicate Shadowed Helpers in Codec Transpiler (Task45601)
- **Path**: `asl/packages/asl-codec/src/sh-transpile.asl:22-38`, `asl/packages/asl-codec/tests/sh-transpile-test.asl`
- **Why**: Invariants C3, D34, and Task45601:
  - `asl/packages/asl-codec/src/sh-transpile.asl:13` imports `(asl-text/text :a txt)`.
  - Lines 22-24 define a local helper `(df estimate-tokens [(text Str)] -> I64 (txt/estimate-tokens text))` which shadows the canonical `txt/estimate-tokens` implementation from `asl-text/text`.
  - Lines 91, 104, 125, and 127 call the local shadow helper `(estimate-tokens ...)` instead of invoking `(txt/estimate-tokens ...)` directly.
  - Remove the unexported redundant helper `(df estimate-tokens ...)` from `sh-transpile.asl` and update all internal call sites to invoke `(txt/estimate-tokens ...)` directly.
  - Run `./bin/asl test asl/packages/asl-codec/tests/sh-transpile-test.asl` to ensure all 18 assertions pass.
- **Gate**:
  ```bash
  python3 -c '
  import sys
  content = open("asl/packages/asl-codec/src/sh-transpile.asl").read()
  errors = []
  if "(df estimate-tokens" in content:
      errors.append("Task45601: redundant local shadow helper (df estimate-tokens) present in sh-transpile.asl")
  if errors:
      print("\n".join(errors))
      sys.exit(1)
  ' && ./bin/asl test asl/packages/asl-codec/tests/sh-transpile-test.asl
  ```
- **Current Baseline Failure**:
  ```text
  Task45601: redundant local shadow helper (df estimate-tokens) present in sh-transpile.asl
  ```
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/packages/asl-codec/src/sh-transpile.asl"]`
- **What breaks if run before prerequisite**: None (disjoint pure ASL codec module).

---

### Item 5: Master Verification (Monorepo Gate & Consistency Audit)
- **Path**: Entire repository verification harness
- **Why**: Validates that all Phase 6 deliverables (nested build cleanup, installer synchronization, canonical lexicon creation, voice mishearing retirement, and shadow helper eradication) are in place and that system-wide integrity is verified cleanly by `./bin/asl gate` (all 7 tiers) and `./bin/asl audit consistency` (all 5 dimensions).
- **Gate**:
  ```bash
  python3 -c '
  import os, hashlib, sys

  errors = []
  if os.path.exists("asl/dist/dist"):
      errors.append("Item 1 incomplete: asl/dist/dist exists")

  canonical = "scripts/install.sh"
  with open(canonical, "rb") as f:
      canon_hash = hashlib.sha256(f.read()).hexdigest()

  for t in ["asl/dist/install.sh", "asl/web/dist/install.sh", "asl/web/public/install.sh"]:
      if not os.path.exists(t):
          errors.append(f"Item 1 incomplete: missing {t}")
      else:
          with open(t, "rb") as f:
              if hashlib.sha256(f.read()).hexdigest() != canon_hash:
                  errors.append(f"Item 1 incomplete: {t} desynchronized")

  if not os.path.exists("asl/grammar/lexicon.asn"):
      errors.append("Item 2 incomplete: asl/grammar/lexicon.asn missing")

  prof = open("voice/src/hyness_profile.asl").read()
  if "\"хайнесс\" \"hyness\"" in prof or "\"хайнесс\" \"harness\"" not in prof:
      errors.append("Item 3 incomplete: voice profile still carries hyness mishearing")

  sh_code = open("asl/packages/asl-codec/src/sh-transpile.asl").read()
  if "(df estimate-tokens" in sh_code:
      errors.append("Item 4 incomplete: sh-transpile.asl retains shadowed estimate-tokens")

  if errors:
      print("\n".join(errors))
      sys.exit(1)
  ' && ./bin/asl gate && ./bin/asl audit consistency
  ```
- **Current Baseline Failure**:
  ```text
  Item 1 incomplete: asl/dist/dist exists
  Item 1 incomplete: asl/dist/install.sh desynchronized
  Item 1 incomplete: asl/web/dist/install.sh desynchronized
  Item 1 incomplete: asl/web/public/install.sh desynchronized
  Item 2 incomplete: asl/grammar/lexicon.asn missing
  Item 3 incomplete: voice profile still carries hyness mishearing
  Item 4 incomplete: sh-transpile.asl retains shadowed estimate-tokens
  ```
- **Prerequisites (`depends_on`)**: `["item-1", "item-2", "item-3", "item-4"]`
- **File ownership (`owns`)**: `[]`
- **What breaks if run before prerequisite**: Fails immediately because `asl/dist/dist` remains present, installer files are desynchronized, `asl/grammar/lexicon.asn` is absent, the voice profile retains the mishearing "hyness", and `sh-transpile.asl` contains the shadowed `estimate-tokens` definition.

---

## Risks
1. **Voice Profile Alias Count Assertion Drift**:
   `voice/tests/audio_bridge_test.asl:98` asserts `(string-contains? prof-asn ":alias-count 5")`.
   When adding the variant "ханес" -> "harness" alongside "хайнесс" -> "harness", the total count of default aliases increases from 5 to 6.
   `audio_bridge_test.asl` must be updated atomically to expect `:alias-count 6` to avoid breaking the audio bridge test suite.
2. **Submodule Git Permissions & Index Status**:
   `asl/dist/install.sh` and `asl/web/*` belong to submodules or tracked directory trees.
   File replacements must maintain POSIX executable permissions (`chmod +x`) and avoid leaving dirty submodule references or untracked file conflicts.
3. **Lexicon ASN Parser Invariants (C1, C2)**:
   `asl/grammar/lexicon.asn` must strictly adhere to zero comments (Invariant C1), zero emoji (Invariant C2), and balanced S-expression forms verified by `./bin/asl check`.

---

## Out of Scope
1. **Monorepo-Wide 371 Redundant Definition Eradication (Task45601 Full Scope)**:
   Task45601 identifies 371 redundant function copies across 291 names (including `strip-quotes`, `calc-savings`, `strip-colon`, `extract-between`). Eradicating all 371 instances across all packages is staged across subsequent duplication eradication waves following Phase 454 binder stabilization. Phase 6 addresses the immediate shadowing in `asl-codec/src/sh-transpile.asl`.
2. **Complete Subsystem and Struct Renaming from Hyness to Harness (Task44702 Full Scope)**:
   Task44702 documents 78 occurrences across five files naming the module `asl-voice/hyness-profile`, structs `HynessPhoneticAlias`, `HynessHardwareEndpoint`, `HynessProfile`, and `.asl/hyness.config.asn`. Renaming the entire module and struct ecosystem carries monorepo-wide blast radius. Phase 6 strictly fixes the phonetic value mapping ("хайнесс" / "ханес" -> "harness") and importing unit tests, while full module and config renaming is staged in a subsequent refactoring wave.
3. **Unreachable 270 Modules Verdict Ledger (Task45603)**:
   Assigning wired/dormant/deleted verdicts to 270 non-test modules requires call-graph analysis after Phase 454 and is deferred to dedicated dead-code remediation.
4. **Compiler Self-Hosting and Token Benchmarking**:
   Explicitly excluded per orchestrator directive.

---

## Opportunities & Suggestions
1. **Automated Lexicon Injection in scripts/install.sh**:
   Extend `scripts/install.sh` with `--render-lexicon` and `--check-lexicon` commands (mirroring the existing `rules_main` renderer) so that newly registered terms in `asl/grammar/lexicon.asn` automatically project into `.agents/skills/*/SKILL.md` and client prompt translators without manual copying.
2. **Nested Build Artifact Guard**:
   Add a verification check to `./bin/asl gate` Tier 4 (Zero Foreign Policy & Boundary Enforcement) or pre-commit hooks to automatically fail if any directory matching `**/dist/dist` or duplicate build artifacts are discovered.
3. **Shadow Function Detection Lint Rule**:
   Add an automated lint rule to `asl/packages/asl-lint` or Gate 2 that flags any module that imports a package and simultaneously defines a local function shadowing an exported name from that import.
