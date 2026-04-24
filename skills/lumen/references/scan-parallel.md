# Parallel Scan Orchestration

Guide for running `/lumen scan` with parallel agent discovery. This pattern uses
multiple subagents to document components concurrently, significantly reducing
scan time on multi-component repos.

---

## When to use parallel scan

Use parallel orchestration when the repo has **3 or more components** to document.
For 1–2 components, sequential scan is fine — the overhead of orchestration isn't worth it.

---

## Three-phase execution model

### Phase 1 — Plan & Global Scan (main agent, sequential)

This phase runs in the main agent context. Do NOT delegate it to subagents.

1. **Load or build the project fingerprint**: if `/lumen init` was run, the fingerprint
   exists in `AGENTS.md` metadata — read it and verify it's still accurate. If no
   fingerprint exists, build one now following `references/project-fingerprint.md`.
   The fingerprint determines which global docs to write, which components to scan,
   and at what depth.

2. **Read existing docs** (if any) — `AGENTS.md` and all files in `docs/`.
   If docs exist, identify what's stale vs fresh. Don't regenerate from scratch.

3. **Detect components**: scan the repo for top-level modules, services, packages.
   Build the component list. Confirm with the user if components are new or removed.
   **Assign scan depth** (Deep/Standard/Light) to each component based on the
   fingerprint — see `references/project-fingerprint.md` § "Scan Depth Assignment".

4. **Scan and write global documentation** — only documents selected by the
   documentation strategy. Use templates from `references/templates.md`:
   - `docs/high-level-design.md` — always
   - `docs/api.md` — if project type includes API service
   - `docs/data-model.md` — if database/storage detected
   - `docs/integrations.md` — if integration density > 3
   - `docs/codestyle.md` — if conventions exist beyond linter configs
   - `docs/deployment.md` — if infra/deploy configs detected
   - `docs/rationale.md` — if domain complexity is Medium or High (start the file;
     content comes from rationale discovery during component scans)
   - `docs/project-context.md` — if non-technical context exists or was ingested
     (stakeholder constraints, product requirements, business rules)

   Global docs MUST be written before Phase 2, because subagents need global
   context (stack, conventions) to produce good component docs.

5. **Build the discovery plan**: for each component, prepare a brief containing:
   - Component name
   - Root directory path(s)
   - Brief description (from high-level-design.md or auto-detection)
   - Output path: `docs/<component-name>/`
   - **Assigned scan depth**: Deep, Standard, or Light
   - Focus areas driven by the fingerprint (e.g., "high integration density —
     document external service connections")

6. **Determine batch size**:
   - 5 or fewer components → launch all agents in a single message
   - 6–15 components → batch in groups of 5
   - 15+ components → batch in groups of 5, ask the user for priority order first:
     *"This repo has <N> components. I'll scan in batches of 5. Suggested priority
     order: [list by activity/importance]. Adjust?"*

### Phase 2 — Parallel Discovery (subagents)

Launch one Agent per component. Each agent runs independently with a focused brief
and a scan depth that controls how much it documents.

**Agent prompt template — Deep Scan:**

```
You are documenting a core component for project documentation. This component
has been assigned a DEEP scan — it contains important domain logic that deserves
thorough documentation.

## Component: <name>
## Root path(s): <directory paths>
## Description: <one-liner from Phase 1>
## Scan Depth: Deep

## Your task

Analyze the source code under the root path(s) and produce comprehensive
documentation in `docs/<name>/`.

### docs/<name>/README.md

#### <Component Name>
1-2 sentence summary: what this component does and why it exists.

#### Responsibility
What this component owns. What it does NOT own (boundaries).

#### Architecture
Mermaid diagram showing internal structure and dependencies.

#### Key Files
The 3–7 most important files for understanding this component.
Use file:function() pointers — e.g. `src/auth/handler.go:HandleLogin()`.

#### Key Interfaces / Types
Main interfaces, structs, or types that define the contract. Point to source with line numbers.

#### Flows
Sequence diagrams for the primary flows using Mermaid. Document at least the
2 most important flows.

#### Configuration
Relevant env vars or config with defaults.

#### Dependencies
Internal (other components) and external (libraries, services).
Note the nature: sync call, async message, shared DB, etc.

#### Error Handling
How errors are handled, propagated, or reported.

#### Related Documents
Links to high-level-design.md and related components.

### docs/<name>/api.md (if the component exposes an API)
Document endpoints: method, path, request/response, errors, implementation pointer.

### docs/<name>/data-model.md (if the component has its own data model)
Document entities, relationships, schema, migrations.

## Rationale Discovery (Deep scan only)
Actively look for code that seems unusual or contrary to best practices.
Flag anything you find with 2–3 hypotheses about why it exists. Format:
"RATIONALE_FLAG: <what> | <why it's unusual> | <hypothesis 1> | <hypothesis 2>"
The main agent will collect these and ask the user.

## Context
The project uses: <stack summary from high-level-design.md>
Project conventions: <key conventions from codestyle.md>

## Rules
- Write ONLY to `docs/<name>/`
- Do NOT modify any files outside `docs/<name>/`
- Do NOT modify AGENTS.md or global docs
- Keep documentation concise and decision-oriented
- Use code references (file:function()) instead of re-describing code
- If a section would just restate the code, link to the file instead
- Include Mermaid diagrams for architecture and flows
- Keep each doc under 300 lines. Split if longer.
```

**Agent prompt template — Standard Scan:**

```
You are documenting a component for project documentation. This component has
been assigned a STANDARD scan — document its role and connections clearly, but
don't go deep into internals.

## Component: <name>
## Root path(s): <directory paths>
## Description: <one-liner from Phase 1>
## Scan Depth: Standard

## Your task

Analyze the source code and produce focused documentation in `docs/<name>/`.

### docs/<name>/README.md

#### <Component Name>
1-2 sentence summary: what this component does and why it exists.

#### Responsibility
What this component owns. What it does NOT own (boundaries). Keep to one paragraph.

#### Architecture
Mermaid diagram showing internal structure and dependencies.

#### Key Files
The 3–5 most important files. Use file:function() pointers.

#### Primary Flow
One sequence diagram for the most important flow using Mermaid.

#### Dependencies
Internal (other components) and external (libraries, services).
Note the nature: sync call, async message, shared DB, etc.

#### Configuration
Relevant env vars or config with defaults (if any).

#### Related Documents
Links to high-level-design.md and related components.

### docs/<name>/api.md — only if the component exposes a significant API surface.
Skip for internal-only components.

## Context
The project uses: <stack summary from high-level-design.md>

## Rules
- Write ONLY to `docs/<name>/`
- Do NOT modify any files outside `docs/<name>/`
- Keep it concise — this is a Standard scan, not a deep dive
- Use code references (file:function()) instead of re-describing code
- Include Mermaid diagrams for architecture and the primary flow
- If the component is straightforward, say so briefly rather than padding
```

**Agent prompt template — Light Scan:**

```
You are documenting a simple component for project documentation. This component
has been assigned a LIGHT scan — it's a thin wrapper, adapter, or config module
that needs only a brief description.

## Component: <name>
## Root path(s): <directory paths>
## Description: <one-liner from Phase 1>
## Scan Depth: Light

## Your task

Create a minimal `docs/<name>/README.md` with:

#### <Component Name>
3–5 lines total:
- What it wraps or what it does (one sentence)
- Why it exists as a separate component (one sentence)
- Pointer to the main source file(s)
- Key dependency or integration (if any)

That's it. No diagrams, no flow documentation, no separate API or data model docs.
If there's genuinely nothing interesting, say "Thin wrapper around <X>, see
`<source file>` for implementation."

## Rules
- Write ONLY `docs/<name>/README.md`
- Keep it under 20 lines
- Do NOT pad with filler to make it look more substantial
```

**Launching agents:**

Use the Agent tool with `subagent_type: "general-purpose"`. Launch all agents for
the current batch in a **single message** with multiple tool-use blocks — this is
what enables true parallel execution.

Example (3 components, mixed depths):
```
[Agent call 1: "Document auth-service component (Deep)"]
  prompt: <filled Deep template for auth-service>

[Agent call 2: "Document api-gateway component (Standard)"]
  prompt: <filled Standard template for api-gateway>

[Agent call 3: "Document config-loader component (Light)"]
  prompt: <filled Light template for config-loader>
```

**Wait for all agents in the batch to complete** before moving to Phase 3
(or launching the next batch).

### Phase 3 — Synthesize (main agent, sequential)

After all subagents complete:

1. **Read all generated component docs** and verify quality against assigned depth:
   - **Deep components**: must have substantive content in all sections, at least
     2 Mermaid diagrams (architecture + flow), and meaningful key files list
   - **Standard components**: must have architecture diagram, primary flow, and
     clear responsibility statement
   - **Light components**: must be genuinely brief (under 20 lines), not padded

2. **Quality checks**:
   - Verify that file:function() references point to files that actually exist
   - Check that Mermaid diagrams use valid syntax (graph TD, sequenceDiagram, erDiagram)
   - Flag any sections that are just headers with no content
   - Flag any Light docs that are suspiciously long (>30 lines)

3. **Cross-reference `docs/high-level-design.md`**:
   - Update the component diagram with any new dependencies discovered
   - Add inter-component relationships that subagents surfaced
   - Ensure the Components section links to all component docs

4. **Add cross-references**: in each component README, ensure Related Documents
   section links to related components. If component A depends on component B,
   both should reference each other.

5. **Consolidate integrations**: if `docs/integrations.md` exists, collect all
   external service references from component docs and ensure they're cataloged
   in the integrations doc with: service name, what it's used for, which
   components use it, and authentication method.

6. **Collect rationale flags**: gather RATIONALE_FLAG entries from Deep-scan
   subagents, consolidate them, and present to the user for confirmation before
   adding to `docs/rationale.md`.

7. **Detect contradictions**: scan across all generated and existing docs for
   conflicting claims — same configuration value documented differently, two
   components claiming ownership of the same responsibility, or docs that
   contradict entries in `project-context.md` or `rationale.md`. Surface these
   to the user; do not silently resolve them.

8. **Surface orphan concepts**: identify terms or component names mentioned in 3 or
   more docs that do not have their own page. Propose these as candidate additions:
   *"The concept `<X>` appears in <N> docs but has no dedicated page. Worth adding?"*

9. **Update `AGENTS.md`**:
   - Refresh the Documentation Index with all generated docs
   - Store the project fingerprint in the Metadata section
   - Update last scan date and commit SHA

10. **Append to `docs/log.md`**:
    `## [YYYY-MM-DD] scan | <N> components (<deep> deep, <std> standard, <light> light), <M> global docs`

11. **Report results**:
    ```
    🔆 Lumen scan complete for <repo-name>.

    Scanned <N> components (<deep> deep, <std> standard, <light> light):

    | Component | Depth | Docs created | Key findings |
    |-----------|-------|-------------|-------------|
    | auth | Deep | README, api.md | 4 endpoints, Stripe + Auth0 integration |
    | billing | Deep | README, data-model.md | 12 tables, complex state machine |
    | api-gateway | Standard | README | Routes to 3 internal services |
    | worker | Standard | README | Cron-based, uses Redis queue |
    | infra | Light | README | Terraform wrapper for AWS |

    Global docs updated: high-level-design, deployment, integrations, data-model
    Cross-references added: 8 inter-component links
    Rationale flags: 3 (pending user confirmation)
    Contradictions found: 1 (token TTL mismatch — flagged above)
    Orphan concepts proposed: 2 (EventBus, circuit breaker pattern)

    Run `/lumen status` to see full coverage. Run `/lumen lint` for a quality audit.
    ```

---

## Error handling

- **If a subagent fails** (returns an error or produces empty output):
  log the failure, continue with other agents, and report the gap in Phase 3.
  Do NOT retry automatically — flag it for the user.

- **If a subagent writes outside its boundary** (this shouldn't happen if the
  prompt is followed, but check): revert the out-of-scope changes in Phase 3
  and note the issue.

- **If the batch is too large and some agents seem stuck**: Phase 3 should
  note incomplete agents and suggest the user re-run `/lumen scan` for those
  specific components.

---

## Incremental parallel scan

When running `/lumen scan` on a repo that already has documentation:

1. In Phase 1, compare existing docs with current code state. Re-evaluate the
   project fingerprint — the project may have grown or changed shape.
2. Only launch subagents for components that are **stale or undocumented**.
   Fresh components are skipped.
3. Preserve scan depth assignments from the previous scan unless the component's
   role has changed (e.g., a Light component that grew into core domain logic
   should be promoted to Deep).
4. Subagent prompts should include the existing README.md content with
   the instruction: "Update this documentation — preserve manually written
   content, update sections where the code has diverged."
5. Preserve any user-written content. Never delete sections the user added manually.

This avoids re-scanning the entire repo when only a few things changed.
Use `/lumen update` for lightweight commit-based sync instead.
