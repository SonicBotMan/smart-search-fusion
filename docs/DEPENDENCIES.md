# Smart Search Fusion - 依赖说明

## 核心依赖

### 必须安装

| 依赖 | 版本 | 说明 | 安装命令 |
|------|------|------|---------|
| **OpenClaw** | >= 2026.2.0 | AI Agent 框架 | 官网安装 |
| **jq** | >= 1.5 | JSON 处理 | `sudo apt install jq` |
| **curl** | 最新 | HTTP 请求 | `sudo apt install curl` |
| **mcporter** | 最新 | MCP 工具调用 | `npm i -g mcporter` |

### 可选依赖

| 依赖 | 说明 | 安装命令 |
|------|------|---------|
| **gh CLI** | GitHub 搜索 | `brew install gh` 或 `sudo apt install gh` |
| **xreach** | Twitter/X 搜索 | 详见 Agent Reach |
| **yt-dlp** | 视频信息提取 | `pip install yt-dlp` |

## API 服务

### 必须配置

| 服务 | 用途 | 免费额度 | 注册地址 |
|------|------|---------|---------|
| **智谱 AI** | 联网搜索 | 1000次/月 | https://open.bigmodel.cn |
| **Exa AI** | 语义搜索 | 1000次/月 | https://exa.ai |

### 可选服务

| 服务 | 用途 | 免费额度 | 注册地址 |
|------|------|---------|---------|
| **SearXNG** | 元搜索 | 无限（自建）| https://searxng.org |
| **Jina Reader** | 网页读取 | 有限 | https://jina.ai |

## 安装步骤

### 1. 安装系统依赖

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y jq curl git

# macOS
brew install jq curl git
```

### 2. 安装 OpenClaw

```bash
# 方式一：官方安装
npm install -g openclaw

# 方式二：Docker
docker pull openclaw/openclaw
```

### 3. 安装 mcporter

```bash
npm install -g mcporter
```

### 4. 配置 MCP

编辑 `~/.openclaw/workspace/config/mcporter.json`:

```json
{
  "mcpServers": {
    "web-search-prime": {
      "description": "智谱 AI 联网搜索 MCP",
      "type": "streamable-http",
      "url": "https://open.bigmodel.cn/api/mcp/web_search_prime/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_ZHIPU_API_KEY"
      }
    },
    "exa": {
      "baseUrl": "https://mcp.exa.ai/mcp"
    }
  }
}
```

### 5. 获取 API Keys

#### 智谱 AI
1. 访问 https://open.bigmodel.cn
2. 注册/登录
3. 控制台 → API Keys → 创建 Key

#### Exa AI
1. 访问 https://exa.ai
2. 注册/登录
3. Dashboard → API Keys → 创建 Key

## 验证安装

```bash
# 检查依赖
bash scripts/install.sh --check

# 测试搜索
search.sh "测试"

# 查看缓存
search.sh stats
```

## 故障排除

### mcporter 命令未找到
```bash
# 重新安装
npm install -g mcporter

# 检查路径
which mcporter
```

### 搜索失败
```bash
# 检查 API Keys
cat ~/.openclaw/workspace/config/mcporter.json | jq '.mcpServers'

# 测试 MCP 连接
mcporter list
```

### 缓存问题
```bash
# 清理缓存
search.sh clear

# 查看日志
cat ~/.openclaw/workspace/smart-search-fusion/logs/cache.log
```
