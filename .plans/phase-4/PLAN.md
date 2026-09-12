# Phase 4: P2 Invariant Normalization & Boundary Deduplication (Consolidated)

## Acceptance Criterion
1. Invariant C2 (Zero Raw Emojis): All raw unicode emojis and pictographic UI glyphs across asl/web and agent TUI must be replaced with pure SVG icons or ASCII indicators.
2. Invariant C3 (Boundary Universalism): All relative directory escapes (../../) across package boundaries must be eliminated.
3. Invariant C3 (Deduplication): TaskState and TaskRecord multi-definitions in agent-core must be unified; 56 duplicate helpers across mem/src must be consolidated into asl-text and mem/src/math.asl; orphan pack/tests/standalone.test.asl must be deleted.
4. All mem test suites must pass cleanly under ./bin/asl test mem/tests/*.

---

## Ordered Work Items

### Item 1: Normalize Raw Unicode Emojis & Pictographs to SVG and ASCII Indicators
- **Path**: asl/web/src/components/, agent/src/asn_boxart.asl, agent/src/tui.asl, agent/tests/tui-test.asl, mem/tests/vfs_sync_test.asl, voice/src/voice_pipeline.asl
- **Why**: Invariant C2 prohibits raw unicode emojis and pictographs in source code and metadata. Replace emojis in web components with pure SVG vector glyphs. Replace pictographic boxart (U+23F8, U+2713, U+2717, U+25B6, U+25BC, U+25C6) with ASCII indicators ([||], [OK], [FAIL], [>], [v], [x]) and update unit test assertions in tui-test.asl and vfs_sync_test.asl.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; emoji_pat = re.compile(r"[🌀-🫿]"); picto_pat = re.compile(r"[▶▼⠋❯◆✔✓✗⏸]"); files = glob.glob("asl/web/**/*.asl", recursive=True) + ["agent/src/asn_boxart.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl"]; found = sum(len(emoji_pat.findall(open(f).read())) + len(picto_pat.findall(open(f).read())) for f in files); sys.exit(1 if found > 0 else 0)' && ./bin/asl test agent/tests/tui-test.asl && ./bin/asl test mem/tests/vfs_sync_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  44 files contain raw unicode emojis/symbols.
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["asl/web/src/components/InBrowserCompanion.asl", "asl/web/src/components/ModuleGraphVisualizer.asl", "asl/web/src/components/Footer.asl", "asl/web/src/views/InIdeView.asl", "asl/web/src/views/PlaygroundView.asl", "agent/src/asn_boxart.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl", "voice/src/voice_pipeline.asl", "voice/src/aloud.asl"]

---

### Item 2: Eradicate Relative Directory Traversal Across Package Boundaries
- **Path**: intel/tests/xref_test.asl:13, mem/src/refactor_vfs.asl:9, mem/tests/refactor_vfs_test.asl:10, agent-bus/src/tool_plane.asl:10
- **Why**: Invariant C3 forbids relative filesystem directory escapes (../../) reaching into sibling package internals. Must declare formal inter-package dependencies in manifest.asn and import via canonical module symbols ((asl-mem/xref), (asl-compiler/compact-rewrite), (asl-contracts/tool-plane)).
- **Gate**:
  ```bash
  ! grep -rn "\.\./\.\./" intel/ mem/ agent-bus/
  ```
- **Current Baseline Failure**:
  ```text
  Matches found in intel/tests/xref_test.asl, mem/src/refactor_vfs.asl, mem/tests/refactor_vfs_test.asl, agent-bus/src/tool_plane.asl
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["intel/tests/xref_test.asl", "mem/src/refactor_vfs.asl", "mem/tests/refactor_vfs_test.asl", "agent-bus/src/tool_plane.asl", "agent-bus/manifest.asn"]

---

### Item 3: Unify Multi-Definition TaskState Enum & TaskRecord Struct in agent-core
- **Path**: agent-core/src/tasktypes.asl, agent-core/src/clarify.asl, agent-core/src/dag.asl, agent-core/src/threads.asl
- **Why**: Invariant C3 & Single Source of Truth: TaskState is currently defined 3 times with diverging variants, and TaskRecord is defined 3 times with conflicting types. Consolidate TaskState and TaskRecord into canonical tasktypes.asl, import into clarify.asl and threads.asl, and rename dag.asl variant to DagNodeState.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; files = glob.glob("agent-core/src/*.asl"); states = [f for f in files if re.search(r"\(dfe\s+TaskState", open(f).read())]; records = [f for f in files if re.search(r"\(dfs\s+TaskRecord", open(f).read())]; sys.exit(0 if len(states) == 1 and len(records) == 1 else 1)' && ./bin/asl test agent-core/tests/*
  ```
- **Current Baseline Failure**:
  ```text
  TaskState defined in 3 files; TaskRecord defined in 3 files.
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["agent-core/src/tasktypes.asl", "agent-core/src/clarify.asl", "agent-core/src/dag.asl", "agent-core/src/threads.asl"]

---

### Item 4: Consolidate 56 Duplicate Helpers in mem/src and Purge pack Orphan
- **Path**: mem/src/*.asl, mem/tests/*.asl, pack/tests/standalone.test.asl
- **Why**: Invariant C3 prohibits duplicate private helper functions across modules. Consolidate text helpers (char-to-code, extract-between, strip-punct, tokenize-words) into asl-text and math utilities (fast-ln, cosine-similarity, vector-norm) into mem/src/math.asl. Delete orphan duplicate pack/tests/standalone.test.asl.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; from collections import defaultdict; func_defs = defaultdict(list); pattern = re.compile(r"\(df\s+([a-zA-Z0-9_-]+)"); [func_defs[m.group(1)].append((f, idx)) for f in sorted(glob.glob("mem/src/*.asl")) for idx, line in enumerate(open(f), 1) for m in [pattern.search(line)] if m]; duplicates = {k: v for k, v in func_defs.items() if len(v) > 1}; sys.exit(1 if len(duplicates) > 0 or glob.glob("pack/tests/standalone.test.asl") else 0)' && ./bin/asl test mem/tests/*
  ```
- **Current Baseline Failure**:
  ```text
  56 duplicate functions found in mem/src/*.asl and pack/tests/standalone.test.asl exists.
  ```
- **Prerequisites (`depends_on`)**: []
- **File ownership (`owns`)**: ["mem/src/subtree_cache.asl", "mem/src/vfs.asl", "mem/src/structural_editor.asl", "mem/src/simhash.asl", "mem/src/driver.asl", "mem/src/store.asl", "mem/src/math.asl", "mem/src/telemetry.asl", "mem/src/pointer_orchestrator.asl", "mem/src/checkpoint.asl", "mem/src/context_scoring.asl", "mem/src/bm25.asl", "mem/src/summary_search.asl", "mem/src/token_regex.asl", "mem/src/egraph.asl", "pack/tests/standalone.test.asl"]
