# hiivmind-corpus

Claude Code skills for creating and maintaining documentation corpus indexes.

## What is a "meta-skill"?

This is a skill that **creates other skills**.

Most Claude Code skills help you do something directly—write code, search files, fetch data. This plugin is different: it helps you **build custom corpus skills** for navigating any project's documentation.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  hiivmind-corpus (meta-plugin) - 6 skills                                   │
│                                                                             │
│  corpus-init → corpus-build → corpus-refresh → corpus-upgrade               │
│       │             ↑              ↓                                        │
│       │        add-source      enhance                                      │
│       ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ hiivmind-corpus-fullstack                                            │   │
│  │   Sources: react (git) + team-standards (local) + blog-posts (web)   │   │
│  └──────────────────────────────────┬───────────────────────────────────┘   │
└─────────────────────────────────────┼───────────────────────────────────────┘
                                      ▼
                    React docs + Team docs + Blog articles
```

The corpus skills you generate are:
- **Persistent** — committed to your repo, survive across sessions
- **Tailored** — built collaboratively around your actual use case
- **Maintainable** — track upstream changes, know when they're stale
- **Multi-source** — combine git repos, local documents, and web content

Think of it as a skill factory: you feed it documentation sources, and it produces a specialized corpus skill with a unified index.

## Four ways to create corpus skills

When you run `hiivmind-corpus-init`, it detects your context and offers appropriate destination types:

### 1. User-level skill

```
~/.claude/skills/hiivmind-corpus-polars/
├── SKILL.md
├── data/
│   ├── config.yaml
│   ├── index.md
│   └── project-awareness.md
└── .source/polars/
```

**Best for:** Personal use across all your projects without sharing.

**Example:** "I want Polars docs available everywhere I work."

### 2. Repo-local skill

```
your-project/
├── .claude-plugin/
│   └── skills/
│       └── hiivmind-corpus-polars/    ← Created here
│           ├── SKILL.md
│           └── data/
└── src/
    └── analysis.py
```

**Best for:** Team sharing—everyone who clones the repo gets the skill automatically.

**Example:** "Our data team all need Polars docs while working on this project."

### 3. Single-corpus plugin

```
hiivmind-corpus-react/                 ← This directory IS the plugin
├── .claude-plugin/plugin.json
├── skills/navigate/SKILL.md
├── data/
├── CLAUDE.md
└── README.md
```

**Best for:** Publishing a standalone corpus to the marketplace.

**Example:** "I want to publish React docs as a reusable plugin."

### 4. Multi-corpus plugin (marketplace)

```
hiivmind-corpus-frontend/              ← Marketplace root
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── hiivmind-corpus-react/             ← Child plugin
│   ├── .claude-plugin/plugin.json
│   ├── skills/navigate/
│   └── data/
├── hiivmind-corpus-vue/               ← Another child plugin
│   └── ...
└── README.md
```

**Best for:** Collections of related documentation (frontend frameworks, data tools, etc.).

**Example:** "I want React, Vue, and Svelte docs in one installable package."

### Comparison

| Aspect | User-level | Repo-local | Single-corpus | Multi-corpus |
|--------|------------|------------|---------------|--------------|
| Location | `~/.claude/skills/` | `.claude-plugin/skills/` | Repo root | Marketplace + subdirs |
| Scope | All your projects | One project | All (via install) | All (via install) |
| Team sharing | No | Yes (via git) | Via marketplace | Via marketplace |
| Marketplace | No | No | Yes | Yes |
| Multiple corpora | No | No | No | Yes |

## Installation

```bash
# Add the marketplace
/plugin marketplace add hiivmind/hiivmind-corpus

# Install the plugin
/plugin install hiivmind-corpus
```

## Overview

This plugin provides skills to:
- Generate corpus skills for any open source project
- Build collaborative, human-readable indexes
- Keep indexes in sync with upstream changes
- Navigate docs with or without a local clone

## Why use this?

### The problem with default documentation lookup

Without structured indexing, Claude investigates libraries by:

1. **Relying on training data** - May be outdated or incomplete
2. **Web searching** - Hit-or-miss, often finds outdated tutorials
3. **Fetching URLs on demand** - One page at a time, no context
4. **Reading installed packages** - Limited to code, not prose docs

**This means:**
- Rediscovering the same things every session
- No memory of what's relevant to *your* work
- Search results aren't curated
- Large doc sites are hard to navigate systematically
- Training cutoff means stale knowledge for fast-moving projects

### What hiivmind-corpus provides

| Capability | Benefit |
|------------|---------|
| **Curated index** | Built collaboratively around your actual use case |
| **Persistent** | Committed to repo, survives across sessions |
| **Current** | Tracks upstream commits, knows when it's stale |
| **Structured** | Systematically find relevant sections |
| **Flexible** | Works with local clone or remote fetch |

### When to use this vs. default lookup

**Use hiivmind-corpus when:**
- Documentation is large (100+ pages)
- You have specific, recurring needs (not one-off questions)
- Docs change frequently
- Official docs are the authoritative source

**Default lookup is fine when:**
- Quick one-off question
- Small library with simple docs
- Just need a code snippet
- Docs are stable and well-known

### The real win

The collaborative index building. Rather than Claude guessing what matters, you tell it: "I care about data modeling and ETL, skip the deployment stuff." That context persists across sessions.

## Structure

```
.
├── .claude-plugin/
│   └── plugin.json                 # Root plugin manifest
├── skills/
│   ├── hiivmind-corpus-init/       # Create new corpus skills
│   ├── hiivmind-corpus-add-source/ # Add sources to existing corpus
│   ├── hiivmind-corpus-build/      # Analyze docs, build index
│   ├── hiivmind-corpus-enhance/    # Deepen specific topics
│   ├── hiivmind-corpus-refresh/    # Refresh from upstream changes
│   └── hiivmind-corpus-upgrade/    # Upgrade existing corpora to latest standards
├── templates/                      # Templates for generated skills
└── docs/                           # Specifications
```

## Workflow

```
hiivmind-corpus-init  →  hiivmind-corpus-build  →  hiivmind-corpus-refresh
     (structure)              (index)                 (per-source tracking)
                                 ↑
                        hiivmind-corpus-add-source
                           (git, local, web)
                                 ↓
                        hiivmind-corpus-enhance
                           (deepen topics)
                                 ↓
                        hiivmind-corpus-upgrade
                      (when meta-plugin evolves)
```

| Skill | When | What |
|-------|------|------|
| `hiivmind-corpus-init` | Once per corpus | Creates folder structure, config, navigate skill |
| `hiivmind-corpus-add-source` | To expand corpus | Adds git repos, local documents, or web pages |
| `hiivmind-corpus-build` | After adding sources | Analyzes all sources, builds unified index |
| `hiivmind-corpus-enhance` | As needed | Expands coverage on specific topics (can span sources) |
| `hiivmind-corpus-refresh` | Ongoing | Checks each source for updates, refreshes index |
| `hiivmind-corpus-upgrade` | When meta-plugin updates | Brings existing corpora to latest template standards |

## Usage

### Create a new corpus skill

```
"Create a corpus skill for ClickHouse"
"Create an empty corpus skill called fullstack-docs"
```

This will:
1. Ask where to create it (project-local or standalone)
2. Ask for initial source type (git repo or start empty)
3. Clone docs repo to `.source/{source_id}/` (if git)
4. Generate corpus structure with config and navigate skill

### Add sources to existing corpus

```
"Add TanStack Query docs to my corpus"
"Add our team standards as a local source"
"Add these blog posts to my corpus" (with URLs)
```

Three source types are supported:

| Type | Description | Storage |
|------|-------------|---------|
| **git** | Clone a documentation repository | `.source/{source_id}/` |
| **local** | User-uploaded markdown files | `data/uploads/{source_id}/` |
| **web** | Fetched and cached web pages | `.cache/web/{source_id}/` |

### Build the index

```
"Build the hiivmind-corpus-fullstack index"
```

This will:
1. Prepare all sources (clone git, verify local, check web cache)
2. Scan each source and present combined summary
3. Ask about your use case and priorities
4. Build unified `index.md` with source-prefixed paths
5. Save per-source tracking metadata

### Navigate documentation

```
"How do I set up React hooks?"
"What are our team's testing standards?"
```

The navigate skill will:
1. Search the index for relevant docs
2. Resolve the source from the path prefix (e.g., `react:`, `local:`, `web:`)
3. Fetch content from appropriate location
4. Answer with citations

### Enhance a topic

```
"Enhance the Testing section with content from all sources"
"Add more detail on hooks from both React docs and the blog posts"
```

This will:
1. Read the current index
2. Search across relevant sources
3. Collaboratively expand with cross-source entries
4. Group by topic or source as preferred

### Refresh from upstream

```
"Check if my corpus needs updating"
"Refresh the react source"
```

Each source type has different refresh behavior:
- **git**: Compare commit SHA, show diff of changed files
- **local**: Detect new/modified files by timestamp
- **web**: Show cache age, re-fetch with user approval

### Make projects aware of your corpus

```
"Add project awareness to my Python project's CLAUDE.md"
```

Each corpus includes a `data/project-awareness.md` file with a ready-to-use snippet. When working in a project that uses a documented library, inject this snippet into the project's CLAUDE.md so Claude knows to use the corpus.

### Upgrade existing corpora

```
"Upgrade my polars corpus to latest standards"
"Upgrade all corpora in this marketplace"
```

When the meta-plugin adds new features (like project awareness or tiered index support), use `hiivmind-corpus-upgrade` to bring existing corpora up to date. It detects missing files and sections, then applies upgrades with your approval.

## Advanced Features

### Tiered Indexes (Large Corpora)

For documentation sets with 500+ files, a single index becomes unwieldy. The build skill offers tiered indexing:

```
data/
├── index.md              # Main index with section summaries + links
├── index-reference.md    # Detailed API reference entries
├── index-guides.md       # Detailed guides/tutorials
└── index-concepts.md     # Detailed conceptual docs
```

The main index provides quick lookups and links to detailed sub-indexes. The enhance and refresh skills understand this structure and update the appropriate files.

### Large Structured Files

Some documentation includes large structured files (GraphQL schemas, OpenAPI specs, JSON schemas) that are too large to read directly. These are marked in the index with `⚡ GREP`:

```markdown
- **GraphQL Schema** `api-docs:schema.graphql` ⚡ GREP - API schema (15k lines). Search with: `grep -n "^type {Name}" ... -A 30`
```

The navigate skill uses Grep instead of Read for these files, searching for specific definitions.

### Project Awareness

Projects using a documented library may not know a corpus skill is available. Each corpus includes `data/project-awareness.md`—a snippet to add to any project's CLAUDE.md:

```markdown
# Polars Documentation Corpus

A curated documentation corpus for Polars is available. Use the
**hiivmind-corpus-polars-navigate** skill when you need to look up
Polars documentation.

## When to Use
- Working with Polars DataFrames, expressions, or lazy evaluation
- Questions about data transformation, aggregation, or I/O
...
```

This makes Claude proactively use the corpus when answering questions in that project.

## Design Principles

**Human-readable indexes**: Simple markdown with heading hierarchy, not complex YAML schemas.

**Collaborative building**: The index is built interactively based on user needs, not auto-generated.

**Works without local clone**: Navigate skill can fetch from raw GitHub URLs when `.source/` doesn't exist.

**Per-project discoverability**: Each corpus skill has its own navigate skill with a specific description (e.g., "Find ClickHouse documentation for data modeling, ETL, query optimization").

**Project awareness**: Corpora include snippets for injecting into project CLAUDE.md files, making Claude proactively use documentation.

**Upgradeable**: As the meta-plugin evolves, existing corpora can be upgraded to latest standards via `hiivmind-corpus-upgrade`.

**Scalable**: Large corpora (500+ files) use tiered indexes; large structured files use grep-based navigation.

## Example: Multi-Source Corpus

```
hiivmind-corpus-fullstack/
├── .claude-plugin/plugin.json
├── skills/navigate/SKILL.md       # "Find fullstack documentation..."
├── data/
│   ├── config.yaml                # Multi-source config
│   ├── index.md                   # Unified index with source prefixes
│   ├── project-awareness.md       # Snippet for project CLAUDE.md
│   └── uploads/                   # Local documents
│       └── team-standards/
│           ├── coding-guidelines.md
│           └── testing.md
├── .source/                       # Git clones (gitignored)
│   ├── react/
│   └── tanstack-query/
└── .cache/                        # Web cache (gitignored)
    └── web/
        └── kent-testing-blog/
```

**Index format with source prefixes:**

```markdown
## React Fundamentals
- **Hooks Overview** `react:reference/hooks.md` - Introduction to hooks
- **useEffect** `react:reference/useEffect.md` - Side effects

## Data Fetching
- **Query Basics** `tanstack-query:docs/queries.md` - Core concepts

## Testing Best Practices
- **Implementation Details** `web:kent-testing-blog/testing-impl.md` - What not to test
- **Our Testing Standards** `local:team-standards/testing.md` - Team conventions
```

## Example: Single-Source Corpus

```
hiivmind-corpus-clickhouse/
├── .claude-plugin/plugin.json
├── skills/navigate/SKILL.md     # "Find ClickHouse documentation..."
├── data/
│   ├── config.yaml              # Single source (still uses sources array)
│   ├── index.md                 # ~150 key docs organized by topic
│   └── project-awareness.md     # Snippet for project CLAUDE.md
└── .source/
    └── clickhouse/              # Local clone (gitignored)
```

The index covers:
- Data Modeling (schema design, denormalization, projections)
- Table Engines (MergeTree family, integrations)
- SQL Reference (SELECT, INSERT, data types)
- Operations (deployment, monitoring, backups)
- Integrations (Kafka, S3, dbt)

## Adding Documentation Sources

### New corpus with single git source

1. Run `hiivmind-corpus-init` with the repo URL
2. Run `hiivmind-corpus-build` to create the index
3. Commit `data/index.md` and `data/config.yaml`

### Add sources to existing corpus

1. Run `hiivmind-corpus-add-source` from the corpus directory
2. Choose source type (git, local, or web)
3. Provide source details (URL, files, etc.)
4. Optionally add entries to the index immediately

### Start empty, add sources later

1. Run `hiivmind-corpus-init` and choose "Start empty"
2. Run `hiivmind-corpus-add-source` for each source
3. Run `hiivmind-corpus-build` to create the unified index

The navigate skill works immediately. Run `hiivmind-corpus-refresh` periodically to check each source for updates.

## Repository Organization

This repository contains the **meta-plugin** (skills for generating and maintaining corpus skills). Generated corpus skills should live in their own repositories following the `hiivmind-corpus-{project}` naming convention.

### Why separate repos?

**Indexes are personal.** The collaborative index you build reflects *your* priorities and use cases. Someone focused on ClickHouse analytics has different needs than someone building ETL pipelines. A centralized collection of "everyone's indexes" has limited value.

**Independent lifecycles.** Your corpus skill updates when *you* need it updated, not when someone else changes theirs.

**Lightweight installation.** Users install only the corpus skills they actually use.

### Recommended approach

| Repository | Contents |
|------------|----------|
| `hiivmind/hiivmind-corpus` | Meta-plugin skills + templates |
| `hiivmind/hiivmind-corpus-prisma` | Prisma documentation corpus |
| `hiivmind/hiivmind-corpus-react` | React documentation corpus |

## Future Enhancements

See [docs/future-enhancements.md](docs/future-enhancements.md) for planned improvements including:
- Staleness warnings during navigation
- Version awareness for library documentation
- Cross-corpus linking
- Automatic web content refresh scheduling

## License

MIT
