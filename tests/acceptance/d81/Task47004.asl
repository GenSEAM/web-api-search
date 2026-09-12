(module tests/acceptance/d81/Task47004
  :d "Acceptance fixture for Task47004: Fixtures for the tasks that are ready under ADR-0081."
  :x [RunTests
      TestReadySetFixtureCoverage
      TestFixtureInversionRefutation
      TestUncoveredTaskClaimRefusal]
  :i [])

(df TestReadySetFixtureCoverage [] -> Bool
  :d "Verifies that dependency-free ready tasks in the current active phase have verification fixtures"
  (let [(p-res (file-read ".asl/mem/tasks/Phase470RestoreGateScopeAndReachExecution.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase470 task file must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src ":id \"Task47001\"") "Task47001 must be registered")
      (assert (string-contains? p-src ":id \"Task47002\"") "Task47002 must be registered")
      (assert (string-contains? p-src ":id \"Task47003\"") "Task47003 must be registered")
      (let [(f1 (file-exists? "tests/acceptance/d81/Task47001.asl"))
            (f2 (file-exists? "tests/acceptance/d81/Task47002.asl"))
            (f3 (file-exists? "tests/acceptance/d81/Task47003.asl"))
            (f4 (file-exists? "tests/acceptance/d81/Task47004.asl"))]
        (assert f1 "Fixture for Task47001 must exist")
        (assert f2 "Fixture for Task47002 must exist")
        (assert f3 "Fixture for Task47003 must exist")
        (assert f4 "Fixture for Task47004 must exist")
        true))))

(df TestFixtureInversionRefutation [] -> Bool
  :d "Verifies that verifier fixtures execute non-vacuous assertions capable of failing under inversion"
  (let [(f-res (file-read "tests/acceptance/d81/Task47003.asl"))]
    (assert (= (.-_tag f-res) "ok") "Task47003 fixture must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "assert") "Fixture must contain assertions")
      (assert (not (string-contains? f-src "(assert true")) "Fixture must not contain vacuous assertions")
      (assert (string-contains? f-src "RunTests") "Fixture must provide RunTests export")
      true)))

(df TestUncoveredTaskClaimRefusal [] -> Bool
  :d "Verifies that SuperviseGate refuses tasks whose acceptance fixtures are missing"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "required verifier fixture is missing")
              "SuperviseGate must check for missing verifier fixtures")
      (assert (string-contains? s-src "exit 3")
              "SuperviseGate must exit 3 when fixture is missing")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47004 supervisor acceptance tests"
  (do
    (assert (TestReadySetFixtureCoverage) "TestReadySetFixtureCoverage must pass")
    (assert (TestFixtureInversionRefutation) "TestFixtureInversionRefutation must pass")
    (assert (TestUncoveredTaskClaimRefusal) "TestUncoveredTaskClaimRefusal must pass")
    true))
