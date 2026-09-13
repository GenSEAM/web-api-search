(module tests/acceptance/d81/Task48701
  :d "Acceptance fixture for Task48701: Pure ASL Stage-2 Architecture Schema and IR Specification under D86."
  :x [run-tests
      test-stage2-grammar-exists
      test-stage2-grammar-schemas
      test-stage2-target-abi-contracts]
  :i [])

(df test-stage2-grammar-exists [] -> Bool
  :d "Verifies that asl/grammar/stage2.asn exists and is readable"
  (let [(res (file-read "asl/grammar/stage2.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/stage2.asn must exist")
    true))

(df test-stage2-grammar-schemas [] -> Bool
  :d "Verifies that stage2.asn declares core IR and binary section schemas"
  (let [(res (file-read "asl/grammar/stage2.asn"))]
    (assert (= (.-_tag res) "ok") "stage2.asn readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "stage2_ir_schema") "stage2_ir_schema concept declared")
      (assert (string-contains? src "target_abi_spec") "target_abi_spec concept declared")
      (assert (string-contains? src "ssaForm") "ssaForm schema declared")
      (assert (string-contains? src "binarySection") "binarySection schema declared")
      (assert (string-contains? src "stage2Architecture") "stage2Architecture schema declared")
      true)))

(df test-stage2-target-abi-contracts [] -> Bool
  :d "Verifies that stage2.asn defines Darwin ARM64 and Linux x86_64 target ABI definitions"
  (let [(res (file-read "asl/grammar/stage2.asn"))]
    (assert (= (.-_tag res) "ok") "stage2.asn readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "darwin-arm64") "darwin-arm64 target declared")
      (assert (string-contains? src "linux-x86_64") "linux-x86_64 target declared")
      (assert (string-contains? src ":pageZero") "pageZero layout specified")
      (assert (string-contains? src ":textSegment") "textSegment layout specified")
      (assert (string-contains? src ":dataSegment") "dataSegment layout specified")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48701 acceptance assertions"
  (let [(r1 (test-stage2-grammar-exists))
        (r2 (test-stage2-grammar-schemas))
        (r3 (test-stage2-target-abi-contracts))]
    (assert (and (and r1 r2) r3) "All Task48701 checks must pass")
    true))
