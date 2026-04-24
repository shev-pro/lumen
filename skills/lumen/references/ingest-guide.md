# Ingest Guide

Rules for processing files in `docs/raw_data/` during `/lumen ingest`.

---

## General principles

- Extract **actionable knowledge only** — skip pleasantries, small talk, logistical noise.
- **Absorb, don't reference.** Raw files live in `raw_data/` which is gitignored —
  they won't exist for anyone else reading the docs. The knowledge must be fully
  integrated into the target document as if it had always been there. Never add
  `> Source: raw_data/...` links or any reference to raw file paths.
- **Integrate first, summarize as fallback.** The preferred outcome is that extracted
  knowledge merges seamlessly into existing doc sections — updating a component's
  dependencies, adding a rationale entry, enriching a flow description. If the
  knowledge doesn't fit cleanly into any existing section (e.g., decisions not yet
  implemented, future plans, exploratory ideas), create a summary section in the
  most relevant doc rather than dropping the information.
- Never duplicate: before adding, check if the knowledge already exists in the target file.
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
- Stakeholder priorities, product direction, business rules, team process
  → route to `docs/project-context.md`
- Sprint goals, retrospective outcomes, team agreements → route to
  `docs/project-context.md` under "Team & Process"

**Ignore**: scheduling talk, off-topic chat, repeated context-setting.

### Emails (emails/)

Email threads, Slack exports, chat logs, discussion dumps.

**Extract**:
- Requirements or spec changes → route to `docs/data-model.md` or component README
- Decisions communicated → route to `docs/rationale.md`
- Stakeholder context ("the client wants...", "legal requires...", "the product
  team has decided...") → route to `docs/project-context.md`
- External constraints ("we can't use X because of licensing", "we must support IE11
  per contract") → route to `docs/project-context.md` under "Constraints"
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
If the original is accessible via URL, a link is fine — but never link to local
raw_data paths. The docs are a distilled reference, not a document archive.

---

## Routing decision tree

When extracted knowledge could go to multiple places, use this priority:

1. Is it a **decision with rationale**? → `docs/rationale.md` (ADR format)
2. Is it **stakeholder context, a business requirement, a product constraint, or
   team/process knowledge not visible in code**? → `docs/project-context.md`
3. Is it about **a specific component's API**? → `docs/<component>/api.md`
4. Is it about **a specific component's data**? → `docs/<component>/data-model.md`
5. Is it about **a specific component** generally? → `docs/<component>/README.md`
6. Is it about **an external service or integration**? → `docs/integrations.md` (if it exists)
7. Is it about **global API surface**? → `docs/api.md`
8. Is it about **data model / schema**? → `docs/data-model.md`
9. Is it about **infrastructure/deploy**? → `docs/deployment.md`
10. Is it about **code patterns/conventions**? → `docs/codestyle.md`
11. Is it about **system architecture**? → `docs/high-level-design.md`

**Note on project-context.md vs rationale.md**: rationale captures *technical decisions*
("we chose Postgres over MySQL because…"). project-context captures the *business and
stakeholder layer* that surrounds those decisions ("the client requires GDPR compliance",
"the product team prioritizes mobile-first", "legal flagged session token storage"). When
a decision is driven by a business constraint, record the constraint in project-context.md
and link to it from the rationale entry.

---

## Integrating into existing files

The goal is seamless absorption — the reader shouldn't be able to tell which parts
came from code analysis and which from ingested files.

### When knowledge fits an existing section

- Find the appropriate section (by heading) and weave the new information in.
- Update existing content rather than appending a separate block. If a component's
  README lists 3 dependencies and the ingested file reveals a 4th, add it to the
  existing list — don't create a new "Ingested Dependencies" section.
- Rewrite sentences if needed to incorporate the new knowledge naturally.

### When knowledge doesn't fit anywhere

Some ingested knowledge doesn't map to existing doc structure — decisions not yet
implemented, future plans, exploratory ideas, stakeholder constraints that aren't
reflected in code yet. For these:

- Add a section in the most relevant doc. Good section names:
  - `## Planned Changes` — decisions made but not yet implemented
  - `## Open Questions` — unresolved discussions or trade-offs
  - `## Constraints` — external constraints not visible in code (legal, business, SLA)
- Use ADR format in `rationale.md` for decisions, even if not yet implemented —
  mark them with `Status: accepted (not yet implemented)`.
- If the knowledge is truly orphaned (doesn't fit any doc), create a brief entry
  in `high-level-design.md` under Cross-Cutting Concerns.

### Formatting

- Use a horizontal rule (`---`) to visually separate newly added sections from
  existing content, but only for new sections — not for inline updates.
- Add an ingestion date as an HTML comment for internal tracking only:
  `<!-- Ingested: YYYY-MM-DD -->` — this is invisible to readers but helps Lumen
  track what was added when.

---

## Post-ingest checklist

After processing all files:

1. Update `AGENTS.md` metadata (last ingest date).
2. Print a summary table showing what knowledge was extracted and where it landed:
   ```
   Ingested 4 files:

   | File | Knowledge extracted | Integrated into |
   |------|-------------------|-----------------|
   | standup-2025-06-01.md | Decision: switch to event-driven auth | docs/rationale.md (new ADR entry) |
   | client-req.pdf | 3 new API requirements, SLA constraint | docs/api-gateway/README.md, docs/high-level-design.md |
   | arch-whiteboard.png | Component topology, data flow | docs/high-level-design.md (updated architecture diagram) |
   | slack-thread.txt | Naming convention for event handlers | docs/codestyle.md (added to Idioms section) |
   ```
3. If any file couldn't be processed or routed, flag it to the user.
4. If knowledge was placed in new sections (Planned Changes, Open Questions, etc.),
   call them out explicitly so the user knows where to find them.
