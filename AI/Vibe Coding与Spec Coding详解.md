# Vibe Coding 与 Spec Coding 详解

> 这两个概念代表了 **AI 时代编程范式的两个方向**

---

## 一、Vibe Coding（氛围编程）

### 起源

由 **Andrej Karpathy**（OpenAI 联合创始人、前 Tesla AI 总监）于 **2025年2月** 提出，并被 **柯林斯词典评选为 2025 年度词汇**。

### 核心理念

> **"完全投入到氛围中，拥抱指数发展，忘记代码"**

```
传统编程：需求 → 写代码 → 调试 → 运行
Vibe Coding：需求 → 用自然语言告诉AI → AI生成代码 → 看起来能跑就行
```

### 特点

| 特点 | 说明 |
|------|------|
| **自然语言即代码** | 不需要学语法，说人话就行 |
| **快速迭代** | 想法到实现只需几分钟 |
| **"Happy but Ignorant"** | 快乐但可能无知——能用但不懂原理 |
| **降低门槛** | 非程序员也能做全栈开发 |

### 代表工具

- **Cursor** - AI 编辑器
- **Lovable** - 活跃用户 800 万
- **Claude / ChatGPT**
- **字节跳动扣子编程**
- **xAI Grok Build**

---

## 二、Spec Coding（规约编程）

### 起源

作为对 Vibe Coding "随意性"的反思，**2025 年下半年**兴起的工程化实践。ThoughtWorks 在 2025年11月的技术雷达中将其列为新兴技术。

### 核心理念

> **"先写规格，再生成代码"**

```
Vibe Coding：直接聊天 → 生成代码（随意、不可控）
Spec Coding：规格文档 → 实现计划 → 任务拆分 → 生成代码（结构化、可验证）
```

### 工作流程

```
1. 锁定意图 → 写规格文档（做什么）
2. 生成计划 → AI 制定实现方案（怎么做）
3. 拆分任务 → 分解为可执行步骤
4. 生成代码 → 按任务逐一生成
5. 验证质量 → 系统性检查
```

### 为什么需要 Spec Coding？

| Vibe Coding 的问题 | Spec Coding 的解决 |
|-------------------|-------------------|
| 90% 代码 AI 生成，质量难控 | 规格文档约束 AI 行为 |
| "幻觉代码"频发 | 意图先锁定，减少偏差 |
| 频繁调试改 bug | 系统化验证 |
| 安全隐患 | 边界提前定义 |

### 代表工具

- **GitHub SpecKit** - 三步流程：charter → orchestration → prompts
- **Amazon Kiro** - 需求 → 设计 → 任务
- **Tessl Framework** - "规格即维护对象"
- **Claude Code** - 强调"显式约束"
- **GitHub Copilot Workspace** - Plan Mode 实现 SDD 原则

---

## 三、对比总结

| 维度 | Vibe Coding | Spec Coding |
|------|-------------|-------------|
| **风格** | 即兴、直觉 | 结构化、工程化 |
| **入口** | 直接聊天 | 先写规格文档 |
| **控制力** | 弱 | 强 |
| **速度** | 极快 | 前期慢、后期稳 |
| **适合场景** | 原型、小项目 | 生产级、大项目 |
| **学习门槛** | 零门槛 | 需要规格编写能力 |
| **代码质量** | 看运气 | 可预期 |

---

## 四、实践建议

### 场景选择

```
快速原型 / 个人项目 / 探索想法  →  Vibe Coding
企业项目 / 生产系统 / 团队协作  →  Spec Coding
```

### 最佳实践

**两者结合**——用 Vibe Coding 快速探索，确定方向后用 Spec Coding 工程化落地。

---

## 五、2025年行业趋势

- **Stack Overflow 2025调查**：65% 的开发者每周至少使用一次 AI 编程工具
- **2025年被称为"编程被重新定义的一年"**
- 从实验性的 Vibe Coding 向工程级的 Spec-Driven Development 演进

---

## 六、参考资料

- [Vibe Coding - Collins Dictionary Word of the Year 2025](https://www.collinsdictionary.com/)
- [Andrej Karpathy on X (February 2025)](https://x.com/karpathy)
- [ThoughtWorks Technology Radar - Spec-Driven Development](https://www.thoughtworks.com/radar)
- [GitHub Copilot Workspace](https://github.com/features/preview/copilot-workspace)

---

*文档生成日期：2026-02-24*
