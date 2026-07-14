"""
@file lint_table_metadata.py
@description 检查表文档 frontmatter 的最小元数据规范，并输出覆盖率报告。

默认模式允许旧格式表文档存在，只检查已有 frontmatter 是否结构完整；
--strict 模式会把缺少 frontmatter 或必填字段的表文档视为失败，供迁移完成后接入质量门。
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


REQUIRED_FIELDS = ("table_id", "title", "hive_name", "grain", "partition_keys")
FIELD_PATTERN = re.compile(r"^([A-Za-z_][\w-]*):(?:\s|$)")


def read_frontmatter(path: Path) -> tuple[dict[str, str] | None, str | None]:
    """读取简单 YAML frontmatter，返回字段或结构错误。"""
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None, None
    end = text.find("\n---\n", 4)
    if end < 0:
        return None, "frontmatter_unclosed"

    fields: dict[str, str] = {}
    current_key = ""
    for line in text[4:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if line.lstrip().startswith("- "):
            if current_key:
                fields[current_key] = f"{fields[current_key]} {line.strip()}".strip()
            continue
        match = FIELD_PATTERN.match(line)
        if not match:
            return None, "frontmatter_malformed"
        current_key = match.group(1)
        fields[current_key] = line.split(":", 1)[1].strip()
    return fields, None


def lint(tables_dir: Path, strict: bool = False) -> dict[str, Any]:
    files = sorted(tables_dir.glob("*.md"))
    findings: list[dict[str, str]] = []
    frontmatter_count = 0
    field_counts = {field: 0 for field in REQUIRED_FIELDS}

    for path in files:
        fields, error = read_frontmatter(path)
        relative = str(path.relative_to(tables_dir)).replace("\\", "/")
        if error:
            findings.append({"path": relative, "kind": error, "severity": "risk"})
            continue
        if fields is None:
            if strict:
                findings.append(
                    {"path": relative, "kind": "frontmatter_missing", "severity": "risk"}
                )
            continue

        frontmatter_count += 1
        for field in REQUIRED_FIELDS:
            if fields.get(field, "").strip():
                field_counts[field] += 1
            elif strict:
                findings.append(
                    {
                        "path": relative,
                        "kind": "field_missing",
                        "field": field,
                        "severity": "risk",
                    }
                )

    total = len(files)
    summary = {
        "table_docs": total,
        "frontmatter_docs": frontmatter_count,
        "frontmatter_coverage": round(frontmatter_count / total, 4) if total else 1.0,
        "required_field_counts": field_counts,
        "finding_count": len(findings),
        "strict": strict,
        "passed": not findings,
    }
    return {"summary": summary, "findings": findings}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="检查表文档 frontmatter 元数据覆盖")
    parser.add_argument(
        "--tables-dir",
        default=".claude/skills/write-query/references/tables",
        help="表文档目录",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="要求每份表文档都有完整最小 frontmatter",
    )
    args = parser.parse_args(argv)

    tables_dir = Path(args.tables_dir)
    if not tables_dir.is_dir():
        print(f"找不到表文档目录: {tables_dir}", file=sys.stderr)
        return 2

    report = lint(tables_dir, strict=args.strict)
    report["source"] = str(tables_dir)
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if report["summary"]["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
