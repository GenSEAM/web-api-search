(module tests/acceptance/d81/Task-F26
  :d "Acceptance fixture for Task-F26: Replace Line-Based S-Expression Splitting in AST Merge under ADR-0081."
  :x [RunTests
      TestMultiLineFormWithNestedSubformsNotShredded
      TestMultiLineModuleAndFunctionsMergeCleanly
      TestMultipleTopLevelFormsPreserved
      TestTaskF26GroundedInPhaseFINSEL]
  :i [(asl-mem/ast-merge :a am)])

(df TestMultiLineFormWithNestedSubformsNotShredded [] -> Bool
  :d "Verifies parse-homoiconic-forms does not shred multi-line forms with nested subforms starting with ("
  (let [(code (str "(df computeTotal [(items (List I64))] -> I64\n"
                   "(let [(tax 10)\n"
                   "      (sub 100)]\n"
                   "  (+ sub tax)))"))
        (forms (am/parse-homoiconic-forms code))]
    (assert (= (list-length forms) 1) "Multi-line function with nested let must parse as exactly 1 form")
    (let [(default-form (am/HomoiconicForm :symbol-id "" :kind "" :raw-form "" :hash ""))
          (f (option-or (list-head forms) default-form))]
      (assert (= (.-symbol-id f) "computeTotal") "Symbol ID must be computeTotal")
      (assert (= (.-kind f) "df") "Kind must be df")
      (assert (string-contains? (.-raw-form f) "tax 10") "Raw form must contain nested let body")
      (assert (string-contains? (.-raw-form f) "(+ sub tax)") "Raw form must contain return expression")
      true)))

(df TestMultiLineModuleAndFunctionsMergeCleanly [] -> Bool
  :d "Verifies universal-ast-3way-merge merges multi-line functions with subforms without AST shredding"
  (let [(base-code (str "(module app :x [f1 f2])\n\n"
                        "(df f1 [(x I64)] -> I64\n"
                        "(let [(a 1)]\n"
                        "  (+ x a)))\n\n"
                        "(df f2 [(y I64)] -> I64\n"
                        "(let [(b 2)]\n"
                        "  (* y b)))"))
        (branch-a (str "(module app :x [f1 f2])\n\n"
                       "(df f1 [(x I64)] -> I64\n"
                       "(let [(a 999)]\n"
                       "  (+ x a)))\n\n"
                       "(df f2 [(y I64)] -> I64\n"
                       "(let [(b 2)]\n"
                       "  (* y b)))"))
        (branch-b (str "(module app :x [f1 f2])\n\n"
                       "(df f1 [(x I64)] -> I64\n"
                       "(let [(a 1)]\n"
                       "  (+ x a)))\n\n"
                       "(df f2 [(y I64)] -> I64\n"
                       "(let [(b 888)]\n"
                       "  (* y b)))"))
        (res (am/universal-ast-3way-merge base-code branch-a branch-b))]
    (assert (.-clean res) "Disjoint multi-line function edits must merge cleanly")
    (assert (= (list-length (.-conflicts res)) 0) "Must report 0 conflicts")
    (assert (= (.-merged-forms-count res) 3) "Must preserve exactly 3 forms (module, f1, f2) without shredding")
    (assert (string-contains? (.-merged-content res) "999") "Merged content must contain branch A update")
    (assert (string-contains? (.-merged-content res) "888") "Merged content must contain branch B update")
    true))

(df TestMultipleTopLevelFormsPreserved [] -> Bool
  :d "Verifies multiple top-level forms with nested definitions maintain accurate count and boundaries"
  (let [(code (str "(:task :id \"T1\" :state :ready)\n\n"
                   "(df helper [(x Str)] -> Str\n"
                   "(if (string-empty? x)\n"
                   "  \"none\"\n"
                   "  x))\n\n"
                   "(:msg :id \"M1\" :body \"hello\")"))
        (forms (am/parse-homoiconic-forms code))]
    (assert (= (list-length forms) 3) "Must parse exactly 3 top-level forms")
    true))

(df TestTaskF26GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F26 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F26\""))
             (has-title (string-contains? content ":title \"Replace Line-Based S-Expression Splitting in AST Merge\""))]
         (assert has-id "Task-F26 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F26 title must match PhaseFINSELRemediation.asn")
         true))
      ((err _)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F26"
  (let [(t1 (TestMultiLineFormWithNestedSubformsNotShredded))
        (t2 (TestMultiLineModuleAndFunctionsMergeCleanly))
        (t3 (TestMultipleTopLevelFormsPreserved))
        (t4 (TestTaskF26GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 t4)))))
