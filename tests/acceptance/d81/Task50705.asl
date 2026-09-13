(module tests/acceptance/d81/Task50705
  :d "Acceptance fixture for Task 50705: Self-Hosted Tree-Walking Evaluator WASI Closure & Package Registration"
  :x [testEvaluatorIoBuiltins
      testEvaluatorSysExecSandboxedRefusal
      testCompileWasiTarget
      testEvaluatorDualPolarityRefutations
      RunTests]
  :i [(reader :a rd)
      (../../../asl/packages/asl-compiler/src/evaluator :a ev)
      (../../../asl/packages/asl-compiler/src/compiler :a comp)])

(df testEvaluatorIoBuiltins [] -> Bool
  :d "Verifies that file-read, file-exists?, and dir-list evaluate cleanly without ERR_UNKNOWN_PROCEDURE"
  (let [(env (ev/makeRootEnv))
        (readExpr (rd/makeList (list (rd/makeAtom "file-read") (rd/makeAtom "\"asl/packages/asl-compiler/src/wasi.asl\""))))
        (existsExpr (rd/makeList (list (rd/makeAtom "file-exists?") (rd/makeAtom "\"asl/packages/asl-compiler/src/wasi.asl\""))))
        (dirExpr (rd/makeList (list (rd/makeAtom "dir-list") (rd/makeAtom "\"asl/packages/asl-compiler/src\""))))
        (vRead (ev/evalSexpr readExpr env))
        (vExists (ev/evalSexpr existsExpr env))
        (vDir (ev/evalSexpr dirExpr env))]
    (mt vRead
      ((ev/valStr text)
       (do
         (assert (> (string-length text) 0) "Evaluated file-read must produce non-empty string")
         (refute (string-empty? text) "Evaluated file-read must not be empty")
         true))
      ((ev/valError msg) (assert false (str "file-read failed with error: " msg)))
      (_ false))
    (mt vExists
      ((ev/valBool b) (assert b "file-exists? must evaluate to true for wasi.asl"))
      (_ false))
    (mt vDir
      ((ev/valList items)
       (do
         (assert (not (list-empty? items)) "dir-list must return entries")
         (refute (list-empty? items) "dir-list must not be empty")
         true))
      (_ false))
    true))

(df testEvaluatorSysExecSandboxedRefusal [] -> Bool
  :d "Verifies that evaluating sys-exec in evaluator returns typed capability denial receipt with code 126"
  (let [(env (ev/makeRootEnv))
        (execExpr (rd/makeList (list (rd/makeAtom "sys-exec") (rd/makeAtom "\"echo forbidden\""))))
        (vExec (ev/evalSexpr execExpr env))]
    (mt vExec
      ((ev/valMap m)
       (let [(statusVal (option-or (map-get m "status") (ev/valStr "")))
             (codeVal (option-or (map-get m "code") (ev/valInt -1)))
             (errVal (option-or (map-get m "stderr") (ev/valStr "")))]
         (mt statusVal
           ((ev/valStr s)
            (do
              (assert (= s "refused") "Refusal status must be refused")
              (refute (= s "ok") "Subprocess status must not be ok")
              true))
           (_ false))
         (mt codeVal
           ((ev/valInt c)
            (do
              (assert (= c 126) "Refusal code must be 126")
              (refute (!= c 126) "Code must not deviate from 126")
              true))
           (_ false))
         (mt errVal
           ((ev/valStr msg)
            (do
              (assert (string-contains? msg "ERR_CAPABILITY_DENIED") "Stderr must contain ERR_CAPABILITY_DENIED")
              (refute (string-empty? msg) "Stderr must not be empty")
              true))
           (_ false))
         true))
      ((ev/valError err) (assert false (str "sys-exec must not produce unhandled valError: " err)))
      (_ false))))

(df testCompileWasiTarget [] -> Bool
  :d "Verifies compileSourceTarget for :target wasi produces valid WebAssembly binary bytecode"
  (let [(src "(df calculate-result [] -> I64 42)")
        (res (comp/compileSourceTarget src "wasi" (map-empty) "test.asl"))]
    (assert (.-ok res) "compileSourceTarget wasi must succeed")
    (refute (not (.-ok res)) "compileSourceTarget wasi must not report failure")
    (assert (> (string-length (.-code res)) 0) "Generated WASI bytecode string must not be empty")
    (refute (string-empty? (.-code res)) "WASI bytecode must not be empty")
    true))

(df testEvaluatorDualPolarityRefutations [] -> Bool
  :d "Verifies rejection of invalid builtins and traps under D77"
  (let [(env (ev/makeRootEnv))
        (unknownExpr (rd/makeList (list (rd/makeAtom "unknown-nonexistent-procedure-12345") (rd/makeAtom "1"))))
        (vUnknown (ev/evalSexpr unknownExpr env))]
    (mt vUnknown
      ((ev/valError msg)
       (do
         (assert (string-contains? msg "ERR_UNKNOWN_PROCEDURE") "Unknown procedure must produce ERR_UNKNOWN_PROCEDURE")
         (refute (string-empty? msg) "Error message must not be empty")
         true))
      (_ false))
    (let [(ioExpr (rd/makeList (list (rd/makeAtom "file-read") (rd/makeAtom "\"asl/packages/asl-compiler/src/wasi.asl\""))))
          (vIo (ev/evalSexpr ioExpr env))]
      (mt vIo
        ((ev/valError err)
         (do
           (refute (string-contains? err "ERR_UNKNOWN_PROCEDURE") "file-read must not trigger ERR_UNKNOWN_PROCEDURE")
           true))
        (_ true)))
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50705 acceptance tests"
  (do
    (assert (testEvaluatorIoBuiltins) "testEvaluatorIoBuiltins must pass")
    (assert (testEvaluatorSysExecSandboxedRefusal) "testEvaluatorSysExecSandboxedRefusal must pass")
    (assert (testCompileWasiTarget) "testCompileWasiTarget must pass")
    (assert (testEvaluatorDualPolarityRefutations) "testEvaluatorDualPolarityRefutations must pass")
    true))
