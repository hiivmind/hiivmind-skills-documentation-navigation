---
name: hiivmind-corpus-add-source
description: Add a new source to an existing corpus skill. Use to extend a corpus with additional git repos, local documents, or web pages.
---

# Add Source to Corpus

Add a new documentation source to an existing corpus skill.

## Process

```
1. LOCATE  →  2. MIGRATE?  →  3. TYPE  →  4. COLLECT  →  5. SETUP  →  6. INDEX?
```

## Prerequisites

Run from within a corpus skill directory containing `data/config.yaml`.

---

## Step 1: Locate Corpus

Find and read `data/config.yaml`:

```bash
cat data/config.yaml
```

Verify:
- File exists
- Check `schema_version` (should be 2 for multi-source)
- List existing sources to user

---

## Step 2: Migration Check

If `schema_version` is missing or 1 (old single-source format):

1. Notify user: "This corpus uses the old single-source format. Migrating to multi-source format..."

2. Read the old config structure:
   ```yaml
   source:
     repo_url: "..."
     branch: "main"
     docs_root: "docs/"
   index:
     last_commit_sha: "abc123"
     last_indexed_at: "2025-01-01T00:00:00Z"
   ```

3. Transform to new structure:
   - Derive source_id from repo name (e.g., `polars`)
   - Move `.source/` to `.source/{source_id}/`
   - Convert to `sources:` array format

4. Update `data/index.md`:
   - Transform all paths from `path/to/file.md` to `{source_id}:path/to/file.md`

5. Write updated config.yaml and index.md

6. Show summary of migration changes

---

## Step 3: Source Type

Ask the user which type of source to add:

| Type | Description | Example Use Case |
|------|-------------|------------------|
| **git** | Git repository | Library docs, framework APIs |
| **local** | User-uploaded files | Team standards, internal docs |
| **web** | Blog posts, articles | Individual web pages to cache |

---

## Step 4: Collect Source Information

### For Git Sources

| Input | Source | Example |
|-------|--------|---------|
| Repo URL | Ask user | `https://github.com/TanStack/query` |
| Source ID | Derive from repo name | `tanstack-query` |
| Branch | Ask or default `main` | `main` |
| Docs root | Investigate or ask | `docs/` |

**Generate unique source ID:**
- Derive from repo name (lowercase, hyphenated)
- Check for conflicts with existing sources
- Ask user if ambiguous

### For Local Sources

| Input | Source | Example |
|-------|--------|---------|
| Source ID | Ask user | `team-standards` |
| Description | Ask user | `Internal team documentation` |

### For Web Sources

| Input | Source | Example |
|-------|--------|---------|
| Source ID | Ask user | `kent-testing-blog` |
| Description | Ask user | `Testing best practices articles` |
| URLs | Ask for list | One or more URLs to fetch |

---

## Step 5: Setup Source

### Git Source Setup

```bash
# Clone to source-specific directory
git clone --depth 1 {repo_url} .source/{source_id}

# Get current commit SHA
cd .source/{source_id} && git rev-parse HEAD
```

Add to config.yaml `sources:` array:
```yaml
- id: "{source_id}"
  type: "git"
  repo_url: "{repo_url}"
  repo_owner: "{owner}"
  repo_name: "{name}"
  branch: "{branch}"
  docs_root: "{docs_root}"
  last_commit_sha: "{sha}"
  last_indexed_at: null
```

### Local Source Setup

```bash
# Create uploads directory
mkdir -p data/uploads/{source_id}
```

Instruct user:
> Place your documents in `data/uploads/{source_id}/`
> Supported formats: .md, .mdx
> Let me know when files are in place.

After user confirms, scan directory:
```bash
find data/uploads/{source_id} -name "*.md" -o -name "*.mdx"
```

Add to config.yaml:
```yaml
- id: "{source_id}"
  type: "local"
  path: "uploads/{source_id}/"
  description: "{description}"
  files: []
  last_indexed_at: null
```

### Web Source Setup

```bash
# Create cache directory
mkdir -p .cache/web/{source_id}
```

For each URL provided:

1. **Fetch content** using WebFetch tool
2. **Show user the fetched content** for approval
3. **If approved**, save as markdown to `.cache/web/{source_id}/{slug}.md`
4. **Generate filename** from URL path (e.g., `testing-implementation-details.md`)
5. **Calculate content hash** (SHA-256 of content)

**Important:** Never auto-save web content. User must approve each fetched article before caching.

Add to config.yaml:
```yaml
- id: "{source_id}"
  type: "web"
  description: "{description}"
  urls:
    - url: "{url}"
      title: "{title}"
      cached_file: "{filename}.md"
      fetched_at: "{timestamp}"
      content_hash: "sha256:{hash}"
  cache_dir: ".cache/web/{source_id}/"
  last_indexed_at: null
```

---

## Step 6: Index Prompt

Ask user:
> Would you like to add entries from this source to the index now?

### If yes:

1. Scan the new source for available documents
2. Show document list to user
3. Ask which documents to include
4. Collaboratively add entries to `data/index.md`
5. Use `{source_id}:{path}` format for all entries
6. Update `last_indexed_at` for the source in config

Example entries:
```markdown
## New Section (from {source_id})

- **Document Title** `{source_id}:path/to/file.md` - Brief description
```

### If no:

- Note that source is configured but not yet indexed
- User can run `hiivmind-corpus-build` or `hiivmind-corpus-enhance` later

---

## Example Sessions

### Adding a Git Repository

**User**: "Add TanStack Query docs to this corpus"

**Step 1**: Read config, confirm multi-source format
**Step 2**: No migration needed (already schema_version 2)
**Step 3**: Source type: **git**
**Step 4**: Collect:
- Repo: `https://github.com/TanStack/query`
- Source ID: `tanstack-query`
- Branch: `main`
- Docs root: `docs/`
**Step 5**: Clone to `.source/tanstack-query/`, add to config
**Step 6**: Ask about indexing

---

### Adding Local Documents

**User**: "I want to add our team's API documentation"

**Step 1**: Read config
**Step 2**: No migration needed
**Step 3**: Source type: **local**
**Step 4**: Collect:
- Source ID: `team-api-docs`
- Description: `Internal API documentation`
**Step 5**: Create `data/uploads/team-api-docs/`, wait for files
**Step 6**: Offer to index

---

### Adding Web Articles

**User**: "Add these testing blog posts to my corpus"

**Step 1**: Read config
**Step 2**: No migration needed
**Step 3**: Source type: **web**
**Step 4**: Collect:
- Source ID: `kent-testing-blog`
- Description: `Testing best practices from Kent C. Dodds`
- URLs:
  - `https://kentcdodds.com/blog/testing-implementation-details`
  - `https://kentcdodds.com/blog/common-mistakes-with-react-testing-library`
**Step 5**:
- Fetch first URL, show content to user
- User approves → save to `.cache/web/kent-testing-blog/testing-implementation-details.md`
- Repeat for each URL
- Add to config
**Step 6**: Offer to index

---

### Migrating Old Single-Source Corpus

**User**: "Add Next.js docs to my Polars corpus"

**Step 1**: Read config, find old format (no schema_version)
**Step 2**: Migration needed:
```
Migrating to multi-source format...
- Created source ID: polars
- Moved .source/ → .source/polars/
- Updated 47 index entries with 'polars:' prefix
- Updated config.yaml to schema_version 2
Migration complete!
```
**Step 3-6**: Continue with adding Next.js as new git source

---

## Reference

- Initialize corpus: `skills/hiivmind-corpus-init/SKILL.md`
- Build full index: `skills/hiivmind-corpus-build/SKILL.md`
- Enhance topics: `skills/hiivmind-corpus-enhance/SKILL.md`
- Refresh sources: `skills/hiivmind-corpus-refresh/SKILL.md`
