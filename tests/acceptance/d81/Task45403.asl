(module tests/acceptance/d81/Task45403
  :d "Acceptance fixture for Task45403: builtins, case, and match behavioural verification under ADR-0081."
  :x [runTests
      testCaseBranchingAndLazyEvaluation
      testMatchFormsAndBindings
      testPairAndTupleBuiltins
      testFoldLeftAssociative
      testListAndMapBuiltins
      testStringBuiltins]
  :i [])

(dfe TestColor
  (c ColorRed)
  (c ColorGreen)
  (c ColorBlue))

(df testCaseBranchingAndLazyEvaluation [] -> Bool
  :d "Verifies case branching on value and strict lazy evaluation of unselected branches"
  (let [(v1 (case 2
              (1 "one")
              (2 "two")
              (_ "other")))
        (v2 (case 1
              (1 "lazy-ok")
              (2 (assert false "case branch 2 must not evaluate"))
              (_ (assert false "case default must not evaluate"))))
        (v3 (case 99
              (1 (assert false "case branch 1 must not evaluate"))
              (2 (assert false "case branch 2 must not evaluate"))
              (_ "fallback-ok")))]
    (assert (= v1 "two") "case must select matching branch")
    (assert (= v2 "lazy-ok") "case lazy evaluation must not evaluate untaken branches")
    (assert (= v3 "fallback-ok") "case wildcard must match fallback")
    true))

(df testMatchFormsAndBindings [] -> Bool
  :d "Verifies match form on some, none, ok, err, enum variants, wildcard, and lazy evaluation"
  (let [(res1 (match (some 42)
                ((some v) (+ v 1))
                (none 0)))
        (res2 (match none
                ((some v) (assert false "none branch must not match some"))
                (none 10)))
        (res3 (match (ok "hello")
                ((ok s) (stringAppend s " world"))
                ((err e) (assert false "ok branch must not match err"))))
        (res4 (match (err "disk full")
                ((ok _) (assert false "err branch must not match ok"))
                ((err msg) msg)))
        (res5 (match (ColorGreen)
                ((ColorRed) (assert false "red branch must not match green"))
                ((ColorGreen) "green-ok")
                (_ (assert false "wildcard must not match green variant"))))
        (res6 (match 999
                (1 (assert false "branch 1 must not match 999"))
                (_ "wildcard-ok")))
        (res7 (match (some 100)
                ((some x) (* x 2))
                (none (assert false "match none branch must not evaluate"))))]
    (assert (= res1 43) "match some must extract bound variable")
    (assert (= res2 10) "match none must select none branch")
    (assert (= res3 "hello world") "match ok must extract bound variable")
    (assert (= res4 "disk full") "match err must extract bound error variable")
    (assert (= res5 "green-ok") "match enum variant must match constructor")
    (assert (= res6 "wildcard-ok") "match wildcard must catch unmatched value")
    (assert (= res7 200) "match lazy evaluation must not evaluate untaken branch")
    true))

(df testPairAndTupleBuiltins [] -> Bool
  :d "Verifies fst, snd, second, pair-first, and pair-second builtins"
  (let [(p (pair 10 20))
        (q (pair 100 200))
        (xs (list 1 2 3))]
    (assert (= (fst p) 10) "fst must return first element of pair")
    (assert (= (snd p) 20) "snd must return second element of pair")
    (assert (= (pairFirst q) 100) "pair-first must return first element of pair")
    (assert (= (pairSecond q) 200) "pair-second must return second element of pair")
    (assert (= (second xs) 2) "second must return second element of list")
    true))

(df testFoldLeftAssociative [] -> Bool
  :d "Verifies fold-left left-associative non-commutative reduction on list"
  (let [(diffLeft (foldLeft (fn [(acc Int64) (x Int64)] -> Int64 (- acc x))
                              100
                              (list 10 5 2)))]
    (assert (= diffLeft 83) "fold-left must evaluate left-associative ((100 - 10) - 5) - 2 = 83")
    true))

(df testListAndMapBuiltins [] -> Bool
  :d "Verifies list-take past bounds, list-first, list-last, count, nil?, and map-merge"
  (let [(xs (list 1 2 3))
        (takenPast (listTake xs 10))
        (takenTwo (listTake xs 2))
        (f (listFirst xs))
        (l (option-or (listLast xs) 0))
        (cnt (count xs))
        (m1 {:a 1 :b 2})
        (m2 {:b 3 :c 4})
        (merged (mapMerge m1 m2))]
    (assert (= (list-length takenPast) 3) "list-take past bounds must return full list")
    (assert (= (list-length takenTwo) 2) "list-take within bounds must return requested prefix")
    (assert (= f 1) "list-first must return first element")
    (assert (= l 3) "list-last must return last element")
    (assert (= cnt 3) "count must return element count")
    (assert (nil? nil) "nil? must return true for nil")
    (assert (not (nil? xs)) "nil? must return false for list")
    (assert (= (map-get merged :a) 1) "map-merge must retain key :a from parent")
    (assert (= (map-get merged :b) 3) "map-merge must override key :b from leaf")
    (assert (= (map-get merged :c) 4) "map-merge must include key :c from leaf")
    true))

(df testStringBuiltins [] -> Bool
  :d "Verifies string-trim and string-append builtins"
  (let [(trimmed (string-trim "  hello world  "))
        (appended (stringAppend "agent" "script"))]
    (assert (= trimmed "hello world") "string-trim must strip whitespace")
    (assert (= appended "agentscript") "string-append must concatenate strings")
    true))

(df runTests [] -> Bool
  :d "Executes all Task45403 acceptance test suites"
  (do
    (assert (testCaseBranchingAndLazyEvaluation) "test-case-branching-and-lazy-evaluation must pass")
    (assert (testMatchFormsAndBindings) "test-match-forms-and-bindings must pass")
    (assert (testPairAndTupleBuiltins) "test-pair-and-tuple-builtins must pass")
    (assert (testFoldLeftAssociative) "test-fold-left-associative must pass")
    (assert (testListAndMapBuiltins) "test-list-and-map-builtins must pass")
    (assert (testStringBuiltins) "test-string-builtins must pass")
    true))
