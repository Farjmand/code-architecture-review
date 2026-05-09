---
name: code-architecture-review
description: >
  Use this skill whenever the user wants to audit, review, or improve the architecture of a codebase.
  Trigger on phrases like: "review my architecture", "check for code smells", "is my folder structure good",
  "audit my codebase", "does this follow clean architecture", "check SOLID principles", "refactor suggestions",
  "tech debt review", "is this well structured", "check my project layout", or any time the user shares
  code or a project and asks if it's built correctly. Also trigger when the user says something like
  "look at my code" or "what do you think of this structure" even without explicit architecture language.
---

# Code Architecture Review

When this skill is invoked, perform a structured audit of the target codebase across four dimensions:
architecture layers, SOLID compliance, code smells, and file/folder structure. Produce a clear,
prioritized report the user can act on immediately.

---

## Step 1 — Orient Yourself

Before reviewing anything, get your bearings:

1. **Get the directory tree.** Run the bundled scanner script:
   ```bash
   bash scripts/scan_structure.sh <project-root>
   ```
   If the project root isn't specified, ask for it or use the current directory.

2. **Identify the stack.** Look for: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`,
   `build.gradle`, `pom.xml`, `*.csproj`. This tells you which language conventions apply.

3. **Identify the architectural intent.** Does the project use a named pattern?
   Look for clues in folder names (`domain/`, `usecases/`, `adapters/`, `infrastructure/`,
   `features/`, `modules/`, `components/`, `services/`, `controllers/`, `repositories/`).
   Common patterns: Clean Architecture, Hexagonal, MVC, Feature-Sliced, Layered, Modular Monolith.

4. **Sample key files.** Read 3-5 files that seem central — entry points, core business logic,
   a controller or handler, a data model. This gives you a feel for naming, coupling, and style.

---

## Step 2 — Architecture Layer Check

Consult `references/clean-architecture.md` for the full layer guide.

**Quick checks to run now:**

- Does the dependency direction flow inward only? (outer layers depend on inner, never reverse)
- Is business logic isolated from framework/DB/HTTP concerns?
- Can the core domain be tested without booting the full app?
- Are there any direct imports from `infrastructure/` or `db/` inside `domain/` or `entities/`?

Score each: ✅ Good / ⚠️ Partial / ❌ Violation

---

## Step 3 — SOLID Principles Scan

For each principle, look for specific evidence (not just "seems fine"):

| Principle | What to look for |
|-----------|-----------------|
| **SRP** (Single Responsibility) | Classes/modules doing >1 thing: mixing HTTP routing + business logic + DB calls |
| **OCP** (Open/Closed) | `if/else` or `switch` chains that grow when adding new types instead of using polymorphism |
| **LSP** (Liskov Substitution) | Subclasses that override methods to throw errors or return null, breaking contracts |
| **ISP** (Interface Segregation) | Interfaces with 10+ methods where implementors leave half unimplemented |
| **DIP** (Dependency Inversion) | `new ConcreteService()` inside high-level classes; no injection; no interfaces |

---

## Step 4 — Code Smell Scan

Consult `references/code-smells.md` for the full catalog with severity ratings.

**Priority smells to flag first (highest impact):**

1. **God Class / God Module** — one file doing everything
2. **Feature Envy** — a function that obsesses over another class's data
3. **Shotgun Surgery** — one change requires edits in 10 different files
4. **Duplicated Code** — same logic copy-pasted in multiple places
5. **Long Method** — functions >40 lines (>20 lines is worth a note)
6. **Primitive Obsession** — passing raw strings/ints where a type would be safer
7. **Dead Code** — unused functions, commented-out blocks, unreachable branches

For each smell found: name it, point to the specific file/line, and suggest the refactoring move.

---

## Step 5 — File & Folder Structure Audit

Consult `references/file-structure-patterns.md` for patterns by stack.

**Universal checks:**

- Is the structure organized by **feature/domain** or by **type** (controllers/, models/, views/)?
  Feature-based is almost always better — easier to navigate and delete.
- Are there circular imports/dependencies between modules?
- Do modules expose clean public APIs (index files) or do they reach into each other's internals?
- Is test code colocated with source or separated? (Colocation is generally preferred)
- Are config, scripts, and tooling at the root and clearly labeled?
- Is there a clear entry point (`main.ts`, `app.py`, `index.js`, `main.go`)?

---

## Step 6 — Generate the Report

ALWAYS produce the report in this exact structure:

```
# Architecture Review — [Project Name]

## TL;DR
[2-3 sentences: overall health, biggest issue, biggest strength]

## Architecture Score
| Dimension | Score | Notes |
|-----------|-------|-------|
| Layer separation | ✅/⚠️/❌ | |
| SOLID compliance | ✅/⚠️/❌ | |
| Code smells | ✅/⚠️/❌ | |
| File structure | ✅/⚠️/❌ | |

## Critical Issues (fix now)
[Issues that create bugs, block testing, or make the codebase hard to change]

### [Issue name] — [file:line if applicable]
**Problem:** [what's wrong and why it matters]
**Fix:** [concrete refactoring move with example if helpful]

## Warnings (fix soon)
[Issues that aren't urgent but will compound over time]

## Suggestions (nice to have)
[Low-priority improvements, style, or modernization ideas]

## What's Working Well
[Genuine strengths — don't skip this, it helps the user know what not to break]

## Next Steps
[Ordered list of 3-5 actions, most impactful first]
```

---

## Calibration Notes

- **Be specific.** "This file has high coupling" is useless. "UserService imports directly from PostgresAdapter on line 34, creating a hard dependency on the DB layer" is actionable.
- **Be honest but kind.** Most codebases have real problems. Name them clearly without making the developer feel attacked.
- **Don't over-flag.** A 50-line function in a script file is not a "Long Method" smell. Apply judgment based on context.
- **Match severity to impact.** A missing interface is a warning. Business logic in a DB migration is critical.
- **Respect the stack.** Clean Architecture in a Django monolith looks different from Clean Architecture in a Go microservice. Don't penalize idiomatic patterns.
