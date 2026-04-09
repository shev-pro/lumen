# Scan Guide

Detailed instructions for analyzing a codebase during `/lumen scan`.

---

## Scan strategy

The scan is not a line-by-line code walkthrough. The goal is to produce **navigable,
decision-oriented documentation** — the kind of knowledge a new team member would
need to become productive quickly.

**Code is the source of truth.** Docs point to it with file:function() references,
never duplicate it. If a section would just restate the code, link to the file instead.

### What to document

- What each component does and why it exists
- How components connect and communicate
- Key design decisions and their rationale
- Patterns and conventions (especially non-obvious ones)
- External dependencies and integration points
- Known quirks, workarounds, and technical debt

### What NOT to document

- Implementation details of individual functions (the code itself is the docs for that)
- Auto-generated code or boilerplate
- Test utilities (unless they embody important patterns)
- Trivial configuration (standard framework defaults)
- Anything already enforced by linter/formatter configs (reference the config file instead)

---

## Global scan checklist

### high-level-design.md

Examine these sources:
- Project root: README, docker-compose, Makefile, build scripts
- Dependency manifests: package.json, pom.xml, go.mod, requirements.txt, build.gradle, Cargo.toml
- Entry points: main files, server startup, CLI entrypoints
- Infrastructure files: Dockerfile, k8s manifests, Helm charts, terraform

Document using the High-Level Design Template from `references/templates.md`:
- **Architecture Overview**: Mermaid `graph TD` showing main components and relationships
- **Components**: list with one-line descriptions and source path pointers
- **Key Design Decisions**: one-liners with rationale
- **Data Flow**: Mermaid `sequenceDiagram` for the most important flow
- **Cross-Cutting Concerns**: error handling, logging, auth — brief descriptions or links

### codestyle.md

Examine these sources:
- Linter/formatter configs: .eslintrc, .prettierrc, rustfmt.toml, checkstyle.xml
- Existing style guides or CONTRIBUTING.md
- Code patterns: look at 3–5 representative files for naming, structure, error handling

Document using the Code Style Template. **Important**: list detected tooling first,
then only document conventions NOT already enforced by tooling. Skip sections that
linter configs already cover — reference the config file instead.

### deployment.md

Examine these sources:
- CI/CD: .github/workflows, .gitlab-ci.yml, Jenkinsfile, bitbucket-pipelines.yml
- Docker: Dockerfile, docker-compose.yml
- Cloud: terraform, cloudformation, helm, k8s manifests
- Config: .env.example, config files, secrets references

Document using the Deployment Template:
- **Build / Run Locally**: actual commands
- **Environment**: env vars with descriptions and defaults
- **Infrastructure**: Mermaid diagram of deploy topology
- **CI/CD**: pipeline stages, triggers, approvals
- **Monitoring**: health checks, metrics, logs

### data-model.md

Examine these sources:
- Data models: ORM entities, database schemas, API request/response types
- Migrations directory
- Business logic files: services, use cases, domain layer
- Existing documentation, README, wiki links

Document using the Data Model Template:
- **Entity Relationship**: Mermaid `erDiagram`
- **Tables / Collections**: columns, types, constraints, source file pointers
- **Indexes**: name, columns, purpose
- **Migrations**: ordered list with descriptions

### api.md (global)

Only if the project has a unified API surface. Document using the API Template:
- **Authentication**: how to authenticate
- **Endpoints**: method, path, request/response, errors, implementation pointer
- **Common Error Format**: standard error shape

### rationale.md

Start with an empty template. This gets populated incrementally through:
- Rationale Discovery during scan (unusual patterns flagged to user)
- `/lumen ingest` from meeting notes, emails, etc.
- Manual entries by the user

---

## Component scan checklist

For each component in `docs/<component-name>/`:

### README.md

Use the Component README Template from `references/templates.md`.

1. **Responsibility**: what this component owns and what it does NOT own (boundaries).
   One paragraph.

2. **Architecture**: Mermaid diagram showing internal structure and dependencies.

3. **Key Files**: the 3–7 most important files. Use file:function() pointers:
   `src/auth/handler.go:HandleLogin()`.

4. **Key Interfaces / Types**: main interfaces, structs, types that define the contract.
   Point to source with line numbers.

5. **Flows**: Mermaid `sequenceDiagram` for primary flows.

6. **Configuration**: relevant env vars or config with defaults.

7. **Dependencies**: internal (other components) and external (libraries, services).
   Note the nature: sync call, async message, shared DB, etc.

8. **Error Handling**: how errors are handled, propagated, or reported.

9. **Related Documents**: links to HLD and related components.

### api.md (component-specific, if applicable)

Only if the component exposes an API. Use the API Template.

### data-model.md (component-specific, if applicable)

Only if the component has its own data model. Use the Data Model Template.

---

## Incremental scan

When running `/lumen scan` on a repo that already has documentation:

1. Read existing content first — don't regenerate from scratch.
2. Compare detected state with documented state.
3. Update only sections where the code diverged from the docs.
4. Add a note at the top of updated files: `<!-- Last scan: YYYY-MM-DD -->`
5. Preserve any manually written content (the user may have enriched docs by hand).

---

## Handling large repos

For repos with many components (>10):

1. Scan and write global docs fully.
2. For components, propose a priority order to the user:
   *"This repo has 15 components. I suggest scanning these first: [top 5 by
   importance/activity]. Continue with the rest?"*
3. Process in batches using parallel orchestration (see `references/scan-parallel.md`).
4. Update `AGENTS.md` after each batch.
