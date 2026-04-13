# Rule File Guide

How `/lumen rules` generates and installs rule files for AI coding tools.

---

## Overview

Lumen generates rule files that tell AI agents to read project documentation before
acting. The rule content is identical across tools — only the file format and location
differ.

| Tool | Rule location | Format |
|------|--------------|--------|
| **Cursor** | `.cursor/rules/lumen.mdc` | MDC (YAML frontmatter + markdown) |
| **Claude Code** | `.claude/rules/lumen.md` | Markdown (plain, no frontmatter needed for global rules) |
| **Codex** | `AGENTS.md` (reads it directly) | Markdown |

The canonical rule content lives at `assets/lumen-rule.md`. The install script
at `scripts/install-rules.sh` copies it to the right places with the right format.

---

## Rule content

The rule file (`assets/lumen-rule.md`) is a static file that tells agents:

1. This project has Lumen-managed documentation
2. Which docs to read before starting any task
3. How to keep documentation current using Lumen commands

This file is the single source of truth. When updating the rule content, edit
`assets/lumen-rule.md` and re-run the install script — don't edit the copies directly.

---

## Tool-specific formats

### Cursor (.cursor/rules/lumen.mdc)

Cursor uses MDC format with YAML frontmatter. The install script wraps the rule
content with:

```yaml
---
description: Lumen project documentation — read docs before any task
globs:
alwaysApply: true
---
```

`alwaysApply: true` makes this an "Always" rule — loaded into context for every
interaction, which is what we want (docs should always be consulted).

### Claude Code (.claude/rules/lumen.md)

Claude Code rules are plain markdown files under `.claude/rules/`. Files without
`paths` frontmatter are unconditional — always loaded. The Lumen rule applies
globally, so no frontmatter is needed.

### Codex

Codex reads `AGENTS.md` directly as its project instruction file. No separate rule
file is needed. The Lumen section in `AGENTS.md` serves the same purpose.

Note: Codex `.rules` files are for execution policies (command allow/deny), not
for project instructions. Don't confuse the two.

---

## AGENTS.md and CLAUDE.md

`AGENTS.md` is the canonical entry point — the project overview, doc index, and
metadata. Both Codex and Claude Code read it (Claude Code via `CLAUDE.md` symlink).

### Lumen section in AGENTS.md

The `/lumen rules` command appends a Lumen section to `AGENTS.md`. This section
is different from the rule files above — it's richer, with the full command table
and skill trigger information:

```markdown
## Lumen — Project Documentation

This project's documentation was generated and is maintained by **Lumen**, a skill
that acts as the persistent knowledge keeper for this repository.

**Skill trigger:** any `/lumen` command, or mentions of "lumen", "knowledge base",
"document the project", or broad architectural questions.

### Before starting any task

1. Read `AGENTS.md` for the project overview, tech stack, and documentation index.
2. Read `docs/high-level-design.md` for architecture and component map.
3. For component-specific work, read `docs/<component-name>/README.md`.
4. Check `docs/codestyle.md` for project patterns and code style (if it exists).
5. Check `docs/rationale.md` for non-obvious decisions and their reasoning (if it exists).
6. Check `docs/integrations.md` for external service dependencies (if it exists).

### Keeping documentation current

This documentation is not static — use Lumen to keep it in sync with the code.
Manual edits are welcome (Lumen preserves them), but for structural updates prefer
Lumen commands so everything stays consistent.

| Command | Purpose |
|---------|---------|
| `/lumen scan` | Analyze code and update documentation |
| `/lumen update` | Quick sync from recent commits |
| `/lumen ingest` | Process raw files in docs/raw_data/ |
| `/lumen status` | Check coverage and freshness |
| `/lumen rules` | Regenerate these rule files |
| `/lumen <question>` | Query the documentation |
```

### CLAUDE.md symlink

`CLAUDE.md` should be a symlink to `AGENTS.md` so both Codex and Claude Code read
the same content. The install script handles this automatically.

```bash
ln -sf AGENTS.md CLAUDE.md
```

---

## Procedure for `/lumen rules`

1. **Run the install script** to copy rule files:
   ```bash
   bash skills/lumen/scripts/install-rules.sh .
   ```
   The script only does mechanical copying — no interactive logic, no AGENTS.md
   content management. It creates the Cursor and Claude Code rule files and
   sets up the CLAUDE.md symlink if AGENTS.md exists.

2. **Update AGENTS.md** (this is the agent's job, not the script's):
   - If `AGENTS.md` doesn't exist → create it using the AGENTS.md template from
     `references/templates.md`, then append the Lumen section above.
   - If `AGENTS.md` exists without a Lumen section → append the section.
   - If `AGENTS.md` exists with a Lumen section → update it in place.
   - If `CLAUDE.md` exists as a regular file (not symlink) → migrate its content
     into `AGENTS.md`, then replace with symlink (`ln -sf AGENTS.md CLAUDE.md`).

3. **Report** what was created or modified.

---

## Re-running rules

The install script is idempotent — safe to run multiple times. It overwrites rule
files with the latest content from `assets/lumen-rule.md`. It never touches
`AGENTS.md` content — that's always managed by the agent.
