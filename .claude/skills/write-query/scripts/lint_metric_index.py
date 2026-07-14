"""
@file lint_metric_index.py
@description 校验 METRIC_INDEX.md 中所有指标表的结构、唯一 ID 和文件链接。
             同时检查 metrics/ 下是否存在未登记的指标文件。输出 JSON 报告，
             发现问题时退出码非零。

依赖：Python 3.8+，仅标准库。
用法：
    python lint_metric_index.py [--index .claude/skills/write-query/references/METRIC_INDEX.md]
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


SEPARATOR_CELL = re.compile(r"^\s*:?-{3,}:?\s*$")


def parse_metric_index(text: str) -> list[dict[str, str]]:
    """解析文档中所有包含 metric_id 的 Markdown 指标表。

    返回每行的字段 dict（含 metric_id, metric_name, ..., table_files, metric_file）。
    """
    lines = text.splitlines()
    rows: list[dict[str, str]] = []
    idx = 0
    while idx < len(lines):
        stripped = lines[idx].strip()
        if not stripped.startswith("|") or not stripped.endswith("|"):
            idx += 1
            continue

        header_cols = [c.strip() for c in stripped.strip("|").split("|")]
        if "metric_id" not in header_cols:
            idx += 1
            continue
        if idx + 1 >= len(lines):
            break

        separator = [c.strip() for c in lines[idx + 1].strip().strip("|").split("|")]
        if len(separator) != len(header_cols) or not all(
            SEPARATOR_CELL.match(cell) for cell in separator
        ):
            idx += 1
            continue

        idx += 2
        while idx < len(lines):
            row_line = lines[idx].strip()
            if not row_line.startswith("|") or not row_line.endswith("|"):
                break
            cols = [c.strip() for c in row_line.strip("|").split("|")]
            if len(cols) == len(header_cols):
                rows.append(dict(zip(header_cols, cols)))
            idx += 1
    return rows


def check_path(base: Path, relative: str) -> bool:
    """检查 base 路径下的相对路径是否存在。"""
    relative = relative.strip()
    if not relative:
        return False
    relative = relative.replace("\\", "/").lstrip("./")
    return (base / relative).exists()


def split_table_files(cell: str) -> list[str]:
    """table_files 单元格可能含多个路径（顿号/逗号/空白分隔）。

    特殊值「以单指标技术口径 SQL 的 FROM 为准」表示无明确表文档，跳过校验。
    """
    if not cell:
        return []
    if "FROM 为准" in cell or "口径" in cell and "为准" in cell:
        return []
    parts = re.split(r"[、，,;\s]+", cell)
    return [p for p in parts if p]


def lint(index_path: Path) -> dict[str, Any]:
    text = index_path.read_text(encoding="utf-8")
    base_dir = index_path.parent
    rows = parse_metric_index(text)

    findings: list[dict[str, Any]] = []
    metric_files: set[str] = set()
    metric_ids: dict[str, int] = {}

    for row_number, row in enumerate(rows, start=1):
        mid = row.get("metric_id", "")
        metric_file = row.get("metric_file", "").strip()
        table_files = split_table_files(row.get("table_files", ""))

        if not mid:
            findings.append({"row": row_number, "kind": "metric_id_empty", "severity": "risk"})
        elif mid in metric_ids:
            findings.append(
                {
                    "metric_id": mid,
                    "row": row_number,
                    "kind": "metric_id_duplicate",
                    "first_row": metric_ids[mid],
                    "severity": "risk",
                }
            )
        else:
            metric_ids[mid] = row_number

        if metric_file:
            normalized_metric_file = metric_file.replace("\\", "/").lstrip("./")
            metric_files.add(normalized_metric_file)
            if not check_path(base_dir, metric_file):
                findings.append(
                    {
                        "metric_id": mid,
                        "kind": "metric_file_missing",
                        "path": metric_file,
                        "severity": "risk",
                    }
                )
        else:
            findings.append(
                {
                    "metric_id": mid,
                    "kind": "metric_file_empty",
                    "path": "",
                    "severity": "risk",
                }
            )

        for tf in table_files:
            if not check_path(base_dir, tf):
                findings.append(
                    {
                        "metric_id": mid,
                        "kind": "table_file_missing",
                        "path": tf,
                        "severity": "warn",
                    }
                )
    metrics_dir = base_dir / "metrics"
    if metrics_dir.exists():
        actual_metric_files = {
            str(path.relative_to(base_dir)).replace("\\", "/")
            for path in metrics_dir.rglob("*.md")
        }
        for orphan in sorted(actual_metric_files - metric_files):
            findings.append(
                {
                    "kind": "metric_file_orphan",
                    "path": orphan,
                    "severity": "risk",
                }
            )

    summary = {
        "total_rows": len(rows),
        "metric_id_count": len(metric_ids),
        "metric_file_count": len(metric_files),
        "metric_file_actual_count": len(actual_metric_files) if metrics_dir.exists() else 0,
        "finding_count": len(findings),
        "passed": not findings,
    }
    return {"summary": summary, "findings": findings}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="校验 METRIC_INDEX.md 引用路径")
    parser.add_argument(
        "--index",
        default=".claude/skills/write-query/references/METRIC_INDEX.md",
        help="METRIC_INDEX.md 路径",
    )
    parser.add_argument("--out", default=None, help="JSON 报告输出（缺省 stdout）")
    args = parser.parse_args(argv)

    index_path = Path(args.index)
    if not index_path.exists():
        print(f"找不到 METRIC_INDEX: {index_path}", file=sys.stderr)
        return 2

    report = lint(index_path)
    report["source"] = str(index_path)
    payload = json.dumps(report, ensure_ascii=False, indent=2)

    if args.out:
        Path(args.out).write_text(payload, encoding="utf-8")
    print(payload)

    return 0 if report["summary"]["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
