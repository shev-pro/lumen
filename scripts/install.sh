#!/usr/bin/env bash
# Lumen skill installer
# Usage:
#   bash scripts/install.sh              # install globally for Claude Code
#   bash scripts/install.sh --project    # install into current project's .claude/skills/
#   bash scripts/install.sh --cursor     # install for Cursor (global)
#   bash scripts/install.sh --all        # install for all supported tools
#
# Remote one-liner:
#   curl -fsSL https://raw.githubusercontent.com/shev-pro/lumen/main/scripts/install.sh | bash

set -euo pipefail

SKILL_NAME="lumen"
REPO_URL="${LUMEN_REPO_URL:-https://github.com/shev-pro/lumen.git}"
REPO_BRANCH="${LUMEN_REPO_BRANCH:-main}"

# Resolve SKILL_DIR. When piped via curl, BASH_SOURCE[0] is /dev/stdin and the
# repo is not on disk — clone it to a temp dir and use that copy.
resolve_skill_dir() {
  local script_path="${BASH_SOURCE[0]:-}"
  if [ -n "$script_path" ] && [ -f "$script_path" ]; then
    local candidate
    candidate="$(cd "$(dirname "$script_path")/../skills/lumen" 2>/dev/null && pwd || true)"
    if [ -n "$candidate" ] && [ -d "$candidate" ]; then
      echo "$candidate"
      return
    fi
  fi

  command -v git >/dev/null 2>&1 || { echo "git is required for remote install" >&2; exit 1; }
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "Cloning $REPO_URL ($REPO_BRANCH) ..." >&2
  git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$tmp/lumen" >&2
  echo "$tmp/lumen/skills/lumen"
}

SKILL_DIR="$(resolve_skill_dir)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_to() {
  local target="$1"
  local label="$2"
  mkdir -p "$target"
  cp -r "$SKILL_DIR/." "$target/"
  echo -e "${GREEN}✓${NC} Installed to $target  ($label)"
}

MODE="${1:-}"

case "$MODE" in
  --project)
    install_to ".claude/skills/$SKILL_NAME" "Claude Code — this project"
    ;;
  --cursor)
    install_to "$HOME/.cursor/skills/$SKILL_NAME" "Cursor — global"
    ;;
  --all)
    install_to "$HOME/.claude/skills/$SKILL_NAME"  "Claude Code — global"
    install_to "$HOME/.cursor/skills/$SKILL_NAME"  "Cursor — global"
    ;;
  "")
    install_to "$HOME/.claude/skills/$SKILL_NAME" "Claude Code — global"
    ;;
  *)
    echo "Unknown option: $MODE"
    echo "Usage: bash scripts/install.sh [--project | --cursor | --all]"
    exit 1
    ;;
esac

echo ""
echo -e "${YELLOW}Invoke with /lumen in Claude Code, Cursor, or any Agent Skills-compatible tool.${NC}"
