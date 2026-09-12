# Phase 465: Agent Working Memory Surface

## Acceptance Criteria
1. **Facade & Checkpoint Suite Integrity (Task46505)**:
   - Facade suites `mem/tests/tasks_test.asl` and `mem/tests/checkpoint_test.asl` execute with non-zero assertions verified under `--strict-falsify`.
   - VFS checkpoint persistence and cross-process buffer restoration fidelity verified without data loss.
   - Acceptance fixture `tests/acceptance/d81/Task46505.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46505`.
2. **Native Memory Command Surface & RPC Registry (Task46501)**:
   - In `asl/tools/asl.c`:
     - Implement native CLI subcommands: `asl note` (`write`, `query`, `list`), `asl task` (`claim`, `list`, `recover` dispatching to `task-recover-session`), and `asl queue` (`enqueue`, `drain`).
     - Implement RPC batch operations: `:note`, `:task`, and `:queue`.
   - In `asl/grammar/rpc.asn`:
     - Register `:note`, `:task`, and `:queue` operations in canonical registry.
   - Dispatch thin wrappers directly to `mem/src/notes.asl` (interfacing with `.asl/mem/notes.asn`) and `mem/src/tasks.asl` (interfacing with `.asl/mem/tasks/InFlight.asn` and `.asl/mem/tasks/*.asn`), adding zero superfluous logic.
   - Recompile `bin/asl` and maintain identical SHA-256 digests across `bin/asl`, `asl/bin/asl`, and `asl/asl`.
   - Acceptance fixture `tests/acceptance/d81/Task46501.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46501`.
3. **Cursor-Driven Persistent File Worklist (Task46502)**:
   - In `mem/src/worklist.asl`:
     - Implement persistent file worklist backed by `.asl/mem/worklist.asn` holding entries with path, intent, status (`pending`, `reading`, `done`, `skipped`), finding notes, and timestamp.
     - Enforce mandatory skip reason: an entry marked `skipped` without a non-empty reason string is strictly rejected.
     - Walk worklist by cursor yielding bounded batches configured per walk.
     - Ensure cursor state survives process termination and restarts.
     - Ensure two concurrent walkers do not receive colliding entries.
   - In `mem/manifest.asn`:
     - Register `"asl-mem/worklist"` in package `:modules` list.
   - Acceptance fixture `tests/acceptance/d81/Task46502.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46502`.
4. **Scope Lifecycles, Retirement & Promotion (Task46503)**:
   - In `mem/src/notes.asl` and `mem/src/amnesia.asl`:
     - Define three explicit scopes by lifetime: `step` (dies with step), `task` (dies with task), and `epic` (outlives task and session).
     - Wire scope close to promote grounded facts into tasks (`note-promote-to-task`) or decisions (`note-promote-to-adr`), and retire ephemeral notes via amnesia eviction (`evict-below-threshold`).
     - Ensure active note store remains strictly bounded under continuous note creation.
   - Acceptance fixture `tests/acceptance/d81/Task46503.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46503`.
5. **Canonical Working Memory Rule & Concession Retirement (Task46504)**:
   - In `asl/grammar/rules.asn`:
     - Add working memory rule `:id note`: instructs agents that context held which could be lost must be written down, specifying conditions and expected outcomes.
     - Retire the anchor concession (`until the ledger ops exist keep the plan in the task file and re-read it` in `asl/grammar/rules.asn:35`).
   - In `scripts/install.sh`:
     - Regenerate all client surfaces via `scripts/install.sh --render-rules`.
     - Confirm drift-free verification via `bash scripts/install.sh --check-rules`.
   - Acceptance fixture `tests/acceptance/d81/Task46504.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46504`.
6. **Empirical Evaluation & Telemetry (Task46506)**:
   - In `asl/bench` and `.asl/mem/telemetry/`:
     - Run comparative evaluation on a fixed task suite with working memory available vs withheld.
     - Measure and record unsupported claims against tree AST, dropped steps, redundant file re-reads, and tool call overhead vs task completion.
     - Emit telemetry receipt into `.asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn` with zero comments (C1) and zero emojis (C2).
   - Acceptance fixture `tests/acceptance/d81/Task46506.asl` is owned and evaluated by `independentVerifier` in post-implementation grading via `sh tests/acceptance/d81/SuperviseGate.sh Task46506`.

---

## Ordered Work Items

### Item 1: Repair Facade and Checkpoint Suite (Task46505)
- **Path**: `mem/src/tasks.asl:1-57`, `mem/src/checkpoint.asl:1-178`, `mem/tests/tasks_test.asl:1-466`, `mem/tests/checkpoint_test.asl:1-150`
- **Identity**:
  - `:id`: `"item-1"` / `"Task46505"`
  - `:title`: `"Repair the facade and the checkpoint suite the engine rests on"`
  - `:kind`: `:remediation`
  - `:lane`: `"surface"`
- **Why**: Invariant D81, ADR-0081, and Task46505:
  - The working memory engine rests on the unified task facade (`mem/src/tasks.asl:1-57`) and checkpoint engine (`mem/src/checkpoint.asl:1-178`).
  - A command surface built on an unverified facade inherits unverified paths.
  - While unit test suites `mem/tests/tasks_test.asl` and `mem/tests/checkpoint_test.asl` pass in isolation, the foundational test suites must be verified under `--strict-falsify` to enforce:
    1. Both suites report non-zero executed assertions under `--strict-falsify`.
    2. A suite executing zero assertions fails even when exit code is 0.
    3. A checkpoint written by one process restores cleanly with exact buffer fidelity in another process.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Establish verifiable baseline integrity for facade and checkpoint modules before command surface dispatch is built over them.
  - `:outcomes`:
    - Facade suites execute with non-zero assertion counts confirmed under `--strict-falsify`.
    - Checkpoint serialization and restoration verified across process boundaries.
    - Zero-assertion test execution treated as strict failure.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Use native ASL file reads and S-expression evaluation to verify checkpoint state preservation.
  - `:failure-modes`: Unbound symbols during evaluator execution; non-deterministic timestamp mismatches across test processes.
  - `:additional-requirements`: Must pass unit test gate under `--strict-falsify`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Inspect `mem/src/tasks.asl:1-57` and `mem/src/checkpoint.asl:1-178` exports.
    2. Verify non-zero assertion execution and cross-process checkpoint buffer restoration in `mem/tests/tasks_test.asl` and `mem/tests/checkpoint_test.asl`.
    3. Execute gate `./bin/asl test --strict-falsify mem/tests/tasks_test.asl mem/tests/checkpoint_test.asl`.
- **Gate**:
  ```bash
  ./bin/asl test --strict-falsify mem/tests/tasks_test.asl mem/tests/checkpoint_test.asl
  ```
- **Current Baseline Output / Status**:
  ```text
      ✓ mem/tests/tasks_test.asl: Delimiter balance and syntax integrity verified cleanly.
  PASS (asl-mem/tasks: all assertions passed cleanly across legacy, holistic, cybernetic, and post-action task protocols)
  ✓ mem/tests/tasks_test.asl: 168 assertion(s) executed and recorded cleanly.
      ✓ mem/tests/tasks_test.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ mem/tests/checkpoint_test.asl: Delimiter balance and syntax integrity verified cleanly.
  ✓ mem/tests/checkpoint_test.asl: 25 assertion(s) executed and recorded cleanly.
      ✓ mem/tests/tasks_test.asl: Delimiter balance and syntax integrity verified cleanly.
      ✓ mem/tests/checkpoint_test.asl: Delimiter balance and syntax integrity verified cleanly.
  ```
  *(Exit code 0; verifies non-zero assertions: 168 in tasks_test and 25 in checkpoint_test, total 193 assertions. Gate ensures cross-process checkpoint restoration fidelity and that zero-assertion runs fail strictly under --strict-falsify).*
- **Prerequisites (`depends_on`)**: `[]`
- **File ownership (`owns`)**: `["mem/src/tasks.asl", "mem/src/checkpoint.asl", "mem/tests/tasks_test.asl", "mem/tests/checkpoint_test.asl"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46505.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: None (Item 1 is the foundational facade verification item for Phase 465).

---

### Item 2: Native Command Surface & RPC Registry (Task46501)
- **Path**: `asl/tools/asl.c:888-970,1621-1700,5306-5327,5381-5384`, `asl/grammar/rpc.asn:1-100`, `mem/src/notes.asl:15-83`, `mem/src/tasks.asl:1-57`, `.asl/mem/notes.asn:1-56`, `.asl/mem/tasks/InFlight.asn:1-9`, `bin/asl`, `asl/bin/asl`, `asl/asl`
- **Identity**:
  - `:id`: `"item-2"` / `"Task46501"`
  - `:title`: `"A command surface over the memory that already works"`
  - `:kind`: `:tooling`
  - `:lane`: `"surface"`
- **Why**: Invariant D81, ADR-0081, and Task46501:
  - Over 237 assertions of tested working memory machinery in `mem/src/notes.asl` and `mem/src/tasks.asl` have zero users because no native command or RPC operation reaches them.
  - In `asl/tools/asl.c:5382`, invoking `./bin/asl note list` fails with `Error: unrecognized subcommand 'note'`, and `./bin/asl task claim` fails with `Error: unrecognized subcommand 'task'`.
  - In `asl/tools/asl.c:888-970`, invoking `./bin/asl rpc '(:batch (:note :list))'` fails with `:ERR_UNIMPLEMENTED`.
  - Implement native CLI subcommands in `asl/tools/asl.c`:
    - `asl note write <fact> [:topic <topic>] [:scope <scope>] [:tags <tags>]`
    - `asl note query <query>`
    - `asl note list`
    - `asl task claim <task-id> [:session <session-id>]`
    - `asl task list [:phase <phase>]`
    - `asl task recover <session-id>` (dispatching directly to `task-recover-session` in `mem/src/tasks.asl:28`)
    - `asl queue enqueue <action>`
    - `asl queue drain`
  - Implement RPC batch operations `:note`, `:task`, `:queue` in `asl/tools/asl.c:888-970` and register them in `asl/grammar/rpc.asn`.
  - Connect dispatch to `.asl/mem/notes.asn` via `mem/src/notes.asl` and `.asl/mem/tasks/InFlight.asn` via `mem/src/tasks.asl`, adding zero extra logic beyond thin dispatch.
  - Recompile `bin/asl` and duplicate to `asl/bin/asl` and `asl/asl` maintaining identical SHA-256 digests.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Provide native CLI subcommands and batch RPC operations over working memory and task lifecycle without inventing superfluous abstractions.
  - `:outcomes`:
    - `asl note`, `asl task`, and `asl queue` subcommands exist and execute cleanly.
    - RPC batch operations `:note`, `:task`, and `:queue` execute in resident batch mode.
    - Operations registered in `asl/grammar/rpc.asn`.
    - Binaries recompiled and synchronized with matching SHA-256 digest.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D46", "D81"]`
  - `:variations`: Commands read and append canonical S-expressions to `.asl/mem/notes.asn` and `.asl/mem/tasks/InFlight.asn`.
  - `:failure-modes`: File lock contention on `.asl/mem/notes.asn`; delimiter corruption during concurrent writes.
  - `:additional-requirements`: Recompile `bin/asl`, `asl/bin/asl`, and `asl/asl` with identical SHA-256 digests.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:targetSymbols`: `["make-note", "note-matches-query?", "task-claim-session", "post-action-enqueue", "task-recover-session"]`
  - `:action-dag`:
    1. Add `asl note`, `asl task` (dispatching to `task-recover-session`), and `asl queue` subcommands to `asl/tools/asl.c`.
    2. Add `:note`, `:task`, `:queue` handling to `execute_single_step` in `asl/tools/asl.c`.
    3. Register `:note`, `:task`, `:queue` operations in `asl/grammar/rpc.asn`.
    4. Recompile `bin/asl` and mirror to `asl/bin/asl` and `asl/asl`.
    5. Execute gate `./bin/asl note list && ./bin/asl rpc '(:batch (:note :list))'`.
- **Gate**:
  ```bash
  ./bin/asl note list && ./bin/asl rpc '(:batch (:note :list))'
  ```
- **Current Baseline Failure**:
  ```text
  Error: unrecognized subcommand 'note'
  ```
  *(Exit code 1; and rpc note operation rejects with :ERR_UNIMPLEMENTED: status "failed", error-code ":ERR_UNIMPLEMENTED")*
- **Prerequisites (`depends_on`)**: `["item-1"]`
- **File ownership (`owns`)**: `["asl/tools/asl.c", "asl/grammar/rpc.asn", "mem/src/notes.asl", "mem/src/tasks.asl", "bin/asl", "asl/bin/asl", "asl/asl"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46501.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Building CLI dispatch over unverified facade and checkpoint modules risks delegating to broken or unasserted functions.

---

### Item 3: Cursor-Driven File Worklist (Task46502)
- **Path**: `mem/src/worklist.asl`, `mem/manifest.asn:1-60`, `.asl/mem/worklist.asn`, `mem/tests/worklist_test.asl`, `mem/src/tasks.asl:7-8,49-53`, `asl/grammar/rpc.asn:1-100`, `asl/tools/asl.c:888-970`
- **Identity**:
  - `:id`: `"item-3"` / `"Task46502"`
  - `:title`: `"A file worklist with a per entry mark, walked by cursor"`
  - `:kind`: `:language`
  - `:lane`: `"worklist"`
- **Why**: Invariant D81, ADR-0081, and Task46502:
  - The scout and implementer workflow enumerates files across packages and walks them sequentially, but there is nowhere to store the enumeration outside model context.
  - Context decay separates retrieved slices from definitions, with the 90th percentile of binding distance measuring 232 lines.
  - Implement a persistent, cursor-driven file worklist in `mem/src/worklist.asl`:
    - Declare and use `.asl/mem/worklist.asn` as persistent worklist storage.
    - Entries hold intent against a path with status `pending`, `reading`, `done`, or `skipped`.
    - Where `skipped`, a reason string is mandatory; skipping without a reason is strictly rejected.
    - Entry holds space for empirical findings.
    - Cursor yields bounded batches with batch size configurable per walk.
    - Cursor state and entry progress persist across process restarts in `.asl/mem/worklist.asn`.
    - Concurrent walkers over the same list do not receive duplicate/colliding entries.
    - Register `"asl-mem/worklist"` in `mem/manifest.asn` `:modules` to maintain monorepo manifest consistency.
    - Wire worklist cursor operations into `asl/grammar/rpc.asn` and `asl/tools/asl.c`.
    - Author author-owned development unit test suite `mem/tests/worklist_test.asl`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Provide bounded, persistent cursor enumeration over repository files, offloading large file queues from volatile model context into `.asl/mem/worklist.asn`.
  - `:outcomes`:
    - Worklist module `mem/src/worklist.asl` implements entry state transitions.
    - Package manifest `mem/manifest.asn` registers `"asl-mem/worklist"`.
    - Persistent store `.asl/mem/worklist.asn` preserves cursor state and entries across restarts.
    - Cursor yields bounded batches that survive process restarts.
    - Invariant enforced: skip reason mandatory.
    - Unit test suite `mem/tests/worklist_test.asl` passes with non-zero assertions under `--strict-falsify`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "C3", "D46", "D81"]`
  - `:variations`: Worklist persists as machine ASN in `.asl/mem/worklist.asn` with atomic file writes.
  - `:failure-modes`: Cursor index out of bounds; empty string accepted as skip reason.
  - `:additional-requirements`: Recompile engine binaries if `asl/tools/asl.c` is updated.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Author development unit test suite `mem/tests/worklist_test.asl`.
    2. Implement worklist struct, entry states, persistent storage in `.asl/mem/worklist.asn`, and cursor batch logic in `mem/src/worklist.asl`.
    3. Register `"asl-mem/worklist"` in `mem/manifest.asn` `:modules`.
    4. Integrate with `PostActionQueue` and facade in `mem/src/tasks.asl`, plus RPC in `asl/grammar/rpc.asn` / `asl/tools/asl.c`.
    5. Execute gate `./bin/asl test --strict-falsify mem/tests/worklist_test.asl`.
- **Gate**:
  ```bash
  ./bin/asl test --strict-falsify mem/tests/worklist_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  Error: test file not found: mem/tests/worklist_test.asl
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **File ownership (`owns`)**: `["mem/src/worklist.asl", "mem/manifest.asn", ".asl/mem/worklist.asn", "mem/tests/worklist_test.asl", "mem/src/tasks.asl", "asl/grammar/rpc.asn", "asl/tools/asl.c"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46502.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Worklist cursor operations depend on the native CLI and RPC dispatch layer established in Item 2.

---

### Item 4: Note Scope Lifecycles, Retirement & Promotion (Task46503)
- **Path**: `mem/src/notes.asl:15-26,52-56,105-134`, `mem/src/amnesia.asl:1-38`, `.asl/mem/notes.asn:1-56`, `mem/tests/notes_scope_test.asl`
- **Identity**:
  - `:id`: `"item-4"` / `"Task46503"`
  - `:title`: `"Scope means something: step, task, epic, and what retires a note"`
  - `:kind`: `:protocol`
  - `:lane`: `"scope"`
- **Why**: Invariant D81, ADR-0081, and Task46503:
  - Notes carry a scope field in `mem/src/notes.asl:22`, but no lifetime rules govern what happens when a scope closes.
  - Without lifetime boundaries, note stores either grow unboundedly or get cleared indiscriminately, losing valuable architectural observations.
  - Define three explicit scopes by lifetime:
    - `step`: dies with step completion.
    - `task`: dies with task completion.
    - `epic`: outlives task and session, inherited by subsequent sessions.
  - Closing a scope promotes enduring grounded findings into tasks (`note-promote-to-task`) or decisions (`note-promote-to-adr`), while transient observations are retired via amnesia eviction (`evict-below-threshold`).
  - Active store remains strictly bounded under continuous writing.
  - Author development unit test suite `mem/tests/notes_scope_test.asl` verifying:
    1. Closing a step retires its step notes and leaves task notes intact.
    2. A note promoted at scope close is retrievable after the scope is gone.
    3. The active store under continuous writing stays bounded, measured rather than asserted.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Establish deterministic note lifetimes and automated scope promotion/retirement, keeping working memory retrieval cost bounded.
  - `:outcomes`:
    - Three lifetimes (`step`, `task`, `epic`) enforced.
    - Scope close triggers promotion of durable findings and retirement of transient notes.
    - Note store boundedness verified under sustained write load.
    - Unit test suite `mem/tests/notes_scope_test.asl` passes with non-zero assertions under `--strict-falsify`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D46", "D81"]`
  - `:variations`: Use `mem/src/amnesia.asl` chunk DAG confidence scoring to identify high-value vs low-confidence notes.
  - `:failure-modes`: Accidental eviction of epic notes; memory leak from dangling unretired step notes.
  - `:additional-requirements`: Note files must conform to C1 (zero comments) and C2 (zero emojis).
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Author development unit test suite `mem/tests/notes_scope_test.asl`.
    2. Add lifetime scope definitions and close-scope transition functions to `mem/src/notes.asl`.
    3. Wire eviction thresholding and confidence pruning to `mem/src/amnesia.asl`.
    4. Execute gate `./bin/asl test --strict-falsify mem/tests/notes_scope_test.asl`.
- **Gate**:
  ```bash
  ./bin/asl test --strict-falsify mem/tests/notes_scope_test.asl
  ```
- **Current Baseline Failure**:
  ```text
  Error: test file not found: mem/tests/notes_scope_test.asl
  ```
  *(Exit code 1)*
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **File ownership (`owns`)**: `["mem/src/notes.asl", "mem/src/amnesia.asl", ".asl/mem/notes.asn", "mem/tests/notes_scope_test.asl"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46503.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Scope lifecycle transitions operate on note persistence and querying added in Item 2.

---

### Item 5: Canonical Working Memory Rule & Concession Retirement (Task46504)
- **Path**: `asl/grammar/rules.asn:34-36,53-55`, `scripts/install.sh:61-99,103-104`, `AGENTS.md:1-60`, `.agents/skills/asl-toolbelt/SKILL.md`, `asl/.agents/skills/asl-toolbelt/SKILL.md`, `.agents/skills/asl-toolbelt/skill.asn`, `asl/.agents/skills/asl-toolbelt/skill.asn`
- **Identity**:
  - `:id`: `"item-5"` / `"Task46504"`
  - `:title`: `"Tell the agent the memory exists, and why rather than when"`
  - `:kind`: `:protocol`
  - `:lane`: `"surface"`
- **Why**: Invariant D81, ADR-0081, and Task46504:
  - The word `note` appears zero times in `asl/grammar/rules.asn` and zero times in rendered instructions (`AGENTS.md`). Agents are never instructed that working memory exists.
  - In `asl/grammar/rules.asn:35`, the `anchor` rule explicitly concedes:
    `:do "... until the ledger ops exist keep the plan in the task file and re-read it"`.
  - Add working memory rule (`:rule :id note`) to `asl/grammar/rules.asn`: instructs agents why to record working notes (what is held in context that would be lost, conditions to survive, expected results) rather than prescribing a rigid procedural checklist.
  - Retire the anchor concession now that native memory commands and ledger operations exist.
  - Regenerate client surfaces with `scripts/install.sh --render-rules` and verify drift-free parity with `bash scripts/install.sh --check-rules`.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Tell agents that working memory exists through the single canonical source of truth, explain why to record notes, and retire the anchor concession.
  - `:outcomes`:
    - Working memory rule added to `asl/grammar/rules.asn`.
    - Anchor concession removed from rule `:id anchor`.
    - Surfaces regenerated via `scripts/install.sh --render-rules`.
    - `bash scripts/install.sh --check-rules` passes cleanly across all 7 rendered surfaces.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Maintain single-source-of-truth invariant (rule edits in `rules.asn` only; rendered surfaces generated via `install.sh`).
  - `:failure-modes`: Hand-editing `AGENTS.md` or skill definitions causing drift check failure; referencing non-existent CLI flags.
  - `:additional-requirements`: Must pass `bash scripts/install.sh --check-rules`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Add `:rule :id note` and retire anchor concession in `asl/grammar/rules.asn`.
    2. Run `scripts/install.sh --render-rules` to regenerate `scripts/install.sh`, `AGENTS.md`, `.agents/skills/asl-toolbelt/SKILL.md`, `asl/.agents/skills/asl-toolbelt/SKILL.md`, `.agents/skills/asl-toolbelt/skill.asn`, and `asl/.agents/skills/asl-toolbelt/skill.asn`.
    3. Execute gate `bash scripts/install.sh --check-rules`.
- **Gate**:
  ```bash
  bash scripts/install.sh --check-rules
  ```
- **Current Baseline Output / Status**:
  ```text
    ok   agents-md
    ok   skill-md
    ok   skill-md-asl
    ok   install-template
    ok   install-directive
    ok   skill-asn (/Users/purplelephant/projects/asex/.agents/skills/asl-toolbelt/skill.asn)
    ok   skill-asn (/Users/purplelephant/projects/asex/asl/.agents/skills/asl-toolbelt/skill.asn)
  rules: all surfaces identical to /Users/purplelephant/projects/asex/asl/grammar/rules.asn
  ```
  *(Exit code 0 on clean tree; immediately fails with exit code 1 and rules: drift detected when rules.asn is edited before render-rules is executed).*
- **Prerequisites (`depends_on`)**: `["item-2"]`
- **File ownership (`owns`)**: `["asl/grammar/rules.asn", "scripts/install.sh", "AGENTS.md", ".agents/skills/asl-toolbelt/SKILL.md", "asl/.agents/skills/asl-toolbelt/SKILL.md", ".agents/skills/asl-toolbelt/skill.asn", "asl/.agents/skills/asl-toolbelt/skill.asn"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46504.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Citing working memory commands (`asl note`, `asl task`, `asl queue`) before Item 2 implements them would violate Invariant D81 (Instruction Surface Truth).

---

### Item 6: Empirical Evaluation and Verification Telemetry (Task46506)
- **Path**: `asl/bench`, `.asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`
- **Identity**:
  - `:id`: `"item-6"` / `"Task46506"`
  - `:title`: `"Measure whether keeping notes actually helps"`
  - `:kind`: `:verification`
  - `:lane`: `"effect"`
- **Why**: Invariant D81, ADR-0081, and Task46506:
  - The expected benefits of working memory (reduced hallucinations, sustained attention, lower context binding distance) are hypotheses until empirically measured.
  - Run comparative evaluation on a fixed task suite with note-keeping available vs withheld:
    - Unsupported claims about codebase counted against AST/tree.
    - Steps dropped from declared plan.
    - Files re-read after being read.
    - Tool call overhead vs task completion rate.
  - Record machine-readable receipt in `.asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn` with zero comments (C1) and zero emojis (C2).
  - A null or negative result is recorded and passes the gate, ensuring measurement is not confirmatory-only.
- **Context & Intent**:
  - `:context`: `D81PlanContext`
  - `:purpose`: Measure empirical impact of working memory commands on agent attention, hallucination rate, and tool call cost.
  - `:outcomes`:
    - Comparative evaluation executed across memory-enabled and memory-withheld arms.
    - Concrete counts recorded for unsupported claims, dropped steps, and re-reads.
    - Empirical telemetry receipt written to `.asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`.
    - Telemetry receipt syntax and delimiter balance verified via `./bin/asl check`.
- **Constraints & Contingencies**:
  - `:invariants`: `["C1", "C2", "D81"]`
  - `:variations`: Evaluation harness executes fixed tasks in isolated scratch environments.
  - `:failure-modes`: Telemetry file formatting invalid ASN; claims judged subjectively rather than against AST tree.
  - `:additional-requirements`: Must be valid ASN passing `bin/asl check .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`.
- **Traceability**:
  - `:adr`: `"ADR-0081"`
  - `:decision`: `"d81"`
  - `:action-dag`:
    1. Define benchmark task set and outcome metrics in `asl/bench`.
    2. Execute both arms (memory available vs withheld) on the task set.
    3. Record comparative telemetry in `.asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`.
    4. Execute gate `test -f .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && ./bin/asl check .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn`.
- **Gate**:
  ```bash
  test -f .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn && ./bin/asl check .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn
  ```
- **Current Baseline Failure**:
  ```text
  (no output)
  ```
  *(Exit code 1; file .asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn does not exist)*
- **Prerequisites (`depends_on`)**: `["item-5"]`
- **File ownership (`owns`)**: `["asl/bench", ".asl/mem/telemetry/WorkingMemoryEvaluation20260912.asn"]`
- **Verification ownership (`verificationOwns`)**: `["tests/acceptance/d81/Task46506.asl"]` (owned by independentVerifier per Invariant hiddenTests)
- **What breaks if run before prerequisite**: Evaluating agent performance with memory instructions enabled before rules are rendered in Item 5 would measure an agent unaware of the note-keeping policy.

---

## Risks
1. **Binary Parity and Distribution Drift**:
   Modifications to `asl/tools/asl.c` in Item 2 and Item 3 require recompiling `bin/asl` and replicating to `asl/bin/asl` and `asl/asl`. Divergence in binary hashes will fail Gate 4/7 during `bin/asl audit gates`.
2. **Rule Drift Check Sensitivity**:
   `scripts/install.sh --check-rules` strictly compares SHA-256 hashes of rendered surfaces against `asl/grammar/rules.asn`. Any manual edit to `AGENTS.md` or skill definitions outside `--render-rules` will cause Item 5 gate to fail immediately.
3. **Evaluation Non-Determinism in Telemetry**:
   Comparative LLM benchmarking can exhibit stochastic variance across runs. The evaluation criteria in Task46506 must measure structural artifacts (AST claims against tree, duplicate file reads in log, step counts in plan) rather than prose similarity.
4. **Benchmark Model Sensitivity and Local Execution**:
   Whether the comparative benchmark task set in `asl/bench` can be evaluated deterministically in local headless execution without external API dependencies remains unverified until Item 6 harness scripts are authored. The benchmark suite should evaluate reproducible structural metrics (AST token verification, step drop counts) that execute deterministically without relying on network-bound external LLM APIs.

---

## Out of Scope
1. **Second Memory Engine Construction**:
   Building a separate or alternate memory engine is strictly prohibited. Phase 465 provides a door over the existing, tested 237-assertion memory engine (`mem/src/notes.asl`, `mem/src/tasks.asl`, `mem/src/checkpoint.asl`).
2. **WASM / Self-Hosting Compiler Rebuild**:
   Rewriting `asl.c` into pure self-hosted ASL is tracked under Phase 438/440.
3. **Subsystem Test Suite Rebinding (Phase 454 / Phase 443)**:
   Remediating external dead suites across browser-plugin, harness, or voice is tracked under Phase 443/444 and Phase 454.

---

## Opportunities & Suggestions
1. **Automated Worklist Pre-Population from Git Diff**:
   Provide a helper command `asl worklist seed --git-diff` that parses `git diff --name-only` or staged files into a ready-to-walk worklist for implementer subagents.
2. **Interactive Note Query TUI Shorthand**:
   Support an interactive fuzzy search mode for `asl note query` when stdout is connected to a terminal, allowing human developers to rapidly search session observations.
3. **Structured Telemetry Ingestion into Continuous Dashboard**:
   Extend `.asl/mem/telemetry/` with automated trend graphing across phases to track error reduction and token efficiency over time.
