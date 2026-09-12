# Phase 472 Plan: Runtime Boundary and Memory Safety

## Status
- **Phase**: Phase472RuntimeBoundaryAndMemorySafety
- **Priority**: Developer Tooling & Safety (Top priority per user instruction)
- **Status**: completed

## Context & Baseline Findings
1. **Task47201 (No Shell Command Built from Request Input)**:
   - In `asl/tools/asl.c`, `op_git` with `subop == "commit"` (lines ~1800-1802) constructs `char cmd[4096]` using `snprintf(cmd, sizeof(cmd), "git -C \"%s\" commit -m \"%s\" 2>/dev/null", ws_root, msg);` and invokes `system(cmd)`.
   - Any commit message containing unescaped double quotes, semicolons, command substitutions (`$()`, `` ` ``) executes arbitrary shell commands under the invoking user.
   - Solution: Replace shell invocation with safe direct child execution via `fork()` + `execvp()` or safe argument passing (`git -C <ws_root> commit -m <msg>`). No shell interpolation.

2. **Task47202 (One Boundary Check on Every Path, Including JS Bridge)**:
   - In `asl/tools/asl.c`, `op_find` (lines 1501-1507) and `op_grep` (lines 1565-1570) allow passing arbitrary absolute paths without passing through `is_safe_path`.
   - In JavaScript filesystem bridge (`js_fs_existsSync`, `js_fs_readFileSync`, `js_fs_writeFileSync`, `js_fs_readdirSync` at lines 2151-2260), paths are opened directly without checking `is_safe_path`.
   - Solution: Enforce `is_safe_path(ws_root, path)` across `op_find`, `op_grep`, and all `js_fs_*` operations. Reject any path escaping `ws_root`.

3. **Task47204 (Memory Bounds & Safe Allocations)**:
   - `sb_grow` at line 49 ignores `realloc` failure and caller copies into potentially invalid buffer.
   - `asl eval` argument array at line 4835 has fixed 16 elements: `ev_args[16]`, loops up to `i < 15`, but sets `ev_args[argc - 1] = NULL`, which overflows if `argc >= 17`.
   - Solution: Bound all index writes (`ev_args` dynamically allocated or strictly clamped), propagate `sb_grow` success/failure.

## Ordered Implementation DAG
1. **Task47201**:
   - Fixture: `tests/acceptance/d81/Task47201.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47201`
   - Changes: Implement `run_git_commit_safe` using `fork()`/`execvp()` or pipe in `asl.c` without calling `system(cmd)` with interpolated user message.
2. **Task47202**:
   - Fixture: `tests/acceptance/d81/Task47202.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47202`
   - Changes: Gate `op_find`, `op_grep`, and `js_fs_*` through `is_safe_path`.
3. **Task47204**:
   - Fixture: `tests/acceptance/d81/Task47204.asl`
   - Gate: `sh tests/acceptance/d81/SuperviseGate.sh Task47204`
   - Changes: Harden buffer allocations and eval argument bounds.
