<p align="center">
  <img src="lumen.jpeg" alt="Lumen — Macroknowledge Refinement System" width="700">
</p>

<h1 align="center">Lumen</h1>

<p align="center">
  <strong>The persistent knowledge keeper for any Git repository.</strong><br>
  A Claude Code skill that builds, maintains, and serves structured documentation — for both humans and AI agents.
</p>

<p align="center">
  <code>/lumen init</code> · <code>/lumen scan</code> · <code>/lumen ingest</code> · <code>/lumen update</code> · <code>/lumen status</code> · <code>/lumen rules</code> · <code>/lumen &lt;question&gt;</code>
</p>

---

## What is Lumen?

Lumen is an agentic persona that acts as the living memory of a codebase. It accumulates, structures, and serves project knowledge across sessions — so every future interaction starts informed, not from scratch.

It produces three things:

1. **Documentation** (`docs/`) — structured markdown files, committed to Git
2. **Rule files** (`AGENTS.md`, `.cursor/rules/agents/lumen.md`) — force any AI agent to read the docs before acting
3. **Raw data inbox** (`docs/raw_data/`) — local staging area for ingesting meeting notes, emails, screenshots, and specs

## Principles

- **Code is the source of truth.** Docs point to it, never duplicate it.
- **Concise over comprehensive.** Each doc earns its existence.
- **Pointers over explanations.** Link to `file:function()`, don't re-describe code.
- **Mermaid diagrams** for architecture, data flow, and sequences.
- **One level of depth per document.** `AGENTS.md` → topic docs → code.

## Commands

| Command | What it does |
|---------|-------------|
| `/lumen init` | Assess the codebase and bootstrap the docs structure |
| `/lumen scan` | Analyze code and generate/update documentation (with parallel agents) |
| `/lumen ingest` | Process raw files (transcripts, emails, screenshots, docs) into structured docs |
| `/lumen update` | Incremental sync from recent git commits |
| `/lumen status` | Show documentation coverage, freshness, and gaps |
| `/lumen rules` | Generate `AGENTS.md` and Cursor rule files |
| `/lumen <question>` | Query the documentation in natural language |

## Document Structure

Lumen generates a standard `docs/` hierarchy tailored to the project size. Three options are offered during init:

```
AGENTS.md                       # Entry point — project overview + doc index
docs/
├── high-level-design.md        # Architecture, component map, key decisions
├── <component>/                # Per-component folder
│   ├── README.md               # Component deep dive
│   ├── api.md                  # API surface (if applicable)
│   └── data-model.md           # Data model (if applicable)
├── api.md                      # Global API reference
├── data-model.md               # Database schema, entities, migrations
├── codestyle.md                # Naming, patterns, idioms
├── rationale.md                # Non-obvious decisions with reasoning (ADR format)
├── deployment.md               # Build, deploy, CI/CD, monitoring
└── raw_data/                   # Local inbox for /lumen ingest
```

## Parallel Scan

For repos with multiple components, `/lumen scan` uses a three-phase orchestration model with parallel subagents:

1. **Plan & Global Scan** — the main agent detects components, writes global docs
2. **Parallel Discovery** — one subagent per component, writing concurrently to isolated paths
3. **Synthesize** — the main agent cross-references, links, and reports results

Batching is adaptive: up to 5 components launch at once, larger repos batch in groups of 5.

## Rationale Discovery

During scanning, Lumen flags code that looks unusual or contrary to best practices. Instead of assuming it's a mistake, it proposes hypotheses to the user and captures confirmed rationale in `docs/rationale.md` using ADR format.

## Installation

Copy the `skills/lumen/` folder into your Claude Code skills directory:

```bash
cp -r skills/lumen/ .claude/skills/lumen/
```

Then invoke with any `/lumen` command.

## File Layout

```
skills/lumen/
├── SKILL.md                        # Main skill definition
└── references/
    ├── templates.md                # Document templates (AGENTS.md, HLD, component, API, etc.)
    ├── scan-guide.md               # What to scan, what to document, what to skip
    ├── scan-parallel.md            # Parallel orchestration model and agent prompts
    ├── ingest-guide.md             # Processing rules for raw data ingestion
    ├── init-template.md            # Init directory structure and stub contents
    └── agents-template.md          # Rule file templates for Claude Code / Cursor
```

## License

MIT
