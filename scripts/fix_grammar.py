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
    "txt/starts?", "txt/ends?", "txt/has?", "txt/split"
}

def to_camel_case(word):
    parts = word.split('-')
    if len(parts) == 1:
        return word
    return parts[0] + ''.join(p.capitalize() for p in parts[1:])

def process_grammar(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    def repl(m):
        prefix = m.group(1)
        word = m.group(2)
        suffix = m.group(3)
        if word in BUILTINS:
            return m.group(0)
        return prefix + to_camel_case(word) + suffix

    new_content = re.sub(r'(:name\s+")([a-z0-9]+(?:-[a-z0-9]+)+[?!]?)(")', repl, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        return True
    return False

def main():
    changed = 0
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file == 'grammar.asn':
                filepath = os.path.join(root, file)
                if process_grammar(filepath):
                    changed += 1
                    print(f"Updated {filepath}")
    print(f"Total grammar.asn updated: {changed}")

if __name__ == '__main__':
    main()
