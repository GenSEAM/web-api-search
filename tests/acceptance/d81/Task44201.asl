(module tests/acceptance/d81/Task44201
  :d "Acceptance fixture for Task44201: asl doctor environment and capability truth probe."
  :x [RunTests
      TestDoctorSubcommandImplemented
      TestDoctorOutputsCapabilitiesMap
      TestDoctorFixturesDirectory]
  :i [])

(df TestDoctorSubcommandImplemented [] -> Bool
  :d "Verifies that asl.c implements run_doctor and dispatches doctor in main"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_doctor")
              "asl.c must implement run_doctor")
      (assert (string-contains? c-src "strcmp(argv[1], \"doctor\")")
              "asl.c must dispatch doctor in main")
      (assert (string-contains? c-src "asl doctor")
              "asl.c must document asl doctor in help/usage")
      true)))

(df TestDoctorOutputsCapabilitiesMap [] -> Bool
  :d "Verifies that run_doctor outputs (:capabilities ...) structure"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "(:capabilities")
              "run_doctor must emit (:capabilities structure")
      (assert (string-contains? c-src ":status")
              "capabilities map must report :status per entry")
      true)))

(df TestDoctorFixturesDirectory [] -> Bool
  :d "Verifies that tests/doctor directory exists with known-answer fixtures"
  (let [(fixture-res (file-read "tests/doctor/fixture.txt"))]
    (assert (= (.-_tag fixture-res) "ok") "tests/doctor/fixture.txt must exist")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task44201 supervisor acceptance tests"
  (do
    (assert (TestDoctorSubcommandImplemented) "TestDoctorSubcommandImplemented must pass")
    (assert (TestDoctorOutputsCapabilitiesMap) "TestDoctorOutputsCapabilitiesMap must pass")
    (assert (TestDoctorFixturesDirectory) "TestDoctorFixturesDirectory must pass")
    true))
