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

1. **Read existing docs** (if any) — `AGENTS.md` and all files in `docs/`.
   If docs exist, identify what's stale vs fresh. Don't regenerate from scratch.

2. **Detect components**: scan the repo for top-level modules, services, packages.
   Build the component list. Confirm with the user if components are new or removed.

3. **Scan and write global documentation** using templates from `references/templates.md`:
   - `docs/high-level-design.md` — architecture, component map, key decisions, data flow
   - `docs/codestyle.md` — naming, idioms (skip what linter configs already cover)
   - `docs/deployment.md` — build, deploy, infra, CI/CD
   - `docs/data-model.md` — entities, relationships, schema (if applicable)
   - `docs/api.md` — global API surface (if applicable)

   Global docs MUST be written before Phase 2, because subagents need global
   context (stack, conventions) to produce good component docs.

4. **Build the discovery plan**: for each component, prepare a brief containing:
   - Component name
   - Root directory path(s)
   - Brief description (from high-level-design.md or auto-detection)
   - Output path: `docs/<component-name>/`
   - What to focus on (responsibility, API surface, dependencies, key files, flows)

5. **Determine batch size**:
   - 5 or fewer components → launch all agents in a single message
   - 6–15 components → batch in groups of 5
   - 15+ components → batch in groups of 5, ask the user for priority order first:
     *"This repo has <N> components. I'll scan in batches of 5. Suggested priority
     order: [list by activity/importance]. Adjust?"*

### Phase 2 — Parallel Discovery (subagents)

Launch one Agent per component. Each agent runs independently with a focused brief.

**Agent prompt template:**

```
You are documenting a single component for project documentation.

## Component: <name>
## Root path(s): <directory paths>
## Description: <one-liner from Phase 1>

## Your task

Analyze the source code under the root path(s) and produce documentation
in `docs/<name>/` following this structure:

### docs/<name>/README.md

Use this template structure:

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
Sequence diagrams for the primary flows using Mermaid.

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
- If the component is trivial (thin wrapper, simple config), say so briefly
  rather than padding with filler
- Keep each doc under 300 lines. Split if longer.
```

**Launching agents:**

Use the Agent tool with `subagent_type: "general-purpose"`. Launch all agents for
the current batch in a **single message** with multiple tool-use blocks — this is
what enables true parallel execution.

Example (3 components):
```
[Agent call 1: "Document auth-service component"]
  prompt: <filled template for auth-service>

[Agent call 2: "Document api-gateway component"]
  prompt: <filled template for api-gateway>

[Agent call 3: "Document scheduler component"]
  prompt: <filled template for scheduler>
```

**Wait for all agents in the batch to complete** before moving to Phase 3
(or launching the next batch).

### Phase 3 — Synthesize (main agent, sequential)

After all subagents complete:

1. **Read all generated component docs** to verify quality and completeness.

2. **Cross-reference `docs/high-level-design.md`**:
   - Update the component diagram with any new dependencies discovered
   - Add inter-component relationships that subagents surfaced
   - Ensure the Components section links to all component docs

3. **Add cross-references**: in each component README, ensure Related Documents
   section links to related components. If component A depends on component B,
   both should reference each other.

4. **Update `AGENTS.md`**:
   - Refresh the Documentation Index with all generated docs
   - Update the Metadata section (last scan date, commit SHA)

5. **Capture rationale**: if any subagents flagged unusual patterns, consolidate
   them and ask the user for confirmation before adding to `docs/rationale.md`.

6. **Report results**:
   ```   
   🔆 Lumen parallel scan complete for <repo-name>.

   Scanned <N> components in <batch-count> batch(es):

   | Component | Docs created | Key findings |
   |-----------|-------------|-------------|
   | auth-service | README, api.md | 4 endpoints, depends on user-db |
   | api-gateway | README | Routes to 3 internal services |
   | scheduler | README | Cron-based, uses Redis queue |

   Global docs updated: high-level-design, codestyle, deployment, data-model
   Cross-references added: 6 inter-component links

   Run `/lumen status` to see full coverage.
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

1. In Phase 1, compare existing docs with current code state.
2. Only launch subagents for components that are **stale or undocumented**.
   Fresh components are skipped.
3. Subagent prompts should include the existing README.md content with
   the instruction: "Update this documentation — preserve manually written
   content, update sections where the code has diverged."
4. Preserve any user-written content. Never delete sections the user added manually.

This avoids re-scanning the entire repo when only a few things changed.
Use `/lumen update` for lightweight commit-based sync instead.
