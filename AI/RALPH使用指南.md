# Ralph 使用指南

## 什么是 Ralph？

Ralph 是一个自主 AI agent 循环工具，它会反复运行 [Amp](https://ampcode.com)（AI 编程助手）直到完成所有 PRD（产品需求文档）中的任务。

### 核心原理

每次迭代都会启动一个**全新的 Amp 实例**（清空上下文），通过以下方式保持记忆：
- Git 提交历史
- `progress.txt`（学习记录）
- `prd.json`（任务状态）

---

## 项目中的 Ralph 安装位置

```
AI-Stock-Analysis-System/
├── scripts/
│   └── ralph/              # Ralph 配置目录
│       ├── ralph.sh        # 主循环脚本
│       ├── prompt.md       # Amp 指令模板
│       ├── prd.json        # 任务列表（自动生成）
│       └── prd.json.example # PRD JSON 格式示例
└── RALPH使用指南.md        # 本文档
```

### 全局 Skills（已安装到 `~/.config/amp/skills/`）

- `prd/` - PRD 生成器 skill
- `ralph/` - PRD 转 JSON skill

---

## 使用 Ralph 的完整流程

### 第一步：创建 PRD（产品需求文档）

在项目根目录打开终端：

```bash
cd D:/work/AI-Stock-Analysis-System
amp
```

在 Amp 中输入：

```
Load the prd skill and create a PRD for [你想实现的功能描述]
```

**示例：**

```
Load the prd skill and create a PRD for:
优化股票分析系统的前端界面，包括视觉设计、数据可视化和用户体验改进
```

Amp 会问你一些澄清问题（3-5个），回答后会生成：
```
tasks/prd-[功能名].md
```

---

### 第二步：将 PRD 转换为 Ralph 格式

PRD 生成后，在 Amp 中继续输入：

```
Load the ralph skill and convert tasks/prd-[功能名].md to scripts/ralph/prd.json
```

这会创建 `scripts/ralph/prd.json`，格式如下：

```json
{
  "project": "项目名称",
  "branchName": "ralph/feature-name",
  "description": "功能描述",
  "userStories": [
    {
      "id": "US-001",
      "title": "用户故事标题",
      "description": "作为用户，我想要...",
      "acceptanceCriteria": [
        "具体的验收标准1",
        "具体的验收标准2",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

### 第三步：运行 Ralph

```bash
./scripts/ralph/ralph.sh
```

默认最多 10 次迭代，也可以指定次数：

```bash
./scripts/ralph/ralph.sh 20
```

### Ralph 会做什么？

1. 创建功能分支（基于 `prd.json` 中的 `branchName`）
2. 选择优先级最高且未完成的任务（`passes: false`）
3. 实现该任务
4. 运行质量检查（类型检查、测试）
5. 如果检查通过，提交代码
6. 更新 `prd.json`，标记任务为完成（`passes: true`）
7. 将学习内容追加到 `progress.txt`
8. 重复直到所有任务完成或达到最大迭代次数

---

## 前置要求

### 必须安装

1. **Amp CLI** - [https://ampcode.com](https://ampcode.com)
   ```bash
   # 下载安装后进行认证
   amp login
   ```

2. **jq**（JSON 处理工具）
   ```bash
   # Windows (Chocolatey)
   choco install jq

   # macOS
   brew install jq

   # Ubuntu/WSL
   sudo apt install jq
   ```

### 可选配置

#### 配置 Amp 自动交接（推荐）

编辑 `~/.config/amp/settings.json`：

```json
{
  "amp.experimental.autoHandoff": { "context": 90 }
}
```

这样可以处理大型任务，超出上下文时自动交接。

---

## 关键概念

### 1. 每个迭代 = 全新上下文

每次迭代启动新的 Amp 实例，**不记住之前的工作**。记忆仅来自：
- Git 历史
- `progress.txt`
- `prd.json`

### 2. 任务要小

每个用户故事应该能在**一次迭代内完成**。

**✅ 合适的任务大小：**
- 添加一个数据库列和迁移
- 向现有页面添加一个 UI 组件
- 更新服务器操作的新逻辑
- 添加一个筛选下拉框

**❌ 太大（需要拆分）：**
- "构建整个仪表板" → 拆分为：schema、queries、UI 组件、filters
- "添加认证" → 拆分为：schema、middleware、login UI、session handling
- "重构 API" → 拆分为每个端点或模式一个故事

### 3. 验收标准必须可验证

**✅ 好的标准（可验证）：**
```
- "向 tasks 表添加 status 列，默认 'pending'"
- "筛选下拉框有选项：全部、活跃、已完成"
- "类型检查通过"
```

**❌ 差的标准（模糊）：**
```
- "工作正常"
- "用户可以轻松完成 X"
- "良好的用户体验"
```

### 4. UI 故事必须包含浏览器验证

对于有 UI 变更的任务，验收标准必须包含：

```
- "Verify in browser using dev-browser skill"
```

Ralph 会使用 dev-browser skill 来验证页面视觉效果。

---

## 调试命令

### 查看任务状态

```bash
# 查看哪些任务已完成
cat scripts/ralph/prd.json | jq '.userStories[] | {id, title, passes}'

# 查看迭代学习记录
cat scripts/ralph/progress.txt

# 查看 Git 提交历史
git log --oneline -10
```

### 停止 Ralph

如果需要停止，按 `Ctrl+C`。已完成的工作会保存到 git。

---

## 任务拆分示例

### 原始需求

> "添加用户通知系统"

### 拆分为多个小任务

1. **US-001**: 向数据库添加 notifications 表
2. **US-002**: 创建 notification service 用于发送通知
3. **US-003**: 向 header 添加通知铃铛图标
4. **US-004**: 创建通知下拉面板
5. **US-005**: 添加标记为已读功能
6. **US-006**: 添加通知设置页面

每个任务都可以独立完成和验证。

---

## 归档机制

Ralph 会自动归档之前的运行。当你开始新功能时（`branchName` 不同），旧的 `prd.json` 和 `progress.txt` 会保存到：

```
scripts/ralph/archive/YYYY-MM-DD-feature-name/
```

---

## 常见问题

### Q: Ralph 卡住了怎么办？

A: 按 `Ctrl+C` 停止。查看 `progress.txt` 了解当前状态，手动修复问题后重新运行。

### Q: 如何跳过某个任务？

A: 编辑 `scripts/ralph/prd.json`，将该任务的 `passes` 设为 `true`。

### Q: Ralph 可以撤销之前的提交吗？

A: 不会。Ralph 只会提交新代码，不会修改已有历史。如需回滚：
```bash
git reset --hard HEAD~1
```

### Q: 任务执行顺序错了吗？

A: 检查 `prd.json` 中的 `priority` 字段。较小的数字优先执行。确保依赖任务排在前面。

---

## 示例：创建前端优化 PRD

### 1. 启动 Amp 并创建 PRD

```bash
cd D:/work/AI-Stock-Analysis-System
amp
```

在 Amp 中输入：

```
Load the prd skill and create a PRD for:
comprehensive frontend UI enhancement for the AI Stock Analysis System
```

### 2. 回答澄清问题

Amp 会问你类似：
- 目标用户是谁？
- 最需要改进的是什么？
- 有技术限制吗？

根据你的项目情况回答：
- 目标用户：A 股短线交易者
- 优先级：视觉设计 > 数据可视化 > 布局导航
- 技术限制：必须使用 Streamlit，保持 SQLite 兼容

### 3. 转换为 Ralph 格式

在 Amp 中输入：

```
Load the ralph skill and convert tasks/prd-frontend-enhancement.md to scripts/ralph/prd.json
```

### 4. 运行 Ralph

```bash
./scripts/ralph/ralph.sh
```

Ralph 会自动实现所有 UI 改进！

---

## 参考资源

- [Ralph 原始文章](https://ghuntley.com/ralph/)
- [Amp 文档](https://ampcode.com/manual)
- [项目中的 prd.json.example](scripts/ralph/prd.json.example) - PRD JSON 格式参考

---

**最后更新：** 2026年1月11日
**Ralph 版本：** 基于 Geoffrey Huntley 的 Ralph pattern
