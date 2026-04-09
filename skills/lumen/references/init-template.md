# Init Template — Documentation Structure

This is the directory structure created by `/lumen init`. Files are markdown stubs
populated with section headers from `references/templates.md`.

---

## Directory tree

The exact set of docs depends on the option the user chose (Minimal, Component-split,
or Full suite). Below is the full suite — omit files not selected.

```
AGENTS.md                              # Entry point — use template from templates.md
docs/
├── high-level-design.md               # Always created
├── <component-name>/                  # One per detected component
│   ├── README.md                      # Always created per component
│   ├── api.md                         # Only if component exposes an API
│   └── data-model.md                  # Only if component has its own data model
├── api.md                             # Only for Full suite
├── data-model.md                      # Only for Full suite
├── codestyle.md                       # Component-split and Full suite
├── rationale.md                       # Component-split and Full suite
├── deployment.md                      # Component-split and Full suite
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

### Option mapping

| Document | Minimal | Component-split | Full suite |
|----------|---------|----------------|------------|
| AGENTS.md | ✅ | ✅ | ✅ |
| high-level-design.md | ✅ | ✅ | ✅ |
| component READMEs | — | ✅ | ✅ |
| component api.md | — | — | ✅ |
| component data-model.md | — | — | ✅ |
| api.md (global) | — | — | ✅ |
| data-model.md (global) | — | — | ✅ |
| codestyle.md | — | ✅ | ✅ |
| rationale.md | — | ✅ | ✅ |
| deployment.md | — | ✅ | ✅ |
| raw_data/ | ✅ | ✅ | ✅ |

---

## Stub contents

All doc stubs use the templates from `references/templates.md`. Create each file
with the full template structure, replacing HTML comments with `<!-- TODO -->` markers.
Do NOT fill in content during init — that's what `/lumen scan` is for.

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
