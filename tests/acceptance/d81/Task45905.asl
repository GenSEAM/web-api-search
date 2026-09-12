(module tests/acceptance/d81/Task45905
  :d "Acceptance fixture for Task45905: Symbol surface as tracked quantity above token count under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSymbolSurfaceTrackingContract
      TestSymbolSurfaceRatchetContract
      TestDualQuantityInventoryContract
      TestSymbolSurfaceTelemetryGrounded
      TestTokenConventionsSymbolSurfaceContract]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestSymbolSurfaceTrackingContract [] -> Bool
  :d "Verifies language-semantics.asn defines symbolSurfaceTracking semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "symbolSurfaceTracking") "language-semantics.asn must define symbolSurfaceTracking semantic")
      (assert (string-contains? s-src "ERR_SURFACE_EXPANSION_WITHOUT_EVIDENCE") "language-semantics.asn must specify ERR_SURFACE_EXPANSION_WITHOUT_EVIDENCE failureCode")
      true)))

(df TestSymbolSurfaceRatchetContract [] -> Bool
  :d "Verifies language-semantics.asn defines symbolSurfaceRatchet semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "symbolSurfaceRatchet") "language-semantics.asn must define symbolSurfaceRatchet semantic")
      (assert (string-contains? s-src "ERR_SYMBOL_SURFACE_RATCHET_VIOLATION") "language-semantics.asn must specify ERR_SYMBOL_SURFACE_RATCHET_VIOLATION failureCode")
      true)))

(df TestDualQuantityInventoryContract [] -> Bool
  :d "Verifies language-semantics.asn defines dualQuantityInventory semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "dualQuantityInventory") "language-semantics.asn must define dualQuantityInventory semantic")
      (assert (string-contains? s-src "ERR_MISSING_DUAL_INVENTORY") "language-semantics.asn must specify ERR_MISSING_DUAL_INVENTORY failureCode")
      true)))

(df TestSymbolSurfaceTelemetryGrounded [] -> Bool
  :d "Verifies SymbolSurface20260912.asn records 17112 distinct head symbols and 1512691 tokens"
  (let [(t-res (file-read ".asl/mem/telemetry/SymbolSurface20260912.asn"))]
    (assert (= (.-_tag t-res) "ok") "SymbolSurface20260912.asn must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "17112") "Telemetry must record 17112 distinct head symbols")
      (assert (string-contains? t-src "1512691") "Telemetry must record 1512691 corpus tokens")
      true)))

(df TestTokenConventionsSymbolSurfaceContract [] -> Bool
  :d "Verifies TOKEN_CONVENTIONS.md documents symbol surface tracking and ratchet policy"
  (let [(t-res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag t-res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "Symbol Surface Tracking") "TOKEN_CONVENTIONS.md must document Symbol Surface Tracking")
      (assert (string-contains? t-src "17112") "TOKEN_CONVENTIONS.md must record 17112 distinct head symbols")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45905 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSymbolSurfaceTrackingContract) "TestSymbolSurfaceTrackingContract must pass")
    (assert (TestSymbolSurfaceRatchetContract) "TestSymbolSurfaceRatchetContract must pass")
    (assert (TestDualQuantityInventoryContract) "TestDualQuantityInventoryContract must pass")
    (assert (TestSymbolSurfaceTelemetryGrounded) "TestSymbolSurfaceTelemetryGrounded must pass")
    (assert (TestTokenConventionsSymbolSurfaceContract) "TestTokenConventionsSymbolSurfaceContract must pass")
    true))
