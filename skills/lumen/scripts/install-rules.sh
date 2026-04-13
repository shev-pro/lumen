#!/usr/bin/env bash
#
# install-rules.sh — Copy Lumen rule files to Cursor and Claude Code locations.
#
# This script does one thing: copies the rule content from assets/lumen-rule.md
# into the correct locations with the correct format for each tool.
# It does NOT manage AGENTS.md content — that's the agent's job.
#
# Usage:  bash scripts/install-rules.sh <repo-root>

set -euo pipefail

REPO_ROOT="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RULE_SOURCE="$SKILL_DIR/assets/lumen-rule.md"
RULE_CONTENT="$(cat "$RULE_SOURCE")"

# --- Cursor (.cursor/rules/lumen.mdc) ---

mkdir -p "$REPO_ROOT/.cursor/rules"
cat > "$REPO_ROOT/.cursor/rules/lumen.mdc" <<EOF
---
description: Lumen project documentation — read docs before any task
globs:
alwaysApply: true
---

$RULE_CONTENT
EOF

# --- Claude Code (.claude/rules/lumen.md) ---

mkdir -p "$REPO_ROOT/.claude/rules"
cat > "$REPO_ROOT/.claude/rules/lumen.md" <<EOF
$RULE_CONTENT
EOF

# --- CLAUDE.md symlink ---

if [[ ! -e "$REPO_ROOT/CLAUDE.md" && -f "$REPO_ROOT/AGENTS.md" ]]; then
  ln -sf AGENTS.md "$REPO_ROOT/CLAUDE.md"
fi
