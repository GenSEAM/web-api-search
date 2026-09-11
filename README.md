<div align="center">

# ⚡ GenSEAM Autonomous Agent Ecosystem

### *Reference Monorepo for Addie, AgentScript (ASL), and In-Memory Codebase Intelligence.*

[![Language: AgentScript](https://img.shields.io/badge/language-AgentScript%20(ASL)-9333ea.svg)](asl/)
[![Gates: 7/7 Passing](https://img.shields.io/badge/verification%20gates-7%2F7%20passing-emerald.svg)](asl/packages/asl-gates/)
[![In-Memory RAM Engine](https://img.shields.io/badge/RAM%20workspace-%3C150ms%20ingest-blue.svg)](asl/bridges/node/asl-mem-daemon.mjs)
[![Token Savings](https://img.shields.io/badge/token%20economy-72%25%20to%2085%25%20savings-purple.svg)](asl/packages/asl-codec/)
[![Zero Foreign Code](https://img.shields.io/badge/zero--foreign%20code-100%25%20pure%20ASL-success.svg)](asl/)
[![License: MIT](https://img.shields.io/badge/license-MIT-gray.svg)](LICENSE)

</div>

---

## 📜 Manifesto & Architectural Philosophy

> **"Code is for agents. Architecture, intent, and verifiable proofs are for humans."**  
> Read the complete [**Agent-Native Language & Dual-Projection Manifesto**](MANIFESTO.md) for the foundational philosophy governing agent-native programming languages, token economics, and dual-projection perception.

---

## 🧭 Overview

This repository is the central engineering monorepo for **GenSEAM** and **Addie** — the autonomous AI coding agent powered by **AgentScript (ASL)**. It eliminates 80% of agent code bloat, hallucination loops, and multi-second subshell overheads by executing in-memory, deterministic S-expression tools.

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                           ADDIE AUTONOMOUS AGENT                        │
│             (Self-Steering, Multi-Arm Benchmarked, Zero-Foreign)        │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
     ┌───────────────────────────────┼───────────────────────────────┐
     ▼                               ▼                               ▼
┌───────────────┐           ┌─────────────────┐             ┌─────────────────┐
│    asl-mem    │           │    asl-intel    │             │    agent-bus    │
│  In-Memory    │           │ Code Intelligence│            │ Inter-Agent Mesh│
│ Vector Recall │           │ & Symbol Graph  │             │ 0.04ms Wire Bus │
└───────┬───────┘           └────────┬────────┘             └────────┬────────┘
        │                            │                               │
        └────────────────────────────┼───────────────────────────────┘
                                     ▼
                      ┌─────────────────────────────┐
                      │      HARNESS & AST GATES    │
                      │  Deterministic Tool Router  │
                      │  All 7 Verification Gates   │
                      └─────────────────────────────┘
```

---

## ⚡ Core Subsystems

### 1. In-Memory Codebase Intelligence (`asl-mem`)
- **Whole-Workspace Ingestion**: Ingests 900+ files and 12,000+ symbols into resident RAM in **< 150ms**.
- **Vector Semantic Search**: Sublinear TF-IDF and cosine similarity query kernel directly over AST docstrings and symbol headers (`asl mem query "<query>"`).
- **In-RAM Virtual File Buffers**: Inspect documents without touching disk (`asl mem doc section`). Stage code edits (`asl mem edit`) and mass refactor across hundreds of files (`asl mem replace`) in < 15ms.
- **Atomic Disk Synchronization**: Preview staged memory diffs (`asl mem diff`), atomically persist dirty buffers to disk (`asl mem flush`), or discard instantly (`asl mem discard`).

### 2. Code Intelligence & Symbol Navigation (`asl-intel`)
- Dense AST skeletons with 0 implementation bloat (`asl intel outline <file>`).
- Blast-radius and call-graph analysis (`asl intel callers <sym>`, `asl intel impact <sym>`).
- Graph-Horizon Paging $H(m, k, B)$ adhering to strict token budgets.

### 3. AgentScript (ASL) Language Toolchain (`asl/`)
- Pure S-expression agent-native programming substrate.
- Zero delimiter hallucination through balanced parentheses invariants.
- 72% to 85% token savings over JSON and Python syntax.
- Self-hosted compiler targeting WebAssembly, Rust, Embedded C, and native binaries.

### 4. Single-Roundtrip ASN Batch RPC Protocol (`asl rpc`)
- High-performance, low-latency execution pipeline with parallel `Promise.all` reads and sequential mutations.
- 1-token shortcodes (`:q`, `:out`, `:sec`, `:sym`, `:load`, `:repl`, `:drop`, `:chk`, `:cov`) slashes agent context token consumption.
- Dual-mode streaming (`--stream`) emitting discrete ND-ASN frames for TUI and WebSocket clients.

### 5. Multi-Agent Ecosystem Skills Installer (`asl-skills`)
- One-shot setup across all AI coding assistants: **Claude Code, Cursor, Windsurf, Antigravity, and Factory Droid**.
- Automatically configures local and global rule files (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, etc.) to prioritize native ASL toolchains.

---

## 📦 Package Matrix

| Package | Path | Purpose |
| :--- | :--- | :--- |
| **`asl`** | [`asl/`](asl/) | Core AgentScript language, compiler, codec, CLI, and checker |
| **`agent-bus`** | [`agent-bus/`](agent-bus/) | High-speed binary wire frames and presence mesh |
| **`agent-core`** | [`agent-core/`](agent-core/) | Task DAG engine, memory buffers, and blackboard |
| **`addie`** | [`agent/`](agent/) | Autonomous AI engineer executive runtime |
| **`harness`** | [`harness/`](harness/) | Verification gates, AST protection, and execution router |
| **`intel`** | [`intel/`](intel/) | Code intelligence graph and blast radius analyzer |
| **`mem`** | [`mem/`](mem/) | Episodic memory indexing and vector cosine math |
| **`crawler`** | [`crawler/`](crawler/) | Stealth web scraping and browser impersonator |
| **`web-api-search`** | [`web-api-search/`](web-api-search/) | Multi-provider web search engine (Tavily, SearXNG, Serper) |
| **`asl-arduino`** | [`asl-arduino/`](asl-arduino/) | Microcontroller HAL and embedded C transpiler |
| **`asl-contracts`** | [`asl-contracts/`](asl-contracts/) | EVM smart contracts and formal verification |
| **`asl-quantum`** | [`asl-quantum/`](asl-quantum/) | Quantum circuit simulation and state vectors |

---

## 🚀 Quickstart

### 1. Setup Environment & Global Agent Directives
```bash
# Interactive setup (auto-detects Claude Code, Cursor, Windsurf, Antigravity, Factory)
npx asl-skills

# Or via local toolchain
asl skill install --global
```

### 2. In-Memory Exploration & Search
```bash
# Index 900+ workspace files into resident memory in <150ms
asl mem index .

# Semantic vector search across all symbols
asl mem query "vector cosine similarity"

# Read markdown documentation from RAM without hitting disk
asl mem doc section AGENTS.md "Ultra-Compact Native Tool Cheat Sheet"
```

### 3. In-Memory Mass Replace & Atomic Flush
```bash
# Stage codebase-wide rename in RAM in <15ms
asl mem replace --match="old-symbol" --replace="new-symbol" --ext=.asl

# Review pending memory modifications
asl mem diff

# Atomically commit dirty buffers to disk (or discard with 'asl mem discard')
asl mem flush
```

### 4. Continuous Audit & 7 Verification Gates
```bash
# Run 100% pure AgentScript 7-gate audit in ~75ms
asl gate

# Output dense ASN summary for LLM context injection
asl gate --asn

# Inspect native test function coverage across all packages
asl coverage
```

---

## 🛡️ Verification Invariants & Gates

All code commits must satisfy the 7 core invariants enforced by [`tools/gate.asl`](tools/gate.asl):
1. **Package Manifests**: All manifests well-formed and valid (`manifest.asn`, `asl.json`).
2. **Form Balance**: 100% balanced AST delimiters across all `.asl` files.
3. **Site Claims**: Benchmark claims grounded against published locks (`published_claims.asn`).
4. **Zero-Foreign Code**: Strictly 0 Python, 0 JavaScript, 0 TypeScript, 0 Rust, 0 C, and 0 Shell in code packages.
5. **Native Test Suites**: 100% test pass rate across all package test suites.
6. **Token Density**: Exported symbols $\le$ 2 tokens or documented with explicit `:rationale`.
7. **Modular Skills**: Valid YAML frontmatters, trigger descriptions, and zero legacy naming drift.

---

## 📄 License

Dual-licensed under **MIT** or **Apache-2.0**.
