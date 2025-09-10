#!/usr/bin/env python3
"""
Move .sh files and files ending with 'backup' into an archive folder.

Defaults:
- root: current working directory
- archive: '<root>/archive'
- recursive: True
- dry-run: off

Examples:
    python move_to_archive.py
    python move_to_archive.py --root /path/to/project
    python move_to_archive.py --archive /path/to/archive
    python move_to_archive.py --dry-run
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path
from datetime import datetime

def is_target_file(path: Path) -> bool:
    """Return True if the file should be archived."""
    if not path.is_file():
        return False
    name = path.name
    if name.endswith(".sh"):
        return True
    # match filenames ending with 'backup' or '.backup'
    if name.endswith("backup") or name.endswith(".backup"):
        return True
    return False

def unique_dest(dest: Path) -> Path:
    """If dest exists, append a timestamp to avoid overwriting."""
    if not dest.exists():
        return dest
    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    stem = dest.stem
    suffix = dest.suffix
    # For files without suffix, dest.suffix == '', keep name clean
    return dest.with_name(f"{stem}.{ts}{suffix}")

def move_matches(root: Path, archive: Path, dry_run: bool = False, recursive: bool = True) -> int:
    """Scan root for matches and move them to archive. Returns count moved."""
    moved = 0

    # Ensure archive exists (unless dry-run)
    if not dry_run:
        archive.mkdir(parents=True, exist_ok=True)

    # Build iterator
    if recursive:
        iterator = (p for p in root.rglob("*"))
    else:
        iterator = (p for p in root.iterdir())

    # Avoid traversing into the archive dir if it is inside root
    archive_in_root = archive.resolve().is_relative_to(root.resolve()) if hasattr(Path, "is_relative_to") else str(archive.resolve()).startswith(str(root.resolve()))
    if archive_in_root:
        # If recursive, skip files inside archive
        def should_skip(p: Path) -> bool:
            try:
                return archive.resolve() in p.resolve().parents
            except Exception:
                return False
    else:
        def should_skip(p: Path) -> bool:
            return False

    for p in iterator:
        if should_skip(p):
            continue
        if is_target_file(p):
            dest = archive / p.name
            dest = unique_dest(dest)
            rel = p.relative_to(root)
            action = f"MOVE  {rel}  ->  {dest.relative_to(archive.parent) if dest.is_absolute() else dest}"
            if dry_run:
                print("[DRY-RUN]", action)
            else:
                try:
                    shutil.move(str(p), str(dest))
                    print(action)
                    moved += 1
                except Exception as e:
                    print(f"[ERROR] Failed to move {p}: {e}", file=sys.stderr)
    return moved

def parse_args():
    ap = argparse.ArgumentParser(description="Archive .sh and *backup files.")
    ap.add_argument("--root", type=Path, default=Path.cwd(), help="Root directory to scan (default: current dir)")
    ap.add_argument("--archive", type=Path, default=None, help="Archive directory (default: <root>/archive)")
    ap.add_argument("--no-recursive", action="store_true", help="Do not scan subdirectories")
    ap.add_argument("--dry-run", action="store_true", help="Show what would happen without moving files")
    return ap.parse_args()

def main():
    args = parse_args()
    root = args.root.resolve()
    archive = (args.archive or (root / "archive")).resolve()
    recursive = not args.no_recursive

    if not root.exists():
        print(f"[ERROR] Root does not exist: {root}", file=sys.stderr)
        sys.exit(1)

    print(f"Root:    {root}")
    print(f"Archive: {archive}")
    print(f"Mode:    {'DRY-RUN' if args.dry_run else 'EXECUTE'}")
    print(f"Depth:   {'recursive' if recursive else 'top-level only'}")
    print("-" * 60)

    count = move_matches(root, archive, dry_run=args.dry_run, recursive=recursive)
    print("-" * 60)
    if args.dry_run:
        print(f"[DRY-RUN] Files that would be moved: {count}")
    else:
        print(f"Files moved: {count}")

if __name__ == "__main__":
    main()

