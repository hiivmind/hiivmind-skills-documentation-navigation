# What If Claude Projects Had No Token Limit?

Claude Projects is genuinely useful. Upload your docs, they're always in context, Claude knows your stuff. But after hitting its limits repeatedly, I started wondering: what would a better version look like?

## The Limits of Claude Projects

| Limitation | Impact |
|------------|--------|
| **~200K token limit** | Maybe 50-100 docs before you're choosing what to cut |
| **Flat file list** | No organization, Claude has to search everything |
| **Manual updates** | Docs change upstream, your project gets stale |
| **Claude.ai only** | Doesn't work in Claude Code CLI or Agent SDK |
| **Per-user** | Team members each maintain their own copies |

These aren't complaints - they're reasonable trade-offs for a general-purpose feature. But for serious documentation work, I wanted more.

## The Realization

Claude Code already has the primitives:
- **Read files** from disk
- **Fetch URLs** from the web
- **Skills** that activate based on context
- **Git** for storage and collaboration

What if instead of uploading documents *into* context, you uploaded a **curated index** that *points to* documents?

```
Claude Projects:     [Doc1][Doc2][Doc3]...[Doc50] → Context full

hiivmind-corpus:     [Index] → Points to → [Unlimited docs]
                        ↓
                     Fetch what's needed
```

The index is small (fits easily in context). The documents are fetched on demand (unlimited capacity).

## What This Enables

| Aspect | Claude Projects | hiivmind-corpus |
|--------|-----------------|-----------------|
| **Capacity** | ~200K tokens | Unlimited (fetch on demand) |
| **Organization** | Flat file list | Curated hierarchy with descriptions |
| **Curation** | Upload everything, hope for the best | You decide what matters |
| **Freshness** | Manual re-upload | Tracks upstream commits, shows diffs |
| **Portability** | Claude.ai only | CLI, API, Agent SDK - anywhere |
| **Collaboration** | Per-user | Git repo, team shares automatically |
| **Multi-source** | Upload files only | Git repos + local files + web pages |

## How It Actually Works

### 1. The Index

A markdown file with paths and descriptions:

```markdown
## React Hooks
- **useEffect** `react:reference/useEffect.md` - Side effects and cleanup
- **useCallback** `react:reference/useCallback.md` - Memoized callbacks

## Data Fetching
- **Queries** `tanstack-query:docs/queries.md` - Basic query patterns

## Team Standards
- **Testing** `local:team-standards/testing.md` - Our conventions
```

~150 lines covers a lot of ground. Claude reads this, understands the structure, fetches what's relevant to your question.

### 2. The Sources

Three types, unified in one index:

| Type | Storage | Example |
|------|---------|---------|
| **git** | `.source/{id}/` | Library documentation repos |
| **local** | `data/uploads/{id}/` | Your own markdown files |
| **web** | `.cache/web/{id}/` | Blog posts, articles |

### 3. The Tracking

Each source tracks its state:
- **Git sources**: Commit SHA - knows exactly what's changed upstream
- **Local sources**: File modification times
- **Web sources**: Fetch timestamp + content hash

Run refresh, see the diff, update what matters.

### 4. The Activation

It's a Claude Code skill. The description triggers activation:

```yaml
description: Find React and TanStack Query documentation.
             Use when working with React hooks, components, or data fetching.
```

Working on React? Ask about hooks? The skill activates automatically. No manual context management.

## The Meta-Skill Pattern

Here's where it gets interesting: hiivmind-corpus is a **skill that creates skills**.

You don't manually write corpus skills. You run:
1. `hiivmind-corpus-init` → Creates the structure
2. `hiivmind-corpus-add-source` → Adds git/local/web sources
3. `hiivmind-corpus-build` → Collaboratively builds the index

The "collaboratively" part matters. Claude analyzes your sources, asks what you care about, builds an index reflecting *your* priorities. Not auto-generated noise - curated signal.

## Multi-Source: The Killer Feature

Real projects don't use one library. My current project needs:
- React docs (git)
- TanStack Query docs (git)
- Team coding standards (local files)
- Testing articles from Kent C. Dodds (web)

Four sources. One unified index. All tracked for freshness.

```
hiivmind-corpus-fullstack/
├── data/
│   ├── index.md              # Unified index
│   └── uploads/team-standards/
├── .source/
│   ├── react/
│   └── tanstack-query/
└── .cache/web/kent-testing-blog/
```

Ask a question about testing - Claude searches the index, finds relevant entries from React docs AND the blog posts AND your team standards, fetches what it needs.

## No Infrastructure Required

The entire system is:
- Markdown files (index + skills)
- YAML config (source tracking)
- Git operations (clone, fetch, diff)
- File reading (local) or web fetching (remote)

No vector database. No embedding models. No MCP servers. No subscriptions.

It works because **human curation is the retrieval system**. A well-organized index with good descriptions beats semantic search over unorganized content.

## Try It

```bash
# Install the meta-skill
/plugin install hiivmind/hiivmind-corpus

# Create a corpus
"Create a corpus skill for React documentation"

# Add more sources
"Add TanStack Query docs to my corpus"
"Add our team standards as local files"

# Build the index (collaborative)
"Build my corpus index"

# Use it
"How do I handle stale data in TanStack Query?"
```

The skill activates based on context. The index points to the right docs. Claude fetches and answers with citations.

## What You Get

- **Unlimited documentation capacity** without token limits
- **Curated, organized knowledge** reflecting what you actually use
- **Multi-source aggregation** (official docs + your notes + web content)
- **Freshness tracking** that knows when sources have updated
- **Team sharing** via git (clone the repo, get the knowledge)
- **Works everywhere** Claude Code runs (CLI, SDK, any interface)

All from markdown files and git. No infrastructure, no complexity, no limits.

---

**GitHub:** [hiivmind/hiivmind-corpus](https://github.com/hiivmind/hiivmind-corpus)
