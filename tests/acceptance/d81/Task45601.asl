(module tests/acceptance/d81/Task45601
  :d "Acceptance fixture for Task45601: Delete 371 redundant copies now that importing works, eliminate shadowing in sh-transpile, and record justified residue under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestShTranspileNoLongerShadowsImport
      TestCanonicalOwningPackages
      TestHarnessBalanceDelimitersSurvivorsEliminated
      TestCodecTranspileRedundantDefinitionsEliminated
      TestRedundantCopiesRecordedResidueWithJustification
      TestVerificationCasesContract
      TestTask45601GroundedInPhase456]
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

(df TestShTranspileNoLongerShadowsImport [] -> Bool
  :d "Verifies that asl-codec/src/sh-transpile.asl imports canonical asl-text/escape and no longer defines or exports escape-sh-arg"
  (let [(sh-res (file-read "asl/packages/asl-codec/src/sh-transpile.asl"))]
    (assert (= (.-_tag sh-res) "ok") "sh-transpile.asl must exist and be readable")
    (let [(sh-code (.-value sh-res))]
      (assert (string-contains? sh-code "asl-text/escape") "sh-transpile.asl must import canonical asl-text/escape")
      (assert (not (string-contains? sh-code "escape-sh-arg")) "sh-transpile.asl must not define or export escape-sh-arg")
      true)))

(df TestCanonicalOwningPackages [] -> Bool
  :d "Verifies canonical packages D34 assigns helpers to declare and export all target symbols"
  (let [(text-res (file-read "asl/packages/asl-text/src/text.asl"))
        (esc-res (file-read "asl/packages/asl-text/src/escape.asl"))
        (bal-res (file-read "asl/packages/asl-parser/src/balance.asl"))]
    (assert (= (.-_tag text-res) "ok") "text.asl must exist and be readable")
    (assert (= (.-_tag esc-res) "ok") "escape.asl must exist and be readable")
    (assert (= (.-_tag bal-res) "ok") "balance.asl must exist and be readable")
    (let [(text-code (.-value text-res))
          (esc-code (.-value esc-res))
          (bal-code (.-value bal-res))]
      (assert (string-contains? text-code "strip-quotes") "text.asl must export strip-quotes")
      (assert (string-contains? text-code "strip-colon") "text.asl must export strip-colon")
      (assert (string-contains? text-code "estimate-tokens") "text.asl must export estimate-tokens")
      (assert (string-contains? text-code "calc-savings") "text.asl must export calc-savings")
      (assert (string-contains? text-code "extract-between") "text.asl must export extract-between")
      (assert (string-contains? esc-code "escape-sh-arg") "escape.asl must export escape-sh-arg")
      (assert (string-contains? bal-code "balance-delimiters") "balance.asl must export balance-delimiters")
      true)))

(df TestHarnessBalanceDelimitersSurvivorsEliminated [] -> Bool
  :d "Verifies balance-delimiters survivors in harness are deleted and delegate to canonical asl-parser/balance"
  (let [(norm-res (file-read "harness/src/normalizer.asl"))
        (ah-res (file-read "harness/src/anti_hallucination.asl"))]
    (assert (= (.-_tag norm-res) "ok") "normalizer.asl must exist and be readable")
    (assert (= (.-_tag ah-res) "ok") "anti_hallucination.asl must exist and be readable")
    (let [(norm-code (.-value norm-res))
          (ah-code (.-value ah-res))]
      (assert (not (string-contains? norm-code "(df balance-delimiters")) "normalizer.asl must not define local balance-delimiters")
      (assert (not (string-contains? ah-code "(df balance-delimiters")) "anti_hallucination.asl must not define local balance-delimiters")
      (assert (string-contains? norm-code "asl-parser/balance") "normalizer.asl must import asl-parser/balance")
      (assert (string-contains? ah-code "asl-parser/balance") "anti_hallucination.asl must import asl-parser/balance")
      true)))

(df TestCodecTranspileRedundantDefinitionsEliminated [] -> Bool
  :d "Verifies redundant copies of estimate-tokens, calc-savings, strip-quotes, and strip-colon in asl-codec are removed"
  (let [(csv-res (file-read "asl/packages/asl-codec/src/csv-transpile.asl"))
        (toml-res (file-read "asl/packages/asl-codec/src/toml-transpile.asl"))
        (yaml-res (file-read "asl/packages/asl-codec/src/yaml-transpile.asl"))
        (svg-res (file-read "asl/packages/asl-codec/src/svg-transpile.asl"))
        (tr-res (file-read "asl/packages/asl-codec/src/transpile.asl"))]
    (assert (= (.-_tag csv-res) "ok") "csv-transpile.asl must exist")
    (assert (= (.-_tag toml-res) "ok") "toml-transpile.asl must exist")
    (assert (= (.-_tag yaml-res) "ok") "yaml-transpile.asl must exist")
    (assert (= (.-_tag svg-res) "ok") "svg-transpile.asl must exist")
    (assert (= (.-_tag tr-res) "ok") "transpile.asl must exist")
    (let [(csv-code (.-value csv-res))
          (toml-code (.-value toml-res))
          (yaml-code (.-value yaml-res))
          (svg-code (.-value svg-res))
          (tr-code (.-value tr-res))]
      (assert (not (string-contains? csv-code "(df estimate-tokens")) "csv-transpile must not define local estimate-tokens")
      (assert (not (string-contains? csv-code "(df calc-savings")) "csv-transpile must not define local calc-savings")
      (assert (not (string-contains? csv-code "(df strip-quotes")) "csv-transpile must not define local strip-quotes")
      (assert (not (string-contains? csv-code "(df strip-colon")) "csv-transpile must not define local strip-colon")
      (assert (not (string-contains? toml-code "(df estimate-tokens")) "toml-transpile must not define local estimate-tokens")
      (assert (not (string-contains? toml-code "(df calc-savings")) "toml-transpile must not define local calc-savings")
      (assert (not (string-contains? toml-code "(df strip-quotes")) "toml-transpile must not define local strip-quotes")
      (assert (not (string-contains? toml-code "(df strip-colon")) "toml-transpile must not define local strip-colon")
      (assert (not (string-contains? yaml-code "(df estimate-tokens")) "yaml-transpile must not define local estimate-tokens")
      (assert (not (string-contains? yaml-code "(df calc-savings")) "yaml-transpile must not define local calc-savings")
      (assert (not (string-contains? yaml-code "(df strip-quotes")) "yaml-transpile must not define local strip-quotes")
      (assert (not (string-contains? yaml-code "(df strip-colon")) "yaml-transpile must not define local strip-colon")
      (assert (not (string-contains? svg-code "(df estimate-tokens")) "svg-transpile must not define local estimate-tokens")
      (assert (not (string-contains? svg-code "(df calc-savings")) "svg-transpile must not define local calc-savings")
      (assert (not (string-contains? svg-code "(df strip-quotes")) "svg-transpile must not define local strip-quotes")
      (assert (not (string-contains? tr-code "(df estimate-tokens")) "transpile must not define local estimate-tokens")
      (assert (not (string-contains? tr-code "(df calc-savings")) "transpile must not define local calc-savings")
      (assert (not (string-contains? tr-code "(df strip-quotes")) "transpile must not define local strip-quotes")
      (assert (not (string-contains? tr-code "(df strip-colon")) "transpile must not define local strip-colon")
      true)))

(df TestRedundantCopiesRecordedResidueWithJustification [] -> Bool
  :d "Verifies that .asl/mem/duplication-residue.asn records baseline, remediated duplicates, and justified survivors under two strikes rule"
  (let [(r-res (file-read ".asl/mem/duplication-residue.asn"))]
    (assert (= (.-_tag r-res) "ok") ".asl/mem/duplication-residue.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src ":baselineRedundantCopies 371") "Must record 371 baseline redundant copies")
      (assert (string-contains? r-src ":remediatedSymbols") "Must record remediated symbol list")
      (assert (string-contains? r-src "estimate-tokens") "Must name estimate-tokens in residue ledger")
      (assert (string-contains? r-src "strip-quotes") "Must name strip-quotes in residue ledger")
      (assert (string-contains? r-src "strip-colon") "Must name strip-colon in residue ledger")
      (assert (string-contains? r-src "extract-between") "Must name extract-between in residue ledger")
      (assert (string-contains? r-src "calc-savings") "Must name calc-savings in residue ledger")
      (assert (string-contains? r-src "balance-delimiters") "Must name balance-delimiters in residue ledger")
      (assert (string-contains? r-src "escape-sh-arg") "Must name escape-sh-arg in residue ledger")
      (assert (string-contains? r-src ":justifiedSurvivors") "Must record justified survivors list")
      (assert (string-contains? r-src "skill-engine") "Must justify skill-engine domain-specific signature")
      true)))

(df TestVerificationCasesContract [] -> Bool
  :d "Verifies verification cases contract: centralised name redefinition rejected, import shadow rejected, unjustified residue rejected"
  (let [(task-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag task-res) "ok") "Phase456 task collection must be readable")
    (let [(task-src (.-value task-res))]
      (assert (string-contains? task-src "Adding a second definition of a centralised name fails the check") "Must record verification case 1")
      (assert (string-contains? task-src "A file that both imports a module and redefines one of its exports fails") "Must record verification case 2")
      (assert (string-contains? task-src "A survivor without a recorded justification fails, so the residue cannot grow quietly") "Must record verification case 3")
      true)))

(df TestTask45601GroundedInPhase456 [] -> Bool
  :d "Verifies Task45601 is registered in Phase456 task collection with all mandatory D52 metadata"
  (let [(c-res (file-read ".asl/mem/tasks/Phase456DuplicationDeadCodeAndUnwiredEradication.asn"))]
    (assert (= (.-_tag c-res) "ok") "Phase456DuplicationDeadCodeAndUnwiredEradication.asn must exist")
    (let [(src (.-value c-res))]
      (assert (string-contains? src ":id \"Task45601\"") "Must declare Task45601")
      (assert (string-contains? src ":gate \"sh tests/acceptance/d81/SuperviseGate.sh Task45601\"") "Must bind gate command")
      (assert (string-contains? src ":owns") "Must declare owned paths")
      (assert (string-contains? src "asl/packages/asl-codec/src") "Must own asl-codec/src")
      (assert (string-contains? src "asl/packages/asl-text/src") "Must own asl-text/src")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45601 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestShTranspileNoLongerShadowsImport) "TestShTranspileNoLongerShadowsImport must pass")
    (assert (TestCanonicalOwningPackages) "TestCanonicalOwningPackages must pass")
    (assert (TestHarnessBalanceDelimitersSurvivorsEliminated) "TestHarnessBalanceDelimitersSurvivorsEliminated must pass")
    (assert (TestCodecTranspileRedundantDefinitionsEliminated) "TestCodecTranspileRedundantDefinitionsEliminated must pass")
    (assert (TestRedundantCopiesRecordedResidueWithJustification) "TestRedundantCopiesRecordedResidueWithJustification must pass")
    (assert (TestVerificationCasesContract) "TestVerificationCasesContract must pass")
    (assert (TestTask45601GroundedInPhase456) "TestTask45601GroundedInPhase456 must pass")
    true))
