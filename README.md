<p align="center">
  <img src="lumen.jpeg" alt="Lumen — Macroknowledge Refinement System" width="700">
</p>

<h1 align="center">Lumen</h1>

<p align="center">
  <strong>The persistent knowledge keeper for any Git repository.</strong><br>
  An agentic skill that builds, maintains, and serves structured documentation — for both humans and AI agents.
</p>

<p align="center">
  <code>/lumen init</code> · <code>/lumen scan</code> · <code>/lumen ingest</code> · <code>/lumen update</code> · <code>/lumen status</code> · <code>/lumen lint</code> · <code>/lumen rules</code> · <code>/lumen &lt;question&gt;</code>
</p>

---

## What is Lumen?

Lumen is an agentic persona that acts as the living memory of a codebase. It accumulates, structures, and serves project knowledge across sessions — so every future interaction starts informed, not from scratch.

It produces three things:

1. **Documentation** (`docs/`) — structured markdown files, committed to Git
2. **Rule files** — for Cursor (`.cursor/rules/lumen.mdc`), Claude Code (`.claude/rules/lumen.md`), and Codex (`AGENTS.md`) — so any AI agent reads the docs before acting
3. **Raw data inbox** (`docs/raw_data/`) — local staging area for ingesting meeting notes, emails, screenshots, and specs

## Principles

- **Two sources of truth.** Code is the source of truth for implementation — docs point to it, never duplicate it. Project artifacts (meetings, specs, decisions, stakeholder context) are the source of truth for context and rationale — ingested and synthesized, not replaced by the code.
- **Compound over time.** Every scan, ingest, query, and lint pass makes the wiki richer. Notable answers get filed, contradictions flagged, gaps surfaced. Knowledge not persisted is knowledge lost.
- **Concise over comprehensive.** Each doc earns its existence.
- **Pointers over explanations.** Link to `file:function()`, don't re-describe code.
- **Mermaid diagrams** for architecture, data flow, and sequences.
- **One level of depth per document.** `AGENTS.md` → topic docs → code.

## Commands

| Command | What it does |
|---------|-------------|
| `/lumen init` | Build a project fingerprint and bootstrap the docs structure |
| `/lumen scan` | Analyze code and generate/update documentation (with parallel agents) |
| `/lumen ingest` | Absorb raw files (transcripts, emails, screenshots, docs) into structured docs |
| `/lumen update` | Incremental sync from recent git commits |
| `/lumen status` | Show documentation coverage, freshness, and gaps |
| `/lumen lint` | Audit documentation health: contradictions, stale claims, orphans, broken refs |
| `/lumen rules` | Install rule files for Cursor, Claude Code, and Codex |
| `/lumen <question>` | Query the documentation in natural language (and optionally file the answer as a new page) |

## Project Fingerprint

Instead of sizing projects as small/medium/large by package count, Lumen builds a
**multidimensional fingerprint** that captures:

- **Project type** — API service, frontend, CLI, library, IaC, data pipeline, monorepo, etc.
- **Complexity signals** — entry point count, integration density, domain complexity, language diversity
- **Maturity signals** — repo age, existing docs, test coverage, CI/CD, contributor count

The fingerprint drives which documents to create, which components to scan, and at
what depth. An empty repo triggers **bootstrapping mode** — Lumen asks what you're
planning to build and creates a provisional structure.

## Document Structure

Lumen generates a `docs/` hierarchy tailored to the project's nature. The fingerprint
determines which documents earn their place.

```
AGENTS.md                       # Entry point — project overview + doc index
docs/
├── log.md                      # Append-only operation log (always created)
├── high-level-design.md        # Architecture, component map, key decisions
├── <component>/                # Per-component folder
│   ├── README.md               # Component deep dive
│   ├── api.md                  # API surface (if applicable)
│   └── data-model.md           # Data model (if applicable)
├── api.md                      # Global API reference
├── data-model.md               # Database schema, entities, migrations
├── integrations.md             # External services and third-party dependencies
├── codestyle.md                # Naming, patterns, idioms
├── rationale.md                # Non-obvious technical decisions with reasoning (ADR format)
├── project-context.md          # Stakeholder context, requirements, business constraints
├── deployment.md               # Build, deploy, CI/CD, monitoring
└── raw_data/                   # Local inbox for /lumen ingest
```

`rationale.md` captures *technical decisions* ("we chose Postgres over MySQL because…"). `project-context.md` captures the *business and stakeholder layer* that surrounds them ("client requires GDPR compliance", "product team prioritizes mobile-first"). When a decision is driven by a business constraint, record the constraint in `project-context.md` and link to it from the rationale entry.

`log.md` is append-only: every `/lumen` command adds a one-line entry (`## [YYYY-MM-DD] <command> | <summary>`). Parse with `grep "^## \[" docs/log.md | tail -10`.

## Scan Depths

Not every component deserves the same documentation effort. Lumen assigns a scan
depth to each component based on its role and complexity:

| Depth | When | What it produces |
|-------|------|-----------------|
| **Deep** | Core domain, complex logic, high integration density | Full README, diagrams, flows, rationale discovery |
| **Standard** | Clear responsibility, moderate complexity | README with key files, dependencies, one primary flow |
| **Light** | Thin wrappers, adapters, config modules | 3–5 line README pointing to source |

## Parallel Scan

For repos with 3+ components, `/lumen scan` uses a three-phase orchestration model:

1. **Fingerprint, Plan & Global Scan** — build/load fingerprint, assign scan depths, write global docs
2. **Parallel Discovery** — one subagent per component with depth-specific prompts, writing concurrently to isolated paths
3. **Synthesize** — cross-reference, validate quality, consolidate integrations, report results

Batching is adaptive: up to 5 components at once, larger repos in groups of 5.

## Knowledge Ingestion

`/lumen ingest` processes files dropped into `docs/raw_data/` (transcripts, emails,
screenshots, documents). Knowledge is **absorbed, not referenced** — raw files are
gitignored, so the extracted information is woven directly into existing docs. Decisions
not yet implemented go into `rationale.md`; future plans and ideas get dedicated
sections in the most relevant doc.

## Lint — Documentation Health

Where `/lumen status` measures *coverage* (what exists), `/lumen lint` measures *health*:

- **Contradictions** — same fact stated differently across docs (config values, ownership, architecture claims)
- **Stale claims** — rationale entries marked "not yet implemented" that appear to have shipped, component docs referring to renamed/deleted files
- **Orphan pages** — docs not linked from `AGENTS.md` or any other doc
- **Orphan concepts** — terms mentioned in 3+ docs with no dedicated page
- **Broken references** — `file:function()` pointers to code that no longer exists

Findings are reported grouped by severity; Lumen never silently resolves contradictions. Run periodically or after a burst of ingests/updates.

## Query → Wiki Growth

`/lumen <question>` answers in natural language, but when the answer required non-trivial synthesis across multiple docs, Lumen offers to file it as a new page. Accepted answers become part of the wiki — the next session starts with them already understood. Q&A sessions compound into durable knowledge.

## Rationale Discovery

During deep scans, Lumen flags code that looks unusual or contrary to best practices.
Instead of assuming it's a mistake, it proposes hypotheses to the user and captures
confirmed rationale in `docs/rationale.md` using ADR format.

## Rule Files

`/lumen rules` installs rule files for multiple AI coding tools from a single source
of truth (`assets/lumen-rule.md`):

| Tool | Location | Format |
|------|----------|--------|
| Cursor | `.cursor/rules/lumen.mdc` | MDC with YAML frontmatter (`alwaysApply: true`) |
| Claude Code | `.claude/rules/lumen.md` | Plain markdown (unconditional) |
| Codex | `AGENTS.md` | Reads it directly |

The install script (`scripts/install-rules.sh`) handles the copying. `CLAUDE.md` is
symlinked to `AGENTS.md` so both Codex and Claude Code see the same content.

## Installation

### One-liner (Claude Code, global)

```bash
curl -fsSL https://raw.githubusercontent.com/shev-pro/lumen/main/scripts/install.sh | bash
```

### Via skills.sh

```bash
npx skills add shev-pro/lumen
```

### Manual options

```bash
# Claude Code — global (all your projects)
bash scripts/install.sh

# Claude Code — this project only
bash scripts/install.sh --project

# Cursor — global
bash scripts/install.sh --cursor

# All supported tools at once
bash scripts/install.sh --all
```

### Platform paths (if you prefer to copy manually)

| Tool | Global path | Project path |
|------|------------|--------------|
| Claude Code | `~/.claude/skills/lumen/` | `.claude/skills/lumen/` |
| Cursor | `~/.cursor/skills/lumen/` | `.cursor/skills/lumen/` |
| Gemini CLI | `~/.gemini/skills/lumen/` | — |
| OpenAI Codex | — | `.codex/skills/lumen/` |
| Kiro | — | `.kiro/skills/lumen/` |

Lumen follows the [Agent Skills open standard](https://agentskills.io/specification) and works with any tool that supports it — Claude Code, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Roo Code, and more.

Then invoke with any `/lumen` command.

## File Layout

```
scripts/
└── install.sh                      # Skill installer (Claude Code, Cursor, and more)
skills/lumen/
├── SKILL.md                        # Main skill definition
├── assets/
│   └── lumen-rule.md               # Static rule content (single source of truth)
├── scripts/
│   └── install-rules.sh            # Copies rules to Cursor, Claude Code locations
└── references/
    ├── project-fingerprint.md      # Project profiling and documentation strategy
    ├── templates.md                # Document templates (AGENTS.md, HLD, component, API, etc.)
    ├── scan-guide.md               # What to scan, what to document, what to skip
    ├── scan-parallel.md            # Parallel orchestration and depth-specific agent prompts
    ├── ingest-guide.md             # Processing rules for raw data ingestion
    ├── lint-guide.md               # Lint checks and resolution guidance
    ├── init-template.md            # Init directory structure and stub contents
    └── agents-template.md          # Rule file guide (formats, procedure, AGENTS.md section)
```

## License

MIT
