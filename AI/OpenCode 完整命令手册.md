---
title: OpenCode 完整命令手册
date: 2026-03-01
tags:
  - AI
  - OpenCode
  - CLI
  - 速查表
aliases:
  - OpenCode 命令
  - OpenCode CLI
cssclasses:
  - callout
---

# OpenCode 完整命令手册

> [!info] 关于 OpenCode
> OpenCode 是一个基于终端的 **AI 编程助手**，类似于 Claude Code 的 CLI 版本，可以直接在命令行中交互、分析代码库、回答问题并修改文件。

---

## 1. 安装方式

```bash
# 方式1：官方脚本安装
curl -fsSL https://opencode.ai/install | bash

# 方式2：NPM 安装
npm install -g opencode-ai@latest
```

---

## 2. CLI 终端命令

| 命令 | 说明 | 场景 |
|-----|------|------|
| `opencode` | 启动交互式 TUI 界面 | 日常使用 |
| `opencode [project]` | 启动 TUI 并指定项目目录 | 多项目管理 |
| `opencode run "指令"` | 非交互模式，直接运行指令 | CI/CD 自动化 |
| `opencode serve` | 启动 headless 服务器 | 后台服务 |
| `opencode web` | 启动 Web 界面 | 浏览器使用 |
| `opencode auth login` | 登录/配置 AI 模型提供商 | 首次配置 |
| `opencode session list` | 列出所有会话 | 查看历史 |
| `opencode export [sessionID]` | 导出会话为 JSON | 备份分享 |
| `opencode import <file/url>` | 导入会话 | 恢复会话 |
| `opencode stats` | 显示用量统计 | 查看消耗 |
| `opencode models` | 列出可用模型 | 选择模型 |
| `opencode models --refresh` | 刷新模型缓存 | 更新模型 |
| `opencode --help` | 查看帮助文档 | 忘了就敲它 |

---

## 3. TUI 内部命令 (Slash Commands)

### 📁 会话管理

| 命令 | 快捷键 | 说明 |
|-----|--------|------|
| `/help` | `Ctrl+X H` | 显示帮助 |
| `/new` | `Ctrl+X N` | 开始新会话 |
| `/sessions` | `Ctrl+X L` | 列出/切换会话 |
| `/share` | `Ctrl+X S` | 分享当前会话（生成链接） |
| `/unshare` | - | 取消分享会话 |
| `/export` | `Ctrl+X X` | 导出对话到 Markdown |
| `/exit` | `Ctrl+X Q` | 退出 |

### 🔧 项目与配置

| 命令 | 快捷键 | 说明 |
|-----|--------|------|
| `/init` | `Ctrl+X I` | 创建/更新 AGENTS.md 文件 |
| `/connect` | - | 添加 API 提供商 |
| `/models` | `Ctrl+X M` | 列出可用模型并切换 |
| `/themes` | `Ctrl+X T` | 列出可用主题 |

> [!tip] `/init` 详解
> 自动分析项目结构，生成 AGENTS.md 文件：
> - 识别项目类型（前端/后端/全栈）
> - 提取技术栈信息
> - 生成项目说明供 AI 理解

### 📝 编辑与操作

| 命令 | 快捷键 | 说明 |
|-----|--------|------|
| `/undo` | `Ctrl+X U` | 撤销上一步操作 |
| `/redo` | `Ctrl+X R` | 重做已撤销的操作 |
| `/editor` | `Ctrl+X E` | 打开外部编辑器 |
| `/open` | - | 搜索并打开文件 |

### 🎯 工作流控制

| 命令 | 快捷键 | 说明 |
|-----|--------|------|
| `/compact` | `Ctrl+X C` | 压缩当前会话（节省上下文） |
| `/details` | `Ctrl+X D` | 切换工具执行详情显示 |
| `/thinking` | - | 切换思考/推理过程可见性 |
| `/review` | - | 审查代码变更 |
| `/mcp` | - | 开启或关闭 MCP |
| `/agent` | - | 选择/切换 Agent |
| `/terminal` | - | 显示或隐藏终端 |

---

## 4. Plan/Build 双模式

> [!important] 核心工作流
> OpenCode 有两种工作模式，按 `Tab` 键切换：

| 模式 | 说明 | 适用场景 |
|-----|------|---------|
| **Plan 模式** | AI 只分析项目、规划任务，不修改文件 | 先出方案 |
| **Build 模式** | AI 会真正修改代码 | 确定方案后执行 |

**推荐流程**：
```
Plan 模式出方案 → 确认满意 → Tab 切换 Build 模式 → 执行
```

---

## 5. 特殊操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `@` | 引用文件 | `@src/index.ts 看看这个文件` |
| `!` | 运行 bash 命令 | `!ls -la` |
| `Tab` | 切换 Plan/Build 模式 | - |

> [!example] 使用示例
> ```
> @src/App.tsx 帮我重构这个组件
> !npm test 运行测试看看结果
> ```

---

## 6. AI Agent 团队

| Agent | 角色 | 用途 |
|-------|------|------|
| **Sisyphus** | 总指挥 | 默认干活，全能型 |
| **Oracle** | 架构师 | 设计架构、调试难题 |
| **Librarian** | 图书管理员 | 查文档、找资料 |
| **Explore** | 探索者 | 快速搜索代码 |
| **Frontend Engineer** | 前端工程师 | 写界面 |

> [!tip] 调用方式
> ```
> @oracle 帮我看看这个架构合不合理
> @librarian 查一下 React 18 的新特性
> @explore 找找项目里的认证逻辑
> ```

---

## 7. 魔法关键词

| 关键词 | 作用 | 说明 |
|--------|------|------|
| `ulw` | 全力模式 | 干到完事 |
| `ultrathink` | 深度思考 | 使用更多推理 |
| `search` / `find` | 搜索模式 | 全力搜索 |
| `analyze` | 分析模式 | 深度分析 |

> [!example] 使用示例
> ```
> ulw 帮我把这个功能做完
> ultrathink 分析一下这个性能问题
> search 找出所有使用 useEffect 的地方
> ```

---

## 8. 配置文件路径

| 系统 | 路径 |
|-----|------|
| Linux/macOS | `~/.config/opencode/opencode.json` |
| Windows | `C:\Users\<用户名>\.config\opencode\opencode.json` |

---

## 9. 与 Claude Code 对比

| 功能 | OpenCode | Claude Code |
|-----|----------|-------------|
| 启动命令 | `opencode` | `claude` |
| 配置文件 | `AGENTS.md` | `CLAUDE.md` |
| 模式切换 | Plan/Build (Tab) | 无 |
| Agent 系统 | 内置 5 个角色 | 需手动配置 |
| MCP 支持 | ✅ | ✅ |
| Web 界面 | ✅ `opencode web` | ❌ |
| 非交互模式 | ✅ `opencode run` | ❌ |

---

## 10. 使用口诀

> [!success] 快速记忆
> 1. 启动项目 → `opencode [目录]`
> 2. 出方案 → Plan 模式
> 3. 执行代码 → Build 模式 (Tab 切换)
> 4. 调专家 → `@oracle` `@librarian`
> 5. 加把劲 → `ulw` `ultrathink`

---

## 相关链接

- [[Claude Code 完整命令手册]]
- [[AI 编程助手对比]]
- [OpenCode 官网](https://opencode.ai/)
- [OpenCode GitHub](https://github.com/opencode-ai/opencode)

---

> [!note] 更新日期
> 2026-03-01
