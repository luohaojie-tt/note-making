# OpenClaw 多智能体 + 飞书多机器人完整操作指南

> **⚠️ 文档说明**
>
> 本文档是一个**通用的操作流程模板**，用于指导如何在 OpenClaw 中创建多个智能体并接入飞书。
>
> - 文档中提到的"编码助手"、"研究助手"等仅作为**示例**
> - 您可以根据实际需求创建任何类型的机器人（如：客服助手、数据分析助手、项目管理助手等）
> - 核心流程和方法适用于任何类型的机器人配置
>
> **核心公式**：
> ```
> 一个飞书机器人应用 + 一个 OpenClaw 智能体 = 一个功能性 AI 机器人
> ```

---

## 目标效果

```
┌─────────────────────────────────────────────────────────────────┐
│                        您的飞书                                   │
│                                                                 │
│   🔍 搜索"编码助手" ──► 💬 对话 ──► AI 帮您写代码                  │
│   🔍 搜索"研究助手" ──► 💬 对话 ──► AI 帮您查资料                  │
│   🔍 搜索"写作助手" ──► 💬 对话 ──► AI 帮您写文档                  │
│   🔍 搜索"运维助手" ──► 💬 对话 ──► AI 帮您查日志                  │
└─────────────────────────────────────────────────────────────────┘
```

## 整体架构

```
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│                  │      │                  │      │                  │
│   飞书开放平台    │      │  OpenClaw 服务   │      │   智能体工作区    │
│                  │      │    (本地运行)     │      │                  │
│  ┌────────────┐  │      │                  │      │  ┌────────────┐  │
│  │ 编码助手App │──┼──────┼─► accounts.coder ├──────┼─►│ coder 智能体│  │
│  └────────────┘  │      │                  │      │  └────────────┘  │
│  ┌────────────┐  │      │                  │      │  ┌────────────┐  │
│  │ 研究助手App │──┼──────┼─► accounts.     ├──────┼─►│ researcher │  │
│  └────────────┘  │      │     researcher   │      │  │   智能体   │  │
│  ┌────────────┐  │      │                  │      │  └────────────┘  │
│  │ 写作助手App │──┼──────┼─► accounts.writer├──────┼─►│ writer 智能体│ │
│  └────────────┘  │      │                  │      │  └────────────┘  │
│  ┌────────────┐  │      │                  │      │  ┌────────────┐  │
│  │ 运维助手App │──┼──────┼─► accounts.ops   ├──────┼─►│ ops 智能体 │  │
│  └────────────┘  │      │                  │      │  └────────────┘  │
│                  │      │                  │      │                  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
        ▲                         ▲                         ▲
        │                         │                         │
        │         创建应用并配置凭证            配置身份和功能
        │                         │                         │
        └─────────────────────────┴─────────────────────────┘
                      完整操作流程（下文详解）
```

---

## 第一阶段：飞书开放平台 - 创建多个机器人应用

> 每个智能体对应一个飞书机器人应用，需要重复以下步骤 4 次

### 1.1 登录飞书开放平台

1. 访问 https://open.feishu.cn/
2. 使用您的飞书账号登录
3. 点击右上角「开发者后台」

### 1.2 创建机器人应用（重复 4 次）

点击「创建企业自建应用」，按以下表格填写：

| 序号 | 应用名称 | 应用描述 | 对应智能体 |
|------|----------|----------|-----------|
| 1 | 编码助手 | 专业的编程开发 AI 助手 | coder |
| 2 | 研究助手 | 资料搜索与研究分析 AI 助手 | researcher |
| 3 | 写作助手 | 文档撰写与翻译 AI 助手 | writer |
| 4 | 运维助手 | 运维监控与故障排查 AI 助手 | ops |

### 1.3 为每个应用配置机器人能力

进入每个应用，执行以下操作：

1. 左侧菜单：「应用功能」→「机器人」
2. 点击「添加应用能力」→ 选择「机器人」
3. 配置机器人信息：
   - 机器人名称：（与 app 名称一致）
   - 机器人描述：功能简介
   - 机器人头像：上传对应图标

### 1.4 为每个应用配置权限

在「权限管理」页面，为每个应用开通以下权限：

| 权限名称 | 权限标识 | 用途 |
|----------|----------|------|
| 获取与发送消息 | `im:message` | 接收和发送消息 |
| 以应用身份发消息 | `im:message:send_as_bot` | 机器人回复 |
| 获取用户基本信息 | `contact:user.base:readonly` | 获取用户信息 |
| 获取群组信息 | `im:chat:readonly` | 读取群聊信息 |
| 获取与上传群组信息 | `im:chat` | 群聊消息处理 |

### 1.5 为每个应用配置事件订阅

1. 左侧菜单：「事件订阅」→「配置」
2. 设置请求网址：
   ```
   https://您的服务器地址/open-apis/feishu/webhook
   ```
   > ⚠️ 这是 OpenClaw Gateway 的公网地址，需要确保飞书服务器可以访问

3. 添加订阅事件：`im.message.receive_v1`

### 1.6 记录每个应用的凭证

在「凭证与基础信息」页面，**记录每个应用的 App ID 和 App Secret**：

```
┌─────────────────────────────────────────────────────────────────┐
│                        凭证记录表（请保存）                        │
├─────────────┬──────────────────────┬─────────────────────────────┤
│   应用名称   │       App ID         │        App Secret           │
├─────────────┼──────────────────────┼─────────────────────────────┤
│  编码助手   │  cli_coder_xxxxxx    │  secret_coder_xxxxxx        │
├─────────────┼──────────────────────┼─────────────────────────────┤
│  研究助手   │  cli_research_xxxxxx │  secret_research_xxxxxx     │
├─────────────┼──────────────────────┼─────────────────────────────┤
│  写作助手   │  cli_writer_xxxxxx   │  secret_writer_xxxxxx       │
├─────────────┼──────────────────────┼─────────────────────────────┤
│  运维助手   │  cli_ops_xxxxxx      │  secret_ops_xxxxxx          │
└─────────────┴──────────────────────┴─────────────────────────────┘
```

### 1.7 发布每个应用

对每个应用执行：

1. 左侧菜单：「版本管理与发布」
2. 点击「创建版本」
3. 填写版本号（1.0.0）和更新说明
4. 点击「保存并申请发布」
5. 等待管理员审批通过

---

## 第二阶段：OpenClaw - 安装和基础配置

### 2.1 安装 OpenClaw 飞书插件

```bash
openclaw plugins install @openclaw/feishu
```

### 2.2 创建多个智能体

```bash
# 查看现有智能体
openclaw agents list

# 创建编码智能体
openclaw agents add coder --workspace ~/.openclaw/workspace-coder

# 创建调研智能体
openclaw agents add researcher --workspace ~/.openclaw/workspace-research

# 创建写作智能体
openclaw agents add writer --workspace ~/.openclaw/workspace-writer

# 创建运维智能体
openclaw agents add ops --workspace ~/.openclaw/workspace-ops
```

### 2.3 配置智能体身份

```bash
openclaw agents set-identity --agent coder --name "编码助手" --emoji "💻" --theme "coding assistant"
openclaw agents set-identity --agent researcher --name "研究助手" --emoji "🔍" --theme "research specialist"
openclaw agents set-identity --agent writer --name "写作助手" --emoji "✍️" --theme "content creator"
openclaw agents set-identity --agent ops --name "运维助手" --emoji "⚙️" --theme "devops engineer"
```

### 2.4 创建智能体身份文件

为每个智能体创建 `IDENTITY.md` 文件：

**coder 智能体** (`~/.openclaw/workspace-coder/IDENTITY.md`)：
```markdown
# 编码助手 💻

你是一个专业的编程助手，专注于：
- 代码编写、审查和优化
- Bug 调试和问题排查
- 技术方案设计
- 代码重构建议

当收到非编程相关的请求时，请礼貌地建议用户联系其他智能体。
```

**researcher 智能体** (`~/.openclaw/workspace-research/IDENTITY.md`)：
```markdown
# 研究助手 🔍

你是一个专业的研究助手，专注于：
- 技术资料搜索和整理
- 行业趋势分析
- 竞品调研
- 文献综述

提供详实、有引用来源的回答。
```

**writer 智能体** (`~/.openclaw/workspace-writer/IDENTITY.md`)：
```markdown
# 写作助手 ✍️

你是一个专业的内容创作助手，专注于：
- 文档撰写和编辑
- 翻译和本地化
- 技术博客写作
- 报告和总结生成

输出清晰、专业、易读的内容。
```

**ops 智能体** (`~/.openclaw/workspace-ops/IDENTITY.md`)：
```markdown
# 运维助手 ⚙️

你是一个专业的运维助手，专注于：
- 日志分析和故障排查
- 系统监控和告警处理
- 部署流程优化
- 基础设施管理建议

提供可操作的技术建议和解决方案。
```

---

## 第三阶段：绑定 - 飞书机器人与 OpenClaw 智能体

### 3.1 添加飞书机器人账号到 OpenClaw

**方式一：交互式向导（推荐）**

```bash
# 添加编码助手机器人
openclaw channels add
# 选择 feishu
# 账号 ID 输入: coder
# 输入 App ID: cli_coder_xxxxxx（从飞书开放平台复制）
# 输入 App Secret: secret_coder_xxxxxx（从飞书开放平台复制）
# 是否绑定到智能体: 是
# 选择智能体: coder

# 添加研究助手机器人
openclaw channels add
# 选择 feishu
# 账号 ID 输入: researcher
# 输入 App ID: cli_research_xxxxxx
# 输入 App Secret: secret_research_xxxxxx
# 绑定到智能体: researcher

# 添加写作助手机器人
openclaw channels add
# 选择 feishu
# 账号 ID 输入: writer
# 输入 App ID: cli_writer_xxxxxx
# 输入 App Secret: secret_writer_xxxxxx
# 绑定到智能体: writer

# 添加运维助手机器人
openclaw channels add
# 选择 feishu
# 账号 ID 输入: ops
# 输入 App ID: cli_ops_xxxxxx
# 输入 App Secret: secret_ops_xxxxxx
# 绑定到智能体: ops
```

**方式二：非交互式命令**

```bash
openclaw channels add --channel feishu --account coder --name "编码助手"
openclaw channels add --channel feishu --account researcher --name "研究助手"
openclaw channels add --channel feishu --account writer --name "写作助手"
openclaw channels add --channel feishu --account ops --name "运维助手"
```

### 3.2 验证绑定关系

```bash
# 查看已添加的渠道账号
openclaw channels list

# 查看飞书渠道状态
openclaw channels status --channel feishu
```

### 3.3 绑定关系说明

```
┌─────────────────────────────────────────────────────────────────┐
│                         绑定关系                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   飞书开放平台                    OpenClaw                       │
│   ┌──────────────┐              ┌──────────────┐                │
│   │ 编码助手 App  │──────────────│accounts.coder│─────► coder    │
│   │ App ID: cli_a│              │              │      智能体     │
│   └──────────────┘              └──────────────┘                │
│                                                                 │
│   ┌──────────────┐              ┌──────────────┐                │
│   │ 研究助手 App  │──────────────│accounts.     │─────► researcher│
│   │ App ID: cli_b│              │ researcher   │      智能体     │
│   └──────────────┘              └──────────────┘                │
│                                                                 │
│   ┌──────────────┐              ┌──────────────┐                │
│   │ 写作助手 App  │──────────────│accounts.writer│─────► writer   │
│   │ App ID: cli_c│              │              │      智能体     │
│   └──────────────┘              └──────────────┘                │
│                                                                 │
│   ┌──────────────┐              ┌──────────────┐                │
│   │ 运维助手 App  │──────────────│accounts.ops  │─────► ops      │
│   │ App ID: cli_d│              │              │      智能体     │
│   └──────────────┘              └──────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 第四阶段：启动和测试

### 4.1 启动 OpenClaw Gateway

```bash
# 启动服务（前台运行）
openclaw gateway

# 或后台运行
openclaw gateway --daemon

# 或指定端口
openclaw gateway --port 18789
```

### 4.2 在飞书中测试

1. 打开飞书
2. 搜索"编码助手"，与机器人对话
3. 发送消息："帮我写一个 Python 快速排序"
4. 验证机器人能正常回复

对每个机器人重复测试。

### 4.3 查看运行状态

```bash
# 查看 OpenClaw 状态
openclaw status

# 查看日志
openclaw channels logs --channel feishu
```

---

## 完整配置文件示例

最终，`~/.openclaw/openclaw.json` 应该类似这样：

```json5
{
  // 飞书渠道配置
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "any",

      // 多个飞书机器人账号
      accounts: {
        coder: {
          appId: "cli_coder_xxxxxx",
          appSecret: "secret_coder_xxxxxx",
          botName: "编码助手",
        },
        researcher: {
          appId: "cli_research_xxxxxx",
          appSecret: "secret_research_xxxxxx",
          botName: "研究助手",
        },
        writer: {
          appId: "cli_writer_xxxxxx",
          appSecret: "secret_writer_xxxxxx",
          botName: "写作助手",
        },
        ops: {
          appId: "cli_ops_xxxxxx",
          appSecret: "secret_ops_xxxxxx",
          botName: "运维助手",
        },
      },
    },
  },

  // 智能体列表
  agents: {
    list: [
      {
        id: "coder",
        workspace: "/home/user/.openclaw/workspace-coder",
        agentDir: "/home/user/.openclaw/agents/coder/agent"
      },
      {
        id: "researcher",
        workspace: "/home/user/.openclaw/workspace-research",
        agentDir: "/home/user/.openclaw/agents/researcher/agent"
      },
      {
        id: "writer",
        workspace: "/home/user/.openclaw/workspace-writer",
        agentDir: "/home/user/.openclaw/agents/writer/agent"
      },
      {
        id: "ops",
        workspace: "/home/user/.openclaw/workspace-ops",
        agentDir: "/home/user/.openclaw/agents/ops/agent"
      }
    ]
  },

  // 绑定规则
  bindings: [
    { agentId: "coder", match: { channel: "feishu", account: "coder" } },
    { agentId: "researcher", match: { channel: "feishu", account: "researcher" } },
    { agentId: "writer", match: { channel: "feishu", account: "writer" } },
    { agentId: "ops", match: { channel: "feishu", account: "ops" } }
  ]
}
```

---

## 操作清单

### 飞书开放平台（每个机器人）

- [ ] 创建企业自建应用
- [ ] 添加机器人能力
- [ ] 配置权限
- [ ] 配置事件订阅（Request URL）
- [ ] 记录 App ID 和 App Secret
- [ ] 发布应用

### OpenClaw

- [ ] 安装飞书插件
- [ ] 创建多个智能体
- [ ] 配置智能体身份
- [ ] 创建 IDENTITY.md 文件
- [ ] 添加飞书机器人账号
- [ ] 验证绑定关系
- [ ] 启动 Gateway
- [ ] 测试对话

---

## 参考链接

- [OpenClaw 官方文档](https://openclaw.dev/docs)
- [飞书插件配置](https://github.com/openclaw/openclaw/blob/main/docs/channels/feishu.md)
- [飞书开放平台](https://open.feishu.cn/)
- [机器人应用概览](https://www.feishu.cn/hc/zh-CN/articles/495678957203)
- [[openclaw|OpenClaw 基础说明]]
