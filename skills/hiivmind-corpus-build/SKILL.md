---
name: hiivmind-corpus-build
description: Analyze documentation and build the initial corpus index collaboratively. Use after running hiivmind-corpus-init.
---

# Corpus Index Builder

Prepare all sources and build the index collaboratively with the user.

## Prerequisites

Run from within a corpus skill directory (e.g., `hiivmind-corpus-polars/`).

Requires `data/config.yaml` with source configuration (schema_version 2):
```yaml
schema_version: 2
sources:
  - id: "polars"
    type: "git"
    repo_url: "https://github.com/..."
```

## Process

```
1. PREPARE  →  2. SCAN  →  3. ASK  →  4. BUILD  →  5. SAVE
```

---

## Step 1: Prepare Sources

Read config and ensure all sources are available:

```bash
cat data/config.yaml
```

### Migration Check

If `schema_version` is missing (old format), run migration first:
- See `hiivmind-corpus-add-source` for migration process
- Or notify user to run `hiivmind-corpus-add-source` which handles migration

### Prepare Each Source Type

For each source in `sources:` array:

**Git sources:**
```bash
# Check if clone exists
ls .source/{source_id}

# If not, clone
git clone --depth 1 {repo_url} .source/{source_id}

# Get current SHA
cd .source/{source_id} && git rev-parse HEAD
```

**Local sources:**
```bash
# Verify uploads directory exists and has files
ls data/uploads/{source_id}
find data/uploads/{source_id} -name "*.md" -o -name "*.mdx"
```

If directory is empty, notify user to place files there.

**Web sources:**
```bash
# Check cache exists
ls .cache/web/{source_id}
```

If cache is missing, notify user to run `hiivmind-corpus-add-source` to fetch content.

---

## Step 2: Scan All Sources

Analyze each source and present a combined summary to user.

### Scan by Source Type

**Git sources:**
```bash
# Count files
find .source/{source_id}/{docs_root} -name "*.md" -o -name "*.mdx" | wc -l

# List top-level directories
ls -la .source/{source_id}/{docs_root}

# Sample some files
head -30 .source/{source_id}/{docs_root}/index.md
```

**Local sources:**
```bash
# Count files
find data/uploads/{source_id} -name "*.md" -o -name "*.mdx" | wc -l

# List files
ls -la data/uploads/{source_id}
```

**Web sources:**
```bash
# Count cached files
ls .cache/web/{source_id}/*.md | wc -l

# List cached files
ls -la .cache/web/{source_id}
```

### Present Combined Summary

Show user a summary of all sources:

```
Found 3 sources:

1. react (git): 150 doc files
   Location: .source/react/src/content/
   Sections: learn, reference, community

2. team-standards (local): 5 files
   Location: data/uploads/team-standards/
   Files: coding-guidelines.md, pr-process.md, ...

3. kent-testing-blog (web): 3 cached articles
   Location: .cache/web/kent-testing-blog/
   Articles: testing-implementation-details.md, ...
```

---

## Step 3: Ask

Present findings and ask the user:

1. **Show what you found:**
   - Summary of all sources (from Step 2)
   - Total file count across sources
   - Key sections per source

2. **Ask about their use case:**
   - "What will you primarily use this corpus for?"
   - "Which sources are most important for your work?"
   - "Within each source, which sections matter most?"
   - "Any sources or sections you want to skip entirely?"

3. **Ask about organization:**
   - "How should I organize the index? By source? By topic across sources?"
   - "Should I include all docs or focus on key topics?"

---

## Step 4: Build

Generate `data/index.md` based on user input:

### Index Format (Multi-Source)

All file paths use the format: `{source_id}:{relative_path}`

```markdown
# {Corpus Name} Documentation Index

> Sources: react, team-standards, kent-testing-blog
> Last updated: {date}

---

## React Fundamentals
*Core React concepts from official docs*

- **Hooks Overview** `react:reference/hooks.md` - Introduction to React hooks
- **useEffect** `react:reference/useEffect.md` - Side effects in components

## Team Standards
*Internal team documentation*

- **Coding Guidelines** `local:team-standards/coding-guidelines.md` - Our coding conventions
- **PR Process** `local:team-standards/pr-process.md` - Code review workflow

## Testing Best Practices
*From Kent C. Dodds blog*

- **Testing Implementation Details** `web:kent-testing-blog/testing-implementation-details.md` - Why to avoid
- **Common RTL Mistakes** `web:kent-testing-blog/common-mistakes-rtl.md` - Pitfalls to avoid
```

### Path Format by Source Type

| Source Type | Path Format | Example |
|-------------|-------------|---------|
| git | `{source_id}:{relative_path}` | `react:reference/hooks.md` |
| local | `local:{source_id}/{filename}` | `local:team-standards/guidelines.md` |
| web | `web:{source_id}/{cached_file}` | `web:kent-blog/article.md` |

### Building Process

1. Organize by user preference (by source, by topic, or mixed)
2. For each section, list key documents with source-prefixed paths
3. Add brief descriptions from content
4. Show draft to user for feedback
5. Iterate until user is satisfied

### Iteration Prompts

- "Which sections should I expand?"
- "Any docs I missed that are important?"
- "Should I reorganize by topic instead of source?"
- "Is the organization clear?"

---

## Step 5: Save

Update `data/config.yaml` with per-source metadata:

For each source that was indexed, update its tracking fields:

**Git sources:**
```yaml
- id: "react"
  type: "git"
  # ... other fields ...
  last_commit_sha: "{current_sha}"
  last_indexed_at: "{ISO-8601 timestamp}"
```

**Local sources:**
```yaml
- id: "team-standards"
  type: "local"
  # ... other fields ...
  files:
    - path: "coding-guidelines.md"
      last_modified: "{file_mtime}"
  last_indexed_at: "{ISO-8601 timestamp}"
```

**Web sources:**
```yaml
- id: "kent-testing-blog"
  type: "web"
  # ... other fields ...
  last_indexed_at: "{ISO-8601 timestamp}"
```

Also update the top-level index metadata:
```yaml
index:
  format: "markdown"
  last_updated_at: "{ISO-8601 timestamp}"
```

Remind user to commit:
```bash
git add data/index.md data/config.yaml
git commit -m "Build {corpus_name} docs index"
```

---

## Example Session

### Single-Source Corpus

**User**: "Build the hiivmind-corpus-prisma index"

**Step 1**: Prepare source `prisma` (git)
- Clone `https://github.com/prisma/docs` to `.source/prisma/`

**Step 2**: Scan
- Found 450 MDX files in `.source/prisma/content/`
- Sections: getting-started, concepts, guides, reference

**Step 3**: Ask
- User: "I mainly work with Prisma Client and migrations"
- User: "Skip the 'about' and 'support' sections"

**Step 4**: Build
- Generate index with `prisma:` prefix on all paths
- User: "Can you add more detail on the Query section?"
- Expand Query subsection
- User: "Perfect"

**Step 5**: Update config with SHA, remind to commit

---

### Multi-Source Corpus

**User**: "Build my fullstack corpus index"

**Step 1**: Prepare all sources
- react (git): Clone to `.source/react/`
- team-standards (local): Verify `data/uploads/team-standards/` has files
- kent-blog (web): Verify `.cache/web/kent-blog/` has cached articles

**Step 2**: Scan
```
Found 3 sources:
1. react (git): 150 files
2. team-standards (local): 5 files
3. kent-blog (web): 3 articles
```

**Step 3**: Ask
- User: "Organize by topic, not by source"
- User: "Focus on hooks, testing, and team standards"

**Step 4**: Build
```markdown
## React Hooks
- **useEffect** `react:reference/useEffect.md` - Side effects
- **Custom Hooks** `react:learn/custom-hooks.md` - Creating reusable hooks

## Testing
- **Testing Implementation Details** `web:kent-blog/testing-impl.md` - Best practices
- **Our Test Guidelines** `local:team-standards/testing.md` - Team conventions

## Team Standards
- **PR Process** `local:team-standards/pr-process.md` - Review workflow
```

**Step 5**: Update per-source metadata, remind to commit

---

## Reference

- Add sources: `skills/hiivmind-corpus-add-source/SKILL.md`
- Initialize corpus: `skills/hiivmind-corpus-init/SKILL.md`
- Enhance topics: `skills/hiivmind-corpus-enhance/SKILL.md`
- Refresh from upstream: `skills/hiivmind-corpus-refresh/SKILL.md`
