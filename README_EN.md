# Smart Search Fusion

![License](https://img.shields.io/badge/license-MIT-green.svg)
![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-orange.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)
![Version](https://img.shields.io/badge/version-v2.0-blue.svg)

> 🚀 **Intelligent Fusion Search Engine** - A Multi-Source Parallel Search Solution for OpenClaw

**[中文文档](README.md)** | **English**

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Search Sources](#search-sources)
- [Usage](#usage)
- [Configuration](#configuration)
- [Development](#development)

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🔄 **Parallel Search** | Call multiple sources simultaneously, aggregate results |
| 🔁 **Auto Retry** | Automatic retry on failure, intelligent fallback |
| 💾 **Smart Cache** | 10-minute cache mechanism, reduces API calls by 90% |
| 🎯 **Intelligent Routing** | Auto-select optimal source based on keywords |
| 🔌 **Unified Interface** | One command to access all sources |
| 🔒 **Security Check** | Automatic API key leak detection |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Smart Search Fusion                   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ Router      │  │ Cache Mgr   │  │ Error Hdlr  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────┤
│                    Source Adapter Layer                  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐          │
│  │Zhipu   │ │  Exa   │ │SearXNG │ │ GitHub │ ...      │
│  └────────┘ └────────┘ └────────┘ └────────┘          │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### One-Line Install

```bash
# Install from GitHub
curl -sL https://raw.githubusercontent.com/SonicBotMan/smart-search-fusion/main/scripts/install.sh | bash

# Or clone and install
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion && bash scripts/install.sh
```

### OpenClaw Remote Deployment

In your OpenClaw conversation, send:

```
Deploy smart-search-fusion
```

## 📊 Search Sources

| Source | Type | Description | Requires Key | Free |
|--------|------|-------------|--------------|------|
| **Zhipu Search** | General | Best for Chinese, web search | ✅ | 1000/month |
| **Exa AI** | Semantic | AI semantic search | ✅ | 1000/month |
| **SearXNG** | Meta | Aggregates multiple engines | ❌ | ✅ Unlimited |
| **GitHub** | Code | Repository search | ✅ | 5000/hour |
| **Twitter/X** | Social | Tweet search | ❌ | ✅ Free |
| **Reddit** | Community | Post search | ✅ | - |
| **Jina Reader** | Web | Deep web reading | ❌ | ✅ Free |

## 📖 Usage

### Basic Search

```bash
# Smart search (auto-select best source)
search.sh "OpenClaw tutorial"

# Parallel search (search 3 sources simultaneously)
search.sh -p "AI latest news"

# Specify source
search.sh -s gh "OpenClaw"          # GitHub search
search.sh -s searxng "news"         # SearXNG search
search.sh -s web-search-prime "OpenClaw" # Zhipu search

# Force real-time search (no cache)
search.sh -f "today headlines"
```

### Advanced Usage

```bash
# Parallel search with custom sources
search.sh -p -s "exa,searxng,gh" "OpenClaw"

# Search with result limit
search.sh -s searxng "AI news" --limit 10

# Output as JSON
search.sh -s gh "OpenClaw" --json

# Verbose mode
search.sh -p "OpenClaw" -v
```

## ⚙️ Configuration

### Config File

Create `config/config.json` based on `config/config.json.example`:

```json
{
  "sources": {
    "gh": {
      "name": "GitHub",
      "command": "gh search repos \"{query}\" --limit 5 --json name,description,url",
      "timeout": 10,
      "fallback": ["exa"]
    },
    "searxng": {
      "name": "SearXNG",
      "command": "bash ~/searxng_search.sh \"{query}\" 5",
      "timeout": 15,
      "fallback": ["exa"]
    }
  },
  "routing": {
    "github|code|git|repo": ["gh", "exa"],
    "default": ["web-search-prime", "exa", "searxng"]
  },
  "cache": {
    "enabled": true,
    "ttl": 600
  },
  "parallel": {
    "enabled": true,
    "maxSources": 3,
    "timeout": 30
  }
}
```

### Environment Variables

```bash
# API Keys (optional)
export ZHIPU_API_KEY="your_key"
export EXA_API_KEY="your_key"
export GITHUB_TOKEN="your_token"

# Cache directory
export SEARCH_CACHE_DIR="/tmp/smart-search-cache"
```

## 🔧 Development

### Project Structure

```
smart-search-fusion/
├── scripts/
│   ├── search.sh              # Main search script
│   ├── cache.sh               # Cache manager
│   ├── install.sh             # Installation script
│   ├── deploy-searxng.sh      # SearXNG deployment
│   └── security-check.sh      # Security check
├── config/
│   ├── config.json.example    # Configuration example
│   └── config.json            # User configuration
├── docs/
│   ├── API.md                 # API documentation
│   └── DEPLOYMENT.md          # Deployment guide
├── README.md                  # Chinese documentation
├── README_EN.md               # English documentation
├── CHANGELOG.md               # Changelog
├── CONTRIBUTING.md            # Contribution guide
└── LICENSE                    # MIT License
```

### Development Guide

```bash
# Clone repository
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion

# Run tests
bash tests/run_all_tests.sh

# Add new search source
# 1. Add to config.json
# 2. Update routing rules
# 3. Test
# 4. Submit PR
```

### Adding New Source

**Step 1: Add to `config.json`**

```json
"new-source": {
  "name": "New Search Source",
  "command": "your_command_here \"{query}\"",
  "timeout": 20,
  "fallback": ["searxng"]
}
```

**Step 2: Update routing**

```json
"keyword1|keyword2": ["new-source", "exa"]
```

**Step 3: Test**

```bash
bash scripts/search.sh -s new-source "test query"
```

**Step 4: Submit PR**

Follow [CONTRIBUTING.md](CONTRIBUTING.md)

## 🤝 Contributing

We welcome contributions!

- **Bug Reports**: [Issues](https://github.com/SonicBotMan/smart-search-fusion/issues)
- **Feature Requests**: [Issues](https://github.com/SonicBotMan/smart-search-fusion/issues)
- **Pull Requests**: [PRs](https://github.com/SonicBotMan/smart-search-fusion/pulls)

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## 📄 License

[MIT License](LICENSE)

## 🙏 Acknowledgments

- [OpenClaw](https://github.com/openclaw/openclaw) - OpenClaw Framework
- [SearXNG](https://github.com/searxng/searxng) - Meta search engine
- [Exa AI](https://exa.ai/) - AI semantic search
- [Zhipu AI](https://www.zhipuai.cn/) - Zhipu Search API

---

<div align="center">

**Made with ❤️ by SonicBotMan**

</div>
