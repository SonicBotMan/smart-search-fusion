#!/bin/bash
# SearXNG 一键部署脚本
# 支持：Docker 部署（推荐）和源码部署

set -e

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

SEARXNG_PORT="${1:-8888}"
SEARXNG_DIR="$HOME/searxng"

# 检查 Docker
check_docker() {
    if command -v docker &> /dev/null; then
        print_success "Docker 已安装"
        return 0
    else
        print_error "Docker 未安装"
        echo ""
        echo "请先安装 Docker："
        echo "  curl -fsSL https://get.docker.com | sh"
        echo "  sudo usermod -aG docker $USER"
        return 1
    fi
}

# Docker 部署（推荐）
deploy_docker() {
    print_info "使用 Docker 部署 SearXNG..."
    
    # 创建配置目录
    mkdir -p "$SEARXNG_DIR"
    
    # 创建 docker-compose.yml
    cat > "$SEARXNG_DIR/docker-compose.yml" << 'EOF'
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
    
  redis:
    image: redis:alpine
    container_name: searxng-redis
    command: redis-server --appendonly yes
    volumes:
      - ./redis:/data:rw
    restart: unless-stopped
EOF

    # 生成密钥
    local secret=$(openssl rand -hex 32)
    sed -i "s/\$(openssl rand -hex 32)/$secret/" "$SEARXNG_DIR/docker-compose.yml"
    
    # 创建 SearXNG 配置
    mkdir -p "$SEARXNG_DIR/searxng"
    cat > "$SEARXNG_DIR/searxng/settings.yml" << 'EOF'
use_default_settings: true

general:
  instance_name: "SearXNG Local"
  debug: false
  enable_metrics: false

search:
  safe_search: 0
  autocomplete: "google"
  default_lang: "zh-CN"

server:
  port: 8080
  bind_address: "0.0.0.0"
  secret_key: "CHANGE_ME"
  limiter: false
  image_proxy: true

outgoing:
  request_timeout: 10.0
  max_request_timeout: 15.0
  pool_connections: 100
  pool_maxsize: 20

engines:
  - name: google
    engine: google
    shortcut: g
    disabled: false
    
  - name: bing
    engine: bing
    shortcut: b
    disabled: false
    
  - name: duckduckgo
    engine: duckduckgo
    shortcut: ddg
    disabled: false
    
  - name: github
    engine: github
    shortcut: gh
    disabled: false
EOF

    # 更新密钥
    sed -i "s/CHANGE_ME/$secret/" "$SEARXNG_DIR/searxng/settings.yml"
    
    # 启动服务
    cd "$SEARXNG_DIR"
    docker-compose up -d 2>&1 | tail -5
    
    print_success "SearXNG 已启动"
    print_info "访问地址: http://localhost:$SEARXNG_PORT"
}

# 源码部署（备选）
deploy_source() {
    print_info "使用源码部署 SearXNG..."
    
    # 检查 Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 未安装"
        return 1
    fi
    
    # 安装依赖
    sudo apt update
    sudo apt install -y git build-essential libxslt-dev python3-dev python3-venv \
        python3-pip libxml2-dev libffi-dev libssl-dev openssl
    
    # 克隆仓库
    git clone https://github.com/searxng/searxng.git "$SEARXNG_DIR/searxng-src"
    cd "$SEARXNG_DIR/searxng-src"
    
    # 创建虚拟环境
    python3 -m venv venv
    source venv/bin/activate
    
    # 安装依赖
    pip install -U pip setuptools wheel
    pip install -U pyyaml lxml
    
    # 生成配置
    make settings
    
    # 启动服务
    SEARXNG_SECRET=$(openssl rand -hex 32) \
    SEARXNG_BASE_URL="http://localhost:$SEARXNG_PORT/" \
    python searx/webapp.py
    
    print_success "SearXNG 已启动（源码模式）"
}

# 配置 Smart Search Fusion
configure_smart_search() {
    print_info "配置 Smart Search Fusion..."
    
    local config_file="$HOME/.openclaw/workspace/smart-search-fusion/config/config.json"
    local search_script="$HOME/.openclaw/workspace/smart-search/scripts/searxng_search.sh"
    
    # 更新搜索脚本
    cat > ~/searxng_search.sh << EOF
#!/bin/bash
# SearXNG 搜索脚本

QUERY="\$1"
COUNT="\${2:-5}"
SEARXNG_URL="http://localhost:$SEARXNG_PORT"

curl -s "\${SEARXNG_URL}/search?q=\${QUERY}&format=json" | \\
    jq -r '.results[:\$COUNT][] | "【\(.engine)】\n标题: \(.title)\n链接: \(.url)\n摘要: \(.content)\n"' 2>/dev/null
EOF
    
    chmod +x ~/searxng_search.sh
    
    print_success "Smart Search Fusion 已配置"
}

# 显示使用说明
show_usage() {
    echo ""
    echo -e "\033[0;36m========================================\033[0m"
    echo -e "\033[0;32m🎉 SearXNG 部署完成！\033[0m"
    echo -e "\033[0;36m========================================\033[0m"
    echo ""
    echo -e "\033[0;33m📝 使用方法:\033[0m"
    echo ""
    echo "1. 访问 Web 界面:"
    echo "   http://localhost:$SEARXNG_PORT"
    echo ""
    echo "2. API 调用:"
    echo "   curl 'http://localhost:$SEARXNG_PORT/search?q=test&format=json'"
    echo ""
    echo "3. Smart Search Fusion 搜索:"
    echo "   bash ~/searxng_search.sh '搜索词' 5"
    echo ""
    echo -e "\033[0;33m📋 管理命令:\033[0m"
    echo ""
    echo "  查看状态:  docker ps | grep searxng"
    echo "  停止服务:  cd $SEARXNG_DIR && docker-compose down"
    echo "  重启服务:  cd $SEARXNG_DIR && docker-compose restart"
    echo "  查看日志:  cd $SEARXNG_DIR && docker-compose logs -f"
    echo ""
}

# 主入口
main() {
    echo -e "\033[0;36m========================================\033[0m"
    echo -e "\033[0;32m🚀 SearXNG 一键部署\033[0m"
    echo -e "\033[0;36m========================================\033[0m"
    echo ""
    
    # 选择部署方式
    echo "请选择部署方式："
    echo "  1) Docker 部署（推荐）"
    echo "  2) 源码部署（备选）"
    echo ""
    read -p "请输入选项 [1/2]: " choice
    
    case "$choice" in
        1)
            if check_docker; then
                deploy_docker
            else
                exit 1
            fi
            ;;
        2)
            deploy_source
            ;;
        *)
            print_error "无效选项"
            exit 1
            ;;
    esac
    
    # 配置 Smart Search Fusion
    configure_smart_search
    
    # 显示使用说明
    show_usage
}

# 命令行参数
case "$1" in
    --docker)
        check_docker && deploy_docker && configure_smart_search && show_usage
        ;;
    --source)
        deploy_source && configure_smart_search && show_usage
        ;;
    --status)
        docker ps | grep searxng
        ;;
    --stop)
        cd "$SEARXNG_DIR" && docker-compose down
        print_success "SearXNG 已停止"
        ;;
    *)
        main
        ;;
esac
