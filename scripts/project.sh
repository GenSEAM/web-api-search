#!/usr/bin/env bash
# scripts/project.sh: Sovereign Pure Shell ASN Host Projection Engine
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CHECK_MODE=false
WS_ROOT="${ROOT_DIR}"

while [ $# -gt 0 ]; do
  case "$1" in
    --check)
      CHECK_MODE=true
      shift
      ;;
    --root)
      WS_ROOT="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

cd "${WS_ROOT}"

if [ ! -f ".asl.config.asn" ]; then
  echo "No .asl.config.asn found."
  exit 0
fi

NODE_BIN="/usr/local/bin/node"
if [ ! -x "$NODE_BIN" ]; then
  if [ -x "/opt/homebrew/bin/node" ]; then
    NODE_BIN="/opt/homebrew/bin/node"
  else
    NODE_BIN="$(command -v node 2>/dev/null || echo "node")"
  fi
fi

"$NODE_BIN" -e '
const fs = require("fs");
const path = require("path");

const checkMode = process.argv[1] === "true";
const wsRoot = process.cwd();

function tokenize(text) {
  const lines = text.split("\n").map(l => {
    let inStr = false;
    let res = "";
    for (let i = 0; i < l.length; i++) {
      const c = l[i];
      if (c === "\"") inStr = !inStr;
      if (c === ";" && !inStr) break;
      res += c;
    }
    return res;
  });
  const clean = lines.join("\n");
  const regex = /(\(|\)|\[|\]|"(?:\\.|[^"\\])*"|:[a-zA-Z0-9_\-\.:]+|[^\s\(\)\[\]]+)/g;
  return clean.match(regex) || [];
}

function parseVal(tokens, ctx) {
  if (ctx.idx >= tokens.length) return null;
  const tok = tokens[ctx.idx];
  if (tok === "(") {
    ctx.idx++;
    const obj = {};
    if (ctx.idx + 1 < tokens.length && tokens[ctx.idx].startsWith(":") && !tokens[ctx.idx + 1].startsWith(":") && (tokens[ctx.idx + 2] === ")" || tokens[ctx.idx + 1] === ")")) {
      const k = tokens[ctx.idx].slice(1);
      ctx.idx++;
      const v = parseVal(tokens, ctx);
      if (ctx.idx < tokens.length && tokens[ctx.idx] === ")") ctx.idx++;
      obj[k] = v;
      return obj;
    }
    if (ctx.idx < tokens.length && tokens[ctx.idx].startsWith(":")) {
      ctx.idx++; // tag
    }
    while (ctx.idx < tokens.length && tokens[ctx.idx] !== ")") {
      const k = tokens[ctx.idx];
      if (k.startsWith(":")) {
        const key = k.slice(1);
        ctx.idx++;
        obj[key] = parseVal(tokens, ctx);
      } else {
        ctx.idx++;
      }
    }
    if (ctx.idx < tokens.length && tokens[ctx.idx] === ")") ctx.idx++;
    return obj;
  } else if (tok === "[") {
    ctx.idx++;
    const arr = [];
    while (ctx.idx < tokens.length && tokens[ctx.idx] !== "]") {
      const v = parseVal(tokens, ctx);
      if (v !== null) arr.push(v);
    }
    if (ctx.idx < tokens.length && tokens[ctx.idx] === "]") ctx.idx++;
    return arr;
  } else if (tok.startsWith("\"") && tok.endsWith("\"")) {
    ctx.idx++;
    return JSON.parse(tok);
  } else if (tok === "true") {
    ctx.idx++; return true;
  } else if (tok === "false") {
    ctx.idx++; return false;
  } else if (tok === "null" || tok === "_" || tok === "none") {
    ctx.idx++; return null;
  } else if (/^-?\d+$/.test(tok)) {
    ctx.idx++; return parseInt(tok, 10);
  } else if (/^-?\d+\.\d+$/.test(tok)) {
    ctx.idx++; return parseFloat(tok);
  } else if (tok.startsWith(":")) {
    ctx.idx++; return tok.slice(1);
  } else {
    ctx.idx++; return tok;
  }
}

function toToml(obj) {
  const lines = [];
  const simples = [];
  const tables = [];
  for (const [k, v] of Object.entries(obj)) {
    if (v && typeof v === "object" && !Array.isArray(v)) {
      tables.push([k, v]);
    } else {
      simples.push([k, v]);
    }
  }
  for (const [k, v] of simples) {
    if (typeof v === "boolean") lines.push(`${k} = ${v}`);
    else if (typeof v === "number") lines.push(`${k} = ${v}`);
    else if (typeof v === "string") lines.push(`${k} = "${v}"`);
    else if (Array.isArray(v)) lines.push(`${k} = [${v.map(x => typeof x === "string" ? `"${x}"` : x).join(", ")}]`);
  }
  for (const [k, table] of tables) {
    if (lines.length > 0) lines.push("");
    lines.push(`[${k}]`);
    for (const [subk, subv] of Object.entries(table)) {
      if (typeof subv === "boolean") lines.push(`${subk} = ${subv}`);
      else if (typeof subv === "number") lines.push(`${subk} = ${subv}`);
      else if (typeof subv === "string") lines.push(`${subk} = "${subv}"`);
      else if (Array.isArray(subv)) lines.push(`${subk} = [${subv.map(x => typeof x === "string" ? `"${x}"` : x).join(", ")}]`);
    }
  }
  return lines.join("\n") + "\n";
}

function toCss(parsed) {
  const lines = [];
  if (parsed.tailwind && Array.isArray(parsed.tailwind)) {
    for (const tw of parsed.tailwind) {
      lines.push(`@tailwind ${tw};`);
    }
    lines.push("");
  }
  if (parsed.layers && Array.isArray(parsed.layers)) {
    for (const layer of parsed.layers) {
      lines.push(`@layer ${layer.name} {`);
      if (layer.themes && Array.isArray(layer.themes)) {
        for (const theme of layer.themes) {
          lines.push(`  ${theme.selector} {`);
          if (theme.tokens && Array.isArray(theme.tokens)) {
            for (const tok of theme.tokens) {
              for (const [k, v] of Object.entries(tok)) {
                lines.push(`    --${k}: ${v};`);
              }
            }
          }
          lines.push(`  }`);
          lines.push("");
        }
      }
      if (layer.rules && Array.isArray(layer.rules)) {
        for (const rule of layer.rules) {
          lines.push(`  ${rule.selector} {`);
          if (rule.declarations && Array.isArray(rule.declarations)) {
            for (const decl of rule.declarations) {
              for (const [k, v] of Object.entries(decl)) {
                lines.push(`    ${k}: ${v};`);
              }
            }
          }
          lines.push(`  }`);
          lines.push("");
        }
      }
      lines.push(`}`);
      lines.push("");
    }
  }
  if (parsed.media && Array.isArray(parsed.media)) {
    for (const m of parsed.media) {
      lines.push(`@media ${m.condition} {`);
      if (m.rules && Array.isArray(m.rules)) {
        for (const rule of m.rules) {
          lines.push(`  ${rule.selector} {`);
          if (rule.declarations && Array.isArray(rule.declarations)) {
            for (const decl of rule.declarations) {
              for (const [k, v] of Object.entries(decl)) {
                lines.push(`    ${k}: ${v};`);
              }
            }
          }
          lines.push(`  }`);
        }
      }
      lines.push(`}`);
      lines.push("");
    }
  }
  return lines.join("\n").trim() + "\n";
}

const configText = fs.readFileSync(".asl.config.asn", "utf8");
const projBlockMatch = configText.match(/:projections\s*\[(.*?)\]\s*(?:\n\s*:[a-zA-Z0-9_\-]+|\n\s*\))/s);
if (!projBlockMatch) {
  console.log("No projections defined in .asl.config.asn.");
  process.exit(0);
}

const projPattern = /\(:proj\s+.*?\)/gs;
const matches = projBlockMatch[1].match(projPattern) || [];
const projections = [];
for (const entry of matches) {
  const fromM = entry.match(/:from\s+"([^"]*)"/);
  const toM = entry.match(/:to\s+"([^"]*)"/);
  const fmtM = entry.match(/:format\s+"([^"]*)"/);
  const docM = entry.match(/:doc\s+"([^"]*)"/);
  if (fromM && toM && fmtM) {
    projections.push({
      from: fromM[1],
      to: toM[1],
      format: fmtM[1],
      doc: docM ? docM[1] : ""
    });
  }
}

console.log(`=== Projecting ${projections.length} declared ASN sources to host runtime targets ===`);
let driftCount = 0;

for (const p of projections) {
  const fromFile = path.resolve(wsRoot, p.from);
  const toFile = path.resolve(wsRoot, p.to);
  const fmt = p.format;
  const doc = p.doc ? ` (${p.doc})` : "";

  if (!fs.existsSync(fromFile)) {
    console.error(`Error: Source ASN ${p.from} not found!`);
    process.exit(1);
  }

  const srcText = fs.readFileSync(fromFile, "utf8");
  const parsed = parseVal(tokenize(srcText), { idx: 0 }) || {};

  let toWrite = "";
  if (fmt === "json") {
    toWrite = JSON.stringify(parsed, null, 2) + "\n";
  } else if (fmt === "toml") {
    toWrite = toToml(parsed);
  } else if (fmt === "css") {
    toWrite = toCss(parsed);
  } else {
    throw new Error(`Unknown format: ${fmt}`);
  }

  if (checkMode) {
    if (!fs.existsSync(toFile) || fs.readFileSync(toFile, "utf8") !== toWrite) {
      console.log(`  [DRIFT] ${p.to} is out of sync with ${p.from}`);
      driftCount++;
    } else {
      console.log(`  [OK]    ${p.to} matches ${p.from}`);
    }
  } else {
    fs.mkdirSync(path.dirname(toFile), { recursive: true });
    fs.writeFileSync(toFile, toWrite, "utf8");
    console.log(`  ✓ ${p.from} ➔ ${p.to} [${fmt.toUpperCase()}]${doc} (${Buffer.byteLength(toWrite)} bytes)`);
  }
}

if (checkMode && driftCount > 0) {
  console.log(`\nDrift detected in ${driftCount} projections. Run '\''asl project'\'' to synchronize.`);
  process.exit(1);
} else {
  console.log(`\n✓ All ${projections.length} host projections synchronized cleanly.`);
}
' "$CHECK_MODE"
