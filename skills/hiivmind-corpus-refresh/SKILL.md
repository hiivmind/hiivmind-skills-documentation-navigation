---
name: hiivmind-corpus-refresh
description: Refresh corpus index by comparing with upstream changes. Checks each source independently and updates based on diffs.
---

# Corpus Index Refresh

Compare index against upstream changes and refresh based on diffs. Handles each source type independently.

## Prerequisites

Run from within a corpus skill directory (e.g., `hiivmind-corpus-polars/`).

Requires initialized plugin with `data/config.yaml` (schema_version 2):
```yaml
schema_version: 2
sources:
  - id: "react"
    type: "git"
    last_commit_sha: "abc123"
    last_indexed_at: "2025-01-01T00:00:00Z"
```

**Note:** For first-time setup, use `hiivmind-corpus-build` instead.

## Commands

- **status**: Check if sources are current
- **update**: Refresh selected sources

---

## Status

Check currency of all sources.

### Step 1: Read config

```bash
cat data/config.yaml
```

### Step 2: Check each source

**For git sources:**
```bash
# If .source/{source_id}/ exists
cd .source/{source_id} && git fetch origin
git rev-parse origin/{branch}
# Compare to last_commit_sha in config

# If no local clone
git ls-remote {repo_url} refs/heads/{branch}
```

**For local sources:**
```bash
# Find files modified after last_indexed_at
find data/uploads/{source_id} -type f -name "*.md" -newer {timestamp_reference}
```

**For web sources:**
- Report cache age (days since `fetched_at`)
- Note: Re-fetching requires user approval

### Step 3: Report status

Present per-source status:

```
Source Status:

1. react (git)
   - Indexed: abc123 (2025-12-01)
   - Upstream: def456
   - Changes: 47 commits, 12 files changed
   - Status: UPDATES AVAILABLE

2. team-standards (local)
   - Last indexed: 2025-12-05
   - Modified files: 2 (coding-guidelines.md, pr-process.md)
   - Status: UPDATES AVAILABLE

3. kent-testing-blog (web)
   - Cache age: 7 days
   - Status: Consider refreshing (URLs may have changed)

4. tanstack-query (git)
   - Indexed: xyz789 (2025-12-07)
   - Upstream: xyz789
   - Status: UP TO DATE
```

---

## Update

Refresh selected sources and update index.

### Step 1: Select sources

Ask user:
> Which sources would you like to update?
> - All sources with updates
> - Specific sources: [list source IDs]
> - All sources (including up-to-date)

### Step 2: Update by source type

#### Git Sources

```bash
# Ensure clone exists
ls .source/{source_id} || git clone --depth 1 {repo_url} .source/{source_id}

# Fetch and show changes
cd .source/{source_id}
git fetch origin

# Show commit log since last index
git log --oneline {last_commit_sha}..origin/{branch} -- {docs_root} | head -20

# Show file changes
git diff --name-status {last_commit_sha}..origin/{branch} -- {docs_root}

# Pull changes
git pull origin {branch}

# Get new SHA
git rev-parse HEAD
```

Show user:
- Number of commits since last index
- Files: Added (A), Modified (M), Deleted (D), Renamed (R)

#### Local Sources

```bash
# Find new/modified files since last index
find data/uploads/{source_id} -type f -name "*.md" -newer /tmp/timestamp_marker
```

Compare file list against `files:` array in config to detect:
- New files (not in config)
- Modified files (mtime > config timestamp)
- Deleted files (in config but not on disk)

#### Web Sources

**Important:** Web content requires user approval before updating cache.

For each URL in the source:
1. Show current cache age
2. Offer to re-fetch
3. If user agrees:
   - Fetch URL with WebFetch
   - Show fetched content to user
   - Compare with cached version (show diff if changed)
   - **Only save if user approves**
4. If URL fails to fetch, warn but preserve existing cache

### Step 3: Update index collaboratively

For changes detected in each source:

**Added files:**
- Show file list to user
- Ask: "Which new files should be added to the index?"
- Add selected entries with `{source_id}:{path}` format

**Modified files:**
- Check if content significantly changed
- Ask: "Should I update the description for {file}?"
- Update entries as needed

**Deleted files:**
- Show which indexed files were deleted
- Remove corresponding entries from index

**Renamed files:**
- Update path in index (keep same description)

### Step 4: Update config metadata

For each updated source:

**Git sources:**
```yaml
- id: "react"
  # ... other fields ...
  last_commit_sha: "{new_sha}"
  last_indexed_at: "{timestamp}"
```

**Local sources:**
```yaml
- id: "team-standards"
  # ... other fields ...
  files:
    - path: "coding-guidelines.md"
      last_modified: "{new_mtime}"
    - path: "new-file.md"
      last_modified: "{mtime}"
  last_indexed_at: "{timestamp}"
```

**Web sources:**
```yaml
- id: "kent-testing-blog"
  # ... other fields ...
  urls:
    - url: "..."
      fetched_at: "{new_timestamp}"
      content_hash: "{new_hash}"
  last_indexed_at: "{timestamp}"
```

### Step 5: Commit reminder

```bash
git add data/index.md data/config.yaml
git commit -m "Refresh docs index"
```

---

## File Locations

- **Config**: `data/config.yaml`
- **Index**: `data/index.md`
- **Git sources**: `.source/{source_id}/` (gitignored)
- **Local sources**: `data/uploads/{source_id}/`
- **Web cache**: `.cache/web/{source_id}/` (gitignored)

---

## Example Sessions

### Refreshing a Single Git Source

**User**: "refresh status"

```
Source Status:

1. polars (git)
   - Indexed: abc123 (2025-12-01)
   - Upstream: def456
   - Changes: 15 commits, 8 files changed
   - Status: UPDATES AVAILABLE
```

**User**: "refresh update"

```
Updating polars (git)...

Changes since last index:
A  docs/guides/new-feature.md
M  docs/reference/expressions.md
M  docs/reference/io.md
D  docs/deprecated/old-api.md

Added files:
- docs/guides/new-feature.md

Would you like to add "new-feature.md" to the index?
```

User: "Yes, add it to the Guides section"

```
Updated index:
- Added: **New Feature Guide** `polars:guides/new-feature.md`
- Removed: `polars:deprecated/old-api.md`

Updated config with new SHA: def456
```

---

### Refreshing Web Sources

**User**: "refresh update kent-testing-blog"

```
Checking kent-testing-blog (web)...

1. testing-implementation-details.md
   - Cached: 14 days ago
   - Re-fetch? [y/n]
```

User: "y"

```
Fetching https://kentcdodds.com/blog/testing-implementation-details...

Content has changed since last fetch.
[Shows diff or summary of changes]

Save updated content? [y/n]
```

User: "y"

```
Saved updated content.
Updated cache timestamp and content hash.
```

---

### Refreshing Local Sources

**User**: "refresh status team-standards"

```
team-standards (local):
- Last indexed: 2025-12-05
- Modified files:
  - coding-guidelines.md (modified 2025-12-07)
- New files:
  - deployment-process.md
- Status: UPDATES AVAILABLE
```

**User**: "refresh update"

```
Updating team-standards (local)...

New file found: deployment-process.md
Add to index? [y/n]
```

User: "Yes, create a new Deployment section"

```
Updated index:
- Added section: ## Deployment
- Added: **Deployment Process** `local:team-standards/deployment-process.md`
```

---

## Reference

- Add sources: `skills/hiivmind-corpus-add-source/SKILL.md`
- Initialize corpus: `skills/hiivmind-corpus-init/SKILL.md`
- Build index: `skills/hiivmind-corpus-build/SKILL.md`
- Enhance topics: `skills/hiivmind-corpus-enhance/SKILL.md`
