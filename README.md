# @genseam/asl-web-api-search (Native AgentScript Search Engine API)

Native AgentScript multi-engine search API aggregator, URL deduplicator, and RAG context compressor for autonomous AI agents.

## Installation
```bash
asl get github.com/GenSEAM/web-api-search
```

---

## Supported Search Providers & Environment Variables

`asl-web-api-search` supports both open (unauthenticated) endpoints and authenticated commercial AI search APIs. Configure private keys in your shell environment or `.env` file:

| Environment Variable | Provider | Header / Auth Scheme | Default / Endpoint Format |
|---|---|---|---|
| `TAVILY_API_KEY` | Tavily Search API | `Authorization: Bearer <key>` | `https://api.tavily.com/search?query={q}&max_results={lim}` |
| `SERPER_API_KEY` | Google Serper.dev | `X-API-KEY: <key>` | `https://google.serper.dev/search?q={q}&num={lim}` |
| `BRAVE_API_KEY` | Brave Web Search | `X-Subscription-Token: <key>` | `https://api.search.brave.com/res/v1/web/search?q={q}&count={lim}` |
| `GITHUB_TOKEN` | GitHub API | `Authorization: token <token>` | `https://api.github.com/search/repositories?q={q}&per_page={lim}` |
| `SEARXNG_URL` | SearXNG Metasearch | Optional Basic / Bearer | `https://searx.be/search?q={q}&format=json` (or private host) |
| *(None - Open)* | DuckDuckGo | Unauthenticated | `https://html.duckduckgo.com/html/?q={q}` |
| *(None - Open)* | Wikipedia | Unauthenticated | `https://en.wikipedia.org/w/api.php?action=opensearch...` |
| *(None - Open)* | arXiv API | Unauthenticated | `http://export.arxiv.org/api/query?search_query=all:...` |
| *(None - Open)* | HackerNews Algolia | Unauthenticated | `https://hn.algolia.com/api/v1/search?query=...` |

### Environment Configuration Example

Add the following to your `~/.zshrc`, `~/.bashrc`, or project `.env`:

```bash
# Tavily AI Search (https://tavily.com)
export TAVILY_API_KEY="tvly-xxxxxxxxxxxxxxxxxxxxxxxx"

# Google Serper API (https://serper.dev)
export SERPER_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Brave Web Search (https://brave.com/search/api/)
export BRAVE_API_KEY="BSAxxxxxxxxxxxxxxxxxxxxxxxx"

# GitHub Token (for repository and code search limits)
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxx"

# Self-Hosted / Private SearXNG Node (optional)
export SEARXNG_URL="https://search.internal.corp/search"
```

---

## Features

- **Pure AgentScript Implementation:** Zero foreign runtime dependencies. Compiles to WebAssembly, TypeScript, and Rust.
- **Multi-Engine API Providers:** Generates target query endpoints for DuckDuckGo, Wikipedia, GitHub, arXiv, HackerNews, Brave, Google Serper, and Tavily.
- **Typed Curl Vectors:** Generates safe, injection-free `(CurlCommand ...)` argument vectors for sandboxed process execution.
- **URL Tracking Cleaner:** Strips `utm_*`, `ref`, `fbclid`, and `gclid` tracking parameters natively in ASL without external regex bloat.
- **Cross-Engine Deduplication:** Merges identical URLs from multiple providers, combines provenance tags (e.g. `brave+tavily`), and computes aggregated relevance scores.
- **RAG Context Compressor:** Formats search results into clean, numbered Markdown context optimized for LLM prompt injection.
- **Proxy Pool Health Checks:** Typed proxy node latency and success rate evaluation with cooldown tracking.

---

## AgentScript API & Usage Examples

### 1. Building Search URLs
```lisp
(use asl-web-api-search/engine [build-search-url])

;; Generate endpoint URL for arXiv
(let [(url (build-search-url "arxiv" "deep seek r1 reasoning" 5))]
  ;; => "http://export.arxiv.org/api/query?search_query=all:deep+seek+r1+reasoning&start=0&max_results=5"
)
```

### 2. Building Authenticated Curl Execution Commands
```lisp
(use asl-web-api-search/engine [build-provider-curl-cmd])

;; Construct authenticated curl command vector with custom API key and timeout
(let [(cmd (build-provider-curl-cmd "tavily" "https://api.tavily.com/search?query=asl" "tvly-xxx" 15))]
  ;; Returns typed (CurlCommand :bin "curl" :args ("-s" "--max-time" "15" "-H" "Accept: application/json" "-H" "Authorization: Bearer tvly-xxx" ...) :url ...)
)
```

### 3. URL Deduplication and Tracking Parameter Removal
```lisp
(use asl-web-api-search/engine [clean-url merge-search-results])

;; Strips tracking tags
(let [(clean (clean-url "https://github.com/GenSEAM/asl?utm_source=twitter&ref=newsletter&fbclid=xyz"))]
  ;; => "https://github.com/GenSEAM/asl"
)
```

### 4. Compressing Results into RAG Context
```lisp
(use asl-web-api-search/engine [format-rag-context SearchResult])

(let [(items (list
               (SearchResult :title "ASL Guide" :url "https://asl.dev" :snippet "AgentScript reference..." :engine "ddg" :score 1.0)))]
  (format-rag-context "AgentScript language" items))
```

---

## ASL Daemon & RPC Batch Integration

When interacting with the resident `asl-mem-daemon`, search queries can be dispatched via the unified compact RPC S-expression protocol:

```lisp
(:batch
  (:step :id 1 :op "web-search" :query "high performance webgl chart" :engine "brave" :limit 5))
```

Or via the native CLI projection:
```bash
asl web "webgl canvas graph visualization" github 5
```

---

## Module Exports (`asl-web-api-search/engine`)
- `build-search-url [(engine Str) (query Str) (limit I64)] -> Str`
- `make-curl-command [(url Str) (timeout-sec I64) (user-agent Str)] -> CurlCommand`
- `build-provider-curl-cmd [(engine Str) (url Str) (api-key Str) (timeout-sec I64)] -> CurlCommand`
- `clean-url [(url Str)] -> Str`
- `merge-search-results [(primary (List SearchResult)) (secondary (List SearchResult))] -> (List SearchResult)`
- `format-rag-context [(query Str) (items (List SearchResult))] -> Str`
- `is-proxy-healthy [(proxy ProxyNode)] -> Bool`
- `select-healthy-proxies [(proxies (List ProxyNode))] -> (List ProxyNode)`

## License
MIT
