#!/usr/bin/env bash
# Corpus Context Detection Functions
# Layer 2 primitives for detecting execution context
#
# Source this file to use: source corpus-context-functions.sh
#
# This domain handles:
# - Git repository detection
# - Marketplace detection
# - Corpus detection
# - Project type detection
#
# Used primarily by hiivmind-corpus-init to determine destination type.

set -euo pipefail

# =============================================================================
# DETECTION PRIMITIVES
# =============================================================================
# Pattern: detect_{what}
# Purpose: Check for presence of specific context indicators
# Output: 0 (true) or 1 (false) exit code

# Detect if current directory is inside a git repository
# Returns: 0 if in git repo, 1 otherwise
detect_is_git_repo() {
    git rev-parse --show-toplevel >/dev/null 2>&1
}

# Detect if current directory has a marketplace manifest
# Returns: 0 if has marketplace.json, 1 otherwise
detect_is_marketplace() {
    [ -f ".claude-plugin/marketplace.json" ]
}

# Detect if current directory is a corpus (has config.yaml)
# Returns: 0 if is corpus, 1 otherwise
detect_is_corpus() {
    [ -f "data/config.yaml" ]
}

# Detect if current directory has corpus plugin subdirectories
# Returns: 0 if has hiivmind-corpus-* subdirs, 1 otherwise
detect_has_corpus_plugins() {
    local count
    count=$(ls -d hiivmind-corpus-*/ 2>/dev/null | wc -l)
    [ "$count" -gt 0 ]
}

# Detect if current directory is an established project (not a corpus)
# Returns: 0 if has project files, 1 otherwise
detect_is_project() {
    [ -f "package.json" ] || \
    [ -f "pyproject.toml" ] || \
    [ -f "Cargo.toml" ] || \
    [ -f "go.mod" ] || \
    [ -f "setup.py" ] || \
    [ -f "requirements.txt" ] || \
    [ -f "pom.xml" ] || \
    [ -f "build.gradle" ]
}

# Detect if directory is empty or near-empty (fresh directory)
# Returns: 0 if empty/near-empty, 1 otherwise
detect_is_fresh() {
    local file_count
    file_count=$(ls -A 2>/dev/null | wc -l)
    [ "$file_count" -le 2 ]
}

# Detect if current directory has a plugin manifest
# Returns: 0 if has plugin.json, 1 otherwise
detect_is_plugin() {
    [ -f ".claude-plugin/plugin.json" ]
}

# =============================================================================
# GET PRIMITIVES
# =============================================================================
# Pattern: get_{what}
# Purpose: Retrieve context information
# Output: Value to stdout

# Get git repository root directory
# Output: Absolute path to repo root, or empty if not in repo
get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || true
}

# Get current directory name
# Output: Directory name (not full path)
get_current_dir_name() {
    basename "$(pwd)"
}

# Get project type from detected files
# Output: "python" | "node" | "rust" | "go" | "java" | "unknown"
get_project_type() {
    if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "package.json" ]; then
        echo "node"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    else
        echo "unknown"
    fi
}

# Get marketplace name from manifest
# Output: Marketplace name or empty
get_marketplace_name() {
    if [ -f ".claude-plugin/plugin.json" ]; then
        yq -r '.name // ""' .claude-plugin/plugin.json 2>/dev/null || true
    fi
}

# =============================================================================
# CONTEXT ANALYSIS
# =============================================================================
# Pattern: analyze_{what}
# Purpose: Determine context type for init routing
# Output: Context type string

# Analyze current context and return context type
# Output: One of: "established-project" | "fresh" | "marketplace-existing" | "corpus"
analyze_context() {
    if detect_is_corpus; then
        echo "corpus"
    elif detect_is_marketplace || detect_has_corpus_plugins; then
        echo "marketplace-existing"
    elif detect_is_project; then
        echo "established-project"
    elif detect_is_fresh; then
        echo "fresh"
    else
        echo "unknown"
    fi
}

# Get recommended destination types based on context
# Output: Space-separated list of destination types
get_destination_options() {
    local context
    context=$(analyze_context)

    case "$context" in
        "established-project")
            echo "user-level repo-local"
            ;;
        "fresh")
            echo "user-level single-corpus multi-corpus"
            ;;
        "marketplace-existing")
            echo "add-to-marketplace"
            ;;
        "corpus")
            echo "none"
            ;;
        *)
            echo "user-level"
            ;;
    esac
}

# =============================================================================
# PATH RESOLUTION
# =============================================================================
# Pattern: resolve_{what}_path
# Purpose: Determine destination paths for different contexts
# Output: Absolute path

# Resolve user-level skill path
# Args: skill_name
# Output: ~/.claude/skills/{skill_name}
resolve_user_level_path() {
    local skill_name="$1"
    echo "${HOME}/.claude/skills/${skill_name}"
}

# Resolve repo-local skill path
# Args: skill_name
# Output: {repo_root}/.claude-plugin/skills/{skill_name}
resolve_repo_local_path() {
    local skill_name="$1"
    local repo_root
    repo_root=$(get_repo_root)

    if [ -z "$repo_root" ]; then
        echo "ERROR: Not in a git repository" >&2
        return 1
    fi

    echo "${repo_root}/.claude-plugin/skills/${skill_name}"
}

# Resolve single-corpus plugin path (current directory)
# Output: Current working directory
resolve_single_corpus_path() {
    pwd
}

# Resolve multi-corpus plugin path
# Args: plugin_name
# Output: {pwd}/{plugin_name}
resolve_multi_corpus_path() {
    local plugin_name="$1"
    echo "$(pwd)/${plugin_name}"
}

# =============================================================================
# SCAFFOLD PRIMITIVES
# =============================================================================
# Pattern: scaffold_{what}
# Purpose: Create directory structures
# Output: Created path

# Scaffold user-level skill directory
# Args: skill_name
# Output: Created path
scaffold_user_level() {
    local skill_name="$1"
    local path
    path=$(resolve_user_level_path "$skill_name")

    mkdir -p "$path/data"
    echo "$path"
}

# Scaffold repo-local skill directory
# Args: skill_name
# Output: Created path
scaffold_repo_local() {
    local skill_name="$1"
    local path
    path=$(resolve_repo_local_path "$skill_name")

    mkdir -p "$path/data"
    echo "$path"
}

# Scaffold single-corpus plugin directory
# Output: Created path (pwd)
scaffold_single_corpus() {
    local path
    path=$(pwd)

    mkdir -p "$path/.claude-plugin"
    mkdir -p "$path/skills/navigate"
    mkdir -p "$path/data"
    echo "$path"
}

# Scaffold multi-corpus marketplace and first plugin
# Args: marketplace_name, plugin_name
# Output: Plugin path
scaffold_multi_corpus() {
    local marketplace_name="$1"
    local plugin_name="$2"
    local marketplace_path plugin_path

    marketplace_path=$(pwd)
    plugin_path="${marketplace_path}/${plugin_name}"

    # Marketplace structure
    mkdir -p "$marketplace_path/.claude-plugin"

    # Plugin structure
    mkdir -p "$plugin_path/.claude-plugin"
    mkdir -p "$plugin_path/skills/navigate"
    mkdir -p "$plugin_path/data"

    echo "$plugin_path"
}

# Scaffold new plugin in existing marketplace
# Args: plugin_name
# Output: Plugin path
scaffold_add_to_marketplace() {
    local plugin_name="$1"
    local plugin_path
    plugin_path="$(pwd)/${plugin_name}"

    mkdir -p "$plugin_path/.claude-plugin"
    mkdir -p "$plugin_path/skills/navigate"
    mkdir -p "$plugin_path/data"

    echo "$plugin_path"
}

# =============================================================================
# VERIFICATION PRIMITIVES
# =============================================================================
# Pattern: verify_{what}
# Purpose: Check if structures are complete
# Output: 0 if valid, 1 if invalid (with error message to stderr)

# Verify user-level or repo-local skill structure
# Args: skill_path
verify_skill_structure() {
    local path="$1"
    local errors=0

    if [ ! -f "$path/SKILL.md" ]; then
        echo "Missing: SKILL.md" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/data/config.yaml" ]; then
        echo "Missing: data/config.yaml" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/data/index.md" ]; then
        echo "Missing: data/index.md" >&2
        ((errors++)) || true
    fi

    [ "$errors" -eq 0 ]
}

# Verify plugin structure (single-corpus or in marketplace)
# Args: plugin_path
verify_plugin_structure() {
    local path="$1"
    local errors=0

    if [ ! -f "$path/.claude-plugin/plugin.json" ]; then
        echo "Missing: .claude-plugin/plugin.json" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/skills/navigate/SKILL.md" ]; then
        echo "Missing: skills/navigate/SKILL.md" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/data/config.yaml" ]; then
        echo "Missing: data/config.yaml" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/data/index.md" ]; then
        echo "Missing: data/index.md" >&2
        ((errors++)) || true
    fi

    [ "$errors" -eq 0 ]
}

# Verify marketplace structure
# Args: marketplace_path
verify_marketplace_structure() {
    local path="$1"
    local errors=0

    if [ ! -f "$path/.claude-plugin/plugin.json" ]; then
        echo "Missing: .claude-plugin/plugin.json" >&2
        ((errors++)) || true
    fi

    if [ ! -f "$path/.claude-plugin/marketplace.json" ]; then
        echo "Missing: .claude-plugin/marketplace.json" >&2
        ((errors++)) || true
    fi

    [ "$errors" -eq 0 ]
}
