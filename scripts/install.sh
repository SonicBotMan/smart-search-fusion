#!/bin/bash
# Smart Search Fusion - 一键安装脚本
# 支持：本地安装和远程部署

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="smart-search-fusion"
GITHUB_USER=""  # 用户需要替换为实际用户名
GITHUB_REPO="https://github.com/${GITHUB_USER}/${PROJECT_NAME}.git"

# 颜色输出
print_info() {
    echo -e "\033[0;36mℹ️  $1\033[0m"
}

print_success() {
    echo -e "\033[0;32m✅ $1\033[0m"
}

print_error() {
    echo -e "\033[0;31m❌ $1\033[0m"
}

print_warning() {
    echo -e "\033[0;33m⚠️  $1\033[0m"
}

# 检查 OpenClaw 安装
check_openclaw() {
    if ! command -v openclaw &> /dev/null; then
        print_error "未检测到 OpenClaw"
        echo "请先安装 OpenClaw: https://github.com/openclaw/openclaw"
        exit 1
    fi
    print_success "OpenClaw 已安装"
}

# 检查依赖
check_dependencies() {
    local missing=()
    
    for cmd in jq curl mcporter; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "缺少依赖: ${missing[*]}"
        echo ""
        echo "请运行: sudo apt install jq curl"
        echo "或参考文档: docs/DEPENDENCIES.md"
        exit 1
    fi
    print_success "所有依赖已安装"
}

# 创建目录结构
setup_directories() {
    print_info "创建目录结构..."
    
    local target_dir="$HOME/.openclaw/workspace/${PROJECT_NAME}"
    mkdir -p "$target_dir/scripts"
    mkdir -p "$target_dir/config"
    mkdir -p "$target_dir/cache"
    mkdir -p "$target_dir/logs"
    mkdir -p "$target_dir/docs"
    
    print_success "目录结构已创建"
}

# 复制文件
install_files() {
    print_info "安装文件..."
    
    local script_dir="$(dirname "$0")"
    local target_dir="$HOME/.openclaw/workspace/${PROJECT_NAME}"
    
    # 复制核心脚本
    cp "$script_dir/scripts/search.sh" "$target_dir/scripts/"
    cp "$script_dir/scripts/cache.sh" "$target_dir/scripts/"
    
    chmod +x "$target_dir/scripts/"*.sh
    
    # 复制配置模板
    if [ ! -f "$target_dir/config/config.json" ]; then
        cp "$script_dir/config/config.json.example" "$target_dir/config/config.json"
        print_warning "已创建配置文件，请编辑填入 API Keys"
    fi
    
    print_success "文件已安装"
}

# 配置 OpenClaw Skill 链接
setup_skill_link() {
    print_info "配置 Skill 链接..."
    
    local skill_dir="$HOME/.openclaw/workspace/skills/${PROJECT_NAME}"
    local target_dir="$HOME/.openclaw/workspace/${PROJECT_NAME}"
    
    # 创建软链接
    if [ ! -L "$skill_dir" ]; then
        ln -s "$target_dir" "$skill_dir"
        print_success "Skill 链接已创建: $skill_dir"
    else
        print_info "Skill 链接已存在"
    fi
}

# 运行安全检查
run_security_check() {
    print_info "运行安全检查..."
    
    local check_script="$HOME/.openclaw/workspace/${PROJECT_NAME}/scripts/security-check.sh"
    
    if [ -f "$check_script" ]; then
        bash "$check_script"
        print_success "安全检查完成"
    else
        print_warning "安全检查脚本不存在，跳过"
    fi
}

# 显示安装后说明
show_post_install() {
    echo ""
    echo -e "\033[0;36m========================================\033[0m"
    echo -e "\033[0;32m🎉 安装完成！\033[0m"
    echo -e "\033[0;36m========================================\033[0m"
    echo ""
    echo -e "\033[0;33m📝 下一步:\033[0m"
    echo ""
    echo "1. 编辑配置文件:"
    echo "   $HOME/.openclaw/workspace/${PROJECT_NAME}/config/config.json"
    echo ""
    echo "2. 配置 API Keys（智谱、Exa 等）:"
    echo "   - 智谱 AI: https://open.bigmodel.cn"
    echo "   - Exa AI: https://exa.ai"
    echo ""
    echo "3. 使用方法:"
    echo "   搜索: search.sh '查询词'"
    echo "   并行搜索: search.sh -p '查询词'"
    echo ""
    echo -e "\033[0;36m📚 文档:\033[0m"
    echo "   $HOME/.openclaw/workspace/${PROJECT_NAME}/README.md"
    echo ""
    echo -e "\033[0;36m🙏️ Star 支持:\033[0m"
    echo "   ${GITHUB_REPO}"
}

# 主安装流程
main() {
    echo -e "\033[0;36m========================================\033[0m"
    echo -e "\033[0;32m🚀 Smart Search Fusion 安装\033[0m"
    echo -e "\033[0;36m========================================\033[0m"
    echo ""
    
    # 执行检查
    check_openclaw
    check_dependencies
    
    # 执行安装
    setup_directories
    install_files
    setup_skill_link
    run_security_check
    
    # 显示结果
    show_post_install
}

# 主入口
case "$1" in
    --check)
        check_openclaw
        check_dependencies
        exit 0
        ;;
    *)
        main
        ;;
esac
