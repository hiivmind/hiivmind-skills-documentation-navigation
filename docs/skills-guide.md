# Skills Guide

This guide explains what each hiivmind-corpus skill does, when to use it, and what choices you'll face. For most tasks, just type `/hiivmind-corpus` and describe what you need—the gateway command routes to the right skill automatically.

## Core Concepts

### Corpus Types

When you create a corpus, you choose where it lives:

| Type | Location | Best For |
|------|----------|----------|
| **User-level** | `~/.claude/skills/hiivmind-corpus-{name}/` | Personal use across all projects |
| **Repo-local** | `{repo}/.claude-plugin/skills/hiivmind-corpus-{name}/` | Team sharing via git |
| **Single-corpus plugin** | `hiivmind-corpus-{name}/` (standalone repo) | Publishing one corpus to marketplace |
| **Multi-corpus marketplace** | `{marketplace}/hiivmind-corpus-{name}/` | Publishing related corpora together |

User-level and repo-local are for personal/team use. The plugin types are for publishing to the Claude Code marketplace.

### Source Types

A corpus can draw documentation from multiple sources:

| Type | Storage | Example Use |
|------|---------|-------------|
| **git** | `.source/{id}/` | Library docs, framework APIs |
| **local** | `data/uploads/{id}/` | Team standards, internal docs |
| **web** | `.cache/web/{id}/` | Blog posts, articles, tutorials |

Sources are identified by a short ID you choose (e.g., `react`, `team-standards`, `kent-blog`). Index entries reference sources as `{source_id}:{path}`.

### Index Structure

The index is a human-readable markdown file that maps topics to documentation files:

```markdown
## Data Modeling
- **Primary Keys** `polars:docs/guides/creating-tables.md#primary-keys` - How to choose effective keys
- **Partitioning** `polars:docs/guides/partitioning.md` - When and how to partition data

## Query Patterns
- **Lazy Evaluation** `polars:docs/concepts/lazy.md` - Why lazy frames matter
```

**Tiered indexes:** For large documentation sets (500+ files), the index can split into multiple files:
- `index.md` — Main index with section summaries and links to detail files
- `index-reference.md` — API reference details
- `index-guides.md` — Tutorials and guides
- `index-concepts.md` — Conceptual documentation

**Large file markers:** Files too large to read directly are marked with `⚡ GREP`:
```markdown
- **GraphQL Schema** `api:schema.graphql` ⚡ GREP - Search with grep patterns
```

## Workflows

### Creating Your First Corpus

**Goal:** Set up a new documentation corpus for a library you use.

1. **Start:** `/hiivmind-corpus` → *"Create a corpus for Polars"*
2. **Choose destination:** User-level (personal) or repo-local (team)
3. **Provide repo URL:** The GitHub URL for the library's documentation
4. **Review structure:** The init skill clones the repo and shows you the doc structure
5. **Build the index:** `/hiivmind-corpus` → *"Build the polars index"*
6. **Guide the build:** You'll be asked what topics matter to you—this shapes the index
7. **Use it:** Ask questions and the navigate skill fetches relevant docs

**Time:** ~10-15 minutes for a typical library

### Extending a Corpus with More Sources

**Goal:** Add another git repo, local documents, or web articles to an existing corpus.

1. **Start:** `/hiivmind-corpus` → *"Add TanStack Query to my fullstack corpus"*
2. **Choose source type:** git repo, local files, or web URLs
3. **Provide details:** URL, file paths, or web addresses
4. **Choose whether to index now:** You can add source without indexing, or index immediately

**Example:** A "fullstack" corpus combining React docs (git), team coding standards (local), and Kent C. Dodds articles (web).

### Keeping Corpora Fresh

**Goal:** Check if upstream documentation has changed and update your index.

**Check for changes:**
- `/hiivmind-corpus` → *"Is my polars corpus up to date?"*
- Shows commits since last index, highlights which docs changed

**Update the index:**
- `/hiivmind-corpus` → *"Refresh my polars corpus"*
- Reviews changes and updates affected index sections

**Upgrade to latest template:**
- `/hiivmind-corpus` → *"Upgrade my polars corpus"*
- Applies new features from hiivmind-corpus updates (e.g., new navigate skill capabilities)

### Querying Your Corpora

**Goal:** Get answers from your indexed documentation.

- `/hiivmind-corpus` → *"How do lazy frames work in Polars?"*
- The navigate skill searches your indexes, fetches relevant docs, and answers with citations

**Cross-corpus queries:** If you have multiple corpora installed, navigate searches across all of them and identifies which corpus each answer comes from.

### Discovering Installed Corpora

**Goal:** See what corpora you have and their status.

- `/hiivmind-corpus` → *"What corpora do I have?"*
- Lists all corpora by location (user-level, repo-local, marketplace)
- Shows status: built, placeholder (needs building), or stale (needs refresh)

## Skills Reference

### discover

**Purpose:** Find all installed corpora and report their status.

**Prerequisites:** None

**Choices:** None—discovery is automatic

**Output:** Table of installed corpora with name, type, status, source count, and last indexed date.

---

### navigate

**Purpose:** Query across all installed corpora to answer documentation questions.

**Prerequisites:** At least one corpus with a built index

**Choices:**
- If the question is ambiguous, you may be asked to clarify
- If multiple corpora match, you'll see which corpus each result comes from

**Output:** Answer with citations to specific documentation files.

---

### init

**Purpose:** Create the directory structure for a new corpus.

**Prerequisites:** None

**Choices:**
1. **Destination type:** User-level, repo-local, or marketplace plugin
2. **Source repository:** GitHub URL for the documentation
3. **Corpus name:** Short identifier (e.g., `polars`, `react`)

**Output:**
- Directory structure with placeholder files
- Source repository cloned to `.source/`
- Recommendation to run `build` next

---

### add-source

**Purpose:** Add a git repo, local documents, or web pages to an existing corpus.

**Prerequisites:** An existing corpus (created with init)

**Choices:**
1. **Source type:** git, local, or web
2. **Source details:** URL, file paths, or web addresses
3. **Source ID:** Short identifier for this source
4. **Index now?** Whether to immediately index the new source

**Output:**
- Source added to `config.yaml`
- Content cloned/copied/cached
- Optional: index updated with new content

---

### build

**Purpose:** Collaboratively create the index for a corpus.

**Prerequisites:**
- Corpus created with init
- At least one source added

**Choices:**
1. **Topics to prioritize:** What areas of the documentation matter most to you
2. **Depth level:** How detailed should each section be
3. **Tiered vs flat:** For large doc sets, whether to split into multiple index files

**Output:**
- `data/index.md` populated with topic → file mappings
- Optional: tiered index files for large corpora
- Navigate skill ready to use

---

### enhance

**Purpose:** Deepen coverage on specific topics in an existing index.

**Prerequisites:**
- Corpus with a built index
- Specific topic or area to enhance

**Choices:**
1. **Topic to enhance:** Which section needs more depth
2. **New entries:** Review and approve additions

**Output:** Updated index with deeper coverage in the specified area.

---

### refresh

**Purpose:** Check for upstream changes and update the index.

**Prerequisites:** Corpus with git sources

**Choices:**
1. **Status only vs update:** Just check what changed, or also update the index
2. **Which changes to incorporate:** Review diffs and decide what affects the index

**Output:**
- Status mode: Report of changes since last index
- Update mode: Refreshed index reflecting upstream changes

---

### upgrade

**Purpose:** Update an existing corpus to the latest hiivmind-corpus template standards.

**Prerequisites:** An existing corpus (any status)

**Choices:**
1. **Features to apply:** Review which template updates are available
2. **Confirm changes:** Approve modifications to corpus files

**Output:** Corpus updated with latest navigate skill features, config schema, etc.

## Troubleshooting

### "No corpora found"

**Cause:** No corpora installed, or corpora in unexpected locations.

**Fix:**
- Create a new corpus: `/hiivmind-corpus` → *"Create a corpus for {library}"*
- Install from marketplace: `/plugin install hiivmind-corpus-polars@hiivmind`

### "Index is a placeholder"

**Cause:** Corpus was created with init but never built.

**Fix:** `/hiivmind-corpus` → *"Build the {name} index"*

### "Corpus is stale"

**Cause:** Upstream documentation has changed since you last indexed.

**Fix:** `/hiivmind-corpus` → *"Refresh my {name} corpus"*

### "Source not found" when navigating

**Cause:** The `.source/` directory was deleted or never cloned.

**Fix:**
- Re-clone: The navigate skill will offer to re-clone from the URL in config.yaml
- Or manually: `git clone {url} .source/{source_id}`

### Navigate returns outdated information

**Cause:** Index points to old file paths or removed content.

**Fix:**
1. Check freshness: `/hiivmind-corpus` → *"Is my {name} corpus up to date?"*
2. Refresh if needed: `/hiivmind-corpus` → *"Refresh my {name} corpus"*

### "Config.yaml missing or invalid"

**Cause:** Corpus structure is corrupted or incomplete.

**Fix:**
- For user-level/repo-local: Re-run init to regenerate
- For marketplace: Re-install the plugin

### Tiered index files out of sync

**Cause:** Main index links to detail files that don't exist or have different structure.

**Fix:** `/hiivmind-corpus` → *"Rebuild the {name} index"* (rebuild from scratch)

## Related Resources

- [README.md](../README.md) — Quick start and installation
- [future-enhancements.md](./future-enhancements.md) — Planned features
- [CLAUDE.md](../CLAUDE.md) — Technical reference for contributors
