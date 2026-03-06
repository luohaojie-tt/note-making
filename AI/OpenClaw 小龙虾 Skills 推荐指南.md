---
title: OpenClaw 小龙虾 Skills 推荐指南
date: 2026-03-06
tags:
  - AI
  - OpenClaw
  - Skills
  - Agent
  - 自动化
aliases:
  - 小龙虾机器人
  - OpenClaw 技能推荐
cssclasses:
  - callout
---

# OpenClaw 小龙虾 Skills 推荐指南

> [!info] 关于 OpenClaw
> OpenClaw（小龙虾）是一个开源的 **AI 数字员工** 框架，用户在 WhatsApp/Telegram/微信/飞书等聊天工具中与它对话，它就能帮你干活：收发邮件、管理日历、写代码、整理文件等。
>
> - GitHub 十万级 Stars，史上增长最快的开源项目之一
> - 1715+ 技能可用
> - 24小时自主运行，能自我进化

---

## ⭐ 必装 Skills (Top 10)

| 排名  | Skill                    | 功能                                   | 安装命令                                              |
| --- | ------------------------ | ------------------------------------ | ------------------------------------------------- |
| 1   | **tavily-search**        | 联网搜索 (无需绑信用卡，每月1000次免费)              | `npx clawhub@latest install tavily-search`        |
| 2   | **find-skills**          | 让龙虾自己搜并安装需要的技能                       | `npx clawhub@latest install find-skills`          |
| 3   | **proactive-agent**      | 给AI加主动性和自我迭代能力                       | `npx clawhub@latest install proactive-agent`      |
| 4   | **github**               | GitHub集成 (管repo/issue/PR)            | `npx clawhub@latest install github`               |
| 5   | **gog**                  | Google Workspace全家桶 (Gmail/日历/Drive) | `npx clawhub@latest install gog`                  |
| 6   | **skill-vetter**         | 安装前扫描安全，防恶意代码                        | `npx clawhub@latest install skill-vetter`         |
| 7   | **automation-workflows** | 工作流编排，串联多个技能                         | `npx clawhub@latest install automation-workflows` |
| 8   | **self-improving-agent** | 加记忆+自我优化，越用越聪明                       | `npx clawhub@latest install self-improving-agent` |
| 9   | **feishu-doc**           | 飞书文档/云盘集成 (国内用户)                     | `npx clawhub@latest install feishu-doc`           |
| 10  | **bird**                 | X/Twitter集成 (慎用，注意安全)                | `npx clawhub@latest install bird`                 |

---

## 🔥 3个有意思的 Skill (社区推荐)

### 1. Tavily 搜索 - 让龙虾能上网

> [!tip] 新手第一个该装的 Skill
> 龙虾默认推荐的搜索是 Brave API，但 Brave 需要绑信用卡。Tavily 不一样！

**特点**：
- 不用绑信用卡，每月 **1000次免费**
- 专为 AI Agent 设计，返回结构化数据
- 支持深度搜索、新闻过滤、网页提取

```bash
# 安装
npx clawhub@latest install tavily

# 设置 API Key
# 1. 去 tavily.com 注册拿 API Key
# 2. 设到环境变量 TAVILY_API_KEY
```

---

### 2. David's Filetranslator - 文档翻译

> [!example] 作者自制私货
> 一个文档翻译智能体，麻雀虽小五脏俱全

**支持格式**：`docx` / `xlsx` / `pptx` / `pdf`

**工作流程**：
```
文档解析 → 抽取术语 → 翻译术语 → 锁定术语翻译 → QA检查 → 输出原格式译文
```

```bash
# GitHub 地址 (已开源)
https://github.com/ShaohuaDavidLee/David-filetranslator
```

---

### 3. NoizAI 语音 - 让龙虾开口说话

> [!quote] 从"只会打字"变成"能开口说话"

**能力**：
- 基础 TTS 文字转语音
- 角色化语音 (调节情绪/语气/风格)
- 声音克隆 (模仿参考音频)
- 视频翻译配音

```bash
# 安装
npx skills add NoizAI/skills --full-depth --skill tts -y

# 本地优先 (Kokoro 引擎)
# 云端效果更好: developers.noiz.ai 拿 API Key
```

---

## 📦 Skills 资源来源

| 来源 | 链接 | 说明 |
|------|------|------|
| **ClawHub** | [clawhub.ai](https://clawhub.ai) | 官方市场，13,000+ Skills |
| **Awesome-openclaw-skills** | [GitHub](https://github.com/VoltAgent/awesome-openclaw-skills) | 精选1,715个，过滤垃圾和恶意 |
| **LobeHub** | [lobehub.com/skills](https://lobehub.com/skills) | 界面友好，有详细说明 |
| **Playbooks** | [playbooks.com/skills](https://playbooks.com/skills) | 技术文档风格 |

---

## 🚀 一键安装脚本

```bash
# ========== 安全优先 ==========
# 先装安全扫描
npx clawhub@latest install skill-vetter

# ========== 核心能力 ==========
npx clawhub@latest install tavily-search
npx clawhub@latest install find-skills
npx clawhub@latest install proactive-agent

# ========== 办公集成 ==========
npx clawhub@latest install github
npx clawhub@latest install gog        # 海外
npx clawhub@latest install feishu-doc # 国内

# ========== 进阶能力 ==========
npx clawhub@latest install self-improving-agent
npx clawhub@latest install automation-workflows
```

---

## 📖 Skills 安装三种方式

### 方式 1：ClawHub 官方市场

```bash
npx clawhub@latest install <skill名>
```

### 方式 2：自然语言对话

> [!tip] 最简单的方式
> 把 Skill 的 GitHub 链接直接丢给龙虾，它会自动安装

### 方式 3：下载安装包

1. 下载 skill zip 包
2. 解压到 OpenClaw skills 目录
3. 重启 OpenClaw

---

## ⚠️ 安全提醒

> [!warning] 注意恶意 Skill
> 社区 Skill 生态很大但也很散，安装前建议：
> 1. 先装 `skill-vetter` 或 `clawsec` 扫描安全
> 2. 从精选列表 ([Awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills)) 开始
> 3. 慎用高赞的 "Twitter" 相关 Skill（有伪装恶意版）

---

## 相关链接

- [[OpenCode 完整命令手册]]
- [[Claude Code 完整命令手册]]
- [[Claude Code Memory MCP 使用指南]]

---

## Sources

- [OpenClaw最受欢迎的10个小龙虾skills安装](https://www.cnblogs.com/cczlovexw/p/19664202)
- [OpenClaw系列｜推荐3个有意思的skill](https://www.53ai.com/news/Openclaw/2026030583450.html)
- [Awesome-openclaw-skills (GitHub)](https://github.com/VoltAgent/awesome-openclaw-skills)

---

> [!note] 更新日期
> 2026-03-06
