#!/bin/bash
# Smart Search Fusion - 安全检查脚本
# 检测 API Key、密码、敏感信息泄露

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0
WARNINGS=0

# 颜色输出
print_error() {
    echo -e "\033[0;31m❌ $1\033[0m"
    ((ERRORS++))
}

print_warning() {
    echo -e "\033[0;33m⚠️  $1\033[0m"
    ((WARNINGS++))
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

# 检查 API Key 泄露
check_api_keys() {
    echo ""
    echo "🔍 检查 API Key 泄露..."
    
    # 常见 API Key 模式
    local patterns=(
        "sk-[a-zA-Z0-9]{20,}"
        "[a-f0-9]{32,}\\.[a-zA-Z0-9_-]{10,}"  # JWT Token
        "ghp_[a-zA-Z0-9]{36}"  # GitHub Personal Token
        "github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}"  # GitHub PAT
        "AIza[a-zA-Z0-9_-]{35}"  # Google API Key
        "AKIA[A-Z0-9]{16}"  # AWS Access Key
        "eyJ[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*"  # JWT
    )
    
    for file in $(find "$SCRIPT_DIR" -type f \( -name "*.sh" -o -name "*.json" -o -name "*.md" \)); do
        for pattern in "${patterns[@]}"; do
            if grep -qE "$pattern" "$file" 2>/dev/null; then
                print_error "发现敏感信息: $file"
                grep -nE "$pattern" "$file" | head -3
            fi
        done
    done
    
    if [ $ERRORS -eq 0 ]; then
        print_success "未发现 API Key 泄露"
    fi
}

# 检查密码泄露
check_passwords() {
    echo ""
    echo "🔍 检查密码泄露..."
    
    local password_patterns=(
        "password\\s*[:=]\\s*['\"][^'\"]+['\"]"
        "passwd\\s*[:=]\\s*['\"][^'\"]+['\"]"
        "pwd\\s*[:=]\\s*['\"][^'\"]+['\"]"
        "secret\\s*[:=]\\s*['\"][^'\"]+['\"]"
    )
    
    for file in $(find "$SCRIPT_DIR" -type f \( -name "*.sh" -o -name "*.json" \)); do
        for pattern in "${password_patterns[@]}"; do
            if grep -qiE "$pattern" "$file" 2>/dev/null; then
                print_warning "可能包含密码: $file"
            fi
        done
    done
    
    if [ $WARNINGS -eq 0 ]; then
        print_success "未发现密码泄露"
    fi
}

# 检查 IP 地址泄露
check_ip_addresses() {
    echo ""
    echo "🔍 检查私有 IP 地址泄露..."
    
    local ip_pattern="(192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}|10\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}|172\\.(1[6-9]|2[0-9]|3[01])\\.[0-9]{1,3}\\.[0-9]{1,3})"
    
    for file in $(find "$SCRIPT_DIR" -type f \( -name "*.sh" -o -name "*.json" -o -name "*.md" \)); do
        if grep -qE "$ip_pattern" "$file" 2>/dev/null; then
            print_warning "可能包含私有 IP: $file"
        fi
    done
    
    if [ $WARNINGS -eq 0 ]; then
        print_success "未发现私有 IP 泄露"
    fi
}

# 检查邮箱地址泄露
check_emails() {
    echo ""
    echo "🔍 检查邮箱地址泄露..."
    
    local email_pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"
    
    for file in $(find "$SCRIPT_DIR" -type f \( -name "*.sh" -o -name "*.json" \)); do
        if grep -qE "$email_pattern" "$file" 2>/dev/null; then
            print_warning "可能包含邮箱: $file"
        fi
    done
    
    if [ $WARNINGS -eq 0 ]; then
        print_success "未发现邮箱泄露"
    fi
}

# 检查 .gitignore
check_gitignore() {
    echo ""
    echo "🔍 检查 .gitignore..."
    
    local gitignore_file="$SCRIPT_DIR/.gitignore"
    
    if [ ! -f "$gitignore_file" ]; then
        print_warning ".gitignore 不存在，建议创建"
        return
    fi
    
    local required_ignores=("*.env" "*.key" "*.pem" "config.json" "cache/" "logs/")
    local missing=()
    
    for ignore in "${required_ignores[@]}"; do
        if ! grep -qF "$ignore" "$gitignore_file" 2>/dev/null; then
            missing+=("$ignore")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_warning ".gitignore 缺少: ${missing[*]}"
    else
        print_success ".gitignore 配置正确"
    fi
}

# 显示结果
show_results() {
    echo ""
    echo "========================================"
    echo "安全检查完成"
    echo "========================================"
    echo ""
    
    if [ $ERRORS -gt 0 ]; then
        echo -e "\033[0;31m❌ 发现 $ERRORS 个严重问题\033[0m"
        echo "请修复后再发布！"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "\033[0;33m⚠️  发现 $WARNINGS 个警告\033[0m"
        echo "建议检查后再发布"
    else
        echo -e "\033[0;32m✅ 所有检查通过，可以安全发布\033[0m"
    fi
}

# 主入口
echo "========================================"
echo "🔒 Smart Search Fusion 安全检查"
echo "========================================"

check_api_keys
check_passwords
check_ip_addresses
check_emails
check_gitignore
show_results
