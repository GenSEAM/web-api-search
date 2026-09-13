(module tests/acceptance/d81/Task48401
  :d "Acceptance fixture for Task48401: Grammar, Typestate Schemas and Blamed Rejection Taxonomy under D83."
  :x [run-tests
      test-records-grammar-exists
      test-eleven-record-schemas-declared
      test-three-cognitive-tiers-declared
      test-error-taxonomy-declared
      test-blamed-receipt-schema-bounded]
  :i [])

(df test-records-grammar-exists [] -> Bool
  :d "Verifies that asl/grammar/records.asn exists and is readable"
  (let [(res (file-read "asl/grammar/records.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/records.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":records :v 1 :src D83 :shortcode D83")
              "records.asn must declare D83 header")
      true)))

(df test-eleven-record-schemas-declared [] -> Bool
  :d "Verifies that all 11 monorepo record schemas are declared"
  (let [(res (file-read "asl/grammar/records.asn"))]
    (assert (= (.-_tag res) "ok") "records.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "(:schema :id note") "note schema must be declared")
      (assert (string-contains? src "(:schema :id receipt") "receipt schema must be declared")
      (assert (string-contains? src "(:schema :id telemetry") "telemetry schema must be declared")
      (assert (string-contains? src "(:schema :id decision") "decision schema must be declared")
      (assert (string-contains? src "(:schema :id intent") "intent schema must be declared")
      (assert (string-contains? src "(:schema :id principle") "principle schema must be declared")
      (assert (string-contains? src "(:schema :id recipe") "recipe schema must be declared")
      (assert (string-contains? src "(:schema :id component") "component schema must be declared")
      (assert (string-contains? src "(:schema :id task") "task schema must be declared")
      (assert (string-contains? src "(:schema :id phase") "phase schema must be declared")
      (assert (string-contains? src "(:schema :id plan") "plan schema must be declared")
      true)))

(df test-three-cognitive-tiers-declared [] -> Bool
  :d "Verifies that Tier Alpha, Tier Beta, and Tier Gamma are declared"
  (let [(res (file-read "asl/grammar/records.asn"))]
    (assert (= (.-_tag res) "ok") "records.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "(:tier :id alpha") "Tier Alpha must be declared")
      (assert (string-contains? src "(:tier :id beta") "Tier Beta must be declared")
      (assert (string-contains? src "(:tier :id gamma") "Tier Gamma must be declared")
      true)))

(df test-error-taxonomy-declared [] -> Bool
  :d "Verifies that the error taxonomy covers schema, concurrency, and integrity codes"
  (let [(res (file-read "asl/grammar/records.asn"))]
    (assert (= (.-_tag res) "ok") "records.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "E_SCHEMA_MISSING_FIELD") "missing field error code")
      (assert (string-contains? src "E_SCHEMA_TYPE_MISMATCH") "type mismatch error code")
      (assert (string-contains? src "E_STORE_LOCK_TIMEOUT") "lock timeout error code")
      (assert (string-contains? src "E_STORE_ATOMIC_RENAME") "atomic rename error code")
      (assert (string-contains? src "E_INTEGRITY_IMMUTABLE_FIELD") "immutable field error code")
      (assert (string-contains? src "E_INTEGRITY_DAG_CYCLE") "dag cycle error code")
      (assert (string-contains? src "E_INTEGRITY_QUARANTINE_VIOLATION") "quarantine violation error code")
      true)))

(df test-blamed-receipt-schema-bounded [] -> Bool
  :d "Verifies blamed rejection receipt schema and token caps"
  (let [(res (file-read "asl/grammar/records.asn"))]
    (assert (= (.-_tag res) "ok") "records.asn must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":tokensCap 80") "blamed receipt must cap tokens at 80")
      (assert (string-contains? src "(:reject :code <str> :field <sym> :expected <sym> :got <val> :summary <str>)")
              "blamed receipt format declared")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48401 acceptance assertions"
  (let [(r1 (test-records-grammar-exists))
        (r2 (test-eleven-record-schemas-declared))
        (r3 (test-three-cognitive-tiers-declared))
        (r4 (test-error-taxonomy-declared))
        (r5 (test-blamed-receipt-schema-bounded))]
    (assert (and r1 (and r2 (and r3 (and r4 r5)))) "All Task48401 checks must pass")
    true))
