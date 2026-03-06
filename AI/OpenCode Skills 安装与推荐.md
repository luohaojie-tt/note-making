---
title: OpenCode Skills 安装与推荐
date: 2026-03-01
tags:
  - AI
  - OpenCode
  - Skills
  - 教程
aliases:
  - OpenCode 技能
  - OpenCode 插件
cssclasses:
  - callout
---

# OpenCode Skills 安装与推荐

> [!info] 关于 Skills
> Skills 是 OpenCode 的扩展功能，可以为 AI 添加专业技能，如代码审查、PDF 处理、API 测试等。

---

## 1. Skills 目录结构

| 类型 | 路径 |
|-----|------|
| **全局 Skills** | `~/.config/opencode/skills/` |
| **项目 Skills** | `.opencode/skills/` (项目根目录) |

---

## 2. 安装方法

### 方法 1：命令行安装

```bash
# 列出可用 skills
npx skills list

# 搜索 skills
npx skills find [关键词]

# 安装 Vercel Labs 的 skills
npx add-skill vercel-labs/agent-skills -a opencode -g

# 安装特定 skill
npx add-skill vercel-labs/agent-skills -s vercel-react-best-practices -a opencode -g
```

### 方法 2：从 GitHub 安装

```bash
# 克隆官方 skills 仓库
git clone https://github.com/anthropics/skills.git

# 复制到 OpenCode skills 目录
cp -r skills/skill-creator ~/.config/opencode/skills/
```

### 方法 3：手动安装

1. 下载 skill zip 包
2. 解压到 `~/.config/opencode/skills/` 目录
3. 重启 OpenCode

### 方法 4：自定义命令

> [!tip] 创建自定义命令
> 在 `~/.config/opencode/commands/` 创建 Markdown 文件：

```markdown
<!-- prime-context.md -->
分析当前项目结构，加载所有相关上下文，准备开始工作。
```

---

## 3. 推荐 Skills (2026)

### ⭐ 必装 Skills

| Skill              | 功能        | 推荐理由  |
| ------------------ | --------- | ----- |
| **oh-my-opencode** | 增强体验      | 社区最推荐 |
| **Superpowers**    | 代码审查+架构设计 | 功能全面  |
| **skill-creator**  | 创建新 skill | 官方出品  |

### 🔥 热门 Skills Top 10

| 排名 | Skill | 功能 | Stars |
|-----|-------|------|-------|
| 1 | **UniversalCodeReviewer** | 跨语言代码审查 (安全/性能/风格) | 4.8k |
| 2 | **cache-components** | Next.js 缓存组件优化 | 3.9k |
| 3 | **PDF Master** | PDF 合并/拆分/提取/OCR/签名 | 3.6k |
| 4 | **LangChain-CR-Pro** | LLM 应用代码审查 | 3.2k |
| 5 | **TeamStyleEnforcer** | 团队代码规范守护 | 2.7k |
| 6 | **SVG Animator Pro** | 一键生成交互式 SVG | 2.5k |
| 7 | **Super Analyst** | 12 种分析框架 (SWOT, 第一性原理) | 2.3k |
| 8 | **API Tester Pro** | 自动生成测试用例 + 断言 | 2.1k |
| 9 | **PPT Generator Max** | 文本 → 多页 PPT | 1.9k |
| 10 | **ui-ux-pro-max** | UI/UX 优化 | - |

---

## 4. Skills 分类

### 📝 文档处理

| Skill | 功能 |
|-------|------|
| PDF Master | PDF 合并/拆分/提取/OCR/签名 |
| PPT Generator Max | 文本 → 多页 PPT |

### 🔍 代码质量

| Skill | 功能 |
|-------|------|
| UniversalCodeReviewer | 跨语言代码审查 |
| TeamStyleEnforcer | 团队代码规范 |
| LangChain-CR-Pro | LLM 应用代码审查 |

### 🧪 测试

| Skill | 功能 |
|-------|------|
| API Tester Pro | 自动生成测试用例 + 断言 + Mocks |

### 🎨 设计

| Skill | 功能 |
|-------|------|
| SVG Animator Pro | 交互式 SVG 生成 |
| ui-ux-pro-max | UI/UX 优化 |

### 📊 分析

| Skill | 功能 |
|-------|------|
| Super Analyst | 12 种分析框架 |
| cache-components | Next.js 性能优化 |

---

## 5. Skills 资源

| 资源 | 链接 | 说明 |
|-----|------|------|
| SkillsMP.com | https://skillsmp.com | 最大 skills 市场 |
| Smithery.ai | https://smithery.ai | 透明数据 |
| skills.sh | https://skills.sh | 开放 Agent Skills 目录 |
| Anthropic 官方 | [GitHub](https://github.com/anthropics/skills) | 质量基准 |

---

## 6. 快速开始

> [!example] 安装第一个 Skill
> ```bash
> # 1. 安装 skill-creator
> npx add-skill vercel-labs/agent-skills -s skill-creator -a opencode -g
>
> # 2. 重启 OpenCode
> opencode
>
> # 3. 使用 skill
> /skill-creator 帮我创建一个代码审查 skill
> ```

---

## 7. 与 Claude Code Skills 对比

| 功能 | OpenCode | Claude Code |
|-----|----------|-------------|
| Skills 目录 | `~/.config/opencode/skills/` | `~/.claude/skills/` |
| 安装命令 | `npx add-skill` | `/plugin install` |
| 市场支持 | SkillsMP, Smithery | 官方 marketplace |
| 自定义命令 | `commands/` 目录 | hooks + skills |

---

## 相关链接

- [[OpenCode 完整命令手册]]
- [[Claude Code 完整命令手册]]
- [[AI 编程助手对比]]

---

> [!note] 更新日期
> 2026-03-01
