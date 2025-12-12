---
name: hiivmind-corpus-enhance
description: Enhance an existing corpus index by adding depth to specific topics. Use when you need more detail on particular areas.
---

# Corpus Index Enhancement

Expand and deepen specific sections of an existing corpus index. Can search across all sources or focus on specific ones.

## Prerequisites

Run from within a corpus skill directory (e.g., `hiivmind-corpus-polars/`).

Requires an initialized index at `data/index.md` (run `hiivmind-corpus-build` first).

**Note:** This skill enhances index *depth*, not *freshness*. Use `hiivmind-corpus-refresh` to sync with upstream changes.

## When to Use

- Initial index was broad but shallow on a topic you now need
- You've started using a feature that needs better coverage
- A section has grown stale in usefulness (not commits)
- You want to add subsections or reorganize a topic

## Process

```
1. READ INDEX  →  2. ASK USER  →  3. EXPLORE  →  4. ENHANCE  →  5. SAVE
```

---

## Step 1: Read Index

Load the current index to understand existing coverage:

```bash
cat data/index.md
```

Identify:
- Current sections and their depth
- Topics with minimal entries
- Areas that could benefit from subsections

---

## Step 2: Ask User

Present the current structure and ask:

1. **Which topic to enhance?**
   - "Which section would you like to expand?"
   - "Is there a specific feature or concept you need more detail on?"

2. **What's the goal?**
   - "What are you trying to accomplish with this topic?"
   - "Any specific questions you want the index to help answer?"

3. **Desired depth?**
   - "Should I find all related docs, or focus on the essentials?"
   - "Do you want subsections, or just more entries?"

---

## Step 3: Explore

Search for relevant documentation not yet in the index.

### Identify Target Sources

Based on user's topic, determine which source(s) to explore:
- Specific source if user mentioned it
- All sources if topic is cross-cutting
- Read `data/config.yaml` to see available sources

### Search by Source Type

**Git sources** (`.source/{source_id}/`):
```bash
# Find docs in the target area
find .source/{source_id}/{docs_root}/{topic_path} -name "*.md" -o -name "*.mdx"

# Search for related content
grep -r "{keyword}" .source/{source_id}/{docs_root} --include="*.md" -l

# Read promising files
head -50 .source/{source_id}/{docs_root}/path/to/file.md
```

If no local clone, use raw GitHub URLs:
```
https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{docs_root}/{path}
```

**Local sources** (`data/uploads/{source_id}/`):
```bash
# Find docs
find data/uploads/{source_id} -name "*.md" -o -name "*.mdx"

# Search content
grep -r "{keyword}" data/uploads/{source_id} --include="*.md" -l
```

**Web sources** (`.cache/web/{source_id}/`):
```bash
# Search cached content
grep -r "{keyword}" .cache/web/{source_id} --include="*.md" -l

# Read cached files
cat .cache/web/{source_id}/{filename}.md
```

### Cross-Source Discovery

If the topic spans multiple sources, search all and group findings by source:

```
Found related content in 2 sources:

react (git):
- src/content/reference/useCallback.md
- src/content/learn/you-might-not-need-an-effect.md

kent-testing-blog (web):
- testing-implementation-details.md (discusses React testing patterns)
```

### What to Look For

- Files not currently in the index
- Sections within files that deserve separate entries
- Related docs that could be grouped together
- Anchor points (#headings) for specific topics within large files
- Cross-source connections (e.g., blog post explaining library feature)
- **Large structured files** that need special handling (see below)

### Detecting Large Structured Files

When enhancing, check if any discovered files are too large to read:

```bash
wc -l {file_path}
```

**If file > 1000 lines**, mark it with `⚡ GREP` in the index:

```markdown
- **OpenAPI Spec** `api-docs:openapi.yaml` ⚡ GREP - Full API spec (5k lines). Search with: `grep -n "/users" ... -A 20`
```

Common patterns for large file types:

| File Type | Search Pattern |
|-----------|----------------|
| GraphQL | `grep -n "^type {Name}" file -A 30` |
| OpenAPI | `grep -n "/{path}" file -A 20` |
| JSON Schema | `grep -n '"{property}"' file -A 10` |

---

## Step 4: Enhance

Update `data/index.md` collaboratively:

### Enhancement Patterns

All paths use the format: `{source_id}:{relative_path}`

**Adding entries to existing section:**
```markdown
## Existing Section
*Current description*

- **Existing Doc** `react:reference/hooks.md` - Description
- **New Doc** `react:reference/useCallback.md` - Added description
- **Blog Post** `web:kent-blog/you-might-not-need-effect.md` - External perspective
```

**Adding subsections:**
```markdown
## React Hooks
*Hook patterns and usage*

### Core Hooks
- **useState** `react:reference/useState.md` - State management
- **useEffect** `react:reference/useEffect.md` - Side effects

### Performance Hooks
- **useMemo** `react:reference/useMemo.md` - Memoized values
- **useCallback** `react:reference/useCallback.md` - Memoized callbacks
```

**Adding anchor links for specificity:**
```markdown
- **Settings - Performance** `polars:reference/settings.md#performance` - Runtime tuning
- **Settings - Memory** `polars:reference/settings.md#memory` - Memory configuration
```

**Cross-source topic grouping:**
```markdown
## Testing Best Practices
*Combined from official docs and blog posts*

- **Testing Overview** `react:learn/testing.md` - Official testing guide
- **Implementation Details** `web:kent-blog/testing-implementation-details.md` - What not to test
- **Our Testing Standards** `local:team-standards/testing.md` - Team conventions
```

### Iteration

- Show proposed changes to user
- "Does this capture what you need?"
- "Should I go deeper on any of these?"
- "Any docs here that aren't actually useful?"
- "Should I group these by source or by subtopic?"

---

## Step 5: Save

Update `data/index.md` with enhancements.

**Do NOT update** `last_commit_sha` in config - that's for `docs-refresh`.

Remind user to commit:
```bash
git add data/index.md
git commit -m "Enhance {topic} section in docs index"
```

---

## Example Sessions

### Single-Source Enhancement

**User**: "Enhance the Query Optimization section"

**Step 1**: Read index, find Query Optimization has 3 entries (all from `polars` source)

**Step 2**:
- User: "I'm working on slow queries and need more detail"
- User: "Focus on practical optimization, skip theory"

**Step 3**: Search `.source/polars/docs/` for optimization, performance, explain
- Found 8 additional relevant files
- Found useful anchors in settings.md

**Step 4**: Propose expanded section:
```markdown
## Query Optimization
*Improving query performance*

### Understanding Query Execution
- **EXPLAIN** `polars:sql-reference/explain.md` - Analyze query plans
- **Query Profiling** `polars:operations/profiling.md` - Identify bottlenecks

### Optimization Techniques
- **Indexing Strategies** `polars:guides/indexing.md` - When and how to index
- **Query Settings** `polars:sql-reference/settings.md#performance` - Runtime tuning

### Common Patterns
- **Filtering Best Practices** `polars:best-practices/filtering.md`
```

User: "Perfect"

**Step 5**: Save, remind to commit

---

### Cross-Source Enhancement

**User**: "Enhance the Testing section with more depth"

**Step 1**: Read index, find Testing section has entries from `react` source only

**Step 2**:
- User: "I want to include the Kent C. Dodds blog posts too"
- User: "Focus on practical patterns"

**Step 3**: Search across sources:
- `react` (git): Found 3 testing docs in `.source/react/src/content/learn/`
- `kent-testing-blog` (web): Found 3 cached articles in `.cache/web/kent-testing-blog/`
- `team-standards` (local): Found testing.md in `data/uploads/team-standards/`

**Step 4**: Propose cross-source section:
```markdown
## Testing Best Practices
*Comprehensive testing guidance from multiple sources*

### Official React Testing
- **Testing Overview** `react:learn/testing.md` - Official guide
- **React Testing Library** `react:learn/testing-library.md` - Recommended tools

### Expert Insights
- **Implementation Details** `web:kent-testing-blog/testing-implementation-details.md` - What not to test
- **Common Mistakes** `web:kent-testing-blog/common-rtl-mistakes.md` - Pitfalls to avoid

### Team Standards
- **Our Testing Guidelines** `local:team-standards/testing.md` - Team conventions
```

User: "Great, but can you add a subsection for mocking?"

**Step 5**: Save, remind to commit

---

## Reference

- Add sources: `skills/hiivmind-corpus-add-source/SKILL.md`
- Initialize corpus: `skills/hiivmind-corpus-init/SKILL.md`
- Build index: `skills/hiivmind-corpus-build/SKILL.md`
- Refresh from upstream: `skills/hiivmind-corpus-refresh/SKILL.md`
