---
title: Claude Code 完整命令手册与官方插件清单
date: 2026-03-01
tags:
  - AI
  - Claude Code
  - 速查表
aliases:
  - Claude Code 命令
  - Claude 插件清单
cssclasses:
  - callout
---

# Claude Code 完整命令手册与官方插件清单

> [!info] 关于本文档
> 一份 Obsidian 速查表，涵盖：
> 1. Claude Code 所有 `/` 命令
> 2. claude-plugins-official 仓库 40 个官方插件
>
> 随用随查，无需再翻截图。

---

## 1. Claude Code `/` 命令速查

### 📁 工作区与项目

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/add-dir` | 把新目录加入工作区 | 多 repo 切换 |
| `/init` | 生成 CLAUDE.md 项目说明模板 | 让 Claude 读懂代码 |
| `/resume` | 继续历史对话 | 昨天没聊完 |

> [!tip] `/add-dir` 详解
> 多 repo 切换 = 你本地同时有多个 Git 仓库。
> - 把常用仓库"挂"进工作区
> - 读/写不同仓库的文件
> - 跨仓库跑脚本、查日志
> - 不用重启 Claude，不用 cd 来 cd 去

### 🤖 Agent 与自动化

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/agents` | 管理 Agent 配置 | 自建 Agent 时 |
| `/hooks` | 管理工具事件钩子 | CI 集成 |
| `/tasks` | 后台异步任务列表 | 索引大工程 |

> [!example] `/hooks` 钩子用途
> - `before_tool_call` – 每次调用工具前
> - `after_tool_call` – 工具跑完后
> - `on_error` – 工具报错时
>
> **常见用途**：
> 1. 自动通知 – Claude 一 push 代码，webhook 到群里
> 2. 自动质量门 – 单测后触发 CI 部署
> 3. 审计日志 – 记录每次工具调用

> [!info] `/tasks` 后台任务
> 典型任务类型：
> - `index-repo` – 把整仓代码做成向量索引
> - `batch-lint` – 一次性跑全仓库 linter
> - `embedding` – 生成向量表示用于语义搜索
> - `crawl-docs` – 爬官方文档并建搜索索引

### 💬 对话与上下文

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/clear` | 清对话历史，释放上下文 | Token 快满 |
| `/compact [提示]` | 先摘要再清历史 | 省 Token 又保留梗概 |
| `/context` | 当前上下文格子图 | 可视化 token 占用 |
| `/export` | 导出当前对话为 md 或剪贴板 | 写周报/留档 |
| `/rename` | 改对话标题 | 左侧栏好找 |
| `/rewind` | 回档到上一检查点 | 改崩了 |

### 🔧 设置与配置

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/config` | 图形设置面板 | 改主题/快捷键 |
| `/model` | 切 Opus/Sonnet/Haiku | 要省 or 要智商 |
| `/output-style` | 回答风格菜单 | 教学/简洁/列表 |
| `/permissions` | 工具权限白名单 | 怕插件乱动文件 |
| `/theme` | 命令行换主题 | 一句话切黑夜 |
| `/vim` | 输入框 Vim 模式 | 键盘党 |
| `/terminal-setup` | 绑 Shift+Enter 换行 | 多行提示词 |

> [!tip] `/output-style` 风格选项
> 1. **教学式** – 每步都解释"为什么"
> 2. **简洁** – 只给结论和关键命令
> 3. **列表** – 用 bullet 把要点列出来
> 4. **详细** – 背景+步骤+注意事项
> 5. **混合** – 先摘要，再展开细节

> [!warning] `/permissions` 权限控制
> - 哪些插件只能读、不能写
> - 哪些目录完全禁止任何插件碰
> - 哪些文件类型（如 `*.key`, `*.env`）全局只读
>
> **场景**：
> - 怕误动 `.env` → 把 `*.env` 设为 deny
> - 多人共用 → 只允许在指定目录动代码

### 🔌 插件与集成

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/plugin` | 启停卸载插件 | 太多拖慢启动 |
| `/mcp` | 管理外部 MCP 服务器 | 私有工具链 |
| `/skills` | 列可用技能包 | 一键宏命令 |
| `/ide` | 管理 VS Code/JetBrains 插件 | 看连没连上 |

### 🐙 GitHub 与协作

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/install-github-app` | 给仓库装 GitHub Actions | PR 自动评论 |
| `/install-slack-app` | 把 Claude 机器人装 Slack | 团队 IM 问问题 |
| `/pr-comments` | 拉取 PR 全部 review 评论 | 汇总意见 |
| `/review` | AI 级 PR review | push 后过一遍 |
| `/security-review` | 扫未提交 diff 的安全风险 | merge 前 |

> [!example] `/install-github-app` 效果
> 1. 把 "Claude GitHub App" 安装到指定仓库
> 2. 自动放一条 GitHub Actions 工作流文件
>
> **结果**：每份 PR 都会多一条 AI 评审意见，像 CI 检查一样自动跑。

> [!example] `/install-slack-app` 效果
> - 在任何频道 **@Claude** 提问
> - 私聊结果只有你看得到
> - 支持上传代码片段、日志分析

### 📊 状态与统计

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/cost` | 本会话已花美元+耗时 | 好奇烧了多少 |
| `/doctor` | 一键体检安装问题 | 突然失效 |
| `/status` | 轻量状态：版本/账号/插件 | 快速确认 |
| `/stats` | 个人用量统计 | 月度复盘 |
| `/usage` | 看周期剩余调用量 | 快月底 |
| `/release-notes` | 当前版本更新日志 | 升级后看新功能 |

### 🛠 其他工具

| 命令 | 说明 | 场景 |
|-----|------|------|
| `/chrome` | 开关 Claude in Chrome 侧边栏 | 网页随时问 |
| `/feedback` | 发 bug/建议给官方 | 遇到离谱问题 |
| `/help` | 列出所有可用命令 | 忘了就敲它 |
| `/login` `/logout` | 切换账号 | 公用电脑 |
| `/memory` | 增删改长期记忆 | 跨会话记得你是谁 |
| `/mobile` | 扫码下手机 App | 安利同事 |
| `/plan` | 查看/编辑任务计划 | 多步骤重构 |
| `/todos` | 看 plan 还剩几条 | 快速瞄一眼 |
| `/statusline` | 开关底部状态条 | 极简党 |
| `/upgrade` | 跳付费页升 Max | 额度用完 |
| `/stickers` | 订贴纸周边 | 粉丝向 |
| `/exit` | 退出 REPL | 命令行模式用完 |

---

## 2. claude-plugins-official 插件清单

### 🔤 语言服务器 (LSP)

| 插件 | 语言 | 必备程度 |
|-----|------|---------|
| `clangd-lsp` | C/C++ 补全+跳转+实时报错 | 写 C/C++ |
| `csharp-lsp` | C# 补全重构 | .NET 开发 |
| `gopls-lsp` | Go 补全重构 | 写 Go 就装 |
| `jdtls-lsp` | Java 补全诊断 | Java 后端/Android |
| `kotlin-lsp` | Kotlin 补全 | Android |
| `lua-lsp` | Lua 补全 | 游戏脚本/Nginx |
| `php-lsp` | PHP 补全 | 写 PHP 就装 |
| `pyright-lsp` | Python 静态类型检查 | 用 type hint |
| `rust-analyzer-lsp` | Rust 补全分析 | Rust 必备 |
| `swift-lsp` | Swift 补全 | iOS/macOS 开发 |
| `typescript-lsp` | TS/JS 补全+类型 | 前端/Node 必备 |

### 🔗 平台集成

| 插件 | 平台 | 功能 |
|-----|------|------|
| `github` | GitHub | 官方全套集成 ⭐ |
| `gitlab` | GitLab | 官方全套集成 |
| `asana` | Asana | 建任务、改进度、看甘特 |
| `atlassian` | Jira/Confluence | 搜票读 wiki |
| `figma` | Figma | 读/写文件、拿色标 |
| `firebase` | Firebase | 操作 Firestore/Auth/Storage |
| `linear` | Linear | 任务管理 |
| `notion` | Notion | 搜页面、写数据库、建看板 |
| `sentry` | Sentry | 读报错自动建工单 |
| `slack` | Slack | 发消息、搜频道、建线程 |
| `stripe` | Stripe | 调 API 订单账单 |
| `supabase` | Supabase | 操作数据库与 Auth |
| `vercel` | Vercel | 一键部署看日志 |

### 🛠 开发工具

| 插件 | 功能 | 谁最需要 |
|-----|------|---------|
| `agent-sdk-dev` | 调试 Claude Agent SDK 脚手架 | 写插件的人 |
| `code-review` | 多语言 linter 自动 PR 评论 | 开源维护者 |
| `commit-commands` | git commit→push→PR 一条龙 | 懒人 git 流 |
| `feature-dev` | 需求→设计→代码→单测→文档 模板 | 独立开发者 |
| `frontend-design` | 一句话生成 Tailwind+React 页面 | 快速 UI 原型 |
| `greptile` | 自然语言搜整个代码库 | 大项目考古 |
| `hookify` | 一键 Class→React Hooks | 老项目升级 |
| `laravel-boost` | Laravel 路由模型迁移生成 | PHP Laravel |
| `playwright` | 浏览器自动化端到端测试 | 前端 UI 测试 |
| `plugin-dev` | 开发 Claude 插件脚手架 | 贡献市场 |
| `pr-review-toolkit` | 多 linter 汇总 PR 评论 | AI 人工 review |
| `ralph-wiggum` | 自嘲式无限反问找逻辑漏洞 | 复杂算法调试 |
| `security-guidance` | 每段代码插安全提醒 | 怕写漏注入 |

### 📚 输出风格

| 插件 | 风格 | 适合 |
|-----|------|------|
| `explanatory-output-style` | 每段代码附"为什么" | 教学/学习 |
| `learning-output-style` | 边写代码边提问帮你学 | 编程初学者 |

### 🔍 代码理解

| 插件 | 功能 | 谁最需要 |
|-----|------|---------|
| `serena` | 语义级代码摘要 | 读别人代码提速 |
| `context7` | 查 Upstash 最新技术文档 | 要"当前最新"文档 |

> [!tip] serena 语义级摘要
> 不只是"把代码逐行翻译"，而是理解函数/类的真实意图。
>
> **例子**：
> ```go
> func CheckRetry(err error, count int) bool {
>     if count > 3 { return false }
>     if _, ok := err.(NetError); ok { return true }
>     return false
> }
> ```
> - 传统摘要："如果 count 大于 3 返回 false..."
> - 语义摘要："网络请求失败时最多重试 3 次"

---

## 3. 使用口诀

> [!success] 快速记忆
> 1. 命令忘了 → `/help`
> 2. Token 告警 → `/compact` 或 `/clear`
> 3. 装插件原则 → "用什么语言装什么 LSP，用什么平台装什么集成"
> 4. 跑前体检 → `/doctor`
> 5. 事后复盘 → `/cost` + `/stats`

---

## 相关链接

- [[Claude Code Memory MCP 使用指南]]
- [[Obsidian Skills 概览]]
- [[MCP 服务器配置]]
- [Claude Code 官方文档](https://docs.anthropic.com/claude-code)

---

> [!note] 更新日期
> 2026-03-01
