(module tests/acceptance/d81/Task48702
  :d "Acceptance fixture for Task48702: Pure ASL Self-Hosted Lexer, Parser and AST Generator under D86."
  :x [run-tests
      test-compiler-parser-exists
      test-compiler-target-symbols
      test-parsing-and-ast-generation]
  :i [])

(df test-compiler-parser-exists [] -> Bool
  :d "Verifies that asl/packages/asl-compiler/src/parser.asl exists and is readable"
  (let [(res (file-read "asl/packages/asl-compiler/src/parser.asl"))]
    (assert (= (.-_tag res) "ok") "asl/packages/asl-compiler/src/parser.asl must exist")
    true))

(df test-compiler-target-symbols [] -> Bool
  :d "Verifies that target and related symbols are defined in parser.asl"
  (let [(res (file-read "asl/packages/asl-compiler/src/parser.asl"))]
    (assert (= (.-_tag res) "ok") "parser.asl must be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "parse_asl_source") "parse_asl_source defined")
      (assert (string-contains? src "tokenize_asl") "tokenize_asl defined")
      (assert (string-contains? src "ast_builder") "ast_builder defined")
      (assert (string-contains? src "syntax_tree") "syntax_tree defined")
      true)))

(df test-parsing-and-ast-generation [] -> Bool
  :d "Verifies that parser.asl parses ASL source and generates valid AST"
  (let [(res (file-read "asl/packages/asl-compiler/src/parser.asl"))]
    (assert (= (.-_tag res) "ok") "parser.asl readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "module asl-compiler/parser") "module declaration present")
      (assert (string-contains? src ":asl-parser") "parser pipeline integration present")
      true)))

(df run-tests [] -> Bool
  :d "Runs all Task48702 acceptance assertions"
  (let [(r1 (test-compiler-parser-exists))
        (r2 (test-compiler-target-symbols))
        (r3 (test-parsing-and-ast-generation))]
    (assert (and (and r1 r2) r3) "All Task48702 checks must pass")
    true))
