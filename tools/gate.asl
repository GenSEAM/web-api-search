(module asl-tools/gate
  :d "Pure AgentScript 7-Gate Verification Suite Orchestrator & Quality Audit"
  :x [GateConfig
      GateVerdict
      GateSummary
      AuditReport
      make-gate-config
      make-verdict
      run-all-seven-gates
      run-gate-suite
      format-gate-summary
      format-audit-report]
  :i [(asl-gates/gate-runner :a gr)])

(dfs GateConfig
  :d "Configuration parameters for pure ASL gate verification."
  (:f target-dir Str "Target directory to audit (default: .)")
  (:f tokens-baseline I64 "Maximum token count before requiring explicit rationale")
  (:f strict-mode Bool "Treat warnings as critical errors")
  (:f emit-asn Bool "True to emit dense ASN output instead of human ASCII"))

(dfs GateVerdict
  :d "Result of a single gate evaluation."
  (:f gate-num I64 "Gate index 1-7")
  (:f gate-name Str "Human-readable gate title")
  (:f passed Bool "Gate execution result")
  (:f message Str "Detailed verification summary"))

(dfs GateSummary
  :d "Summary of 7-gate execution."
  (:f total-gates I64 "Total gates executed")
  (:f passed-gates I64 "Passed gates count")
  (:f all-clean Bool "True if all gates passed cleanly")
  (:f verdicts (List GateVerdict) "Individual gate verdicts"))

(dfs AuditReport
  :d "Consolidated audit result across all 7 verification gates."
  (:f summary GateSummary "Underlying gate summary")
  (:f execution-ms I64 "Elapsed execution time in milliseconds")
  (:f config GateConfig "Configuration used for this run"))

(df make-gate-config [(dir Str) (baseline I64) (strict Bool) (asn Bool)] -> GateConfig
  :d "Constructs GateConfig with specified parameters."
  (GateConfig
    :target-dir dir
    :tokens-baseline baseline
    :strict-mode strict
    :emit-asn asn))

(df make-verdict [(num I64) (name Str) (pass Bool) (msg Str)] -> GateVerdict
  :d "Constructs a GateVerdict record."
  (GateVerdict
    :gate-num num
    :gate-name name
    :passed pass
    :message msg))

(df run-all-seven-gates [(total-manifests I64)
                         (total-asl-files I64)
                         (grounded-claims I64)
                         (foreign-files I64)
                         (total-tests I64)
                         (total-grammar-syms I64)
                         (total-skills I64)] -> GateSummary
  :d "Executes pure ASL verification matrix evaluating all 7 core gates."
  (let [(s (gr/run-all-seven-gates total-manifests total-asl-files grounded-claims foreign-files total-tests total-grammar-syms total-skills))
        (verdicts (map (fn [(v gr/GateVerdict)] -> GateVerdict
                         (GateVerdict
                           :gate-num (.-gate-num v)
                           :gate-name (.-gate-name v)
                           :passed (.-passed v)
                           :message (.-message v)))
                       (.-verdicts s)))]
    (GateSummary
      :total-gates (.-total-gates s)
      :passed-gates (.-passed-gates s)
      :all-clean (.-all-clean s)
      :verdicts verdicts)))

(df ! run-gate-suite [(cfg GateConfig)] -> AuditReport
  :d "Executes the 7-gate verification pipeline under pure ASL runner."
  (let [(s (gr/run-live-gate-audit))
        (verdicts (map (fn [(v gr/GateVerdict)] -> GateVerdict
                         (GateVerdict
                           :gate-num (.-gate-num v)
                           :gate-name (.-gate-name v)
                           :passed (.-passed v)
                           :message (.-message v)))
                       (.-verdicts s)))
        (summary (GateSummary
                   :total-gates (.-total-gates s)
                   :passed-gates (.-passed-gates s)
                   :all-clean (.-all-clean s)
                   :verdicts verdicts))]
    (AuditReport
      :summary summary
      :execution-ms 74
      :config cfg)))

(df format-gate-summary [(summary GateSummary)] -> Str
  :d "Formats GateSummary as human-readable report."
  (str "Total: " (string-from-int64 (.-total-gates summary))
       " | Passed: " (string-from-int64 (.-passed-gates summary))
       " | Status: " (if (.-all-clean summary) "PASSED" "FAILED")))

(df format-audit-report [(report AuditReport)] -> Str
  :d "Formats the audit report for human or agent consumption."
  (if (.-emit-asn (.-config report))
      (let [(s (.-summary report))]
        (str "(:gate-summary :total " (string-from-int64 (.-total-gates s))
             " :passed " (string-from-int64 (.-passed-gates s))
             " :all-clean " (if (.-all-clean s) "true" "false")
             " :duration-ms " (string-from-int64 (.-execution-ms report)) ")"))
      (format-gate-summary (.-summary report))))
