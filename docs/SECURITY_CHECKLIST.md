# Smart Search Fusion - 安全检查清单

## 发布前必检

### ✅ API Key 检查

- [ ] 配置文件中的 API Key 已替换为占位符
- [ ] 未提交真实的 API Key 到仓库
- [ ] `.gitignore` 包含 `*.json`（用户配置）

### ✅ 敏感信息检查

- [ ] 无密码硬编码
- [ ] 无私有 IP 地址（192.168.x.x, 10.x.x.x）
- [ ] 无个人邮箱地址
- [ ] 无 Token/Password 关键词

### ✅ 依赖检查

- [ ] 依赖列表完整
- [ ] 开源许可证兼容
- [ ] 无恶意依赖

### ✅ 代码质量

- [ ] 无明显的安全漏洞
- [ ] 无调试代码残留
- [ ] 错误处理完善

## 敏感信息模式

### 禁止提交的模式

```bash
# API Keys
sk-xxxxx
ghp_xxxxx
github_pat_xxxxx

# 密码
password = "xxx"
passwd: xxx

# 私有信息
192.168.x.x
10.x.x.x
user@example.com
```

### 安全实践

1. **使用环境变量**
```bash
# ❌ 错误
echo "API_KEY=sk-xxx" > config.json

# ✅ 正确
echo "API_KEY=\$API_KEY" > config.json
# 用户设置环境变量
export API_KEY=sk-xxx
```

2. **使用 .gitignore**
```
*.json
*.key
*.pem
.env
cache/
logs/
```

3. **配置文件模板**
```json
{
  "api_key": "YOUR_API_KEY_HERE"
}
```

## 自动化检查

项目包含自动化安全检查脚本：

```bash
# 运行安全检查
bash scripts/security-check.sh
```

检查项目：
- API Key 泄露
- 密码泄露
- IP 地址泄露
- 邮箱地址泄露
- .gitignore 配置

## 报告问题

如发现安全问题，请：

1. **不要**提交到公开仓库
2. 发送邮件至: security@example.com
3. 或提交 [Issue](https://github.com/YOUR_USERNAME/smart-search-fusion/issues)

## 更新日志

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-03-01 | 1.0.0 | 初始版本 |
