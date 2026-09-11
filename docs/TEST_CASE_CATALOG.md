# Test Case Catalog

Purpose: an implementer writes tests by picking case kinds from this table, not by inventing them. Every area in Phase443 declares which kinds it needs. A suite that covers only kind 1 is rejected at review.

Rules that bind every case:
- One behaviour per `(df Test… [] -> Bool)`. The function name says the behaviour, not the function under test.
- Every `assert` carries a message that states the expectation, not the code.
- A case must be able to fail. Before committing, invert its assertion and confirm the suite exits non-zero. If it still passes, the case is vacuous and does not count.
- Never assert a property of a literal you wrote two lines above. `(let [(x 0.75)] (assert (>= x 0.75)))` measures nothing.
- Never write `(assert true)`.

## The twelve kinds

| # | Kind | Catches | Required for |
|---|---|---|---|
| 1 | Happy path | nothing on its own; it is the baseline | every area |
| 2 | Boundary | off-by-one, empty, single element, max | every function taking a size, index or collection |
| 3 | Empty and absent | empty string vs missing value confusion | every function taking Str or Option |
| 4 | Malformed input | crashes and silent acceptance of garbage | every parser, decoder, path or arg handler |
| 5 | Negative control | the function accepting what it must reject | every validator, gate, boundary check |
| 6 | Error propagation | a failure reported as success | every op returning a status or exit code |
| 7 | Round trip | lossy encode/decode | every escape, codec, serializer |
| 8 | Idempotence | double application corrupting state | every normalizer, renderer, flush, discard |
| 9 | Metamorphic | equivalent inputs giving different answers | every search, sort, ranking, path resolver |
| 10 | Adversarial | injection, traversal, prefix collision | every path, shell arg, query, external input |
| 11 | Concurrency | lost update, stale read | every lease, buffer, ledger write |
| 12 | Resource bound | truncation reported as success, hang | every read, write, exec, index build |

## Worked examples

Each block is a template. Replace the module and symbols; keep the shape.

### 1 + 2 + 3 — happy, boundary, empty, on one function

```asl
(df TestEscapeShArgShapes [] -> Bool
  :d "Escaping covers empty, simple and quote-bearing arguments."
  (let [(empty-arg (esc/escape-sh-arg ""))
        (simple-arg (esc/escape-sh-arg "status"))
        (quoted-arg (esc/escape-sh-arg "don't stop"))]
    (assert (= empty-arg "''") "Empty argument must become a quoted empty string, not an empty result")
    (assert (= simple-arg "'status'") "A simple argument must be wrapped, not passed through")
    (assert (string-contains? quoted-arg "'\\''") "An embedded single quote must be closed, escaped and reopened")
    true))
```
Why it is not vacuous: each expected value differs from the input, so a pass-through implementation fails all three.

### 5 + 10 — negative control and adversarial, on a boundary check

```asl
(df TestSafePathRejectsEscapes [] -> Bool
  :d "Path validation rejects traversal, sibling prefixes and symlink escapes."
  (assert (not (safe-path? "/ws/asex" "/ws/asex_other/secret.txt"))
          "A sibling directory sharing the workspace prefix must be rejected")
  (assert (not (safe-path? "/ws/asex" "../../etc/passwd"))
          "Traversal outside the workspace must be rejected after canonicalisation")
  (assert (safe-path? "/ws/asex" "mem/src/../README.md")
          "A relative path whose canonical form stays inside must be accepted")
  true)
```
Why it matters here: the third assertion is the one the current C implementation fails. A suite with only the first two would pass on a wrong implementation.

### 6 — error propagation

```asl
(df TestRunReportsRealExit [] -> Bool
  :d "Supervised execution reports the command exit status, not the pipeline status."
  (let [(res (rpc/run "exit 3"))]
    (assert (= (.-exit res) 3) "Exit status 3 must be reported as 3")
    (assert (not (= (.-exit res) 0)) "A failing command must never be reported as success")
    true))
```

### 7 + 8 — round trip and idempotence

```asl
(df TestAsnEscapeRoundTripIsIdempotent [] -> Bool
  :d "Escape then unescape restores the input, and escaping twice is not the same as once."
  (let [(raw "line\nwith \"quotes\" and \\slash")
        (once (esc/escape-asn-str raw))
        (twice (esc/escape-asn-str once))]
    (assert (= (esc/unescape-asn-str once) raw) "One escape then unescape must restore the exact input")
    (assert (not (= once twice)) "Double escaping must be observable, so callers cannot escape twice by accident")
    (assert (= (esc/unescape-asn-str (esc/unescape-asn-str twice)) raw) "Two unescapes must undo two escapes")
    true))
```

### 9 — metamorphic

```asl
(df TestBm25RankingIsOrderInvariant [] -> Bool
  :d "Ranking depends on content, not on document insertion order."
  (let [(docs-a (list "alpha beta" "beta gamma" "gamma delta"))
        (docs-b (list "gamma delta" "alpha beta" "beta gamma"))
        (top-a (bm/top-hit (bm/make-index docs-a) "beta"))
        (top-b (bm/top-hit (bm/make-index docs-b) "beta"))]
    (assert (= top-a top-b) "The same query over the same documents must rank identically regardless of input order")
    true))
```

### 11 — concurrency

```asl
(df TestLeaseRejectsStaleWrite [] -> Bool
  :d "A write is refused when the file changed after the claim."
  (let [(claim (vfs/claim "a.asl"))
        (_ (vfs/external-touch "a.asl"))
        (res (vfs/write-with-claim claim "new"))]
    (assert (= (.-error-code res) ":ERR_STALE_FILE") "A write after an external change must be refused with ERR_STALE_FILE")
    (assert (= (vfs/read "a.asl") (vfs/external-content "a.asl")) "The refused write must leave the file untouched")
    true))
```

### 12 — resource bound

```asl
(df TestWriteRefusesTruncation [] -> Bool
  :d "Content larger than the buffer is an error, never a truncated success."
  (let [(big (string-repeat "a" 5000))
        (res (rpc/write "probe.txt" big))]
    (assert (not (= (.-status res) "ok")) "Oversized content must not report success")
    (assert (= (.-error-code res) ":ERR_CONTENT_TOO_LARGE") "Truncation must be an explicit error")
    true))
```
Why this one exists: measured 2026-09-11, a 5000-byte write returned `:status ok :bytes 1023` and wrote 1023 bytes.

## Review checklist

A suite is accepted when all of these hold, and each is mechanically checkable:

1. Every exported symbol of the module under test is named in at least one case.
2. The suite declares at least four distinct kinds from the table, and at least one of kinds 5, 6 or 10.
3. Every assertion carries a message, and no message is a restatement of the expression.
4. Inverting any single assertion makes the suite exit non-zero (run the inversion, record the exit code).
5. No assertion compares a literal with a literal bound in the same `let`.
6. The suite executes: its reported executed-assertion count equals its declared count.
