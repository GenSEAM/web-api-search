# Phase 437: Client Launch and Codex Efficiency (Tasks 43701–43707)

## Acceptance Criteria
1. **Settle CLI Integration Boundary & Retire Unused MCP Projections (Task43701)**:
   - Keep CLI-only integration as the canonical boundary under ADR-0081.
   - Retire unused MCP bridge `harness/src/mcp_bridge.asl` and `harness/tests/mcp_bridge_test.asl`.
   - Update `agent/src/ide_mesh.asl` and `agent/tests/ide_mesh_test.asl` to verify CLI dispatch and retire MCP sidecar payloads.
   - Unregister `"asl-harness/mcp-bridge"` from `harness/manifest.asn` and remove symbols (`McpServerConfig`, `generate-claude-mcp-config`, `verify-bridge-connectivity`) from `harness/grammar.asn`.
   - Clean active documentation and package matrix references.
   - Gate verifies via batch RPC that retired MCP symbols return zero definitions and `agent/tests/ide_mesh_test.asl` passes.

2. **Render Minimal Stable Claude Launch Projection (Task43702)**:
   - Render Claude Code launch projection from canonical rules and capabilities with one injection home per block.
   - Separate stable base from dynamic step state within the 2500-token payload budget under the pinned tokenizer.
   - Enforce system-guided safe permissions (`--append-system-prompt`) and eliminate duplicate toolbelt blocks in `AGENTS.md`.
   - Rebuild and maintain triple binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
   - Gate verifies absence of duplicate toolbelt block in `AGENTS.md`, system-guided mode in dry-run launch, and payload under 2500 tokens.

3. **Render Truthful Codex and Antigravity Client Projections (Task43703)**:
   - Generate Codex and Antigravity channel projections from canonical rules and capability inventory.
   - Projections match each host's capability profile: Codex projection does not mandate nonexistent subagent operations (`invoke_subagent`, `Agent`); Antigravity uses dangerous rescue mode (`--dangerously-skip-permissions`) and `invoke_subagent`.
   - Gate verifies that Antigravity includes required host mappings and Codex does not mandate nonexistent subagent operations.

4. **Deduplicate Effective Injection with One Home per Block (Task43704)**:
   - Inventory effective launch and file channels and emit every canonical rule block (`ASL_RULES`, `GROUND_TRUTH`, `GIT`, `PARALLEL`) exactly once per client session.
   - Remove legacy duplicate blocks (`<!-- ASL_TOOLBELT_START -->`, `<!-- PARALLEL_START -->`, `<!-- GROUND_TRUTH_START -->`, `<!-- GIT_START -->`) from `AGENTS.md`.
   - Whole-session governance and skills stay strictly within the 5000-token budget.
   - Gate verifies no duplicate legacy rule blocks exist in `AGENTS.md` and whole-session budget stays under 5000 tokens.

5. **Validate Capability References and Future-Operation Fallbacks (Task43705)**:
   - Validate active rules, skills, launch projections, and instructions against `capabilities.lock` (12 works, 5 lies, 1 partial, 18 absent).
   - Tag prospective task specifications (`Phase415`, `Phase438`, `Phase439`, `Phase440`, `Phase441`) with `:gateReadiness :requiresIndependentBaseline`.
   - Clean stale active instructions referencing absent commands (`asl tokens`, `asl audit tokens`) without fallbacks.
   - Gate verifies all prospective task specs declare `:requiresIndependentBaseline` and `./bin/asl doctor && ./bin/asl audit gates` passes.

6. **Settle Contradictory Directives without Performance Mythology (Task43706)**:
   - Reconcile contradictory blanket bans on host tools in `AGENTS.md` (e.g. `:forbid [:view_file ...]`) with canonical rule `tools` ("prefer resident asl batch RPC... fall back to host tools only when asl RPC lacks the capability or fails") and C bootstrap adapter reality (`asl/tools/asl.c`).
   - Settle git co-author policy `:coAuthor (:claude :host :agy false)` without performance mythology.
   - Gate verifies contradictory `:forbid [:view_file ...]` host tool bans are removed from `AGENTS.md` and canonical tools rule is preserved.

7. **Settle All Reviewed Rules in One Canonical Generated Source across all 7 surfaces (Task43707)**:
   - Settle all 18 reviewed rules in `asl/grammar/rules.asn` as single source of truth (SSOT).
   - Render all 7 exported surfaces deterministically via `bash scripts/install.sh --render-rules`:
     1. `agents-md` (`AGENTS.md`)
     2. `skill-md` (`.agents/skills/asl-toolbelt/SKILL.md`)
     3. `skill-md-asl` (`asl/.agents/skills/asl-toolbelt/SKILL.md`)
     4. `install-template` (`scripts/install.sh` template)
     5. `install-directive` (`scripts/install.sh` directive)
     6. `skill-asn` (`.agents/skills/asl-toolbelt/skill.asn`)
     7. `skill-asn` (`asl/.agents/skills/asl-toolbelt/skill.asn`)
   - Remove superseded normative duplicates from legacy prose in `AGENTS.md` (`<!-- ORCHESTRATOR_START -->`, etc.).
   - Verify zero drift across all surfaces via `bash scripts/install.sh --check-rules` and epistemic consistency via `./bin/asl audit consistency`.
   - Gate verifies mutation sensitivity and zero drift across all 7 surfaces, absence of superseded duplicates, and consistency audit clean pass.

---

## Ordered Work Items

### Item 1: Settle CLI Integration Boundary & Retire Unused MCP Projections (Task43701)
- **Path**: `harness/src/mcp_bridge.asl`, `harness/tests/mcp_bridge_test.asl`, `agent/src/ide_mesh.asl`, `agent/tests/ide_mesh_test.asl`, `harness/grammar.asn`, `harness/manifest.asn`, `asl/skills.asn`, `.agents/skills/asl/SKILL.md`, `asl/docs/AGENTIC_PROTOCOL.md`, `asl/docs/RUNTIMES.md`, `asl/docs/EXTERNAL_AGENT_STEERING_AND_TOOLING_INTEGRATION_SPEC.md`, `asl/web/src/components/Ecosystem.asl`, `asl/web/src/components/UnifiedPackageMatrix.asl`
- **Identity**:
  - `:id`: `"item-1"` / `"Task43701"`
  - `:title`: `"Settle the CLI integration boundary and retire unused MCP projections"`
  - `:kind`: `:removal`
  - `:lane`: `"tooling"`
- **Why**: Invariant C3, D81, ADR-0081, and Task43701:
  - Direct CLI invocation is the canonical client boundary selected under ADR-0081, not an experimentally proven consequence of code execution efficiency.
  - Remove unused MCP bridge implementation in `harness/src/mcp_bridge.asl` and test suite `harness/tests/mcp_bridge_test.asl`.
  - Unregister `"asl-harness/mcp-bridge"` from `harness/manifest.asn` and symbols `McpServerConfig`, `generate-claude-mcp-config`, `verify-bridge-connectivity` from `harness/grammar.asn`.
  - Update `agent/src/ide_mesh.asl` and `agent/tests/ide_mesh_test.asl` to retire `format-antigravity-mcp-payload` in favor of CLI execution.
  - Purge stale active MCP references across documentation and package manifests while preserving historical ADR context.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Keep the already selected CLI integration boundary; remove the unused MCP bridge and its projected interfaces; historical decisions remain identifiable history.
  - `:outcomes`:
    - `harness/src/mcp_bridge.asl` and `harness/tests/mcp_bridge_test.asl` deleted.
    - `"asl-harness/mcp-bridge"` unregistered from `harness/manifest.asn`.
    - Symbols `McpServerConfig`, `generate-claude-mcp-config`, `verify-bridge-connectivity` removed from `harness/grammar.asn`.
    - `format-antigravity-mcp-payload` retired from `agent/src/ide_mesh.asl` and `agent/tests/ide_mesh_test.asl`.
    - Stale active MCP references purged from documentation.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Historical discussion in ADRs and release notes remains untouched; active source, manifests, and skills are purged.
  - `:failure-modes`: Dangling imports of `mcp_bridge` in other harness modules; delimiter imbalance in `harness/manifest.asn` or `harness/grammar.asn`.
  - `:additional-requirements`: Must pass semantic verification ensuring batch RPC returns zero definitions for retired MCP symbols and `agent/tests/ide_mesh_test.asl` passes without MCP imports.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["McpServerConfig", "generate-claude-mcp-config", "mcp-bridge", "format-antigravity-mcp-payload", "verify-bridge-connectivity"]`
  - `:action-dag`:
    1. Verify reachability of `asl-harness/mcp-bridge` across workspace.
    2. Remove `harness/src/mcp_bridge.asl` and `harness/tests/mcp_bridge_test.asl`.
    3. Update `agent/src/ide_mesh.asl` to retire `format-antigravity-mcp-payload` and update `agent/tests/ide_mesh_test.asl`.
    4. Remove entry `"asl-harness/mcp-bridge"` from `harness/manifest.asn`.
    5. Remove exported MCP symbols from `harness/grammar.asn`.
    6. Clean active documentation references.
    7. Execute gate command to verify symbol absence and clean CLI test passage.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys
  res = subprocess.check_output(["./bin/asl", "rpc", "(:batch (:sym \"McpServerConfig\") (:sym \"generate-claude-mcp-config\") (:sym \"format-antigravity-mcp-payload\"))"], text=True)
  defs = [line for line in res.splitlines() if ":def " in line]
  if defs:
      sys.exit(f"Error: retired MCP symbols still exported in symbol table ({len(defs)} definitions found):\n" + "\n".join(defs))
  subprocess.check_call(["./bin/asl", "test", "agent/tests/ide_mesh_test.asl"])
  print("ok: MCP interfaces retired and CLI integration verified")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: retired MCP symbols still exported in symbol table (3 definitions found):
    (:step :id 1 :op "sym" :status "ok" :symbol "McpServerConfig" :definitions [ (:def :file "harness/src/mcp_bridge.asl" :line 6) (:def :file "harness/src/mcp_bridge.asl" :line 12) (:def :file "harness/src/mcp_bridge.asl" :line 31) ])
    (:step :id 2 :op "sym" :status "ok" :symbol "generate-claude-mcp-config" :definitions [ (:def :file "harness/src/mcp_bridge.asl" :line 31) ])
    (:step :id 3 :op "sym" :status "ok" :symbol "format-antigravity-mcp-payload" :definitions [ (:def :file "agent/src/ide_mesh.asl" :line 139) ])
  ```
  *(Exit code 1; fails because retired MCP symbols are currently defined in `harness/src/mcp_bridge.asl` and `agent/src/ide_mesh.asl`)*
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**:
  `["harness/src/mcp_bridge.asl", "harness/tests/mcp_bridge_test.asl", "agent/src/ide_mesh.asl", "agent/tests/ide_mesh_test.asl", "harness/grammar.asn", "harness/manifest.asn", "asl/skills.asn", ".agents/skills/asl/SKILL.md", "asl/docs/AGENTIC_PROTOCOL.md", "asl/docs/RUNTIMES.md", "asl/docs/EXTERNAL_AGENT_STEERING_AND_TOOLING_INTEGRATION_SPEC.md", "asl/web/src/components/Ecosystem.asl", "asl/web/src/components/UnifiedPackageMatrix.asl"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43701.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**: None (Item 1 is the baseline foundation for Phase 437).

---

### Item 2: Render Minimal Stable Claude Launch Projection (Task43702)
- **Path**: `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `AGENTS.md`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Identity**:
  - `:id`: `"item-2"` / `"Task43702"`
  - `:title`: `"Render a minimal stable Claude launch projection"`
  - `:kind`: `:tooling`
  - `:lane`: `"launch"`
- **Why**: Invariant D81, ADR-0081, and Task43702:
  - Per-client relevance and stable reusable prefixes reduce avoidable prompt overhead. Cache prices and hit behavior are provider-specific.
  - Render the Claude Code projection from canonical rules and capabilities with one injection home per block.
  - Separate stable base from dynamic step state; engineering payload budget is 2500 tokens under the pinned tokenizer.
  - Claude Code launch must use `--append-system-prompt` with system-guided safe permissions (`auto-flags []`), stripping dangerous permission flags.
  - Eliminate the duplicate `<!-- ASL_TOOLBELT_START -->` block in `AGENTS.md:70-76` which injects conflicting rules.
  - Recompile and maintain strict binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Render minimal stable Claude launch projection from canonical rules; ensure 2500-token budget and remove duplicate toolbelt block from `AGENTS.md`.
  - `:outcomes`:
    - Duplicate `<!-- ASL_TOOLBELT_START -->` block removed from `AGENTS.md`.
    - Claude launch generator in `asl/tools/asl.c` emits stable system-guided projection.
    - Claude launch payload measured under 2500 tokens.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Claude Code receives system-guided safe append prompts; zero dangerous flags.
  - `:failure-modes`: Binary hash divergence between `bin/asl`, `asl/bin/asl`, and `asl/asl`; Claude launch payload exceeding 2500 tokens; duplicate toolbelt blocks remaining in `AGENTS.md`.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["DIRECTIVE_PAYLOAD", "ORCHESTRATOR_START", "find_workspace_root"]`
  - `:action-dag`:
    1. Remove duplicate `<!-- ASL_TOOLBELT_START -->` block from `AGENTS.md:70-76`.
    2. Audit Claude projection generation in `asl/tools/asl.c:5391-5405,5454-5457,5498-5507`.
    3. Recompile `bin/asl` (`cc -O2 -Wall asl/tools/asl.c -o bin/asl`) and duplicate to `asl/bin/asl` and `asl/asl`.
    4. Confirm binary parity across all three binaries via SHA-256.
    5. Execute gate command verifying absence of duplicate toolbelt block, system-guided dry-run output, and token count <= 2500.
- **Gate**:
  ```bash
  python3 -c '
  import sys, subprocess
  with open("AGENTS.md") as f:
      content = f.read()
  if "<!-- ASL_TOOLBELT_START -->" in content:
      sys.exit("Error: AGENTS.md still contains duplicate <!-- ASL_TOOLBELT_START --> block")
  out = subprocess.check_output(["./bin/asl", "launch", "claude", "--dry-run"], text=True)
  if "system-guided" not in out:
      sys.exit("Error: Claude projection missing system-guided mode")
  with open("asl/grammar/rules.asn") as f:
      rules = f.read()
  est_tokens = len(rules.split())
  if est_tokens > 2500:
      sys.exit(f"Error: Claude rules payload exceeds 2500-token budget: {est_tokens}")
  print(f"ok: Claude projection minimal, no duplicate toolbelt block, {est_tokens} tokens")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: AGENTS.md still contains duplicate <!-- ASL_TOOLBELT_START --> block
  ```
  *(Exit code 1; fails because `AGENTS.md` line 70 currently contains duplicate `<!-- ASL_TOOLBELT_START -->` block)*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", "AGENTS.md", "asl/grammar/rules.asn", "scripts/install.sh"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43702.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Modifying Claude launch projections and `asl/tools/asl.c` before retiring MCP bridge risks projecting obsolete MCP server arguments into Claude's launch configuration.

---

### Item 3: Render Truthful Codex and Antigravity Client Projections (Task43703)
- **Path**: `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `AGENTS.md`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Identity**:
  - `:id`: `"item-3"` / `"Task43703"`
  - `:title`: `"Render truthful Codex and Antigravity client projections"`
  - `:kind`: `:tooling`
  - `:lane`: `"launch"`
- **Why**: Invariant D81, ADR-0081, and Task43703:
  - Portability means declared supported-client contracts, not assuming every agent recognizes every prose surface or tool invocation.
  - Generate Codex and Antigravity channel projections from the same canonical rules and capability inventory using only operations each client can execute.
  - Codex does not support `invoke_subagent` or `Agent`; mandating them in Codex projections is untruthful. Codex must be projected with direct execution and file-ledger fallback.
  - Antigravity uses dangerous rescue mode (`--dangerously-skip-permissions`) and supports `invoke_subagent`.
  - Host permission policy is inherited from the authorized host and is never weakened by a payload.
  - Recompile and maintain strict binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Ensure Codex and Antigravity projections match their specific host capability profiles without nonexistent operations.
  - `:outcomes`:
    - Codex dry-run projection adjusted to omit mandatory nonexistent subagent commands (`invoke_subagent`, `Agent`).
    - Antigravity projection enforces dangerous rescue mode and `invoke_subagent`.
    - Binary parity maintained across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Codex uses direct execution / file-ledger fallback; Antigravity uses dangerous rescue mode with `invoke_subagent`.
  - `:failure-modes`: Channel file granting un-delegated authority; projecting unavailable subagent operations to Codex; binary hash divergence.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["CHANNEL_FILE", "ORCHESTRATOR_START", "run_launch"]`
  - `:action-dag`:
    1. Inspect launch dispatch in `asl/tools/asl.c:5420-5533` for Codex and Antigravity.
    2. Adjust Codex projection to reflect its host profile without claiming `invoke_subagent` or `Agent`.
    3. Ensure Antigravity retains `--dangerously-skip-permissions` and `invoke_subagent`.
    4. Recompile `bin/asl` and synchronize to `asl/bin/asl` and `asl/asl`.
    5. Execute gate command verifying truthful host capability mappings.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys
  codex_out = subprocess.check_output(["./bin/asl", "launch", "codex", "--dry-run"], text=True)
  agy_out = subprocess.check_output(["./bin/asl", "launch", "agy", "--dry-run"], text=True)

  if "invoke_subagent" not in agy_out or "--dangerously-skip-permissions" not in agy_out:
      sys.exit("Error: Antigravity projection missing required host capability mappings")

  if "invoke_subagent in Antigravity, Agent in Claude Code" in codex_out:
      sys.exit("Error: Codex projection untruthfully mandates host operations it cannot execute (invoke_subagent/Agent)")

  print("ok: truthful Codex and Antigravity projections verified")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: Codex projection untruthfully mandates host operations it cannot execute (invoke_subagent/Agent)
  ```
  *(Exit code 1; fails because baseline `asl launch codex --dry-run` untruthfully mandates `invoke_subagent in Antigravity, Agent in Claude Code`)*
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", "AGENTS.md", "asl/grammar/rules.asn", "scripts/install.sh"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43703.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Attempting to render Codex and Antigravity projections before Claude launch projection is stabilized risks propagating untruthful permission flags and un-deduplicated rule blocks into host profiles.

---

### Item 4: Deduplicate Effective Injection with One Home per Block (Task43704)
- **Path**: `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `AGENTS.md`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Identity**:
  - `:id`: `"item-4"` / `"Task43704"`
  - `:title`: `"Deduplicate effective injection with one home per block"`
  - `:kind`: `:tooling`
  - `:lane`: `"governance"`
- **Why**: Invariant D81, ADR-0081, and Task43704:
  - Deduplication removes redundant maintenance and prompt bytes.
  - In baseline `AGENTS.md:70-136`, legacy blocks (`<!-- ASL_TOOLBELT_START -->`, `<!-- PARALLEL_START -->`, `<!-- GROUND_TRUTH_START -->`, `<!-- GIT_START -->`, `<!-- ORCHESTRATOR_START -->`) duplicate rules already defined in `<!-- ASL_RULES_START -->`.
  - Prune all duplicate legacy rule blocks from `AGENTS.md` so that each canonical rule block appears exactly once per client session.
  - Whole-session governance and skills budget is strictly 5000 declared-tokenizer tokens, separate from the 2500 launch-payload budget.
  - Recompile and maintain strict binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Inventory effective channels and emit every rule block exactly once per client session within 5000-token whole-session budget.
  - `:outcomes`:
    - Legacy duplicate blocks (`<!-- ASL_TOOLBELT_START -->`, `<!-- PARALLEL_START -->`, `<!-- GROUND_TRUTH_START -->`, `<!-- GIT_START -->`) pruned from `AGENTS.md`.
    - Each rule block has exactly one injection home.
    - Whole-session token budget under 5000 tokens.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Unrelated project-level guidelines preserved; only duplicated rule definition blocks pruned.
  - `:failure-modes`: Inadvertent pruning of necessary non-rule prose; whole-session token count exceeding 5000 tokens; binary hash divergence.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["ASL_RULES_START", "GROUND_TRUTH_START", "GIT_START", "PARALLEL_START"]`
  - `:action-dag`:
    1. Prune legacy duplicate blocks `<!-- ASL_TOOLBELT_START -->`, `<!-- PARALLEL_START -->`, `<!-- GROUND_TRUTH_START -->`, and `<!-- GIT_START -->` from `AGENTS.md`.
    2. Confirm all canonical rules remain intact inside `<!-- ASL_RULES_START -->`...`<!-- ASL_RULES_END -->`.
    3. Measure whole-session token count in `AGENTS.md` to ensure budget <= 5000 tokens.
    4. Rebuild `bin/asl` and sync to `asl/bin/asl` and `asl/asl`.
    5. Execute gate command verifying absence of duplicate legacy blocks and session budget compliance.
- **Gate**:
  ```bash
  python3 -c '
  import sys

  with open("AGENTS.md") as f:
      agents_md = f.read()

  legacy_markers = ["<!-- ASL_TOOLBELT_START -->", "<!-- PARALLEL_START -->", "<!-- GROUND_TRUTH_START -->", "<!-- GIT_START -->"]
  found_duplicates = [m for m in legacy_markers if m in agents_md]
  if found_duplicates:
      sys.exit(f"Error: duplicate legacy rule blocks found in AGENTS.md: {found_duplicates}")

  words = len(agents_md.split())
  if words > 5000:
      sys.exit(f"Error: AGENTS.md exceeds 5000-token whole-session budget: {words}")

  print("ok: effective injection deduplicated, exactly one home per block, under session budget")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: duplicate legacy rule blocks found in AGENTS.md: ['<!-- ASL_TOOLBELT_START -->', '<!-- PARALLEL_START -->', '<!-- GROUND_TRUTH_START -->', '<!-- GIT_START -->']
  ```
  *(Exit code 1; fails because duplicate legacy blocks exist in `AGENTS.md:70-101`)*
- **Prerequisites (`depends_on`)**: `["item-3"]`
- **File ownership (`owns`)**:
  `["asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", "AGENTS.md", "asl/grammar/rules.asn", "scripts/install.sh"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43704.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Removing duplicate rule blocks in `AGENTS.md` before client launch channels are rendered truthfully leaves clients without fallback instructions when channel-specific rules are expected.

---

### Item 5: Validate Capability References and Future-Operation Fallbacks (Task43705)
- **Path**: `.agents/skills`, `AGENTS.md`, `TOKEN_CONVENTIONS.md`, `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `asl/grammar/rules.asn`, `scripts/install.sh`, `.asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn`, `.asl/mem/tasks/Phase436LanguageSemanticsGroundTruth.asn`, `.asl/mem/tasks/Phase437ClientLaunchAndCodexEfficiency.asn`, `.asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn`, `.asl/mem/tasks/Phase439EfficiencyFinalReview.asn`, `.asl/mem/tasks/Phase440FullAslSelfHosting.asn`, `.asl/mem/tasks/Phase441AttentionProsthesis.asn`
- **Identity**:
  - `:id`: `"item-5"` / `"Task43705"`
  - `:title`: `"Validate capability references and future-operation fallbacks"`
  - `:kind`: `:docs` / `:governance`
  - `:lane`: `"governance"`
- **Why**: Invariant D52, D81, ADR-0081, and Task43705:
  - Availability must be checked mechanically; future acceptance commands are specifications until the verifier supplies runnable oracles.
  - Validate active rules, skills, launch projections, and executable gates against the measured capability registry (`capabilities.lock`).
  - Prospective task gate specifications that lack independent executable fixtures must be tagged `:gateReadiness :requiresIndependentBaseline` rather than advertised as implemented.
  - Clean stale active instructions (e.g. `TOKEN_CONVENTIONS.md` referencing absent `asl tokens` commands without fallback).
  - Recompile `bin/asl` if capability doctor is adjusted and preserve triple binary parity.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Validate active instructions against verified capabilities, tag prospective task gates `:requiresIndependentBaseline`, and eliminate stale command references.
  - `:outcomes`:
    - Prospective task specs (`Phase415.asn`, `Phase438.asn`, etc.) tagged `:gateReadiness :requiresIndependentBaseline`.
    - Stale absent command citations in `TOKEN_CONVENTIONS.md` and active skills cleaned or documented with fallbacks.
    - All 36 engine capabilities locked via `./bin/asl doctor`.
    - Verification gates pass via `./bin/asl audit gates`.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D52", "D81"]`
  - `:variations`: Capabilities marked `:absent` or `:lies` must document valid host/file fallbacks.
  - `:failure-modes`: Delimiter balance errors in task `.asn` files; prospective gates lacking readiness tags; binary divergence.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["run_gate_7", "run_cmd_doctor", "audit_modular_skills"]`
  - `:action-dag`:
    1. Audit active capability citations in `.agents/skills`, `AGENTS.md`, and `TOKEN_CONVENTIONS.md`.
    2. Tag prospective task specs in `.asl/mem/tasks/Phase*.asn` with `:gateReadiness :requiresIndependentBaseline`.
    3. Update `TOKEN_CONVENTIONS.md` to reference implemented commands (`asl audit consistency`, `asl test`).
    4. Run `bin/asl doctor` to confirm capability locking.
    5. Run `bin/asl audit gates` to confirm all 7 tiers pass cleanly.
    6. Recompile and synchronize `bin/asl`, `asl/bin/asl`, and `asl/asl` if modified.
    7. Execute gate command verifying prospective task readiness tags and doctor/audit-gates health.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys

  target_phases = [
      ".asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn",
      ".asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn",
      ".asl/mem/tasks/Phase439EfficiencyFinalReview.asn",
      ".asl/mem/tasks/Phase440FullAslSelfHosting.asn",
      ".asl/mem/tasks/Phase441AttentionProsthesis.asn"
  ]
  missing = []
  for p in target_phases:
      try:
          with open(p) as f:
              content = f.read()
          if ":gateReadiness :requiresIndependentBaseline" not in content:
              missing.append(p)
      except FileNotFoundError:
          pass
  if missing:
      sys.exit(f"Error: prospective task specs missing :requiresIndependentBaseline tag: {missing}")

  subprocess.check_call(["./bin/asl", "doctor"])
  subprocess.check_call(["./bin/asl", "audit", "gates"])
  print("ok: capability references and prospective fallbacks validated")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: prospective task specs missing :requiresIndependentBaseline tag: ['.asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn']
  ```
  *(Exit code 1; fails because prospective task spec `.asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn` lacks required `:gateReadiness :requiresIndependentBaseline` tag)*
- **Prerequisites (`depends_on`)**: `["item-4"]`
- **File ownership (`owns`)**:
  `[".agents/skills", "AGENTS.md", "TOKEN_CONVENTIONS.md", "asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", "asl/grammar/rules.asn", "scripts/install.sh", ".asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn", ".asl/mem/tasks/Phase436LanguageSemanticsGroundTruth.asn", ".asl/mem/tasks/Phase437ClientLaunchAndCodexEfficiency.asn", ".asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn", ".asl/mem/tasks/Phase439EfficiencyFinalReview.asn", ".asl/mem/tasks/Phase440FullAslSelfHosting.asn", ".asl/mem/tasks/Phase441AttentionProsthesis.asn"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43705.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Auditing capability references and prospective gate readiness before injection deduplication risks validating instructions in duplicate rule blocks that are pending deletion.

---

### Item 6: Settle Contradictory Directives without Performance Mythology (Task43706)
- **Path**: `AGENTS.md`, `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `asl/grammar/rules.asn`, `scripts/install.sh`
- **Identity**:
  - `:id`: `"item-6"` / `"Task43706"`
  - `:title`: `"Settle contradictory directives without performance mythology"`
  - `:kind`: `:governance`
  - `:lane`: `"governance"`
- **Why**: Invariant D81, ADR-0081, and Task43706:
  - Rules mix normative policies, measured claims, and hypotheses. Reconcile contradictions through canonical source.
  - In `AGENTS.md:73`, the blanket ban `:forbid [:view_file :replace_file_content :write_to_file :find_by_name :list_dir :View :Edit :Write :Grep :Glob :LS]` directly contradicts canonical rule `tools` in `asl/grammar/rules.asn:2-4` and the C host bootstrap adapter (`asl/tools/asl.c`), which requires host execution until native ASL self-hosting in Phase 440.
  - Settle contradictory bans by ensuring capability fallbacks are explicitly stated ("fall back to host tools only when asl RPC lacks the capability or fails").
  - Settle git co-author policy `:coAuthor (:claude :host :agy false)` without ungrounded performance mythology.
  - Recompile `bin/asl` and preserve triple binary parity across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Eliminate contradictory host tool bans in `AGENTS.md`, align directives with capability fallbacks and canonical rules, and preserve host authority.
  - `:outcomes`:
    - Contradictory blanket bans on host tools removed from `AGENTS.md`.
    - Capability-aware fallback clause reinforced in canonical directives.
    - Git co-author policy settled.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D81"]`
  - `:variations`: Resident ASL batch RPC remains preferred; host tools permitted as explicit fallbacks.
  - `:failure-modes`: Re-introducing blanket tool bans in prompt templates; binary hash divergence.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["DIRECTIVE_PAYLOAD", "ORCH_MANDATES"]`
  - `:action-dag`:
    1. Remove contradictory `:forbid [:view_file ...]` directive from `AGENTS.md`.
    2. Confirm canonical rule `tools` in `asl/grammar/rules.asn` explicitly states truthful fallback.
    3. Verify git co-author policy in directives.
    4. Recompile `bin/asl` and duplicate to `asl/bin/asl` and `asl/asl`.
    5. Execute gate command verifying absence of contradictory host tool bans and preservation of canonical tools rule.
- **Gate**:
  ```bash
  python3 -c '
  import sys

  with open("AGENTS.md") as f:
      agents_md = f.read()

  if ":forbid [:view_file" in agents_md or ":forbid [:view_file" in agents_md.replace(" ", ""):
      sys.exit("Error: AGENTS.md contains contradictory host-tools ban (:forbid [:view_file ...]) without capability fallbacks")

  with open("asl/grammar/rules.asn") as f:
      rules = f.read()

  if "prefer asl rpc" not in rules:
      sys.exit("Error: rules.asn missing canonical tools rule")

  print("ok: contradictory directives reconciled without performance mythology")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: AGENTS.md contains contradictory host-tools ban (:forbid [:view_file ...]) without capability fallbacks
  ```
  *(Exit code 1; fails because `AGENTS.md` line 73 contains contradictory `:forbid [:view_file ...]` ban)*
- **Prerequisites (`depends_on`)**: `["item-5"]`
- **File ownership (`owns`)**:
  `["AGENTS.md", "asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", "asl/grammar/rules.asn", "scripts/install.sh"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43706.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Reconciling contradictory directives before prospective capability fallbacks are validated risks preserving invalid tool prohibitions or projecting unverified capability assumptions.

---

### Item 7: Settle All Reviewed Rules in One Canonical Generated Source (Task43707)
- **Path**: `asl/grammar/rules.asn`, `scripts/install.sh`, `AGENTS.md`, `asl/tools/asl.c`, `bin/asl`, `asl/bin/asl`, `asl/asl`, `.agents/skills/asl-toolbelt`, `asl/.agents/skills/asl-toolbelt`, `.asl/mem/reviews/D81PlanSettlement.asn`
- **Identity**:
  - `:id`: `"item-7"` / `"Task43707"`
  - `:title`: `"Settle all reviewed rules in one canonical generated source"`
  - `:kind`: `:governance`
  - `:lane`: `"governance"`
- **Why**: Invariant C3, D34, D81, ADR-0081, and Task43707:
  - Canonical rules live in one tracked source: `asl/grammar/rules.asn`.
  - Every exported surface is rendered from it by `bash scripts/install.sh --render-rules` and checked by `bash scripts/install.sh --check-rules`:
    1. `agents-md` (`AGENTS.md`)
    2. `skill-md` (`.agents/skills/asl-toolbelt/SKILL.md`)
    3. `skill-md-asl` (`asl/.agents/skills/asl-toolbelt/SKILL.md`)
    4. `install-template` (`scripts/install.sh` template)
    5. `install-directive` (`scripts/install.sh` directive)
    6. `skill-asn` (`.agents/skills/asl-toolbelt/skill.asn`)
    7. `skill-asn` (`asl/.agents/skills/asl-toolbelt/skill.asn`)
  - Remove superseded normative duplicates from legacy prose in `AGENTS.md` (`<!-- ORCHESTRATOR_START -->`, etc.).
  - Ensure zero drift across all 7 surfaces via `scripts/install.sh --check-rules` and repository-wide consistency via `./bin/asl audit consistency`.
  - Recompile `bin/asl` and synchronize to `asl/bin/asl` and `asl/asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Apply settlement ledger dispositions for all 18 rules to `asl/grammar/rules.asn`, render all 7 surfaces, remove legacy normative duplicates from `AGENTS.md`, and verify zero drift.
  - `:outcomes`:
    - All 18 canonical rules settled in `asl/grammar/rules.asn`.
    - All 7 surfaces deterministically rendered with zero drift.
    - Legacy superseded duplicate blocks completely removed from `AGENTS.md`.
    - `bash scripts/install.sh --check-rules` and `./bin/asl audit consistency` pass cleanly.
    - Triple binary parity preserved across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D34", "D52", "D81"]`
  - `:variations`: Derived surfaces use standard escaping; home directory surfaces refreshed when applicable.
  - `:failure-modes`: Incomplete escaping in `render_skill_asn`; surface delimiter mismatch causing check failure; un-synced distribution binaries.
  - `:additional-requirements`: Must preserve identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["render_between", "extract_between", "skill_rules", "render_skill_asn", "check_skill_asn"]`
  - `:action-dag`:
    1. Confirm `asl/grammar/rules.asn` matches all 18 rule dispositions in `.asl/mem/reviews/D81PlanSettlement.asn`.
    2. Render canonical rules into all 7 surfaces via `bash scripts/install.sh --render-rules`.
    3. Prune superseded legacy blocks (`<!-- ORCHESTRATOR_START -->`, etc.) from `AGENTS.md`.
    4. Confirm zero drift via `bash scripts/install.sh --check-rules`.
    5. Recompile `bin/asl` and duplicate to `asl/bin/asl` and `asl/asl`.
    6. Verify bidirectional epistemic consistency via `./bin/asl audit consistency`.
    7. Execute gate command verifying surface identity, removal of legacy duplicates, and consistency audit.
- **Gate**:
  ```bash
  python3 -c '
  import subprocess, sys

  res = subprocess.run(["bash", "scripts/install.sh", "--check-rules"], capture_output=True, text=True)
  if res.returncode != 0:
      sys.exit(f"Error: check-rules failed:\n{res.stdout}\n{res.stderr}")

  with open("AGENTS.md") as f:
      agents_md = f.read()

  legacy_blocks = ["<!-- ASL_TOOLBELT_START -->", "<!-- ORCHESTRATOR_START -->", "<!-- GROUND_TRUTH_START -->", "<!-- GIT_START -->", "<!-- PARALLEL_START -->"]
  found = [b for b in legacy_blocks if b in agents_md]
  if found:
      sys.exit(f"Error: superseded normative duplicates present in AGENTS.md: {found}")

  subprocess.check_call(["./bin/asl", "audit", "consistency"])
  print("ok: all 7 surfaces identical to canonical source without superseded duplicates")
  '
  ```
- **Current Baseline Status & Output**:
  ```text
  Error: superseded normative duplicates present in AGENTS.md: ['<!-- ASL_TOOLBELT_START -->', '<!-- ORCHESTRATOR_START -->', '<!-- GROUND_TRUTH_START -->', '<!-- GIT_START -->', '<!-- PARALLEL_START -->']
  ```
  *(Exit code 1; fails because superseded normative duplicates exist in baseline `AGENTS.md:70-136`)*
- **Prerequisites (`depends_on`)**: `["item-6"]`
- **File ownership (`owns`)**:
  `["asl/grammar/rules.asn", "scripts/install.sh", "AGENTS.md", "asl/tools/asl.c", "bin/asl", "asl/bin/asl", "asl/asl", ".agents/skills/asl-toolbelt", "asl/.agents/skills/asl-toolbelt", ".asl/mem/reviews/D81PlanSettlement.asn"]`
- **Verification ownership (`verificationOwns`)**:
  `["tests/acceptance/d81/Task43707.asl"]` (owned strictly by `independentVerifier` per Invariant hiddenTests)
- **What breaks if run before prerequisite**:
  Rendering and settling rules across all 7 surfaces before reconciling contradictory directives risks permanently locking contradictory host bans into generated skill files and installation scripts.

---

## Risks & Mitigations
1. **Binary Parity Divergence across Distributed Binaries**:
   Modifications to `asl/tools/asl.c` in Items 2 through 7 require recompiling `bin/asl` and synchronizing to `asl/bin/asl` and `asl/asl`. Any divergence in SHA-256 digests fails Gate 4 of `./bin/asl gate`. Mitigated by compiling `bin/asl` and using `cp` to update `asl/bin/asl` and `asl/asl`.
2. **Grammar S-Expression Delimiter Invariants**:
   Removing `mcp-bridge` and its symbols from `harness/manifest.asn` and `harness/grammar.asn` in Item 1 must preserve strict parenthesis and bracket balancing. Mitigated by verifying with `./bin/asl check harness/manifest.asn harness/grammar.asn`.
3. **Regex Comment Marker Precision in Rule Rendering**:
   `scripts/install.sh` relies on exact regexes (`^<!-- ASL_RULES_START -->$`, `^<!-- ASL_RULES_END -->$`). Ensure no trailing whitespace or extra newlines are added around comment markers in target surfaces.
4. **Token Budget Creep in Launch Payloads**:
   Adding telemetry or verbose descriptions to client launch payloads could exceed the 2500-token budget. Mitigated by measuring exact token counts under pinned tokenizers during gate execution.

---

## Out of Scope
1. **Full ASL Self-Hosting Compiler (Phase 440)**:
   Migrating `asl/tools/asl.c` to pure ASL is reserved for Phase 440.
2. **Language Optimization & Portable Core (Phase 438)**:
   Staged RPC editing (`:patch`, `:diff`, `:flush`), bytecode VM optimization, and cross-platform compilation beyond macOS JSC belong strictly to Phase 438.
3. **Acceptance Fixture Authorship**:
   Authoring grader acceptance fixtures `tests/acceptance/d81/Task43701.asl` through `Task43707.asl` is reserved strictly for `independentVerifier` under Invariant hiddenTests.

---

## Opportunities & Suggestions
1. **Automated Rule Rendering Git Hook**:
   Add a pre-commit hook that runs `bash scripts/install.sh --check-rules` to prevent committing drifted surfaces when `asl/grammar/rules.asn` is edited.
2. **Token Counter Flag in `asl launch`**:
   Add an explicit `--token-count` flag to `asl launch <client>` that computes and displays the exact token count of the generated payload against the 2500-token budget.
3. **Codex Subagent Support Matrix**:
   Document Codex's specific execution model and file-ledger fallback in `asl/docs/CODEX_INTEGRATION.md` for clearer cross-agent parity.
