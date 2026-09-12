# Phase 446 Plan: Multi-Runtime Relay and Observability

## Status
- **Phase**: Phase446MultiRuntimeRelayAndObservability
- **Priority**: High
- **Status**: completed

## Context & Objectives
Execute Phase 446 under ADR-0081 and monorepo verification contracts:

1. **Task44601**: Reclassify relay surfaces as runtime targets
   - *Rationale*: Relay and browser surfaces were planned for retirement in Task43807 under the misconception that they were dead code. They are active runtime targets and components.
2. **Task44602**: One wire contract across runtimes: ASN frames over stdio, unix socket, http and sse
   - *Rationale*: Runtimes must share one binary and text framing format without ad-hoc transcoding.
3. **Task44603**: Cross-runtime observability: one trace spanning browser, local, server and relay
   - *Rationale*: Debugging multi-runtime swarms requires unified causal ordering and explicit gap reporting overriding local clock skew.
4. **Task44604**: Parallel development across runtimes: partitioned ownership and conflict resolution at relay
   - *Rationale*: Relay acts as the synchronization arbiter enforcing author leases and rejecting stale writes.
5. **Task44605**: In-browser runtime: wasm engine with OPFS-backed workspace and the same boundary policy
   - *Rationale*: Wasm browser engine requires origin-private file system sandboxing sharing identical boundary enforcement as native POSIX runtime.
6. **Task44606**: camelCase across the wire and the ledgers, enforced not asserted
   - *Rationale*: Enforce universal camelCase identifier compaction across telemetry, receipts, wire frames, and mesh traces, covered by D51 emitted output checker.

## Work Breakdown & Ordered DAG

### Step 1: Task44601 — Reclassify relay surfaces as runtime targets
- **Fixture**: `tests/acceptance/d81/Task44601.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44601`
- **Owned Files**: `.asl/mem/tasks/Phase438LanguageOptimizationAndPortableCore.asn`, `.asl/mem/components.asn`
- **Implementation**: Verified that `agent-bus`, `browser-plugin`, `asl-bridge`, `asl-gateway`, and `vdom` are classified as active runtime components.

### Step 2: Task44602 — One wire contract across runtimes
- **Fixture**: `tests/acceptance/d81/Task44602.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44602`
- **Owned Files**: `asl/grammar/wire.asn`, `agent-bus/src/wire.asl`, `agent-bus/src/transport.asl`, `asl/tools/asl.c`
- **Implementation**: Implemented `CanonicalWireFrame` with camelCase keys across stdio, unix socket, http, and sse with ingress validation.

### Step 3: Task44603 — Cross-runtime observability
- **Fixture**: `tests/acceptance/d81/Task44603.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44603`
- **Owned Files**: `agent-bus/src/mesh.asl`, `agent-bus/src/presence.asl`, `asl/tools/asl.c`, `.asl/mem/telemetry/mesh-trace.asn`
- **Implementation**: Implemented causal trace frames, sequence gap detection, cross-runtime trace merging, and `asl reflect` mesh ingestion.

### Step 4: Task44604 — Partitioned ownership and conflict resolution at relay
- **Fixture**: `tests/acceptance/d81/Task44604.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44604`
- **Owned Files**: `agent-bus/src/cluster.asl`, `agent-bus/src/gateway.asl`, `asl/tools/asl.c`
- **Implementation**: Implemented authoritative `RelayLeaseRegistry`, path claim/release, and closed-fail rejection of stale writes (`ERR_STALE_LEASE`).

### Step 5: Task44605 — In-browser runtime with OPFS-backed workspace
- **Fixture**: `tests/acceptance/d81/Task44605.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44605`
- **Owned Files**: `browser-plugin/src`, `agent-bus/src/browser-bridge.asl`, `asl/tools/asl.c`
- **Implementation**: Implemented OPFS path normalization, boundary violation defense, capability registry with explicit fallbacks, and wasm step execution.

### Step 6: Task44606 — camelCase across the wire and the ledgers, enforced not asserted
- **Fixture**: `tests/acceptance/d81/Task44606.asl`
- **Gate**: `sh tests/acceptance/d81/SuperviseGate.sh Task44606`
- **Owned Files**: `agent-bus/src`, `harness/src`, `asl/tools/asl.c`, `.asl/mem/telemetry`
- **Implementation**: Authored canonical migration dictionary `.asl/mem/telemetry/key-mapping.asn`, implemented bidirectional translation in `harness/src/key_mapping.asl`, migrated machine emitters to camelCase in `asl.c`, `mesh.asl`, `wire.asl`, and `trace_recorder.asl`, and wired emitted output verification into D51 gate 6.
