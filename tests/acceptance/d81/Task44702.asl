(module tests/acceptance/d81/Task44702
  :d "Acceptance fixture for Task44702: Retire mishearing from artifact names under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestHarnessProfileArtifactContract
      TestHarnessConfigArtifactContract
      TestAudioBridgeTestContract
      TestVoiceManifestContract
      TestTask44702GroundedInPhase447]
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

(df TestHarnessProfileArtifactContract [] -> Bool
  :d "Verifies voice/src/harness_profile.asl exists and defines canonical HarnessProfile structs"
  (let [(h-res (file-read "voice/src/harness_profile.asl"))]
    (assert (= (.-_tag h-res) "ok") "voice/src/harness_profile.asl must exist and be readable")
    (let [(h-src (.-value h-res))]
      (assert (string-contains? h-src "module asl-voice/harness-profile") "Module must be renamed to asl-voice/harness-profile")
      (assert (string-contains? h-src "HarnessPhoneticAlias") "Struct must be renamed to HarnessPhoneticAlias")
      (assert (string-contains? h-src "HarnessHardwareEndpoint") "Struct must be renamed to HarnessHardwareEndpoint")
      (assert (string-contains? h-src "HarnessProfile") "Struct must be renamed to HarnessProfile")
      (assert (string-contains? h-src "make-default-harness-profile") "Function must be renamed to make-default-harness-profile")
      (assert (string-contains? h-src "format-harness-profile-asn") "Function must be renamed to format-harness-profile-asn")
      true)))

(df TestHarnessConfigArtifactContract [] -> Bool
  :d "Verifies .asl/harness.config.asn exists with canonical harness-config form"
  (let [(c-res (file-read ".asl/harness.config.asn"))]
    (assert (= (.-_tag c-res) "ok") ".asl/harness.config.asn must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src ":harness-config") "Config must declare :harness-config root")
      (assert (string-contains? c-src "harness-workstation") "Config must name harness-workstation profile")
      true)))

(df TestAudioBridgeTestContract [] -> Bool
  :d "Verifies voice/tests/audio_bridge_test.asl imports and tests harness-profile"
  (let [(t-res (file-read "voice/tests/audio_bridge_test.asl"))]
    (assert (= (.-_tag t-res) "ok") "voice/tests/audio_bridge_test.asl must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "asl-voice/harness-profile") "Test must import asl-voice/harness-profile")
      (assert (string-contains? t-src "test-harness-profile-defaults-and-aliases") "Test must execute test-harness-profile")
      true)))

(df TestVoiceManifestContract [] -> Bool
  :d "Verifies voice/manifest.asn registers canonical asl-voice/harness-profile"
  (let [(m-res (file-read "voice/manifest.asn"))]
    (assert (= (.-_tag m-res) "ok") "voice/manifest.asn must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "asl-voice/harness-profile") "Manifest must register asl-voice/harness-profile")
      true)))

(df TestTask44702GroundedInPhase447 [] -> Bool
  :d "Verifies Phase 447 task collection grounds Task44702"
  (let [(p-res (file-read ".asl/mem/tasks/Phase447CanonicalLexiconCrossClient.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 447 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Retire the mishearing from artifact names: hyness becomes harness") "Phase 447 must state Task44702 title")
      (assert (string-contains? p-src "Module, structs, file and config renamed") "Phase 447 must state rename outcome")
      (assert (string-contains? p-src "Rename mapping recorded for older configs") "Phase 447 must state backward compatibility outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44702 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestHarnessProfileArtifactContract) "TestHarnessProfileArtifactContract must pass")
    (assert (TestHarnessConfigArtifactContract) "TestHarnessConfigArtifactContract must pass")
    (assert (TestAudioBridgeTestContract) "TestAudioBridgeTestContract must pass")
    (assert (TestVoiceManifestContract) "TestVoiceManifestContract must pass")
    (assert (TestTask44702GroundedInPhase447) "TestTask44702GroundedInPhase447 must pass")
    true))
