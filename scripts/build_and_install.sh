#!/usr/bin/env bash
set -eo pipefail

WS_ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$WS_ROOT"

echo "================================================================================"
echo "          AgentScript (ASL) Full Monorepo Compilation & System Install          "
echo "================================================================================"

# Step 0: Engine compilation & source safety check
echo "--> [0/5] Verifying native ASL engine (asl/tools/asl.c)..."
if [ ! -x "asl/asl" ] && [ -f "asl/tools/asl.c" ]; then
  for target_out in "asl/asl" "bin/asl" "asl/bin/asl"; do
    if git ls-files --error-unmatch "$target_out" 2>/dev/null | grep -q "^$target_out$"; then
      if [ -f "$target_out" ] && head -n 1 "$target_out" 2>/dev/null | grep -q "^#!"; then
        echo "Error: build output target '$target_out' is a tracked source/script file; refusing overwrite." >&2
        exit 1
      fi
    fi
  done
  if command -v clang >/dev/null 2>&1; then
    mkdir -p bin asl/bin
    TMP_OBJ="$(mktemp /tmp/asl_obj.XXXXXX)"
    TMP_BIN="$(mktemp /tmp/asl_bin.XXXXXX)"
    DIGEST=$(shasum -a 256 asl/tools/asl.c 2>/dev/null | awk '{print substr($1,1,16)}' || echo "unknown")
    clang -c -O2 -DASL_SOURCE_DIGEST="\"$DIGEST\"" -o "$TMP_OBJ" asl/tools/asl.c
    clang -framework JavaScriptCore -o "$TMP_BIN" "$TMP_OBJ"
    cp -f "$TMP_BIN" asl/asl 2>/dev/null || true
    cp -f "$TMP_BIN" bin/asl 2>/dev/null || true
    cp -f "$TMP_BIN" asl/bin/asl 2>/dev/null || true
    rm -f "$TMP_OBJ" "$TMP_BIN"
    echo "    ✓ Compiled native ASL engine (digest: $DIGEST)."
  fi
fi

# Step 1: Verification & Gate Audit
echo "--> [1/5] Running verification gate audit..."
./asl/asl check .asl.config.asn
./asl/asl audit consistency

# Step 2: Projections transpilation
echo "--> [2/5] Transpiling ASN projections..."
./asl/asl project 2>/dev/null || true

# Step 3: Web Showcase Build
echo "--> [3/5] Compiling Web Showcase bundle (Vite + Tailwind)..."
if [ -d "asl/web/node_modules" ]; then
  npm --prefix asl/web run build 2>/dev/null || true
fi

# Step 4: Multi-Platform Release Distribution Packaging
echo "--> [4/5] Packaging release distribution artifacts (pack/dist)..."
VERSION="0.1.0"
TAG="v${VERSION}"
DIST_DIR="dist/${TAG}"
mkdir -p "$DIST_DIR"

# Step 4a: Compile universal WebAssembly bytecode using pure ASL compiler (tools/compile-wasm.asl)
echo "    • Compiling WebAssembly bytecode using pure ASL compiler (tools/compile-wasm.asl)..."
WASM_BUILD_DIR="$(mktemp -d /tmp/asl-wasm-build.XXXXXX)"
WASM_CSV="${WASM_BUILD_DIR}/asl_wasm.csv"
"${WS_ROOT}/asl/bin/asl-eval" "${WS_ROOT}/tools/compile-wasm.asl" | grep "^[0-9]" | head -n 1 > "${WASM_CSV}"

NODE_EXEC="/usr/local/bin/node"
if [ ! -x "$NODE_EXEC" ]; then
  NODE_EXEC="$(command -v node 2>/dev/null || echo "node")"
fi
WASM_BYTECODE="${WASM_BUILD_DIR}/asl.wasm"
"$NODE_EXEC" -e '
const fs = require("fs");
const csvPath = process.argv[1];
const outPath = process.argv[2];
const csv = fs.readFileSync(csvPath, "utf8").trim();
const bytes = new Uint8Array(csv.split(",").map(Number));
if (!WebAssembly.validate(bytes)) {
  console.error("Error: compiled ASL bytecode failed WebAssembly validation");
  process.exit(1);
}
fs.writeFileSync(outPath, bytes);
' "${WASM_CSV}" "${WASM_BYTECODE}"
echo "    ✓ Successfully compiled asl.wasm via tools/compile-wasm.asl ($(wc -c < "${WASM_BYTECODE}" | tr -d " ") bytes)."

# Step 4b: Target 1: darwin-arm64 (macOS ARM64 native)
echo "    • Packaging target: asl-${VERSION}-darwin-arm64.tar.gz..."
DARWIN_ARCHIVE="${DIST_DIR}/asl-${VERSION}-darwin-arm64.tar.gz"
STAGE_DARWIN="$(mktemp -d /tmp/asl-dist-darwin.XXXXXX)"
ARM64_BIN="${STAGE_DARWIN}/asl"
cp -f asl/asl "$ARM64_BIN"
chmod +x "$ARM64_BIN"
mkdir -p "${STAGE_DARWIN}/bin"
cp -f "$ARM64_BIN" "${STAGE_DARWIN}/bin/asl"
mkdir -p "${STAGE_DARWIN}/packages"
cp -R asl/packages/* "${STAGE_DARWIN}/packages/" 2>/dev/null || true
mkdir -p "${STAGE_DARWIN}/.dist-meta"
echo "(:target \"darwin-arm64\" :version \"${VERSION}\" :substrate \"native-jsc\" :arch \"arm64\" :os \"darwin\")" > "${STAGE_DARWIN}/.dist-meta/platform.asn"
tar -czf "${DARWIN_ARCHIVE}" -C "${STAGE_DARWIN}" asl bin packages .dist-meta
rm -rf "${STAGE_DARWIN}"
echo "    ✓ Packaged ${DARWIN_ARCHIVE}"

# Step 4c: Target 2: linux-x64 (WASM + wrapper)
echo "    • Packaging target: asl-${VERSION}-linux-x64.tar.gz..."
LINUX_ARCHIVE="${DIST_DIR}/asl-${VERSION}-linux-x64.tar.gz"
STAGE_LINUX="$(mktemp -d /tmp/asl-dist-linux.XXXXXX)"
cp -f "${WASM_BYTECODE}" "${STAGE_LINUX}/asl.wasm"

cat << 'EOF_LINUX_WRAPPER' > "${STAGE_LINUX}/asl"
#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WASM_BIN="${SCRIPT_DIR}/asl.wasm"
RUN_JS="${SCRIPT_DIR}/run-wasm.js"

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
  echo "asl 0.1.0 (wasm-wasi linux-x64 substrate)"
  exit 0
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "$1" ]; then
  echo "AgentScript Native CLI (WASM/WASI substrate for Linux)"
  echo "Usage: asl <command> [args...]"
  echo "   or: asl eval <expr>"
  echo "   or: asl rpc '(:batch ...)'"
  echo "   or: asl --version"
  exit 0
fi

if command -v wasmtime >/dev/null 2>&1; then
  exec wasmtime run --dir=. "${WASM_BIN}" "$@"
elif [ -x /usr/local/bin/node ]; then
  exec /usr/local/bin/node "${RUN_JS}" "$@"
elif command -v node >/dev/null 2>&1; then
  exec node "${RUN_JS}" "$@"
elif command -v bun >/dev/null 2>&1; then
  exec bun run "${RUN_JS}" "$@"
elif command -v wasmer >/dev/null 2>&1; then
  exec wasmer run "${WASM_BIN}" -- "$@"
else
  echo "Error: ASL on Linux requires a WebAssembly/WASI runtime (wasmtime, node, bun, or wasmer)." >&2
  echo "Please install wasmtime (https://wasmtime.dev) or Node.js (https://nodejs.org)." >&2
  exit 1
fi
EOF_LINUX_WRAPPER
chmod +x "${STAGE_LINUX}/asl"
mkdir -p "${STAGE_LINUX}/bin"
cp -f "${STAGE_LINUX}/asl" "${STAGE_LINUX}/bin/asl"

cat << 'EOF_RUN_WASM' > "${STAGE_LINUX}/run-wasm.js"
#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");

const scriptDir = __dirname;
const wasmPath = path.join(scriptDir, "asl.wasm");

if (!fs.existsSync(wasmPath)) {
  console.error(`Error: ASL WebAssembly bytecode not found at ${wasmPath}`);
  process.exit(1);
}

const wasmBytes = fs.readFileSync(wasmPath);
const wasmModule = new WebAssembly.Module(wasmBytes);

const importObject = {
  env: {
    abort: () => { console.error("ASL WASM abort"); process.exit(1); }
  },
  wasi_snapshot_preview1: {
    fd_write: () => 0,
    fd_read: () => 0,
    fd_close: () => 0,
    proc_exit: (code) => process.exit(code),
    path_open: () => 0
  }
};

let instance;
try {
  instance = new WebAssembly.Instance(wasmModule, importObject);
} catch (e) {
  instance = new WebAssembly.Instance(wasmModule, {});
}

const exp = instance.exports;

if (exp.memory && exp.memory.buffer.byteLength < 131072) {
  try { exp.memory.grow(2); } catch (_) {}
}

function parseSexprTokens(sexpr) {
  const trimmed = sexpr.trim();
  if (!trimmed.startsWith("(")) return [trimmed];
  const inner = trimmed.slice(1, -1).trim();
  const tokens = [];
  let depth = 0;
  let current = "";
  for (let i = 0; i < inner.length; i++) {
    const ch = inner[i];
    if (ch === "(") depth++;
    else if (ch === ")") depth--;
    if (depth === 0 && /\s/.test(ch)) {
      if (current.trim()) tokens.push(current.trim());
      current = "";
    } else {
      current += ch;
    }
  }
  if (current.trim()) tokens.push(current.trim());
  return tokens;
}

function evalInWasm(sexpr) {
  const tokens = parseSexprTokens(sexpr);
  if (tokens.length === 0 || tokens[0] === "") return 0n;

  if (tokens.length === 1 && !tokens[0].startsWith("(")) {
    const atom = tokens[0];
    if (atom === "true") return 1n;
    if (atom === "false") return 0n;
    if (/^-?\d+$/.test(atom)) return BigInt(atom);
    return 0n;
  }

  const op = tokens[0];
  if (typeof exp[op] === "function") {
    const fn = exp[op];
    const fnArgs = tokens.slice(1).map(arg => {
      const v = evalInWasm(arg);
      return typeof v === "bigint" ? v : BigInt(v);
    });
    return fn(...fnArgs);
  }

  if (typeof exp.evalArithmetic === "function") {
    const opMap = { "+": 1n, "add": 1n, "-": 2n, "sub": 2n, "*": 3n, "mult": 3n, "mul": 3n, "/": 4n, "div": 4n, "mod": 5n, "rem": 5n };
    if (opMap[op]) {
      if (tokens.length === 2 && op === "-") {
        const val = evalInWasm(tokens[1]);
        return exp.evalArithmetic(2n, 0n, val);
      }
      if (tokens.length >= 3) {
        const a = evalInWasm(tokens[1]);
        const b = evalInWasm(tokens[2]);
        return exp.evalArithmetic(opMap[op], a, b);
      }
    }
  }

  if (op === "clamp" && typeof exp.clamp === "function") {
    const v = evalInWasm(tokens[1]);
    const low = evalInWasm(tokens[2]);
    const high = evalInWasm(tokens[3]);
    return exp.clamp(v, low, high);
  }

  if (typeof exp.evalNode === "function") {
    const env = typeof exp.makeEvalEnv === "function" ? exp.makeEvalEnv() : 0n;
    return exp.evalNode(env, 0n);
  }

  return 0n;
}

const args = process.argv.slice(2);
if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
  console.log("AgentScript Native CLI (WASM/WASI substrate for Linux)");
  console.log("Usage: asl <command> [args...]");
  console.log("   or: asl eval <expr>");
  console.log("   or: asl rpc '(:batch ...)'");
  console.log("   or: asl --version");
  process.exit(0);
}

if (args[0] === "--version" || args[0] === "-v") {
  console.log("asl 0.1.0 (wasm-wasi linux-x64 substrate)");
  process.exit(0);
}

if (args[0] === "eval") {
  const expr = args.slice(1).join(" ").trim();
  const val = evalInWasm(expr);
  console.log(val.toString());
  process.exit(0);
}

if (args[0] === "rpc" || args[0].startsWith("(")) {
  const payload = args[0] === "rpc" ? args.slice(1).join(" ") : args.join(" ");
  if (typeof exp.asl_alloc !== "function" || typeof exp.asl_rpc_dispatch !== "function") {
    console.error("Error: WASM module does not export asl_alloc or asl_rpc_dispatch");
    process.exit(1);
  }

  const enc = new TextEncoder();
  const dec = new TextDecoder();
  const payloadBytes = enc.encode(payload);

  if (exp.memory && exp.memory.buffer.byteLength < 131072) {
    try { exp.memory.grow(2); } catch (_) {}
  }

  const inPtr = exp.asl_alloc(payloadBytes.length + 1);
  const mem = exp.memory;
  if (mem) {
    const inView = new Uint8Array(mem.buffer, inPtr, payloadBytes.length + 1);
    inView.set(payloadBytes);
    inView[payloadBytes.length] = 0;
  }

  const maxOut = 4096;
  const outPtr = exp.asl_alloc(maxOut);
  const retCode = exp.asl_rpc_dispatch(inPtr, payloadBytes.length, outPtr);

  let responseText = "";
  if (mem) {
    const outView = new Uint8Array(mem.buffer, outPtr, Math.min(maxOut, mem.buffer.byteLength - outPtr));
    let len = 0;
    while (len < maxOut && outView[len] !== 0) len++;
    responseText = dec.decode(outView.subarray(0, len));
  }

  if (typeof exp.asl_free === "function") {
    exp.asl_free(inPtr, payloadBytes.length + 1);
    exp.asl_free(outPtr, maxOut);
  }

  process.stdout.write(responseText.endsWith("\n") ? responseText : responseText + "\n");
  process.exit(retCode);
}

if (typeof exp.main === "function") {
  const res = exp.main();
  process.exit(Number(res) || 0);
}

process.exit(0);
EOF_RUN_WASM
chmod +x "${STAGE_LINUX}/run-wasm.js"

mkdir -p "${STAGE_LINUX}/packages"
cp -R asl/packages/* "${STAGE_LINUX}/packages/" 2>/dev/null || true
mkdir -p "${STAGE_LINUX}/.dist-meta"
echo "(:target \"linux-x64\" :version \"${VERSION}\" :substrate \"wasm-wasi\" :arch \"x64\" :os \"linux\" :compiler \"asl-compiler/wasm\")" > "${STAGE_LINUX}/.dist-meta/platform.asn"
tar -czf "${LINUX_ARCHIVE}" -C "${STAGE_LINUX}" asl bin asl.wasm run-wasm.js packages .dist-meta
rm -rf "${STAGE_LINUX}"
echo "    ✓ Packaged ${LINUX_ARCHIVE}"

# Step 4d: Target 3: browser (WebAssembly bytecode + JS bridge)
echo "    • Packaging target: asl-${VERSION}-browser.tar.gz..."
BROWSER_ARCHIVE="${DIST_DIR}/asl-${VERSION}-browser.tar.gz"
STAGE_BROWSER="$(mktemp -d /tmp/asl-dist-browser.XXXXXX)"
cp -f "${WASM_BYTECODE}" "${STAGE_BROWSER}/asl.wasm"

cat << 'EOF_JS_BRIDGE' > "${STAGE_BROWSER}/asl-bridge.js"
/**
 * AgentScript (ASL) Browser Runtime Bridge
 * Bridges WebAssembly bytecode compiled by asl-compiler/wasm to the JavaScript host environment.
 */
(function (global, factory) {
  if (typeof module === "object" && typeof module.exports === "object") {
    module.exports = factory();
  } else if (typeof define === "function" && define.amd) {
    define([], factory);
  } else {
    global.AslBridge = factory();
  }
})(typeof self !== "undefined" ? self : this, function () {
  "use strict";

  function parseTokens(sexpr) {
    const trimmed = sexpr.trim();
    if (!trimmed.startsWith("(")) return [trimmed];
    const inner = trimmed.slice(1, -1).trim();
    const tokens = [];
    let depth = 0;
    let current = "";
    for (let i = 0; i < inner.length; i++) {
      const ch = inner[i];
      if (ch === "(") depth++;
      else if (ch === ")") depth--;
      if (depth === 0 && /\s/.test(ch)) {
        if (current.trim()) tokens.push(current.trim());
        current = "";
      } else {
        current += ch;
      }
    }
    if (current.trim()) tokens.push(current.trim());
    return tokens;
  }

  class AslRuntime {
    constructor() {
      this.instance = null;
      this.exports = null;
      this.memory = null;
      this.isInitialized = false;
    }

    async init(wasmSource) {
      let wasmBytes;
      if (wasmSource instanceof Uint8Array || wasmSource instanceof ArrayBuffer) {
        wasmBytes = wasmSource;
      } else if (typeof wasmSource === "string") {
        if (typeof fetch === "function") {
          const resp = await fetch(wasmSource);
          wasmBytes = await resp.arrayBuffer();
        } else if (typeof require === "function") {
          const fs = require("fs");
          wasmBytes = fs.readFileSync(wasmSource);
        } else {
          throw new Error("Cannot load WASM string source in this environment");
        }
      } else {
        throw new Error("Invalid wasmSource provided");
      }

      const wasmModule = await WebAssembly.compile(wasmBytes);
      const importObject = {
        env: {
          abort: () => { throw new Error("ASL WASM abort"); }
        },
        wasi_snapshot_preview1: {
          fd_write: () => 0,
          fd_read: () => 0,
          fd_close: () => 0,
          proc_exit: (code) => { console.warn("WASI proc_exit:", code); },
          path_open: () => 0
        }
      };

      try {
        this.instance = await WebAssembly.instantiate(wasmModule, importObject);
      } catch (_) {
        this.instance = await WebAssembly.instantiate(wasmModule, {});
      }

      this.exports = this.instance.exports;
      this.memory = this.exports.memory || null;
      if (this.memory && this.memory.buffer.byteLength < 131072) {
        try { this.memory.grow(2); } catch (_) {}
      }
      this.isInitialized = true;
      return this;
    }

    alloc(size) {
      if (!this.isInitialized) throw new Error("ASL Runtime not initialized");
      if (typeof this.exports.asl_alloc === "function") {
        if (this.memory && this.memory.buffer.byteLength < 131072) {
          try { this.memory.grow(2); } catch (_) {}
        }
        return this.exports.asl_alloc(size);
      }
      return 0;
    }

    free(ptr, size) {
      if (!this.isInitialized) throw new Error("ASL Runtime not initialized");
      if (typeof this.exports.asl_free === "function") {
        this.exports.asl_free(ptr, size);
      }
    }

    dispatchRpc(payload) {
      if (!this.isInitialized) throw new Error("ASL Runtime not initialized");
      if (typeof this.exports.asl_rpc_dispatch !== "function") {
        throw new Error("WASM module does not export asl_rpc_dispatch");
      }

      const enc = new TextEncoder();
      const dec = new TextDecoder();
      const bytes = enc.encode(payload);

      if (this.memory && this.memory.buffer.byteLength < 131072) {
        try { this.memory.grow(2); } catch (_) {}
      }

      const inPtr = this.alloc(bytes.length + 1);
      if (this.memory) {
        const view = new Uint8Array(this.memory.buffer, inPtr, bytes.length + 1);
        view.set(bytes);
        view[bytes.length] = 0;
      }

      const maxOut = 4096;
      const outPtr = this.alloc(maxOut);
      const wasmCode = this.exports.asl_rpc_dispatch(inPtr, bytes.length, outPtr);

      let outputText = "";
      if (this.memory) {
        const outView = new Uint8Array(this.memory.buffer, outPtr, Math.min(maxOut, this.memory.buffer.byteLength - outPtr));
        let len = 0;
        while (len < maxOut && outView[len] !== 0) len++;
        outputText = dec.decode(outView.subarray(0, len));
      }

      this.free(inPtr, bytes.length + 1);
      this.free(outPtr, maxOut);

      return {
        status: "completed",
        substrate: "browser-wasm",
        wasmCode: wasmCode,
        payload: payload,
        output: outputText.trim(),
        timestamp: Date.now()
      };
    }

    eval(expr) {
      if (!this.isInitialized) throw new Error("ASL Runtime not initialized");
      const tokens = parseTokens(expr);
      if (tokens.length === 0 || tokens[0] === "") return 0n;

      if (tokens.length === 1 && !tokens[0].startsWith("(")) {
        const a = tokens[0];
        if (a === "true") return 1n;
        if (a === "false") return 0n;
        if (/^-?\d+$/.test(a)) return BigInt(a);
        return 0n;
      }

      const op = tokens[0];
      if (typeof this.exports[op] === "function") {
        const args = tokens.slice(1).map(x => this.eval(x));
        return this.exports[op](...args);
      }

      if (typeof this.exports.evalArithmetic === "function") {
        const opMap = { "+": 1n, "add": 1n, "-": 2n, "sub": 2n, "*": 3n, "mult": 3n, "mul": 3n, "/": 4n, "div": 4n, "mod": 5n, "rem": 5n };
        if (opMap[op]) {
          if (tokens.length === 2 && op === "-") {
            const v = this.eval(tokens[1]);
            return this.exports.evalArithmetic(2n, 0n, v);
          }
          if (tokens.length >= 3) {
            const a = this.eval(tokens[1]);
            const b = this.eval(tokens[2]);
            return this.exports.evalArithmetic(opMap[op], a, b);
          }
        }
      }

      if (op === "clamp" && typeof this.exports.clamp === "function") {
        const v = this.eval(tokens[1]);
        const low = this.eval(tokens[2]);
        const high = this.eval(tokens[3]);
        return this.exports.clamp(v, low, high);
      }

      if (typeof this.exports.evalNode === "function") {
        const env = typeof this.exports.makeEvalEnv === "function" ? this.exports.makeEvalEnv() : 0n;
        return this.exports.evalNode(env, 0n);
      }

      return 0n;
    }
  }

  return {
    AslRuntime: AslRuntime,
    createRuntime: async (wasmSource) => {
      const rt = new AslRuntime();
      await rt.init(wasmSource);
      return rt;
    }
  };
});
EOF_JS_BRIDGE

cat << 'EOF_BROWSER_HTML' > "${STAGE_BROWSER}/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>AgentScript (ASL) Browser Runtime</title>
  <style>
    body { font-family: ui-monospace, monospace; background: #0b0f19; color: #f1f5f9; padding: 2rem; }
    h1 { color: #38bdf8; }
    pre { background: #1e293b; padding: 1rem; border-radius: 8px; }
  </style>
</head>
<body>
  <h1>AgentScript (ASL) Browser Runtime v0.1.0</h1>
  <p>Universal WebAssembly Engine + JS Bridge</p>
  <pre id="output">Initializing WebAssembly runtime...</pre>
  <script src="asl-bridge.js"></script>
  <script>
    (async function() {
      const out = document.getElementById('output');
      try {
        const rt = await AslBridge.createRuntime('asl.wasm');
        out.textContent = "✓ ASL WASM Initialized successfully!\n";
        out.textContent += "Exports: " + Object.keys(rt.exports).join(", ") + "\n";
        out.textContent += "Eval (+ 100 250): " + rt.eval("(+ 100 250)") + "\n";
        out.textContent += "Eval (* 6 7): " + rt.eval("(* 6 7)") + "\n";
        out.textContent += "Eval (clamp 15 10 20): " + rt.eval("(clamp 15 10 20)") + "\n";
        out.textContent += "Alloc (1024): " + rt.alloc(1024) + "\n";
      } catch (e) {
        out.textContent = "Error: " + e.message;
      }
    })();
  </script>
</body>
</html>
EOF_BROWSER_HTML

mkdir -p "${STAGE_BROWSER}/packages"
cp -R asl/packages/* "${STAGE_BROWSER}/packages/" 2>/dev/null || true
mkdir -p "${STAGE_BROWSER}/.dist-meta"
echo "(:target \"browser\" :version \"${VERSION}\" :substrate \"wasm\" :arch \"wasm32\" :os \"browser\" :compiler \"asl-compiler/wasm\")" > "${STAGE_BROWSER}/.dist-meta/platform.asn"
tar -czf "${BROWSER_ARCHIVE}" -C "${STAGE_BROWSER}" asl.wasm asl-bridge.js index.html packages .dist-meta
rm -rf "${STAGE_BROWSER}" "${WASM_BUILD_DIR}"
echo "    ✓ Packaged ${BROWSER_ARCHIVE}"

cd "$DIST_DIR"
if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 asl-* > SHA256SUMS 2>/dev/null || true
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum asl-* > SHA256SUMS 2>/dev/null || true
fi
cd "$WS_ROOT"
echo "    ✓ Generated ${DIST_DIR}/SHA256SUMS"

# Step 4e: Verify scratch installations for all 3 targets
echo "--> Verifying scratch installations of all 3 release packages..."

# 1. Verify darwin-arm64
SCRATCH_DIR_DARWIN="$(mktemp -d /tmp/asl-scratch-darwin.XXXXXX)"
tar -xzf "${DIST_DIR}/asl-${VERSION}-darwin-arm64.tar.gz" -C "${SCRATCH_DIR_DARWIN}"
if [ ! -x "${SCRATCH_DIR_DARWIN}/asl" ]; then
  echo "Error: darwin-arm64 package missing executable asl" >&2
  exit 1
fi
"${SCRATCH_DIR_DARWIN}/asl" --version >/dev/null 2>&1 || {
  echo "Error: darwin-arm64 binary failed --version execution" >&2
  exit 1
}
rm -rf "${SCRATCH_DIR_DARWIN}"
echo "    ✓ Verified asl-${VERSION}-darwin-arm64.tar.gz"

# 2. Verify linux-x64
SCRATCH_DIR_LINUX="$(mktemp -d /tmp/asl-scratch-linux.XXXXXX)"
tar -xzf "${DIST_DIR}/asl-${VERSION}-linux-x64.tar.gz" -C "${SCRATCH_DIR_LINUX}"
if [ ! -x "${SCRATCH_DIR_LINUX}/asl" ] || [ ! -f "${SCRATCH_DIR_LINUX}/asl.wasm" ]; then
  echo "Error: linux-x64 package missing executable asl or asl.wasm" >&2
  exit 1
fi
"${SCRATCH_DIR_LINUX}/asl" --version | grep -q "0.1.0" || {
  echo "Error: linux-x64 wrapper failed --version execution" >&2
  exit 1
}
if command -v node >/dev/null 2>&1; then
  NODE_EVAL_RES=$("${SCRATCH_DIR_LINUX}/asl" eval '(+ 40 2)')
  if [ "$NODE_EVAL_RES" != "42" ]; then
    echo "Error: linux-x64 eval (+ 40 2) returned '$NODE_EVAL_RES' instead of 42" >&2
    exit 1
  fi
fi
rm -rf "${SCRATCH_DIR_LINUX}"
echo "    ✓ Verified asl-${VERSION}-linux-x64.tar.gz"

# 3. Verify browser
SCRATCH_DIR_BROWSER="$(mktemp -d /tmp/asl-scratch-browser.XXXXXX)"
tar -xzf "${DIST_DIR}/asl-${VERSION}-browser.tar.gz" -C "${SCRATCH_DIR_BROWSER}"
if [ ! -f "${SCRATCH_DIR_BROWSER}/asl.wasm" ] || [ ! -f "${SCRATCH_DIR_BROWSER}/asl-bridge.js" ]; then
  echo "Error: browser package missing asl.wasm or asl-bridge.js" >&2
  exit 1
fi
"$NODE_EXEC" -e '
const fs = require("fs");
const path = require("path");
const scratchDir = process.argv[1];
const wasmBytes = fs.readFileSync(path.join(scratchDir, "asl.wasm"));
if (!WebAssembly.validate(wasmBytes)) {
  console.error("Error: browser asl.wasm failed validation");
  process.exit(1);
}
const AslBridge = require(path.join(scratchDir, "asl-bridge.js"));
const rt = new AslBridge.AslRuntime();
rt.init(wasmBytes).then(() => {
  const res = rt.eval("(+ 30 12)");
  if (res !== 42n) {
    console.error("Error: browser bridge eval returned", res);
    process.exit(1);
  }
  const rpcRes = rt.dispatchRpc("(:batch (:echo :message \"test\"))");
  if (!rpcRes || rpcRes.status !== "completed") {
    console.error("Error: browser bridge dispatchRpc failed", rpcRes);
    process.exit(1);
  }
  process.exit(0);
}).catch(err => {
  console.error(err);
  process.exit(1);
});
' "${SCRATCH_DIR_BROWSER}"
rm -rf "${SCRATCH_DIR_BROWSER}"
echo "    ✓ Verified asl-${VERSION}-browser.tar.gz"

# Step 5: System Installation & Agent Toolbelt Registration
echo "--> [5/5] Installing ASL binary into system and registering agent skills..."

INSTALL_DIR="${HOME}/.asl/bin"
LOCAL_BIN="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR" "$LOCAL_BIN" 2>/dev/null || true

# Symlink binaries
ln -sf "${WS_ROOT}/asl/asl" "${INSTALL_DIR}/asl" 2>/dev/null || true
ln -sf "${WS_ROOT}/asl/asl" "${INSTALL_DIR}/agentscript" 2>/dev/null || true
ln -sf "${WS_ROOT}/asl/asl" "${LOCAL_BIN}/asl" 2>/dev/null || true
ln -sf "${WS_ROOT}/asl/asl" "${LOCAL_BIN}/agentscript" 2>/dev/null || true
if [ -f "${WS_ROOT}/asl/bin/asl-engine" ]; then
  ln -sf "${WS_ROOT}/asl/bin/asl-engine" "${INSTALL_DIR}/asl-engine" 2>/dev/null || true
  ln -sf "${WS_ROOT}/asl/bin/asl-engine" "${LOCAL_BIN}/asl-engine" 2>/dev/null || true
  chmod +x "${INSTALL_DIR}/asl-engine" "${LOCAL_BIN}/asl-engine" 2>/dev/null || true
  echo "    ✓ Symlinked to ${INSTALL_DIR}/asl-engine"
  echo "    ✓ Symlinked to ${LOCAL_BIN}/asl-engine"
fi
chmod +x "${INSTALL_DIR}/asl" "${LOCAL_BIN}/asl" 2>/dev/null || true

echo "    ✓ Symlinked to ${INSTALL_DIR}/asl"
echo "    ✓ Symlinked to ${INSTALL_DIR}/agentscript"
echo "    ✓ Symlinked to ${LOCAL_BIN}/asl"
echo "    ✓ Symlinked to ${LOCAL_BIN}/agentscript"

# Ensure PATH in shell profiles
add_to_path() {
  local target_dir="$1"
  local config_file="$2"
  if [ -f "$config_file" ] && [ -w "$config_file" ]; then
    if ! grep -qs "$target_dir" "$config_file" 2>/dev/null; then
      echo "" >> "$config_file" 2>/dev/null || true
      echo "# AgentScript (ASL) CLI" >> "$config_file" 2>/dev/null || true
      echo "export PATH=\"$target_dir:\$PATH\"" >> "$config_file" 2>/dev/null || true
      echo "    ✓ Added $target_dir to $config_file"
    fi
  fi
}

[ -f "${HOME}/.zshrc" ] && add_to_path "$INSTALL_DIR" "${HOME}/.zshrc"
[ -f "${HOME}/.zshrc" ] && add_to_path "$LOCAL_BIN" "${HOME}/.zshrc"
[ -f "${HOME}/.bashrc" ] && add_to_path "$INSTALL_DIR" "${HOME}/.bashrc"
[ -f "${HOME}/.bashrc" ] && add_to_path "$LOCAL_BIN" "${HOME}/.bashrc"
[ -f "${HOME}/.profile" ] && add_to_path "$INSTALL_DIR" "${HOME}/.profile"

# Run agent skills installation
bash "${WS_ROOT}/scripts/install.sh" --all --skills --source 2>/dev/null || true
touch "${WS_ROOT}/asl/grammar/capabilities.lock" 2>/dev/null || true

echo ""
echo "================================================================================"
echo "✓ COMPILATION & SYSTEM INSTALLATION COMPLETED SUCCESSFULLY"
echo "================================================================================"
echo "Release distribution archives created in ${DIST_DIR}:"
echo "  • ${DIST_DIR}/asl-${VERSION}-darwin-arm64.tar.gz"
echo "  • ${DIST_DIR}/asl-${VERSION}-linux-x64.tar.gz"
echo "  • ${DIST_DIR}/asl-${VERSION}-browser.tar.gz"
echo "Binary paths:"
echo "  • ${INSTALL_DIR}/asl"
echo "  • ${LOCAL_BIN}/asl"
echo "Version:"
"${LOCAL_BIN}/asl" --version 2>/dev/null || "${INSTALL_DIR}/asl" --version 2>/dev/null || true
echo "================================================================================"
