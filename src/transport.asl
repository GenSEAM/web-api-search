(module aslWebApiSearch/transport
  :d "Multi-runtime network transport: Host curl, Browser Extension Relay, CORS Proxy, and Airgap fallback"
  :x [RuntimeKind TransportStrategy resolveRuntimeStrategy buildTransportFetchCmd isCorsRestricted? isOfflineTransport?]
  :i [])

(dfe RuntimeKind
  (:c desktopHost [] "Unrestricted host Node / CLI execution")
  (:c browserExtension [] "WebExtension background worker with <all_urls> permission")
  (:c browserWebpage [] "In-page DOM / WebLLM sandbox subject to CORS")
  (:c airgapSandbox [] "Restricted container / ERGP without outbound internet"))

(dfe TransportStrategy
  (:c directCurl [] "Host direct curl / socket fetch")
  (:c extensionRelay [] "Relay through browser-plugin background worker")
  (:c corsSafeDirect [] "Direct fetch to CORS-enabled endpoints")
  (:c localDaemonBridge [] "Proxy through local ASL daemon on 127.0.0.1:8765")

  (:c memoryCacheOnly [] "Immediate offline fallback to resident research memory"))

(df isCorsRestricted? [(runtime RuntimeKind)] -> Bool
  :d "Determines whether runtime environment is subject to browser CORS restrictions"
  (mt runtime
    ((RuntimeKind:browserWebpage) true)
    ((RuntimeKind:airgapSandbox) true)
    ((RuntimeKind:desktopHost) false)
    ((RuntimeKind:browserExtension) false)))

(df resolveRuntimeStrategy [(runtime RuntimeKind) (hasExtension Bool) (isCorsEndpoint Bool)] -> TransportStrategy
  :d "Selects the optimal network transport strategy based on runtime execution environment"
  (mt runtime
    ((RuntimeKind:airgapSandbox)
     (TransportStrategy:memoryCacheOnly))
    ((RuntimeKind:desktopHost)
     (TransportStrategy:directCurl))
    ((RuntimeKind:browserExtension)
     (TransportStrategy:extensionRelay))
    ((RuntimeKind:browserWebpage)
     (if hasExtension
         (TransportStrategy:extensionRelay)
         (if isCorsEndpoint
             (TransportStrategy:corsSafeDirect)
             (TransportStrategy:localDaemonBridge))))))

(df buildTransportFetchCmd [(strategy TransportStrategy) (url Str) (headers (List Str))] -> (List Str)
  :d "Constructs command vector or payload descriptor for selected transport strategy"
  (mt strategy
    ((TransportStrategy:directCurl)
     (let [(base (list "curl" "-sSL" "--max-time" "10"))
           (withHeaders (fold (fn [(acc (List Str)) (h Str)] -> (List Str)
                                 (listConcat acc (list "-H" h)))
                               base
                               headers))]
       (listConcat withHeaders (list "--" url))))
    ((TransportStrategy:extensionRelay)
     (list "asl_extension_relay" "fetch" url))
    ((TransportStrategy:corsSafeDirect)
     (list "fetch" url "cors:origin=*"))
    ((TransportStrategy:localDaemonBridge)
     (let [(u1 (string-replace url "%" "%25"))
           (u2 (string-replace u1 "&" "%26"))
           (u3 (string-replace u2 "?" "%3F"))
           (u4 (string-replace u3 "#" "%23"))
           (u5 (string-replace u4 "=" "%3D"))]
       (list "curl" "-sSL" (str "http://127.0.0.1:8765/proxy?url=" u5))))

    ((TransportStrategy:memoryCacheOnly)
     (list "mem_cache_hit" url))))

(df isOfflineTransport? [(strategy TransportStrategy)] -> Bool
  :d "Evaluates whether network transport strategy is restricted to offline local memory cache"
  (mt strategy
    ((TransportStrategy:memoryCacheOnly) true)
    (:else false)))

