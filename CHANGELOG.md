# 更新日志

所有重要的更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并且本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 🔜 计划中

- 添加更多搜索源支持
- 性能监控和统计
- Web UI 界面
- Docker 部署方案

---

## [2.0.0] - 2026-03-12

### ✨ 新增功能

**智能搜索系统：**
- ✅ 并行搜索 - 同时调用多个搜索源，聚合结果
- ✅ 错误重试 - 自动重试失败请求，智能切换备选源
- ✅ 智能缓存 - 10 分钟缓存机制，减少 API 调用 90%
- ✅ 智能路由 - 根据关键词自动选择最优搜索源
- ✅ 统一接口 - 一个命令调用所有搜索源
- ✅ 安全检查 - 自动检测 API Key 泄露

**搜索源支持：**
- ✅ 智谱搜索（web-search-prime）- 中文首选
- ✅ Exa AI - AI 语义搜索
- ✅ SearXNG - 元搜索引擎
- ✅ GitHub - 代码仓库搜索
- ✅ Twitter/X - 推文搜索
- ✅ Reddit - 帖子搜索
- ✅ YouTube/B站 - 视频内容提取
- ✅ Jina Reader - 深度网页读取

**部署支持：**
- ✅ OpenClaw 远程部署
- ✅ SearXNG 本地部署
- ✅ 自动化 Release Workflow

### 📝 文档

- ✅ 完整的 README.md
- ✅ 架构图和流程图
- ✅ 配置示例文件
- ✅ 安装指南

---

## [1.0.0] - 2026-03-08

### ✨ 初始发布

**核心功能：**
- ✅ 基础搜索框架
- ✅ 配置文件系统
- ✅ 缓存机制
- ✅ 错误处理

**搜索源：**
- ✅ SearXNG
- ✅ GitHub
- ✅ 基础网页搜索

---

## 版本说明

### 版本号格式

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 更新类型

- **✨ 新增功能** - Added
- **🔄 变更** - Changed
- **🐛 修复** - Fixed
- **🗑️ 移除** - Removed
- **🚫 废弃** - Deprecated
- **🔒 安全** - Security

---

## 路线图

### v2.1.0（计划）

**性能优化：**
- 🔄 缓存命中率统计
- 🔄 并发性能提升
- 🔄 内存占用优化

**新搜索源：**
- 🔄 Google Custom Search
- 🔄 Bing Search
- 🔄 DuckDuckGo

### v2.2.0（计划）

**高级功能：**
- 🔄 搜索结果排序算法
- 🔄 自定义评分权重
- 🔄 搜索历史记录
- 🔄 导出搜索报告

### v3.0.0（远期）

**平台化：**
- 🔄 Web UI 界面
- 🔄 REST API
- 🔄 Docker 部署
- 🔄 Kubernetes 支持

---

## 贡献

欢迎贡献代码、报告问题、提出建议！

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 许可证

[MIT License](LICENSE)

---

*最后更新: 2026-03-13*
