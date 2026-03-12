# 贡献指南

感谢你考虑为 Smart Search Fusion 做贡献！

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [提交规范](#提交规范)
- [发布流程](#发布流程)

---

## 行为准则

### 我们的承诺

- 使用包容性语言
- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

---

## 如何贡献

### 🐛 报告 Bug

**在提交 Bug 之前：**

1. 检查 [Issues](https://github.com/SonicBotMan/smart-search-fusion/issues) 是否已有相同问题
2. 确认你使用的是最新版本
3. 收集以下信息：
   - 操作系统和版本
   - OpenClaw 版本
   - 错误日志
   - 复现步骤

**提交 Bug Issue：**

```markdown
## Bug 描述

简洁描述问题

## 复现步骤

1. 执行 '...'
2. 输入 '....'
3. 看到错误 '....'

## 期望行为

描述你期望发生的事情

## 实际行为

描述实际发生的事情

## 环境信息

- OS: [e.g. Ubuntu 22.04]
- OpenClaw: [e.g. 2026.3.2]
- Smart Search Fusion: [e.g. v2.0.0]

## 日志

```
粘贴相关日志
```

## 截图

如果适用，添加截图
```

---

### ✨ 提出新功能

**提交 Feature Issue：**

```markdown
## 功能描述

清晰描述你想要的功能

## 问题背景

描述这个功能解决什么问题

## 建议方案

描述你建议的解决方案

## 替代方案

描述你考虑过的替代方案

## 附加信息

添加任何其他相关信息
```

---

### 🔧 提交代码

**开发流程：**

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add: 添加某功能'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

**PR 标题格式：**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type（必填）：**

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例：**

```
feat(search): 添加 Google 搜索源支持

- 新增 Google Custom Search API 集成
- 支持自定义搜索范围
- 自动 fallback 到 SearXNG

Closes #123
```

---

## 开发流程

### 🔨 本地开发

**环境要求：**

- Bash 4.0+
- jq 1.6+
- curl 7.0+

**克隆项目：**

```bash
git clone https://github.com/SonicBotMan/smart-search-fusion.git
cd smart-search-fusion
```

**安装依赖：**

```bash
# 安装 jq（如果没有）
sudo apt-get install jq

# 配置搜索源
cp config/config.json.example config/config.json
# 编辑 config.json，填入你的 API Keys
```

**测试：**

```bash
# 测试单个搜索源
bash scripts/search.sh -s searxng "OpenClaw"

# 测试并行搜索
bash scripts/search.sh -p "AI 最新动态"

# 测试缓存
bash scripts/cache.sh test
```

---

### 📝 代码规范

**Shell 脚本：**

```bash
#!/bin/bash
# Script Description
# Author: Your Name
# Version: 1.0.0

set -o pipefail  # 启用管道错误检测

# 使用有意义的变量名
CACHE_DIR="/tmp/smart-search-cache"
MAX_RETRIES=3

# 函数注释
# 函数：search_source
# 功能：执行单个搜索源
# 参数：
#   $1 - 搜索源名称
#   $2 - 搜索关键词
# 返回：JSON 格式搜索结果
search_source() {
    local source="$1"
    local query="$2"
    
    # 实现...
}

# 错误处理
if [ $? -ne 0 ]; then
    echo "Error: Failed to search" >&2
    exit 1
fi
```

**命名规范：**

- **脚本文件**：`search.sh`, `cache.sh`, `install.sh`
- **配置文件**：`config.json`, `*.example`
- **文档文件**：`README.md`, `CHANGELOG.md`
- **变量**：UPPER_CASE（常量）, lower_case（变量）
- **函数**：snake_case

**注释规范：**

```bash
# ======== 主要功能区块 ========

# 单行注释

# TODO: 待实现功能
# FIXME: 需要修复的问题
# NOTE: 重要说明
# HACK: 临时解决方案
```

---

### 🧪 测试规范

**测试清单：**

- [ ] 单个搜索源测试
- [ ] 并行搜索测试
- [ ] 缓存功能测试
- [ ] 错误重试测试
- [ ] 超时处理测试
- [ ] 配置加载测试

**测试命令：**

```bash
# 运行所有测试
bash tests/run_all_tests.sh

# 运行单个测试
bash tests/test_search.sh
bash tests/test_cache.sh
```

---

## 提交规范

### 📝 Commit Message 格式

遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**示例：**

```
feat(search): 添加并行搜索支持

- 支持同时调用 3 个搜索源
- 自动聚合结果
- 智能路由选择

Closes #45
```

```
fix(cache): 修复缓存过期时间计算错误

- 使用 TTL 秒数而非毫秒
- 添加边界检查

Fixes #67
```

---

## 发布流程

### 🚀 版本发布

**遵循语义化版本：**

- **MAJOR**：不兼容的 API 修改
- **MINOR**：向下兼容的功能新增
- **PATCH**：向下兼容的问题修正

**发布步骤：**

1. 更新 `CHANGELOG.md`
2. 更新版本号
3. 提交并打标签
4. 推送标签
5. GitHub 自动构建 Release

**示例：**

```bash
# 更新 CHANGELOG.md
vim CHANGELOG.md

# 提交更改
git add CHANGELOG.md
git commit -m "chore: 准备发布 v2.1.0"

# 创建标签
git tag v2.1.0

# 推送
git push origin main
git push origin v2.1.0
```

---

## 🤝 代码审查

### 审查重点

**代码质量：**
- 代码是否符合规范
- 是否有明显的 bug
- 是否有性能问题
- 是否有安全隐患

**文档完整性：**
- 是否更新了 README
- 是否更新了 CHANGELOG
- 是否添加了必要的注释

**测试覆盖：**
- 是否添加了测试
- 测试是否通过
- 边界情况是否考虑

---

## 📞 联系方式

- **GitHub Issues**: [提交问题](https://github.com/SonicBotMan/smart-search-fusion/issues)
- **GitHub Discussions**: [参与讨论](https://github.com/SonicBotMan/smart-search-fusion/discussions)
- **Pull Requests**: [提交代码](https://github.com/SonicBotMan/smart-search-fusion/pulls)

---

## 📄 许可证

通过贡献代码，你同意你的代码将根据 [MIT License](LICENSE) 授权。

---

*感谢你的贡献！🎉*

---

*最后更新: 2026-03-13*
