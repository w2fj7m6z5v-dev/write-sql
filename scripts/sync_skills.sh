#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/sync_skills.sh check
  bash scripts/sync_skills.sh sync agents --force
  bash scripts/sync_skills.sh sync claude --force

Modes:
  check                 Compare .agents/skills and .claude/skills.
  sync agents --force   Replace .claude/skills with .agents/skills.
  sync claude --force   Replace .agents/skills with .claude/skills.
USAGE
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
agents_root="$repo_root/.agents/skills"
claude_root="$repo_root/.claude/skills"
mode="${1:-check}"

check_dirs() {
  if [[ ! -d "$agents_root" ]]; then
    echo "Missing Codex skills directory: $agents_root" >&2
    exit 1
  fi
  if [[ ! -d "$claude_root" ]]; then
    echo "Missing Claude skills directory: $claude_root" >&2
    exit 1
  fi
}

check_sync() {
  check_dirs
  if diff -qr -x '*-workspace' "$agents_root" "$claude_root"; then
    echo "Skills are in sync."
    return 0
  fi

  echo "Skills differ. Choose a source, then run one of:" >&2
  echo "  bash scripts/sync_skills.sh sync agents --force" >&2
  echo "  bash scripts/sync_skills.sh sync claude --force" >&2
  return 2
}

sync_from() {
  local from="$1"
  local force="${2:-}"
  local source_root
  local target_root

  if [[ "$force" != "--force" ]]; then
    echo "Sync replaces the target skills directory. Re-run with --force." >&2
    exit 1
  fi

  check_dirs

  case "$from" in
    agents)
      source_root="$agents_root"
      target_root="$claude_root"
      echo "Syncing .agents/skills -> .claude/skills"
      ;;
    claude)
      source_root="$claude_root"
      target_root="$agents_root"
      echo "Syncing .claude/skills -> .agents/skills"
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac

  rsync -a --delete --exclude='*-workspace' "$source_root/" "$target_root/"
  check_sync
}

case "$mode" in
  check)
    check_sync
    ;;
  sync)
    sync_from "${2:-}" "${3:-}"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
