# Code Architecture Review

A Claude Code plugin that audits your codebase for architectural issues, code smells, SOLID violations, and file structure problems — then hands you a prioritized, actionable report.

## What it checks

**Clean Architecture layers** — verifies the dependency rule (outer layers may depend on inner, never the reverse), flags business logic leaking into controllers or DB layer bleeding into domain code.

**SOLID principles** — scans for Single Responsibility violations (classes doing too many things), Open/Closed failures (if-else chains that grow with every new type), missing dependency inversion (concrete classes hardcoded instead of injected), and more.

**Code smells** — covers all 22 smells from Fowler's catalog, grouped by category: Bloaters (God Class, Long Method, Primitive Obsession), Change Preventers (Shotgun Surgery, Divergent Change), Couplers (Feature Envy, Message Chains), and Dispensables (Dead Code, Duplicate Code). Each finding includes the file, the smell name, severity, and the specific refactoring move.

**File & folder structure** — checks for feature-based vs type-based organization, circular dependencies, missing public API boundaries (index files), test colocation, and stack-specific best practices for Node.js, Python/Django/FastAPI, React/Next.js, Go, and monorepos.

## Usage

Once installed, trigger the skill naturally:

```
review my code architecture
check this project for code smells
is my folder structure following best practices?
audit my codebase
does this follow clean architecture?
```

Claude will scan the project, run the bundled directory scanner, and return a structured report:

```
# Architecture Review — [Project Name]

## TL;DR
## Architecture Score  (✅ / ⚠️ / ❌ per dimension)
## Critical Issues     (fix now)
## Warnings            (fix soon)
## Suggestions         (nice to have)
## What's Working Well
## Next Steps
```

## Installation

### From the official marketplace

```
/plugin install code-architecture-review@claude-plugins-official
```

### From this repository

```
/plugin marketplace add zahra-farjmand/code-architecture-review
/plugin install code-architecture-review@zahra-farjmand-code-architecture-review
```

### Local (for development / testing)

```
claude --plugin-dir ./code-arch-plugin
```

## What's inside

```
code-arch-plugin/
├── .claude-plugin/
│   └── plugin.json                        ← plugin metadata
├── skills/
│   └── code-architecture-review/
│       ├── SKILL.md                       ← 6-step review process
│       ├── references/
│       │   ├── clean-architecture.md      ← layer guide + checklist
│       │   ├── code-smells.md             ← 22-smell catalog with severity
│       │   └── file-structure-patterns.md ← patterns for 5 stacks
│       └── scripts/
│           └── scan_structure.sh          ← directory + file size scanner
└── README.md
```

## Supported stacks

Node.js / Express, Python (FastAPI, Django), React / Next.js (incl. Feature-Sliced Design), Go, and monorepos (Turborepo, Nx, pnpm workspaces).

## Contributing

Issues and PRs welcome at [github.com/Farjmand/code-architecture-review](https://github.com/Farjmand/code-architecture-review).

## License

MIT
