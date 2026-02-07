# Teams 学习笔记

> 本文档记录关于 Claude Code Teams 功能的学习对话

---

## 第一部分：Teams 功能简介

**问题：给我介绍一下你最新发布的这个 teams**

### Teams 功能介绍

Teams 是 Claude Code 的**多智能体协作系统**,让多个专门的 AI 代理同时处理复杂任务。

### 核心概念

**Team = 协作框架（配置文件 + 任务目录 + 通信机制）**

创建 Team 时会自动生成:
- ✅ 团队配置文件 (`~/.claude/teams/{team-name}/config.json`) - 存储成员信息
- ✅ 共享任务目录 (`~/.claude/tasks/{team-name}/`) - 存储任务列表
- ✅ 协作框架 - 使得后续 Agents 可以加入并互相通信

> **注意：** 创建 Team 时只建立基础设施，不会自动启动 Agents。需要手动使用 `Task` 工具启动 Agents，他们才会加入团队并开始协作。

### 工作流程

1. **创建团队** - 使用 `TeamCreate` 工具
2. **生成任务** - 通过 `TaskCreate` 创建待办事项
3. **分配成员** - 使用 `Task` 工具启动专门 Agent
4. **协作执行** - Agent 自主认领任务、协作、完成
5. **清理团队** - 使用 `TeamDelete` 清理资源

### Agent 类型选择

根据任务需求选择合适的 Agent 类型:

| Agent | 工具能力 | 适用场景 |
|-------|---------|---------|
| **general-purpose** | 完整工具集 | 编码、实现、修改 |
| **Explore** | 只读工具 | 探索、搜索、研究 |
| **code-reviewer** | 代码审查 | 审查代码质量 |
| **tdd-guide** | 测试驱动 | 测试优先开发 |
| **architect** | 系统设计 | 架构决策 |

### 关键特性

- **消息自动传递** - Agent 间自动通信,无需手动检查
- **空闲状态管理** - Agent 完成任务后自动空闲,等待新任务
- **任务依赖管理** - 支持 `blocks`/`blockedBy` 任务依赖
- **共享任务列表** - 所有 Agent 可见和认领任务

### 何时使用 Teams

✅ **适合使用:**
- 复杂功能实现(前后端并行)
- 大规模重构
- 需要多个专家视角的任务
- 多步骤项目(研究+规划+编码)

❌ **无需使用:**
- 简单单文件修改
- 纯研究任务(用 Explore agent 即可)
- 明确的小型修复

---

## 第二部分：Teams vs 多终端方式的区别

**问题：我提问你回答。你提到Task list + Multiple Agents这个样方式，这个方式和之前我多开几个终端然后使用不同的agent来完成任务有什么不同？优势是什么**

### 核心区别

Teams 与传统多终端方式的核心区别在于**协作机制**。

#### 🔄 任务协调

**多终端方式：**
```bash
# 终端1: 你手动启动 agent 处理前端
# 终端2: 你手动启动 agent 处理后端
# 终端3: 你手动启动 agent 写测试
```
❌ 你需要手动切换、手动分配、手动汇总进度

**Teams 方式：**
```
创建任务列表 → Agents 自主认领 → 自动协作
```
✅ 你只需创建任务，agents 自动协调工作

#### 📊 状态共享

**多终端：**
- 每个终端独立工作
- Agent B 不知道 Agent A 做到哪了
- 需要你手动同步信息

**Teams：**
- 共享任务列表
- 所有 agents 可见全局进度
- Agent A 完成任务 1 后，Agent B 自动知道任务 2 解锁了

#### 💬 消息通信

**多终端：**
- Agent 完成 → 你看到 → 你告诉另一个 agent
- 你是"消息路由器"

**Teams：**
- Agent A 完成任务 → 自动通知 Team Lead 和其他 Agents
- 自动消息传递，无需你转发

### 具体例子

假设你要**实现用户认证功能**（前端+后端+测试）：

**多终端方式：**
```bash
终端1: "你处理 API"
终端2: "你处理前端登录页"
终端3: "你写测试"

# 5分钟后你手动检查进度：
# - 终端1 卡住了，需要定义 API 接口
# - 终端2 在等终端1 的接口
# - 你需要手动协调：让终端1 先定义接口，然后通知终端2
```

**Teams 方式：**
```
任务1: 定义 API 接口 (blocks: 任务2, 3)
任务2: 实现 API 后端 (blockedBy: 任务1)
任务3: 实现前端登录页 (blockedBy: 任务1)

# Agents 自主工作：
# - Agent 看到"我需要任务1完成"
# - 自动认领任务1
# - 完成后自动解锁任务2和3
# - 其他 agents 立即看到并认领新任务
```

### 核心优势总结

1. **减少手动协调** - 不用你在终端间切换传话
2. **自动依赖管理** - 任务自动解锁，不会漏步骤
3. **全局可见性** - 所有进度一目了然
4. **自主性更强** - Agents 可以自主决策下一步做什么

**简单总结：多终端是手动管理，Teams 是自动化协作系统。**

---

## 第三部分：Agent 间消息通信的技术实现

**问题：你这个提到了在teams中agents之前的消息互通，这个是如何做到的，之前在手动打开多终端来运行agent时无法做到，这应该算是teams在这方面的突破把**

### 🔒 多终端的天然限制

**问题根源：会话隔离**

```bash
# 终端 1
Session ID: abc-123 (独立上下文)
Agent: "code-reviewer"
上下文：只知道自己的任务

# 终端 2
Session ID: xyz-789 (完全独立的上下文)
Agent: "tdd-guide"
上下文：不知道 terminal-1 的存在
```

❌ **两个 Agent 在"平行宇宙"中，无法发现彼此**

### 🔗 Teams 的突破

#### 1. 共享团队上下文

```bash
~/.claude/teams/my-project/config.json
{
  "members": [
    {"name": "agent-1", "agentType": "code-reviewer", "agentId": "..."},
    {"name": "agent-2", "agentType": "tdd-guide", "agentId": "..."},
    {"name": "agent-3", "agentType": "general-purpose", "agentId": "..."}
  ]
}
```

✅ **所有 Agents 都知道"队友"是谁**

#### 2. 专用消息传递工具

Teams 有专门的 `SendMessage` 工具：

```javascript
// Agent A 发送消息
SendMessage({
  type: "message",
  recipient: "agent-2",  // 指定接收者
  content: "我发现了一个 bug，请检查",
  summary: "Bug 报告"
})

// Agent B 自动收到（无需轮询！）
// → 作为新的 conversation turn 出现在 Agent B 的会话中
```

#### 3. 自动消息路由

```
Team Lead Session (主会话)
    │
    ├── Agent 1 Session ──→ SendMessage ──┐
    │                                     │
    ├── Agent 2 Session ←─────────────────┘
    │         (自动收到消息)
    │
    └── Agent 3 Session
```

### 为什么多终端无法实现

| 维度 | 多终端方式 | Teams 方式 |
|------|-----------|-----------|
| **会话空间** | 完全隔离 | 共享团队空间 |
| **Agent 发现** | 无法知道其他 agents | 从 config.json 读取成员列表 |
| **消息传递** | 无工具支持 | 专用 `SendMessage` 工具 |
| **状态同步** | 需要手动复制粘贴 | 自动推送消息 |
| **事件通知** | 需要主动轮询 | 自动推送（idle 通知等） |

### 核心技术突破

#### 1. 跨会话通信
```
传统：Session A → 用户 → Session B
Teams：Session A → 消息系统 → Session B（用户不需要转发）
```

#### 2. Agent 发现协议
```javascript
// Agent 可以读取团队配置
const teamConfig = readFileSync("~/.claude/teams/my-project/config.json")
// → 知道可以发送消息给谁
```

#### 3. 事件驱动通知
```
Agent 完成任务 → 自动发送 idle 通知
→ Team Lead 和其他 Agents 自动看到
```

### 具体示例

**场景：Agent 1 发现安全问题，需要 Agent 2 停止工作**

**多终端方式：**
```
终端1 Agent: "我发现安全漏洞！"
你: 看到消息
你: 切换到终端2
你: "agent-1 发现漏洞，先停下"
终端2 Agent: "好的，等待..."
```

**Teams 方式：**
```
Agent 1: SendMessage({
  type: "broadcast",
  content: "发现安全漏洞，所有工作暂停！",
  summary: "紧急停止"
})
→ 所有 Agents 自动收到
→ 无需你手动传话
```

### 总结

**突破点：**
1. ✅ **打破会话隔离** - 共享团队上下文
2. ✅ **Agent 发现机制** - 知道队友是谁
3. ✅ **自动消息路由** - 无需用户转发
4. ✅ **事件驱动通知** - 实时状态更新

**本质上：**
- 多终端 = 多个**孤立**的 AI 会话
- Teams = 多个 AI agent 在**共享工作空间**中协作

这就像从"每个人在自己的房间工作"升级到"大家在同一个会议室协作"。

---

## 第四部分：Agent 如何决定发送消息给谁

**问题：等一下，你这个提到了agent自动发送消息给其他agent，但是你个teams中肯定不止2个agent，在发送消息时，如何知道该发送给哪一个agent，比如为什么agent 1不发送给agent 3 ，而是发送给agent 2 ，这些消息发送给谁，是靠什么约定的，靠/.claude/teams/my-project/config.json这个配置文件吗？**

### 答案：config.json 是"通讯录"，不是"路由表"

#### config.json 的真实作用

```json
~/.claude/teams/my-project/config.json
{
  "members": [
    {"name": "frontend-dev", "agentType": "general-purpose", "agentId": "abc-123"},
    {"name": "backend-dev", "agentType": "general-purpose", "agentId": "def-456"},
    {"name": "tester", "agentType": "tdd-guide", "agentId": "ghi-789"},
    {"name": "security-reviewer", "agentType": "code-reviewer", "agentId": "jkl-012"}
  ]
}
```

**作用：** 告诉 Agent"团队里有哪些成员"（类似公司通讯录）

**但不是：** 规定"谁必须给谁发消息"（那是 Agent 自己决策的）

### Agent 的路由决策机制

#### 决策依据

Agent 根据以下因素决定**发送给谁**：

##### 1. agentType（专业角色）

```javascript
// Agent 发现前端 bug
if (agentType === "code-reviewer") {
  // 我应该告诉谁？
  // - tester？不太对，他负责测试
  // + frontend-dev？对！他负责前端
  SendMessage({
    recipient: "frontend-dev",  // 根据专业判断
    content: "发现前端 XSS 漏洞"
  })
}
```

##### 2. 任务依赖关系

```javascript
// 任务列表：
// 任务1: 设计 API (backend-dev)
// 任务2: 实现前端 (frontend-dev, blockedBy: 任务1)

// backend-dev 完成任务1后
if (taskCompleted) {
  // 谁在等我的任务？
  // 查看 tasks.json → 发现 frontend-dev 的任务2被任务1阻塞
  SendMessage({
    recipient: "frontend-dev",
    content: "API 设计完成，可以开始了"
  })
}
```

##### 3. 对话上下文

```
之前的对话：
- 你对 backend-dev 说："实现用户 API"
- backend-dev 对 frontend-dev 说："API 接口是 /api/users"

// 现在 frontend-dev 发现问题
→ 他知道应该回复 backend-dev（因为之前是他告诉你的）
```

### 具体示例对比

#### 场景：发现 API 接口不一致

**为什么发送给 Agent 2 而不是 Agent 3？**

```javascript
// 配置文件（通讯录）
config.json = {
  members: [
    {name: "agent-1", agentType: "frontend-dev"},
    {name: "agent-2", agentType: "backend-dev"},
    {name: "agent-3", agentType: "tester"}
  ]
}

// Agent-1 (前端) 发现 API 返回格式错误
// 决策过程：
1. 读取 config.json → 看到 agent-2 和 agent-3
2. 分析问题 → "API 接口问题"
3. 判断专家类型 → "backend-dev 负责 API"
4. 查找对应 name → agent-2 是 backend-dev
5. 发送消息
SendMessage({
  type: "message",
  recipient: "agent-2",  // ← 根据专业判断
  content: "API 返回格式错误，应该是 {user: {...}} 而不是 {data: {...}}"
})
```

**为什么不发给 agent-3？**
- agent-3 是 tester（测试工程师）
- 他不负责 API 实现
- 告诉他也解决不了问题

### 三种消息类型

Teams 支持不同的发送策略：

#### 1. 点对点消息（指定接收者）

```javascript
SendMessage({
  type: "message",
  recipient: "backend-dev",  // 明确指定
  content: "API 有问题"
})
```
**用途：** 需要特定专家处理的问题

#### 2. 广播消息（所有人）

```javascript
SendMessage({
  type: "broadcast",  // 不指定 recipient
  content: "项目紧急停止！发现安全漏洞"
})
```
**用途：** 重要通知，所有人都要知道

#### 3. Team Lead 消息（汇报）

```javascript
// Agent 完成任务后自动发送
{
  type: "task_completed",
  to: "team-lead"
}
```
**用途：** 汇报进度

### Agent 决策流程图

```
Agent 发现问题/完成工作
    ↓
读取 config.json（了解团队成员）
    ↓
分析问题性质
    ↓
根据专业分工判断
    ├─ 前端问题 → frontend-dev
    ├─ 后端问题 → backend-dev
    ├─ 测试问题 → tester
    ├─ 审查问题 → code-reviewer
    └─ 全员通知 → broadcast
    ↓
执行 SendMessage
```

### 类比理解

**config.json = 公司通讯录**
```
张三（前端开发）
李四（后端开发）
王五（测试工程师）
```

**Agent 决策 = 你的常识判断**
```
你发现前端 bug → 看通讯录 → 知道该找张三
你发现 API 问题 → 看通讯录 → 知道该找李四
你要发布项目 → 看通讯录 → 群发所有人
```

**不是：** 通讯录规定了你必须找谁
**而是：** 你根据问题性质，自己判断该找谁

### 总结

| 问题 | 答案 |
|------|------|
| **如何知道发送给谁？** | Agent 根据问题性质自主判断 |
| **config.json 的作用？** | 提供"成员列表"（通讯录），不是"路由规则" |
| **判断依据是什么？** | 1. agentType（专业分工）<br>2. 任务依赖关系<br>3. 对话上下文 |
| **可以发给多人吗？** | 可以，使用 `type: "broadcast"` |
| **会发错人吗？** | 理论上可能，但 Agent 会根据专业判断 |

**核心：config.json 告诉 Agent"有哪些队友"，Agent 自己决定"该找谁"。**

---

## 第五部分：澄清"创建 Team"的真实过程

**问题：你组开始时描述创建Team时，会自动创建生成团队配置文件、创建共享任务列表还有各个agnet可以协作完成任务，这第一条配置我理解了，适用于保存team成员及其负责内容的，然后创建共享任务列表，这个应该是根据总任务来划分的子任务列表吧，但是第三个你有说了一遍多个 Agent 可以协作完成任务，这是想表达什么意思**

### 问题所在

原始表述中的三点并列，容易让人误解为"创建 Team 时自动发生了三件事"：

```
创建 Team 时会自动:
- 生成团队配置文件
- 创建共享任务列表
- 多个 Agent 可以协作完成任务  ← 误导性表述
```

### 准确的理解

**创建 Team 时真正自动生成的（只有前两项）：**

```bash
# 当你运行 TeamCreate({team_name: "my-project"})

# 自动生成 1: 配置文件
~/.claude/teams/my-project/config.json  ← 空的成员列表（初始为空）

# 自动生成 2: 任务目录
~/.claude/tasks/my-project/  ← 空的任务列表（初始为空）
```

**第3点"多个 Agent 可以协作完成任务"不是自动生成的**，而是描述**创建 Team 后能实现的功能**。

### 重新表述

更准确的说法应该是：

**创建 Team 时会自动：**
1. ✅ 生成团队配置文件（存储成员信息）
2. ✅ 创建共享任务列表目录（存储任务）
3. ✅ **建立协作框架**（使得后续 Agents 可以加入并协作）

**然后你手动：**
4. 启动 Agents（使用 `Task` 工具的 `team_name` 参数）
5. 创建任务（使用 `TaskCreate`）
6. Agents 开始协作

### 类比理解

**创建 Team = 租了一个会议室**

```
你租会议室时自动得到：
1. 会议室名单（config.json）
2. 白板/任务板（tasks/ 目录）

但此时：
- 会议室是空的
- 还没有人来开会
- 没有实际协作发生

然后你需要：
1. 邀请专家加入（启动 Agents）
2. 在白板上写任务（TaskCreate）
3. 专家们开始协作（实际协作发生）
```

### 时间线

```bash
# 步骤1: 创建 Team（只有基础设施）
TeamCreate({team_name: "my-project"})
→ 生成 config.json（空）
→ 生成 tasks/ 目录（空）
→ **还没有协作**

# 步骤2: 启动第一个 Agent
Task({
  team_name: "my-project",
  name: "agent-1",
  subagent_type: "general-purpose"
})
→ config.json 更新：添加 agent-1
→ agent-1 加入团队

# 步骤3: 启动更多 Agents
Task({team_name: "my-project", name: "agent-2", ...})
Task({team_name: "my-project", name: "agent-3", ...})
→ config.json 更新：添加 agent-2, agent-3
→ 现在 team 有 3 个成员

# 步骤4: 创建任务
TaskCreate({
  subject: "实现用户认证",
  description: "..."
})
→ 任务写入 tasks/ 目录
→ 所有 Agents 可见

# 步骤5: Agents 协作
→ agent-1 认领任务
→ agent-2 协助
→ agent-3 审查
→ **协作实际发生**
```

### 第3点的准确含义

**"多个 Agent 可以协作完成任务"** 应该理解为：

> ✅ 创建 Team **建立了协作机制**
>
> 这个机制包括：
> - 共享上下文（所有 Agents 知道自己在同一个 team）
> - 消息传递（Agents 可以互相发消息）
> - 任务共享（所有 Agents 看到同一份任务列表）
> - 状态同步（Agents 知道其他成员的状态）

❌ **不是**：创建 Team 时就自动启动了 Agents 或让他们开始工作

### 更准确的总结

| 动作 | 自动生成 | 需要手动操作 |
|------|---------|-------------|
| **config.json** | ✅ 创建空文件 | - |
| **tasks/ 目录** | ✅ 创建空目录 | - |
| **协作框架** | ✅ 建立机制 | - |
| **启动 Agents** | ❌ | ✅ 使用 Task 工具 |
| **创建任务** | ❌ | ✅ 使用 TaskCreate |
| **实际协作** | ❌ | ✅ Agents 自主工作 |

### 总结

**原表述的问题：**
- 把"基础设施"和"实际行为"混在一起了

**正确的理解：**
- **创建 Team** = 盖房子（建会议室）
- **启动 Agents** = 请专家来
- **创建任务** = 分配工作
- **实际协作** = 专家们一起干活

所以第3点应该理解为：**创建 Team 为多个 Agent 协作提供了必要的框架和机制**。

---

## 第六部分：如何使用 Planner Agent 规划任务

**问题：你这里提到加入planner agent，这个如何加入，比如在上面这个例子中，从创建teams到你说的使用planner agent规划，具体的流程是怎么样的**

### 两种使用 Planner 的方式

#### 方式 A：先用 Planner 规划，再创建 Team（推荐）

这种方式更清晰，规划阶段和执行阶段分离。

```bash
# === 阶段1: 规划（Team 之外）===

# 步骤1: 启动 Planner Agent（独立会话）
Task({
  subagent_type: "planner",
  prompt: """
  我要开发一个股票信息分析系统，需求如下：

  功能需求：
  1. 前后端分离架构
  2. 数据库存储股票数据
  3. 实时获取股票数据
  4. 数据可视化展示

  请帮我规划：
  1. 技术栈推荐
  2. 任务划分（包括任务描述、依赖关系）
  3. 需要多少个 Agent？分别是什么类型？
  4. 任务优先级排序
  5. 预估时间
  """
})

# Planner 会输出类似内容：
"""
## 规划方案

### 技术栈推荐
- 前端：Next.js + TypeScript + Recharts
- 后端：Node.js + Express + TypeScript
- 数据库：PostgreSQL
- 数据源：Alpha Vantage API

### 任务划分（14个任务）

#### 阶段1: 架构设计
任务1: [P0] 技术栈确认
- 负责人: architect
- 预估: 1小时

任务2: [P1] 数据库 schema 设计
- 负责人: architect
- 依赖: 任务1
- 预估: 2小时

任务3: [P1] REST API 设计
- 负责人: architect
- 依赖: 任务1
- 预估: 2小时

#### 阶段2: 后端开发
任务4: [P2] 数据库初始化
- 负责人: backend-dev
- 依赖: 任务2
- 预估: 2小时

任务5: [P2] 股票数据 API 实现
- 负责人: backend-dev
- 依赖: 任务4
- 预估: 4小时

... (省略其他任务)

### 建议的 Team 结构
- architect (1个)
- backend-dev (1个)
- frontend-dev (1个)
- qa-tester (1个)
总计: 4 个 Agents
"""

# === 阶段2: 创建 Team ===

# 步骤2: 根据规划创建 Team
TeamCreate({
  team_name: "stock-analysis-system",
  description: "股票信息分析系统开发团队",
  agent_type: "architect"  // 指定 team lead 类型
})

# 自动生成：
# ~/.claude/teams/stock-analysis-system/config.json
# ~/.claude/tasks/stock-analysis-system/

# === 阶段3: 启动 Team Members ===

# 步骤3: 启动各个 Agents
Task({
  team_name: "stock-analysis-system",
  name: "architect",
  subagent_type: "architect",
  prompt: "你负责系统架构设计，包括技术栈、数据库、API设计"
})

Task({
  team_name: "stock-analysis-system",
  name: "backend-dev",
  subagent_type: "general-purpose",
  prompt: "你负责后端开发，包括数据库操作和 API 实现"
})

Task({
  team_name: "stock-analysis-system",
  name: "frontend-dev",
  subagent_type: "general-purpose",
  prompt: "你负责前端开发，包括 UI 和数据可视化"
})

Task({
  team_name: "stock-analysis-system",
  name: "qa-tester",
  subagent_type: "tdd-guide",
  prompt: "你负责测试，包括单元测试和集成测试"
})

# === 阶段4: 创建任务列表 ===

# 步骤4: 根据 Planner 的输出创建任务
TaskCreate({
  subject: "技术栈确认",
  description: "确认使用 Next.js + Node.js + PostgreSQL",
  owner: "architect",
  metadata: {priority: "P0", estimated: "1h"}
})

TaskCreate({
  subject: "数据库 schema 设计",
  description: "设计 stocks 表结构，包含 symbol, price, timestamp 等字段",
  owner: "architect",
  addBlockedBy: ["技术栈确认"],  // 依赖关系
  metadata: {priority: "P1", estimated: "2h"}
})

# ... 继续创建其他 12 个任务

# === 阶段5: 开始协作 ===

# 步骤5: Team Lead (architect) 自动认领第一个任务
# 其他 Agents 看到任务列表，等待自己能做的任务解锁

# 当"技术栈确认"完成后，自动解锁：
# - 数据库 schema 设计
# - REST API 设计

# architect 认领这些任务并完成...

# 当"数据库 schema 设计"完成后，解锁：
# - 数据库初始化（backend-dev 可以认领）

# backend-dev: "我看到任务4解锁了，开始认领"
# frontend-dev: "我还在等任务3完成"
```

#### 方式 B：将 Planner 作为 Team 成员

这种方式将 Planner 加入 Team，可以在过程中调整规划。

```bash
# === 步骤1: 创建 Team ===

TeamCreate({
  team_name: "stock-analysis-system",
  description: "股票信息分析系统"
})

# === 步骤2: 先启动 Planner 作为成员 ===

Task({
  team_name: "stock-analysis-system",
  name: "planner",
  subagent_type: "planner",
  prompt: """
  请规划这个股票信息分析系统的实现方案。

  注意：规划完成后，你将作为 team member 继续参与项目，
  在开发过程中如果遇到规划调整需求，请你协助修改任务列表。
  """
})

# Planner 会：
# 1. 读取 config.json（看到自己是成员）
# 2. 创建任务规划
# 3. 调用 TaskCreate 创建任务（因为 Planner 也可以使用工具）
# 4. 完成规划任务后，进入 idle 状态

# === 步骤3: 启动其他成员 ===

Task({
  team_name: "stock-analysis-system",
  name: "backend-dev",
  subagent_type: "general-purpose"
})

Task({
  team_name: "stock-analysis-system",
  name: "frontend-dev",
  subagent_type: "general-purpose"
})

# === 步骤4: 开始执行 ===

# 所有 Agents 都能看到任务列表
# 开始自主认领和协作

# 如果开发过程中需要调整规划：
backend-dev: SendMessage({
  type: "message",
  recipient: "planner",
  content: "我们发现 Alpha Vantage API 有调用限制，需要调整数据获取策略"
})

# planner 收到消息后：
planner: "收到，我来重新规划数据获取方案..."
# 调用 TaskUpdate 修改任务
# 或者创建新的任务
```

### 完整对话示例（方式 A）

实际的对话流程：

```bash
# 你在主会话中：

你: Task({
  subagent_type: "planner",
  prompt: "规划股票信息分析系统"
})

# Planner Agent 返回：

Planner: 我来规划这个项目。

## 规划方案

### 1. 技术栈
- 前端: Next.js 14 + TypeScript + shadcn/ui
- 后端: Node.js + Express + TypeScript
- 数据库: PostgreSQL + Prisma ORM
- 数据源: Alpha Vantage API

### 2. 任务列表（14个任务）

[P0] 任务1: 项目初始化（architect）
- 创建 monorepo 结构
- 配置 TypeScript
- 设置开发环境

[P1] 任务2: 数据库设计（architect）
- 依赖: 任务1
- 设计 stocks, portfolios, users 表

[P1] 任务3: API 接口设计（architect）
- 依赖: 任务1
- 定义 RESTful 规范

[P2] 任务4: 数据库实现（backend-dev）
- 依赖: 任务2
- Prisma schema + migrations

[P2] 任务5: 股票数据 API（backend-dev）
- 依赖: 任务4
- GET /api/stocks/:symbol

[P2] 任务6: 数据分析 API（backend-dev）
- 依赖: 任务4
- POST /api/analyze

[P2] 任务7: 前端项目搭建（frontend-dev）
- 依赖: 任务1
- Next.js + 基础布局

[P3] 任务8: 数据可视化（frontend-dev）
- 依赖: 任务7
- Recharts 图表组件

[P3] 任务9: 用户界面（frontend-dev）
- 依赖: 任务7
- 搜索框、股票详情页

[P3] 任务10: 前后端联调（frontend-dev + backend-dev）
- 依赖: 任务5, 任务8

[P4] 任务11: 单元测试（qa-tester）
- 依赖: 任务6

[P4] 任务12: E2E 测试（qa-tester）
- 依赖: 任务10

[P4] 任务13: 部署配置（architect）
- Docker + docker-compose

[P4] 任务14: 文档编写（architect）
- README + API 文档

### 3. 建议 Team
- architect (1个)
- backend-dev (1个)
- frontend-dev (1个)
- qa-tester (1个)

---

你: 很好！现在我来创建 Team。

你: TeamCreate({
  team_name: "stock-analysis-system"
})

# 系统返回：
✅ Team created: stock-analysis-system
📁 Config: ~/.claude/teams/stock-analysis-system/config.json
📁 Tasks: ~/.claude/tasks/stock-analysis-system/

你: Task({
  team_name: "stock-analysis-system",
  name: "architect",
  subagent_type: "architect"
})

# architect 加入团队...

你: Task({
  team_name: "stock-analysis-system",
  name: "backend-dev",
  subagent_type: "general-purpose"
})

# backend-dev 加入团队...

你: Task({
  team_name: "stock-analysis-system",
  name: "frontend-dev",
  subagent_type: "general-purpose"
})

# frontend-dev 加入团队...

你: Task({
  team_name: "stock-analysis-system",
  name: "qa-tester",
  subagent_type: "tdd-guide"
})

# qa-tester 加入团队...

你: 现在创建任务列表：

你: TaskCreate({
  subject: "项目初始化",
  description: "创建 monorepo 结构，配置 TypeScript",
  owner: "architect"
})

# ... 继续创建其他 13 个任务

你: TaskList()

# 系统返回：
ID  | Subject          | Owner       | Status   | BlockedBy
----|------------------|-------------|----------|-----------
1   | 项目初始化        | architect   | pending  |
2   | 数据库设计        | architect   | pending  | [1]
3   | API 接口设计      | architect   | pending  | [1]
4   | 数据库实现        | backend-dev | pending  | [2]
5   | 股票数据 API      | backend-dev | pending  | [4]
...  | ...              | ...         | ...      | ...

你: 好了，开始工作吧！

# architect 自动认领任务1...
# backend-dev 等待任务4解锁...
# frontend-dev 等待任务7解锁...
```

### 关键点总结

| 方式 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **A: 先规划后创建** | 规划清晰，阶段分离 | 需要 Planner 独立运行 | 大型项目，首次使用 Teams |
| **B: Planner 作为成员** | 灵活调整规划 | Planner 可能闲置 | 需要动态调整的项目 |

### 推荐流程

```
1. Task({subagent_type: "planner", prompt: "..."})
   ↓ Planner 输出规划方案
2. 审查规划，确认可行
   ↓
3. TeamCreate({team_name: "..."})
   ↓ 创建空 Team
4. Task({team_name: "...", name: "architect", ...})
   Task({team_name: "...", name: "backend-dev", ...})
   ...
   ↓ 启动 Agents
5. TaskCreate({subject: "...", ...})
   ...
   ↓ 根据 Planner 输出创建任务
6. Agents 自动开始协作
```

### 关键区别

| 方式 | Planner 何时启动 | Planner 是否在 Team 中 |
|------|----------------|---------------------|
| **A** | 创建 Team 之前 | ❌ 否（独立运行） |
| **B** | 创建 Team 之后 | ✅ 是（作为成员） |

---

## 第七部分：Agent 如何自主拆分任务

**问题：你这里提到让agent自主细化是什么意思？agent不是teams自动创建的吗？这些agent如何知道该对任务规划到什么地步，如何知道任务需要拆分到什么地步**

### Agent 不是"脚本"，是"智能助手"

#### 关键理解

```javascript
// ❌ 错误理解：Agent 是预编程的脚本
function agent(task) {
  if (task.size > "2小时") {
    split(task)  // 写死的规则
  } else {
    do(task)
  }
}

// ✅ 正确理解：Agent 是有推理能力的 AI
Agent 接收任务 → 分析任务 → 判断复杂度 → 决定是否拆分
```

### Agent 的决策流程

```
Agent 认领任务："实现用户认证模块"
    ↓
Agent 阅读任务描述
    ↓
Agent 分析："这个任务包含什么？"
  ├─ 用户注册
  ├─ 用户登录
  ├─ Token 生成
  ├─ Token 验证
  └─ 错误处理
    ↓
Agent 推理："这需要多个步骤，应该拆分"
    ↓
Agent 决策："我要创建子任务"
    ↓
Agent 调用 TaskCreate 工具创建子任务
```

### 实际例子（Agent 的"思考"过程）

```javascript
// 你创建的任务
TaskCreate({
  subject: "实现用户认证模块",
  description: "包括用户注册、登录、JWT 验证",
  owner: "backend-dev"
})

// backend-dev Agent 接收到任务后的"内心独白"：

backend-dev (AI): "让我分析这个任务..."

// 1. Agent 阅读和理解
"任务要求实现用户认证模块，包括：
- 用户注册
- 用户登录
- JWT 验证"

// 2. Agent 评估复杂度
"这个任务包含多个独立功能：
- 注册需要 email 验证、密码加密
- 登录需要密码比对、token 生成
- JWT 验证需要中间件
- 预估需要 8-10 小时
- 一次性实现风险较高"

// 3. Agent 做出决策
"我应该拆分成以下子任务：
1. 设计数据库 User 表结构
2. 实现密码加密工具
3. 实现注册 API
4. 实现登录 API
5. 实现 JWT 工具
6. 实现认证中间件
7. 编写单元测试"

// 4. Agent 执行拆分
for (let subtask of subtasks) {
  TaskCreate({
    subject: subtask.name,
    owner: "backend-dev",
    addBlockedBy: [previousTask]  // 设置依赖
  })
}

// 5. Agent 开始执行第一个子任务
```

### Agent 的"知识"从哪里来？

#### 1. 训练数据（AI 的基础能力）

```
Agent "知道"的事情（来自训练）：
├─ 什么是"用户注册"功能
├─ 注册通常包含哪些步骤
├─ 什么是"合理的任务大小"
├─ 何时需要拆分任务
└─ 如何编写代码实现功能
```

#### 2. System Prompt（行为指导）

```javascript
// Agent 的系统提示词（内置）
"你是一个专业的后端开发工程师。
当你收到任务时：
1. 先分析任务的复杂度和范围
2. 如果任务预计超过 2 小时，考虑拆分
3. 拆分时要考虑：
   - 功能模块的独立性
   - 依赖关系的合理性
   - 每个子任务的可测试性
4. 创建子任务后，按顺序执行"
```

#### 3. 上下文学习（从对话中学习）

```
之前的对话：
你: "我喜欢任务拆得细一点，每个任务 1-2 小时"
Agent: "好的，我会记住这个偏好"

后续任务：
Agent: "根据你的偏好，我将这个任务拆分成 5 个子任务"
```

### 实际演示：Agent 的自主拆分

#### 场景：你创建一个较粗粒度的任务

```bash
# 步骤1: 你创建任务
TaskCreate({
  subject: "实现股票数据 API",
  description: "支持查询单个股票和批量查询",
  owner: "backend-dev"
})

# 步骤2: backend-dev Agent 接收任务
backend-dev: "收到任务：实现股票数据 API"

# 步骤3: Agent 分析任务
backend-dev (思考过程):
"""
分析这个任务：
- 需要两个端点：GET /api/stocks/:symbol 和 POST /api/stocks/batch
- 需要数据库查询逻辑
- 需要参数验证
- 需要错误处理
- 需要编写测试

预估时间：6-8 小时
判断：任务较大，应该拆分

拆分方案：
1. 设置路由结构 (30分钟)
2. 实现查询单个股票端点 (2小时)
3. 实现批量查询端点 (1.5小时)
4. 添加参数验证 (1小时)
5. 编写测试 (1.5小时)
"""

# 步骤4: Agent 自动创建子任务
backend-dev: 调用 TaskCreate 工具：
→ 创建子任务1: "设置 API 路由结构"
→ 创建子任务2: "实现 GET /api/stocks/:symbol" (blockedBy: 1)
→ 创建子任务3: "实现 POST /api/stocks/batch" (blockedBy: 1)
→ 创建子任务4: "添加参数验证" (blockedBy: 1)
→ 创建子任务5: "编写单元测试" (blockedBy: 2, 3)

# 步骤5: Agent 开始执行第一个子任务
backend-dev: TaskUpdate({taskId: 1, status: "in_progress"})
backend-dev: 开始编码...
```

### Agent 如何知道"拆到什么程度"？

#### 判断标准（Agent 内部规则）

```
Agent 会考虑：

1. 时间预估
   ├─ < 30分钟 → 太小，考虑合并
   ├─ 30分钟 - 2小时 ✅ 合适
   └─ > 2小时 → 太大，需要拆分

2. 功能完整性
   ├─ 每个子任务应该是一个完整的功能点
   ├─ 不要把"写一个函数"当任务
   └─ 例如："实现登录接口" ✅ 合适
                 "定义路由变量" ❌ 太小

3. 可测试性
   ├─ 每个子任务应该可以独立测试
   └─ 有明确的验收标准

4. 依赖关系
   ├─ 子任务之间要有清晰的依赖
   └─ 避免循环依赖
```

#### 实际例子

##### ❌ 拆得太细

```javascript
任务: "实现登录接口"
→ 拆分成：
  1. 创建路由文件 (5分钟)
  2. 导入 express (2分钟)
  3. 定义路由变量 (2分钟)
  4. 实现 handler (30分钟)
  ...

问题：每个任务太琐碎，管理成本 > 任务成本
```

##### ✅ 合理的拆分

```javascript
任务: "实现登录接口"
→ 拆分成：
  1. "设置路由结构和中间件" (1小时)
  2. "实现 POST /api/auth/login 端点" (1.5小时)
  3. "添加参数验证" (30分钟)
  4. "编写单元测试" (1小时)

优点：每个任务有意义，可独立完成和测试
```

##### ❌ 拆得太粗

```javascript
任务: "实现用户认证"
→ 没拆分，直接实现 (预估 10小时)

问题：
- 无法跟踪进度
- 失败难以定位
- 协作困难
```

### Agent 拆分任务的两种模式

#### 模式 1：事前拆分（推荐）

```bash
# Agent 认领任务后，立即拆分

Agent 认领任务
    ↓
Agent 分析任务
    ↓
Agent 创建所有子任务
    ↓
Agent 按顺序执行子任务
```

**优点：**
- 一开始就有清晰的路线图
- Team Lead 可以看到完整计划
- 其他 Agents 可以了解进度

#### 模式 2：迭代拆分

```bash
# Agent 做一步，看一步

Agent 认领任务
    ↓
Agent 完成第一步
    ↓
Agent 根据进展决定下一步
    ↓
Agent 动态创建新任务
```

**优点：**
- 灵活应对变化
- 适合探索性任务

### 关键理解：Agent 是"智能的"，不是"预编程的"

#### 类比：人类专家 vs 机器人

```
机器人（预编程）：
if (task == "实现API") {
  step1: doX()
  step2: doY()
  step3: doZ()
}
// 固定的步骤，无法适应变化

人类专家（智能）：
专家接到任务 → 思考 → 计划 → 执行
// 根据实际情况动态调整
```

**Agent 更像人类专家：**
- 有推理能力
- 能判断任务复杂度
- 能做决策
- 能适应变化

### 实际对话示例

```bash
# 你创建一个粗粒度任务
你: TaskCreate({
  subject: "实现用户认证系统",
  description: "包括注册、登录、JWT",
  owner: "backend-dev"
})

# backend-dev 的响应
backend-dev: "收到任务。让我分析一下..."

# Agent 发送消息给你（汇报分析结果）
backend-dev: SendMessage({
  type: "message",
  recipient: "team-lead",  // 发给你
  content: """
  我分析了这个任务，包含以下内容：
  1. 用户注册（需要 email 验证、密码加密）
  2. 用户登录（需要密码比对、token 生成）
  3. JWT 验证（需要中间件）

  预估时间：10小时

  建议拆分成 7 个子任务：
  1. 设计 User 表结构 (1h)
  2. 实现密码加密工具 (1h)
  3. 实现注册 API (2h)
  4. 实现登录 API (2h)
  5. 实现 JWT 工具 (1.5h)
  6. 实现认证中间件 (1h)
  7. 编写测试 (1.5h)

  是否同意这个拆分方案？
  """
})

# 你回复
你: "同意，开始执行吧"

# backend-dev 开始创建子任务并执行
backend-dev:
→ TaskCreate({subject: "设计 User 表结构", ...})
→ TaskCreate({subject: "实现密码加密工具", addBlockedBy: ["设计 User 表结构"], ...})
→ ...
→ TaskUpdate({taskId: 1, status: "in_progress"})
→ 开始编码...
```

### 总结

#### 回答关键问题

| 问题 | 答案 |
|------|------|
| **Agent 如何知道拆分到什么程度？** | Agent 有**推理能力**，会分析任务复杂度、功能点、预估时间 |
| **Agent 的"知识"从哪里来？** | 1. 训练数据（基础软件工程知识）<br>2. System Prompt（行为指导）<br>3. 上下文学习（从对话中了解偏好） |
| **这需要我配置吗？** | **不需要**，Agent 内置了这些能力。但你可以通过对话**调整偏好** |

#### 核心理解

**Agent = AI（有智能）≠ 脚本（预编程）**

- Agent 能**理解任务**
- Agent 能**判断复杂度**
- Agent 能**做出决策**
- Agent 能**动态调整**

---

## 第八部分：分层 Teams 与中途创建 Team

**问题：给我讲解一下你提到的分层teams，这要如何做。还有在一个进行到一半的项目中如何创建一个teams来继续后续的工作，还是teams只能在项目创建时才有效，一旦项目开始了就不能在创建teams了？**

### 第一部分：分层 Teams（Hierarchy of Teams）

#### 什么是分层 Teams？

```
传统 Teams（单层）：
一个 Team 包含多个 Agents

分层 Teams（多层）：
主 Team（协调层）
  ├─ 子 Team 1（前端团队）
  ├─ 子 Team 2（后端团队）
  └─ 子 Team 3（测试团队）
```

#### 架构示例

```
┌─────────────────────────────────────┐
│   Project Coordination Team (主团队) │
│   Coordinator (project-manager)      │
│   Planner (planner)                  │
│   Architect (architect)              │
└──────────┬──────────────────────────┘
           │
           ├──────────────────────────────┐
           │                              │
    ┌──────▼──────┐            ┌─────────▼────────┐
    │ Frontend Team│            │  Backend Team    │
    │ (子团队1)    │            │  (子团队2)       │
    ├─────────────┤            ├──────────────────┤
    │ frontend-dev│            │ backend-dev      │
    │ ui-designer │            │ database-dev     │
    │ qa-frontend │            │ api-dev          │
    └─────────────┘            └──────────────────┘
           │                              │
           └──────────┬───────────────────┘
                      │
                ┌─────▼──────┐
                │ Test Team  │
                │ (子团队3)   │
                ├────────────┤
                │ qa-tester  │
                │ e2e-tester │
                └────────────┘
```

#### 如何实现分层 Teams？

##### 步骤 1：创建主 Team

```bash
# 创建协调层 Team
TeamCreate({
  team_name: "project-coordination",
  description: "项目协调和总体规划",
  agent_type: "general-purpose"
})

# 启动协调层的 Agents
Task({
  team_name: "project-coordination",
  name: "project-manager",
  subagent_type: "general-purpose",
  prompt: """
  你是项目经理，负责：
  1. 协调各个子团队的工作
  2. 监控整体进度
  3. 处理跨团队的依赖和冲突
  4. 向用户汇报项目状态

  你下属三个子团队：
  - frontend-team（前端）
  - backend-team（后端）
  - test-team（测试）
  """
})

Task({
  team_name: "project-coordination",
  name: "planner",
  subagent_type: "planner",
  prompt: "负责规划整个项目的任务分配给各个子团队"
})

Task({
  team_name: "project-coordination",
  name: "architect",
  subagent_type: "architect",
  prompt: "负责整体架构设计，确保前后端架构一致性"
})
```

##### 步骤 2：创建子 Teams

```bash
# 创建前端子团队
TeamCreate({
  team_name: "frontend-team",
  description: "前端开发团队",
  agent_type: "general-purpose"
})

Task({
  team_name: "frontend-team",
  name: "frontend-lead",
  subagent_type: "general-purpose",
  prompt: "前端团队负责人，直接向 project-manager 汇报"
})

Task({
  team_name: "frontend-team",
  name: "ui-developer",
  subagent_type: "general-purpose",
  prompt: "负责 UI 组件开发"
})

Task({
  team_name: "frontend-team",
  name: "frontend-tester",
  subagent_type: "tdd-guide",
  prompt: "负责前端测试"
})

# 创建后端子团队
TeamCreate({
  team_name: "backend-team",
  description: "后端开发团队",
  agent_type: "general-purpose"
})

Task({
  team_name: "backend-team",
  name: "backend-lead",
  subagent_type: "general-purpose",
  prompt: "后端团队负责人，直接向 project-manager 汇报"
})

Task({
  team_name: "backend-team",
  name: "api-developer",
  subagent_type: "general-purpose",
  prompt: "负责 API 开发"
})

Task({
  team_name: "backend-team",
  name: "database-developer",
  subagent_type: "general-purpose",
  prompt: "负责数据库开发"
})

# 创建测试子团队
TeamCreate({
  team_name: "test-team",
  description: "测试团队",
  agent_type: "tdd-guide"
})

Task({
  team_name: "test-team",
  name: "qa-lead",
  subagent_type: "tdd-guide",
  prompt: "测试负责人，直接向 project-manager 汇报"
})

Task({
  team_name: "test-team",
  name: "e2e-tester",
  subagent_type: "e2e-runner",
  prompt: "负责端到端测试"
})
```

##### 步骤 3：建立跨 Team 通信

```bash
# 主 Team 分配任务给子 Team

# project-manager 发送任务给 frontend-lead
project-manager: SendMessage({
  type: "message",
  recipient: "frontend-lead",
  content: """
  请前端团队完成以下任务：
  1. 实现用户登录页面
  2. 实现数据可视化组件
  3. 与后端联调 API

  预计时间：2周
  优先级：P0
  """
})

# frontend-lead 收到后，在自己的 Team 内分配任务
frontend-lead: TaskCreate({
  subject: "实现用户登录页面",
  owner: "ui-developer"
})

frontend-lead: TaskCreate({
  subject: "实现数据可视化组件",
  owner: "ui-developer"
})
```

##### 步骤 4：子 Team 向主 Team 汇报

```bash
# 子团队完成任务后汇报
frontend-lead: SendMessage({
  type: "message",
  recipient: "project-manager",
  content: """
  前端团队任务完成：
  ✅ 用户登录页面
  ✅ 数据可视化组件
  ⚠️ 与后端联调中，遇到 API 响应格式问题

  需要协调：请后端团队协助解决 API 问题
  """
})

# project-manager 协调
project-manager: SendMessage({
  type: "message",
  recipient: "backend-lead",
  content: "前端反馈 API 响应格式问题，请协助解决"
})
```

#### 分层 Teams 的实际使用场景

##### 场景 1：大型微服务项目

```bash
Main Team (项目协调)
  ├─ User Service Team (用户服务)
  ├─ Payment Service Team (支付服务)
  ├─ Order Service Team (订单服务)
  └─ Notification Service Team (通知服务)
```

##### 场景 2：多平台开发

```bash
Main Team (产品协调)
  ├─ Web Team (Web 应用)
  ├─ iOS Team (iOS 应用)
  ├─ Android Team (Android 应用)
  └─ Backend Team (共享后端)
```

#### 分层 Teams 的优势

| 优势 | 说明 |
|------|------|
| **职责分离** | 每个 Team 专注于自己的领域 |
| **并行开发** | 多个 Team 同时工作，互不干扰 |
| **灵活管理** | 可以单独调整某个 Team 的规模 |
| **故障隔离** | 一个 Team 的问题不影响其他 Teams |
| **可扩展性** | 需要时可以添加新的子 Team |

---

### 第二部分：中途创建 Team

#### 核心答案：✅ 完全可以！

**Teams 可以在任何时候创建，不限于项目开始时。**

实际上，**中途创建 Team 往往更常见**，因为：
- 项目开始时需求不明确
- 先由你自己或单个 Agent 探索
- 需求清晰后再组建 Team

#### 时机 1：项目进行到一半，需要加速

```bash
# 背景：你已经自己开发了一段时间

当前状态：
- 你已经完成了基础架构
- 已经有了基本的代码结构
- 后续还有很多功能要开发

问题：
- 一个人开发太慢
- 需要并行开发多个模块

解决：中途创建 Team
```

##### 具体操作步骤

```bash
# 步骤 1：评估当前状态
你: "当前项目情况：
- 已完成：项目初始化、数据库设计
- 进行中：后端 API（完成 50%）
- 待开发：前端、测试、部署

我需要创建 Team 来加速后续工作"

# 步骤 2：创建 Team
TeamCreate({
  team_name: "my-project-continuation",
  description: "接续现有项目开发"
})

# 步骤 3：使用 Planner 分析当前状态
Task({
  subagent_type: "planner",
  prompt: """
  当前项目状态：
  - 已完成：项目初始化、数据库 schema
  - 进行中：后端 API（完成 50%）

  代码位置：D:\\projects\\my-app

  请分析：
  1. 剩余工作量
  2. 需要多少 Agents？
  3. 如何划分任务？
  4. 如何与现有代码集成？
  """
})

# Planner 会：
# 1. 读取现有代码（使用 Read、Glob 等工具）
# 2. 分析项目结构
# 3. 评估剩余工作
# 4. 规划任务分配

# 步骤 4：启动 Agents
Task({
  team_name: "my-project-continuation",
  name: "backend-dev",
  subagent_type: "general-purpose",
  prompt: """
  继续开发后端 API。
  当前代码在：D:\\projects\\my-app\\backend

  已完成：
  - 用户注册 API
  - 数据库连接

  待完成：
  - 用户登录 API
  - 股票数据 API
  - 数据分析 API

  请先阅读现有代码，理解架构后继续开发。
  """
})

Task({
  team_name: "my-project-continuation",
  name: "frontend-dev",
  subagent_type: "general-purpose",
  prompt: """
  从头开发前端部分。
  后端 API 文档：D:\\projects\\my-app\\docs\\api.md

  请与 backend-dev 协调，完成前端开发。
  """
})

# 步骤 5：创建任务
TaskCreate({
  subject: "完成用户登录 API",
  description: "参考已有的注册 API 实现",
  owner: "backend-dev",
  metadata: {
    codebase: "D:\\projects\\my-app\\backend",
    reference: "auth-controller.ts#register"
  }
})

TaskCreate({
  subject: "搭建前端项目",
  description: "使用 Next.js，与后端 API 对接",
  owner: "frontend-dev"
})
```

#### 时机 2：需求变更，需要更多专业人员

```bash
# 背景：项目进行中，突然需要安全审计

当前状态：
- 2 个 Agents 正在开发
- 项目即将完成

需求变更：
- 客户要求安全审计
- 需要添加安全专家

解决：动态添加 Agent
```

##### 具体操作

```bash
# 当前 Team 只有 2 个 Agents
config.json:
{
  "members": [
    {"name": "dev-1", "agentType": "general-purpose"},
    {"name": "dev-2", "agentType": "general-purpose"}
  ]
}

# 添加安全审查 Agent
Task({
  team_name: "my-project",
  name: "security-reviewer",
  subagent_type: "security-reviewer",
  prompt: "审查现有代码的安全问题"
})

# config.json 自动更新为：
{
  "members": [
    {"name": "dev-1", ...},
    {"name": "dev-2", ...},
    {"name": "security-reviewer", "agentType": "security-reviewer"}
  ]
}

# security-reviewer 自动：
# 1. 读取 config.json，看到队友
# 2. 查看任务列表
# 3. 开始审查代码
```

#### 时机 3：项目遇到瓶颈，需要求助

```bash
# 背景：某个 Agent 卡住了

backend-dev: SendMessage({
  type: "message",
  recipient: "team-lead",
  content: """
  我遇到了性能优化问题。
  数据库查询太慢，需要数据库专家。
  """
})

# 你决定添加数据库专家
你: Task({
  team_name: "my-project",
  name: "database-expert",
  subagent_type: "general-purpose",
  prompt: "数据库性能优化专家"
})

# database-expert 加入并协助
```

---

### 第三部分：纯对话格式的完整示例

下面以股票分析系统为例，展示完整的对话流程，不使用任何代码块格式。

#### 完整对话：创建股票分析系统的分层 Teams

##### 第一步：创建主协调团队

**你：** 我要创建一个股票分析系统的协调团队，名字叫 stock-system-coordination

**系统：** 好的，团队创建成功！团队配置文件已生成，任务目录已创建。现在可以向团队添加成员了。

---

**你：** 启动一个项目经理 agent 叫 project-manager，类型用 general-purpose，告诉它负责协调整个项目

**系统：** Agent 启动成功！

**project-manager：** 收到！我是项目经理。我已经加入了 stock-system-coordination 团队。当前团队只有我一个人。我需要规划项目任务还是先创建子团队？

---

**你：** 再启动一个规划师 agent 叫 planner，类型用 planner

**系统：** Agent 启动成功！

**planner：** 让我来规划这个股票分析系统。

我建议的系统架构：

系统分为三层：
1. 前端层 - 负责用户界面
2. 后端层 - 负责服务端逻辑
3. 数据层 - 负责数据处理和存储

我建议创建三个子团队：

第一个子团队叫 frontend-team（前端团队），需要 2 个人：
- frontend-lead：前端负责人
- ui-developer：UI 开发工程师

职责包括：股票查询界面、数据可视化图表、用户交互

第二个子团队叫 backend-team（后端团队），需要 2 个人：
- backend-lead：后端负责人
- api-developer：API 开发工程师

职责包括：RESTful API、业务逻辑、前后端对接

第三个子团队叫 data-team（数据处理团队），需要 2 个人：
- data-engineer：数据工程师
- database-admin：数据库管理

职责包括：外部数据源集成（Alpha Vantage API）、数据存储和优化、数据分析算法

团队协作流程是：
data-team → backend-team → frontend-team
原始数据 → API 服务 → 用户界面

需要我现在开始创建这些子团队吗？

---

##### 第二步：创建前端子团队

**你：** 好的，现在创建前端团队，名字叫 frontend-team

**系统：** 前端团队创建成功！

---

**你：** 启动 frontend-lead 作为前端负责人，类型用 general-purpose，告诉它负责前端开发，技术栈是 Next.js，需要向项目经理汇报

**系统：** Agent 启动成功！

**frontend-lead：** 收到！我是前端团队负责人。我已经加入了 frontend-team。当前团队成员只有我一个。我需要等待 project-manager 分配任务，还是现在就开始规划前端工作？

---

**你：** 再启动一个 ui-developer，类型用 general-purpose，告诉它听从 frontend-lead 的指挥

**系统：** Agent 启动成功！

---

##### 第三步：创建后端子团队

**你：** 现在创建后端团队，名字叫 backend-team

**系统：** 后端团队创建成功！

---

**你：** 启动 backend-lead 作为后端负责人，类型用 general-purpose，告诉它向 project-manager 汇报

**系统：** Agent 启动成功！

**backend-lead：** 收到！我是后端团队负责人。我已经加入了 backend-team。等待任务分配。

---

**你：** 再启动一个 api-developer，类型用 general-purpose

**系统：** Agent 启动成功！

---

##### 第四步：创建数据处理子团队

**你：** 现在创建数据处理团队，名字叫 data-team

**系统：** 数据处理团队创建成功！

---

**你：** 启动 data-engineer 作为数据工程师，类型用 general-purpose

**系统：** Agent 启动成功！

**data-engineer：** 收到！我是数据工程师。我已经加入了 data-team。等待任务分配。

---

**你：** 再启动一个 database-admin 作为数据库管理员，类型用 general-purpose

**系统：** Agent 启动成功！

---

##### 第五步：项目经理分配任务

**project-manager：** 现在所有子团队都创建完成了。让我开始分配任务。

project-manager 发送消息给 data-engineer：

"请数据处理团队完成以下任务：

优先级最高：
1. 集成 Alpha Vantage API 来获取股票数据
2. 设计数据库的 stocks 表结构
3. 实现数据存储逻辑

预计时间：1 周

完成后请向我汇报。"

---

**project-manager：** 发送消息给 backend-lead：

"请后端团队准备以下工作：

优先级高：
1. 设计 RESTful API 的规范
2. 等待 data-team 完成数据库后开始 API 开发

注意：需要先与 data-team 协调好数据格式。"

---

**project-manager：** 发送消息给 frontend-lead：

"请前端团队准备以下工作：

优先级高：
1. 搭建 Next.js 项目框架
2. 设计基础的 UI 布局
3. 等待 backend-team 完成 API 规范后开始对接"

---

##### 第六步：各团队开始工作

**data-engineer：** 收到任务！我现在在 data-team 中。让我创建任务列表并开始执行。

data-engineer 创建了第一个任务：研究 Alpha Vantage API，优先级最高，预计 2 小时

data-engineer 创建了第二个任务：设计 stocks 表结构，依赖第一个任务，分配给 database-admin

data-engineer 创建了第三个任务：实现 API 集成，依赖第二个任务

data-engineer 创建了第四个任务：实现数据存储，依赖第二个任务，分配给 database-admin

现在我开始执行第一个任务...

---

**frontend-lead：** 收到任务！让我创建前端任务列表。

frontend-lead 创建了任务：初始化 Next.js 项目

frontend-lead 创建了任务：设计页面布局，依赖初始化任务，分配给 ui-developer

frontend-lead 创建了任务：实现搜索组件，依赖布局设计任务，分配给 ui-developer

我现在开始初始化项目...

---

##### 第七步：跨团队协作

**data-engineer：** 完成了 Alpha Vantage API 研究和数据库设计！

data-engineer 发送消息给 project-manager：

"data-team 任务完成：
- Alpha Vantage API 已研究完毕
- 数据库表结构已设计

数据格式包括：
- symbol：股票代码
- price：价格
- volume：交易量
- timestamp：时间戳

请通知 backend-team 可以开始 API 开发了。"

---

**project-manager：** 收到！立即通知 backend-team。

project-manager 发送消息给 backend-lead：

"data-team 已完成数据库设计。

数据格式如下：
- symbol：字符串类型
- price：数字类型
- volume：数字类型
- timestamp：日期类型

请开始 API 开发工作。"

---

**backend-lead：** 收到通知！数据库设计已完成。

让我规划 API 任务：

backend-lead 创建了任务：设计 API 端点，包括查询单个股票和批量查询

backend-lead 创建了任务：实现查询单个股票 API，依赖设计任务，分配给 api-developer

backend-lead 创建了任务：实现批量查询 API，依赖设计任务，分配给 api-developer

backend-lead 发送消息给 frontend-lead：

"我们正在开发 API，预计 2 天完成。

API 端点包括：
- 获取单个股票：GET /api/stocks/代码
- 批量查询：POST /api/stocks/batch

请前端团队准备对接工作。"

---

**frontend-lead：** 收到！我们等你们完成后对接。

ui-developer，我们先使用 Mock 数据开发 UI，等 API 好了再替换成真实调用。

frontend-lead 创建了任务：使用 Mock 数据开发 UI，分配给 ui-developer

---

##### 第八步：查看进度

**你：** 汇报一下当前进度

**project-manager：** 整体进度汇报：

data-team：100% 完成
- API 研究完成
- 数据库设计完成
- 数据集成完成

backend-team：进行中，70% 完成
- API 设计完成
- API 实现进行中

frontend-team：进行中，60% 完成
- 项目初始化完成
- UI 开发进行中

整体项目进度：约 70%

预计完成时间：3 天

---

##### 第九步：处理问题

**ui-developer：** 我在对接 API 时发现问题！

ui-developer 发送消息给 frontend-lead：

"API 返回的数据格式与文档不符。

文档说格式是：{symbol, price, volume}
实际返回是：{data: {symbol, price, volume}}

多了一层 data 包装，需要协调。"

---

**frontend-lead：** 收到，我来协调。

frontend-lead 发送消息给 project-manager：

"前端团队发现 API 问题：

backend-team 的 API 返回格式多了一层 data 包装。

请协调解决方案：
选项 1：前端适配，多解析一层
选项 2：后端修改，去掉 data 包装

我建议选项 2，保持数据格式简洁。"

---

**project-manager：** 收到协调请求。

project-manager 发送消息给 backend-lead：

"前端反馈 API 返回格式问题。

当前返回：{data: {symbol, price, volume}}
期望返回：{symbol, price, volume}

请修改 API，去掉 data 包装层。"

---

**backend-lead：** 收到，立即修改。

api-developer，请修改 API 的响应格式，去掉 data 包装。

（api-developer 修改代码中...）

backend-lead 发送消息给 frontend-lead：

"API 已修改完成，返回格式现在是：{symbol, price, volume}

请重新测试对接。"

---

**frontend-lead：** 收到！测试中...

frontend-lead 发送消息给 project-manager：

"API 对接成功！问题已解决。

前端继续开发其他功能..."

---

##### 第十步：项目完成

**data-engineer：** 发送消息给 project-manager：data-team 所有任务完成！

**backend-lead：** 发送消息给 project-manager：backend-team 所有任务完成！

**frontend-lead：** 发送消息给 project-manager：frontend-team 所有任务完成！

---

**project-manager：** 项目完成报告：

所有子团队状态：
- data-team：100% 完成
- backend-team：100% 完成
- frontend-team：100% 完成

交付物包括：
1. PostgreSQL 数据库
2. Node.js + Express 后端 API
3. Next.js 前端应用
4. 完整的测试套件

项目统计：
- 总任务数：42 个
- 完成时间：2 周
- 团队规模：9 个 agents

---

##### 第十一步：清理团队

**你：** 很好！现在清理所有团队。先通知所有 agents 准备关闭

**你：** 发送广播消息：项目完成！请所有 agents 准备关闭。

---

**你：** 逐个关闭 data-team 的成员

**你：** 发送关闭请求给 data-engineer：感谢你的工作，请关闭

**data-engineer：** 同意关闭，再见！

**你：** 发送关闭请求给 database-admin：感谢你的工作，请关闭

**database-admin：** 同意关闭，再见！

---

**你：** 关闭 data-team 团队

**系统：** data-team 已删除

---

**你：** 同样方式关闭 backend-team 和 frontend-team

**系统：** backend-team 已删除
**系统：** frontend-team 已删除

---

**你：** 最后关闭主团队 stock-system-coordination

**你：** 发送关闭请求给 project-manager：关闭主团队

**project-manager：** 同意关闭，项目圆满完成！

**你：** 发送关闭请求给 planner：感谢规划，请关闭

**planner：** 同意关闭！

**系统：** stock-system-coordination 已删除

---

**系统：** 所有团队已清理，资源已释放。

---

**你：** 完成！

---

### 关键要点总结

#### 分层 Teams

| 要点 | 说明 |
|------|------|
| **架构** | 主 Team 协调多个子 Teams |
| **通信** | 通过 SendMessage 跨 Team 通信 |
| **适用** | 大型项目、微服务、多平台 |
| **复杂度** | 较高，建议有经验后使用 |

#### 中途创建 Team

| 要点 | 说明 |
|------|------|
| **可以吗？** | ✅ 完全可以，而且很常见 |
| **最佳时机** | 需求清晰后、需要加速时、遇到瓶颈时 |
| **关键步骤** | 1. 总结现状<br>2. 创建 Team<br>3. 让 Planner 分析<br>4. 启动 Agents<br>5. 创建任务 |
| **注意事项** | 确保新 Agents 能理解现有代码 |

#### 实践建议

##### 对于分层 Teams

建议：
1. 先掌握单层 Team
2. 从 2 层结构开始（1 主 + 2 子）
3. 不要一开始就搞复杂的层级

避免：
- 创建过多子 Team（管理成本高）
- 层级过深（超过 3 层）

##### 对于中途创建 Team

建议：
1. 做好项目状态文档
2. 代码要有清晰的注释
3. 让新 Agent 先阅读现有代码

避免：
- 在代码混乱时创建 Team
- 没有文档就直接加入
- 期望 Agent 自动理解所有东西

---

## 第九部分：任务管理工具详解

**问题：详细了解 TaskList、TaskGet、TaskUpdate 等任务管理工具的使用方法**

### 一、TaskList - 查看任务列表

#### 基本用法

```bash
TaskList()
```

#### 输出示例

```bash
# 基本输出
ID  | Subject          | Owner        | Status       | BlockedBy
----|------------------|--------------|--------------|----------
1   | 项目初始化        | architect    | completed    | []
2   | 数据库设计        | architect    | completed    | [1]
3   | API 设计          | architect    | in_progress  | [1]
4   | 数据库实现        | backend-dev  | pending      | [2]
5   | 股票数据 API      | backend-dev  | pending      | [4]
6   | 批量查询 API      | backend-dev  | pending      | [4]
7   | 前端初始化        | frontend-dev | pending      | [1]
8   | UI 组件开发       | frontend-dev | pending      | [7]
9   | 前后端联调        | frontend-dev | pending      | [5, 8]
10  | 单元测试          | qa-tester    | pending      | [5, 8]
```

#### 字段说明

| 字段 | 说明 | 可能的值 |
|------|------|---------|
| **ID** | 任务唯一标识 | 数字 |
| **Subject** | 任务标题 | 文本 |
| **Owner** | 负责人 | Agent 名称或空 |
| **Status** | 任务状态 | `pending`, `in_progress`, `completed`, `deleted` |
| **BlockedBy** | 依赖的任务 ID 列表 | 数组，如 `[1, 2]` |

#### 状态说明

```bash
pending      # 待开始（等待认领或等待依赖满足）
in_progress  # 进行中（Agent 正在执行）
completed    # 已完成
deleted      # 已删除
```

#### 使用场景

##### 场景 1：检查整体进度

```bash
你: TaskList()

输出：
ID  | Subject       | Owner    | Status       | BlockedBy
----|---------------|----------|--------------|----------
1   | 任务1         | agent-1  | completed    | []
2   | 任务2         | agent-2  | in_progress  | [1]
3   | 任务3         | agent-1  | pending      | [1]
4   | 任务4         | agent-2  | pending      | [2,3]

你: 分析：
- 任务1 已完成 ✅
- 任务2 正在进行 🔄
- 任务3 等待任务1（已满足，可以开始）
- 任务4 等待任务2和3（还需等待）

整体进度：25% (1/4 完成)
```

##### 场景 2：查找可执行的任务

```bash
你: TaskList()

你: 识别可执行任务：
- pending + BlockedBy=[] 的任务可以立即执行
- 在上面的例子中：任务3 可以执行
```

##### 场景 3：检查 Agent 工作负载

```bash
你: TaskList()

输出：
ID  | Subject    | Owner      | Status
----|------------|------------|-------------
1   | 任务1      | agent-1    | in_progress
2   | 任务2      | agent-1    | pending
3   | 任务3      | agent-1    | pending
4   | 任务4      | agent-2    | completed

你: 分析：
- agent-1 很忙（1个进行中 + 2个待办）
- agent-2 很闲（已完成所有任务）
- 可以考虑重新分配
```

---

### 二、TaskGet - 获取任务详情

#### 基本用法

```bash
TaskGet({taskId: "1"})
```

#### 完整输出示例

```bash
TaskGet({taskId: "3"})

输出：
{
  "id": "3",
  "subject": "实现用户登录 API",
  "description": "实现 POST /api/auth/login 端点

  要求：
  - 接收 email 和 password
  - 验证用户凭证
  - 返回 JWT token
  - 错误处理",

  "status": "pending",
  "owner": "backend-dev",

  "blockedBy": ["1", "2"],
  "blocks": ["4", "5"],

  "metadata": {
    "priority": "P0",
    "estimated": "2h",
    "complexity": "medium",
    "acceptanceCriteria": [
      "正确返回 token",
      "错误时返回 401",
      "密码错误时提示明确"
    ]
  },

  "createdAt": "2026-02-07T10:00:00Z",
  "updatedAt": "2026-02-07T11:30:00Z",

  "history": [
    {
      "action": "created",
      "timestamp": "2026-02-07T10:00:00Z",
      "user": "team-lead"
    },
    {
      "action": "updated",
      "field": "addBlockedBy",
      "value": ["1", "2"],
      "timestamp": "2026-02-07T11:30:00Z",
      "user": "planner"
    }
  ]
}
```

#### 字段详解

##### 基本信息

```bash
id           # 任务 ID
subject      # 任务标题（简短）
description  # 详细描述（可以很长）
```

##### 状态信息

```bash
status       # 当前状态
owner        # 负责人（可能是空的，表示无人认领）
```

##### 依赖关系

```bash
blockedBy    # 依赖的任务（必须完成后才能开始）
blocks       # 阻塞的任务（自己在做，别人要等）
```

##### 元数据

```bash
metadata     # 自定义数据
  - priority     # 优先级（P0, P1, P2, P3）
  - estimated    # 预估时间
  - complexity   # 复杂度
  - acceptanceCriteria  # 验收标准
```

##### 时间信息

```bash
createdAt    # 创建时间
updatedAt    # 最后更新时间
```

##### 历史记录

```bash
history      # 操作历史
  - action       # 操作类型（created, updated, assigned）
  - field        # 修改的字段
  - value        # 修改的值
  - timestamp    # 时间戳
  - user         # 操作者
```

#### 使用场景

##### 场景 1：了解任务详情

```bash
你: TaskGet({taskId: "5"})

你: 查看：
- 这个任务要做什么？（subject, description）
- 谁负责？（owner）
- 为什么还没开始？（检查 blockedBy）
- 优先级如何？（metadata.priority）
```

##### 场景 2：诊断任务为什么卡住

```bash
你: TaskList()  # 看到任务3 是 pending

你: TaskGet({taskId: "3"})

输出：
{
  "blockedBy": ["1", "2"],
  ...
}

你: 检查：
TaskGet({taskId: "1"})  # 状态？
TaskGet({taskId: "2"})  # 状态？

发现任务1 还是 in_progress
→ 所以任务3 在等任务1完成
```

##### 场景 3：查看验收标准

```bash
你: TaskGet({taskId: "7"})

输出：
{
  "metadata": {
    "acceptanceCriteria": [
      "支持多选",
      "实时搜索",
      "显示结果数量"
    ]
  }
}

你: 知道什么时候算完成
```

---

### 三、TaskUpdate - 更新任务

#### 基本语法

```bash
TaskUpdate({
  taskId: "任务ID",
  字段名: "新值"
})
```

#### 可修改的字段

##### 1. status - 更新状态

```bash
# 开始任务
TaskUpdate({
  taskId: "3",
  status: "in_progress"
})

# 完成任务
TaskUpdate({
  taskId: "3",
  status: "completed"
})

# 删除任务
TaskUpdate({
  taskId: "3",
  status: "deleted"
})
```

##### 2. owner - 分配任务

```bash
# 分配给 Agent
TaskUpdate({
  taskId: "5",
  owner: "backend-dev"
})

# 取消分配（让任务无人认领）
TaskUpdate({
  taskId: "5",
  owner: null
})
```

##### 3. addBlockedBy - 添加依赖

```bash
# 添加单个依赖
TaskUpdate({
  taskId: "3",
  addBlockedBy: ["1"]
})

# 添加多个依赖
TaskUpdate({
  taskId: "3",
  addBlockedBy: ["1", "2", "4"]
})
```

##### 4. subject - 修改标题

```bash
TaskUpdate({
  taskId: "3",
  subject: "实现用户登录和注册 API（扩展）"
})
```

##### 5. description - 修改描述

```bash
TaskUpdate({
  taskId: "3",
  description: "更新后的详细描述..."
})
```

##### 6. metadata - 更新元数据

```bash
# 更新优先级
TaskUpdate({
  taskId: "3",
  metadata: {
    "priority": "P0"
  }
})

# 合并元数据（保留其他字段）
TaskUpdate({
  taskId: "3",
  "metadata.priority": "P0",  # 只更新 priority
  "metadata.estimated": "3h"  # 只更新 estimated
})
```

#### 使用场景

##### 场景 1：Agent 认领任务

```bash
# Agent 看到 TaskList()
agent-1: 发现任务3 是 pending，blockedBy=[]

agent-1: 我来认领这个任务

agent-1: TaskUpdate({
  taskId: "3",
  status: "in_progress",
  owner: "agent-1"
})
```

##### 场景 2：完成任务

```bash
agent-1: 任务完成了！

agent-1: TaskUpdate({
  taskId: "3",
  status: "completed"
})

# 系统自动：
# - 检查是否有其他任务依赖任务3
# - 如果有，通知相关 Agents
# - 更新任务列表
```

##### 场景 3：设置依赖关系

```bash
你: 创建任务时没设置依赖，现在补充

你: TaskUpdate({
  taskId: "5",
  addBlockedBy: ["3", "4"]
})

# 结果：任务5 现在依赖任务3和4
```

##### 场景 4：调整任务分配

```bash
你: TaskList() 显示：

agent-1:
  - 任务1 in_progress
  - 任务2 pending
  - 任务3 pending

agent-2:
  - 任务4 completed

你: agent-2 太闲了，重新分配

你: TaskUpdate({
  taskId: "2",
  owner: "agent-2"
})

你: TaskUpdate({
  taskId: "3",
  owner: "agent-2"
})

# 现在负载更均衡
```

##### 场景 5：修复循环依赖

```bash
你: 发现问题

TaskGet({taskId: "1"})
→ blockedBy: ["2"]

TaskGet({taskId: "2"})
→ blockedBy: ["1"]

你: 循环依赖！需要修复

你: TaskUpdate({
  taskId: "1",
  addBlockedBy: []  # 移除对任务2的依赖
})

# 问题解决
```

---

### 四、实际工作流程示例

#### 完整的任务生命周期

```bash
# === 步骤 1：创建任务 ===
你: TaskCreate({
  subject: "实现登录 API",
  description: "实现 POST /api/auth/login",
  owner: "backend-dev"
})

# === 步骤 2：查看任务列表 ===
你: TaskList()

ID | Subject        | Owner       | Status  | BlockedBy
---|----------------|-------------|---------|----------
1  | 实现登录 API    | backend-dev | pending | []

# === 步骤 3：Agent 认领任务 ===
backend-dev: TaskUpdate({
  taskId: "1",
  status: "in_progress"
})

# === 步骤 4：查看进度 ===
你: TaskList()

ID | Subject        | Owner       | Status       | BlockedBy
---|----------------|-------------|--------------|----------
1  | 实现登录 API    | backend-dev | in_progress  | []

# === 步骤 5：Agent 完成任务 ===
backend-dev: TaskUpdate({
  taskId: "1",
  status: "completed"
})

# === 步骤 6：验证完成 ===
你: TaskList()

ID | Subject        | Owner       | Status    | BlockedBy
---|----------------|-------------|-----------|----------
1  | 实现登录 API    | backend-dev | completed | []
```

#### 依赖关系的完整流程

```bash
# === 创建有依赖的任务 ===
你: TaskCreate({
  subject: "设计数据库",
  owner: "architect"
})

你: TaskCreate({
  subject: "实现 API",
  addBlockedBy: ["设计数据库"],
  owner: "backend-dev"
})

你: TaskCreate({
  subject: "前端对接",
  addBlockedBy: ["实现 API"],
  owner: "frontend-dev"
})

# === 查看依赖链 ===
你: TaskList()

ID | Subject      | Owner        | Status  | BlockedBy
---|--------------|--------------|---------|----------
1  | 设计数据库    | architect    | pending | []
2  | 实现 API      | backend-dev  | pending | [1]
3  | 前端对接      | frontend-dev | pending | [2]

# === 任务执行流程 ===
architect: TaskUpdate({taskId: "1", status: "in_progress"})
architect: TaskUpdate({taskId: "1", status: "completed"})
           ↓
backend-dev: 看到任务1完成，任务2 解锁
backend-dev: TaskUpdate({taskId: "2", status: "in_progress"})
backend-dev: TaskUpdate({taskId: "2", status: "completed"})
           ↓
frontend-dev: 看到任务2完成，任务3 解锁
frontend-dev: TaskUpdate({taskId: "3", status: "in_progress"})
```

---

### 五、高级技巧

#### 技巧 1：批量查看任务

```bash
# 查看特定 Agent 的任务
你: TaskList()
然后筛选 owner 字段

# 查看所有 pending 任务
筛选 status = "pending"

# 查看所有可执行任务
筛选 status = "pending" AND blockedBy = []
```

#### 技巧 2：使用 metadata 组织任务

```bash
# 创建任务时添加标签
TaskCreate({
  subject: "实现登录功能",
  metadata: {
    "priority": "P0",
    "category": "authentication",
    "estimated": "3h",
    "assignedTo": "backend-dev"
  }
})

# 后续可以按 category 筛选
```

#### 技巧 3：任务的版本控制

```bash
# 查看任务历史
TaskGet({taskId: "5"})

输出中的 history 字段：
[
  {action: "created", timestamp: "..."},
  {action: "updated", field: "status", value: "in_progress", timestamp: "..."},
  {action: "updated", field: "owner", value: "agent-2", timestamp: "..."}
]

# 可以追踪任务的所有变更
```

#### 技巧 4：优先级管理

```bash
# 设置优先级
TaskUpdate({
  taskId: "1",
  "metadata.priority": "P0"
})

TaskUpdate({
  taskId: "2",
  "metadata.priority": "P1"
})

TaskUpdate({
  taskId: "3",
  "metadata.priority": "P2"
})

# Agent 认领任务时参考优先级
# 先做 P0，再做 P1，最后 P2
```

---

### 六、常见错误和解决

#### 错误 1：任务 ID 不存在

```bash
你: TaskUpdate({taskId: "999", status: "completed"})

错误：Task not found: 999

解决：先用 TaskList() 查看正确的 ID
```

#### 错误 2：循环依赖

```bash
你: TaskUpdate({taskId: "1", addBlockedBy: ["2"]})
you: TaskUpdate({taskId: "2", addBlockedBy: ["1"]})

警告：Circular dependency detected!

解决：移除一个依赖
TaskUpdate({taskId: "1", addBlockedBy: []})
```

#### 错误 3：状态转换无效

```bash
你: TaskUpdate({taskId: "1", status: "completed"})
# 但任务1还在 in_progress

错误：Cannot transition from in_progress to completed without owner confirmation

解决：先让 owner 确认完成
```

---

### 七、最佳实践

#### ✅ 推荐做法

```bash
1. 定期查看 TaskList()
   → 每天至少一次，监控进度

2. 任务描述要清晰
   → 让 Agent 一看就懂

3. 合理使用依赖
   → 不要过度依赖，保持简单

4. 及时更新状态
   → Agent 完成任务立即更新

5. 使用 metadata 存储额外信息
   → 优先级、预估时间等
```

#### ❌ 避免的做法

```bash
1. 不要频繁修改任务
   → 保持任务稳定

2. 不要创建过多依赖
   → 3层以上的依赖链很复杂

3. 不要忽略 pending 状态的任务
   → 定期检查为什么没开始

4. 不要忘记查看 history
   → 出问题时查看历史

5. 不要手动修改 config.json
   → 始终使用工具
```

---

### 总结

| 工具 | 用途 | 使用频率 |
|------|------|---------|
| **TaskList** | 查看所有任务 | ⭐⭐⭐⭐⭐ 最常用 |
| **TaskGet** | 查看单个任务详情 | ⭐⭐⭐⭐ 经常使用 |
| **TaskUpdate** | 更新任务状态 | ⭐⭐⭐⭐⭐ 最常用 |
| **TaskCreate** | 创建新任务 | ⭐⭐⭐⭐⭐ 最常用 |

**典型工作流：**
```
TaskCreate() → TaskList() → TaskGet() → TaskUpdate() → TaskList()
    创建        查看       详情      更新        验证
```

---

## 第十部分：监控和调试 Teams

**问题：如何监控 Team 的进度，如何调试常见问题**

### 一、查看 Agent 状态

#### 方法 1：读取团队配置文件

```bash
# 查看团队配置
Read({file_path: "~/.claude/teams/test-team/config.json"})
```

##### 输出示例

```bash
{
  "team_name": "test-team",
  "description": "测试团队",
  "created_at": "2026-02-07T10:00:00Z",
  "members": [
    {
      "name": "agent-1",
      "agentType": "general-purpose",
      "agentId": "abc-123",
      "status": "idle",
      "last_active": "2026-02-07T11:30:00Z"
    },
    {
      "name": "agent-2",
      "agentType": "tdd-guide",
      "agentId": "def-456",
      "status": "busy",
      "last_active": "2026-02-07T11:45:00Z",
      "current_task": "3"
    },
    {
      "name": "agent-3",
      "agentType": "code-reviewer",
      "agentId": "ghi-789",
      "status": "idle",
      "last_active": "2026-02-07T11:20:00Z"
    }
  ]
}
```

##### Agent 状态说明

| 状态 | 说明 |
|------|------|
| **idle** | 空闲，等待任务 |
| **busy** | 忙碌，正在执行任务 |
| **waiting** | 等待依赖满足 |
| **error** | 遇到错误 |
| **offline** | 离线（已关闭） |

---

#### 方法 2：使用 TaskList 推断状态

```bash
你: TaskList()

输出：
ID | Subject    | Owner    | Status
---|------------|----------|-------------
1  | 任务1      | agent-1  | in_progress
2  | 任务2      | agent-1  | pending
3  | 任务3      | agent-2  | completed
4  | 任务4      |          | pending

你: 分析：
- agent-1 正在做任务1（in_progress）
- agent-1 还有任务2待办
- agent-2 完成了任务3，现在空闲
- 任务4无人认领
```

---

#### 方法 3：直接发送消息询问

```bash
你: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "你当前在做什么？有没有遇到问题？"
})

agent-1 回复：
"我正在实现用户登录 API，目前进行到 50%。
遇到了一个密码加密的问题，正在研究解决方案。
预计还需要 1 小时完成。"
```

---

### 二、监控 Team 进度

#### 定期检查进度

```bash
# 每天检查一次
你: TaskList()

输出：
ID | Subject       | Owner       | Status       | BlockedBy
---|---------------|-------------|--------------|----------
1  | 任务1         | agent-1     | completed    | []
2  | 任务2         | agent-2     | completed    | [1]
3  | 任务3         | agent-1     | in_progress  | [1]
4  | 任务4         | agent-2     | pending      | [2]
5  | 任务5         |             | pending      | [3,4]

你: 计算进度：
- 总任务数：5
- 已完成：2 (40%)
- 进行中：1 (20%)
- 待办：2 (40%)

整体进度：40%
```

---

#### 进度报告模板

```bash
你: "汇报一下当前状态"

project-manager:
## 项目进度报告

### 完成情况
✅ 任务1：项目初始化（已完成）
✅ 任务2：数据库设计（已完成）
🔄 任务3：API 开发（进行中，70%）
⏸️ 任务4：前端开发（等待任务2）
⏸️ 任务5：测试（等待任务3、4）

### 团队状态
- agent-1：忙碌（任务3 进行中）
- agent-2：空闲（任务2 刚完成）
- agent-3：等待（任务4 依赖未满足）

### 风险和问题
⚠️ 任务4 还没开始，可能影响项目进度
⚠️ agent-2 已空闲 2 小时，可以分配新任务

### 下一步行动
1. agent-1 继续完成任务3
2. 任务3 完成后，任务4 自动解锁
3. agent-2 可以认领任务4
```

---

### 三、诊断常见问题

#### 问题 1：Agent 长时间没有更新

##### 症状

```bash
你: TaskList()

ID | Subject    | Owner    | Status
---|------------|----------|-------------
1  | 任务1      | agent-1  | in_progress

你: 查看 agent-1 已经 in_progress 3 小时了
```

##### 诊断步骤

```bash
# 步骤 1：检查任务详情
你: TaskGet({taskId: "1"})

输出：
{
  "status": "in_progress",
  "updatedAt": "2026-02-07T08:00:00Z"  # 3小时前
}

# 步骤 2：发送消息询问
你: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "你已经在这个任务上工作了 3 小时，遇到了什么问题吗？"
})

agent-1 回复：
"我遇到了一个复杂的算法问题，正在调试。
已经尝试了 3 种方案，都不太理想。
现在在尝试第 4 种方案，预计还需要 1 小时。"
```

##### 解决方法

```bash
# 方法 1：给 Agent 更多时间
你: "好的，继续努力，有问题随时汇报"

# 方法 2：提供帮助
你: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "描述一下你遇到的问题，我来看看能不能提供帮助"
})

# 方法 3：调整任务
你: TaskUpdate({
  taskId: "1",
  "metadata.estimated": "5h"  # 调整预估时间
})
```

---

#### 问题 2：任务一直 pending，没有 Agent 认领

##### 症状

```bash
你: TaskList()

ID | Subject    | Owner    | Status       | BlockedBy
---|------------|----------|--------------|----------
1  | 任务1      |          | pending      | []
2  | 任务2      | agent-1  | in_progress  | []
3  | 任务3      | agent-2  | completed    | []

你: 任务1 无人认领，但它没有依赖（BlockedBy=[]）
```

##### 诊断步骤

```bash
# 步骤 1：检查任务详情
你: TaskGet({taskId: "1"})

输出：
{
  "subject": "实现复杂的数据分析算法",
  "description": "...",
  "owner": null,  # 无人认领
  "blockedBy": []
}

# 步骤 2：检查 Agent 状态
你: Read({file_path: "~/.claude/teams/test-team/config.json"})

agent-1: status = "busy"
agent-2: status = "idle"  # 空闲！

# 步骤 3：询问为什么没人认领
you: SendMessage({
  type: "message",
  recipient: "agent-2",
  content: "任务1 无人认领，你能接手吗？"
})

agent-2 回复：
"我看了一下任务1，需要数学背景和算法经验。
我的专业领域是前端开发，不太擅长这个。
建议让 agent-3（他是算法专家）来做。"
```

##### 解决方法

```bash
# 方法 1：手动分配任务
你: TaskUpdate({
  taskId: "1",
  owner: "agent-3"
})

# 方法 2：修改任务描述，降低门槛
you: TaskUpdate({
  taskId: "1",
  description: "简化的数据分析任务（已提供详细步骤）"
})

# 方法 3：启动专门的 Agent
you: Task({
  team_name: "test-team",
  name: "algorithm-expert",
  subagent_type: "general-purpose",
  prompt: "算法专家，擅长数据分析和数学计算"
})
```

---

#### 问题 3：循环依赖导致任务无法开始

##### 症状

```bash
you: TaskList()

ID | Subject    | BlockedBy
---|------------|----------
1  | 任务1      | [2]
2  | 任务2      | [1]

you: 两个任务互相依赖，永远无法开始！
```

##### 诊断步骤

```bash
# 步骤 1：检查依赖关系
you: TaskGet({taskId: "1"})
→ blockedBy: ["2"]

you: TaskGet({taskId: "2"})
→ blockedBy: ["1"]

# 确认：循环依赖！
```

##### 解决方法

```bash
# 方法 1：移除一个依赖
you: TaskUpdate({
  taskId: "1",
  addBlockedBy: []  # 移除对任务2的依赖
})

# 方法 2：拆分任务
you: TaskUpdate({
  taskId: "1",
  subject: "任务1 - 第一步（无依赖）"
})

you: TaskCreate({
  subject: "任务1 - 第二步（依赖任务2）",
  addBlockedBy: ["2"]
})

# 方法 3：合并任务
you: TaskUpdate({
  taskId: "1",
  addBlockedBy: []  # 移除依赖
})

you: TaskUpdate({
  taskId: "2",
  status: "deleted"  # 删除任务2，合并到任务1
})
```

---

#### 问题 4：Agent 工作负载不均衡

##### 症状

```bash
you: TaskList()

ID | Subject    | Owner    | Status
---|------------|----------|-------------
1  | 任务1      | agent-1  | in_progress
2  | 任务2      | agent-1  | pending
3  | 任务3      | agent-1  | pending
4  | 任务4      | agent-2  | completed

you: agent-1 太忙，agent-2 太闲
```

##### 解决方法

```bash
# 重新分配任务
you: TaskUpdate({
  taskId: "2",
  owner: "agent-2"
})

you: TaskUpdate({
  taskId: "3",
  owner: "agent-2"
})

# 现在负载均衡了
```

---

### 四、高级调试技巧

#### 技巧 1：使用时间戳分析问题

```bash
# 查看任务历史
you: TaskGet({taskId: "5"})

history 字段：
[
  {action: "created", timestamp: "2026-02-07T09:00:00Z"},
  {action: "updated", field: "status", value: "in_progress", timestamp: "2026-02-07T09:30:00Z"},
  {action: "updated", field: "status", value: "pending", timestamp: "2026-02-07T10:00:00Z"}  # 怎么变回 pending？
]

you: 发现异常：任务从 in_progress 变回了 pending！

you: 查询 agent：
"任务5 的状态怎么从 in_progress 变回 pending 了？"

agent: "抱歉，我遇到了问题，主动释放了任务。
我忘记更新状态为 in_progress 了。"
```

---

#### 技巧 2：监控 Agent 活跃度

```bash
# 查看 config.json 中的 last_active
you: Read({file_path: "~/.claude/teams/test-team/config.json"})

agent-1: last_active = "2026-02-07T11:00:00Z"  # 3小时前
agent-2: last_active = "2026-02-07T13:50:00Z"  # 刚刚

you: agent-1 3小时没活动了，可能出问题了

you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "你还好吗？3小时没看到你的活动了"
})
```

---

#### 技巧 3：使用 metadata 记录调试信息

```bash
# 创建任务时添加调试标签
TaskCreate({
  subject: "实现 API",
  metadata: {
    "debug": true,
    "complexity": "high",
    "notes": "这个任务有风险，需要密切关注"
  }
})

# 后续筛选 debug=true 的任务
```

---

### 五、常见调试场景

#### 场景 1：性能问题

```bash
you: "agent-1，你完成任务6用了5小时，预估是2小时，发生了什么？"

agent-1:
"原因是：
1. 发现了代码中的 bug，修复花了1小时
2. 需要学习新的库，花了1小时
3. 测试时发现了边界情况，修复花了1小时
实际有效工作时间是2小时，额外3小时是处理意外情况"

you: "好的，更新预估时间，并记录经验教训"

you: TaskUpdate({
  taskId: "6",
  "metadata.estimated": "5h",
  "metadata.actual": "5h",
  "metadata.notes": "遇到意外bug，需要预留额外时间"
})
```

---

#### 场景 2：质量问题

```bash
code-reviewer: SendMessage({
  type: "message",
  recipient: "team-lead",
  content: """
  agent-1 提交的代码有问题：
  - 缺少错误处理
  - 没有注释
  - 测试覆盖率不足

  需要返工。
  """
})

you: "收到，让 agent-1 修复"

you: TaskUpdate({
  taskId: "7",
  status: "pending",  # 重新打开任务
  "metadata.reviews": "需要添加错误处理和注释"
})

you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "代码审查发现问题，请修复：缺少错误处理、注释、测试"
})
```

---

#### 场景 3：通信问题

```bash
you: 发现 agent-1 和 agent-2 在做重复的工作

you: TaskList()

ID | Subject        | Owner
---|----------------|------
1  | 实现登录 API    | agent-1
2  | 实现认证接口    | agent-2  # 重复！

you: "停下！你们在做什么？"

agent-1: "我在做登录功能"
agent-2: "我在做认证功能"

you: "这是同一个功能！agent-2 停止，agent-1 继续"

you: TaskUpdate({
  taskId: "2",
  status: "deleted"  # 删除重复任务
})
```

---

### 六、最佳实践

#### ✅ 监控建议

```bash
1. 定期检查（每天至少一次）
   → TaskList() 查看整体状态

2. 关注异常情况
   → 长时间 in_progress
   → 无人认领的 pending 任务
   → Agent 长时间 idle

3. 主动沟通
   → 发现问题立即询问 Agent
   → 不要等到最后才发现

4. 记录问题
   → 在 metadata 中记录遇到的问题
   → 方便后续复盘

5. 及时调整
   → 发现负载不均衡立即重新分配
   → 发现任务难度不匹配立即调整
```

#### ❌ 避免的做法

```bash
1. 不要完全放任不管
   → Teams 需要监督

2. 不要频繁打扰 Agents
   → 给他们足够的时间工作

3. 不要忽略警告信号
   → 小问题会变成大问题

4. 不要等到最后才检查
   → 定期监控，及时发现问题

5. 不要手动修改内部文件
   → 始终使用工具
```

---

### 七、故障排查清单

#### 快速检查清单

```bash
□ TaskList() - 查看任务状态
□ 检查是否有长时间 in_progress 的任务
□ 检查是否有无人认领的 pending 任务
□ 检查是否有循环依赖
□ 查看 Agent 状态（config.json）
□ 检查 Agent 工作负载是否均衡
□ 向空闲 Agent 询问为什么没认领任务
□ 向忙碌 Agent 询问是否需要帮助
□ 检查任务历史记录
□ 查看 metadata 中的备注
```

---

### 八、监控仪表板示例

#### 手动创建监控报告

```bash
# 定期向所有 Agents 发送状态请求
you: SendMessage({
  type: "broadcast",
  content: """
  ## 📊 Team 状态报告

  请所有 Agents 汇报：
  1. 当前在做什么任务？
  2. 预计何时完成？
  3. 有没有遇到问题？
  4. 下一步计划是什么？
  """
})

# 收集所有回复并整理成报告
```

#### 常见监控指标

```bash
1. 任务完成率
   → completed / total

2. Agent 利用率
   → busy / total agents

3. 平均任务时长
   → sum(actual_time) / completed_tasks

4. 阻塞任务数
   → count of tasks with blockedBy

5. 空闲 Agent 数
   → count of idle agents
```

---

### 总结

| 监控方法 | 用途 | 频率 |
|---------|------|------|
| **TaskList()** | 查看整体任务状态 | 每天多次 |
| **TaskGet()** | 查看单个任务详情 | 需要时 |
| **Read config.json** | 查看 Agent 状态 | 每天至少一次 |
| **SendMessage** | 直接询问 Agent | 发现问题时 |

**监控原则：**
- 主动监控，不要被动等待
- 及时发现问题，及时解决
- 保持沟通，不要放任不管
- 记录经验，持续改进

---

## 第十一部分：故障排查和常见问题

**问题：Teams 使用中可能遇到哪些问题，如何排查和解决？**

### 一、创建 Team 相关问题

#### 问题 1：Team 创建失败

##### 症状

```bash
you: TeamCreate({
  team_name: "my-team"
})

错误：Team creation failed
```

##### 可能原因和解决

###### 原因 1：Team 名称已存在

```bash
错误：Team already exists: my-team

解决方法 1：删除旧 Team
you: 首先删除旧 Team
you: TeamDelete({team_name: "my-team"})
you: 然后重新创建

解决方法 2：使用新名称
you: TeamCreate({
  team_name: "my-team-v2"  # 使用不同的名称
})
```

###### 原因 2：权限问题

```bash
错误：Permission denied to create team directory

解决方法：
检查 ~/.claude/ 目录权限
确保有写入权限
```

###### 原因 3：磁盘空间不足

```bash
错误：Insufficient disk space

解决方法：
清理磁盘空间
删除不需要的旧 Teams
```

---

#### 问题 2：Agent 启动失败

##### 症状

```bash
you: Task({
  team_name: "my-team",
  name: "agent-1",
  subagent_type: "general-purpose"
})

错误：Failed to start agent
```

##### 可能原因和解决

###### 原因 1：Team 不存在

```bash
错误：Team not found: my-team

解决方法：
先创建 Team，再启动 Agent
you: TeamCreate({team_name: "my-team"})
you: 然后启动 Agent
```

###### 原因 2：Agent 名称重复

```bash
错误：Agent name already exists: agent-1

解决方法：
使用不同的名称
you: Task({
  team_name: "my-team",
  name: "agent-2",  # 使用新名称
  subagent_type: "general-purpose"
})
```

###### 原因 3：Agent 类型无效

```bash
错误：Invalid agent type: invalid-type

解决方法：
使用有效的类型
you: Task({
  team_name: "my-team",
  name: "agent-1",
  subagent_type: "general-purpose"  # 有效类型
})

# 有效的 agent 类型：
- general-purpose
- planner
- architect
- code-reviewer
- tdd-guide
- security-reviewer
- e2e-runner
```

---

### 二、任务管理相关问题

#### 问题 3：任务创建失败

##### 症状

```bash
you: TaskCreate({
  subject: "测试任务"
})

错误：Failed to create task
```

##### 可能原因和解决

###### 原因 1：没有上下文 Team

```bash
错误：No active team context

解决方法 1：在 Team 中创建
you: 需要先指定 team_name 或在 Team 上下文中

解决方法 2：使用 Team 路径
you: TaskCreate({
  subject: "测试任务",
  team_name: "my-team"  # 指定 Team
})
```

###### 原因 2：必填字段缺失

```bash
错误：Missing required field: subject

解决方法：
you: TaskCreate({
  subject: "完整的任务标题",  # 必须提供
  description: "详细描述"      # 可选
})
```

---

#### 问题 4：任务依赖关系错误

##### 症状

```bash
you: TaskCreate({
  subject: "任务2",
  addBlockedBy: ["任务1"]
})

警告：Dependency task not found: 任务1
```

##### 解决方法

```bash
# 先创建被依赖的任务
you: TaskCreate({
  subject: "任务1"
})

# 再创建依赖它的任务
you: TaskCreate({
  subject: "任务2",
  addBlockedBy: ["任务1"]
})

# 或者使用任务 ID
you: TaskCreate({subject: "任务1"})  # ID = 1
you: TaskCreate({
  subject: "任务2",
  addBlockedBy: ["1"]  # 使用 ID
})
```

---

#### 问题 5：循环依赖

##### 症状

```bash
you: TaskCreate({subject: "A", addBlockedBy: ["B"]})
you: TaskCreate({subject: "B", addBlockedBy: ["A"]})

警告：Circular dependency detected!
```

##### 检测方法

```bash
# 方法 1：手动检查
you: TaskGet({taskId: "A"})
→ blockedBy: ["B"]

you: TaskGet({taskId: "B"})
→ blockedBy: ["A"]

→ 发现循环！

# 方法 2：系统自动检测
系统会自动检测并警告
```

##### 解决方法

```bash
# 方法 1：移除一个依赖
you: TaskUpdate({
  taskId: "A",
  addBlockedBy: []  # 移除依赖
})

# 方法 2：拆分任务
you: TaskUpdate({
  taskId: "A",
  subject: "A-第1步（无依赖）"
})

you: TaskCreate({
  subject: "A-第2步",
  addBlockedBy: ["B"]
})

# 方法 3：重新规划依赖
分析实际依赖关系，重新设计
```

---

### 三、Agent 行为异常

#### 问题 6：Agent 不响应

##### 症状

```bash
you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "你还好吗？"
})

# 长时间没有回复...
```

##### 诊断步骤

```bash
# 步骤 1：检查 Agent 状态
you: Read({file_path: "~/.claude/teams/my-team/config.json"})

agent-1: {
  "status": "offline"  # Agent 已离线
}

# 步骤 2：检查最后活动时间
agent-1: {
  "last_active": "2026-02-07T08:00:00Z"  # 5小时前
}

# 步骤 3：查看任务状态
you: TaskList()

agent-1 的任务：
ID | Subject    | Status
---|------------|-------------
1  | 任务1      | in_progress（5小时了）
```

##### 解决方法

```bash
# 方法 1：等待 Agent 完成
如果 Agent 确实在工作，只是需要更多时间

# 方法 2：重新启动 Agent
you: 删除并重新创建 Agent

# 方法 3：手动干预
you: TaskUpdate({
  taskId: "1",
  status: "pending"  # 重置任务状态
})

you: 让其他 Agent 接手
```

---

#### 问题 7：Agent 重复认领任务

##### 症状

```bash
you: TaskList()

ID | Subject    | Owner
---|------------|-------
1  | 任务1      | agent-1
2  | 任务2      | agent-1
3  | 任务3      | agent-1
4  | 任务4      | agent-1
5  | 任务5      | agent-1

所有任务都被 agent-1 认领了！
```

##### 原因

```bash
可能原因：
1. agent-1 太积极，认领了所有任务
2. 其他 Agents 太慢，没抢到
3. 任务分配机制有问题
```

##### 解决方法

```bash
# 方法 1：手动重新分配
you: TaskUpdate({
  taskId: "3",
  owner: "agent-2"
})

you: TaskUpdate({
  taskId: "4",
  owner: "agent-3"
})

you: TaskUpdate({
  taskId: "5",
  owner: "agent-2"
})

# 方法 2：调整 Agent 的认领行为
you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "不要一次认领太多任务，给其他 Agent 留一些"
})

# 方法 3：预先分配任务
you: TaskCreate({
  subject: "任务",
  owner: "agent-2"  # 创建时就指定 owner
})
```

---

#### 问题 8：Agent 之间意见冲突

##### 症状

```bash
agent-1: "应该用 PostgreSQL"
agent-2: "应该用 MongoDB"

双方争执不下...
```

##### 解决方法

```bash
# 方法 1：你做最终决策
you: SendMessage({
  type: "broadcast",
  content: "我决定使用 PostgreSQL。请所有人遵循这个决策。"
})

# 方法 2：让第三者仲裁
you: SendMessage({
  type: "message",
  recipient: "architect",
  content: "agent-1 想用 PostgreSQL，agent-2 想用 MongoDB。
  你作为架构师，请给出建议并说明理由。"
})

# 方法 3：创建对比任务
you: TaskCreate({
  subject: "数据库选型对比分析",
  owner: "architect",
  description: "对比 PostgreSQL 和 MongoDB 的优劣"
})

# 然后根据分析结果做决策
```

---

### 四、性能和资源问题

#### 问题 9：Team 运行缓慢

##### 症状

```bash
Agent 响应很慢
任务执行时间过长
```

##### 可能原因和解决

###### 原因 1：任务太多

```bash
问题：创建了 100+ 个任务

解决方法 1：合并小任务
you: 把多个小任务合并成大任务

解决方法 2：删除不必要的任务
you: TaskUpdate({
  taskId: "xxx",
  status: "deleted"
})
```

###### 原因 2：Agent 太多

```bash
问题：创建了 10+ 个 Agents

解决方法：减少 Agent 数量
you: 让一些 Agent shutdown
you: 删除不需要的 Agents
```

###### 原因 3：依赖链太长

```bash
问题：
任务1 → 任务2 → 任务3 → ... → 任务10
10层依赖！

解决方法：缩短依赖链
you: 重新规划任务，减少依赖层级
```

---

#### 问题 10：内存或资源占用过高

##### 症状

```bash
系统变慢
内存占用高
```

##### 解决方法

```bash
# 方法 1：清理已完成的 Teams
you: 删除不再使用的 Teams
you: TeamDelete({team_name: "old-team"})

# 方法 2：清理历史记录
you: 删除旧任务
you: TaskUpdate({
  taskId: "old-task",
  status: "deleted"
})

# 方法 3：减少并发 Agents
you: 让一些 Agent 进入 idle 状态
you: 或者直接 shutdown
```

---

### 五、数据一致性问题

#### 问题 11：配置文件损坏

##### 症状

```bash
you: Read({file_path: "~/.claude/teams/my-team/config.json"})

错误：Invalid JSON format
```

##### 解决方法

```bash
# 方法 1：从备份恢复
you: 检查是否有自动备份
you: 恢复备份文件

# 方法 2：手动修复
you: 仔细检查 JSON 格式
you: 修复语法错误

# 方法 3：重新创建 Team
you: TeamDelete({team_name: "my-team"})
you: TeamCreate({team_name: "my-team"})
you: 重新添加 Agents
```

---

#### 问题 12：任务状态不同步

##### 症状

```bash
you: TaskList() 显示任务 in_progress
但 Agent 实际上已经完成
```

##### 诊断

```bash
# 检查任务详情
you: TaskGet({taskId: "1"})

history:
[
  {action: "updated", status: "completed", timestamp: "10:00"},
  {action: "updated", status: "in_progress", timestamp: "10:05"}  # 为什么又变回去了？
]

# 发现：状态被意外修改
```

##### 解决方法

```bash
# 手动修正状态
you: TaskUpdate({
  taskId: "1",
  status: "completed"
})

# 询问 Agent
you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "任务1 状态显示 in_progress，但你不是已经完成了吗？"
})
```

---

### 六、通信问题

#### 问题 13：Agent 收不到消息

##### 症状

```bash
you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "测试消息"
})

# Agent 没有回复
```

##### 诊断

```bash
# 检查 1：Agent 是否在线
you: Read({file_path: "~/.claude/teams/my-team/config.json"})

agent-1: {
  "status": "offline"  # 离线了！
}

# 检查 2：Agent 名称是否正确
you: 是否有拼写错误？

# 检查 3：Agent 是否在同一个 Team
you: 发送者和接收者必须在同一个 Team
```

##### 解决方法

```bash
# 方法 1：等待 Agent 上线
you: 等待 Agent 变成 idle 或 busy 状态

# 方法 2：使用 broadcast
you: SendMessage({
  type: "broadcast",  # 所有人都能收到
  content: "重要通知"
})

# 方法 3：重启 Agent
you: 删除并重新创建 Agent
```

---

#### 问题 14：消息格式错误

##### 症状

```bash
you: SendMessage({
  type: "message",
  content: "测试"
})

错误：Missing required field: recipient
```

##### 解决方法

```bash
# 检查消息类型

# type: "message" 需要 recipient
SendMessage({
  type: "message",
  recipient: "agent-1",  # 必须提供
  content: "..."
})

# type: "broadcast" 不需要 recipient
SendMessage({
  type: "broadcast",  # 发给所有人
  content: "..."
})

# type: "shutdown_request" 需要 recipient
SendMessage({
  type: "shutdown_request",
  recipient: "agent-1",  # 必须提供
  content: "..."
})
```

---

### 七、清理和关闭问题

#### 问题 15：Team 删除失败

##### 症状

```bash
you: TeamDelete({team_name: "my-team"})

错误：Failed to delete team
```

##### 可能原因和解决

###### 原因 1：Agents 还在运行

```bash
错误：Cannot delete team with active agents

解决方法：先关闭所有 Agents
you: 逐个发送 shutdown_request
you: 等待所有 Agents 批准
you: 然后再删除 Team
```

###### 原因 2：Team 不存在

```bash
错误：Team not found: my-team

解决方法：
you: 检查 Team 名称是否正确
you: 查看现有的 Teams
```

###### 原因 3：权限问题

```bash
错误：Permission denied

解决方法：
you: 检查文件系统权限
you: 确保有删除权限
```

---

#### 问题 16：Agent 拒绝关闭

##### 症状

```bash
you: SendMessage({
  type: "shutdown_request",
  recipient: "agent-1",
  content: "请关闭"
})

agent-1: SendMessage({
  type: "shutdown_response",
  approve: false,  # 拒绝！
  content: "我还有任务没完成"
})
```

##### 解决方法

```bash
# 方法 1：等待 Agent 完成
you: 让 Agent 完成当前任务
you: 然后再请求关闭

# 方法 2：强制关闭（不推荐）
you: 直接停止 Agent 进程

# 方法 3：解决 Agent 的顾虑
you: SendMessage({
  type: "message",
  recipient: "agent-1",
  content: "你的任务可以由其他 Agent 接手，请放心关闭"
})
```

---

### 八、最佳实践总结

#### ✅ 预防问题的最佳实践

```bash
1. 从小规模开始
   → 先用 2-3 个 Agents 练习
   → 不要一开始就创建大规模 Team

2. 定期备份
   → 定期复制重要配置文件
   → 记录关键决策

3. 渐进式复杂化
   → 先掌握单层 Team
   → 再尝试分层 Team

4. 监控和日志
   → 定期检查状态
   → 记录遇到的问题

5. 清理资源
   → 及时删除不需要的 Teams
   → 不要让资源泄漏
```

#### ❌ 常见错误

```bash
1. 创建过多 Agents
   → 推荐：3-5 个
   → 避免：10+ 个

2. 过度依赖
   → 依赖链不超过 3 层
   → 避免循环依赖

3. 完全放任
   → 需要定期监督
   → 主动发现问题

4. 忽略警告
   → 注意系统警告
   → 及时处理

5. 手动修改文件
   → 始终使用工具
   → 不要手动改 config.json
```

---

### 九、故障排查流程图

#### 通用排查步骤

```
发现问题
    ↓
1. 收集信息
   ├─ TaskList() - 查看任务状态
   ├─ TaskGet() - 查看任务详情
   ├─ Read config.json - 查看 Agent 状态
   └─ SendMessage - 询问 Agent
    ↓
2. 分析原因
   ├─ 是任务问题？Agent 问题？
   ├─ 是配置问题？依赖问题？
   └─ 是通信问题？权限问题？
    ↓
3. 尝试解决
   ├─ 查阅相关文档
   ├─ 尝试推荐解决方案
   └─ 如果还不行...
    ↓
4. 重新开始
   ├─ 删除并重新创建
   ├─ 恢复备份
   └─ 简化配置
```

---

### 十、常见问题快速参考

| 问题类型 | 快速诊断 | 快速解决 |
|---------|---------|---------|
| **Team 创建失败** | 检查名称是否重复 | 使用新名称或删除旧 Team |
| **Agent 不响应** | 检查 status 是否 offline | 重启 Agent 或等待 |
| **任务无人认领** | 检查是否有空闲 Agent | 手动分配或调整任务 |
| **循环依赖** | TaskGet 检查 blockedBy | 移除一个依赖 |
| **Agent 重复认领** | TaskList 查看分配 | 手动重新分配 |
| **消息发送失败** | 检查 recipient 是否正确 | 确认 Agent 在线 |
| **Team 删除失败** | 检查是否有活跃 Agent | 先关闭所有 Agents |

---

### 总结

**故障排查的核心原则：**

1. **先诊断，后解决** - 不要盲目修改
2. **备份重要数据** - 防止丢失
3. **从小规模开始** - 容易定位问题
4. **保持冷静** - 大多数问题都有解决方案
5. **记录经验** - 避免重复犯错

**遇到问题时，按以下顺序检查：**
1. 查看错误信息
2. 检查配置文件
3. 使用诊断工具
4. 查阅文档
5. 尝试重新开始

---

*本文档持续更新中...*
