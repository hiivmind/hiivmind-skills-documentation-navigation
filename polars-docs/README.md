# Polars Documentation Plugin

A Claude Code documentation navigation plugin for [Polars](https://pola.rs/) - the lightning-fast DataFrame library for Python and Rust.

## Source

- **Repository**: https://github.com/pola-rs/polars
- **Documentation**: https://docs.pola.rs/
- **Docs path**: `docs/source`
- **Framework**: MkDocs Material

## Usage

Once the index is built, use the navigate skill:

> "Find Polars documentation about lazy evaluation"

## Updating the Index

Run `docs-refresh` to check for upstream changes and update the index.

## Structure

```
polars-docs/
├── .claude-plugin/plugin.json   # Plugin manifest
├── skills/navigate/SKILL.md     # Navigation skill
├── data/
│   ├── config.yaml              # Source configuration
│   └── index.md                 # Documentation index
└── .source/                     # Local clone (gitignored)
```
