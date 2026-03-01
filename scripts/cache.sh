#!/bin/bash
# Smart Search 缓存管理脚本
# 用法：
#   cache.sh get <query> <source>          # 获取缓存（返回 JSON 或空）
#   cache.sh set <query> <source> <result> # 保存缓存
#   cache.sh clear                          # 清理过期缓存
#   cache.sh stats                          # 缓存统计

CACHE_DIR="$HOME/.openclaw/workspace/smart-search/cache"
CACHE_TTL=600  # 10 分钟 = 600 秒

# 生成缓存键（MD5）
cache_key() {
    echo -n "${1}:${2}" | md5sum | cut -d' ' -f1
}

# 获取缓存
get_cache() {
    local query="$1"
    local source="$2"
    local key=$(cache_key "$query" "$source")
    local cache_file="$CACHE_DIR/${key}.json"
    local meta_file="$CACHE_DIR/${key}.meta"
    
    # 检查缓存是否存在
    if [ ! -f "$cache_file" ] || [ ! -f "$meta_file" ]; then
        echo ""
        return
    fi
    
    # 检查是否过期
    local cache_time=$(cat "$meta_file" 2>/dev/null)
    local now=$(date +%s)
    local age=$((now - cache_time))
    
    if [ $age -gt $CACHE_TTL ]; then
        # 过期，删除缓存
        rm -f "$cache_file" "$meta_file"
        echo ""
        return
    fi
    
    # 返回缓存内容
    cat "$cache_file"
}

# 保存缓存
set_cache() {
    local query="$1"
    local source="$2"
    local result="$3"
    local key=$(cache_key "$query" "$source")
    local cache_file="$CACHE_DIR/${key}.json"
    local meta_file="$CACHE_DIR/${key}.meta"
    
    # 保存结果
    echo "$result" > "$cache_file"
    
    # 保存时间戳
    date +%s > "$meta_file"
    
    # 记录日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') | CACHE SET | $source | $query" >> \
        "$HOME/.openclaw/workspace/smart-search/logs/cache.log"
}

# 清理过期缓存
clear_expired() {
    local count=0
    local now=$(date +%s)
    
    for meta_file in "$CACHE_DIR"/*.meta; do
        [ ! -f "$meta_file" ] && continue
        
        local cache_time=$(cat "$meta_file" 2>/dev/null)
        local age=$((now - cache_time))
        
        if [ $age -gt $CACHE_TTL ]; then
            local key=$(basename "$meta_file" .meta)
            rm -f "$CACHE_DIR/${key}.json" "$CACHE_DIR/${key}.meta"
            ((count++))
        fi
    done
    
    echo "清理了 $count 个过期缓存"
}

# 缓存统计
stats() {
    local total=$(ls -1 "$CACHE_DIR"/*.json 2>/dev/null | wc -l)
    local size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
    
    echo "缓存统计："
    echo "  总数: $total 条"
    echo "  大小: $size"
    echo "  有效期: $CACHE_TTL 秒（$((CACHE_TTL / 60)) 分钟）"
}

# 主入口
case "$1" in
    get)
        get_cache "$2" "$3"
        ;;
    set)
        set_cache "$2" "$3" "$4"
        ;;
    clear)
        clear_expired
        ;;
    stats)
        stats
        ;;
    *)
        echo "用法: $0 {get|set|clear|stats}"
        echo "  get <query> <source>          # 获取缓存"
        echo "  set <query> <source> <result> # 保存缓存"
        echo "  clear                          # 清理过期缓存"
        echo "  stats                          # 缓存统计"
        exit 1
        ;;
esac
