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
    "df", "dfs", "dfe", "let", "if", "module", "cond", "loop", "try", "assert", "refute",
    "asl-cli", "asl-help", "asl-lint", "asl-gates", "asl-eval", "asl-parser", "asl-checker", "asl-codegen", "asl-codec", "asl-compiler", "asl-bridge", "asl-sh", "asl-sql", "asl-text", "asl-registry", "asl-plugin", "agent-bus", "agent-core", "vdom", "voice", "mem"
}

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
            tokens.append(('string', content[start:i], start))
        elif content[i] == ';':
            start = i
            while i < len(content) and content[i] != '\n':
                i += 1
            tokens.append(('comment', content[start:i], start))
        else:
            start = i
            while i < len(content) and content[i] not in ('"', ';'):
                i += 1
            tokens.append(('code', content[start:i], start))

    pattern = re.compile(r'(:?)([a-z0-9]+(?:-[a-z0-9]+)+[?!]?)', re.IGNORECASE)
    
    found = []
    for ttype, text, start_idx in tokens:
        if ttype == 'code':
            for m in pattern.finditer(text):
                prefix = m.group(1)
                word = m.group(2)
                
                # Check if this word was excluded
                if word in BUILTINS:
                    continue
                # Dates, UUIDs
                if re.match(r'^[\d-]+$', word) or re.match(r'^[0-9a-fA-F-]+$', word):
                    continue
                # If it's a valid kebab-case word, wait, the pattern allows camelCase mixed with dashes?
                # Actually, if it has a dash, it wasn't converted!
                if '-' in word:
                    # Calculate line number
                    line_num = content.count('\n', 0, start_idx + m.start()) + 1
                    found.append((line_num, prefix + word))
    return found

def main():
    total = 0
    for root, dirs, files in os.walk('.'):
        if '.git' in root: continue
        for file in files:
            if file.endswith('.asl') or file.endswith('.asn'):
                filepath = os.path.join(root, file)
                res = process_file(filepath)
                if res:
                    print(f"\n{filepath}:")
                    for line_num, word in res:
                        print(f"  Line {line_num}: {word}")
                        total += 1
    print(f"\nTotal leftover kebab-case instances: {total}")

if __name__ == '__main__':
    main()
