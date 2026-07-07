#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# review-pr.sh — 本地交互式 PR 审核脚本
#
# 用法：
#   bash scripts/review-pr.sh <PR_NUMBER>
#   bash scripts/review-pr.sh          # 自动检测当前分支关联的 PR
#
# 流程：
#   1. 暂存本地修改（git stash）
#   2. 检出 PR 分支
#   3. 运行机械检查（同步、审计、索引校验）
#   4. 可选：运行 AI 深度审核
#   5. 恢复原分支和本地修改
#
# 依赖：git, gh CLI, python3, bash

set -euo pipefail

# ---- 颜色 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ---- 状态变量 ----
STASHED=false
ORIGINAL_BRANCH=""
PR_NUMBER="${1:-}"

# ---- 工具函数 ----
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

cleanup() {
  echo ""
  info "正在恢复工作区..."

  # 回到原分支
  if [ -n "$ORIGINAL_BRANCH" ]; then
    git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
    ok "已切回分支: $ORIGINAL_BRANCH"
  fi

  # 恢复 stash
  if [ "$STASHED" = true ]; then
    git stash pop 2>/dev/null || warn "stash pop 失败，请手动执行 git stash pop"
    ok "已恢复本地修改"
  fi

  echo ""
  info "审核流程结束。"
}
trap cleanup EXIT

# ---- 前置检查 ----
if ! command -v gh &>/dev/null; then
  error "未找到 gh CLI，请先安装: https://cli.github.com/"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  error "gh CLI 未登录，请先执行: gh auth login"
  exit 1
fi

# ---- 获取 PR 编号 ----
if [ -z "$PR_NUMBER" ]; then
  info "未指定 PR 编号，尝试从当前分支检测..."
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
  if [ -z "$PR_NUMBER" ]; then
    error "无法检测到关联的 PR，请手动指定: bash scripts/review-pr.sh <PR_NUMBER>"
    exit 1
  fi
  info "检测到 PR #$PR_NUMBER"
fi

# ---- 第一步：保存当前状态 ----
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
info "当前分支: $ORIGINAL_BRANCH"

if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  info "工作区有未提交修改，执行 git stash ..."
  git stash push -m "review-pr-$(date +%s)" --include-untracked
  STASHED=true
  ok "已暂存本地修改"
else
  info "工作区干净，无需 stash"
fi

# ---- 第二步：检出 PR ----
echo ""
info "正在检出 PR #$PR_NUMBER ..."
if ! gh pr checkout "$PR_NUMBER"; then
  error "PR #$PR_NUMBER 检出失败"
  exit 1
fi
ok "PR #$PR_NUMBER 已检出"

# ---- 第三步：机械检查 ----
echo ""
echo "============================================"
echo "  机械检查"
echo "============================================"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

CHECK_RESULTS=""

# 3a. 双入口一致性
echo ""
info "检查 1/3: 双入口一致性..."
if bash scripts/sync_skills.sh check 2>&1; then
  ok "双入口一致性: 通过"
else
  SYNC_EXIT=$?
  if [ $SYNC_EXIT -eq 2 ]; then
    warn "双入口一致性: 不一致！请同步后再提交。"
    CHECK_RESULTS="$CHECK_RESULTS\n  - 双入口不一致，需同步 .agents/skills/ 和 .claude/skills/"
  else
    warn "双入口一致性: 检查失败（退出码 $SYNC_EXIT）"
  fi
fi

# 3b. SQL 审计
echo ""
info "检查 2/3: SQL 静态审计..."
SQL_FILES=$(git diff --name-only --diff-filter=ACMRT origin/main...HEAD 2>/dev/null | grep '\.sql$' || true)
if [ -z "$SQL_FILES" ]; then
  ok "无 SQL 文件变更，跳过审计"
else
  SQL_HAS_RISK=0
  while IFS= read -r f; do
    if [ -f "$f" ]; then
      echo "  ---"
      if python .claude/skills/write-query/scripts/audit_sql.py "$f" --format text 2>&1; then
        echo "  ok: $f"
      else
        echo "  risk in: $f"
        SQL_HAS_RISK=1
      fi
    fi
  done <<< "$SQL_FILES"
  if [ $SQL_HAS_RISK -eq 0 ]; then
    ok "SQL 审计: 全部通过"
  else
    warn "SQL 审计: 发现风险项"
    CHECK_RESULTS="$CHECK_RESULTS\n  - SQL 文件存在风险项，需修复"
  fi
fi

# 3c. METRIC_INDEX 校验
echo ""
info "检查 3/3: METRIC_INDEX 引用校验..."
METRIC_FILES=$(git diff --name-only --diff-filter=ACMRT origin/main...HEAD 2>/dev/null | grep 'METRIC_INDEX\.md$' || true)
if [ -z "$METRIC_FILES" ]; then
  ok "METRIC_INDEX.md 未变更，跳过校验"
else
  LINT_TARGET=$(echo "$METRIC_FILES" | head -1)
  if python .claude/skills/write-query/scripts/lint_metric_index.py --index "$LINT_TARGET" 2>&1; then
    ok "METRIC_INDEX 校验: 通过"
  else
    warn "METRIC_INDEX 校验: 发现缺失引用"
    CHECK_RESULTS="$CHECK_RESULTS\n  - METRIC_INDEX.md 存在断链引用"
  fi
fi

# ---- 第四步：机械检查总结 ----
echo ""
echo "============================================"
echo "  机械检查总结"
echo "============================================"
if [ -z "$CHECK_RESULTS" ]; then
  ok "全部机械检查通过！"
else
  warn "机械检查发现问题:"
  echo -e "$CHECK_RESULTS"
fi

# ---- 第五步：AI 深度审核 ----
echo ""
echo "============================================"
echo "  AI 深度审核"
echo "============================================"
echo ""
echo "变更文件:"
git diff --name-only --diff-filter=ACMRT origin/main...HEAD 2>/dev/null | head -20 | sed 's/^/  /'

echo ""
echo -e "${YELLOW}是否运行 AI 深度审核？${NC}"
echo "  - 审核将使用 Claude Code 的 code-reviewer agent（Opus 模型）"
echo "  - 会分析业务口径、SQL 语义、安全性和可维护性"
echo ""
read -r -p "运行 AI 审核？[y/N] " AI_REVIEW

if [ "$AI_REVIEW" = "y" ] || [ "$AI_REVIEW" = "Y" ]; then
  echo ""
  info "请在此 Claude Code 会话中运行以下命令进行 AI 审核："
  echo ""
  echo -e "  ${GREEN}/code-review${NC}  — 审核当前 diff"
  echo -e "  ${GREEN}/review${NC}       — 审核 GitHub PR"
  echo ""
  echo "或者直接告诉我："
  echo -e "  ${GREEN}请审核这个 PR #$PR_NUMBER 的变更，重点关注 SQL 口径正确性和双入口一致性${NC}"
  echo ""
  echo "审核完成后，我会自动恢复原分支和本地修改。"
else
  info "跳过 AI 审核。"
fi

echo ""
info "按 Enter 键恢复工作区..."
read -r