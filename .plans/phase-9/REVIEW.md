# Plan Review: Phase 9 — Instruction Surface Truth, Doctor Tooling & Capabilities Lock

**Reviewer**: steps-plan-reviewer (clean context)  
**Date**: 2026-09-12  
**Plan Under Review**: [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md)  
**Verdict**: **APPROVE-WITH-AMENDMENTS**

---

## Verdict Summary

The plan for Phase 9 is architecturally sound and decomposes cleanly into 4 sequential items. All four items have gate commands that legitimately fail on baseline before implementation, and master verification pre-checks pass cleanly on the unmodified repository. However, two gate/ownership vulnerabilities and one citation error must be amended before implementation starts.

---

## Baseline Gate Verification

| Item | Title | Baseline Failure Verified? | Verification Command Output |
| :--- | :--- | :---: | :--- |
| **Item 1** | `Task46403`: Capability Doctor (`asl doctor`) & `capabilities.lock` | **YES** | Exits with code 1: `Error: asl doctor failed: Error: unrecognized subcommand 'doctor'` |
| **Item 2** | `Task46401`: Instruction Surface Truth (`AGENTS.md`, `README.md`) | **YES** | Exits with code 1: `Error: absent command cited as active in AGENTS.md` |
| **Item 3** | `Task47303`: Engine Binary Parity & Distribution Reconciliation | **YES** | Exits with code 1: `Error: bin/asl doctor failed` |
| **Item 4** | Master Verification (`./bin/asl gate` & `./bin/asl audit consistency`) | **YES** | Exits with code 1: `Item 1 incomplete: asl doctor failed or missing receipt` (baseline master checks `./bin/asl gate && ./bin/asl audit consistency` pass cleanly) |

---

## Blockers & Required Amendments

### 1. Gate 2 & Gate 4 Precheck Omission: Conformant-but-Wrong Implementation Leakage
- **Citation**: [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L134-L144), [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L258-L262), [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L15)
- **Evidence**:
  1. Gate 2 (`PLAN.md:137`) loops over `["AGENTS.md", "README.md"]`, omitting `CLAUDE.md`. Although `CLAUDE.md` is currently a symlink to `AGENTS.md`, `CLAUDE.md` is declared in `owns` (`PLAN.md:152`) and `Path` (`PLAN.md:98`). If an implementer creates a regular file or edits decouple the symlink, `CLAUDE.md` remains unchecked.
  2. Gate 2 only checks `if "asl doc " in c or "asl task spawn" in c:`. However, Acceptance Criteria 2 (`PLAN.md:15`) and Item 2 Why (`PLAN.md:107-109`) explicitly target 5 non-existent CLI subcommands: `asl doc`, `asl task spawn`, `asl task claim`, `asl task recover`, `asl task settle`.
  3. Under the current gate, an implementer who removes `asl task spawn` but leaves `asl task claim` (line 285), `asl task recover` (lines 281, 285), and `asl task settle` (line 288) will still pass Gate 2 and Gate 4 precheck cleanly.
- **Required Amendment**:
  Update Gate 2 and Gate 4 precheck to assert:
  ```python
  for f in ["AGENTS.md", "CLAUDE.md", "README.md"]:
      c = open(f).read()
      for bad in ["asl doc ", "asl task spawn", "asl task claim", "asl task recover", "asl task settle"]:
          if bad in c:
              print(f"Error: absent command {bad!r} cited as active in {f}")
              sys.exit(1)
  ```

### 2. File Ownership Boundary Conflict on `bin/asl`
- **Citation**: [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L92), [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L63), [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L210)
- **Evidence**:
  - Item 1 Action DAG step 5 states: `Recompile bin/asl and run Item 1 gate.` Item 1 Gate runs `./bin/asl doctor`.
  - However, Item 1 `owns` is declared as `["asl/tools/asl.c", "asl/grammar/capabilities.lock"]`, which omits `bin/asl`. Recompiling `bin/asl` modifies a target outside of Item 1's declared `:owns` boundary.
  - Item 3 then declares `owns: ["bin/asl", "asl/bin/asl", "asl/asl"]`.
- **Required Amendment**:
  Explicitly include `"bin/asl"` in Item 1's `:owns` (`["asl/tools/asl.c", "bin/asl", "asl/grammar/capabilities.lock"]`), and refine Item 3's `:owns` to the distribution replicas `["asl/bin/asl", "asl/asl"]` (with Item 3 reconciling `bin/asl` into the replica distributions).

### 3. Inaccurate Line Citation in Item 1
- **Citation**: [.plans/phase-9/PLAN.md](file:///Users/purplelephant/projects/asex/.plans/phase-9/PLAN.md#L37)
- **Evidence**:
  `PLAN.md:37` states: `The capabilities rule in asl/grammar/rules.asn:67-70 states:`.
  However, `asl/grammar/rules.asn` has only 60 total lines. The capabilities rule is located at `asl/grammar/rules.asn:56-59`.
- **Required Amendment**:
  Correct citation to `asl/grammar/rules.asn:56-59`.

---

## Non-blocking & Proactive Suggestions

1. **Gate 1 Non-Vacuous Content Check**:
   In Item 1 gate (`PLAN.md:80`), assert that `capabilities.lock` contains `:status` or recognized capability statuses (`:works`, `:partial`, `:absent`, `:lies`) rather than only `:measured`, preventing a stub receipt from passing.
2. **Deterministic `asl doctor` Benchmark**:
   Ensure `asl doctor` execution takes < 200ms by utilizing in-memory functional probing or lightweight dispatch instead of spawning full sub-processes for all 36 capabilities.
3. **Distribution Parity Check Hook**:
   Consider wiring a distribution parity check into `./bin/asl gate` or pre-commit hooks to ensure `bin/asl`, `asl/bin/asl`, and `asl/asl` never diverge in future waves.

---

## Unverified

None. All cited files, line numbers, and baseline gate commands were executed and inspected in a clean context.

