(module asl-tools/skills-dist
  :d "Modular Skills Distribution & Dynamic Registry Engine in Pure ASL"
  :x [SkillManifest
      SkillDistribution
      create-skill-manifest
      build-standard-distribution
      resolve-skill-dependencies
      format-skills-registry
      contains-str?]
  :i [])

(dfs SkillManifest
  (:f id Str "Unique skill identifier e.g. asl, asl-style, asl-polyglot")
  (:f name Str "Human-readable skill title")
  (:f version Str "Semantic version string e.g. 1.0.0")
  (:f category Str "Capability grouping: core, style, polyglot, native")
  (:f description Str "One-line description of capabilities")
  (:f dependencies (List Str) "List of required prerequisite skill IDs"))

(dfs SkillDistribution
  (:f skills (List SkillManifest) "All registered skill manifests")
  (:f default-skill-id Str "Default baseline skill ID loaded into agent context"))

(df create-skill-manifest [(id Str) (name Str) (ver Str) (cat Str) (desc Str) (deps (List Str))] -> SkillManifest
  :d "Constructs a SkillManifest definition."
  (SkillManifest
    :id id
    :name name
    :version ver
    :category cat
    :description desc
    :dependencies deps))

(df build-standard-distribution [] -> SkillDistribution
  :d "Assembles standard modular skills distribution with minimal core and on-demand extensions."
  (let [(m-core (create-skill-manifest
                  "asl"
                  "AgentScript Core"
                  "1.0.0"
                  "core"
                  "Native agent-centric language syntax, sandboxed evaluation & memory indexing"
                  (list)))
        (m-native (create-skill-manifest
                    "asl-native"
                    "AgentScript Native CLI"
                    "1.0.0"
                    "native"
                    "Native Ahead-of-Time compilation, C binary linking, and high-performance SIMD"
                    (list "asl")))
        (m-style (create-skill-manifest
                   "asl-style"
                   "CSS Cascade & Design System Guard"
                   "1.0.0"
                   "style"
                   "CSS computed cascade engine, CSS variables extractor, and design policy guard"
                   (list "asl")))
        (m-polyglot (create-skill-manifest
                      "asl-polyglot"
                      "Polyglot AST & Script Runner"
                      "1.0.0"
                      "polyglot"
                      "Python, TypeScript, Go, Rust, and PHP AST outlines with in-memory sandboxed runners"
                      (list "asl")))
        (m-slm (create-skill-manifest
                 "asl-slm"
                 "SLM Local Inference & Telemetry"
                 "1.0.0"
                 "slm"
                 "Small Language Model local inference on M1 unified memory, telemetry metrics & offline evaluation"
                 (list "asl")))
        (m-bus (create-skill-manifest
                 "asl-bus"
                 "ASL Swarm Bus & Presence"
                 "1.0.0"
                 "bus"
                 "Swarm room presence, binary ASB wire framing, and inter-agent task negotiation"
                 (list "asl")))]
    (SkillDistribution
      :skills (list m-core m-native m-style m-polyglot m-slm m-bus)
      :default-skill-id "asl")))

(df find-skill [(dist SkillDistribution) (skill-id Str)] -> (Option SkillManifest)
  :d "Finds a skill manifest by ID."
  (foldl (fn [(acc (Option SkillManifest)) (m SkillManifest)] -> (Option SkillManifest)
           (mt acc
             ((some _) acc)
             ((none) (if (= (.-id m) skill-id) (some m) (none)))))
         (none)
         (.-skills dist)))

(df resolve-skill-dependencies [(dist SkillDistribution) (skill-id Str)] -> (List Str)
  :d "Resolves all transitive dependencies for a skill in topological load order with cycle protection."
  (resolve-skill-deps-internal dist skill-id (list)))

(df resolve-skill-deps-internal [(dist SkillDistribution) (skill-id Str) (visited (List Str))] -> (List Str)
  :d "Internal helper resolving transitive dependencies with visited cycle guard."
  (if (contains-str? visited skill-id)
      (list)
      (let [(manifest (find-skill dist skill-id))]
        (mt manifest
          ((none) (list))
          ((some m)
           (let [(new-visited (append visited skill-id))
                 (deps (.-dependencies m))
                 (all-deps (foldl (fn [(acc (List Str)) (dep-id Str)] -> (List Str)
                                    (let [(transitive (resolve-skill-deps-internal dist dep-id new-visited))]
                                      (foldl (fn [(iacc (List Str)) (tid Str)] -> (List Str)
                                               (if (contains-str? iacc tid) iacc (append iacc tid)))
                                             acc
                                             transitive)))
                                  (list)
                                  deps))]
             (if (contains-str? all-deps skill-id)
                 all-deps
                 (append all-deps skill-id))))))))

(df contains-str? [(items (List Str)) (needle Str)] -> Bool
  :d "Checks if a string item is in the list."
  (foldl (fn [(found Bool) (item Str)] -> Bool
           (or found (= item needle)))
         false
         items))

(df format-skills-registry [(dist SkillDistribution)] -> Str
  :d "Renders a markdown table of available skills and their dependencies."
  (let [(hdr (str "### Modular Skills Distribution Registry\n"
                  "**Default Baseline Skill**: `" (.-default-skill-id dist) "`\n\n"
                  "| Skill ID | Name | Version | Category | Dependencies |\n"
                  "|---|---|---|---|---|\n"))]
    (foldl (fn [(acc Str) (m SkillManifest)] -> Str
             (let [(deps-str (if (= (length (.-dependencies m)) 0)
                                 "none"
                                 (join-strings (.-dependencies m) ", ")))]
               (str acc "| `" (.-id m) "` | " (.-name m) " | " (.-version m) " | " (.-category m) " | `" deps-str "` |\n")))
           hdr
           (.-skills dist))))

(df join-strings [(items (List Str)) (sep Str)] -> Str
  :d "Joins a list of strings with separator."
  (let [(len (length items))]
    (if (= len 0)
        ""
        (foldl (fn [(acc Str) (pair (Tuple2 I64 Str))] -> Str
                 (let [(idx (tuple2-first pair))
                       (item (tuple2-second pair))]
                   (if (= idx 0)
                       item
                       (str acc sep item))))
               ""
               (enumerate items)))))
