(module tests/acceptance/d81/Task50106
  :d "Supervisor fixture certifying Phase 501 integrity across Task50101..Task50106"
  :x [testPhase501Integrity RunTests]
  :i [])

(df verifyTaskFixture [(taskFile String)] -> Bool
  (let [(cmd (str "bin/asl test --strict-falsify " taskFile))
        (res (sys-exec cmd))
        (code (.-exitCode res))]
    (assert (= code 0) (str "Task fixture " taskFile " passed cleanly"))
    (refute (!= code 0) (str "Task fixture " taskFile " must not fail"))
    (assert (string-contains? (.-stdout res) "assertion(s) executed") (str taskFile " executed assertions"))
    (refute (string-contains? (.-stdout res) "0 assertion(s) executed") (str taskFile " non-vacuous"))
    true))

(df testPhase501Integrity [] -> Bool
  (do
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50101.asl") "Task50101 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50102.asl") "Task50102 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50103.asl") "Task50103 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50104.asl") "Task50104 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50105.asl") "Task50105 verified")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testPhase501Integrity) "testPhase501Integrity passes")
    true))
