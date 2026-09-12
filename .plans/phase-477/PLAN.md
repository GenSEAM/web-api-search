# Phase 477 Task47701: Normalize Raw Unicode Emojis & Pictographs

## Acceptance Criterion
1. **Invariant C2 (Zero Raw Unicode Emojis & Pictographs)**: All raw unicode emojis (`U+1F300..U+1FAFF`) and terminal UI pictographs (`▶▼⠋❯◆✔✓✗⏸`) across `asl/web` components/views/scripts/data, `agent/src/asn_boxart.asl`, and `agent/src/tui.asl` must be eliminated and replaced with standardized ASCII indicators or SVG vector icons.
2. **Canonical ASCII Mappings**:
   - `▶` -> `[>]`
   - `▼` -> `[v]`
   - `⠋` -> `[~]`
   - `❯` -> `>`
   - `◆` -> `[*]`
   - `✔` / `✓` -> `[OK]`
   - `✗` -> `[FAIL]`
   - `⏸` -> `[||]`
3. **Test Assertion Synchronization & Integrity**: All unit test assertions in `agent/tests/tui-test.asl` and `mem/tests/vfs_sync_test.asl` must be updated to expect the new ASCII indicators. All 47 assertions in `agent/tests/tui-test.asl` and all 38 assertions in `mem/tests/vfs_sync_test.asl` must pass cleanly under `./bin/asl test`.
4. **Acceptance Verification Gate**: The composite gate command must exit with code 0:
   ```bash
   python3 -c 'import re, glob, sys; emoji_pat = re.compile(r"[\U0001F300-\U0001FAFF]"); picto_pat = re.compile(r"[▶▼⠋❯◆✔✓✗⏸]"); files = glob.glob("asl/web/**/*.asl", recursive=True) + ["agent/src/asn_boxart.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl"]; found = sum(len(emoji_pat.findall(open(f).read())) + len(picto_pat.findall(open(f).read())) for f in files); sys.exit(1 if found > 0 else 0)' && ./bin/asl test agent/tests/tui-test.asl && ./bin/asl test mem/tests/vfs_sync_test.asl
   ```

---

## Evidence & Current Behavior

Measured on 2026-09-12 against repository baseline: **100 matches** (34 emojis, 66 pictographs) across 14 target files.

1. **[agent/src/asn_boxart.asl:22-28](file:///Users/purplelephant/projects/asex/agent/src/asn_boxart.asl#L22-L28)**:
   - `format-box-badge` emits `✓` (line 23), `▶` (line 24), `✗` (line 25), and `⏸` (line 26).
   - [agent/src/asn_boxart.asl:82](file:///Users/purplelephant/projects/asex/agent/src/asn_boxart.asl#L82): `render-dag-boxart` emits `▼` directional connector.
   - Total: 5 pictographs.

2. **[agent/src/tui.asl:100-123](file:///Users/purplelephant/projects/asex/agent/src/tui.asl#L100-L123)**:
   - `format-tool-call` (line 100) emits `▶`.
   - `format-tool-call-fold` (lines 105-106) emits `▶` and `▼`.
   - `format-spinner-status` (line 110) emits `⠋`.
   - `format-chat-msg` (lines 115-116) emits `❯` and `◆`.
   - `format-session-summary` (line 121) emits `✔`.
   - Total: 7 pictographs.

3. **[agent/tests/tui-test.asl:37-126](file:///Users/purplelephant/projects/asex/agent/tests/tui-test.asl#L37-L126)**:
   - Assertions assert against pictographs: line 37 (`▶`), line 46 (`▶`), line 48 (`▼`), line 54 (`⠋`), line 61 (`❯`), line 62 (`◆`), line 69 (`✔`), line 126 (`▶`).
   - Total: 8 pictographs.

4. **[mem/tests/vfs_sync_test.asl:96-101](file:///Users/purplelephant/projects/asex/mem/tests/vfs_sync_test.asl#L96-L101)**:
   - Assertions assert against pictographs: line 96 (`✓`), line 97 (`▶`), line 98 (`✗`), line 101 (`▼`).
   - Total: 4 pictographs.

5. **asl/web Components (17 matches)**:
   - [asl/web/src/components/Footer.asl:9](file:///Users/purplelephant/projects/asex/asl/web/src/components/Footer.asl#L9): contains `🦎` (`U+1F98E`).
   - [asl/web/src/components/InBrowserCompanion.asl:10,13,16,24,25,26,27,28](file:///Users/purplelephant/projects/asex/asl/web/src/components/InBrowserCompanion.asl#L10): contains 8 emojis (`🎨`, `🕹️`, `🌐`, `💎`, `🚀`, `🕹️`, `🧮`, `🦎`).
   - [asl/web/src/components/ModuleGraphVisualizer.asl:240,268,280,294,343,534](file:///Users/purplelephant/projects/asex/asl/web/src/components/ModuleGraphVisualizer.asl#L240): contains 4 emojis (`📐`, `🏛`, `🏷`, `🔗`) and 2 pictographs (`▶`).
   - [asl/web/src/components/KeyCapabilities.asl:134](file:///Users/purplelephant/projects/asex/asl/web/src/components/KeyCapabilities.asl#L134) & [asl/web/asl-src/components/KeyCapabilities.asl:134](file:///Users/purplelephant/projects/asex/asl/web/asl-src/components/KeyCapabilities.asl#L134): contains `✓`.

6. **asl/web Views, Scripts & Blog Data (59 matches)**:
   - [asl/web/src/views/InIdeView.asl:8](file:///Users/purplelephant/projects/asex/asl/web/src/views/InIdeView.asl#L8): contains 17 emojis (`🌐`, `🚀`, `📄`, `📦`, `🤖`, `🕹`, `🦖`, `🔍`, `🎨`, `📥`, `📤`, `📝`) and 2 pictographs (`✓`).
   - [asl/web/src/views/PlaygroundView.asl:8,220](file:///Users/purplelephant/projects/asex/asl/web/src/views/PlaygroundView.asl#L8): contains `✓` (line 8) and `👟` (line 220).
   - [asl/web/asl-src/scripts/installer.asl:25,31,34,42,53,66](file:///Users/purplelephant/projects/asex/asl/web/asl-src/scripts/installer.asl#L25): contains 3 emojis (`🚀`, `📦`) and 3 pictographs (`✓`).
   - [asl/web/scripts/gen-web.asl:8](file:///Users/purplelephant/projects/asex/asl/web/scripts/gen-web.asl#L8): contains `✓`.
   - [asl/web/src/data/blog/posts.asl:52,66,80,94,150,192,206,220,234,248,304](file:///Users/purplelephant/projects/asex/asl/web/src/data/blog/posts.asl#L52): contains 31 pictographs (`✓`, `✗`, `▼`).

---

## Ordered Work Items

### Item 1: agent TUI & Boxart Pictogram to ASCII Normalization
- **Path**: `agent/src/asn_boxart.asl`, `agent/src/tui.asl`
- **Why**: Satisfies Invariant C2 for agent terminal interfaces. Replace pictograms with standardized ASCII symbols:
  - In `agent/src/asn_boxart.asl`: In `format-box-badge`, replace `"✓"` with `"OK"`, `"▶"` with `">"`, `"✗"` with `"FAIL"`, `"⏸"` with `"||"` (resulting in `"[OK] "`, `"[>] "`, `"[FAIL] "`, `"[||] "` since `format-box-badge` wraps `icon` in `[...]`). In `render-dag-boxart:82`, replace directional connector `"▼"` with `"[v]"`.
  - In `agent/src/tui.asl`: In `format-tool-call:100` and `format-tool-call-fold:105`, replace `"▶"` with `"[>]"`. In `format-tool-call-fold:106`, replace `"▼"` with `"[v]"`. In `format-spinner-status:110`, replace `"⠋"` with `"[~]"`. In `format-chat-msg:115-116`, replace `"❯"` with `">"` and `"◆"` with `"[*]"`. In `format-session-summary:121`, replace `"✔"` with `"[OK]"`.
- **Gate**:
  ```bash
  python3 -c 'import re, sys; pat = re.compile(r"[\U0001F300-\U0001FAFF▶▼⠋❯◆✔✓✗⏸]"); count = sum(len(pat.findall(open(f).read())) for f in ["agent/src/asn_boxart.asl", "agent/src/tui.asl"]); sys.exit(0 if count == 0 else 1)'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
  *(12 matches found: 5 in asn_boxart.asl, 7 in tui.asl)*
- **What breaks if run before previous item**: None (First execution item).
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["agent/src/asn_boxart.asl", "agent/src/tui.asl"]`

---

### Item 2: Synchronize Unit Test Assertions for Agent TUI & Boxart ASCII Indicators
- **Path**: `agent/tests/tui-test.asl`, `mem/tests/vfs_sync_test.asl`
- **Why**: Prevent test breakage following Item 1's ASCII conversion, and eliminate pictographs embedded in assertion check strings.
  - In `agent/tests/tui-test.asl`: Update string assertions:
    - Line 37: `"[>] [read_file]"`
    - Line 46: `"[>] [asl:test] batch_test.asl → passed"`
    - Line 48: `"[v] [asl:test] batch_test.asl → passed"`
    - Line 54: `"[~] Executing verification gates..."`
    - Line 61: `"\n> Refactor"`
    - Line 62: `"\n[*] Policy updated."`
    - Line 69: `"[OK] Session complete (4 turns)"`
    - Line 126: `"[>] [read]"`
  - In `mem/tests/vfs_sync_test.asl`: Update string assertions:
    - Line 96: `"[OK] Task Alpha"`
    - Line 97: `"[>] Task Beta"`
    - Line 98: `"[FAIL] Task Gamma"`
    - Line 101: `"[v]"`
- **Gate**:
  ```bash
  ./bin/asl test agent/tests/tui-test.asl && ./bin/asl test mem/tests/vfs_sync_test.asl && python3 -c 'import re, sys; pat = re.compile(r"[\U0001F300-\U0001FAFF▶▼⠋❯◆✔✓✗⏸]"); count = sum(len(pat.findall(open(f).read())) for f in ["agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl"]); sys.exit(0 if count == 0 else 1)'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
  *(12 matches found: 8 in tui-test.asl, 4 in vfs_sync_test.asl)*
- **What breaks if run before Item 1**: Test assertions expecting `[>]`, `[v]`, `[OK]` will fail against unpatched `asn_boxart.asl` and `tui.asl` which output `▶`, `▼`, `✔`.
- **Prerequisites (`depends_on`)**: `["agent/src/asn_boxart.asl", "agent/src/tui.asl"]` (Item 1)
- **File ownership (`owns`)**: `["agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl"]`

---

### Item 3: Eradicate Raw Unicode Emojis & Pictographs in asl/web Components
- **Path**: `asl/web/src/components/Footer.asl`, `asl/web/src/components/InBrowserCompanion.asl`, `asl/web/src/components/ModuleGraphVisualizer.asl`, `asl/web/src/components/KeyCapabilities.asl`, `asl/web/asl-src/components/KeyCapabilities.asl`
- **Why**: Enforces Invariant C2 across web component templates and interactive visualizers.
  - In `asl/web/src/components/Footer.asl:9`: Remove `🦎` (`U+1F98E`) mascot emoji from tooltip text.
  - In `asl/web/src/components/InBrowserCompanion.asl`: Replace tab emojis (`🎨`, `🕹️`, `🌐`) with clean typography or pure SVG; remove template badge emojis (`💎`, `🚀`, `🕹️`, `🧮`, `🦎`).
  - In `asl/web/src/components/ModuleGraphVisualizer.asl`: Replace tab & header emojis (`📐`, `🏛`, `🏷`, `🔗`) with clean text labels; replace button pictographs `▶ Execute in Jailed Sandbox` with `[>] Execute in Jailed Sandbox` (both markup at line 343 and runtime handler at line 534).
  - In `asl/web/src/components/KeyCapabilities.asl:134` & `asl/web/asl-src/components/KeyCapabilities.asl:134`: Replace `✓ PASS (12/12)` with `[OK] PASS (12/12)`.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; pat = re.compile(r"[\U0001F300-\U0001FAFF▶▼⠋❯◆✔✓✗⏸]"); files = glob.glob("asl/web/**/components/*.asl", recursive=True); count = sum(len(pat.findall(open(f).read())) for f in files); sys.exit(0 if count == 0 else 1)'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
  *(17 matches found: 1 in Footer.asl, 8 in InBrowserCompanion.asl, 6 in ModuleGraphVisualizer.asl, 2 in KeyCapabilities.asl)*
- **What breaks if run before Item 1**: Can run in parallel wave with Item 1 (disjoint files).
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["asl/web/src/components/Footer.asl", "asl/web/src/components/InBrowserCompanion.asl", "asl/web/src/components/ModuleGraphVisualizer.asl", "asl/web/src/components/KeyCapabilities.asl", "asl/web/asl-src/components/KeyCapabilities.asl"]`

---

### Item 4: Eradicate Raw Unicode Emojis & Pictographs in asl/web Views, Scripts & Blog Data
- **Path**: `asl/web/src/views/InIdeView.asl`, `asl/web/src/views/PlaygroundView.asl`, `asl/web/asl-src/scripts/installer.asl`, `asl/web/scripts/gen-web.asl`, `asl/web/src/data/blog/posts.asl`, `asl/web/src/data/blog/posts.asn`
- **Why**: Eliminates all remaining emojis and pictographs in web views, generator scripts, and blog post AST markdown data.
  - In `asl/web/src/views/InIdeView.asl:8`:
    - Model options: replace `🌐 OpenAI-Compatible API` with `OpenAI-Compatible API`, `🚀 Boost: Large Host Daemon` with `Boost: Large Host Daemon`.
    - VFS tree nodes: remove `📄` and `📦` prefix emojis.
    - Chat & Preset buttons: replace `🤖 Addie Agent:` with `[Agent] Addie Agent:`, `✓ Ingested` with `[OK] Ingested`, `✓ 124ms (OK)` with `[OK] 124ms (OK)`. Remove preset button emojis (`🕹️`, `🦖`, `🔍`, `🎨`).
    - Modal actions: remove `📥`, `📤`, `📦`, `📄`, `📝` emojis from modal labels.
  - In `asl/web/src/views/PlaygroundView.asl:8,220`: Replace `✓` with `[OK]` (line 8) and `👟` with `[Run]` (line 220).
  - In `asl/web/asl-src/scripts/installer.asl:25-66`: Replace `🚀 Installing` with `Installing`, `📦 Updating/Cloning` with `Updating/Cloning`, and `✓` with `[OK]`.
  - In `asl/web/scripts/gen-web.asl:8`: Replace `✓ All web models` with `[OK] All web models`.
  - In `asl/web/src/data/blog/posts.asl` and `asl/web/src/data/blog/posts.asn`: Replace 31 pictographs (`✓` -> `[OK]`, `✗` -> `[FAIL]`, `▼` -> `[v]`) across blog post markdown bodies.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; pat = re.compile(r"[\U0001F300-\U0001FAFF▶▼⠋❯◆✔✓✗⏸]"); files = glob.glob("asl/web/**/*.asl", recursive=True); count = sum(len(pat.findall(open(f).read())) for f in files); sys.exit(0 if count == 0 else 1)'
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  ```
  *(76 matches found in asl/web/**/*.asl when components are unpatched, or 59 remaining after Item 3)*
- **What breaks if run before Item 3**: Item 4 gate scans all `asl/web/**/*.asl`, so if components from Item 3 are not yet normalized, Item 4 gate will fail due to the 17 matches in components.
- **Prerequisites (`depends_on`)**: `["asl/web/src/components/Footer.asl", "asl/web/src/components/InBrowserCompanion.asl", "asl/web/src/components/ModuleGraphVisualizer.asl", "asl/web/src/components/KeyCapabilities.asl", "asl/web/asl-src/components/KeyCapabilities.asl"]` (Item 3)
- **File ownership (`owns`)**: `["asl/web/src/views/InIdeView.asl", "asl/web/src/views/PlaygroundView.asl", "asl/web/asl-src/scripts/installer.asl", "asl/web/scripts/gen-web.asl", "asl/web/src/data/blog/posts.asl", "asl/web/src/data/blog/posts.asn"]`

---

### Item 5: Composite Monorepo Gate & Falsification Verification
- **Path**: `asl/web/**/*.asl`, `agent/src/asn_boxart.asl`, `agent/src/tui.asl`, `agent/tests/tui-test.asl`, `mem/tests/vfs_sync_test.asl`
- **Why**: Final end-to-end acceptance gate verifying zero raw unicode emojis or pictographs across all target files, and ensuring all affected test suites pass cleanly with non-zero evaluated assertions.
- **Gate**:
  ```bash
  python3 -c 'import re, glob, sys; emoji_pat = re.compile(r"[\U0001F300-\U0001FAFF]"); picto_pat = re.compile(r"[▶▼⠋❯◆✔✓✗⏸]"); files = glob.glob("asl/web/**/*.asl", recursive=True) + ["agent/src/asn_boxart.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl"]; found = sum(len(emoji_pat.findall(open(f).read())) + len(picto_pat.findall(open(f).read())) for f in files); sys.exit(1 if found > 0 else 0)' && ./bin/asl test agent/tests/tui-test.asl && ./bin/asl test mem/tests/vfs_sync_test.asl
  ```
- **Current Verbatim Output**:
  ```text
  [Command exited with code 1]
  Found 100 matches in target files
  ```
- **What breaks if run before Items 1–4**: Fails if any single emoji or pictograph remains in any target file, or if any test assertion mismatches the rendered output.
- **Prerequisites (`depends_on`)**: `["agent/src/asn_boxart.asl", "agent/src/tui.asl", "agent/tests/tui-test.asl", "mem/tests/vfs_sync_test.asl", "asl/web/**/*.asl"]` (Items 1, 2, 3, 4)
- **File ownership (`owns`)**: `[]` (Verification harness)

---

## Parallel Execution Waves

```mermaid
graph TD
    W1A["Item 1: agent TUI & Boxart Normalization"]
    W1B["Item 3: asl/web Components Normalization"]
    
    W1A --> W2A["Item 2: Synchronize Unit Test Assertions"]
    W1B --> W2B["Item 4: asl/web Views, Scripts & Blog Data"]
    
    W2A --> W3["Item 5: Composite Acceptance Gate"]
    W2B --> W3
```

- **Wave 1 (Independent Parallel Edits - Disjoint Files)**:
  - **Item 1**: `agent/src/asn_boxart.asl`, `agent/src/tui.asl`
  - **Item 3**: `asl/web/src/components/*`, `asl/web/asl-src/components/*`
- **Wave 2 (Dependent Updates)**:
  - **Item 2**: `agent/tests/tui-test.asl`, `mem/tests/vfs_sync_test.asl` (depends on Item 1)
  - **Item 4**: `asl/web/src/views/*`, `asl/web/asl-src/scripts/*`, `asl/web/scripts/*`, `asl/web/src/data/blog/*` (depends on Item 3)
- **Wave 3 (Composite Verification)**:
  - **Item 5**: Composite Monorepo Gate & Falsification Verification

---

## Risks & Mitigations

1. **Risk: Double-Bracket Formatting in Boxart Badge**:
   - `format-box-badge` in `agent/src/asn_boxart.asl:28` already evaluates `(str "[" icon "] " text)`. If the icon string is set to `"[OK]"` instead of `"OK"`, the output becomes `"[[OK]] Task Alpha"`.
   - *Mitigation*: Ensure the icon replacement in `format-box-badge` is `"OK"`, `">"`, `"FAIL"`, and `"||"` without surrounding brackets, so `str "[" icon "] "` generates exact `"[OK] "`, `"[>] "`, `"[FAIL] "`, and `"[||] "`.
2. **Risk: Discrepancy Between `posts.asl` and `posts.asn`**:
   - `posts.asl` contains generated or duplicate blog posts from `posts.asn`. If only `posts.asl` is edited, a subsequent `gen-web` run will overwrite the fixes with raw pictographs from `posts.asn`.
   - *Mitigation*: Item 4 explicitly owns and replaces pictographs in both `posts.asl` and `posts.asn`.
3. **Risk: Dual Tree in `asl/web` (`src/` vs `asl-src/`)**:
   - `asl/web` contains both `src/components/KeyCapabilities.asl` and `asl-src/components/KeyCapabilities.asl`. The composite gate uses `asl/web/**/*.asl` which matches both.
   - *Mitigation*: Items 3 and 4 explicitly own and normalize both directories.

---

## Out of Scope

- **Subsequent Phase 477 Tasks**:
  - Task47702: Eradicate relative directory traversal (`../../`) across package boundaries (intel, mem, agent-bus).
  - Task47703: Unify multi-definition `TaskState` enum and `TaskRecord` struct in agent-core.
  - Task47704: Consolidate 56 duplicate helpers in mem/src and purge pack orphan.
- **CamelCase Test Renaming (D51)**:
  - Renaming 1,626 test functions is scheduled under Phase 5.
- **Emojis in Third-Party / Distribution Files**:
  - `asl/web/node_modules/` and `asl/web/dist/` are generated/vendor trees and excluded from ASL source invariant C2.

---

## Opportunities & Suggestions

1. **Automated Invariant C2 Pre-Commit Hook**:
   - Add a git pre-commit hook or AST lint check in `asl/packages/asl-lint` that rejects commits introducing characters matching `[\U0001F300-\U0001FAFF]` or `[▶▼⠋❯◆✔✓✗⏸]`.
2. **Centralized ASCII TUI Glyphs Module (`asl-tui/glyphs`)**:
   - Expose standard constants (`GLYPH_OK = "[OK]"`, `GLYPH_FAIL = "[FAIL]"`, `GLYPH_RUN = "[>]"`, `GLYPH_DOWN = "[v]"`, `GLYPH_SPIN = "[~]"`) in a shared module so TUI and boxart renderers don't hardcode magic string indicators.
