#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Team Lead Role Check Hook
自动检测 Team Lead 模式，禁止直接修改代码
"""

import json
import os
import sys
from pathlib import Path

def get_project_dir():
    """获取项目目录"""
    # 脚本在 .claude/hooks/ 下
    script_dir = Path(__file__).parent
    project_dir = script_dir.parent.parent
    return project_dir

def check_manual_marker():
    """检查手动标记文件"""
    script_dir = Path(__file__).parent
    marker_file = script_dir / ".team-lead-mode"
    return marker_file.exists()

def check_active_team_lead():
    """检查是否有活动的 team 且当前是 team-lead"""
    project_dir = get_project_dir()
    teams_dir = Path.home() / ".claude" / "teams"

    if not teams_dir.exists():
        return False

    for team_dir in teams_dir.iterdir():
        if not team_dir.is_dir():
            continue

        config_file = team_dir / "config.json"
        if not config_file.exists():
            continue

        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)

            # 检查是否有活跃的 lead session
            if not config.get('leadSessionId'):
                continue

            # 检查 members 中是否有 cwd 匹配当前项目的 team-lead
            for member in config.get('members', []):
                if member.get('agentType') == 'team-lead':
                    member_cwd = Path(member.get('cwd', ''))
                    try:
                        # 比较路径（解析后）
                        if member_cwd.resolve() == project_dir.resolve():
                            return True
                    except:
                        # 如果解析失败，尝试字符串比较
                        if str(member_cwd).replace('\\', '/') == str(project_dir).replace('\\', '/'):
                            return True
        except Exception as e:
            continue

    return False

def main():
    # 检查手动标记文件（优先级最高）
    if check_manual_marker():
        print("")
        print("=" * 42)
        print("  Team Lead 角色约束 (手动启用)")
        print("=" * 42)
        print("")
        print("你正在以 Team Lead 身份运行，不能直接修改代码。")
        print("")
        print("请执行以下步骤：")
        print("  1. 使用 TaskCreate 创建任务")
        print("  2. 使用 Task 分配给合适的 teammate")
        print("  3. 使用 SendMessage 告知具体需求")
        print("")
        print("=" * 42)
        sys.exit(2)

    # 自动检测 team-lead 模式
    if check_active_team_lead():
        print("")
        print("=" * 42)
        print("  Team Lead 角色约束 (自动检测)")
        print("=" * 42)
        print("")
        print("检测到活动的 Team 模式，你作为 Team Lead 不能直接修改代码。")
        print("")
        print("请执行以下步骤：")
        print("  1. 使用 TaskCreate 创建任务")
        print("  2. 使用 Task 分配给合适的 teammate")
        print("  3. 使用 SendMessage 告知具体需求")
        print("")
        print("如需手动编辑，请先关闭 team 或删除 team 配置。")
        print("")
        print("=" * 42)
        sys.exit(2)

    # 未检测到 team-lead 模式，允许操作
    sys.exit(0)

if __name__ == "__main__":
    main()
