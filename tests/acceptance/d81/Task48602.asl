(module tests/acceptance/d81/Task48602
  :d "Acceptance fixture for Task48602: Scanner tests."
  :x [runTests]
  :i [(aslMesh/scanner :a scan)
      (asl-parser/reader :a rd)])

(df testScannerVacuous [] -> Bool
  (let [(vacuousSrc "(df test [] -> Bool\n  (let [(r (file-read \"f.txt\"))]\n    (assert (string-contains? r \"foo\") \"foo\")))")
        (defects (scan/check_vacuous_tests vacuousSrc "test.asl"))]
    (assert (= (list-length defects) 1) "One vacuous defect found")
    (assert (= (option-or (map-get (option-or (list-get defects 0) map-empty) :defectId) "") "def-vacuous-1") "Defect ID matches")
    (refute (= (list-length defects) 0) "Defects list is not empty")
    true))

(df testScannerAstVisitor [] -> Bool
  (let [(atom (rd/makeAtom "foo"))
        (lst (rd/makeList (list atom)))
        (res (scan/ast_visitor lst (fn [(n rd/SExpr)] -> (List Map) (list {:visited 1}))))]
    (assert (= (list-length res) 2) "Visited list and atom")
    (refute (= (list-length res) 0) "Not empty")
    true))

(df runTests [] -> Bool
  (let [(r1 (testScannerVacuous))
        (r2 (testScannerAstVisitor))]
    (assert (and r1 r2) "All scanner tests pass")
    true))
