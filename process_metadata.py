#!/usr/bin/env python3
"""Unify YAML frontmatter for all blog posts and reorganize into YYYY-MM/SLUG/ structure."""

import os
import re
import sys
import shutil
from datetime import datetime
import yaml

# ── Paths ──────────────────────────────────────────────────
PROJECT = "D:/CherryStudio/Code"
OLD_POSTS = os.path.join(PROJECT, ".old", "_posts")
OLD_DRAFTS = os.path.join(PROJECT, ".old", "_drafts")
CUR_POSTS = os.path.join(PROJECT, "_posts")
OUTPUT   = os.path.join(PROJECT, ".old")  # output root

# ── Standard field order ──────────────────────────────────
STANDARD_FIELDS = [
    "title", "date", "slug", "status", "visibility",
    "lastmod", "categories", "tags", "url", "description", "author",
]

# ── Slug from filename ────────────────────────────────────
def extract_slug(filename):
    stem = filename.replace(".md", "")
    # Try: YYYY-MM-DD-slug or YYYY-MM-DD-HHMM-slug
    m = re.match(r"^\d{4}-\d{2}-\d{2}-(.+)$", stem)
    if m:
        return m.group(1)
    # Draft: YYYY-MM-DD-HHMM (just use the HHMM as slug)
    m = re.match(r"^\d{4}-\d{2}-\d{2}-(\d{4})$", stem)
    if m:
        return m.group(1)
    # Current posts: YYYY-MM-DD-YYYY-Www-slug...
    m = re.match(r"^\d{4}-\d{2}-\d{2}-(.+)$", stem)
    if m:
        return m.group(1)
    return stem

# ── Date from filename ────────────────────────────────────
def date_from_filename(filename):
    stem = filename.replace(".md", "")
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})", stem)
    if m:
        return f"{m.group(1)}-{m.group(2)}-{m.group(3)}"
    return None

# ── Best-effort date extraction ──────────────────────────
def best_date(old_data, filename):
    """Try date field, then filename, then createdAt."""
    for key in ("date",):
        val = old_data.get(key)
        if val:
            if isinstance(val, datetime):
                return val.strftime("%Y-%m-%d")
            s = str(val).strip()
            if s:
                m = re.match(r"(\d{4}-\d{2}-\d{2})", s)
                if m:
                    return m.group(1)
    fd = date_from_filename(filename)
    if fd:
        return fd
    for key in ("createdAt",):
        val = old_data.get(key)
        if val:
            if isinstance(val, datetime):
                return val.strftime("%Y-%m-%d")
            s = str(val).strip()
            if s:
                m = re.match(r"(\d{4}-\d{2}-\d{2})", s)
                if m:
                    return m.group(1)
    return None

# ── Determine status ──────────────────────────────────────
def determine_status(old_data):
    if "status" in old_data and old_data["status"]:
        return old_data["status"]
    return "archived"

# ── Determine visibility ──────────────────────────────────
def determine_visibility(old_data):
    if "visibility" in old_data and old_data["visibility"]:
        return old_data["visibility"]
    if old_data.get("unlisted"):
        return "hidden"
    return "public"

# ── Determine lastmod ─────────────────────────────────────
def get_lastmod(old_data):
    for key in ("lastmod", "modifiedAt", "updatedAt"):
        if key in old_data and old_data[key]:
            val = old_data[key]
            if isinstance(val, datetime):
                return val.isoformat()
            return str(val)
    return ""

# ── YAML dump preserving order & multi-line ───────────────
class OrderedDumper(yaml.SafeDumper):
    pass

def str_representer(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)

OrderedDumper.add_representer(str, str_representer)

def dict_representer(dumper, data):
    return dumper.represent_mapping("tag:yaml.org,2002:map", data.items())

OrderedDumper.add_representer(dict, dict_representer)

# ── Process one file ──────────────────────────────────────
def process_file(filepath, source):
    """source: 'old_post' | 'draft' | 'cur_post'"""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Parse frontmatter
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?(.*)", content, re.DOTALL)
    if not m:
        print(f"  SKIP (no frontmatter): {filepath}")
        return None

    yaml_text = m.group(1)
    body = m.group(2)

    try:
        old_data = yaml.safe_load(yaml_text) or {}
    except yaml.YAMLError as e:
        print(f"  SKIP (yaml error): {filepath} — {e}")
        return None

    if not isinstance(old_data, dict):
        old_data = {}

    filename = os.path.basename(filepath)
    slug = extract_slug(filename)

    # ── Build new standardized data ──
    new = {}
    new["title"] = old_data.get("title", "")
    raw_date = old_data.get("date")
    if raw_date is None or (isinstance(raw_date, str) and raw_date.strip() == ""):
        raw_date = best_date(old_data, filename)
    new["date"] = raw_date or ""
    new["slug"] = slug
    new["status"] = determine_status(old_data)
    new["visibility"] = determine_visibility(old_data)
    new["lastmod"] = get_lastmod(old_data)
    new["categories"] = ["少作"]
    new["tags"] = old_data.get("tags", [])
    new["url"] = old_data.get("url", "")
    new["description"] = old_data.get("description", "")
    new["author"] = "高天驰"

    # ── Keep old fields NOT in standard set ──
    old_extra = {k: v for k, v in old_data.items() if k not in STANDARD_FIELDS}

    # ── Build output frontmatter dict ──
    result = {}
    for k in STANDARD_FIELDS:
        result[k] = new[k]
    for k, v in old_extra.items():
        result[k] = v

    # ── Output YAML ──
    # Custom serialization to keep field order
    lines = ["---"]
    for k, v in result.items():
        if v is None or (isinstance(v, str) and v == ""):
            # Just output key with empty value
            lines.append(f"{k}:")
        elif isinstance(v, list) and len(v) == 0:
            lines.append(f"{k}: []")
        elif isinstance(v, list):
            lines.append(f"{k}:")
            for item in v:
                lines.append(f"  - {item}")
        elif isinstance(v, datetime):
            lines.append(f"{k}: {v.isoformat()}")
        elif isinstance(v, bool):
            lines.append(f"{k}: {'true' if v else 'false'}")
        elif isinstance(v, str) and "\n" in v:
            lines.append(f"{k}: |")
            for line in v.rstrip().split("\n"):
                lines.append(f"  {line}")
        else:
            lines.append(f"{k}: {v}")
    lines.append("---")
    # Ensure blank line after ---
    if body.strip():
        lines.append("")
        lines.append(body.strip())
        lines.append("")
    else:
        lines.append("")

    return "\n".join(lines), slug, new["date"]

# ── Determine output dir ─────────────────────────────────
def output_dir(date_val, slug):
    """Get YYYY-MM/SLUG/ from date."""
    if not date_val:
        return None
    date_str = str(date_val)
    m = re.match(r"(\d{4})-(\d{2})", date_str)
    if m:
        return f"{m.group(1)}-{m.group(2)}", slug
    return None

# ── Main ──────────────────────────────────────────────────
def main():
    batches = [
        ("cur_post", CUR_POSTS),
    ]

    total = 0
    success = 0

    for source, directory in batches:
        if not os.path.isdir(directory):
            print(f"Directory not found: {directory}")
            continue

        files = sorted(os.listdir(directory))
        for fname in files:
            if not fname.endswith(".md") or fname in ("文章.md", "提示词.md"):
                continue

            fpath = os.path.join(directory, fname)
            print(f"[{source}] {fname}")

            result = process_file(fpath, source)
            if result is None:
                continue

            new_content, slug, date_val = result
            od = output_dir(date_val, slug)
            if od is None:
                print(f"  WARN: cannot determine date for {fname}, skipping")
                continue

            month_dir, _ = od
            target_dir = os.path.join(OUTPUT, month_dir, slug)
            os.makedirs(target_dir, exist_ok=True)

            target_file = os.path.join(target_dir, "index.md")
            # Avoid overwriting if already processed
            if os.path.exists(target_file):
                print(f"  WARN: {target_file} exists, skipping")
                continue

            with open(target_file, "w", encoding="utf-8") as f:
                f.write(new_content)

            print(f"  -> {target_file}")
            success += 1
            total += 1

    print(f"\nDone: {success}/{total} files processed successfully.")

if __name__ == "__main__":
    main()
