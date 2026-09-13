(module aslTools/skillsDistTest
  :d "Unit verification test suite for Modular Skills Distribution Engine"
  :x [testBuildStandardDistribution
      testResolveSkillDependencies
      testCircularDependencyGuard
      testFormatSkillsRegistry
      runTests]
  :i [(skillsDist :a sd)])

(df testBuildStandardDistribution [] -> Bool
  :d "Tests assembling standard skills distribution"
  (let [(dist (sd/buildStandardDistribution))]
    (assert (= (.-defaultSkillId dist) "asl") "Default skill must be asl")
    (assert (= (length (.-skills dist)) 6) "Standard distribution must have 6 skills")
    true))

(df testResolveSkillDependencies [] -> Bool
  :d "Tests resolving topological dependencies for modular skills"
  (let [(dist (sd/buildStandardDistribution))
        (depsCore (sd/resolveSkillDependencies dist "asl"))
        (depsStyle (sd/resolveSkillDependencies dist "asl-style"))
        (depsPoly (sd/resolveSkillDependencies dist "asl-polyglot"))
        (depsSlm (sd/resolveSkillDependencies dist "asl-slm"))
        (depsBus (sd/resolveSkillDependencies dist "asl-bus"))]
    (assert (= (length depsCore) 1) "Core skill must have 1 dependency")
    (assert (= (option-or (list-get depsCore 0) "") "asl") "Core dependency must be asl")
    (assert (= (length depsStyle) 2) "Style skill must have 2 dependencies")
    (assert (= (option-or (list-get depsStyle 0) "") "asl") "Style first dependency must be asl")
    (assert (= (option-or (list-get depsStyle 1) "") "asl-style") "Style second dependency must be asl-style")
    (assert (= (length depsPoly) 2) "Polyglot skill must have 2 dependencies")
    (assert (= (option-or (list-get depsPoly 0) "") "asl") "Polyglot first dependency must be asl")
    (assert (= (option-or (list-get depsPoly 1) "") "asl-polyglot") "Polyglot second dependency must be asl-polyglot")
    (assert (= (length depsSlm) 2) "SLM skill must have 2 dependencies")
    (assert (= (option-or (list-get depsSlm 1) "") "asl-slm") "SLM second dependency must be asl-slm")
    (assert (= (length depsBus) 2) "Bus skill must have 2 dependencies")
    (assert (= (option-or (list-get depsBus 1) "") "asl-bus") "Bus second dependency must be asl-bus")
    true))

(df testFormatSkillsRegistry [] -> Bool
  :d "Tests rendering skills distribution markdown registry"
  (let [(dist (sd/buildStandardDistribution))
        (tbl (sd/formatSkillsRegistry dist))]
    (assert (string-contains? tbl "Modular Skills Distribution Registry") "Table header must match")
    (assert (string-contains? tbl "`asl`") "Must contain asl")
    (assert (string-contains? tbl "`asl-style`") "Must contain asl-style")
    (assert (string-contains? tbl "`asl-polyglot`") "Must contain asl-polyglot")
    (assert (string-contains? tbl "`asl-slm`") "Must contain asl-slm")
    (assert (string-contains? tbl "`asl-bus`") "Must contain asl-bus")
    true))

(df testCircularDependencyGuard [] -> Bool
  :d "Tests safe termination when circular skill dependencies exist"
  (let [(mA (sd/createSkillManifest "skill-a" "Skill A" "1.0" "test" "desc" (list "skill-b")))
        (mB (sd/createSkillManifest "skill-b" "Skill B" "1.0" "test" "desc" (list "skill-a")))
        (dist (sd/SkillDistribution :skills (list mA mB) :defaultSkillId "skill-a"))
        (depsA (sd/resolveSkillDependencies dist "skill-a"))]
    (assert (>= (length depsA) 1) "Circular dependency resolution must terminate")
    (assert (sd/containsStr? depsA "skill-a") "Resolved dependencies must contain root skill")
    true))

(df runTests [] -> Bool
  :d "Runs complete test suite for modular skills distribution"
  (and (testBuildStandardDistribution)
       (and (testResolveSkillDependencies)
            (and (testCircularDependencyGuard)
                 (testFormatSkillsRegistry)))))
