(module tests/acceptance/d81/Task50401
  :d "Acceptance fixture for Task 50401: Eliminate range 5000 and implement bounded metavariable substitution (End-to-End)"
  :x [buildVarChain
      testResolveNonVariable
      testResolveTransitiveChain
      testBoundedMetavariableCutoff
      testResolveVarSubstRecFuel
      testResolveCycleTermination
      testCheckerUnifySuiteExecution
      RunTests]
  :i [(../../../asl/packages/asl-checker/src/types :a ty)
      (../../../asl/packages/asl-checker/src/unify :a u)])

(df buildVarChain [(n Int64) (target ty/Type)] -> (Map Int64 ty/Type)
  :d "Constructs a substitution chain v1 -> v2 -> ... -> vn -> target"
  (fold (fn [(s (Map Int64 ty/Type)) (i Int64)] -> (Map Int64 ty/Type)
          (if (= i n)
            (map-set s i target)
            (map-set s i (ty/tyVar (+ i 1) "any"))))
        (map-empty)
        (range 1 (+ n 1))))

(df testResolveNonVariable [] -> Bool
  :d "Verifies direct return on non-variable types"
  (let [(i64 (ty/tyCon "Int64" (list) (none) (none)))
        (strTy (ty/tyCon "String" (list) (none) (none)))
        (s0 (map-empty))]
    (assert (u/typeEqual? (u/resolveVarSubst s0 i64) i64) "Direct return on Int64 type")
    (refute (u/typeEqual? (u/resolveVarSubst s0 i64) strTy) "Int64 does not resolve to String")
    true))

(df testResolveTransitiveChain [] -> Bool
  :d "Verifies multi-hop transitive metavariable chain resolution"
  (let [(i64 (ty/tyCon "Int64" (list) (none) (none)))
        (strTy (ty/tyCon "String" (list) (none) (none)))
        (v1 (ty/tyVar 1 "any"))
        (v2 (ty/tyVar 2 "any"))
        (v3 (ty/tyVar 3 "any"))
        (s1 (map-set (map-empty) 1 v2))
        (s2 (map-set s1 2 v3))
        (s3 (map-set s2 3 i64))]
    (assert (u/typeEqual? (u/resolveVarSubst s3 v1) i64) "v1 resolves through v2 and v3 to Int64")
    (refute (u/typeEqual? (u/resolveVarSubst s3 v1) strTy) "v1 does not resolve to String")
    (refute (u/typeEqual? (u/resolveVarSubst s3 v1) v2) "v1 does not stop at intermediate variable v2")
    (refute (u/typeEqual? (u/resolveVarSubst s3 v1) v3) "v1 does not stop at intermediate variable v3")
    true))

(df testBoundedMetavariableCutoff [] -> Bool
  :d "Verifies that resolveVarSubst enforces 100-step fuel bounds without range 5000 traversal"
  (let [(i64 (ty/tyCon "Int64" (list) (none) (none)))
        (v1 (ty/tyVar 1 "any"))
        (v101 (ty/tyVar 101 "any"))
        (s150 (buildVarChain 150 i64))
        (s50 (buildVarChain 50 i64))
        (res150 (u/resolveVarSubst s150 v1))
        (res50 (u/resolveVarSubst s50 v1))]
    (assert (u/typeEqual? res50 i64) "50-hop chain resolves fully to Int64 within 100 fuel")
    (refute (u/typeEqual? res50 v1) "50-hop chain does not stop at v1")
    (assert (u/typeEqual? res150 v101) "150-hop chain is strictly bounded at 100 fuel steps, stopping at v101")
    (refute (u/typeEqual? res150 i64) "150-hop chain must not run 5000 steps to reach Int64")
    true))

(df testResolveVarSubstRecFuel [] -> Bool
  :d "Verifies bounded fuel behavior in resolveVarSubstRec"
  (let [(i64 (ty/tyCon "Int64" (list) (none) (none)))
        (v1 (ty/tyVar 1 "any"))
        (v6 (ty/tyVar 6 "any"))
        (s10 (buildVarChain 10 i64))]
    (assert (u/typeEqual? (u/resolveVarSubstRec s10 v1 100) i64) "resolveVarSubstRec with positive fuel resolves target")
    (assert (u/typeEqual? (u/resolveVarSubstRec s10 v1 0) v1) "resolveVarSubstRec with 0 fuel returns current type without stepping")
    (refute (u/typeEqual? (u/resolveVarSubstRec s10 v1 0) i64) "0 fuel must not resolve substitution")
    (assert (u/typeEqual? (u/resolveVarSubstRec s10 v1 5) v6) "resolveVarSubstRec with 5 fuel stops at v6")
    (refute (u/typeEqual? (u/resolveVarSubstRec s10 v1 5) i64) "5 fuel must not reach terminal Int64 on 10-hop chain")
    true))

(df testResolveCycleTermination [] -> Bool
  :d "Verifies termination on self-cycles without stack overflow"
  (let [(v1 (ty/tyVar 1 "any"))
        (v2 (ty/tyVar 2 "any"))
        (i64 (ty/tyCon "Int64" (list) (none) (none)))
        (sSelf (map-set (map-empty) 1 v1))
        (sCycle (map-set (map-set (map-empty) 1 v2) 2 v1))]
    (assert (u/typeEqual? (u/resolveVarSubst sSelf v1) v1) "Self cycle 1 -> 1 terminates with v1")
    (refute (u/typeEqual? (u/resolveVarSubst sSelf v1) i64) "Self cycle 1 -> 1 does not produce unrelated concrete type")
    (let [(resCycle (u/resolveVarSubst sCycle v1))]
      (assert (or (u/typeEqual? resCycle v1) (u/typeEqual? resCycle v2)) "Mutual cycle 1 -> 2 -> 1 terminates safely within fuel bounds")
      (refute (u/typeEqual? resCycle i64) "Mutual cycle 1 -> 2 -> 1 does not produce unrelated concrete type"))
    true))

(df testCheckerUnifySuiteExecution [] -> Bool
  :d "Verifies end-to-end execution of checker package unify unit test suite"
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-checker/tests/unify_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Checker unify_test suite must exit 0")
    (refute (!= code 0) "Checker unify_test suite must not fail")
    (assert (string-contains? out "assertion(s) executed") "unify_test must report assertions")
    (refute (string-contains? out " 0 assertion(s) executed") "unify_test assertions must be non-zero")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50401 end-to-end acceptance tests"
  (do
    (assert (testResolveNonVariable) "testResolveNonVariable must pass")
    (assert (testResolveTransitiveChain) "testResolveTransitiveChain must pass")
    (assert (testBoundedMetavariableCutoff) "testBoundedMetavariableCutoff must pass")
    (assert (testResolveVarSubstRecFuel) "testResolveVarSubstRecFuel must pass")
    (assert (testResolveCycleTermination) "testResolveCycleTermination must pass")
    (assert (testCheckerUnifySuiteExecution) "testCheckerUnifySuiteExecution must pass")
    true))
