#!/usr/bin/env python3
"""Migrate images from assets/img/Public/ to co-locate with referencing Markdown files."""
import os
import re
import shutil
from pathlib import Path
from urllib.parse import unquote

REPO_ROOT = Path(__file__).parent.parent
SITE_CONTENT = Path(__file__).parent / "src" / "content"
ASSETS_IMG = REPO_ROOT / "assets" / "img" / "Public"

# Pattern 1: Obsidian embed ![[../../assets/img/Public/FILENAME]]
OBSIDIAN_PATTERN = re.compile(r'!\[\[(?:\.\./)*assets/img/Public/([^\]]+)\]\]')

# Pattern 2: Standard MD ![alt](../../../assets/img/Public/FILENAME)
MD_PATTERN = re.compile(r'!\[([^\]]*)\]\((?:\.\./)*assets/img/Public/([^)]+)\)')

def resolve_image(img_name: str) -> Path | None:
    """Try to find image file, handling URL-encoded names."""
    src = ASSETS_IMG / img_name
    if src.exists():
        return src
    # Try URL-decoded version
    decoded = unquote(img_name)
    src = ASSETS_IMG / decoded
    if src.exists():
        return src
    return None

def find_md_files(root: Path):
    for f in root.rglob("*.md"):
        yield f

def migrate():
    moved = 0
    replaced = 0
    errors = []

    for md_file in find_md_files(SITE_CONTENT):
        content = md_file.read_text(encoding="utf-8")
        new_content = content
        md_dir = md_file.parent

        # Process Obsidian-style embeds
        for match in OBSIDIAN_PATTERN.finditer(content):
            img_name = match.group(1)
            src = resolve_image(img_name)
            actual_name = unquote(img_name)
            dst = md_dir / actual_name
            if src and not dst.exists():
                shutil.copy2(src, dst)
                moved += 1
            elif not src:
                errors.append(f"NOT FOUND: {img_name} (referenced in {md_file.name})")
            old = match.group(0)
            new = f'![{actual_name}](./{actual_name})'
            new_content = new_content.replace(old, new)
            replaced += 1

        # Process standard MD images
        for match in MD_PATTERN.finditer(content):
            alt = match.group(1)
            img_name = match.group(2)
            src = resolve_image(img_name)
            actual_name = unquote(img_name)
            dst = md_dir / actual_name
            if src and not dst.exists():
                shutil.copy2(src, dst)
                moved += 1
            elif not src:
                errors.append(f"NOT FOUND: {img_name} (referenced in {md_file.name})")
            old = match.group(0)
            new = f'![{alt}](./{actual_name})'
            new_content = new_content.replace(old, new)
            replaced += 1

        if new_content != content:
            md_file.write_text(new_content, encoding="utf-8")

    print(f"Images copied: {moved}")
    print(f"References replaced: {replaced}")
    if errors:
        print(f"\nErrors ({len(errors)}):")
        for e in errors:
            print(f"  {e}")

if __name__ == "__main__":
    migrate()
