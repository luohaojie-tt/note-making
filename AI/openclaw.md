---
title: OpenClaw
date: 2026-03-05
tags:
  - AI
  - tool
  - agent
aliases:
  - openclaw
---

# OpenClaw

OpenClaw 是一个 AI Agent 工具，提供 Gateway、Canvas 和 Browser Control 等服务。

## 服务地址

| 服务            | 地址                                         |
| --------------- | -------------------------------------------- |
| Gateway         | `ws://127.0.0.1:18789`                       |
| Canvas          | `http://127.0.0.1:18789/__openclaw__/canvas/` |
| Browser Control | `http://127.0.0.1:18791/`                    |
| Agent Model     | `zai/glm-4.7`                                |

> [!info] 日志文件
> `\tmp\openclaw\openclaw-2026-03-05.log`

## 常用命令

Gateway 正在后台运行时，可以使用以下命令：

| 命令                   | 说明     |
| -------------------- | ------ |
| `openclaw dashboard` | 打开控制面板 |
| `openclaw tui`       | 打开终端界面 |
| `openclaw status`    | 查看运行状态 |

## Gateway 启动与停止

| 命令                      | 说明             |
| ----------------------- | -------------- |
| `openclaw gateway`      | 启动 Gateway 服务  |
| `openclaw gateway -d`   | 后台模式启动 Gateway |
| `openclaw stop`         | 停止所有服务         |
| `openclaw stop gateway` | 仅停止 Gateway 服务 |

## 相关链接

- [[Claude Code Memory MCP 使用指南]]
- [[Codex CLI 完整命令手册]]
- [[OpenCode Skills 安装与推荐]]
