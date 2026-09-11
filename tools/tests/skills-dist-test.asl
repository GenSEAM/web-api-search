(module asl-tools/skills-dist-test
  :d "Unit verification test suite for Modular Skills Distribution Engine"
  :x [test-build-standard-distribution
      test-resolve-skill-dependencies
      test-circular-dependency-guard
      test-format-skills-registry
      run-tests]
  :i [(skills-dist :a sd)])

(df test-build-standard-distribution [] -> Bool
  :d "Tests assembling standard skills distribution"
  (let [(dist (sd/build-standard-distribution))]
    (assert (= (.-default-skill-id dist) "asl") "Default skill must be asl")
    (assert (= (length (.-skills dist)) 6) "Standard distribution must have 6 skills")
    true))

(df test-resolve-skill-dependencies [] -> Bool
  :d "Tests resolving topological dependencies for modular skills"
  (let [(dist (sd/build-standard-distribution))
        (deps-core (sd/resolve-skill-dependencies dist "asl"))
        (deps-style (sd/resolve-skill-dependencies dist "asl-style"))
        (deps-poly (sd/resolve-skill-dependencies dist "asl-polyglot"))
        (deps-slm (sd/resolve-skill-dependencies dist "asl-slm"))
        (deps-bus (sd/resolve-skill-dependencies dist "asl-bus"))]
    (assert (= (length deps-core) 1) "Core skill must have 1 dependency")
    (assert (= (option-or (list-get deps-core 0) "") "asl") "Core dependency must be asl")
    (assert (= (length deps-style) 2) "Style skill must have 2 dependencies")
    (assert (= (option-or (list-get deps-style 0) "") "asl") "Style first dependency must be asl")
    (assert (= (option-or (list-get deps-style 1) "") "asl-style") "Style second dependency must be asl-style")
    (assert (= (length deps-poly) 2) "Polyglot skill must have 2 dependencies")
    (assert (= (option-or (list-get deps-poly 0) "") "asl") "Polyglot first dependency must be asl")
    (assert (= (option-or (list-get deps-poly 1) "") "asl-polyglot") "Polyglot second dependency must be asl-polyglot")
    (assert (= (length deps-slm) 2) "SLM skill must have 2 dependencies")
    (assert (= (option-or (list-get deps-slm 1) "") "asl-slm") "SLM second dependency must be asl-slm")
    (assert (= (length deps-bus) 2) "Bus skill must have 2 dependencies")
    (assert (= (option-or (list-get deps-bus 1) "") "asl-bus") "Bus second dependency must be asl-bus")
    true))

(df test-format-skills-registry [] -> Bool
  :d "Tests rendering skills distribution markdown registry"
  (let [(dist (sd/build-standard-distribution))
        (tbl (sd/format-skills-registry dist))]
    (assert (string-contains? tbl "Modular Skills Distribution Registry") "Table header must match")
    (assert (string-contains? tbl "`asl`") "Must contain asl")
    (assert (string-contains? tbl "`asl-style`") "Must contain asl-style")
    (assert (string-contains? tbl "`asl-polyglot`") "Must contain asl-polyglot")
    (assert (string-contains? tbl "`asl-slm`") "Must contain asl-slm")
    (assert (string-contains? tbl "`asl-bus`") "Must contain asl-bus")
    true))

(df test-circular-dependency-guard [] -> Bool
  :d "Tests safe termination when circular skill dependencies exist"
  (let [(m-a (sd/create-skill-manifest "skill-a" "Skill A" "1.0" "test" "desc" (list "skill-b")))
        (m-b (sd/create-skill-manifest "skill-b" "Skill B" "1.0" "test" "desc" (list "skill-a")))
        (dist (sd/SkillDistribution :skills (list m-a m-b) :default-skill-id "skill-a"))
        (deps-a (sd/resolve-skill-dependencies dist "skill-a"))]
    (assert (>= (length deps-a) 1) "Circular dependency resolution must terminate")
    (assert (sd/contains-str? deps-a "skill-a") "Resolved dependencies must contain root skill")
    true))

(df run-tests [] -> Bool
  :d "Runs complete test suite for modular skills distribution"
  (and (test-build-standard-distribution)
       (and (test-resolve-skill-dependencies)
            (and (test-circular-dependency-guard)
                 (test-format-skills-registry)))))
