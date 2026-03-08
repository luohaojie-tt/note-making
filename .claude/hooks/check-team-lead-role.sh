#!/bin/bash

# Team Lead Role Check Hook
# 自动检测 Team Lead 模式，禁止直接修改代码

# 获取脚本所在目录（应该是 .claude/hooks/）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# 转换为 Unix 风格路径用于比较
PROJECT_DIR_UNIX="$(echo "$PROJECT_DIR" | sed 's|\\|/|g')"

# 检查手动标记文件（优先级最高）
MARKER_FILE="$SCRIPT_DIR/.team-lead-mode"
if [ -f "$MARKER_FILE" ]; then
    echo ""
    echo "=========================================="
    echo "  Team Lead 角色约束 (手动启用)"
    echo "=========================================="
    echo ""
    echo "你正在以 Team Lead 身份运行，不能直接修改代码。"
    echo ""
    echo "请执行以下步骤："
    echo "  1. 使用 TaskCreate 创建任务"
    echo "  2. 使用 Task 分配给合适的 teammate"
    echo "  3. 使用 SendMessage 告知具体需求"
    echo ""
    echo "=========================================="
    exit 2
fi

# 自动检测：检查是否有活动的 team 且当前目录匹配
TEAMS_DIR="$HOME/.claude/teams"
if [ -d "$TEAMS_DIR" ]; then
    # 遍历所有 team 配置
    for team_config in "$TEAMS_DIR"/*/config.json; do
        if [ -f "$team_config" ]; then
            # 提取 team 的 cwd 和检查是否有 leadSessionId（表示 team 活跃）
            TEAM_CWD=$(grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' "$team_config" 2>/dev/null | sed 's/"cwd"[[:space:]]*:[[:space:]]*"\(.*\)"/\1/' | sed 's|\\|/|g')
            LEAD_SESSION=$(grep -o '"leadSessionId"[[:space:]]*:[[:space:]]*"[^"]*"' "$team_config" 2>/dev/null)

            # 如果 team 的 cwd 与当前项目目录匹配，且有活跃的 lead session
            if [ "$TEAM_CWD" = "$PROJECT_DIR_UNIX" ] && [ -n "$LEAD_SESSION" ]; then
                echo ""
                echo "=========================================="
                echo "  Team Lead 角色约束 (自动检测)"
                echo "=========================================="
                echo ""
                echo "检测到活动的 Team 模式，你作为 Team Lead 不能直接修改代码。"
                echo ""
                echo "请执行以下步骤："
                echo "  1. 使用 TaskCreate 创建任务"
                echo "  2. 使用 Task 分配给合适的 teammate"
                echo "  3. 使用 SendMessage 告知具体需求"
                echo ""
                echo "如需手动编辑，请先关闭 team 或删除 team 配置。"
                echo ""
                echo "=========================================="
                exit 2
            fi
        fi
    done
fi

# 未检测到 team-lead 模式，允许操作
exit 0
