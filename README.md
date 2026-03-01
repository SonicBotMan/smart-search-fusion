# Smart Search Fusion

🚀 **智能融合搜索引擎** - 为 OpenClaw 打造的多源并行搜索解决方案

## ✨ 特性

- 🔄 **并行搜索** - 同时调用多个搜索源，聚合结果
- 🔁 **错误重试** - 自动重试失败请求，智能切换备选源
- 💾 **智能缓存** - 10 分钟缓存机制，减少 API 调用
- 🎯 **智能路由** - 根据关键词自动选择最优搜索源
- 🔌 **统一接口** - 一个命令调用所有搜索源

## 📊 支持的搜索源

| 搜索源 | 类型 | 说明 | API Key |
|--------|------|------|---------|
| **web-search-prime** | 通用 | 智谱联网搜索（中文首选）| ✅ 需要 |
| **Exa AI** | 语义 | AI 语义搜索 | ✅ 需要 |
| **SearXNG** | 元搜索 | 聚合多搜索引擎 | ❌ 免费 |
| **GitHub** | 代码 | 仓库搜索 | ✅ 需要 |
| **Twitter/X** | 社交 | 推文搜索 | ❌ 免费 |
| **Reddit** | 社区 | 帖子搜索（via Exa）| ✅ 需要 |
| **Jina Reader** | 网页 | 深度网页读取 | ❌ 免费 |

## 🚀 快速开始

### 方式一：一键安装

```bash
# 克隆项目
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion

# 运行安装脚本
bash scripts/install.sh
```

### 方式二：OpenClaw 远程部署

在你的 OpenClaw 对话中发送：

```
部署 smart-search-fusion
```

或手动发送指令：

```bash
curl -s https://raw.githubusercontent.com/SonicBotMan/smart-search-fusion/main/scripts/install.sh | bash
```

## 🐳 SearXNG 本地部署（可选）

SearXNG 是免费的开源元搜索引擎，可以本地部署后替代付费服务。

### 一键部署

```bash
# Docker 部署（推荐）
bash scripts/deploy-searxng.sh --docker

# 查看状态
bash scripts/deploy-searxng.sh --status

# 停止服务
bash scripts/deploy-searxng.sh --stop
```

### 手动部署

```bash
# 1. 安装 Docker（如果没有）
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 2. 创建目录
mkdir -p ~/searxng

# 3. 创建 docker-compose.yml
cat > ~/searxng/docker-compose.yml << 'EOF'
version: '3.7'
services:
  searxng:
    image: searxng/searxng:latest
    container_name: searxng
    ports:
      - "8888:8080"
    environment:
      - SEARXNG_BASE_URL=http://localhost:8888/
      - SEARXNG_SECRET=$(openssl rand -hex 32)
    volumes:
      - ./searxng:/etc/searxng:rw
    restart: unless-stopped
EOF

# 4. 启动
cd ~/searxng && docker-compose up -d
```

### 访问 SearXNG

- **Web 界面**: http://localhost:8888
- **API**: http://localhost:8888/search?q=test&format=json

### 配置 Smart Search 使用本地 SearXNG

```bash
# 编辑搜索脚本，修改 URL
nano ~/searxng_search.sh

# 将 SEARXNG_URL 改为你的本地地址
SEARXNG_URL="http://localhost:8888"
```

### 常见问题

| 问题 | 解决方案 |
|------|---------|
| Docker 未安装 | 运行 `curl -fsSL https://get.docker.com | sh` |
| 端口被占用 | 修改 `docker-compose.yml` 中的端口号 |
| 无法访问 | 检查防火墙：`sudo ufw allow 8888` |

## ⚙️ 配置

### 1. 复制配置文件

```bash
cp config/config.json.example ~/.openclaw/workspace/smart-search/config.json
```

### 2. 配置 API Keys

编辑 `config.json`，填入你的 API Keys：

```json
{
  "sources": {
    "web-search-prime": {
      "headers": {
        "Authorization": "Bearer YOUR_ZHIPU_API_KEY"
      }
    },
    "exa": {
      "headers": {
        "x-api-key": "YOUR_EXA_API_KEY"
      }
    }
  }
}
```

### 3. 获取 API Keys

| 服务 | 获取地址 | 免费额度 |
|------|---------|---------|
| 智谱 AI | https://open.bigmodel.cn | 1000 次/月 |
| Exa AI | https://exa.ai | 1000 次/月 |
| GitHub | https://github.com/settings/tokens | 5000 次/小时 |

## 📖 使用方法

### 基本用法

```bash
# 智能搜索（自动选择最优源）
search.sh "OpenClaw 教程"

# 并行搜索（同时搜索 3 个源）
search.sh -p "AI 最新动态"

# 指定搜索源
search.sh -s gh "OpenClaw"  # GitHub 搜索
search.sh -s searxng "新闻"  # SearXNG 搜索

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

## 🏗️ 项目结构

```
smart-search-fusion/
├── README.md                 # 本文件
├── LICENSE                  # MIT License
├── .gitignore              # Git 忽略文件
├── scripts/
│   ├── install.sh           # 一键安装脚本
│   ├── deploy-searxng.sh   # SearXNG 部署脚本
│   ├── search.sh           # 统一搜索入口
│   ├── cache.sh            # 缓存管理
│   └── security-check.sh   # 安全检查
├── config/
│   └── config.json.example # 配置文件模板
└── docs/
    ├── DEPENDENCIES.md      # 依赖说明
    └── SECURITY_CHECKLIST.md # 安全检查清单
```

## 🔧 依赖项

详见 [DEPENDENCIES.md](docs/DEPENDENCIES.md)

### 核心依赖

- **OpenClaw** >= 2026.2.0
- **jq** - JSON 处理
- **curl** - HTTP 请求
- **mcporter** - MCP 工具调用

### 可选依赖

- **gh CLI** - GitHub 搜索
- **xreach** - Twitter/X 搜索
- **yt-dlp** - 视频信息提取

## 🔒 安全检查

发布前请运行安全检查：

```bash
bash scripts/security-check.sh
```

详见 [SECURITY_CHECKLIST.md](docs/SECURITY_CHECKLIST.md)

## 🤝 致谢

本项目依赖以下开源项目和服务：

### 开源项目
- [OpenClaw](https://github.com/openclaw/openclaw) - AI Agent 框架
- [mcporter](https://github.com/openclaw/mcporter) - MCP 工具调用
- [jq](https://stedolan.github.io/jq/) - JSON 处理器
- [SearXNG](https://github.com/searxng/searxng) - 元搜索引擎

### API 服务
- [智谱 AI](https://open.bigmodel.cn) - GLM 联网搜索
- [Exa AI](https://exa.ai) - AI 语义搜索
- [Jina AI](https://jina.ai) - 网页读取服务

### 灵感来源
- [Perplexity AI](https://perplexity.ai) - AI 搜索引擎
- [Brave Search](https://search.brave.com) - 隐私搜索引擎

## 📝 License

MIT License - 详见 [LICENSE](LICENSE)

## 🐛 问题反馈

如有问题或建议，请提交 [Issue](https://github.com/SonicBotMan/smart-search-fusion/issues)

## 🌟 Star History

如果这个项目对你有帮助，请给个 ⭐️ Star！

---

**Made with ❤️ for OpenClaw Community**
