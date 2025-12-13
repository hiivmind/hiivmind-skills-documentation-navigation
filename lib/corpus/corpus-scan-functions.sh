#!/usr/bin/env bash
# Corpus Scan Functions
# Layer 2 primitives for scanning and analyzing documentation
#
# Source this file to use: source corpus-scan-functions.sh
#
# This domain handles:
# - Documentation file discovery
# - Framework detection
# - Large file detection
# - Structure analysis
#
# Used by: init, build, enhance, add-source skills

set -euo pipefail

# =============================================================================
# FILE DISCOVERY PRIMITIVES
# =============================================================================
# Pattern: scan_{what}, find_{what}
# Purpose: Find documentation files
# Output: File paths or counts

# Scan for markdown documentation files
# Args: path
# Output: File paths, one per line
scan_docs() {
    local path="$1"

    if [ ! -d "$path" ]; then
        return 0
    fi

    find "$path" -type f \( -name "*.md" -o -name "*.mdx" \) 2>/dev/null | sort
}

# Scan for documentation files with specific extension
# Args: path, extension (e.g., "md" or "mdx")
# Output: File paths, one per line
scan_docs_ext() {
    local path="$1"
    local ext="$2"

    if [ ! -d "$path" ]; then
        return 0
    fi

    find "$path" -type f -name "*.${ext}" 2>/dev/null | sort
}

# Count documentation files
# Args: path
# Output: Integer count
count_docs() {
    local path="$1"

    scan_docs "$path" | wc -l | tr -d ' '
}

# Find documentation files matching a pattern
# Args: path, pattern (grep regex)
# Output: Matching file paths
find_docs_matching() {
    local path="$1"
    local pattern="$2"

    scan_docs "$path" | grep -E "$pattern" || true
}

# List top-level directories in docs
# Args: path
# Output: Directory names, one per line
list_doc_sections() {
    local path="$1"

    if [ ! -d "$path" ]; then
        return 0
    fi

    find "$path" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | xargs -I{} basename {} | sort
}

# =============================================================================
# FRAMEWORK DETECTION PRIMITIVES
# =============================================================================
# Pattern: detect_{what}
# Purpose: Identify documentation framework
# Output: Framework name or indicator files

# Detect documentation framework
# Args: source_path
# Output: "docusaurus" | "mkdocs" | "sphinx" | "vitepress" | "nextra" | "unknown"
detect_doc_framework() {
    local path="$1"

    if [ -f "$path/docusaurus.config.js" ] || [ -f "$path/docusaurus.config.ts" ]; then
        echo "docusaurus"
    elif [ -f "$path/mkdocs.yml" ] || [ -f "$path/mkdocs.yaml" ]; then
        echo "mkdocs"
    elif [ -f "$path/conf.py" ] && grep -q "sphinx" "$path/conf.py" 2>/dev/null; then
        echo "sphinx"
    elif [ -f "$path/.vitepress/config.js" ] || [ -f "$path/.vitepress/config.ts" ]; then
        echo "vitepress"
    elif [ -f "$path/next.config.js" ] && [ -d "$path/pages" ]; then
        echo "nextra"
    elif [ -f "$path/book.toml" ]; then
        echo "mdbook"
    elif [ -f "$path/antora.yml" ]; then
        echo "antora"
    else
        echo "unknown"
    fi
}

# Find navigation/sidebar configuration file
# Args: source_path
# Output: Path to nav config file, or empty
find_nav_config() {
    local path="$1"

    # Docusaurus
    if [ -f "$path/sidebars.js" ]; then
        echo "$path/sidebars.js"
    elif [ -f "$path/sidebars.ts" ]; then
        echo "$path/sidebars.ts"
    # MkDocs
    elif [ -f "$path/mkdocs.yml" ]; then
        echo "$path/mkdocs.yml"
    elif [ -f "$path/mkdocs.yaml" ]; then
        echo "$path/mkdocs.yaml"
    # Sphinx
    elif [ -f "$path/index.rst" ]; then
        echo "$path/index.rst"
    # VitePress
    elif [ -f "$path/.vitepress/config.js" ]; then
        echo "$path/.vitepress/config.js"
    fi
}

# Detect if docs have frontmatter
# Args: source_path
# Output: "yaml" | "toml" | "none"
detect_frontmatter_type() {
    local path="$1"
    local sample_file

    # Find first markdown file
    sample_file=$(scan_docs "$path" | head -1)

    if [ -z "$sample_file" ]; then
        echo "none"
        return 0
    fi

    # Check first line
    local first_line
    first_line=$(head -1 "$sample_file" 2>/dev/null || true)

    if [ "$first_line" = "---" ]; then
        echo "yaml"
    elif [ "$first_line" = "+++" ]; then
        echo "toml"
    else
        echo "none"
    fi
}

# =============================================================================
# LARGE FILE DETECTION PRIMITIVES
# =============================================================================
# Pattern: detect_{what}, find_{what}
# Purpose: Find files too large to read directly
# Output: File paths or line counts

# Find files larger than threshold
# Args: path, [min_lines (default 1000)]
# Output: "path|lines" per file
find_large_files() {
    local path="$1"
    local min_lines="${2:-1000}"

    if [ ! -d "$path" ]; then
        return 0
    fi

    # Find all text files and check line count
    find "$path" -type f \( \
        -name "*.md" -o -name "*.mdx" -o \
        -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o \
        -name "*.graphql" -o -name "*.gql" \
    \) -exec wc -l {} \; 2>/dev/null | \
    awk -v min="$min_lines" '$1 >= min {print $2 "|" $1}' | sort -t'|' -k2 -nr
}

# Find structured schema files (GraphQL, OpenAPI, JSON Schema)
# Args: path
# Output: File paths, one per line
find_schema_files() {
    local path="$1"

    if [ ! -d "$path" ]; then
        return 0
    fi

    find "$path" -type f \( \
        -name "*.graphql" -o -name "*.gql" -o \
        -name "openapi.yaml" -o -name "openapi.json" -o \
        -name "swagger.yaml" -o -name "swagger.json" -o \
        -name "schema.json" -o -name "*.schema.json" \
    \) 2>/dev/null | sort
}

# Get line count for a file
# Args: file_path
# Output: Integer line count
get_file_lines() {
    local file="$1"

    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

# Check if file is too large to read directly
# Args: file_path, [threshold (default 1000)]
# Returns: 0 if large, 1 if small
is_large_file() {
    local file="$1"
    local threshold="${2:-1000}"
    local lines

    lines=$(get_file_lines "$file")
    [ "$lines" -ge "$threshold" ]
}

# Suggest grep pattern for file type
# Args: file_path
# Output: Suggested grep pattern
suggest_grep_pattern() {
    local file="$1"
    local ext="${file##*.}"

    case "$ext" in
        graphql|gql)
            echo 'grep -n "^type {Name}" FILE -A 30'
            ;;
        yaml|yml)
            if grep -q "openapi" "$file" 2>/dev/null; then
                echo 'grep -n "/{path}" FILE -A 20'
            else
                echo 'grep -n "{key}:" FILE -A 10'
            fi
            ;;
        json)
            echo 'grep -n "\"{property}\"" FILE -A 10'
            ;;
        *)
            echo 'grep -n "{pattern}" FILE -A 20'
            ;;
    esac
}

# =============================================================================
# CONTENT ANALYSIS PRIMITIVES
# =============================================================================
# Pattern: sample_{what}, extract_{what}
# Purpose: Analyze documentation content
# Output: Sample content or extracted data

# Sample frontmatter from a file
# Args: file_path
# Output: Frontmatter content (between --- delimiters)
sample_frontmatter() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 0
    fi

    # Check if starts with ---
    if [ "$(head -1 "$file")" != "---" ]; then
        return 0
    fi

    # Extract between first and second ---
    sed -n '1,/^---$/p' "$file" | sed -n '2,/^---$/p' | head -n -1
}

# Sample first N lines of a file
# Args: file_path, [num_lines (default 30)]
# Output: First N lines
sample_file() {
    local file="$1"
    local num_lines="${2:-30}"

    if [ -f "$file" ]; then
        head -"$num_lines" "$file"
    fi
}

# Extract title from markdown file
# Args: file_path
# Output: Title string
extract_title() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 0
    fi

    # Try frontmatter title first
    local fm_title
    fm_title=$(sample_frontmatter "$file" | grep -E "^title:" | sed 's/title: *//' | tr -d '"'"'" | head -1)

    if [ -n "$fm_title" ]; then
        echo "$fm_title"
        return 0
    fi

    # Try first H1
    grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //' || true
}

# Extract description from markdown file
# Args: file_path
# Output: Description string
extract_description() {
    local file="$1"

    if [ ! -f "$file" ]; then
        return 0
    fi

    # Try frontmatter description
    local fm_desc
    fm_desc=$(sample_frontmatter "$file" | grep -E "^description:" | sed 's/description: *//' | tr -d '"'"'" | head -1)

    if [ -n "$fm_desc" ]; then
        echo "$fm_desc"
        return 0
    fi

    # Try first paragraph after H1
    sed -n '/^# /,/^$/p' "$file" 2>/dev/null | tail -n +2 | head -1 || true
}

# =============================================================================
# INDEX STRUCTURE DETECTION
# =============================================================================
# Pattern: detect_{what}, list_{what}
# Purpose: Analyze index structure
# Output: Structure information

# Detect if corpus uses tiered indexing
# Args: corpus_path
# Returns: 0 if tiered, 1 if flat
detect_tiered_index() {
    local corpus_path="$1"
    local data_path="${corpus_path%/}/data"

    ls "$data_path"/index-*.md >/dev/null 2>&1
}

# List sub-index files
# Args: corpus_path
# Output: Sub-index filenames (not full paths)
list_subindex_files() {
    local corpus_path="$1"
    local data_path="${corpus_path%/}/data"

    for f in "$data_path"/index-*.md; do
        [ -f "$f" ] || continue
        basename "$f"
    done
}

# Count index entries
# Args: index_file
# Output: Approximate entry count (lines starting with -)
count_index_entries() {
    local index_file="$1"

    if [ -f "$index_file" ]; then
        grep -c "^- " "$index_file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Extract sections from index
# Args: index_file
# Output: Section headings (## lines)
extract_index_sections() {
    local index_file="$1"

    if [ -f "$index_file" ]; then
        grep "^## " "$index_file" 2>/dev/null | sed 's/^## //' || true
    fi
}

# =============================================================================
# BATCH SCANNING
# =============================================================================
# Pattern: scan_all_{what}
# Purpose: Scan across multiple sources
# Output: Combined results

# Scan all sources in a corpus for docs
# Args: corpus_path
# Output: "source_id|count|path" per source
scan_all_sources() {
    local corpus_path="$1"
    local config_file="${corpus_path%/}/data/config.yaml"

    if [ ! -f "$config_file" ]; then
        return 0
    fi

    # Get source IDs
    local source_ids
    source_ids=$(yq '.sources[].id' "$config_file" 2>/dev/null || true)

    for source_id in $source_ids; do
        local source_type source_path count

        source_type=$(yq ".sources[] | select(.id == \"$source_id\") | .type" "$config_file" 2>/dev/null)

        case "$source_type" in
            git)
                local docs_root
                docs_root=$(yq ".sources[] | select(.id == \"$source_id\") | .docs_root // \".\"" "$config_file" 2>/dev/null)
                source_path="${corpus_path%/}/.source/${source_id}/${docs_root}"
                ;;
            local)
                source_path="${corpus_path%/}/data/uploads/${source_id}"
                ;;
            web)
                source_path="${corpus_path%/}/.cache/web/${source_id}"
                ;;
        esac

        count=$(count_docs "$source_path")
        echo "${source_id}|${count}|${source_path}"
    done
}

# Get total doc count across all sources
# Args: corpus_path
# Output: Integer total
count_all_docs() {
    local corpus_path="$1"
    local total=0

    while IFS='|' read -r source_id count path; do
        total=$((total + count))
    done < <(scan_all_sources "$corpus_path")

    echo "$total"
}
