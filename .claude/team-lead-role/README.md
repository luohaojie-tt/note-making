# Team Lead Role Skill

自动检测 Team Lead 模式并强制禁止直接修改代码。

---

## 快速安装（3 步）

### 步骤 1：复制文件到目标项目

```bash
# 复制到目标项目的 .claude 目录
cp -r team-lead-role/skills/* /path/to/项目/.claude/skills/
cp -r team-lead-role/hooks/* /path/to/项目/.claude/hooks/
```

### 步骤 2：添加 hooks 配置

在项目的 `.claude/settings.json` 中添加：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/check-team-lead-role.py"
          }
        ]
      }
    ]
  }
}
```

### 步骤 3：完成

现在当你创建 team 时，Team Lead 会自动被禁止直接修改代码。

---

## 工作原理

| 状态 | 行为 |
|------|------|
| 有活动的 team | Edit/Write 自动被拦截 |
| 无活动的 team | 正常编辑 |

---

## 手动控制（可选）

```bash
# 强制启用
touch .claude/hooks/.team-lead-mode

# 强制禁用
rm .claude/hooks/.team-lead-mode
```

---

## 文件说明

```
team-lead-role/
├── skills/
│   └── team-lead-role.md      # 复制到 .claude/skills/
├── hooks/
│   └── check-team-lead-role.py # 复制到 .claude/hooks/
└── README.md                   # 本文件
```

---

## 触发 Skill

```
/skill team-lead-role
```

或在 team 模式下自动生效。
