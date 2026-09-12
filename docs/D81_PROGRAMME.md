# D81 Programme

Thirty-one phases, 182 tasks, registered in ADR-0081, `.asl/mem/intent.asn`, `.asl/mem/decisions/decisions.asn` and `.asl/mem/roadmap.asn`. Every phase carries a `:baseline` stating what was measured and when; no phase was written from an impression.

## Phases

| phase | wave | tasks | pri | what it settles |
|---|---|---|---|---|
| Phase436 | Wave 88 | 7 | 1 | Language Semantics Ground Truth: module import resolution, loud failure on unknown symbols, honest RPC status, |
| Phase437 | Wave 89 | 7 | 2 | Client Launch and Codex Efficiency: complete MCP removal, per-client minimal launch payloads for Claude Code a |
| Phase438 | Wave 90 | 9 | 3 | Language Optimization and Portable Core: C evaluator without JavaScriptCore, wasm32-wasi build, content search |
| Phase439 | Wave 91 | 4 | 4 | Final Efficiency Review: mutation score as the verification metric, cache-stability measurement of the launch  |
| Phase440 | Wave 92 | 5 | 5 | Full ASL self-hosting: owned native compiler/evaluator autonomous rebuild closure, WASM backend and all CLI/RP |
| Phase441 | - | 10 | 6 | Attention Prosthesis: external working memory and step-scoped rule delivery so small and long-context models p |
| Phase442 | Wave 94 | 10 | 6 | Agent Reliability and Multidimensional Observability Utilities: instruments that close the blind spots measure |
| Phase443 | Wave 95 | 7 | 7 | Test Coverage Campaign: raise coverage where a missing case kind is a defect rather than a gap, using the twel |
| Phase444 | Wave 96 | 6 | 8 | Test Telemetry and Coverage Guarantees: collect what the runtime already knows, turn it into three decidable g |
| Phase445 | Wave 97 | 4 | 9 | Static Confirmation Coverage: a working checker for every constraint that admits one, an explicit runtime-only |
| Phase446 | Wave 98 | 6 | 10 | Multi-Runtime Relay and Observability: one wire contract and one causal trace across in-browser, local, server |
| Phase447 | Wave 99 | 4 | 11 | Canonical Lexicon Cross-Client: one spoken-to-canonical source rendered to every client and both translators,  |
| Phase448 | Wave 100 | 6 | 11 | Instrumented Editorial Web Design: select a coherent ASL visual frame, retain readable width for prose, widen  |
| Phase454 | Wave 101 | 6 | 2 | Engine Binding Ground Truth: module resolution driven by declared manifests instead of a path guess ladder, an |
| Phase455 | Wave 102 | 6 | 3 | Verification Layer Honesty: no command reports a result it did not compute, no flag is inert, no invocation su |
| Phase456 | Wave 103 | 4 | 4 | Duplication, Dead Code and Unwired Eradication: remove the 371 redundant copies that the broken binder forced  |
| Phase457 | Wave 104 | 5 | 5 | Static Analysis Toolchain: the cross cutting sweep becomes a first class command that answers what binds, what |
| Phase458 | Wave 105 | 4 | 6 | Ledger Truth and Write Discipline: a certification cannot outrun its evidence, a commit message cannot claim a |
| Phase459 | Wave 106 | 6 | 1 | Language Compaction and Predictability: one name per concept, the measured 3.38 percent of syntax compaction a |
| Phase460 | Wave 107 | 6 | 1 | Scheme Alignment and Racket Concepts: stop being gratuitously different from the Lisp the model already knows, |
| Phase461 | Wave 108 | 6 | 2 | Core and Interchangeable Extensions: a core that knows no extension by name, four mechanisms that let everythi |
| Phase462 | Wave 109 | 6 | 3 | LLM-First Lexicon: measured token count decides every name, the human is removed from the source and served by |
| Phase463 | Wave 110 | 5 | 4 | ASL-First Beyond Racket: lead on the axes Racket never optimised, being emission reliability, nesting depth, b |
| Phase464 | Wave 111 | 6 | 1 | Instruction Truth and Example Coverage: every command an instruction names must exist, every operation must an |
| Phase465 | Wave 112 | 6 | 2 | Agent Working Memory Surface: give the memory engine that already exists a command surface, a file worklist, a |
| Phase466 | Wave 113 | 5 | 2 | Paradigm by Force and Tier: separate what binds from what orients from what merely usually works, give each it |
| Phase467 | Wave 114 | 6 | 3 | Tool Reliability and Scenario Coverage: an inventory an agent can see, a scenario matrix per tool, a stated en |
| Phase468 | Wave 115 | 5 | 3 | Intent, Goal and Practice Lifecycle: three kinds distinguished by what closes them, a stated threshold for wri |
| Phase469 | Wave 116 | 7 | 3 | Swarm Edit Visibility and Collision Avoidance: peers already see each other, so add what each is holding, a su |
| Phase470 | Wave 117 | 5 | 1 | Restore Gate Scope and Reach Execution: make a green gate mean a green corpus again, close the seven remaining |
| Phase471 | Wave 118 | 3 | 2 | Closing the Unplanned: the three findings and requests from this programme that no task covers, being the decl |

## Records this programme produced

| record | what it holds |
|---|---|
| `.asl/mem/principles.asn` | 31 standing principles, each `:normative` or `:empirical`; an empirical one carries method, scope and date |
| `.asl/mem/reviews/D81StaticSweepAudit20260911.asn` | the cross-cutting static sweep: binding root cause, duplication, dead code, fabricated gate output |
| `.asl/mem/reviews/D81CompactionFrontier20260912.asn` | where compaction stops paying: devowelling, single letters, the DF family |
| `.asl/mem/reviews/D81PersistentMemoryResearch20260912.asn` | the memory engine that exists, passes 237 assertions and has no caller |
| `.asl/mem/reviews/D81ExecutionAudit20260912.asn` | what was implemented, what regressed, the shortest path to execution |
| `docs/EXAMPLE_DOCTRINE.md` | how to compose acceptance fixtures, capability probes and emission cases, with the scout walkthrough |
| `docs/TEST_CASE_CATALOG.md` | the twelve case kinds |

## The measurements this programme rests on

```
corpus            888 files · 1 512 691 tokens cl100k · 3.72 chars/token
                  strings 41.8% · identifiers 20.4% · delimiters 12.7%
suites            314 · failing 46 (was 136, then 142)
unresolved        7 module names (was 36)
fixtures          9 of ~182 tasks
memory store      469 582 tokens · 1 record ever superseded of 164
paradigm          5 913 tokens loaded per agent · essential core 617
binding distance  median 53 lines · p90 232 · max 1172 · 11.7% beyond 200
symbol surface    17 112 distinct head symbols
language changes  every naming change combined: 3.38%
refuted           devowelling +106% · indentation rendering +7.7% · abbreviation 0%
events            push 97 200 tokens vs pull 740 for one session: 131x
```

## Critical path

1. **Task47001** — gate 5 audits the corpus again. No dependencies. Until this lands, every acceptance below it is certified against five suites.
2. **Task47003** — the installed binary reports its source digest. No dependencies. Today the binary on PATH is not the one the repository builds.
3. **Task45901 / Task46001** — one name per concept, then the Scheme spellings, before Task45403 writes forty new primitives under the old fragmentation.
4. **Task47002** — the seven remaining module names.
5. **Task47004** — fixtures for the ready set; a task without one exits 3 at its own gate.

## Open, and not ours to close

- `~/.claude/rules/asl.md` and `~/.claude/CLAUDE.md` sit outside the repository and name eleven commands that do not exist. Task46401 covers the repository surfaces only.
- C or Rust for the portable core; the disposition of `voice`, `agent`, `browser-plugin` and `crawler`; whether C1 and C4 remain unconditional invariants.
- Three phrases from a dictated message were not recoverable and are not planned.
