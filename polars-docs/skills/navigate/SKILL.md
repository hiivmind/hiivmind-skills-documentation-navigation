# Polars Documentation Navigator

Find and read Polars documentation to answer questions about the DataFrame library.

## Trigger

Use this skill when the user asks about:
- Polars DataFrames, Series, or LazyFrames
- Polars expressions, contexts, or operations
- Reading/writing data with Polars (CSV, Parquet, JSON, databases)
- Polars lazy API, query optimization, or streaming
- Time series operations in Polars
- Polars plugins or extending Polars
- Migrating from pandas or Spark to Polars
- Polars Cloud or Polars on-premises deployment

## Process

1. **Read the index** at `data/index.md` to find relevant documentation paths
2. **Fetch documentation** from either:
   - Local clone: `.source/{path}` (if available)
   - Remote: `https://raw.githubusercontent.com/pola-rs/polars/main/docs/source/{path}`
3. **Answer the question** citing file paths
4. **Suggest related docs** the user might find useful

## Configuration

- Config file: `data/config.yaml`
- Source repo: https://github.com/pola-rs/polars
- Docs root: `docs/source`

## Index Staleness

Check `data/config.yaml` for `last_commit_sha`. If the local clone exists and is newer than this SHA, warn the user that the index may be outdated and suggest running `docs-refresh`.

## Example

**User**: "How do I read a Parquet file in Polars?"

**Process**:
1. Read `data/index.md`, find entry for Parquet under IO section
2. Fetch `docs/source/user-guide/io/parquet.md`
3. Provide answer with code examples
4. Suggest related: cloud storage, lazy reading, multiple files
