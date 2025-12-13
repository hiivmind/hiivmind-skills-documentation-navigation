laude Code Plugin/Skill Marketplace Research

  Here's what I found about the Claude Code plugin ecosystem:

  Official Resources

  https://github.com/anthropics/skills (20.6k stars)
  - Official public repository demonstrating skills across creative, development, enterprise, and document categories
  - Can be registered as a Claude Code marketplace
  - Skills available in Claude.ai (paid), Claude API, and Claude Code

  https://code.claude.com/docs/en/plugin-marketplaces
  - Marketplaces are JSON files listing available plugins with locations
  - Any git hosting service works for distribution
  - No monetization mechanism exists — all plugins are free/open-source

  Key Concepts

  | Concept      | Description                                                             |
  |--------------|-------------------------------------------------------------------------|
  | Skills       | Model-invoked capabilities that activate automatically based on context |
  | Commands     | Require explicit /command trigger                                       |
  | Plugins      | Bundles of skills, commands, agents, hooks                              |
  | Marketplaces | JSON catalogs pointing to plugin repositories                           |

  Community Marketplaces

  | Marketplace                                                 | Size                               | Notes                                                         |
  |-------------------------------------------------------------|------------------------------------|---------------------------------------------------------------|
  | https://github.com/jeremylongshore/claude-code-plugins-plus | 257 plugins, 175 with Agent Skills | Claims largest collection, validated against 2025 schema      |
  | https://skillsmp.com/                                       | 24,117+ skills                     | Web aggregator scanning GitHub, not affiliated with Anthropic |
  | https://github.com/netresearch/claude-code-marketplace      | Curated                            | Netresearch DTT GmbH collection                               |
  | https://github.com/MadAppGang/claude-code                   | Production-ready                   | Focus on web development teams                                |
  | https://github.com/hekmon8/awesome-claude-code-plugins      | Meta-list                          | Curated list of plugins and resources                         |

  Distribution Model

  # Register a marketplace
  /plugin marketplace add owner/repo

  # Install from marketplace
  /plugin install plugin-name@marketplace-name

  Marketplaces use .claude-plugin/marketplace.json format. Individual plugins use .claude-plugin/plugin.json.

  Relevance to hiivmind-corpus

  Your current marketplace publishing approach (standalone repos at hiivmind-corpus-data/, hiivmind-corpus-claude/) aligns well with the ecosystem. The pattern of:
  - Marketplace repo with marketplace.json
  - Individual plugin subdirectories
  - Installation via /plugin marketplace add hiivmind/...

  ...matches how community marketplaces operate.

  ---
  Sources:
  - https://github.com/anthropics/skills
  - https://code.claude.com/docs/en/plugin-marketplaces
  - https://code.claude.com/docs/en/plugins
  - https://skillsmp.com/
  - https://github.com/jeremylongshore/claude-code-plugins-plus
  - https://www.anthropic.com/news/skills

──────────────────────────────────────────────────────
