# How to compose an example

An example in this repository is never illustration. It is the artefact that decides whether a
claim is true, whether a capability exists, and whether a model can produce the language at all.
Three kinds exist and they are not interchangeable.

| kind | answers | lives in | fails when |
|---|---|---|---|
| **acceptance fixture** | did this task do what it said | `tests/acceptance/d81/TaskNNNNN.asl` | the task is not done |
| **capability probe** | does this operation actually work | `tests/probes/` | the operation lies or is absent |
| **emission case** | can a model write this correctly | `asl/bench/emission/` | the model produces malformed or unbound output |

## The rule that governs all three

An example that cannot fail proves nothing. Before an example is accepted, invert one assertion
and confirm a non-zero exit. If the inverted example still passes, the example is vacuous and the
original result meant nothing. This is the single check that separates an example from decoration,
and it is cheap.

Measured reason to insist: a test suite in this corpus printed a clean line while executing zero
assertions, and a gate reported a ratio it never computed.

## Acceptance fixtures

One per task, named for the task. The fixture asserts the behaviour the task promised, not the
implementation it happens to use, so a correct reimplementation still passes.

```
(module tests/acceptance/d81/TaskNNNNN
  :d "Acceptance fixture for TaskNNNNN: <the promise, in one sentence>."
  :x [run-tests]
  :i [(<module under test> :a m)])

(define TestPromiseHolds []
  :d "<what specific observable establishes the promise>"
  (assert (= <expected> (m/<operation> <input>))))

(define TestPromiseFailsWhenItShould []
  :d "<the condition the task said would be rejected>"
  (refute (m/<operation> <the input that must be rejected>)))
```

Write the negative case first. A fixture with only positive cases passes on a stub that returns
the expected constant, and this corpus contains functions whose body is a bare constant.

**Coverage today: 2 fixtures for 139 tasks.** Every task gate calls `SuperviseGate.sh`, which
exits 3 when the fixture is missing, so a task without a fixture cannot be accepted at all.

## Capability probes

A probe invokes an operation and reads the **result**, never the status. It is written to fail
loudly when the operation answers a different question than the one asked.

```
(define TestGrepAnswersTheQuestionAsked []
  :d "grep for a symbol in one directory returns matches for that symbol in that directory"
  (let ([r (rpc-grep "escape-asn-str" "asl/packages/asl-text/src")])
    (assert (all-matches-contain? r "escape-asn-str"))
    (assert (all-paths-under? r "asl/packages/asl-text/src"))))
```

Measured reason this shape exists: `:grep` currently returns `:status "ok"` together with 319
files matching a default glob, having ignored both arguments. A probe asserting only on status
would pass.

Probe every operation a rule or instruction surface names. Seven commands named as the priority
toolchain do not exist.

## Emission cases

These measure the language rather than the code: can a model write a correct form. Each case is a
task statement plus a checker, and the recorded outcome is a rate, not a pass.

```
(:emissionCase
  :id "EC001"
  :prompt "<the task, stated as it would be given>"
  :checks [:parses :binds :assertionsExecute :assertionsPass]
  :recordPerModel true
  :variant "<which language variant this run used>")
```

A case is useful only if two language variants can produce different rates on it. A case every
model passes and a case every model fails both measure nothing; keep them only as anchors.

## Composing a set

1. **One example per claim, not per file.** A claim without an example is a claim; a file without
   an example may be fine.
2. **Negative before positive.** The negative case is what has power.
3. **Bound it.** An example longer than a screen is testing several things and will fail for a
   reason nobody reads.
4. **Name the observable, not the intent.** `TestUnresolvedImportNamesTheImportingFile` beats
   `TestImportsWork`.
5. **No shared mutable fixture state.** Examples run in parallel.
6. **Real inputs.** Use a value from the corpus, not `"foo"`. A real input finds real defects.
7. **Record the measurement, not the verdict.** Assertions executed, exit code, and what was
   compared.

## Review checklist

- [ ] Inverting one assertion produces a non-zero exit
- [ ] A stub returning a constant fails at least one case
- [ ] Every operation is checked on its result, never on its status
- [ ] The example names the observable in its title
- [ ] No case depends on another case having run
- [ ] Assertions executed is greater than zero and is reported

---

# Worked example: a scout over a package

The scout's problem is that the enumeration is larger than the attention that must survive it.
A package has 40 files; by file 25 the reason file 3 mattered is gone. The fix is not a bigger
context, it is to stop holding the list.

## 1. Open a scope and record the conditions, before looking at anything

The first note is written before any file is read, because it is the thing most likely to be lost
and the thing whose loss is most expensive: what was asked, what counts as done, and why.

```
(:note :scope :task
  :task      "Assess asl-codec for duplicated helpers"
  :asked     "Find helpers defined here that belong to asl-text under D34"
  :expected  "A list of name, path, line, and the canonical owner, with nothing repaired"
  :notRepair "Explicitly out of scope: no edits, this is an assessment")
```

Everything after this is recoverable from the tree. This is not.

## 2. Enumerate into the worklist, not into the reply

```
asl note worklist create --scope task --intent read asl/packages/asl-codec/src/**.asl
→ worklist wl-7f3a: 23 entries, all pending
```

The list now lives outside the model. It survives the session, a crash, and a handoff to another
agent. The scout holds none of it.

## 3. Walk by cursor in bounded batches

```
asl note worklist next wl-7f3a --batch 5
→ entries 1-5 of 23
```

Batch size is a judgement, not a constant: outlines take a larger batch than full reads. After
each batch the scout marks what it did and writes only what it found — the scalar fact, not the
file.

```
(:mark  "csv-transpile.asl" :done
        :found "defines estimate-tokens at line 20, canonical owner asl-text")
(:mark  "placement.asl" :skipped :reason "no helper definitions, only dispatch")
```

`skipped` requires a reason. Without that requirement a worklist is drained by marking rather
than by working, which is the failure mode of every checklist.

## 4. Findings and detours go to the same place

A detour discovered mid-walk is enqueued, not followed. Following it is how the walk is lost.

```
(:note :scope :task :kind :finding
       :fact "sh-transpile.asl imports asl-text/escape at line 12 and redefines escape-sh-arg at 35")
(:note :scope :epic :kind :todo
       :fact "The import is declared and shadowed; check whether resolution silently dropped it")
```

The step-scoped note dies with the step. The epic-scoped one is what a later session inherits.

## 5. Close the scope

Closing promotes what is still true and retires the rest. The result is the deliverable; the
walk that produced it is gone, which is correct.

## What this changes, and what is not yet known

The scout holds at any moment: the conditions note, the current batch of five, and the cursor.
It does not hold 23 paths, 18 completed marks, or the reason file 3 mattered.

Measured here: the ninetieth percentile distance from a binding to its use is 232 lines and
11.7% of uses are beyond 200, so a retrieved slice frequently arrives without what defines it.
That is the mechanism the notes are meant to defeat.

**Whether it works is not yet measured.** Fewer hallucinations and better attention are the
hypothesis, not the finding, and note keeping costs tool calls that a single-pass read does not.
Task46506 runs the same fixed task set with the memory surface available and withheld, counting
unsupported claims, dropped steps, files re-read, and tasks completed. A null result is a valid
outcome and is recorded as one.

## Scenario Matrix Doctrine (Task46702, ADR-0081)

Happy-path tests are insufficient to guarantee tool reliability; silent degradations occur when edge conditions are never tested. Core tools must be subjected to a systematic scenario matrix covering:

1. **Absent / Non-Existent Target Files (`test-missing-file`)**: Must fail cleanly with explicit error code (`:ERR_FILE_NOT_FOUND`) rather than returning empty success or crashing.
2. **Directory Traversal Refusal (`test-path-traversal`)**: Paths attempting to escape the workspace boundary via parent segments or foreign roots must be detected and rejected with `:ERR_BOUNDARY_VIOLATION`.
3. **Empty Query / Pattern String (`test-empty-pattern`)**: Empty queries must either reject cleanly with `:ERR_MISSING_ARG` or produce an empty match set without unbounded allocation.
4. **Bounded Output Truncation (`test-bounded-output`)**: Tools producing stream or process output must enforce hard upper limits (`spool-truncate` via `RingBuffer` and `DiskSpool`) and explicitly report truncation status.
5. **Normal Case Verification (`test-normal-search`)**: Verify standard operational accuracy on valid inputs against ground truth files.

