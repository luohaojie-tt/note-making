# Memorix 使用指南

## 简介

Memorix 是一个跨代理记忆桥接工具，为 AI 编码代理提供通用的记忆层。它可以存储项目知识、记录发现、管理记忆，并在不同会话和代理之间共享上下文。

## Dashboard 启动

### Windows 端口问题

**重要：** Windows 系统保留了部分端口范围（3109-3208），默认端口 3210 落在此范围内，会导致启动失败并报错：

```
ERROR listen EACCES: permission denied 0.0.0.0:3210
```

### 解决方案

使用非保留端口启动 Dashboard：

```bash
npx memorix dashboard --port=13210
```

### Windows 保留端口查询

查看系统保留的端口范围：

```bash
netsh interface ipv4 show excludedportrange protocol=tcp
```

输出示例：
```
协议 tcp 端口排除范围

开始端口    结束端口
----------    --------
      1029        1128
      1334        1433
      2909        3008
      3009        3108
      3109        3208   <-- 默认端口 3210 在此范围内
      3209        3308
      ...
```

### 推荐端口

以下端口通常可用：
- `13210`
- `18080`
- `5000`（如果未被其他服务占用）

## CLI 命令

```bash
# 查看帮助
npx memorix --help

# 启动 MCP Server
npx memorix serve

# 查看项目状态
npx memorix status

# 启动 Dashboard
npx memorix dashboard --port=13210

# 清理低质量自动生成的观察记录
npx memorix cleanup
```

## 观察记录类型

| 类型 | 说明 |
|------|------|
| `gotcha` | 关键陷阱/坑点 |
| `decision` | 架构决策 |
| `problem-solution` | 问题解决方案 |
| `how-it-works` | 工作原理解释 |
| `what-changed` | 变更记录 |
| `discovery` | 发现/洞察 |
| `why-it-exists` | 存在原因 |
| `trade-off` | 权衡取舍 |
| `session-request` | 会话目标 |

## MCP 工具

在 Claude Code 中可通过以下 MCP 工具使用：

- `memorix_store` - 存储新观察记录
- `memorix_search` - 搜索记忆
- `memorix_timeline` - 查看时间线
- `memorix_detail` - 获取详细信息
- `memorix_dashboard` - 启动 Web Dashboard

## 相关链接

- Dashboard 地址: http://localhost:13210
- 项目: note-making
