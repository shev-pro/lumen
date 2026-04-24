# Init Template — Documentation Structure

This is the directory structure created by `/lumen init`. The exact set of docs is
determined by the project fingerprint — not by a fixed menu of options.

---

## Directory tree

The fingerprint-driven documentation strategy selects which files to create.
Below is the full possible set — only create files selected by the strategy.

```
AGENTS.md                              # Entry point — always created
docs/
├── log.md                             # Append-only operation log — always created
├── high-level-design.md               # Always created
├── <component-name>/                  # One per detected component
│   ├── README.md                      # Always created per component
│   ├── api.md                         # Only if component exposes an API (Deep scan)
│   └── data-model.md                  # Only if component has its own data model (Deep scan)
├── api.md                             # If project type includes API service
├── data-model.md                      # If database/storage detected
├── integrations.md                    # If integration density > 3
├── codestyle.md                       # If conventions exist beyond linter configs
├── rationale.md                       # If domain complexity is Medium or High
├── project-context.md                 # If non-technical context exists or is expected
├── deployment.md                      # If infra/deploy configs detected
└── raw_data/                          # Always created
    ├── .gitignore
    ├── README.md
    ├── transcripts/
    │   └── .gitkeep
    ├── emails/
    │   └── .gitkeep
    ├── screenshots/
    │   └── .gitkeep
    └── documents/
        └── .gitkeep
```

### Document selection guide

| Document | When to create |
|----------|---------------|
| AGENTS.md | Always |
| log.md | Always |
| high-level-design.md | Always |
| component READMEs | Always (one per detected component) |
| component api.md | Deep-scan components that expose an API |
| component data-model.md | Deep-scan components with their own data model |
| api.md (global) | Project type includes API service |
| data-model.md (global) | Database or structured storage detected |
| integrations.md | Integration density > 3 external services |
| codestyle.md | Conventions exist that linter configs don't cover |
| rationale.md | Domain complexity is Medium or High |
| project-context.md | Non-technical context exists or is expected (stakeholder constraints, product requirements, business rules not in code) |
| deployment.md | Infrastructure or deploy configs detected |
| raw_data/ | Always |

---

## Stub contents

All doc stubs use the templates from `references/templates.md`. Create each file
with the full template structure, replacing HTML comments with `<!-- TODO -->` markers.
Do NOT fill in content during init — that's what `/lumen scan` is for.

**Exceptions — create with real content, not stubs:**

- `docs/log.md` — create with the first real entry (the init event), not a stub.
  Use the Log Template from `references/templates.md`.
- `docs/project-context.md` — create with the stub template, but if the user
  described non-technical context during fingerprinting, write that content in
  directly rather than leaving it empty.

For component README stubs, use the Component README Template.
For global docs, use the corresponding template (HLD, API, Data Model, etc.).
For AGENTS.md, use the AGENTS.md Template with placeholders.

---

## raw_data/.gitignore

```
# Raw data is local-only — not committed to the repository.
# Drop files here and run /lumen ingest to process them.
*
!.gitignore
!README.md
!transcripts/
!emails/
!screenshots/
!documents/
transcripts/*
!transcripts/.gitkeep
emails/*
!emails/.gitkeep
screenshots/*
!screenshots/.gitkeep
documents/*
!documents/.gitkeep
```

## raw_data/README.md

```markdown
# Raw Data

This folder is the inbox for Lumen's ingestion pipeline.
Drop files here and run `/lumen ingest` to process them into structured documentation.

**Contents are not committed to Git** — this is a local staging area.

## Subfolders

| Folder | What to put here |
|--------|-----------------|
| `transcripts/` | Meeting notes, call transcripts, audio-to-text outputs |
| `emails/` | Email threads, Slack exports, discussion dumps |
| `screenshots/` | UI screenshots, architecture diagrams, whiteboard photos |
| `documents/` | Specs, RFCs, external docs, PDFs, any reference material |

## How it works

1. Drop your files into the appropriate subfolder
2. Run `/lumen ingest`
3. Lumen reads each file, extracts relevant knowledge, and routes it to the right
   document in `docs/`
4. A summary tells you what was extracted and where it went
```
