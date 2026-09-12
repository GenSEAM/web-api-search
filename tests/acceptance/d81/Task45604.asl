(module tests/acceptance/d81/Task45604
  :d "Acceptance fixture for Task45604: Single tracked install.sh, distribution copy byte-identity, and nested dist eradication under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSingleTrackedInstallerSource
      TestDistributionCopiesIdentical
      TestDriftDetectionContract
      TestNestedDistPathEliminated
      TestGateIntegrationContract
      TestRulePropagationSingleSource
      TestTask45604GroundedInPhase456]
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

(df TestSingleTrackedInstallerSource [] -> Bool
  :d "Verifies scripts/install.sh is the authoritative single tracked installer with check-installers command"
  (let [(s-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "--check-installers") "Must support --check-installers flag")
      (assert (string-contains? s-src "--render-rules") "Must support --render-rules flag")
      (assert (string-contains? s-src "--check-rules") "Must support --check-rules flag")
      (assert (string-contains? s-src "installers: verified single tracked installer") "Must emit verification message")
      true)))

(df TestDistributionCopiesIdentical [] -> Bool
  :d "Verifies distribution copies of install.sh are byte-identical to scripts/install.sh"
  (let [(s-res (file-read "scripts/install.sh"))
        (p-res (file-read "asl/web/public/install.sh"))
        (d-res (file-read "asl/dist/install.sh"))
        (w-res (file-read "asl/web/dist/install.sh"))]
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist")
    (assert (= (.-_tag p-res) "ok") "asl/web/public/install.sh must exist")
    (assert (= (.-_tag d-res) "ok") "asl/dist/install.sh must exist")
    (assert (= (.-_tag w-res) "ok") "asl/web/dist/install.sh must exist")
    (let [(s-src (.-value s-res))
          (p-src (.-value p-res))
          (d-src (.-value d-res))
          (w-src (.-value w-res))]
      (assert (= s-src p-src) "asl/web/public/install.sh must be byte-identical to scripts/install.sh")
      (assert (= s-src d-src) "asl/dist/install.sh must be byte-identical to scripts/install.sh")
      (assert (= s-src w-src) "asl/web/dist/install.sh must be byte-identical to scripts/install.sh")
      true)))

(df TestDriftDetectionContract [] -> Bool
  :d "Verifies scripts/install.sh enforces drift detection on modified distribution copies"
  (let [(s-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "cmp -s \"$SRC\" \"$target\"") "Must compare against canonical source using cmp")
      (assert (string-contains? s-src "drift detected in $target (not byte-identical to $SRC)") "Must report drift error")
      true)))

(df TestNestedDistPathEliminated [] -> Bool
  :d "Verifies nested dist/dist path detection and confirms zero nested dist directories exist"
  (let [(s-res (file-read "scripts/install.sh"))
        (dir-check (file-read "asl/dist/dist/install.sh"))]
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist")
    (assert (= (.-_tag dir-check) "err") "Nested asl/dist/dist/install.sh must not exist")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "find \"$ROOT_DIR\" -path \"*/dist/dist*\"") "Must search for nested dist directories")
      (assert (string-contains? s-src "nested dist directory detected:") "Must report nested dist error")
      true)))

(df TestGateIntegrationContract [] -> Bool
  :d "Verifies asl/tools/asl.c wires check_distribution_installers into Gate 7"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_distribution_installers") "asl.c must declare check_distribution_installers")
      (assert (string-contains? c-src "--check-installers") "asl.c must invoke --check-installers")
      (assert (string-contains? c-src "Distribution installers verified: single tracked source") "asl.c Gate 7 must report installer verification")
      true)))

(df TestRulePropagationSingleSource [] -> Bool
  :d "Verifies rule single source of truth rules.asn is projected through scripts/install.sh"
  (let [(r-res (file-read "asl/grammar/rules.asn"))
        (s-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist")
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist")
    (let [(r-src (.-value r-res))
          (s-src (.-value s-res))]
      (assert (string-contains? r-src "(:rules :v 7 :src ADR-0081") "rules.asn must be canonical v7")
      (assert (string-contains? s-src "asl/grammar/rules.asn") "scripts/install.sh must reference canonical rules.asn")
      true)))

(df TestTask45604GroundedInPhase456 [] -> Bool
  :d "Verifies Phase 456 task collection grounds Task45604"
  (let [(p-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 456 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Task45604") "Phase 456 must contain Task45604")
      (assert (string-contains? p-src "One install.sh, not four byte copies") "Phase 456 must state Task45604 title")
      (assert (string-contains? p-src "A single tracked installer") "Phase 456 must state single installer outcome")
      (assert (string-contains? p-src "Distribution copies verified identical or regenerated") "Phase 456 must state distribution copy outcome")
      (assert (string-contains? p-src "The nested dist path eliminated") "Phase 456 must state nested dist outcome")
      (assert (string-contains? p-src "SuperviseGate.sh Task45604") "Phase 456 must configure SuperviseGate.sh")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45604 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSingleTrackedInstallerSource) "TestSingleTrackedInstallerSource must pass")
    (assert (TestDistributionCopiesIdentical) "TestDistributionCopiesIdentical must pass")
    (assert (TestDriftDetectionContract) "TestDriftDetectionContract must pass")
    (assert (TestNestedDistPathEliminated) "TestNestedDistPathEliminated must pass")
    (assert (TestGateIntegrationContract) "TestGateIntegrationContract must pass")
    (assert (TestRulePropagationSingleSource) "TestRulePropagationSingleSource must pass")
    (assert (TestTask45604GroundedInPhase456) "TestTask45604GroundedInPhase456 must pass")
    true))
