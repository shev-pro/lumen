# Project Fingerprint

How to assess a codebase before deciding what to document and how deeply.

The fingerprint replaces simple size-based categorization (small/medium/large) with
a multidimensional profile that drives documentation strategy. A 5-module fintech
backend needs deeper docs than a 20-module CRUD app — counting packages misses this.

---

## Table of Contents

- [Gathering the Fingerprint](#gathering-the-fingerprint)
- [Project Type Detection](#project-type-detection)
- [Complexity Signals](#complexity-signals)
- [Maturity Signals](#maturity-signals)
- [Building the Fingerprint Summary](#building-the-fingerprint-summary)
- [From Fingerprint to Documentation Strategy](#from-fingerprint-to-documentation-strategy)
- [Bootstrapping Mode (Empty Repo)](#bootstrapping-mode-empty-repo)
- [Scan Depth Assignment](#scan-depth-assignment)

---

## Gathering the Fingerprint

Explore these sources in order (stop early if the picture is clear):

1. **Root markers**: README, package.json, go.mod, Cargo.toml, pom.xml, build.gradle,
   pyproject.toml, Makefile, Dockerfile, docker-compose.yml, terraform/, helm/
2. **Directory structure**: depth 3–4, looking for service boundaries, module layout
3. **Entry points**: main files, server startup, CLI entrypoints, Lambda handlers,
   cron definitions, worker processes
4. **Integration surface**: SDK imports, HTTP clients, queue consumers/producers,
   database drivers, cloud service references
5. **Existing documentation**: README, CHANGELOG, ADR/, docs/, wiki links, OpenAPI
   specs, GraphQL schemas, Swagger files
6. **CI/CD and infra**: .github/workflows, .gitlab-ci.yml, Jenkinsfile, terraform/,
   k8s manifests, Dockerfile
7. **Test structure**: test directories, test frameworks, coverage configs
8. **Git history** (lightweight): first commit date, approximate contributor count,
   recent activity

---

## Project Type Detection

Identify one or more types. Most projects are a combination.

| Type | Detection signals |
|------|------------------|
| **API Service** | HTTP framework, route definitions, middleware, OpenAPI/Swagger |
| **Frontend / SPA** | React/Vue/Angular/Svelte, bundler config (vite, webpack), component directories |
| **CLI Tool** | cobra/clap/argparse, command definitions, flag parsing |
| **Library / SDK** | Published package config, public API surface, no server startup |
| **Infrastructure-as-Code** | Terraform, CloudFormation, Pulumi, Helm charts |
| **Data Pipeline** | ETL scripts, Airflow DAGs, Spark jobs, data transformation logic |
| **Monorepo** | Workspace config (npm/yarn/pnpm workspaces, Lerna, Nx, Turborepo, Bazel) |
| **Mobile App** | React Native, Flutter, Swift/Kotlin project files, Xcode/Gradle mobile configs |
| **Full-Stack** | Both frontend and backend in same repo without workspace tooling |
| **Event-Driven** | Message broker configs, event handlers, saga/choreography patterns |

A project can be multiple types: "API Service + Event-Driven" or "Monorepo containing
API Services + Frontend". Capture all that apply.

---

## Complexity Signals

These matter more than package count for deciding documentation depth.

### Entry Point Count

Count distinct ways the system starts or gets invoked:
- HTTP servers, gRPC servers
- CLI commands (not subcommands — top-level entry points)
- Lambda/Cloud Function handlers
- Worker/consumer processes
- Cron jobs, scheduled tasks
- Webhook receivers

More entry points = more surface area to document.

### Integration Density

Count external systems the code talks to:
- Third-party APIs (Stripe, SendGrid, Twilio, etc.)
- Cloud services (S3, SQS, DynamoDB, etc.)
- Databases (each distinct database, not each query)
- Message brokers (Kafka, RabbitMQ, Redis pub/sub)
- Auth providers (Auth0, Cognito, Okta)
- Monitoring/observability (Datadog, CloudWatch, Sentry)

High integration density (>3) warrants a dedicated `integrations.md`.

### Domain Complexity

Assess the richness of the business domain:
- **Low**: CRUD operations, simple data transformations, config-driven behavior
- **Medium**: Business rules with conditionals, multiple entity relationships,
  workflow states, role-based access
- **High**: Complex algorithms, state machines, financial calculations, regulatory
  logic, multi-step orchestration, domain-driven design patterns

High domain complexity means rationale documentation is essential from day one.

### Language Diversity

Count distinct programming languages with significant code (ignore config-only
languages like YAML/JSON):
- **1 language**: straightforward
- **2 languages**: common (e.g., Go + Terraform, TypeScript + Python)
- **3+ languages**: polyglot — cross-language conventions become important

### Pattern Diversity

Count distinct communication/API patterns:
- REST, GraphQL, gRPC, WebSocket, Server-Sent Events
- Sync request/response, async messaging, event sourcing, CQRS

More patterns = more architectural surface to document.

---

## Maturity Signals

These influence *how* to scan, not just *what* to document.

| Signal | How to detect | Impact on scan |
|--------|--------------|----------------|
| **Repo age** | First commit date | Young repos need foundational docs; mature repos need gap analysis |
| **Existing docs** | README quality, docs/ folder, ADR/, OpenAPI specs | Don't regenerate what exists — import and enrich |
| **Test coverage** | Test directories, coverage configs, CI test steps | Well-tested code needs less behavioral documentation |
| **CI/CD maturity** | Pipeline complexity, deploy automation | Mature CI/CD means deployment.md can reference configs rather than explain |
| **Contributor count** | Git shortlog | Solo projects need less process docs; team projects need conventions |
| **Recent activity** | Commits in last 30 days | Active repos benefit from `/lumen update`; dormant repos need a snapshot |

---

## Building the Fingerprint Summary

After gathering signals, produce a structured summary. This becomes the input for
documentation strategy decisions.

**Format:**

```
Project Fingerprint: <repo-name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Type:          <primary type> [+ secondary types]
Stack:         <languages, frameworks, databases, infra>
Languages:     <count> (<list>)

Entry points:  <count> (<list briefly>)
Integrations:  <count> (<list>)
Domain:        <Low | Medium | High> — <one-line justification>
Patterns:      <list communication patterns>

Maturity:      <Young | Established | Legacy>
Existing docs: <None | Partial | Comprehensive> — <what exists>
Test coverage:  <None | Low | Medium | High>
CI/CD:         <None | Basic | Mature>
Contributors:  <count>

Components detected: <count>
  <list with one-liner descriptions>
```

Present this to the user and ask for corrections before proceeding. The user knows
things the code doesn't reveal — planned migrations, deprecated components, external
constraints.

---

## From Fingerprint to Documentation Strategy

The fingerprint drives which documents to create and how to prioritize them.

### Always present (any project)

- `AGENTS.md` — entry point and navigation
- `docs/high-level-design.md` — architecture and component map

### Driven by project type

| Condition | Document | Why |
|-----------|----------|-----|
| Type includes API Service | `api.md` (global or per-component) | API surface is the primary contract |
| Type includes Frontend | Component tree, state management, routing sections in HLD | Frontend architecture is visual/structural |
| Type includes CLI Tool | Command reference in README or dedicated doc | CLI surface is the user contract |
| Type includes Library/SDK | Public API surface doc, usage examples | Consumers need the contract, not internals |
| Type includes IaC | `deployment.md` becomes primary doc, not secondary | Infra IS the product |
| Type includes Data Pipeline | Data flow doc, pipeline stages, scheduling | The flow is the architecture |
| Type includes Event-Driven | Event catalog, message schemas, flow diagrams | Events are the hidden API |

### Driven by complexity

| Condition | Document | Why |
|-----------|----------|-----|
| Integration density > 3 | `integrations.md` | External dependencies deserve dedicated tracking |
| Domain complexity = High | `rationale.md` from day one | Complex domains have non-obvious decisions |
| Pattern diversity > 2 | Expanded architecture section in HLD | Multiple patterns need explicit documentation |
| Language diversity ≥ 3 | Cross-language section in `codestyle.md` | Polyglot conventions prevent confusion |

### Driven by maturity

| Condition | Approach |
|-----------|----------|
| Existing OpenAPI/Swagger | Import into `api.md`, don't regenerate |
| Existing ADRs | Import into `rationale.md`, preserve format |
| Existing README with architecture | Use as input for HLD, don't discard |
| Mature CI/CD | `deployment.md` references pipeline configs, doesn't re-explain |
| No docs at all | Full scan, focus on architecture and decisions first |

### Presenting the strategy

Show the user a clear plan with reasoning:

```
Documentation Strategy
━━━━━━━━━━━━━━━━━━━━━━

Core (always):
  ✅ AGENTS.md
  ✅ high-level-design.md

Recommended for this project:
  ✅ api.md — 3 HTTP entry points detected
  ✅ data-model.md — PostgreSQL with 12 tables
  ✅ deployment.md — Terraform + Docker setup
  ✅ integrations.md — 5 external services (Stripe, SendGrid, S3, CloudWatch, Auth0)
  ✅ rationale.md — High domain complexity, decisions worth capturing

Skipping (with reason):
  ⬜ codestyle.md — .golangci.yml + .editorconfig cover conventions
  ⬜ Global api.md — each component has its own API surface

Components to document (<count>):
  <list with assigned scan depth>

Adjust anything?
```

Wait for user confirmation before proceeding.

---

## Bootstrapping Mode (Empty Repo)

When `/lumen init` runs on an empty or near-empty repo, the fingerprint can't be
built from code. The codebase has no source files to analyze — just maybe a bare
README or some config stubs.

### Procedure

1. **Ask the user** what they're building:
   *"This repo is empty or just getting started. To set up the right documentation
   structure, I need to know what you're planning to build."*

   Ask for:
   - What type of project (API, frontend, CLI, library, etc.)
   - Primary language/framework
   - Expected components or modules (even rough ideas)
   - Any existing specs, designs, or docs to ingest

2. **Build a provisional fingerprint** from the user's answers. Use the same format
   as a normal fingerprint, but mark it clearly:
   ```
   Project Fingerprint: <repo-name>
   Status: PROVISIONAL (built from user input, no code analyzed)
   ```
   Store `Status: provisional` in the AGENTS.md metadata. The first real `/lumen scan`
   when code exists will re-evaluate and replace it with a code-based fingerprint.

3. **Derive documentation strategy** from the provisional fingerprint, same logic as
   normal — but be conservative. When in doubt, create the stub (it's cheap to have
   an empty file; it's annoying to realize you need one later).

4. **Create stubs** with a provisional marker in each:
   `<!-- Provisional — will be populated by /lumen scan once code exists -->`

5. **Welcome message** reflects the bootstrapping state:
   ```
   🔆 Lumen initialized for <repo-name> (bootstrapping mode).

   Project type: <type(s) from user input>
   Status: Provisional — will re-evaluate when code is added

   Documentation structure created at docs/
   Stubs ready for: <list>

   Next steps:
     1. Start building your code
     2. Drop any specs/designs into docs/raw_data/ and run /lumen ingest
     3. When you have code, run /lumen scan to populate the docs
   ```

---

## Scan Depth Assignment

Not every component deserves the same level of documentation effort. Assign a scan
depth to each component based on its role and complexity.

### Deep Scan

For core domain components where the "why" matters as much as the "what".

**When to assign:**
- Component contains core business logic
- Complex algorithms, state machines, or orchestration
- High integration density within the component
- Frequently changed (high commit activity)

**What it produces:**
- Full README with all sections (architecture, flows, key files, interfaces, config,
  dependencies, error handling)
- Mermaid diagrams for architecture AND key flows
- API doc if the component exposes an API
- Data model doc if the component has its own data model
- Rationale discovery: actively look for unusual patterns and propose hypotheses

### Standard Scan

For important components that are well-structured and don't hide surprises.

**When to assign:**
- Component has clear responsibility and boundaries
- Moderate complexity, standard patterns
- Important for understanding the system but not the core domain

**What it produces:**
- README with responsibility, key files, dependencies, and one primary flow
- Architecture diagram
- API doc only if the component exposes a significant API
- No rationale discovery (unless something jumps out)

### Light Scan

For thin wrappers, adapters, simple configs, or generated code.

**When to assign:**
- Component is a thin wrapper around an external library
- Simple adapter or translation layer
- Configuration-only module
- Generated or boilerplate-heavy code

**What it produces:**
- README with 3–5 lines: what it wraps, why it exists, pointer to the code
- No diagrams, no flow documentation
- No separate API or data model docs

### Presenting the plan

```
Scan Plan
━━━━━━━━━

Deep:     auth, billing       (core domain, complex logic)
Standard: notifications, users, api-gateway, worker
Light:    infra               (Terraform wrapper)

Batch 1 (5): auth, billing, notifications, users, api-gateway
Batch 2 (2): worker, infra

Proceed?
```
