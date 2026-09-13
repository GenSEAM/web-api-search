(module aslTools/lens
  :d "Drop-in codebase steering engine and negative constraints accelerator for external agents."
  :x [LensConfig SteeringDirectives LensResult
      makeLensConfig generateSteeringDirectives
      formatOnboardingMessage runLensDiagnostics]
  :i [])

(dfs LensConfig
  (:f targetAgent Str "Target external agent: claude-code, cursor, windsurf, opendevin")
  (:f maxViewLines I64 "Strict negative constraint threshold (default 50 lines)")
  (:f enforceAslIntel Bool "True to mandate asl intel outline/impact over raw cat"))

(dfs SteeringDirectives
  (:f agent Str "Target assistant identifier")
  (:f negativeConstraints Str "Negative constraints rules text")
  (:f steeringRules Str "MANDATORY asl intel steering instructions"))

(dfs LensResult
  (:f success Bool "True if steering rules generated cleanly")
  (:f directives SteeringDirectives "Constructed steering directives")
  (:f onboardingNotice Str "Turn-0 onboarding instructions if runtime missing"))

(df makeLensConfig [(agent Str) (maxLines I64) (enforce Bool)] -> LensConfig
  :d "Constructs a Lens configuration record."
  (LensConfig
    :targetAgent agent
    :maxViewLines maxLines
    :enforceAslIntel enforce))

(df generateSteeringDirectives [(cfg LensConfig)] -> SteeringDirectives
  :d "Generates strict negative constraints and steering rules for external coding agents."
  (let [(agent (.-targetAgent cfg))
        (neg (str "# Negative Constraints (" agent ")\n"
                  "- FORBIDDEN: Never call whole-file View/cat on files exceeding "
                  (str (.-maxViewLines cfg)) " lines (prevents context blowout).\n"
                  "- FORBIDDEN: Never mutate files without checking dependency impact.\n"))
        (steer (str "# Mandatory Code Intelligence Steering\n"
                    "- MANDATORY: Use 'asl intel outline <file>' to inspect module structure and signatures.\n"
                    "- MANDATORY: Use 'asl intel impact <symbol>' before modifying shared functions.\n"
                    "- MANDATORY: Use compact ASN format for dense tool execution.\n"))]
    (SteeringDirectives
      :agent agent
      :negativeConstraints neg
      :steeringRules steer)))

(df formatOnboardingMessage [] -> Str
  :d "Formats the turn-0 onboarding hook message when ASL is not found."
  (str "[genseam/lens] ERROR: AgentScript (asl) runtime is required but not found on PATH.\n"
       "To install AgentScript instantly, run:\n\n"
       "  curl -fsSL https://aslang.dev/install.sh | bash\n\n"
       "For documentation, visit https://aslang.dev\n"))

(df runLensDiagnostics [(agent Str)] -> LensResult
  :d "Executes Lens configuration and emits steering directives."
  (let [(cfg (makeLensConfig agent 50 true))
        (dirs (generateSteeringDirectives cfg))
        (onboard (formatOnboardingMessage))]
    (LensResult
      :success true
      :directives dirs
      :onboardingNotice onboard)))
