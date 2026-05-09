# File & Folder Structure Patterns

## The Core Principle: Organize by Feature, Not by Type

**Bad (type-based):**
```
src/
├── controllers/
│   ├── userController.js
│   ├── orderController.js
│   └── productController.js
├── models/
│   ├── user.js
│   ├── order.js
│   └── product.js
└── services/
    ├── userService.js
    ├── orderService.js
    └── productService.js
```
Problem: To understand or change the "order" feature, you must navigate three separate directories.

**Good (feature-based):**
```
src/
├── users/
│   ├── user.model.js
│   ├── user.service.js
│   ├── user.controller.js
│   └── user.test.js
├── orders/
│   ├── order.model.js
│   ├── order.service.js
│   ├── order.controller.js
│   └── order.test.js
└── shared/
    ├── middleware/
    └── utils/
```
Benefit: Deleting a feature = deleting one directory. Understanding a feature = reading one directory.

---

## Patterns by Stack

### Node.js / Express API

```
project/
├── src/
│   ├── features/              ← feature modules
│   │   ├── auth/
│   │   │   ├── auth.routes.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.dto.ts
│   │   │   └── auth.test.ts
│   │   └── users/
│   ├── shared/                ← cross-cutting concerns
│   │   ├── middleware/
│   │   ├── errors/
│   │   └── utils/
│   ├── infrastructure/        ← DB, external APIs, config
│   │   ├── database/
│   │   └── email/
│   └── app.ts                 ← wires everything together
├── tests/                     ← integration/e2e tests
├── package.json
└── tsconfig.json
```

**Red flags for Node projects:**
- `routes/` at root level importing directly from `models/`
- `app.js` with hundreds of lines of business logic
- No separation between HTTP layer and business layer
- `require('../../../utils/helper')` — deep relative imports signal poor structure

### Python / FastAPI / Django

**FastAPI feature-based:**
```
app/
├── api/
│   └── v1/
│       ├── routers/
│       │   ├── users.py
│       │   └── orders.py
│       └── __init__.py
├── core/                      ← config, security, deps
├── models/                    ← SQLAlchemy models (or per-feature)
├── schemas/                   ← Pydantic schemas (DTOs)
├── services/                  ← business logic
├── repositories/              ← DB access layer
└── main.py
```

**Django app-based (already feature-sliced by design):**
```
project/
├── apps/
│   ├── users/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   └── tests/
│   └── orders/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   └── urls.py
└── manage.py
```

**Red flags for Python projects:**
- All logic in `views.py` (fat views)
- Models with `.send_email()`, `.charge_card()` methods (too many responsibilities)
- No `tests/` directory or tests mixed with source without clear naming
- `settings.py` without environment split (dev/prod in one file)

### React / Next.js Frontend

**Feature-Sliced Design (recommended for large apps):**
```
src/
├── app/                       ← routing, providers, layout
├── pages/                     ← Next.js pages or route components
├── widgets/                   ← complex composed UI blocks
├── features/                  ← user interactions (login, checkout)
│   └── auth/
│       ├── ui/
│       ├── model/             ← state, hooks
│       └── api/
├── entities/                  ← domain objects + their UI
│   └── user/
│       ├── ui/
│       └── model/
└── shared/                    ← reusable primitives
    ├── ui/                    ← base components (Button, Input)
    ├── lib/                   ← utilities
    ├── api/                   ← HTTP client config
    └── config/                ← env, constants
```

**Simpler apps:**
```
src/
├── components/                ← shared/generic components
├── features/                  ← feature-specific components + logic
│   ├── auth/
│   └── dashboard/
├── hooks/                     ← shared custom hooks
├── services/                  ← API calls
├── store/                     ← global state
├── types/                     ← TypeScript types
└── utils/
```

**Red flags for React projects:**
- `components/` with 50+ files, no subfolders (flat component soup)
- Business logic in components rather than hooks or services
- Direct API calls inside components (no service layer)
- Global state (Redux/Zustand) used for local UI state
- No co-located tests or Storybook stories

### Go

```
project/
├── cmd/
│   └── server/
│       └── main.go            ← entry point
├── internal/                  ← private packages (not importable externally)
│   ├── domain/                ← entities, interfaces (no dependencies)
│   ├── application/           ← use cases
│   ├── infrastructure/        ← DB, HTTP clients
│   └── handlers/              ← HTTP handlers
├── pkg/                       ← public reusable packages
├── config/
└── go.mod
```

**Red flags for Go projects:**
- Everything in one package (no separation)
- HTTP handler logic mixed with DB queries in the same function
- No use of `internal/` to enforce package boundaries

### Monorepo

```
monorepo/
├── apps/                      ← deployable applications
│   ├── web/
│   ├── api/
│   └── mobile/
├── packages/                  ← shared libraries
│   ├── ui/                    ← shared component library
│   ├── utils/
│   └── types/
├── tools/                     ← build scripts, generators
├── configs/                   ← shared ESLint, TSConfig, etc.
├── turbo.json / nx.json       ← build orchestration
└── package.json
```

**Red flags for monorepos:**
- `apps/` importing from `apps/` (cross-app imports)
- Deep internal imports: `import { foo } from '../../packages/ui/src/components/Button/internal'`
- No clear public API for packages (missing `index.ts` barrel exports)
- All packages built even when only one changed (no caching/affected detection)

---

## Universal File Structure Red Flags

| Red Flag | Why It's a Problem |
|----------|--------------------|
| Files named `utils.js`, `helpers.py`, `misc.ts` | Dumping ground — anything can go in and nothing has a clear home |
| Root-level files growing without bound | `index.js` with 800 lines means the entry point became the app |
| No `tests/` or test files anywhere | Untestable or just untested — either is a problem |
| `temp/`, `old/`, `backup/` directories | Junk in the repo — use git for history |
| Deeply nested directories (>4 levels) | Navigation nightmare; usually signals over-engineering |
| Module A and Module B import each other | Circular dependency — causes hard-to-debug initialization issues |
| Everything in one directory | No organization; works for scripts, not for applications |
| `constants.js` with 500 constants | Not organized by domain — use feature-level constants files |
| Config files without env separation | `settings.py` in prod is the same as dev = hardcoded secrets risk |

---

## Dependency Direction Rules

In any well-structured project, imports should generally flow:
```
entry point → features → domain/entities → shared utilities
```
And never:
```
shared → features (shared depends on a feature = circular)
domain → infrastructure (domain depends on DB = violation)
feature A → feature B's internals (feature coupling)
```

The test: if you deleted `featureA/`, would `featureB/` break? If yes, you have coupling. If no, you have clean boundaries.
