# Lint Guide

Detailed checks and resolution guidance for `/lumen lint`.

Where `/lumen status` measures *coverage* (what exists vs what should exist),
lint measures *health* (what's accurate, consistent, and internally coherent).

---

## Check 1 — Contradictions

**What to look for:**

Read all docs looking for the same fact stated differently in two or more places.
Common contradiction types:

- **Config values**: a timeout, port, TTL, batch size, or env var documented with
  different values in different files (e.g., `auth/README.md` says token TTL is 24h,
  `api.md` says 1h)
- **Ownership conflicts**: two components claiming responsibility for the same
  concern (e.g., both `api-gateway` and `auth` claim to handle rate limiting)
- **Architecture conflicts**: `high-level-design.md` describes component A calling B
  directly, but component B's README says all calls go through C
- **Decision vs implementation**: `rationale.md` records a decision, but current
  component docs describe a different approach
- **Context vs code**: `project-context.md` states a requirement (e.g., "must support
  offline mode") but no component doc addresses it and HLD makes no mention of it

**How to report:**

For each contradiction found:
```
⚠️  <short description>
    - <doc A>: "<exact claim>"
    - <doc B>: "<exact claim>"
    Suggested resolution: <which is likely correct, or ask the user>
```

**How to resolve:**

Do NOT silently pick one version. Surface all contradictions to the user with a
suggested resolution. Once the user confirms which is correct, update the docs
in the same session.

---

## Check 2 — Stale Claims

**What to look for:**

Content that was accurate when written but may have been superseded. Detection signals:

- `<!-- Ingested: YYYY-MM-DD -->` annotations in docs — check if the referenced
  systems or decisions have changed since that date
- `rationale.md` entries with `Status: accepted (not yet implemented)` — cross-check
  against current code to see if they've been implemented (look for related file paths,
  function names, or config patterns from the rationale entry)
- Component docs that describe a structure (file paths, function names) that no longer
  exists in the repo
- `project-context.md` requirements that appear to have been dropped or superseded
  by newer requirements

**How to report:**

```
🕐 <doc>: <what the claim says> — may be stale since <date or event>
   Verify: <what to check to confirm>
```

**Note:** Lumen should not auto-update stale claims — they require human judgment
about whether the new state is intentional. Flag them and wait for the user to confirm.

---

## Check 3 — Orphan Pages

**What to look for:**

Doc files that are **neither** listed in `AGENTS.md`'s Documentation Index
**nor** linked from any other doc.

These pages are invisible to navigation and will not be read by agents or humans
following the index.

**How to report:**

```
📄 docs/<path> — not linked from AGENTS.md or any other doc
   Suggested action: add to AGENTS.md index or link from relevant doc
```

**How to resolve:**

Offer to add the orphan page to the AGENTS.md Documentation Index. Ask the user
if the page should be kept, linked, or deleted.

---

## Check 4 — Orphan Concepts

**What to look for:**

Terms, system names, or component names that appear frequently across docs but have
no dedicated page. These are knowledge gaps masquerading as references.

**Detection method:**

1. Read all docs and extract nouns that look like system/component/concept names
   (CamelCase, quoted terms, italicized terms, terms that appear alongside verbs
   like "calls", "sends to", "managed by", "owned by")
2. Count occurrences across docs
3. Flag terms appearing in 3+ docs that have no corresponding page in `docs/`

**How to report:**

```
💡 "<concept>" — mentioned in <N> docs (<list doc names>), no dedicated page
   Candidate path: docs/<suggested-slug>.md
```

**How to resolve:**

These are suggestions, not errors. Present them to the user as candidate pages worth
creating. The user decides which are worth formalizing. If agreed, create a stub using
the appropriate template from `references/templates.md`.

---

## Check 5 — Broken References

**What to look for:**

`file:function()` or `file:line` pointers in docs that point to files or functions
that no longer exist in the repo. These are the most immediately harmful lint findings
— they cause agents to look for code that isn't there.

**Detection method:**

1. Extract all patterns matching `\w[\w./]+\.(go|ts|js|py|java|rb|rs|kt|swift):\w+`
   from all docs
2. For each, check if the file path exists in the repo
3. For function references, optionally grep for the function name in the file

**How to report:**

```
❌ <doc>: `<file:function>` — file not found
   Last seen: <look at git log for when the file was deleted>
   Suggested action: update reference or remove
```

**How to resolve:**

For each broken reference, check git log to find when the file was deleted or renamed.
If renamed, update the reference. If deleted (code removed), remove the reference and
update the surrounding text.

---

## Check 6 — Empty Sections in Populated Docs

**What to look for:**

Docs that have section headers with no content — `<!-- TODO -->` markers or headers
immediately followed by another header. This indicates stubs that were never filled in
after `/lumen init`.

**How to report:**

```
📝 <doc> § <section heading> — empty since init
   Suggested action: run /lumen scan to populate, or remove if not applicable
```

---

## Check 7 — project-context.md Completeness

If `project-context.md` exists but has mostly empty sections, flag it specifically:

```
📝 project-context.md has <N> empty sections — consider ingesting project
   requirements or stakeholder context via /lumen ingest
```

If `project-context.md` doesn't exist but `rationale.md` contains entries driven by
business or legal constraints, suggest creating it:

```
💡 rationale.md references stakeholder constraints (legal compliance, client requirements)
   but project-context.md doesn't exist. Consider creating it to capture the full context.
```

---

## Severity Levels

| Symbol | Meaning | Action required |
|--------|---------|-----------------|
| ❌ | Broken — definitely wrong | Fix immediately |
| ⚠️ | Contradiction — two truths conflict | Resolve with user |
| 🕐 | Stale — may have been superseded | Verify with user |
| 📄 | Orphan page — invisible to navigation | Link or remove |
| 💡 | Opportunity — missing page or improvement | Decide with user |
| 📝 | Incomplete — stub not filled | Scan or remove |

---

## Suggested Investigations

After running all checks, synthesize findings into actionable suggestions. These go
beyond what the docs contain — they propose what to do next to deepen the wiki.

Examples:
- *"Three docs mention `EventBus` but its source and ownership are unclear. A
  `/lumen scan` focused on the event system would clarify this."*
- *"project-context.md is empty. If there are stakeholder emails or meeting notes,
  dropping them in raw_data/ and running `/lumen ingest` would add significant context."*
- *"The auth flow is documented but the token refresh path has no sequence diagram.
  Worth adding to auth/README.md."*
- *"No rationale entries exist despite Medium domain complexity. Running `/lumen scan`
  with rationale discovery enabled would surface non-obvious decisions."*

Limit to 3–5 high-value suggestions. Don't generate noise.
