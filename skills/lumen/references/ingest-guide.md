# Ingest Guide

Rules for processing files in `docs/raw_data/` during `/lumen ingest`.

---

## General principles

- Extract **actionable knowledge only** — skip pleasantries, small talk, logistical noise.
- Always attribute the source: add a `> Source: <filename>` line at the end of any
  appended section.
- Never duplicate: before appending, check if the knowledge already exists in the target file.
- When in doubt about where to route something, ask the user.
- Preserve the original raw file — never delete or modify it.
- Use code references (`file:function()`) when the ingested content references specific code.

---

## Processing by file type

### Transcripts (transcripts/)

Meeting notes, call recordings (text), standup summaries, retro notes.

**Extract**:
- Decisions made ("we decided to...", "let's go with...", "agreed that...")
  → route to `docs/rationale.md`
- Action items and commitments → route to `docs/deployment.md` if operational,
  or component README if component-specific
- Technical constraints or requirements discovered → route to relevant doc
- Architecture discussions → route to `docs/high-level-design.md`
- API decisions → route to `docs/api.md` or `docs/<component>/api.md`

**Ignore**: scheduling talk, off-topic chat, repeated context-setting.

### Emails (emails/)

Email threads, Slack exports, chat logs, discussion dumps.

**Extract**:
- Requirements or spec changes → route to `docs/data-model.md` or component README
- Decisions communicated → route to `docs/rationale.md`
- Stakeholder context ("the client wants...", "legal requires...") → route to
  `docs/high-level-design.md` under Cross-Cutting Concerns or component README
- Technical constraints ("the API only supports...", "we can't use X because...")
  → route to `docs/codestyle.md` or `docs/rationale.md`

**Ignore**: email signatures, forwarding chains, automated notifications.

### Screenshots (screenshots/)

UI mockups, architecture diagrams, whiteboard photos, config panels, error messages.

**Extract**:
- Describe what the screenshot shows in text
- If it's an architecture/flow diagram → extract components and relationships
  into `docs/high-level-design.md`
- If it's a UI → note the component it belongs to in component README
- If it's a config/settings panel → extract configuration details
  into `docs/deployment.md`
- If it's an error → document the issue in the relevant component README
  under Error Handling

**Always**: save the textual description. Screenshots can't be searched — the text
extraction is what makes them useful.

### Documents (documents/)

PDFs, specs, RFCs, external API docs, requirements docs, design docs.

**Extract**:
- Requirements and constraints → route to relevant component README or HLD
- API specifications → route to `docs/api.md` or `docs/<component>/api.md`
- Architecture decisions → route to `docs/rationale.md`
- Deployment/infra requirements → route to `docs/deployment.md`
- Data model specs → route to `docs/data-model.md` or `docs/<component>/data-model.md`

**For large documents**: summarize the key points rather than transcribing everything.
Link to the original if it's accessible (e.g., a URL). The docs are a
distilled reference, not a document archive.

---

## Routing decision tree

When extracted knowledge could go to multiple places, use this priority:

1. Is it a **decision with rationale**? → `docs/rationale.md` (ADR format)
2. Is it about **a specific component's API**? → `docs/<component>/api.md`
3. Is it about **a specific component's data**? → `docs/<component>/data-model.md`
4. Is it about **a specific component** generally? → `docs/<component>/README.md`
5. Is it about **global API surface**? → `docs/api.md`
6. Is it about **data model / schema**? → `docs/data-model.md`
7. Is it about **infrastructure/deploy**? → `docs/deployment.md`
8. Is it about **code patterns/conventions**? → `docs/codestyle.md`
9. Is it about **system architecture**? → `docs/high-level-design.md`

---

## Appending to existing files

When adding extracted knowledge to an existing file:

- Find the appropriate section (by heading) and append within it.
- If no appropriate section exists, add a new section at the end (before any
  "Related Documents" section).
- Use a horizontal rule (`---`) to separate newly ingested content from existing.
- Add the source attribution: `> Source: raw_data/<type>/<filename>, ingested <YYYY-MM-DD>`

---

## Post-ingest checklist

After processing all files:

1. Update `AGENTS.md` metadata (last ingest date).
2. Print a summary table:
   ```
   Ingested 4 files:

   | File | Type | Routed to |
   |------|------|-----------|
   | standup-2025-06-01.md | transcript | docs/rationale.md |
   | client-req.pdf | document | docs/api-gateway/README.md, docs/data-model.md |
   | arch-whiteboard.png | screenshot | docs/high-level-design.md |
   | slack-thread.txt | email | docs/codestyle.md |
   ```
3. If any file couldn't be processed or routed, flag it to the user.
