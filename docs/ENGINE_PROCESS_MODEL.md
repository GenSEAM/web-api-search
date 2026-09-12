# AgentScript Engine Residency and Process Lifetime Model

This document defines the host engine architecture, runtime residency, session model, workspace root determination, and process lifetime guarantees for AgentScript (ASL) under ADR-0081.

## 1. Engine Residency and Bootstrap Architecture

The AgentScript execution core operates via a native C host bootstrap adapter (`asl/tools/asl.c`). On macOS and POSIX systems, this C engine embeds the Apple JavaScriptCore (JSC) framework to provide a resident, high-performance runtime for evaluating pure ASL AST forms, bytecode translation, and JavaScript-compatible projections without external node or python dependencies.

The engine can run in two primary residency modes:
1. **Direct CLI Invocations**: Immediate process execution for discrete commands (`asl check`, `asl lint`, `asl grep`, `asl callers`, `asl impact`, `asl test`).
2. **Batch RPC Processor**: Evaluates S-expression batch payloads (`asl rpc '(:batch ...)'`) in a single roundtrip, avoiding multi-process spawn overhead.

## 2. Session Model (`:session-model`)

The runtime enforces an explicit session model:

- **Ephemeral Sessions**: By default, each CLI invocation and `asl rpc` call operates in an ephemeral session. Memory state is instantiated for the batch, steps are executed, results are rendered as structured ASN receipts, and resident buffers are released at process exit.
- **Persistent Daemon Sessions (`--daemon`, `--serve`)**: For continuous agent interactions, the engine can be launched in background residency via `asl daemon start` or `asl --serve <socket> <ws_root> <pid>`. Persistent sessions listen on a dedicated UNIX domain socket (`/tmp/asl_mem_<id>.sock`), keeping AST caches, symbol cross-references, and working memory notes resident in RAM across turns.
- **Session Continuity and Task Leases**: Active work in flight is tracked via `.asl/mem/tasks/InFlight.asn`. Agents claim tasks with session identifiers (`asl task claim <id> :session <session_id>`) and can recover orphaned sessions (`asl task recover <session_id>`) following agent disconnection.

## 3. Workspace Root Determination (`:root-determination`)

Tool execution and path normalization are strictly anchored to the workspace root:

- **Resolution Mechanism (`discovered_ws`)**: When the engine initializes, it resolves the canonical workspace path stored in `discovered_ws`:
  1. If `ASL_WORKSPACE_ROOT` environment variable is set and non-empty, its absolute path is used.
  2. Otherwise, the engine performs upward filesystem traversal starting from the current working directory (`cwd`), searching for `.asl.config.asn`.
  3. The directory containing `.asl.config.asn` becomes `discovered_ws`.
- **Path Canonicalization and Boundary Security**: All relative paths passed to tools (`:read`, `:out`, `:sec`, `:edit`, `:write`, `:grep`, `:find`) are resolved relative to `discovered_ws`. Paths attempting traversal outside `discovered_ws` (e.g., via `..` or absolute foreign paths) are intercepted by `is_safe_path` and refused with `:ERR_BOUNDARY_VIOLATION`.

## 4. Process Lifetime and Watchdog Model (`:process-lifetime`)

Child process executions initiated by the engine or `asl-sh` packages obey strict lifetime contracts:

- **Process Spawning Mechanics**: Processes are spawned with non-interactive firewalls (`STDIN=/dev/null`, `PAGER=cat`, `CI=true`). Interactive prompts are blocked from hanging the supervisor.
- **Watchdog Timeout Ceiling**: Every process step executes under a bounded watchdog ceiling (default 15 minutes, with a 10-second sliding idle watchdog). Commands exceeding deadline limits receive progressive escalation (`SIGINT`, followed by `SIGKILL` after grace period).
- **Bounded Output Truncation**: Processes producing unbounded streams of stdout or stderr are captured using a two-tier spooling architecture (`asl-sh/spool`):
  1. A 200-line RAM ring buffer (`RingBuffer`) preserving the trailing lines in FIFO order for tail inspection.
  2. A 10MB circular ephemeral disk spool (`DiskSpool`) enforcing hard storage limits.
  3. Circular byte truncation via `spool-truncate` with explicit `:is-truncated true` receipt reporting when output exceeds maximum capacity.
- **Session Survival**: Processes outliving ephemeral sessions are detached or terminated based on the registered supervisor policy, preventing orphaned daemon accumulation.
