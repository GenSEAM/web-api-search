<div align="center">

# ⚡ GenSEAM

### *Autonomous AI Agent Architectures, In-Memory Intelligence & The AgentScript Language.*

[Website](https://aslang.dev) · [Documentation](https://aslang.dev/docs) · [Playground](https://aslang.dev/playground) · [LLM Spec](https://aslang.dev/llms.txt)

[![Website](https://img.shields.io/badge/Website-aslang.dev-6366f1?style=for-the-badge&logo=globe)](https://aslang.dev)
[![Blog](https://img.shields.io/badge/Blog-Engineering_Essays-10b981?style=for-the-badge&logo=rss)](https://aslang.dev/blog)
[![Token Reduction](https://img.shields.io/badge/Token_Tax--80%25-f59e0b?style=for-the-badge)](https://aslang.dev/blog/the-token-tax-and-interface-compression)
[![Wasm Sandbox](https://img.shields.io/badge/Wasm_Execution-0.038ms-3b82f6?style=for-the-badge)](https://aslang.dev/blog/from-vibe-code-to-wasm-in-0-04ms)

</div>

---

## 🌟 The GenSEAM Vision

**GenSEAM** builds next-generation infrastructure for autonomous AI software engineers and multi-agent swarms. By replacing bloated JSON protocols, fragile whitespace languages, and multi-second container restarts with **pure S-expressions**, **in-memory AST buffers**, and **deterministic capability-jailed runtimes**, we achieve **72%–85% token economy** and sub-millisecond execution.

---

## 🏛️ Ecosystem Repositories

| Repository | Status | Focus & Description | Language |
| :--- | :--- | :--- | :--- |
| [**`monorepo`**](https://github.com/GenSEAM/asl) | **Core** | Central engineering reference monorepo for ASL, agent swarms, and in-memory codebase intelligence | ASL / Polyglot |
| [**`asl`**](https://github.com/GenSEAM/asl) | **Core** | **AgentScript (ASL)** compiler, parser, checker, code generator (`wasm32-wasip1`, Rust, TS, Python, Go, SQL) | Pure ASL |
| [**`harness`**](https://github.com/GenSEAM/harness) | **Runtime** | Universal multi-modal agent harness with Code execution, Headless Browser, and Computer-Use adapters | Pure ASL |
| [**`agent`**](https://github.com/GenSEAM/agent) | **Agent** | Sovereign autonomous coding agent, adaptive swarm orchestrator, and terminal TUI (`agent`, alias: `gsa`) | Pure ASL |
| [**`agent-core`**](https://github.com/GenSEAM/agent-core) | **Agent** | Composable onion middleware, capability negotiator, algebraic FSM, and tool calling runtime | Pure ASL |
| [**`agent-bus`**](https://github.com/GenSEAM/agent-bus) | **Mesh** | High-performance inter-agent swarm bus with Unix domain sockets, shared memory ring buffers, and SSE | Pure ASL |
| [**`mem`**](https://github.com/GenSEAM/mem) | **Data** | Zero-server in-memory vector database, SimHash, CAS subtree cache, and Git-native memory matrix | Pure ASL |
| [**`intel`**](https://github.com/GenSEAM/intel) | **Intel** | AgentScript dense code intelligence, symbol search, polyglot AST outlines, and call graphs | Pure ASL |
| [**`web-api-search`**](https://github.com/GenSEAM/web-api-search) | **Search** | Decentralized SearXNG metasearch aggregator, Tavily/Brave API client, and proxy pool rotator | Pure ASL |
| [**`vdom`**](https://github.com/GenSEAM/vdom) | **UI** | Declarative S-Expression Virtual DOM renderer bridging AI-generated components into React 19, Vue 3, Svelte 5 | Pure ASL |
| [**`voice`**](https://github.com/GenSEAM/voice) | **Audio** | Real-time voice stream assistant, 16kHz PCM audio bridge, and sub-millisecond voice router | Pure ASL |
| [**`browser-plugin`**](https://github.com/GenSEAM/browser-plugin) | **Extension** | Manifest V3 companion with embedded in-browser WASI runner, visual context extractor, DOM AST compressor | ASL / Wasm |
| [**`pack`**](https://github.com/GenSEAM/pack) | **Distribution** | Pure AgentScript packaging, binary compilation, and Wasm runtime distribution toolchain | Pure ASL |
| [**`crawler`**](https://github.com/GenSEAM/crawler) | **Automation** | Pure ASL Parallel Stealth Web Crawler and Automation Engine | Pure ASL |
| [**`asl-arduino`**](https://github.com/GenSEAM/asl-arduino) | **Embedded** | Microcontroller hardware abstraction layer, GPIO primitives, and embedded AgentScript runtime | Pure ASL |
| [**`asl-contracts`**](https://github.com/GenSEAM/asl-contracts) | **Formal** | Formal verification, state transition invariants, and smart contract execution in AgentScript | Pure ASL |
| [**`asl-quantum`**](https://github.com/GenSEAM/asl-quantum) | **Simulation** | Quantum circuit simulation, quantum gates, and state vector manipulation in AgentScript | Pure ASL |
| [**`editorial-matrix`**](https://github.com/GenSEAM/editorial-matrix) | **Strategy** | Private content strategy, SEO guidelines, syndication APIs, and editorial roadmap | Private |

---

## 📊 Empirical Benchmarks

### 1. Token Overhead (Function & Data Invocation)
*Measured using OpenAI `cl100k_base` tokenizer on identical functional payloads:*

| Format | Raw Size | Tokens | Overhead vs Baseline |
| :--- | :--- | :--- | :--- |
| **Standard JSON-RPC** | 248 bytes | 51 tokens | +183% (Bloat) |
| **YAML Payload** | 162 bytes | 34 tokens | +89% |
| **Agent Script Notation (ASN)** | 84 bytes | 27 tokens | +50% |
| **Agent Protocol Frame (`agp`)** | **52 bytes** | **18 tokens** | **Baseline (65% Savings)** |

### 2. Execution Latency
*Cold-start and execution of verified agent tasks:*

| Runtime / Isolation Layer | Cold Start | Execution | Total Roundtrip |
| :--- | :--- | :--- | :--- |
| **Docker Container** | ~1,200 ms | 12 ms | 1,212 ms |
| **Firecracker MicroVM** | ~350 ms | 8 ms | 358 ms |
| **Node.js Sandbox (v8::Context)** | ~85 ms | 4 ms | 89 ms |
| **GenSEAM Wasm (`wasm32-wasip1`)** | **< 0.01 ms** | **0.038 ms** | **0.048 ms (Instant)** |

---

## 🚀 Quick Setup

Install native ASL skills and instructions across all your AI coding assistants (**Claude Code, Cursor, Windsurf, Antigravity, Factory Droid**):

```bash
npx asl-skills
```

Or install the standalone native CLI toolchain:

```bash
curl -fsSL https://aslang.dev/install.sh | bash
```

---

<div align="center">
  <sub>Maintained with architectural rigor by the GenSEAM Core Team. Dual-licensed under MIT and Apache-2.0.</sub>
</div>
