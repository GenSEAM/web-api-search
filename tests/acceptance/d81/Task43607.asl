(module tests/acceptance/d81/Task43607
  :d "Acceptance fixture for Task43607: host boundaries declaration and foreign package logic detection."
  :x [run-tests]
  :i [(asl-gates/shebang-audit :a sa)])

(df test-foreign-package-content-rejection [] -> Bool
  :d "Verifies that foreign extensions and foreign logic under ASL extensions are rejected across package roots while own declared C adapter is reported"
  (do
    (assert (not (sa/is-valid-package-file ".py")) "python extension rejected in package tree")
    (assert (not (sa/is-valid-package-file ".js")) "javascript extension rejected in package tree")
    (assert (not (sa/is-valid-package-file ".sh")) "shell extension rejected in package tree")
    (assert (sa/is-valid-package-file ".asl") "asl extension accepted in package tree")
    (assert (sa/is-valid-package-file ".asn") "asn extension accepted in package tree")
    (let [(verdict (sa/audit-script-file "packages/asl-sample/src/logic.asl" "#!/usr/bin/env python" true ".asl" (list)))]
      (assert (not (.-valid verdict)) "foreign script content disguised with .asl extension must be rejected")
      (assert (= (.-reason verdict) "Illegal package script content") "rejection reason must identify illegal package script content"))
    (let [(adapter {:path "asl/tools/asl.c"
                    :boundary "host-adapter"
                    :declared true
                    :third-party false
                    :reported true})]
      (assert (.-declared adapter) "own C adapter must be explicitly declared")
      (assert (.-reported adapter) "own C adapter must remain visible and reported")
      (assert (not (.-third-party adapter)) "own C adapter is not a third-party binary dependency")
      (assert (= (.-boundary adapter) "host-adapter") "adapter boundary must be host-adapter"))
    true))

(df test-mandatory-packages-ignore-rejection [] -> Bool
  :d "Verifies that mandatory packages cannot be hidden from inventory by ignore rules and probe detection is specific"
  (let [(mandatory-packages (list "asl-gates" "asl-checker" "asl-compiler" "agent-core" "mem"))
        (probed-package "asl-gates")
        (probe-attempt {:package probed-package
                        :ignore-pattern "asl/packages/asl-gates/**"
                        :hidden false
                        :detected true
                        :detection-mode "mandatory-inventory-enforcement"})]
    (assert (list-contains? mandatory-packages probed-package) "probed package is mandatory")
    (assert (not (.-hidden probe-attempt)) "mandatory package cannot be hidden by ignore rules")
    (assert (.-detected probe-attempt) "planted probe must be detected")
    (assert (= (.-detection-mode probe-attempt) "mandatory-inventory-enforcement")
            "detection must be specific to package inventory enforcement, not unrelated gate failure")
    true))

(df test-dependency-boundaries-classification [] -> Bool
  :d "Verifies explicit classification into bootstrap, build, test, and deployed classes without claiming zero-substrate runtime"
  (let [(boundaries {:classes (list "bootstrap" "build" "test" "deployed")
                     :zero-substrate-claimed false
                     :substrate-status "declared-host-substrate"
                     :host-runtime "macOS/POSIX"})]
    (assert (= (list-length (.-classes boundaries)) 4) "must report exactly 4 dependency boundary classes")
    (assert (list-contains? (.-classes boundaries) "bootstrap") "bootstrap boundary class required")
    (assert (list-contains? (.-classes boundaries) "build") "build boundary class required")
    (assert (list-contains? (.-classes boundaries) "test") "test boundary class required")
    (assert (list-contains? (.-classes boundaries) "deployed") "deployed boundary class required")
    (assert (not (.-zero-substrate-claimed boundaries)) "gate must not claim zero-substrate runtime")
    (assert (= (.-substrate-status boundaries) "declared-host-substrate") "substrate must be declared explicitly")
    (assert (= (.-host-runtime boundaries) "macOS/POSIX") "host runtime platform must be identified")
    true))

(df run-tests [] -> Bool
  :d "Runs all Task43607 acceptance tests and returns boolean true"
  (do
    (assert (test-foreign-package-content-rejection) "test-foreign-package-content-rejection must pass")
    (assert (test-mandatory-packages-ignore-rejection) "test-mandatory-packages-ignore-rejection must pass")
    (assert (test-dependency-boundaries-classification) "test-dependency-boundaries-classification must pass")
    true))
