(module asl-tools/lens
  :d "Drop-in codebase steering engine and negative constraints accelerator for external agents."
  :x [LensConfig SteeringDirectives LensResult
      make-lens-config generate-steering-directives
      format-onboarding-message run-lens-diagnostics]
  :i [])

(dfs LensConfig
  (:f target-agent Str "Target external agent: claude-code, cursor, windsurf, opendevin")
  (:f max-view-lines I64 "Strict negative constraint threshold (default 50 lines)")
  (:f enforce-asl-intel Bool "True to mandate asl intel outline/impact over raw cat"))

(dfs SteeringDirectives
  (:f agent Str "Target assistant identifier")
  (:f negative-constraints Str "Negative constraints rules text")
  (:f steering-rules Str "MANDATORY asl intel steering instructions"))

(dfs LensResult
  (:f success Bool "True if steering rules generated cleanly")
  (:f directives SteeringDirectives "Constructed steering directives")
  (:f onboarding-notice Str "Turn-0 onboarding instructions if runtime missing"))

(df make-lens-config [(agent Str) (max-lines I64) (enforce Bool)] -> LensConfig
  :d "Constructs a Lens configuration record."
  (LensConfig
    :target-agent agent
    :max-view-lines max-lines
    :enforce-asl-intel enforce))

(df generate-steering-directives [(cfg LensConfig)] -> SteeringDirectives
  :d "Generates strict negative constraints and steering rules for external coding agents."
  (let [(agent (.-target-agent cfg))
        (neg (str "# Negative Constraints (" agent ")\n"
                  "- FORBIDDEN: Never call whole-file View/cat on files exceeding "
                  (str (.-max-view-lines cfg)) " lines (prevents context blowout).\n"
                  "- FORBIDDEN: Never mutate files without checking dependency impact.\n"))
        (steer (str "# Mandatory Code Intelligence Steering\n"
                    "- MANDATORY: Use 'asl intel outline <file>' to inspect module structure and signatures.\n"
                    "- MANDATORY: Use 'asl intel impact <symbol>' before modifying shared functions.\n"
                    "- MANDATORY: Use compact ASN format for dense tool execution.\n"))]
    (SteeringDirectives
      :agent agent
      :negative-constraints neg
      :steering-rules steer)))

(df format-onboarding-message [] -> Str
  :d "Formats the turn-0 onboarding hook message when ASL is not found."
  (str "[genseam/lens] ERROR: AgentScript (asl) runtime is required but not found on PATH.\n"
       "To install AgentScript instantly, run:\n\n"
       "  curl -fsSL https://aslang.dev/install.sh | bash\n\n"
       "For documentation, visit https://aslang.dev\n"))

(df run-lens-diagnostics [(agent Str)] -> LensResult
  :d "Executes Lens configuration and emits steering directives."
  (let [(cfg (make-lens-config agent 50 true))
        (dirs (generate-steering-directives cfg))
        (onboard (format-onboarding-message))]
    (LensResult
      :success true
      :directives dirs
      :onboarding-notice onboard)))
