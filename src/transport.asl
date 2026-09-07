(module asl-web-api-search/transport
  :d "Multi-runtime network transport: Host curl, Browser Extension Relay, CORS Proxy, and Airgap fallback"
  :x [RuntimeKind TransportStrategy resolve-runtime-strategy build-transport-fetch-cmd is-cors-restricted? is-offline-transport?]
  :i [])

(dfe RuntimeKind
  (:c desktop-host [] "Unrestricted host Node / CLI execution")
  (:c browser-extension [] "WebExtension background worker with <all_urls> permission")
  (:c browser-webpage [] "In-page DOM / WebLLM sandbox subject to CORS")
  (:c airgap-sandbox [] "Restricted container / ERGP without outbound internet"))

(dfe TransportStrategy
  (:c direct-curl [] "Host direct curl / socket fetch")
  (:c extension-relay [] "Relay through browser-plugin background worker")
  (:c cors-safe-direct [] "Direct fetch to CORS-enabled endpoints")
  (:c local-daemon-bridge [] "Proxy through local ASL daemon on 127.0.0.1:8765")
  (:c public-cors-proxy [] "Proxy through allorigins.win or configured CORS mirror")
  (:c memory-cache-only [] "Immediate offline fallback to resident research memory"))

(df is-cors-restricted? [(runtime RuntimeKind)] -> Bool
  :d "Determines whether runtime environment is subject to browser CORS restrictions"
  (mt runtime
    ((RuntimeKind:browser-webpage) true)
    ((RuntimeKind:airgap-sandbox) true)
    ((RuntimeKind:desktop-host) false)
    ((RuntimeKind:browser-extension) false)))

(df resolve-runtime-strategy [(runtime RuntimeKind) (has-extension Bool) (is-cors-endpoint Bool)] -> TransportStrategy
  :d "Selects the optimal network transport strategy based on runtime execution environment"
  (mt runtime
    ((RuntimeKind:airgap-sandbox)
     (TransportStrategy:memory-cache-only))
    ((RuntimeKind:desktop-host)
     (TransportStrategy:direct-curl))
    ((RuntimeKind:browser-extension)
     (TransportStrategy:extension-relay))
    ((RuntimeKind:browser-webpage)
     (if has-extension
         (TransportStrategy:extension-relay)
         (if is-cors-endpoint
             (TransportStrategy:cors-safe-direct)
             (TransportStrategy:local-daemon-bridge))))))

(df build-transport-fetch-cmd [(strategy TransportStrategy) (url Str) (headers (List Str))] -> (List Str)
  :d "Constructs command vector or payload descriptor for selected transport strategy"
  (mt strategy
    ((TransportStrategy:direct-curl)
     (let [(base (list "curl" "-sSL" "--max-time" "10"))
           (with-headers (fold (fn [(acc (List Str)) (h Str)] -> (List Str)
                                 (list-concat acc (list "-H" h)))
                               base
                               headers))]
       (list-concat with-headers (list url))))
    ((TransportStrategy:extension-relay)
     (list "asl_extension_relay" "fetch" url))
    ((TransportStrategy:cors-safe-direct)
     (list "fetch" url "cors:origin=*"))
    ((TransportStrategy:local-daemon-bridge)
     (list "curl" "-sSL" (str "http://127.0.0.1:8765/proxy?url=" url)))
    ((TransportStrategy:public-cors-proxy)
     (list "fetch" (str "https://api.allorigins.win/raw?url=" url)))
    ((TransportStrategy:memory-cache-only)
     (list "mem_cache_hit" url))))

(df is-offline-transport? [(strategy TransportStrategy)] -> Bool
  :d "Evaluates whether network transport strategy is restricted to offline local memory cache"
  (mt strategy
    ((TransportStrategy:memory-cache-only) true)
    (:else false)))

