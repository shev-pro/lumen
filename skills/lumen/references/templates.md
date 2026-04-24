# Document Templates

Ready-to-fill templates for each document type. Read this file during `/lumen scan`
and `/lumen rules`.

---

## Log Template

`docs/log.md` is always created at init and appended to by every Lumen command.
It is append-only — never edit or delete past entries.

```markdown
# Lumen Log

Append-only record of Lumen operations for <repo-name>.
Each entry: `## [YYYY-MM-DD] <command> | <summary>`
Parse with: `grep "^## \[" docs/log.md | tail -10`

---

## [YYYY-MM-DD] init | Initialized for <repo-name> — <type(s)>, <stack summary>
```

**Entry formats by command:**

| Command | Entry format |
|---------|-------------|
| init | `## [YYYY-MM-DD] init \| Initialized for <repo-name> — <type(s)>, <stack>` |
| scan | `## [YYYY-MM-DD] scan \| <N> components (<deep>D/<std>S/<light>L), <M> global docs` |
| ingest | `## [YYYY-MM-DD] ingest \| <N> files — <knowledge types extracted>` |
| update | `## [YYYY-MM-DD] update \| Commits <SHA>..<SHA> — <N> docs updated` |
| lint | `## [YYYY-MM-DD] lint \| <N> contradictions, <M> stale claims, <K> orphan concepts` |
| query | `## [YYYY-MM-DD] query \| "<question summary>" — <filed as docs/X.md \| not filed>` |

---

## Project Context Template

`docs/project-context.md` captures the non-technical layer: what stakeholders need,
why the project exists, constraints not visible in code, and team/process context.
This is the source of truth for *context and rationale*, complementing the code as
source of truth for implementation.

```markdown
# Project Context

<1-2 sentences: what this project is for and who it serves.>

## Stakeholders

<Who commissioned or owns this project. What they care about.>

- **<Stakeholder / team>** — <what they need from this project>
- ...

## Goals & Success Criteria

<What does success look like? What metrics or outcomes matter?>

- ...

## Constraints

<Hard limits that shape the project — legal, contractual, technical, timeline.>

- **<Constraint>** — <source and implication>
- ...

## Requirements

<Key functional or non-functional requirements captured from specs, stakeholder
conversations, or ingested documents. Link to rationale.md for decisions they drove.>

### Must Have

- ...

### Should Have

- ...

### Won't Have (in scope)

- ...

## Team & Process

<How the team works. Relevant conventions, cadences, or constraints on process.>

- **Branching strategy:** ...
- **Release cadence:** ...
- **On-call / ownership:** ...

## Planned Changes

<Decisions made or requirements received that are not yet implemented.>

- **<Change>** — <source, expected timeline if known>

## Open Questions

<Unresolved topics from stakeholder conversations or planning sessions.>

- **<Question>** — <raised by whom, when, what's blocking resolution>

## Related Documents

- [Rationale](rationale.md) — technical decisions driven by these constraints
- [High-Level Design](high-level-design.md)
```

---

## AGENTS.md Template

```markdown
# <Project Name>

<1-2 sentence description of what this project does.>

## Tech Stack

- **Language:** ...
- **Framework:** ...
- **Database:** ...
- **Messaging:** ...
- **Deployment:** ...

## Project Structure

<Brief description of top-level directory layout.>

```
├── src/           # ...
├── pkg/           # ...
├── cmd/           # ...
├── docs/          # Project documentation
└── ...
```

## Key Entry Points

- **Main entrypoint:** `cmd/main.go`
- **Config loading:** `src/config/config.go`
- **HTTP routes:** `src/routes/router.go`
- ...

## Documentation Index

- [High-Level Design](docs/high-level-design.md) — Architecture and key decisions
- [Component Name](docs/component-name/) — Component deep dive
- [API](docs/api.md) — API endpoints and contracts
- [Data Model](docs/data-model.md) — Database schema and data flows
- [Code Style](docs/codestyle.md) — Naming conventions, comments, idioms
- [Rationale](docs/rationale.md) — Non-obvious decisions with reasoning
- [Project Context](docs/project-context.md) — Stakeholder context, requirements, constraints
- [Deployment](docs/deployment.md) — Build, deploy, infrastructure
- [Log](docs/log.md) — Operation history

## Development

<Brief: how to build, run, test. Keep to essentials.>

## Configuration

<Key env vars or config files.>

- `PORT` — HTTP listen port (default: `8080`)
- ...

## Metadata

| Field | Value |
|-------|-------|
| **Managed by** | [Lumen](skills/lumen/) — project knowledge keeper skill |
| **Project type** | <type(s) from fingerprint> |
| **Domain complexity** | <Low / Medium / High> |
| **Integration density** | <count> |
| **Scan depths** | <Deep: list, Standard: list, Light: list> |
| **Fingerprint status** | <active / provisional> |
| **Last scan** | <YYYY-MM-DD> |
| **Last ingest** | <YYYY-MM-DD> |
| **Last lint** | <YYYY-MM-DD> |
| **Last update commit** | <short SHA> |
| **Lumen version** | 2.0 |
```

---

## High-Level Design Template

```markdown
# High-Level Design

<1-2 sentence summary of the system's purpose and architecture style.>

## Architecture Overview

<Mermaid diagram showing main components and their relationships.>

```mermaid
graph TD
    A[Client] --> B[API Gateway]
    B --> C[Service A]
    B --> D[Service B]
    C --> E[(Database)]
    D --> F[(Cache)]
```

## Components

- **Service A** — Handles X → `src/service-a/`
- **Service B** — Handles Y → `src/service-b/`
- ...

## Key Design Decisions

- **Auth strategy:** JWT — Stateless, scales horizontally
- ...

## Data Flow

<Sequence diagram for the most important flow.>

```mermaid
sequenceDiagram
    participant C as Client
    participant A as API
    participant DB as Database
    C->>A: POST /resource
    A->>DB: INSERT
    DB-->>A: OK
    A-->>C: 201 Created
```

## Cross-Cutting Concerns

- **Error handling:** <brief description or link>
- **Logging:** <brief description or link>
- **Authentication:** <brief description or link>

## Related Documents

- [Component A](component-a/)
- [Component B](component-b/)
```

---

## Component README Template

```markdown
# <Component Name>

<1-2 sentence summary: what this component does and why it exists.>

## Responsibility

<What this component owns. What it does NOT own (boundaries).>

## Architecture

```mermaid
graph TD
    A[Input] --> B[Component]
    B --> C[Output]
    B --> D[Dependency]
```

## Key Files

- `src/component/handler.go` — HTTP handlers
- `src/component/service.go` — Business logic
- `src/component/repo.go` — Data access
- ...

## Key Interfaces / Types

<Main interfaces, structs, or types that define this component's contract. Point to source.>

- `Handler` — HTTP handler interface → `src/component/handler.go:15`
- `Service` — Business logic → `src/component/service.go:22`

## Flows

### <Primary Flow Name>

```mermaid
sequenceDiagram
    participant H as Handler
    participant S as Service
    participant R as Repository
    H->>S: ProcessRequest()
    S->>R: FindByID()
    R-->>S: Entity
    S-->>H: Response
```

## Configuration

- `...` — ... (default: `...`)

## Dependencies

- **Internal:** <list internal dependencies>
- **External:** <list external services/APIs>

## Error Handling

<How errors are handled, propagated, or reported in this component.>

## Related Documents

- [High-Level Design](../high-level-design.md)
- [Related Component](../related-component/)
```

---

## API Document Template

```markdown
# API Reference

<1 sentence: what API this covers and its base path.>

## Authentication

<How to authenticate. Token format, header name, etc.>

## Endpoints

### `POST /api/v1/resource`

<Short description.>

**Request:**
```json
{
  "field": "value"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "field": "value"
}
```

**Errors:**

- `400` — Invalid input
- `401` — Unauthorized
- `404` — Resource not found

**Implementation:** `src/handler/resource.go:Create()`

---

### `GET /api/v1/resource/:id`

<Repeat pattern for each endpoint.>

## Common Error Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "field X is required"
  }
}
```
```

---

## Data Model Template

```markdown
# Data Model

<1 sentence: what data this system manages.>

## Entity Relationship

```mermaid
erDiagram
    USER ||--o{ ORDER : places
    ORDER ||--|{ LINE_ITEM : contains
    PRODUCT ||--o{ LINE_ITEM : "ordered in"
```

## Tables / Collections

### `users`

- `id` (UUID, PK) — User identifier
- `email` (VARCHAR(255), UNIQUE, NOT NULL) — Login email
- `created_at` (TIMESTAMP, NOT NULL) — Creation timestamp

**Defined in:** `migrations/001_create_users.sql`

### `orders`

<Repeat for each table.>

## Indexes

- `idx_users_email` on `users(email)` — Login lookup

## Migrations

- `migrations/001_create_users` — Initial user table
- `migrations/002_add_orders` — Order and line item tables
```

---

## Code Style Template

```markdown
# Code Style

<1 sentence: how code style is managed in this project.>

## Style Tooling

<If linter/formatter configs exist, list them here and skip sections they already cover.>

- **Formatter:** `.prettierrc` — handles spacing, line length, quotes
- **Linter:** `.eslintrc` — enforces import order, unused vars, etc.
- **Editor config:** `.editorconfig` — indent style, trailing whitespace

> Sections below only document conventions **not enforced by tooling**.

## Naming Conventions

### Files & Directories

- <pattern, e.g. "kebab-case for files, PascalCase for React components">

### Variables & Functions

- <pattern, e.g. "camelCase for functions, UPPER_SNAKE for constants">
- <domain-specific prefixes/suffixes, e.g. "repositories suffixed with `Repo`">

### Types & Interfaces

- <pattern, e.g. "PascalCase, no `I` prefix for interfaces">

## Comments

- <when to comment: non-obvious intent, trade-offs, constraints — never narrate what the code does>
- <doc comment style, e.g. "JSDoc for public APIs", "godoc format">

## Code Organization

- <file structure patterns, e.g. "one exported type per file", "group by feature not layer">
- <import ordering, e.g. "stdlib → external → internal, blank line between groups">

## Error Handling

- <pattern, e.g. "return errors, don't panic", "use custom error types from `pkg/errors`">

## Idioms & Patterns

- <project-specific patterns, e.g. "constructor functions named `New<Type>`">
- <anti-patterns to avoid>

## Related

- [High-Level Design](high-level-design.md)
```

---

## Rationale Template

```markdown
# Rationale

Non-obvious decisions in this project that deviate from common patterns or best
practices, with reasoning.

> Built incrementally during codebase exploration. Each entry captures something
> that looks unusual and why it exists.

---

### <Short Decision Title>

- **Date:** YYYY-MM-DD
- **Status:** active | superseded | deprecated
- **Context:** <What problem or constraint led to this decision>
- **Decision:** <What was chosen>
- **Alternatives considered:** <What else was evaluated and why rejected>
- **Rationale:** <Why this choice, despite not being the obvious/standard approach>

---

### <Another Decision>

...
```

---

## Integrations Template

```markdown
# External Integrations

<1 sentence: what external services this system depends on and why they matter.>

## Service Catalog

| Service | Purpose | Used by | Auth method |
|---------|---------|---------|-------------|
| Stripe | Payment processing | billing, checkout | API key (secret) |
| SendGrid | Transactional email | notifications | API key |
| Auth0 | User authentication | auth, api-gateway | OAuth2 / JWKS |
| S3 | File storage | uploads, reports | IAM role |
| Redis | Caching + job queue | api-gateway, worker | Connection string |

## Dependency Map

```mermaid
graph TD
    SYS[Our System] --> STRIPE[Stripe]
    SYS --> SG[SendGrid]
    SYS --> AUTH0[Auth0]
    SYS --> S3[AWS S3]
    SYS --> REDIS[Redis]
```

## Per-Service Details

### Stripe

- **Purpose:** Payment processing — charges, subscriptions, refunds
- **Used by:** `billing` component → `src/billing/stripe_client.go`
- **Base URL:** `https://api.stripe.com/v1`
- **Auth:** API key via `STRIPE_SECRET_KEY` env var
- **Rate limits:** 100 req/s (live mode)
- **Error handling:** Retries with exponential backoff → `src/billing/retry.go`
- **Fallback:** Queues failed charges for manual review
- **Webhook:** `POST /webhooks/stripe` → `src/billing/webhook_handler.go`

### <Next Service>

<Repeat pattern for each service.>

## Environment Variables

| Variable | Service | Required | Default |
|----------|---------|----------|---------|
| `STRIPE_SECRET_KEY` | Stripe | yes | — |
| `SENDGRID_API_KEY` | SendGrid | yes | — |
| `AUTH0_DOMAIN` | Auth0 | yes | — |
| `AWS_S3_BUCKET` | S3 | yes | — |
| `REDIS_URL` | Redis | yes | `localhost:6379` |
```

---

## Deployment Template

```markdown
# Deployment

<1 sentence: how this project is built, deployed, and run.>

## Build

```bash
# Build command
make build
```

## Run Locally

```bash
# Local development
make dev
```

## Environment

- `DATABASE_URL` (required) — Postgres connection
- `PORT` — HTTP port (default: `8080`)

## Infrastructure

```mermaid
graph TD
    LB[Load Balancer] --> A[Instance 1]
    LB --> B[Instance 2]
    A --> DB[(Database)]
    B --> DB
```

## CI/CD

<Pipeline description: what triggers builds, what runs, where it deploys.>

## Monitoring

- **Health check:** `GET /health`
- **Metrics:** <where/how>
- **Logs:** <where/how>
```
