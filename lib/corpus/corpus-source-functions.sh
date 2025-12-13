#!/usr/bin/env bash
# Corpus Source Functions
# Layer 2 primitives for managing documentation sources
#
# Source this file to use: source corpus-source-functions.sh
#
# This domain handles:
# - Git source operations (clone, fetch, pull)
# - Git tracking (SHA, commits, diffs)
# - Local source management
# - Web cache management
#
# Used by: add-source, build, refresh skills

set -euo pipefail

# =============================================================================
# GIT CLONE PRIMITIVES
# =============================================================================
# Pattern: clone_{what}
# Purpose: Clone git repositories
# Output: Path to cloned repo

# Clone a git source into .source directory
# Args: repo_url, source_id, [corpus_path]
# Output: Path to cloned directory
clone_source() {
    local repo_url="$1"
    local source_id="$2"
    local corpus_path="${3:-.}"
    local clone_path="${corpus_path}/.source/${source_id}"

    # Remove trailing slash from corpus_path
    corpus_path="${corpus_path%/}"
    clone_path="${corpus_path}/.source/${source_id}"

    if [ -d "$clone_path" ]; then
        echo "ERROR: Clone already exists at $clone_path" >&2
        return 1
    fi

    mkdir -p "$(dirname "$clone_path")"
    git clone --depth 1 "$repo_url" "$clone_path" >&2

    echo "$clone_path"
}

# Clone with specific branch
# Args: repo_url, source_id, branch, [corpus_path]
# Output: Path to cloned directory
clone_source_branch() {
    local repo_url="$1"
    local source_id="$2"
    local branch="$3"
    local corpus_path="${4:-.}"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ -d "$clone_path" ]; then
        echo "ERROR: Clone already exists at $clone_path" >&2
        return 1
    fi

    mkdir -p "$(dirname "$clone_path")"
    git clone --depth 1 --branch "$branch" "$repo_url" "$clone_path" >&2

    echo "$clone_path"
}

# =============================================================================
# GIT TRACKING PRIMITIVES
# =============================================================================
# Pattern: get_{what}
# Purpose: Get git repository information
# Output: Requested value

# Get HEAD SHA from a cloned source
# Args: corpus_path, source_id
# Output: SHA string
get_source_sha() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" rev-parse HEAD
}

# Get short SHA (7 chars)
# Args: corpus_path, source_id
# Output: Short SHA string
get_source_sha_short() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" rev-parse --short HEAD
}

# Get current branch name
# Args: corpus_path, source_id
# Output: Branch name
get_source_branch() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" rev-parse --abbrev-ref HEAD
}

# Get remote URL
# Args: corpus_path, source_id
# Output: Remote URL
get_source_remote_url() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" remote get-url origin
}

# =============================================================================
# GIT UPDATE PRIMITIVES
# =============================================================================
# Pattern: fetch_{what}, pull_{what}
# Purpose: Update cloned sources
# Output: Status or new SHA

# Fetch updates from remote (doesn't merge)
# Args: corpus_path, source_id
# Output: Nothing (status to stderr)
fetch_source() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" fetch origin >&2
}

# Pull updates from remote
# Args: corpus_path, source_id
# Output: New HEAD SHA
pull_source() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" pull origin >&2
    git -C "$clone_path" rev-parse HEAD
}

# Get upstream SHA without pulling
# Args: repo_url, [branch]
# Output: SHA string
fetch_upstream_sha() {
    local repo_url="$1"
    local branch="${2:-main}"

    git ls-remote "$repo_url" "refs/heads/$branch" 2>/dev/null | cut -f1 || true
}

# =============================================================================
# GIT COMPARISON PRIMITIVES
# =============================================================================
# Pattern: get_{what}, compare_{what}
# Purpose: Compare versions and get changes
# Output: Comparison data

# Get commit log between two SHAs
# Args: corpus_path, source_id, from_sha, to_sha, [docs_path]
# Output: Oneline commit log
get_commit_log() {
    local corpus_path="$1"
    local source_id="$2"
    local from_sha="$3"
    local to_sha="$4"
    local docs_path="${5:-}"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    if [ -n "$docs_path" ]; then
        git -C "$clone_path" log --oneline "${from_sha}..${to_sha}" -- "$docs_path"
    else
        git -C "$clone_path" log --oneline "${from_sha}..${to_sha}"
    fi
}

# Get file changes between two SHAs
# Args: corpus_path, source_id, from_sha, to_sha, [docs_path]
# Output: name-status format (A/M/D/R + path)
get_file_changes() {
    local corpus_path="$1"
    local source_id="$2"
    local from_sha="$3"
    local to_sha="$4"
    local docs_path="${5:-}"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    if [ -n "$docs_path" ]; then
        git -C "$clone_path" diff --name-status "${from_sha}..${to_sha}" -- "$docs_path"
    else
        git -C "$clone_path" diff --name-status "${from_sha}..${to_sha}"
    fi
}

# Count commits between two SHAs
# Args: corpus_path, source_id, from_sha, to_sha
# Output: Integer count
count_commits() {
    local corpus_path="$1"
    local source_id="$2"
    local from_sha="$3"
    local to_sha="$4"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    git -C "$clone_path" rev-list --count "${from_sha}..${to_sha}"
}

# Compare local clone with indexed SHA
# Args: corpus_path, source_id, indexed_sha
# Output: "current" | "ahead" | "behind" | "diverged"
compare_clone_to_indexed() {
    local corpus_path="$1"
    local source_id="$2"
    local indexed_sha="$3"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    if [ ! -d "$clone_path/.git" ]; then
        echo "ERROR: No git repo at $clone_path" >&2
        return 1
    fi

    local clone_sha
    clone_sha=$(git -C "$clone_path" rev-parse HEAD)

    if [ "$clone_sha" = "$indexed_sha" ]; then
        echo "current"
    else
        # Check if indexed is ancestor of clone (clone is ahead)
        if git -C "$clone_path" merge-base --is-ancestor "$indexed_sha" "$clone_sha" 2>/dev/null; then
            echo "ahead"
        # Check if clone is ancestor of indexed (clone is behind - shouldn't happen)
        elif git -C "$clone_path" merge-base --is-ancestor "$clone_sha" "$indexed_sha" 2>/dev/null; then
            echo "behind"
        else
            echo "diverged"
        fi
    fi
}

# =============================================================================
# LOCAL SOURCE PRIMITIVES
# =============================================================================
# Pattern: setup_{what}, list_{what}
# Purpose: Manage local document sources
# Output: Paths or file lists

# Setup local uploads directory
# Args: corpus_path, source_id
# Output: Path to uploads directory
setup_local_source() {
    local corpus_path="$1"
    local source_id="$2"
    local uploads_path="${corpus_path%/}/data/uploads/${source_id}"

    mkdir -p "$uploads_path"
    echo "$uploads_path"
}

# List files in local source
# Args: corpus_path, source_id
# Output: File paths, one per line
list_local_files() {
    local corpus_path="$1"
    local source_id="$2"
    local uploads_path="${corpus_path%/}/data/uploads/${source_id}"

    if [ -d "$uploads_path" ]; then
        find "$uploads_path" -type f \( -name "*.md" -o -name "*.mdx" \) 2>/dev/null || true
    fi
}

# Count files in local source
# Args: corpus_path, source_id
# Output: Integer count
count_local_files() {
    local corpus_path="$1"
    local source_id="$2"

    list_local_files "$corpus_path" "$source_id" | wc -l | tr -d ' '
}

# =============================================================================
# WEB SOURCE PRIMITIVES
# =============================================================================
# Pattern: setup_{what}, cache_{what}
# Purpose: Manage web content cache
# Output: Paths or status

# Setup web cache directory
# Args: corpus_path, source_id
# Output: Path to cache directory
setup_web_source() {
    local corpus_path="$1"
    local source_id="$2"
    local cache_path="${corpus_path%/}/.cache/web/${source_id}"

    mkdir -p "$cache_path"
    echo "$cache_path"
}

# Generate cache filename from URL
# Args: url
# Output: Filename (slug.md)
generate_cache_filename() {
    local url="$1"

    # Extract path, remove leading/trailing slashes, replace slashes with hyphens
    echo "$url" | sed -E 's|https?://[^/]+||; s|^/||; s|/$||; s|/|-|g; s|\.html?$||' | tr -cd 'a-zA-Z0-9-_' | head -c 100
    echo ".md"
}

# List cached web files
# Args: corpus_path, source_id
# Output: File paths, one per line
list_web_cache() {
    local corpus_path="$1"
    local source_id="$2"
    local cache_path="${corpus_path%/}/.cache/web/${source_id}"

    if [ -d "$cache_path" ]; then
        find "$cache_path" -type f -name "*.md" 2>/dev/null || true
    fi
}

# Get cache age in days
# Args: corpus_path, source_id, filename
# Output: Age in days
get_cache_age() {
    local corpus_path="$1"
    local source_id="$2"
    local filename="$3"
    local file_path="${corpus_path%/}/.cache/web/${source_id}/${filename}"

    if [ -f "$file_path" ]; then
        local file_time now_time
        file_time=$(stat -c %Y "$file_path" 2>/dev/null || stat -f %m "$file_path" 2>/dev/null)
        now_time=$(date +%s)
        echo $(( (now_time - file_time) / 86400 ))
    else
        echo "-1"
    fi
}

# =============================================================================
# SOURCE EXISTENCE CHECKS
# =============================================================================
# Pattern: exists_{what}
# Purpose: Check if sources exist
# Output: 0 (exists) or 1 (not exists) exit code

# Check if git source clone exists
# Args: corpus_path, source_id
exists_git_source() {
    local corpus_path="$1"
    local source_id="$2"
    local clone_path="${corpus_path%/}/.source/${source_id}"

    [ -d "$clone_path/.git" ]
}

# Check if local source has files
# Args: corpus_path, source_id
exists_local_source() {
    local corpus_path="$1"
    local source_id="$2"
    local count

    count=$(count_local_files "$corpus_path" "$source_id")
    [ "$count" -gt 0 ]
}

# Check if web source has cached files
# Args: corpus_path, source_id
exists_web_source() {
    local corpus_path="$1"
    local source_id="$2"
    local cache_path="${corpus_path%/}/.cache/web/${source_id}"

    [ -d "$cache_path" ] && [ "$(ls -A "$cache_path" 2>/dev/null | wc -l)" -gt 0 ]
}

# =============================================================================
# URL PARSING PRIMITIVES
# =============================================================================
# Pattern: parse_{what}
# Purpose: Extract components from URLs
# Output: Extracted value

# Parse owner from GitHub URL
# Args: repo_url
# Output: Owner name
parse_repo_owner() {
    local url="$1"
    echo "$url" | sed -E 's|.*github\.com[:/]([^/]+)/.*|\1|'
}

# Parse repo name from GitHub URL
# Args: repo_url
# Output: Repo name (without .git)
parse_repo_name() {
    local url="$1"
    echo "$url" | sed -E 's|.*github\.com[:/][^/]+/([^/.]+)(\.git)?.*|\1|'
}

# Generate source ID from repo URL
# Args: repo_url
# Output: Lowercase hyphenated source ID
generate_source_id() {
    local url="$1"
    parse_repo_name "$url" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
}
