# Forensic Audit: Orca System & ASL Runtime Engine (2026-09-11)

Source: external forensic audit pasted by the owner into session 43abe3b2; claims re-verified in that session before adoption (see Verification below).

## 1. Path boundary rejections (:ERR_BOUNDARY_VIOLATION) — asl.c:128-135 is_safe_path
- Rejects any path containing ".." even when canonical path stays inside the workspace.
- Rejects /tmp and agent scratch roots; rejects Orca sibling worktrees outside ws_root.
- Prefix test `strncmp(path, ws_root, wlen)` without a trailing slash: `/…/asex_probe/…` passes as inside `/…/asex`.
- No realpath canonicalisation; ws_root fixed at startup, so ADR-0080 tier changes by directory are not reflected.

## 2. Blind fallbacks — asl.c
- Unknown / unimplemented ops (23 of 36 declared, incl. :exec :codec :patch :engine :proc-* :tokens) return `:status "ok"`; `:ERR_UNIMPLEMENTED` is never emitted.
- :diff / :flush / :discard are hardcoded `:vfs-status "clean"`; :edit writes disk directly (fopen "w", asl.c:1035).
- :gate / :chk return a mock `:passed 7 :active 7 :total 7` without running anything.
- :grep / :q route to the filename walker with a canned `*test*.asl` pattern (asl.c:1216).

## 3. Static buffers
- `str[1024]` (asl.c:352) positional token buffer; `file[1024]`, `old_txt[2048]`, `new_txt[2048]`, `full_path[2048]`.
- Consequence verified: `(:write f <5000 bytes>)` reports `:status ok :bytes 1023` and writes a 1023-byte file (silent truncation).

## 4. Cascading hallucination risks
Phantom verification (:chk mock), rollback illusion (:discard mock), hallucinated search basis (:grep canned list).

## 5. Unused components
visibility_scope.asl (D80 tiers) and vfs.asl (VFSBuffer, CAS, diff) are never invoked by asl.c; asl-checker duplicates the C checker; 13 leaf packages have no inbound references.

## 6. Remediation (adopted into D81 plan)
1. is_safe_path: realpath, trailing-slash prefix, allowlist of ws_root + registered worktrees + declared scratch roots — Task43809.
2. Unknown op → `:status "rejected" :error-code ":ERR_UNIMPLEMENTED"` — Task43603 (amended).
3. In-process content grep — Task43804.
4. VFS staging in C from vfs.asl semantics — Task43805.
5. Dynamic StrBuf for all argument and content buffers; no silent truncation — Task44103 (amended).

## Verification performed in session 43abe3b2 (2026-09-11 17:44)
- `(:read "mem/src/../README.md" 1 1)` → ERR_BOUNDARY_VIOLATION (confirmed).
- `(:read "/Users/purplelephant/projects/asex_probe/s.txt" 1 1)` → status ok, content returned (prefix collision confirmed).
- `(:exec "echo hi")` → `:status "ok"` with no payload (dummy confirmed).
- `(:write "tests/fixtures/big_probe.txt" <5000 x 'a'>)` → `:status ok :bytes 1023`, file 1023 bytes (truncation confirmed).
- Note: engine_js.h is a 4,049-line hex header; the decoded JavaScript evaluator is 1,772 lines.

---

# Comprehensive System Audit (second pass, 2026-09-11 18:00) — adoption notes

Eleven clusters submitted by the owner. Nine were already covered by ADR-0081 / Phase436-441. Corrections and new work below.

## Corrections to the submitted audit
1. **Cluster 9 note is stale.** `asl coverage` does NOT exit 0. Measured 18:06: all eight absent subcommands (coverage, tokens, intel, doc, task, fmt, run, codec) print an error and exit 1. The exit-0 behaviour was fixed by the engine rebuild earlier that day; documentation references remain (Task43705).
2. **Cluster 6, "62 missing :owns paths" conflates two populations.** Measured: 407 distinct paths, 62 absent. 32 are declared outputs of D81 tasks not yet executed (.claude/agents/*.md, asl/Makefile, asl/bench/*.asl, asl/bin/*.wasm, .asl/profiles.asn, tests/conformance) — correct for a planned task. 30 are genuine relics of completed phases: 18 deleted `tests/test_*_e2e.sh` gate scripts plus 12 phantom sources. Only the latter are defects. Folded into Task43904.
3. **Cluster 3, engine_js.h line count.** 4,049 lines is the hex C header; the decoded JavaScript evaluator is 1,772 lines.
4. **Cluster 10, submodule drift.** All six inspected submodules are on `main`, none detached. `harness` is 4 commits ahead of `origin/main` — unpushed, not drifted. Superproject having no commits is the owner's deliberate choice (local-only workspace, git init required by Orca).

## Immediate blocker — resolved
`harness/src/prompt_translator.asl:145` carried one stray `)` from an uncommitted parallel refactor that correctly wrapped `string-index-of` results in `(option-or … -1)` across 12 lines. Removed the single character; that line now matches HEAD and the other 11 changes are intact. `asl check` clean; `asl audit gates` 7/7 exit 0. Receipt: `rc-gate2-repair`.

## Coverage map: cluster -> existing task
| Cluster | Task |
|---|---|
| 1 Gate 2 crash (SIGABRT instead of a report) | Task43607 |
| 2 Evaluator vacuity, module resolution, Gate 5 text count | Task43601, Task43602, Task43605 |
| 3 Substrate dualism, .aslignore carve-out, JSC lock-in, ghost WASM | Task43607, Task43801, Task43802, Task43803 |
| 4 Dispatcher: blind ok, grep, mock VFS, static buffers | Task43603, Task43804, Task43805, Task44103 |
| 5 Boundary policy, /tmp, worktrees, prefix collision, D80 unenforced | Task43809 |
| 6 Git root state | owner decision: local-only workspace, no action |
| 7 Dead packages, relic :owns | Task43807, Task43904 |
| 8 C3 duplication, 111 symbols, 6 token estimators | Task43807 |
| 9 D51 CamelCase gaps, Phase415 falsely complete | Task43806, Task43904 |
| 10 Phantom subcommands in docs | Task43705 |
| 11 node_modules and Node in scripts | Task43803 |
