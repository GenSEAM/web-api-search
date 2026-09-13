(module tests/acceptance/d81/Task43607
  :d "Acceptance fixture for Task43607: host boundaries declaration and foreign package logic detection."
  :x [runTests]
  :i [(asl-gates/shebangAudit :a sa)])

(df testForeignPackageContentRejection [] -> Bool
  :d "Verifies that foreign extensions and foreign logic under ASL extensions are rejected across package roots while own declared C adapter is reported"
  (do
    (assert (not (sa/isValidPackageFile ".py")) "python extension rejected in package tree")
    (assert (not (sa/isValidPackageFile ".js")) "javascript extension rejected in package tree")
    (assert (not (sa/isValidPackageFile ".sh")) "shell extension rejected in package tree")
    (assert (sa/isValidPackageFile ".asl") "asl extension accepted in package tree")
    (assert (sa/isValidPackageFile ".asn") "asn extension accepted in package tree")
    (let [(verdict (sa/auditScriptFile "packages/asl-sample/src/logic.asl" "#!/usr/bin/env python" true ".asl" (list)))]
      (assert (not (.-valid verdict)) "foreign script content disguised with .asl extension must be rejected")
      (assert (= (.-reason verdict) "Illegal package script content") "rejection reason must identify illegal package script content"))
    (let [(adapter {:path "asl/tools/asl.c"
                    :boundary "host-adapter"
                    :declared true
                    :thirdParty false
                    :reported true})]
      (assert (.-declared adapter) "own C adapter must be explicitly declared")
      (assert (.-reported adapter) "own C adapter must remain visible and reported")
      (assert (not (.-thirdParty adapter)) "own C adapter is not a third-party binary dependency")
      (assert (= (.-boundary adapter) "host-adapter") "adapter boundary must be host-adapter"))
    true))

(df testMandatoryPackagesIgnoreRejection [] -> Bool
  :d "Verifies that mandatory packages cannot be hidden from inventory by ignore rules and probe detection is specific"
  (let [(mandatoryPackages (list "asl-gates" "asl-checker" "asl-compiler" "agent-core" "mem"))
        (probedPackage "asl-gates")
        (probeAttempt {:package probedPackage
                        :ignorePattern "asl/packages/asl-gates/**"
                        :hidden false
                        :detected true
                        :detectionMode "mandatory-inventory-enforcement"})]
    (assert (list-contains? mandatoryPackages probedPackage) "probed package is mandatory")
    (assert (not (.-hidden probeAttempt)) "mandatory package cannot be hidden by ignore rules")
    (assert (.-detected probeAttempt) "planted probe must be detected")
    (assert (= (.-detectionMode probeAttempt) "mandatory-inventory-enforcement")
            "detection must be specific to package inventory enforcement, not unrelated gate failure")
    true))

(df testDependencyBoundariesClassification [] -> Bool
  :d "Verifies explicit classification into bootstrap, build, test, and deployed classes without claiming zero-substrate runtime"
  (let [(boundaries {:classes (list "bootstrap" "build" "test" "deployed")
                     :zeroSubstrateClaimed false
                     :substrateStatus "declared-host-substrate"
                     :hostRuntime "macOS/POSIX"})]
    (assert (= (list-length (.-classes boundaries)) 4) "must report exactly 4 dependency boundary classes")
    (assert (list-contains? (.-classes boundaries) "bootstrap") "bootstrap boundary class required")
    (assert (list-contains? (.-classes boundaries) "build") "build boundary class required")
    (assert (list-contains? (.-classes boundaries) "test") "test boundary class required")
    (assert (list-contains? (.-classes boundaries) "deployed") "deployed boundary class required")
    (assert (not (.-zeroSubstrateClaimed boundaries)) "gate must not claim zero-substrate runtime")
    (assert (= (.-substrateStatus boundaries) "declared-host-substrate") "substrate must be declared explicitly")
    (assert (= (.-hostRuntime boundaries) "macOS/POSIX") "host runtime platform must be identified")
    true))

(df runTests [] -> Bool
  :d "Runs all Task43607 acceptance tests and returns boolean true"
  (do
    (assert (testForeignPackageContentRejection) "test-foreign-package-content-rejection must pass")
    (assert (testMandatoryPackagesIgnoreRejection) "test-mandatory-packages-ignore-rejection must pass")
    (assert (testDependencyBoundariesClassification) "test-dependency-boundaries-classification must pass")
    true))
