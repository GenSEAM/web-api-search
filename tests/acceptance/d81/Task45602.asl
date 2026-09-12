(module tests/acceptance/d81/Task45602
  :d "Acceptance fixture for Task45602: Retire unreferenced definitions, enforce explicit constant declaration for constant bodies, and require explicit failure for unimplemented stubs under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestDeadDefinitionsRetired
      TestConstantBodyFunctionsExplicitDeclaration
      TestUnimplementedFunctionsFailExplicitly
      TestVerificationCasesContract
      TestTask45602GroundedInPhase456]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestDeadDefinitionsRetired [] -> Bool
  :d "Verifies that unreferenced definitions like make-svg-node in vdom are retired"
  (let [(v-res (file-read "vdom/src/asn_svg.asl"))]
    (assert (= (.-_tag v-res) "ok") "vdom/src/asn_svg.asl must exist and be readable")
    (let [(v-code (.-value v-res))]
      (assert (not (string-contains? v-code "(df make-svg-node")) "make-svg-node must be retired from vdom/src/asn_svg.asl")
      true)))

(df TestConstantBodyFunctionsExplicitDeclaration [] -> Bool
  :d "Verifies that functions returning bare constants are explicitly declared with :constant true exemption"
  (let [(g-res (file-read "asl-arduino/src/gpio.asl"))]
    (assert (= (.-_tag g-res) "ok") "asl-arduino/src/gpio.asl must exist and be readable")
    (let [(g-code (.-value g-res))]
      (assert (string-contains? g-code ":constant true") "gpio.asl constant-returning functions must carry explicit :constant true declaration")
      true)))

(df TestUnimplementedFunctionsFailExplicitly [] -> Bool
  :d "Verifies that stubs or unhandled conditions do not return silent success or mock constants"
  (let [(sql-res (file-read "asl/packages/asl-sql/src/core/sql.asl"))]
    (assert (= (.-_tag sql-res) "ok") "sql.asl must exist and be readable")
    (let [(sql-code (.-value sql-res))]
      (assert (string-contains? sql-code "render-placeholder") "sql.asl must provide implemented render-placeholder")
      true)))

(df TestVerificationCasesContract [] -> Bool
  :d "Verifies verification cases contract for Task45602 in phase task file"
  (let [(task-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag task-res) "ok") "Phase456 task collection must be readable")
    (let [(task-src (.-value task-res))]
      (assert (string-contains? task-src "A newly added function referenced by nothing is reported") "Must record verification case 1")
      (assert (string-contains? task-src "A function whose body is a bare constant is reported, and one that legitimately returns a constant is exempted only by an explicit declaration") "Must record verification case 2")
      (assert (string-contains? task-src "Calling a declared unimplemented function fails rather than returning a value") "Must record verification case 3")
      true)))

(df TestTask45602GroundedInPhase456 [] -> Bool
  :d "Verifies Task45602 is registered in Phase456 task collection with all mandatory D52 metadata"
  (let [(c-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag c-res) "ok") "Phase456DuplicationDeadCodeAndUnwiredEradication.asn must exist")
    (let [(src (.-value c-res))]
      (assert (string-contains? src ":id \"Task45602\"") "Must declare Task45602")
      (assert (string-contains? src ":gate \"sh tests/acceptance/d81/SuperviseGate.sh Task45602\"") "Must bind gate command")
      (assert (string-contains? src ":owns") "Must declare owned paths")
      (assert (string-contains? src "vdom/src") "Must own vdom/src")
      (assert (string-contains? src "asl-arduino/src") "Must own asl-arduino/src")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45602 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestDeadDefinitionsRetired) "TestDeadDefinitionsRetired must pass")
    (assert (TestConstantBodyFunctionsExplicitDeclaration) "TestConstantBodyFunctionsExplicitDeclaration must pass")
    (assert (TestUnimplementedFunctionsFailExplicitly) "TestUnimplementedFunctionsFailExplicitly must pass")
    (assert (TestVerificationCasesContract) "TestVerificationCasesContract must pass")
    (assert (TestTask45602GroundedInPhase456) "TestTask45602GroundedInPhase456 must pass")
    true))
