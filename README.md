# Smart Search Fusion

![License](https://img.shields.io/badge/license-MIT-green.svg)
![OpenClaw](https://img.shields.io/badge/OpenClaw-Compatible-orange.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)
![Version](https://img.shields.io/badge/version-v2.0-blue.svg)

> 🚀 **智能融合搜索引擎** - 为 OpenClaw 打造的多源并行搜索解决方案

## 📋 目录

- [特性](#特性)
- [架构](#架构)
- [快速开始](#快速开始)
- [搜索源](#搜索源)
- [使用方法](#使用方法)
- [配置](#配置)
- [开发](#开发)

## ✨ 特性

| 特性 | 说明 |
|------|------|
| 🔄 **并行搜索** | 同时调用多个搜索源，聚合结果 |
| 🔁 **错误重试** | 自动重试失败请求，智能切换备选源 |
| 💾 **智能缓存** | 10 分钟缓存机制，减少 API 调用 90% |
| 🎯 **智能路由** | 根据关键词自动选择最优搜索源 |
| 🔌 **统一接口** | 一个命令调用所有搜索源 |
| 🔒 **安全检查** | 自动检测 API Key 泄露 |

## 🏗️ 架构

```
┌─────────────────────────────────────────────────────────┐
│                    Smart Search Fusion                   │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ 智能路由器   │  │  缓存管理器  │  │  错误处理器  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────┤
│                     搜索源适配层                         │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐          │
│  │智谱搜索│ │  Exa   │ │SearXNG │ │ GitHub │ ...      │
│  └────────┘ └────────┘ └────────┘ └────────┘          │
└─────────────────────────────────────────────────────────┘
```

## 🚀 快速开始

### 一键安装

```bash
# 从 GitHub 安装
curl -sL https://raw.githubusercontent.com/SonicBotMan/smart-search-fusion/main/scripts/install.sh | bash

# 或克隆安装
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion && bash scripts/install.sh
```

### OpenClaw 远程部署

在你的 OpenClaw 对话中发送：

```
部署 smart-search-fusion
```

## 📊 搜索源

| 搜索源 | 类型 | 说明 | 需要 Key | 免费 |
|--------|------|------|---------|------|
| **智谱搜索** | 通用 | 中文首选，联网搜索 | ✅ | 1000次/月 |
| **Exa AI** | 语义 | AI 语义搜索 | ✅ | 1000次/月 |
| **SearXNG** | 元搜索 | 聚合多搜索引擎 | ❌ | ✅ 无限 |
| **GitHub** | 代码 | 仓库搜索 | ✅ | 5000次/小时 |
| **Twitter/X** | 社交 | 推文搜索 | ❌ | ✅ 免费 |
| **Reddit** | 社区 | 帖子搜索 | ✅ | - |
| **Jina Reader** | 网页 | 深度网页读取 | ❌ | ✅ 免费 |

## 📖 使用方法

### 基本搜索

```bash
# 智能搜索（自动选择最优源）
search.sh "OpenClaw 教程"

# 并行搜索（同时搜索 3 个源）
search.sh -p "AI 最新动态"

# 指定搜索源
search.sh -s gh "OpenClaw"      # GitHub 搜索
search.sh -s searxng "新闻"     # SearXNG 搜索
search.sh -s web-search-prime "OpenClaw" # 智谱搜索

# 强制实时搜索（不使用缓存）
search.sh -f "今日头条"
```

### 缓存管理

```bash
# 查看缓存统计
search.sh stats

# 清理过期缓存
search.sh clear
```

### SearXNG 本地部署

```bash
# Docker 一键部署
bash scripts/deploy-searxng.sh --docker

# 查看状态
bash scripts/deploy-searxng.sh --status

# 停止服务
bash scripts/deploy-searxng.sh --stop
```

## ⚙️ 配置

### 配置文件

```bash
# 复制配置模板
cp config/config.json.example ~/.openclaw/workspace/smart-search/config.json

# 编辑配置
nano ~/.openclaw/workspace/smart-search/config.json
```

### 获取 API Keys

| 服务 | 获取地址 | 免费额度 |
|------|---------|---------|
| 智谱 AI | https://open.bigmodel.cn | 1000 次/月 |
| Exa AI | https://exa.ai | 1000 次/月 |
| GitHub | https://github.com/settings/tokens | 5000 次/小时 |

## 🔧 开发

### 项目结构

```
smart-search-fusion/
├── README.md
├── LICENSE
├── .gitignore
├── .github/workflows/
│   └── release.yml        # 自动 Release
├── scripts/
│   ├── install.sh         # 一键安装
│   ├── search.sh          # 统一搜索入口
│   ├── cache.sh           # 缓存管理
│   ├── deploy-searxng.sh  # SearXNG 部署
│   └── security-check.sh  # 安全检查
├── config/
│   └── config.json.example
└── docs/
    ├── DEPENDENCIES.md
    └── SECURITY_CHECKLIST.md
```

### 本地开发

```bash
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion

# 运行安全检查
bash scripts/security-check.sh

# 测试搜索
bash scripts/search.sh "测试"
```

## 🤝 致谢

### 开源项目
- [OpenClaw](https://github.com/openclaw/openclaw) - AI Agent 框架
- [mcporter](https://github.com/openclaw/mcporter) - MCP 工具调用
- [SearXNG](https://github.com/searxng/searxng) - 元搜索引擎
- [jq](https://stedolan.github.io/jq/) - JSON 处理器

### API 服务
- [智谱 AI](https://open.bigmodel.cn) - GLM 联网搜索
- [Exa AI](https://exa.ai) - AI 语义搜索
- [Jina AI](https://jina.ai) - 网页读取服务

## 📝 License

MIT License - 详见 [LICENSE](LICENSE)

## 🐛 问题反馈

如有问题或建议，请提交 [Issue](https://github.com/SonicBotMan/smart-search-fusion/issues)

---

**Made with ❤️ for OpenClaw Community**
