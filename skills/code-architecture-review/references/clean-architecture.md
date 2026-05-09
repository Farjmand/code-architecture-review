# Clean Architecture Reference

## The Dependency Rule (The One Rule That Matters)

Source code dependencies must point inward only. Nothing in an inner circle can know about anything in an outer circle. Specifically: the name of something declared in an outer circle must not be mentioned in the inner circles.

```
         ┌─────────────────────────────────┐
         │  Frameworks & Drivers           │  ← outermost: DB, Web, UI, Devices
         │  ┌───────────────────────────┐  │
         │  │  Interface Adapters       │  │  ← Controllers, Presenters, Gateways
         │  │  ┌─────────────────────┐  │  │
         │  │  │  Use Cases          │  │  │  ← Application business rules
         │  │  │  ┌───────────────┐  │  │  │
         │  │  │  │  Entities     │  │  │  │  ← Enterprise business rules (innermost)
         │  │  │  └───────────────┘  │  │  │
         │  │  └─────────────────────┘  │  │
         │  └───────────────────────────┘  │
         └─────────────────────────────────┘
         Dependencies: always →  (inward)
```

---

## Layer Responsibilities

### Entities (Innermost)
- Pure business objects and rules that would exist even without software
- No framework imports, no DB imports, no HTTP imports
- Should be the most stable code in the system — changes rarely
- Examples: `User`, `Order`, `Invoice`, `Money`

**Violations to flag:**
- Entity importing from `orm/`, `db/`, `http/`, `express`, `django`, `sqlalchemy`
- Entities with `.save()`, `.findById()` methods (that's a repository's job)
- Entities containing validation that depends on external services

### Use Cases / Application Layer
- Orchestrates entities to fulfill a specific application goal
- One use case = one user story / one action
- Depends only on entities and abstract interfaces (ports)
- Does NOT know about HTTP, SQL, or UI

**Violations to flag:**
- `req.body`, `res.json()`, `HttpRequest` inside a use case
- Direct DB queries (e.g., `db.query(...)`) without going through a repository interface
- Use case importing a concrete ORM model instead of a domain entity

### Interface Adapters
- Converts data between the use case format and the external format
- Controllers: translate HTTP/CLI input → call use cases
- Presenters: translate use case output → HTTP response / view model
- Repositories (implementations): translate domain calls → SQL/NoSQL

**Violations to flag:**
- Controller containing business logic (should delegate to use case)
- Repository implementation importing domain entities in reverse (fine) vs domain importing repository concrete class (violation)

### Frameworks & Drivers (Outermost)
- The "glue" layer: Express, Django, Spring, React, PostgreSQL drivers, Redis clients
- Should be easily swappable without touching inner layers
- Typically thin — mostly wiring/config

**Violations to flag:**
- Framework-specific decorators or annotations bleeding into domain entities
- Test code that can only run with a live DB or HTTP server due to tight coupling

---

## Architecture Variants

### Hexagonal (Ports & Adapters)
Same idea, different vocabulary. "Ports" = interfaces defined by the application core. "Adapters" = implementations that plug into those ports from outside.

Good signal: a `ports/` or `interfaces/` directory at the core layer; concrete adapters in a separate `adapters/` directory.

### MVC
- Model: data + business rules (often conflated with DB model — this is the common problem)
- View: presentation
- Controller: routes input to model, passes result to view

**Common MVC violation:** "Fat Controller" — controllers with business logic that should be in the model/service layer.

### Feature-Sliced Design (Frontend)
Layers (top to bottom, stricter dependency direction):
- `app/` — entry point, providers, global config
- `pages/` — route-level compositions
- `widgets/` — complex standalone UI blocks
- `features/` — user-facing capabilities (login, checkout)
- `entities/` — domain objects and their UI
- `shared/` — reusable primitives, utils, UI kit

Rule: a layer can only import from layers below it. `features/` cannot import from `pages/`.

---

## Clean Architecture Checklist

**Layer isolation:**
- [ ] Domain/entity layer has zero framework imports
- [ ] Use cases / application layer has no HTTP or DB imports
- [ ] All cross-layer dependencies go through interfaces/abstractions
- [ ] Database schema changes don't require touching business logic

**Testability:**
- [ ] Core business logic can be unit-tested without spinning up a DB or HTTP server
- [ ] Repositories are behind interfaces that can be mocked
- [ ] Use cases accept injected dependencies (not `new ConcreteX()` internally)

**Boundary crossing:**
- [ ] Data crossing layer boundaries uses DTOs or plain data structures, not domain entities leaked outward
- [ ] No circular dependencies between layers

**Common violations severity:**
| Violation | Severity |
|-----------|----------|
| DB import in entity/domain layer | Critical |
| HTTP request object in use case | Critical |
| Business logic in controller | High |
| Missing repository abstraction | High |
| Framework annotation on domain class | Medium |
| Shared mutable state across layers | High |
| Test requires live DB due to coupling | Medium |
