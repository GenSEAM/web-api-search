import os
import re

BUILTINS = {
    "mod", "checked-div", "checked-mod", "neg", "abs", "min", "max",
    "and", "or", "not",
    "string-length", "string-empty?", "str", "string-slice", "string-index-of", "string-contains?", "string-starts-with?", "string-ends-with?", "string-split", "string-join", "string-upper", "string-lower", "string-trim", "string-reverse", "string-replace", "string-chars", "string-from-int64", "string-from-float64", "string-to-int64", "string-to-float64",
    "int32-to-int64", "int64-to-int32", "int64-to-float64", "float64-to-int64",
    "list", "list-empty?", "list-length", "list-get", "list-head", "list-tail", "list-cons", "list-append", "list-reverse", "list-slice", "list-contains?", "list-index-of", "list-sort", "list-sort-by", "map", "filter", "fold", "range", "zip", "list-sum", "list-min", "list-max",
    "map-empty", "map-get", "map-set", "map-remove", "map-has?", "map-size", "map-keys", "map-values", "map-pairs", "map-from-pairs",
    "some", "none", "ok", "err", "is-some?", "is-none?", "is-ok?", "is-err?", "option-or", "result-or", "option-map", "result-map", "result-map-err", "option-to-result", "result-to-option", "pair",
    "not-found", "permission-denied", "already-exists", "invalid-path", "interrupted", "other", "read-line", "read-all", "print", "println", "eprintln", "file-read", "file-write", "file-append", "file-exists?",
    # also keywords
    "df", "dfs", "dfe", "let", "if", "module", "cond", "loop", "try", "assert", "refute",
    # module names that might look like words
    "asl-cli", "asl-help", "asl-lint", "asl-gates", "asl-eval", "asl-parser", "asl-checker", "asl-codegen", "asl-codec", "asl-compiler", "asl-bridge", "asl-sh", "asl-sql", "asl-text", "asl-registry", "asl-plugin", "agent-bus", "agent-core", "vdom", "voice", "mem"
}

def to_camel_case(word):
    parts = word.split('-')
    if len(parts) == 1:
        return word
    res = parts[0] + ''.join(p.capitalize() for p in parts[1:])
    return res

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    tokens = []
    i = 0
    while i < len(content):
        if content[i] == '"':
            start = i
            i += 1
            while i < len(content):
                if content[i] == '\\':
                    i += 2
                elif content[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
            tokens.append(('string', content[start:i]))
        elif content[i] == ';':
            start = i
            while i < len(content) and content[i] != '\n':
                i += 1
            tokens.append(('comment', content[start:i]))
        else:
            start = i
            while i < len(content) and content[i] not in ('"', ';'):
                i += 1
            tokens.append(('code', content[start:i]))

    new_content = []
    pattern = re.compile(r'(:?)([a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)+[?!]?)')
    
    for ttype, text in tokens:
        if ttype == 'code':
            def repl(m):
                prefix = m.group(1)
                word = m.group(2)
                if word in BUILTINS:
                    return m.group(0)
                if re.match(r'^[\d-]+$', word) or re.match(r'^[0-9a-fA-F-]+$', word):
                    return m.group(0)
                return prefix + to_camel_case(word)
            
            text = pattern.sub(repl, text)
            new_content.append(text)
        else:
            new_content.append(text)

    new_content_str = "".join(new_content)
    if new_content_str != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content_str)
        return True
    return False

def main():
    changed = 0
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file.endswith('.asl') or file.endswith('.asn'):
                filepath = os.path.join(root, file)
                if process_file(filepath):
                    changed += 1
                    print(f"Updated {filepath}")
    print(f"Total files updated: {changed}")

if __name__ == '__main__':
    main()
