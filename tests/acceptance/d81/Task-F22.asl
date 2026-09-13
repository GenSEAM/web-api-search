(module tests/acceptance/d81/Task-F22
  :d "Acceptance fixture for Task-F22: Implement Delimiter Stack in Parser Balance Checker under ADR-0081."
  :x [RunTests
      TestInterleavedDelimitersFlaggedUnbalanced
      TestProperlyNestedDelimiters
      TestStringsAndEscapesIgnored
      TestUnclosedAndExtraClosers
      TestBalanceDelimiters
      TestTaskF22GroundedInPhaseFINSEL]
  :i [(asl-parser/balance :a bal)])

(df TestInterleavedDelimitersFlaggedUnbalanced [] -> Bool
  :d "Verifies check-delimiter-balance rejects interleaved delimiters like ([)]"
  (let [(res1 (bal/check-delimiter-balance "([)]"))
        (res2 (bal/check-delimiter-balance "[(])"))
        (res3 (bal/check-delimiter-balance "{(})"))
        (res4 (bal/check-delimiter-balance "{[(]})"))
        (res5 (bal/check-delimiter-balance "(defn foo [x)] (+ x 1)"))]
    (assert (not (.-balanced res1)) "Interleaved ([)] must be unbalanced")
    (assert (not (bal/is-delimiter-balanced? "([)]")) "is-delimiter-balanced? on ([)] must return false")
    (assert (not (.-balanced res2)) "Interleaved [(]) must be unbalanced")
    (assert (not (bal/is-delimiter-balanced? "[(])")) "is-delimiter-balanced? on [(]) must return false")
    (assert (not (.-balanced res3)) "Interleaved {(}) must be unbalanced")
    (assert (not (.-balanced res4)) "Interleaved {[(]}) must be unbalanced")
    (assert (not (.-balanced res5)) "Interleaved definition syntax must be unbalanced")
    true))

(df TestProperlyNestedDelimiters [] -> Bool
  :d "Verifies properly nested delimiters pass balance checks"
  (let [(res1 (bal/check-delimiter-balance "(defn foo [x] (+ x 1))"))
        (res2 (bal/check-delimiter-balance "([{}])"))
        (res3 (bal/check-delimiter-balance "{[()]}"))
        (res4 (bal/check-delimiter-balance "(let [(x [1 2 3])] { :val (+ (list-head x) 1) })"))]
    (assert (.-balanced res1) "Standard S-expression must be balanced")
    (assert (.-balanced res2) "Nested ([{}]) must be balanced")
    (assert (.-balanced res3) "Nested {[()]} must be balanced")
    (assert (.-balanced res4) "Complex nested S-expression must be balanced")
    (assert (= (.-open-parens res1) 0) "Open parens must be zero")
    (assert (= (.-open-brackets res1) 0) "Open brackets must be zero")
    (assert (= (.-open-braces res1) 0) "Open braces must be zero")
    true))

(df TestStringsAndEscapesIgnored [] -> Bool
  :d "Verifies that delimiters inside string literals and escaped quotes are ignored"
  (let [(res1 (bal/check-delimiter-balance "(println \"([)]\")"))
        (res2 (bal/check-delimiter-balance "(let [(s \"(\\\")\")] 42)"))]
    (assert (.-balanced res1) "Interleaved delimiters inside string literal must be ignored")
    (assert (.-balanced res2) "Escaped quotes inside string literal must be preserved")
    true))

(df TestUnclosedAndExtraClosers [] -> Bool
  :d "Verifies unclosed openers and premature closers are flagged"
  (let [(unclosed (bal/check-delimiter-balance "((["))
        (extra-close (bal/check-delimiter-balance "]))"))]
    (assert (not (.-balanced unclosed)) "Unclosed openers must be unbalanced")
    (assert (> (.-open-parens unclosed) 0) "Open parens count must be greater than 0")
    (assert (> (.-open-brackets unclosed) 0) "Open brackets count must be greater than 0")
    (assert (not (.-balanced extra-close)) "Extra closers must be unbalanced")
    true))

(df TestBalanceDelimiters [] -> Bool
  :d "Verifies balance-delimiters utility functions"
  (let [(unclosed "(foo [bar]")
        (balanced (bal/balance-delimiters unclosed))
        (count (bal/count-unclosed-parens unclosed))]
    (assert (= count 1) "Unclosed paren count must be 1")
    (assert (= balanced "(foo [bar])") "Must balance unclosed paren")
    true))

(df TestTaskF22GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies Task-F22 registration in PhaseFINSELRemediation.asn"
  (let [(res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (mt res
      ((ok content)
       (let [(has-id (string-contains? content ":id \"Task-F22\""))
             (has-title (string-contains? content ":title \"Implement Delimiter Stack in Parser Balance Checker\""))]
         (assert has-id "Task-F22 must be registered in PhaseFINSELRemediation.asn")
         (assert has-title "Task-F22 title must match PhaseFINSELRemediation.asn")
         true))
      ((err e)
       (assert false "PhaseFINSELRemediation.asn must be readable")
       false))))

(df RunTests [] -> Bool
  :d "Acceptance test runner for Task-F22"
  (let [(t1 (TestInterleavedDelimitersFlaggedUnbalanced))
        (t2 (TestProperlyNestedDelimiters))
        (t3 (TestStringsAndEscapesIgnored))
        (t4 (TestUnclosedAndExtraClosers))
        (t5 (TestBalanceDelimiters))
        (t6 (TestTaskF22GroundedInPhaseFINSEL))]
    (and t1 (and t2 (and t3 (and t4 (and t5 t6)))))))
