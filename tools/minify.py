#!/usr/bin/env python3
"""Build the minified distribution into minified/.

- Every .lua and .json file is minified; the root installer.lua is skipped
  (it is edited per-release and must stay readable/editable).
- Output is FLAT inside minified/ named:
      DIRECTORY.<id>.EXT
  where DIRECTORY is the file's parent folder ("server/config.lua" ->
  "server.<id>.lua"); files at the project root use their own basename
  ("updater.lua" -> "updater.<id>.lua"). <id> is a random 6-character
  [a-zA-Z0-9] tag, unique across one build.
- minified/.min.map maps every minified name back to its source path:
      { "server.512c...lua": "server/config.lua", ... }

Usage:
    python3 tools/minify.py            # build minified/
    python3 tools/minify.py --check    # verify the build (parse lua, map json)
"""
import json, os, random, re, string, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "minified")
MAP_FILE = os.path.join(OUT_DIR, ".min.map")
SKIP_FILES = {os.path.join(ROOT, "installer.lua")}  # never minified
SKIP_DIRS = {".git", "tools", "node_modules", ".mermediamond", "bank", "minified"}

# ---------------------------------------------------------------- name tag

_NAME_CHARS = string.ascii_letters + string.digits

def random_tag(used, length=6):
    """Random [a-zA-Z0-9] tag, unique within this build."""
    while True:
        tag = "".join(random.SystemRandom().choice(_NAME_CHARS) for _ in range(length))
        if tag not in used:
            used.add(tag)
            return tag

# ---------------------------------------------------------------- JSON

def minify_json_text(text):
    data = json.loads(text)
    return json.dumps(data, ensure_ascii=False, separators=(",", ":"))

# ---------------------------------------------------------------- Lua
# (same engine as before, with the comment bug fixed)

TOKEN_RE = re.compile(r"""
    (?P<line_comment>--[^\n]*)
  | (?P<block_comment>--\[(?P<ceqs>=*)\[)
  | (?P<long_open>\[(?P<eqs>=*)\[)
  | (?P<string>"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')
""", re.VERBOSE)


def close_for(eqs):
    return "]" + "=" * eqs + "]"


def strip_lua_comments(src):
    out = []
    i = 0
    n = len(src)
    while i < n:
        m = TOKEN_RE.match(src, i)
        if m is None:
            out.append(src[i])
            i += 1
            continue
        if m.group("line_comment") is not None:
            nl = src.find("\n", m.end())
            i = n if nl == -1 else nl
            continue
        if m.group("block_comment") is not None:
            close = close_for(len(m.group("ceqs")))
            end = src.find(close, m.end())
            i = n if end == -1 else end + len(close)
            out.append("\n")  # keep line structure
            continue
        if m.group("long_open") is not None:
            close = close_for(len(m.group("eqs")))
            end = src.find(close, m.end())
            end_idx = n if end == -1 else end + len(close)
            out.append(src[i:end_idx])
            i = end_idx
            continue
        out.append(m.group("string"))
        i = m.end()
    return "".join(out)


def has_unterminated_long_string(text):
    stripped = re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', "", text)
    opens = re.findall(r"\[(=*)\[", stripped)
    closes = re.findall(r"\](=*)\]", stripped)
    return len(opens) != len(closes)


def split_lua_lines(src):
    """Split into lines, keeping unterminated multi-line string literals intact."""
    out = []
    buf = None
    for line in src.split("\n"):
        if buf is not None:
            buf.append(line)
            if not has_unterminated_long_string("\n".join(buf)):
                out.append("\n".join(buf))
                buf = None
        elif has_unterminated_long_string(line): buf = [line]
        else: out.append(line)
    if buf is not None: out.append("\n".join(buf))
    return out


def minify_lua(src):
    src = strip_lua_comments(src)
    cleaned = []
    for line in split_lua_lines(src):
        if "\n" in line:  # multi-line literal: keep verbatim
            cleaned.append(line)
            continue
        s = line.strip()
        if s: cleaned.append(s)
    join_after = re.compile(r"(\bthen|\bdo|\belse|,|\band|\bor|\bnot|[+*/%^]=?|\.\.|[=<>~-])\s*$")
    join_before = re.compile(r"^\s*(\bthen\b|\bdo\b|\bend\b|\buntil\b|\band\b|\bor\b|\bin\b)")
    out = []
    for line in cleaned:
        if out and "\n" not in out[-1]:
            prev = out[-1]
            if (join_after.search(prev) or join_before.match(line)) and not _creates_comment(prev, line):
                out[-1] = prev + " " + line
                continue
        out.append(line)
    return "\n".join(out) + "\n"


def _creates_comment(prev, line):
    """A join must never produce a `--` sequence."""
    joined_tail = prev[-2:] + " " + line[:2]
    if "--" in joined_tail: return True
    return False


# ---------------------------------------------------------------- build

def minified_name(rel_path, used):
    folder = os.path.dirname(rel_path)
    base = folder if folder else os.path.basename(rel_path)
    return f"{base}.{random_tag(used)}{os.path.splitext(rel_path)[1]}"


def collect():
    targets = []
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in sorted(filenames):
            if not (name.endswith(".lua") or name.endswith(".json")): continue
            full = os.path.join(dirpath, name)
            if os.path.normpath(full) in {os.path.normpath(p) for p in SKIP_FILES}: continue
            targets.append(os.path.relpath(full, ROOT))
    return targets


def clean_outputs():
    """Remove every stale .min.* file and wipe the minified/ folder."""
    removed = 0
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if ".min." in name:
                os.remove(os.path.join(dirpath, name))
                removed += 1
    if os.path.isdir(OUT_DIR):
        import shutil
        shutil.rmtree(OUT_DIR)
        removed += 1
    return removed


def build():
    removed = clean_outputs()
    if removed: print(f"cleaned {removed} old artifact(s)")

    os.makedirs(OUT_DIR)
    mapping = {}
    used = set()
    total_src = total_min = 0
    for rel in collect():
        src_path = os.path.join(ROOT, rel)
        with open(src_path, "r", encoding="utf-8") as f: src = f.read()
        if rel.endswith(".json"): mini = minify_json_text(src)
        else: mini = minify_lua(src)
        name = minified_name(rel, used)
        with open(os.path.join(OUT_DIR, name), "w", encoding="utf-8") as f: f.write(mini)
        mapping[name] = rel
        total_src += len(src.encode("utf-8"))
        total_min += len(mini.encode("utf-8"))
        print(f"{rel} -> minified/{name}")
    with open(MAP_FILE, "w", encoding="utf-8") as f: json.dump(mapping, f, ensure_ascii=False, indent=2, sort_keys=True)
    saved = 100 * (1 - total_min / total_src) if total_src else 0
    print(f"\n{len(mapping)} file(s): {total_src} -> {total_min} bytes ({saved:.1f}% saved)")
    print(f"map: {MAP_FILE}")

def check():
    from lupa import LuaRuntime
    lua = LuaRuntime()
    bad = 0
    with open(MAP_FILE, "r", encoding="utf-8") as f: mapping = json.load(f)
    for name, rel in sorted(mapping.items()):
        path = os.path.join(OUT_DIR, name)
        content = open(path, encoding="utf-8").read()
        if name.endswith(".lua"):
            try: lua.execute("assert(load(%s))" % json.dumps(content))
            except Exception as e:
                print("PARSE FAIL", name, ":", str(e).split("\n")[0])
                bad += 1
        elif name.endswith(".json"):
            if json.loads(content) != json.loads(open(os.path.join(ROOT, rel), encoding="utf-8").read()):
                print("JSON MISMATCH", name)
                bad += 1
    print(f"check: {len(mapping)-bad}/{len(mapping)} OK" + ("" if bad == 0 else f" ({bad} FAILED)"))
    return bad == 0


if __name__ == "__main__":
    if "--check" in sys.argv or "-C" in sys.argv: sys.exit(0 if check() else 1)
    build()
