(module tests/acceptance/d81/Task44301
  :d "Acceptance fixture for Task44301: Path boundary and workspace visibility under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestPathBoundaryConformanceSuiteExecution
      TestAslCPathBoundaryContract
      TestRequiredCaseKindsContract
      TestVisibilityScopeTiersContract
      TestTask44301GroundedInPhase443]
  :i [("../../conformance/boundary/path_boundary_test" :a pbt)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestPathBoundaryConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/boundary/path_boundary_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/boundary/path_boundary_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (pbt/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestAslCPathBoundaryContract [] -> Bool
  :d "Verifies asl/tools/asl.c implements canonical path resolution, boundary checks, and scratch roots"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "is_safe_path") "asl.c must implement is_safe_path")
      (assert (string-contains? c-src "resolve_path") "asl.c must implement resolve_path")
      (assert (string-contains? c-src "normalize_path_components") "asl.c must implement normalize_path_components")
      (assert (string-contains? c-src "/tmp/") "asl.c must permit declared scratch root /tmp/")
      (assert (string-contains? c-src ":ERR_BOUNDARY_VIOLATION") "asl.c must emit :ERR_BOUNDARY_VIOLATION on escape")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (negativeControl, adversarial, boundary, metamorphic, errorPropagation) are present"
  (let [(f-res (file-read "tests/conformance/boundary/path_boundary_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestNegativeControlSiblingPrefix") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestAdversarialTraversalEscapes") "Must implement adversarial case")
      (assert (string-contains? f-src "TestBoundaryCanonicalDotDotInside") "Must implement boundary case")
      (assert (string-contains? f-src "TestMetamorphicEquivalentPathVerdicts") "Must implement metamorphic case")
      (assert (string-contains? f-src "TestErrorPropagationRejectionReceipt") "Must implement errorPropagation case")
      true)))

(df TestVisibilityScopeTiersContract [] -> Bool
  :d "Verifies asl-mem/visibility-scope exports 3-tier scoping types and functions"
  (let [(v-res (file-read "mem/src/visibility_scope.asl"))]
    (assert (= (.-_tag v-res) "ok") "mem/src/visibility_scope.asl must exist")
    (let [(v-src (.-value v-res))]
      (assert (string-contains? v-src "tier-isolated-session") "Must define tier-isolated-session")
      (assert (string-contains? v-src "tier-workspace-lineage") "Must define tier-workspace-lineage")
      (assert (string-contains? v-src "tier-sovereign-system") "Must define tier-sovereign-system")
      (assert (string-contains? v-src "filter-visible-worktrees") "Must implement filter-visible-worktrees")
      (assert (string-contains? v-src "filter-visible-sessions") "Must implement filter-visible-sessions")
      (assert (string-contains? v-src "filter-visible-repos") "Must implement filter-visible-repos")
      true)))

(df TestTask44301GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44301"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Path boundary and workspace visibility") "Phase 443 must state Task44301 title")
      (assert (string-contains? p-src ":lane \"boundary\"") "Phase 443 must specify boundary lane")
      (assert (string-contains? p-src "tests/conformance/boundary") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "is_safe_path") "Phase 443 must target is_safe_path")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44301 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestPathBoundaryConformanceSuiteExecution) "TestPathBoundaryConformanceSuiteExecution must pass")
    (assert (TestAslCPathBoundaryContract) "TestAslCPathBoundaryContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestVisibilityScopeTiersContract) "TestVisibilityScopeTiersContract must pass")
    (assert (TestTask44301GroundedInPhase443) "TestTask44301GroundedInPhase443 must pass")
    true))
