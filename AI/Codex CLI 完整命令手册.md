---
title: Codex CLI 完整命令手册
date: 2026-03-01
tags:
  - AI
  - Codex
  - OpenAI
  - CLI
  - 速查表
aliases:
  - Codex 命令
  - OpenAI Codex
  - Codex CLI
cssclasses:
  - callout
---

# Codex CLI 完整命令手册

> [!info] 关于 Codex CLI
> Codex CLI 是 **OpenAI 开源的终端编程助手**，使用 Rust 编写。它可以读取、修改和执行代码，直接与本地文件系统交互。

---

## 1. 安装方式

```bash
# 通过 npm 安装 (推荐)
npm install -g @openai/codex

# 通过 Homebrew 安装 (macOS)
brew install codex

# 更新到最新版本
npm install -g @openai/codex@latest
```

---

## 2. 配置 API Key

### 方式 1：环境变量

```bash
# Linux/macOS
export OPENAI_API_KEY="your-api-key-here"

# Windows
set OPENAI_API_KEY=your-api-key-here
```

### 方式 2：配置文件

创建 `~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "sk-your-api-key"
}
```

---

## 3. CLI 启动命令

| 命令 | 说明 |
|-----|------|
| `codex` | 启动交互模式 |
| `codex "你的指令"` | 带初始指令启动 |
| `codex --model gpt-5-codex` | 指定模型 |
| `codex --approval-mode full-auto` | 全自动模式 |
| `codex --image <path>` | 附带图片 |
| `codex --oss` | 使用本地开源模型 (需 Ollama) |
| `codex --profile <name>` | 加载配置文件 |
| `codex --cd <path>` | 设置工作目录 |

---

## 4. Slash 斜杠命令

### 📁 会话与流程控制

| 命令 | 功能 |
|-----|------|
| `/new` | 新建会话，清空上下文 |
| `/undo` | 撤销上一步操作 (文件修改/命令执行) |
| `/exit` 或 `/quit` | 退出 CLI |
| `/logout` | 登出账号，清除本地认证 |
| `/compact` | 压缩对话为总结，释放上下文 |

### 🔧 配置与权限管理

| 命令 | 功能 |
|-----|------|
| `/approvals` | 设置权限模式 |
| `/model` | 切换模型和推理强度 |

> [!tip] `/approvals` 权限模式
> | 模式 | 说明 |
> |-----|------|
> | **Auto** (建议) | 审查后应用更改 |
> | **Read Only** | 只读，不修改文件 |
> | **Full Access** | 全自动，无需确认 |

### 📝 代码与文件操作

| 命令 | 功能 |
|-----|------|
| `/review` | 审查当前工作目录的代码改动 |
| `/diff` | 查看 git diff，包括未跟踪文件 |
| `/init` | 生成 `AGENTS.md` 模板文件 |
| `/mention <file>` | 将文件/目录加入上下文重点参考 |

### 📊 状态与扩展

| 命令 | 功能 |
|-----|------|
| `/status` | 查看会话状态：模型、审批策略、token 使用 |
| `/mcp` | 列出已配置的 MCP 工具 |
| `/prompts` | 触发自定义 prompts |
| `/skills` | 触发自定义 skills |

---

## 5. 任务类型 (Agents)

| 类型 | 说明 |
|-----|------|
| **Local Tasks** | 在本机直接运行，与本地文件系统交互 |
| **Sandbox 沙箱** | Mac/Linux 默认启用，限制文件访问和命令权限 |
| **Cloud Tasks** | 多任务并行，自动克隆 GitHub 仓库，隔离环境运行 |

---

## 6. 接口方式

| 接口 | 说明 |
|-----|------|
| **CLI** | 终端交互 |
| **IDE Extension** | VS Code、Cursor、Windsurf 扩展 |
| **Web** | [chatgpt.com/codex](https://chatgpt.com/codex) |
| **Mobile** | ChatGPT iOS 应用 |
| **SDK** | API 库、GitHub Action 集成 CI/CD |

---

## 7. 安全模式

> [!warning] 权限控制
> Codex 提供三种安全模式：

| 模式 | 文件修改 | 命令执行 | 适用场景 |
|-----|---------|---------|---------|
| **Suggest** (默认) | 需确认 | 需确认 | 日常开发 |
| **Auto-Edit** | 自动 | 需确认 | 快速迭代 |
| **Full-Auto** | 自动 | 自动 | CI/CD 自动化 |

---

## 8. 自定义扩展

### AGENTS.md 项目说明书

在项目根目录创建 `AGENTS.md`：

```markdown
# 项目说明

## 技术栈
- React + TypeScript
- Tailwind CSS
- Vite

## 代码规范
- 使用 ESLint + Prettier
- 组件使用函数式写法

## 注意事项
- 不要修改 config/ 目录
- 测试覆盖率要求 80%+
```

### 自定义 Slash 命令

在 `~/.codex/prompts/` 目录下创建 `.md` 文件：

```markdown
<!-- review-security.md -->
审查代码中的安全漏洞：
1. 检查 SQL 注入
2. 检查 XSS 漏洞
3. 检查敏感信息泄露
4. 检查认证授权问题
```

使用：`/review-security`

---

## 9. 与其他工具对比

| 功能 | Codex CLI | Claude Code | OpenCode |
|-----|-----------|-------------|----------|
| 开发者 | OpenAI | Anthropic | 社区 |
| 配置文件 | `AGENTS.md` | `CLAUDE.md` | `AGENTS.md` |
| 模型 | GPT-5-codex | Claude 4.6 | 多模型 |
| Web 界面 | ✅ | ❌ | ✅ |
| MCP 支持 | ✅ | ✅ | ✅ |
| 沙箱模式 | ✅ | ❌ | ❌ |
| Cloud Tasks | ✅ | ❌ | ❌ |

---

## 10. 使用口诀

> [!success] 快速记忆
> 1. 启动项目 → `codex`
> 2. 切换模型 → `/model`
> 3. 权限控制 → `/approvals`
> 4. 撤销操作 → `/undo`
> 5. 查看状态 → `/status`

---

## 相关链接

- [[Claude Code 完整命令手册]]
- [[OpenCode 完整命令手册]]
- [[AI 编程助手对比]]
- [Codex 官方文档](https://developers.openai.com/codex/cli)
- [Codex GitHub](https://github.com/openai/codex)

---

> [!note] 更新日期
> 2026-03-01
