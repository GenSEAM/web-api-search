# @genseam/asl-web-api-search (Native AgentScript Search Engine API)

Native AgentScript multi-engine search API aggregator, URL deduplicator, and RAG context compressor for autonomous AI agents.

## Installation
```bash
asl get github.com/GenSEAM/web-api-search
```

## Features
- **Pure AgentScript Implementation:** Zero foreign runtime dependencies. Compiles to WebAssembly, TypeScript, and Rust.
- **Multi-Engine API Providers:** Generates target query endpoints for DuckDuckGo, Wikipedia, GitHub, arXiv, HackerNews, Brave, Google, and Tavily.
- **Typed Curl Command Vectors:** Generates safe, injection-free `(CurlCommand ...)` argument vectors.
- **URL Tracking Cleaner:** Strips `utm_*`, `ref`, `fbclid`, and `gclid` tracking parameters natively in ASL.
- **Cross-Engine Deduplication:** Cleans duplicate URLs, boosts relevance scores, and combines engine source tags.
- **RAG Context Compressor:** Formats search results into clean, numbered Markdown context optimized for LLM prompt injection.
- **Proxy Pool Health Checks:** Typed proxy node latency and success rate evaluation.

## Module Exports (`asl-web-api-search/engine`)
- `build-search-url [(engine Str) (query Str) (limit I64)] -> Str`
- `make-curl-command [(url Str) (timeout-sec I64) (user-agent Str)] -> CurlCommand`
- `clean-url [(url Str)] -> Str`
- `merge-search-results [(primary (List SearchResult)) (secondary (List SearchResult))] -> (List SearchResult)`
- `format-rag-context [(query Str) (items (List SearchResult))] -> Str`
- `is-proxy-healthy [(proxy ProxyNode)] -> Bool`
- `select-healthy-proxies [(proxies (List ProxyNode))] -> (List ProxyNode)`

## License
MIT
