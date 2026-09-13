(module aslTools/skillsDist
  :d "Modular Skills Distribution & Dynamic Registry Engine in Pure ASL"
  :x [SkillManifest
      SkillDistribution
      createSkillManifest
      buildStandardDistribution
      resolveSkillDependencies
      formatSkillsRegistry
      containsStr?]
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
  (:f defaultSkillId Str "Default baseline skill ID loaded into agent context"))

(df createSkillManifest [(id Str) (name Str) (ver Str) (cat Str) (desc Str) (deps (List Str))] -> SkillManifest
  :d "Constructs a SkillManifest definition."
  (SkillManifest
    :id id
    :name name
    :version ver
    :category cat
    :description desc
    :dependencies deps))

(df buildStandardDistribution [] -> SkillDistribution
  :d "Assembles standard modular skills distribution with minimal core and on-demand extensions."
  (let [(mCore (createSkillManifest
                  "asl"
                  "AgentScript Core"
                  "1.0.0"
                  "core"
                  "Native agent-centric language syntax, sandboxed evaluation & memory indexing"
                  (list)))
        (mNative (createSkillManifest
                    "asl-native"
                    "AgentScript Native CLI"
                    "1.0.0"
                    "native"
                    "Native Ahead-of-Time compilation, C binary linking, and high-performance SIMD"
                    (list "asl")))
        (mStyle (createSkillManifest
                   "asl-style"
                   "CSS Cascade & Design System Guard"
                   "1.0.0"
                   "style"
                   "CSS computed cascade engine, CSS variables extractor, and design policy guard"
                   (list "asl")))
        (mPolyglot (createSkillManifest
                      "asl-polyglot"
                      "Polyglot AST & Script Runner"
                      "1.0.0"
                      "polyglot"
                      "Python, TypeScript, Go, Rust, and PHP AST outlines with in-memory sandboxed runners"
                      (list "asl")))
        (mSlm (createSkillManifest
                 "asl-slm"
                 "SLM Local Inference & Telemetry"
                 "1.0.0"
                 "slm"
                 "Small Language Model local inference on M1 unified memory, telemetry metrics & offline evaluation"
                 (list "asl")))
        (mBus (createSkillManifest
                 "asl-bus"
                 "ASL Swarm Bus & Presence"
                 "1.0.0"
                 "bus"
                 "Swarm room presence, binary ASB wire framing, and inter-agent task negotiation"
                 (list "asl")))]
    (SkillDistribution
      :skills (list mCore mNative mStyle mPolyglot mSlm mBus)
      :defaultSkillId "asl")))

(df findSkill [(dist SkillDistribution) (skillId Str)] -> (Option SkillManifest)
  :d "Finds a skill manifest by ID."
  (foldl (fn [(acc (Option SkillManifest)) (m SkillManifest)] -> (Option SkillManifest)
           (mt acc
             ((some _) acc)
             ((none) (if (= (.-id m) skillId) (some m) (none)))))
         (none)
         (.-skills dist)))

(df resolveSkillDependencies [(dist SkillDistribution) (skillId Str)] -> (List Str)
  :d "Resolves all transitive dependencies for a skill in topological load order with cycle protection."
  (resolveSkillDepsInternal dist skillId (list)))

(df resolveSkillDepsInternal [(dist SkillDistribution) (skillId Str) (visited (List Str))] -> (List Str)
  :d "Internal helper resolving transitive dependencies with visited cycle guard."
  (if (containsStr? visited skillId)
      (list)
      (let [(manifest (findSkill dist skillId))]
        (mt manifest
          ((none) (list))
          ((some m)
           (let [(newVisited (append visited skillId))
                 (deps (.-dependencies m))
                 (allDeps (foldl (fn [(acc (List Str)) (depId Str)] -> (List Str)
                                    (let [(transitive (resolveSkillDepsInternal dist depId newVisited))]
                                      (foldl (fn [(iacc (List Str)) (tid Str)] -> (List Str)
                                               (if (containsStr? iacc tid) iacc (append iacc tid)))
                                             acc
                                             transitive)))
                                  (list)
                                  deps))]
             (if (containsStr? allDeps skillId)
                 allDeps
                 (append allDeps skillId))))))))

(df containsStr? [(items (List Str)) (needle Str)] -> Bool
  :d "Checks if a string item is in the list."
  (foldl (fn [(found Bool) (item Str)] -> Bool
           (or found (= item needle)))
         false
         items))

(df formatSkillsRegistry [(dist SkillDistribution)] -> Str
  :d "Renders a markdown table of available skills and their dependencies."
  (let [(hdr (str "### Modular Skills Distribution Registry\n"
                  "**Default Baseline Skill**: `" (.-defaultSkillId dist) "`\n\n"
                  "| Skill ID | Name | Version | Category | Dependencies |\n"
                  "|---|---|---|---|---|\n"))]
    (foldl (fn [(acc Str) (m SkillManifest)] -> Str
             (let [(depsStr (if (= (length (.-dependencies m)) 0)
                                 "none"
                                 (joinStrings (.-dependencies m) ", ")))]
               (str acc "| `" (.-id m) "` | " (.-name m) " | " (.-version m) " | " (.-category m) " | `" depsStr "` |\n")))
           hdr
           (.-skills dist))))

(df joinStrings [(items (List Str)) (sep Str)] -> Str
  :d "Joins a list of strings with separator."
  (let [(len (length items))]
    (if (= len 0)
        ""
        (foldl (fn [(acc Str) (pair (Tuple2 I64 Str))] -> Str
                 (let [(idx (tuple2First pair))
                       (item (tuple2Second pair))]
                   (if (= idx 0)
                       item
                       (str acc sep item))))
               ""
               (enumerate items)))))
