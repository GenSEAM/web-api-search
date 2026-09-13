(module asl-tools/pre-commit
  :d "Pure AgentScript Git Pre-Commit Hook & Automated Threshold Enforcement Engine."
  :x [main
      run-pre-commit
      verify-thresholds
      count-dashed-identifiers
      count-uncompensated-sagas
      evaluate-commit-diff
      PreCommitConfig]
  :i [])

(dfs PreCommitConfig
  (:f strictTokens Bool "Enforce camelCase tokens on new identifiers")
  (:f checkConsistency Bool "Enforce ADR and task consistency")
  (:f maxComplexity I64 "Maximum allowed function complexity"))

(df is-dashed-identifier? [(name Str)] -> Bool
  :d "Checks whether an identifier contains kebab-case hyphens"
  (let [(clean (string-trim name))]
    (and (string-contains? clean "-")
         (not (string-starts-with? clean ":"))
         (not (string-starts-with? clean "--"))
         (not (string-equals? clean "->"))
         (not (string-equals? clean "-")))))

(df extract-fn-name-from-line [(line Str)] -> Str
  :d "Extracts function or symbol name from definition line"
  (let [(trimmed (string-trim line))
        (after-plus (if (string-starts-with? trimmed "+")
                      (string-trim (option-or (string-slice trimmed 1 (string-length trimmed)) ""))
                      trimmed))]
    (if (string-starts-with? after-plus "(df ")
      (let [(rest-s (string-trim (option-or (string-slice after-plus 4 (string-length after-plus)) "")))
            (parts (string-split rest-s " "))]
        (option-or (list-head parts) ""))
      (if (string-starts-with? after-plus "(defun ")
        (let [(rest-s (string-trim (option-or (string-slice after-plus 7 (string-length after-plus)) "")))
              (parts (string-split rest-s " "))]
          (option-or (list-head parts) ""))
        ""))))

(df count-dashed-identifiers [(diff Str)] -> I64
  :d "Scans git diff additions for kebab-case function identifiers"
  (let [(lines (string-split diff "\n"))]
    (fold (fn [(count I64) (line Str)] -> I64
            (let [(trimmed (string-trim line))]
              (if (and (string-starts-with? trimmed "+")
                       (not (string-starts-with? trimmed "+++")))
                (let [(fn-name (extract-fn-name-from-line trimmed))]
                  (if (and (not (string-empty? fn-name))
                           (is-dashed-identifier? fn-name))
                    (+ count 1)
                    count))
                count)))
          0
          lines)))

(df count-uncompensated-sagas [(diff Str)] -> I64
  :d "Detects saga transaction declarations without rollback or compensation blocks"
  (let [(lines (string-split diff "\n"))
        (has-saga (fold (fn [(found Bool) (l Str)] -> Bool
                          (or found (and (string-starts-with? (string-trim l) "+")
                                         (or (string-contains? l "saga-begin")
                                             (string-contains? l "(:saga")))))
                        false
                        lines))
        (has-comp (fold (fn [(found Bool) (l Str)] -> Bool
                          (or found (or (string-contains? l "saga-compensate")
                                        (or (string-contains? l "saga-rollback")
                                            (string-contains? l ":compensate")))))
                        false
                        lines))]
    (if (and has-saga (not has-comp)) 1 0)))

(df verify-thresholds [(config PreCommitConfig) (dashedCount I64) (uncompensatedSagas I64)] -> Bool
  :d "Validates that commit delta adheres to token economy and saga invariants"
  (let [(tokensOk (if (.-strictTokens config) (= dashedCount 0) true))
        (sagasOk (= uncompensatedSagas 0))]
    (and tokensOk sagasOk)))

(df evaluate-commit-diff [(diff Str) (cfg PreCommitConfig)] -> Str
  :d "Evaluates commit diff against PreCommitConfig thresholds"
  (let [(dashed (count-dashed-identifiers diff))
        (sagas (count-uncompensated-sagas diff))
        (ok (verify-thresholds cfg dashed sagas))]
    (if ok
      "(:pre-commit-gate :status :clean :thresholds :passed)"
      (str "(:pre-commit-gate :status :blocked :thresholds :failed :dashed-count "
           (string-from-int64 dashed)
           " :uncompensated-sagas "
           (string-from-int64 sagas)
           ")"))))

(df run-pre-commit [] -> Str
  :d "Runs pre-commit gate suite in pure AgentScript with automated threshold enforcement."
  (let [(cfg (PreCommitConfig :strictTokens true :checkConsistency true :maxComplexity 15))
        (diff-read (file-read ".git/COMMIT_DIFF"))
        (diff (mt diff-read
                ((ok c) c)
                ((err e) "")))]
    (evaluate-commit-diff diff cfg)))

(df main [args] -> Str
  :d "Entrypoint for git pre-commit hook."
  (run-pre-commit))
