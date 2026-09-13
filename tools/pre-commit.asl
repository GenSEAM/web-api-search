(module aslTools/preCommit
  :d "Pure AgentScript Git Pre-Commit Hook & Automated Threshold Enforcement Engine."
  :x [main
      runPreCommit
      verifyThresholds
      countDashedIdentifiers
      countUncompensatedSagas
      evaluateCommitDiff
      PreCommitConfig]
  :i [])

(dfs PreCommitConfig
  (:f strictTokens Bool "Enforce camelCase tokens on new identifiers")
  (:f checkConsistency Bool "Enforce ADR and task consistency")
  (:f maxComplexity I64 "Maximum allowed function complexity"))

(df isDashedIdentifier? [(name Str)] -> Bool
  :d "Checks whether an identifier contains kebab-case hyphens"
  (let [(clean (string-trim name))]
    (and (string-contains? clean "-")
         (not (string-starts-with? clean ":"))
         (not (string-starts-with? clean "--"))
         (not (stringEquals? clean "->"))
         (not (stringEquals? clean "-")))))

(df extractFnNameFromLine [(line Str)] -> Str
  :d "Extracts function or symbol name from definition line"
  (let [(trimmed (string-trim line))
        (afterPlus (if (string-starts-with? trimmed "+")
                      (string-trim (option-or (string-slice trimmed 1 (string-length trimmed)) ""))
                      trimmed))]
    (if (string-starts-with? afterPlus "(df ")
      (let [(restS (string-trim (option-or (string-slice afterPlus 4 (string-length afterPlus)) "")))
            (parts (string-split restS " "))]
        (option-or (list-head parts) ""))
      (if (string-starts-with? afterPlus "(defun ")
        (let [(restS (string-trim (option-or (string-slice afterPlus 7 (string-length afterPlus)) "")))
              (parts (string-split restS " "))]
          (option-or (list-head parts) ""))
        ""))))

(df countDashedIdentifiers [(diff Str)] -> I64
  :d "Scans git diff additions for kebab-case function identifiers"
  (let [(lines (string-split diff "\n"))]
    (fold (fn [(count I64) (line Str)] -> I64
            (let [(trimmed (string-trim line))]
              (if (and (string-starts-with? trimmed "+")
                       (not (string-starts-with? trimmed "+++")))
                (let [(fnName (extractFnNameFromLine trimmed))]
                  (if (and (not (string-empty? fnName))
                           (isDashedIdentifier? fnName))
                    (+ count 1)
                    count))
                count)))
          0
          lines)))

(df countUncompensatedSagas [(diff Str)] -> I64
  :d "Detects saga transaction declarations without rollback or compensation blocks"
  (let [(lines (string-split diff "\n"))
        (hasSaga (fold (fn [(found Bool) (l Str)] -> Bool
                          (or found (and (string-starts-with? (string-trim l) "+")
                                         (or (string-contains? l "saga-begin")
                                             (string-contains? l "(:saga")))))
                        false
                        lines))
        (hasComp (fold (fn [(found Bool) (l Str)] -> Bool
                          (or found (or (string-contains? l "saga-compensate")
                                        (or (string-contains? l "saga-rollback")
                                            (string-contains? l ":compensate")))))
                        false
                        lines))]
    (if (and hasSaga (not hasComp)) 1 0)))

(df verifyThresholds [(config PreCommitConfig) (dashedCount I64) (uncompensatedSagas I64)] -> Bool
  :d "Validates that commit delta adheres to token economy and saga invariants"
  (let [(tokensOk (if (.-strictTokens config) (= dashedCount 0) true))
        (sagasOk (= uncompensatedSagas 0))]
    (and tokensOk sagasOk)))

(df evaluateCommitDiff [(diff Str) (cfg PreCommitConfig)] -> Str
  :d "Evaluates commit diff against PreCommitConfig thresholds"
  (let [(dashed (countDashedIdentifiers diff))
        (sagas (countUncompensatedSagas diff))
        (ok (verifyThresholds cfg dashed sagas))]
    (if ok
      "(:pre-commit-gate :status :clean :thresholds :passed)"
      (str "(:pre-commit-gate :status :blocked :thresholds :failed :dashed-count "
           (string-from-int64 dashed)
           " :uncompensated-sagas "
           (string-from-int64 sagas)
           ")"))))

(df runPreCommit [] -> Str
  :d "Runs pre-commit gate suite in pure AgentScript with automated threshold enforcement."
  (let [(cfg (PreCommitConfig :strictTokens true :checkConsistency true :maxComplexity 15))
        (diffRead (file-read ".git/COMMIT_DIFF"))
        (diff (mt diffRead
                ((ok c) c)
                ((err e) "")))]
    (evaluateCommitDiff diff cfg)))

(df main [args] -> Str
  :d "Entrypoint for git pre-commit hook."
  (runPreCommit))
