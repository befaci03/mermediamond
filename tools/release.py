#!/usr/bin/env python3
"""Stamp the `ver` file (dotenv format) for a release.

Usage:
    python3 tools/release.py 2.0.1-stable [--commit sha1]

- commit: full SHA-1 of HEAD (or --commit), written as "sha1:<hex>"
- version: x.x.x-(stable/beta/alpha/dev)
- hash: SHA-512 of the ver file content, written as "sha512:<hex>".
  Because the hash cannot cover itself, it is defined as the SHA-512 of
  the file content with the hash value replaced by 128 '0' characters
  (the placeholder). Verifiers must apply the same substitution before
  hashing.
"""
import subprocess, sys, os, hashlib, argparse

def get_full_commit() -> str:
    try: return subprocess.check_output( ["git", "rev-parse", "HEAD"], text=True).strip()
    except Exception: return "0" * 40
def render(commit: str, version: str, digest: str) -> bytes: return (f"commit;version;hash\ncommit=sha1:{commit}\nversion={version}\nhash=sha512:{digest}").encode()

PLACEHOLDER = "0" * 128
def verify_digest(content: bytes, digest: str) -> bool:
    """Check a stamped ver file against its own sha512:<hex> claim."""
    return hashlib.sha512(content.replace(digest.encode(), PLACEHOLDER.encode())).hexdigest() == digest

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("version", help="x.x.x-(stable/beta/alpha/dev)")
    ap.add_argument("--commit", default=None, help="override full commit sha1")
    args = ap.parse_args()

    if "-" not in args.version or args.version.split("-", 1)[1] not in ("stable", "beta", "alpha", "dev"):
        sys.exit("version must look like 2.1.0-(stable/beta/alpha/dev)")

    commit = args.commit or get_full_commit()

    # Hash of the content with the hash value replaced by the placeholder
    content = render(commit, args.version, PLACEHOLDER)
    digest = hashlib.sha512(content).hexdigest()
    result = render(commit, args.version, digest)
    assert verify_digest(result, digest)

    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    with open(os.path.join(here, "ver"), "wb") as f: f.write(result)
    print(f"stamped ver: commit=sha1:{commit[:12]}... version={args.version} hash=sha512:{digest[:16]}...")

if __name__ == "__main__":
    main()
