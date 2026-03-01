#!/bin/bash
# Smart Search 统一搜索入口 v2.0
# 支持：并行搜索、错误重试、自动切换、缓存

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_SCRIPT="$SCRIPT_DIR/cache.sh"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo "{}"
    fi
}

CONFIG=$(load_config)

# 从配置读取值
get_config() {
    local path="$1"
    local default="$2"
    echo "$CONFIG" | jq -r "$path // $default" 2>/dev/null || echo "$default"
}

CACHE_ENABLED=$(get_config '.cache.enabled' 'true')
CACHE_TTL=$(get_config '.cache.ttl' '600')
PARALLEL_ENABLED=$(get_config '.parallel.enabled' 'true')
PARALLEL_MAX=$(get_config '.parallel.maxSources' '3')
PARALLEL_TIMEOUT=$(get_config '.parallel.timeout' '30')
RETRY_MAX=$(get_config '.retry.maxAttempts' '2')
RETRY_DELAY=$(get_config '.retry.delayMs' '500')

# 解析关键词确定搜索源
detect_sources() {
    local query="$1"
    local q=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # 匹配路由规则
    if [[ "$q" =~ github|代码|git|repo ]]; then
        echo '["gh", "exa"]'
    elif [[ "$q" =~ twitter|x\.com|推文|tweet ]]; then
        echo '["xreach", "searxng"]'
    elif [[ "$q" =~ reddit|帖子 ]]; then
        echo '["exa-reddit", "searxng"]'
    elif [[ "$q" =~ youtube|b站|视频 ]]; then
        echo '["ytdlp"]'
    elif [[ "$q" =~ http|https|www\. ]]; then
        echo '["jina"]'
    else
        # 默认：并行搜索 3 个源
        echo '["web-search-prime", "exa", "searxng"]'
    fi
}

# 执行单个搜索源
search_source() {
    local source="$1"
    local query="$2"
    local timeout_sec="${3:-20}"
    
    local cmd=$(echo "$CONFIG" | jq -r ".sources[\"$source\"].command // empty" 2>/dev/null)
    
    if [ -z "$cmd" ]; then
        echo "{\"error\": \"Unknown source: $source\"}"
        return 1
    fi
    
    # 替换查询词
    cmd="${cmd//\{query\}/$query}"
    
    # 执行搜索（带超时）
    local result
    result=$(timeout "$timeout_sec" bash -c "$cmd" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo "{\"error\": \"Timeout after ${timeout_sec}s\", \"source\": \"$source\"}"
        return 1
    elif [ $exit_code -ne 0 ] || [ -z "$result" ]; then
        echo "{\"error\": \"Search failed\", \"source\": \"$source\", \"code\": $exit_code}"
        return 1
    fi
    
    echo "$result"
    return 0
}

# 带重试的搜索
search_with_retry() {
    local source="$1"
    local query="$2"
    local attempt=1
    
    while [ $attempt -le $RETRY_MAX ]; do
        local result
        result=$(search_source "$source" "$query" "$PARALLEL_TIMEOUT")
        
        if [ $? -eq 0 ]; then
            echo "$result"
            return 0
        fi
        
        # 检查是否有备选源
        local fallback=$(echo "$CONFIG" | jq -r ".sources[\"$source\"].fallback[0] // empty" 2>/dev/null)
        
        if [ -n "$fallback" ] && [ $attempt -eq $RETRY_MAX ]; then
            echo "【切换备选】$source → $fallback" >&2
            search_source "$fallback" "$query" "$PARALLEL_TIMEOUT"
            return $?
        fi
        
        [ $attempt -lt $RETRY_MAX ] && sleep "${RETRY_DELAY}e-3"
        ((attempt++))
    done
    
    echo "{\"error\": \"All attempts failed for $source\"}"
    return 1
}

# 并行搜索
parallel_search() {
    local query="$1"
    local sources="$2"
    local temp_dir=$(mktemp -d)
    local pids=()
    local count=0
    
    # 限制并行数量
    local max=$PARALLEL_MAX
    local source_arr=($(echo "$sources" | jq -r '.[]' 2>/dev/null))
    
    echo "【并行搜索】启动 ${#source_arr[@]} 个源..." >&2
    
    for source in "${source_arr[@]}"; do
        [ $count -ge $max ] && break
        
        (
            result=$(search_with_retry "$source" "$query")
            echo "{\"source\": \"$source\", \"result\": $result}" > "$temp_dir/$source.json"
        ) &
        pids+=($!)
        ((count++))
    done
    
    # 等待所有任务完成
    for pid in "${pids[@]}"; do
        wait $pid 2>/dev/null
    done
    
    # 聚合结果
    echo "【聚合结果】" >&2
    for source in "${source_arr[@]}"; do
        if [ -f "$temp_dir/$source.json" ]; then
            local data=$(cat "$temp_dir/$source.json")
            local error=$(echo "$data" | jq -r '.result.error // empty' 2>/dev/null)
            
            if [ -n "$error" ]; then
                echo "  ❌ $source: $error" >&2
            else
                echo "  ✅ $source" >&2
                echo "$data" | jq -c '.result'
            fi
        fi
    done
    
    rm -rf "$temp_dir"
}

# 串行搜索（带缓存）
serial_search() {
    local query="$1"
    local source="$2"
    
    # 检查缓存
    if [ "$CACHE_ENABLED" = "true" ]; then
        local cached=$($CACHE_SCRIPT get "$query" "$source")
        if [ -n "$cached" ]; then
            echo "【缓存命中】$source | $query"
            echo "$cached"
            return
        fi
    fi
    
    echo "【实时搜索】$source | $query"
    
    local result
    result=$(search_with_retry "$source" "$query")
    
    # 保存缓存
    if [ "$CACHE_ENABLED" = "true" ] && [ -n "$result" ]; then
        $CACHE_SCRIPT set "$query" "$source" "$result"
    fi
    
    echo "$result"
}

# 主入口
main() {
    local query=""
    local force=""
    local source=""
    local parallel=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                force="1"
                shift
                ;;
            -s|--source)
                shift
                source="$1"
                shift
                ;;
            -p|--parallel)
                parallel="1"
                shift
                ;;
            -h|--help)
                echo "Smart Search v2.0 - 并行搜索 + 错误重试"
                echo ""
                echo "用法: search.sh [选项] <查询词>"
                echo ""
                echo "选项:"
                echo "  -f, --force      强制实时搜索，不使用缓存"
                echo "  -s, --source     指定搜索源"
                echo "  -p, --parallel   并行搜索（多个源同时搜索）"
                echo ""
                echo "搜索源: gh, xreach, exa-reddit, ytdlp, jina, web-search-prime, searxng, exa"
                echo ""
                echo "示例:"
                echo "  search.sh OpenClaw                    # 自动选择最优源"
                echo "  search.sh -p OpenClaw                 # 并行搜索 3 个源"
                echo "  search.sh -s gh OpenClaw              # 仅用 GitHub"
                echo "  search.sh -f AI 最新新闻              # 强制实时搜索"
                exit 0
                ;;
            *)
                query="$1"
                shift
                ;;
        esac
    done
    
    if [ -z "$query" ]; then
        echo "错误: 请提供查询词"
        echo "使用 -h 查看帮助"
        exit 1
    fi
    
    # 确定搜索源
    local sources
    if [ -n "$source" ]; then
        sources="[\"$source\"]"
    else
        sources=$(detect_sources "$query")
    fi
    
    # 选择搜索模式
    if [ "$parallel" = "1" ] || [ "$PARALLEL_ENABLED" = "true" ]; then
        # 如果指定了单个源，还是用串行
        if [ -n "$source" ]; then
            serial_search "$query" "$source"
        else
            parallel_search "$query" "$sources"
        fi
    else
        # 串行搜索第一个源
        local first_source=$(echo "$sources" | jq -r '.[0]')
        serial_search "$query" "$first_source"
    fi
}

# 缓存管理
case "$1" in
    stats)
        $CACHE_SCRIPT stats
        ;;
    clear)
        $CACHE_SCRIPT clear
        ;;
    *)
        main "$@"
        ;;
esac
