# Playwright 完整入门指南

## 第一部分：什么是 Playwright？

### 1.1 概念解释

**Playwright** 是微软开发的一个**浏览器自动化工具**，主要用于：

| 用途 | 说明 |
|------|------|
| **端到端测试（E2E Testing）** | 模拟真实用户操作，测试整个应用流程 |
| **浏览器自动化** | 自动打开网页、点击按钮、填写表单等 |
| **跨浏览器测试** | 一套代码，测试 Chrome、Firefox、Safari |
| **爬虫/数据采集** | 自动抓取网页数据 |

### 1.2 为什么选择 Playwright？

```
传统手动测试：
  打开浏览器 → 输入网址 → 点击按钮 → 填写表单 → 检查结果
  ↓
  每次发布都要重复一遍，累死人了！

Playwright 自动测试：
  写一次代码 → 自动执行所有测试 → 永远不用手动重复
```

**核心优势：**
- **自动等待**：不用手动写 `sleep(1000)`，Playwright 会自动等待元素出现
- **跨浏览器**：一个测试，跑 Chrome、Firefox、Safari
- **内置断言**：自动重试，直到条件满足或超时
- **并行执行**：多个测试同时跑，节省时间

---

## 第二部分：安装与配置

### 2.1 环境准备

确保你已安装：
- **Node.js** (v18+ 推荐)
- **npm** 或 **pnpm**

### 2.2 创建新项目

```bash
# 方式一：创建全新项目（推荐新手）
npm init playwright@latest

# 执行后会问你这些问题：
# ✔ Do you want to use TypeScript or JavaScript? → TypeScript
# ✔ Where to put your end-to-end tests? → tests
# ✔ Add a GitHub Actions workflow? → No
# ✔ Install Playwright browsers? → Yes
```

### 2.3 项目结构

```
my-playwright-project/
├── playwright.config.ts    # 配置文件
├── package.json
├── tests/                  # 测试文件放这里
│   └── example.spec.ts     # 示例测试
└── test-results/           # 测试结果（运行后生成）
```

### 2.4 配置文件详解

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // 测试文件所在目录
  testDir: './tests',

  // 是否并行执行测试
  fullyParallel: true,

  // CI 环境失败重试次数
  retries: process.env.CI ? 2 : 0,

  // 报告格式
  reporter: 'html',

  // 全局配置
  use: {
    // 基础 URL，测试中可以用相对路径
    baseURL: 'http://localhost:3000',

    // 失败时记录 trace（调试用）
    trace: 'on-first-retry',

    // 截图
    screenshot: 'only-on-failure',
  },

  // 浏览器项目配置
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',  // Safari 内核
      use: { ...devices['Desktop Safari'] },
    },
  ],
});
```

---

## 第三部分：第一个测试

### 3.1 最简单的测试

```typescript
// tests/first-test.spec.ts
import { test, expect } from '@playwright/test';

test('我的第一个测试', async ({ page }) => {
  // 1. 打开网页
  await page.goto('https://example.com');

  // 2. 检查标题是否包含 "Example"
  await expect(page).toHaveTitle(/Example/);
});
```

### 3.2 运行测试

```bash
# 运行所有测试
npx playwright test

# 运行特定文件
npx playwright test first-test.spec.ts

# 可视化界面运行（强烈推荐！）
npx playwright test --ui

# 查看测试报告
npx playwright show-report
```

### 3.3 测试代码逐行解释

```typescript
import { test, expect } from '@playwright/test';

// test() 定义一个测试
// 参数1: 测试名称
// 参数2: 测试函数，{ page } 是 Playwright 注入的页面对象
test('我的第一个测试', async ({ page }) => {

  // page.goto() 导航到指定 URL
  // await 表示等待导航完成
  await page.goto('https://example.com');

  // expect() 是断言，检查条件是否满足
  // toHaveTitle() 检查页面标题
  // /Example/ 是正则表达式，表示标题包含 "Example"
  // 如果条件不满足，测试会失败
  await expect(page).toHaveTitle(/Example/);
});
```

---

## 第四部分：定位元素（Locators）

### 4.1 什么是定位器？

定位器是用来**找到页面上的元素**的方式。比如找到"登录按钮"、"用户名输入框"等。

### 4.2 推荐的定位方式（按优先级）

```typescript
import { test, expect } from '@playwright/test';

test('定位器示例', async ({ page }) => {
  await page.goto('https://example.com/login');

  // ========== 1. getByRole（最推荐）==========
  // 通过元素的"角色"定位，如 button、link、heading、textbox
  // 符合无障碍访问标准，最稳定

  await page.getByRole('button', { name: '登录' }).click();
  await page.getByRole('textbox', { name: '用户名' }).fill('admin');
  await page.getByRole('link', { name: '忘记密码' }).click();
  await page.getByRole('heading', { name: '欢迎' }).isVisible();

  // ========== 2. getByLabel ==========
  // 通过表单的 label 文本定位输入框

  await page.getByLabel('邮箱地址').fill('test@example.com');
  await page.getByLabel('密码').fill('123456');

  // ========== 3. getByPlaceholder ==========
  // 通过输入框的 placeholder 属性定位

  await page.getByPlaceholder('请输入用户名').fill('admin');
  await page.getByPlaceholder('搜索...').fill('Playwright');

  // ========== 4. getByText ==========
  // 通过元素的文本内容定位

  await page.getByText('欢迎回来').isVisible();
  await page.getByText('了解更多').click();
  // exact: true 表示完全匹配
  await page.getByText('登录', { exact: true }).click();

  // ========== 5. getByTestId ==========
  // 通过 data-testid 属性定位（需要开发配合添加）
  // HTML: <button data-testid="submit-btn">提交</button>

  await page.getByTestId('submit-btn').click();
  await page.getByTestId('error-message').isVisible();

  // ========== 6. CSS 选择器（最后选择）==========
  // 不推荐，因为页面结构变化时容易失效

  await page.locator('#username').fill('admin');
  await page.locator('.submit-button').click();
  await page.locator('div.card > h2.title').isVisible();
});
```

### 4.3 定位器对比

| 方式 | 示例 | 稳定性 | 推荐度 |
|------|------|--------|--------|
| `getByRole` | `getByRole('button', {name: '提交'})` | ⭐⭐⭐⭐⭐ | ✅ 最推荐 |
| `getByLabel` | `getByLabel('用户名')` | ⭐⭐⭐⭐⭐ | ✅ 表单推荐 |
| `getByPlaceholder` | `getByPlaceholder('请输入')` | ⭐⭐⭐⭐ | ✅ 输入框 |
| `getByText` | `getByText('欢迎')` | ⭐⭐⭐⭐ | ✅ 文本验证 |
| `getByTestId` | `getByTestId('submit')` | ⭐⭐⭐⭐⭐ | ✅ 需开发配合 |
| CSS选择器 | `locator('#id')` | ⭐⭐ | ⚠️ 最后选择 |

---

## 第五部分：页面交互

### 5.1 常用操作

```typescript
import { test, expect } from '@playwright/test';

test('页面交互示例', async ({ page }) => {
  await page.goto('https://example.com/form');

  // ========== 输入操作 ==========

  // fill() - 填写输入框（会先清空再填写）
  await page.getByLabel('用户名').fill('张三');

  // type() - 逐字输入（模拟真实打字）
  await page.getByLabel('用户名').type('张三', { delay: 100 }); // 每个字间隔100ms

  // clear() - 清空输入框
  await page.getByLabel('用户名').clear();

  // ========== 点击操作 ==========

  // click() - 单击
  await page.getByRole('button', { name: '提交' }).click();

  // 双击
  await page.getByText('双击编辑').dblclick();

  // 右键点击
  await page.getByText('右键菜单').click({ button: 'right' });

  // Shift + 点击
  await page.getByText('多选').click({ modifiers: ['Shift'] });

  // ========== 复选框和单选框 ==========

  // 勾选
  await page.getByLabel('同意条款').check();

  // 取消勾选
  await page.getByLabel('订阅通知').uncheck();

  // 断言是否已勾选
  await expect(page.getByLabel('同意条款')).toBeChecked();

  // ========== 下拉选择框 ==========

  // 单选
  await page.getByLabel('城市').selectOption('北京');

  // 多选
  await page.getByLabel('爱好').selectOption(['阅读', '运动']);

  // 通过可见文本选择
  await page.getByLabel('城市').selectOption({ label: '上海' });

  // ========== 文件上传 ==========

  // 单文件
  await page.getByLabel('上传头像').setInputFiles('path/to/file.jpg');

  // 多文件
  await page.getByLabel('上传图片').setInputFiles(['file1.jpg', 'file2.jpg']);

  // ========== 键盘操作 ==========

  // 按单个键
  await page.getByLabel('搜索').press('Enter');
  await page.getByLabel('搜索').press('Escape');

  // 组合键
  await page.getByLabel('内容').press('Control+A'); // 全选
  await page.getByLabel('内容').press('Control+C'); // 复制

  // ========== 鼠标悬停 ==========

  await page.getByText('菜单').hover();

  // ========== 等待 ==========

  // 等待元素出现
  await page.getByText('加载完成').waitFor();

  // 等待元素消失
  await page.getByText('加载中...').waitFor({ state: 'hidden' });

  // 等待指定时间（不推荐，只在特殊情况下使用）
  await page.waitForTimeout(1000); // 等待1秒
});
```

---

## 第六部分：断言（Assertions）

### 6.1 什么是断言？

断言就是**验证测试结果是否符合预期**。如果断言失败，测试就失败。

### 6.2 常用断言

```typescript
import { test, expect } from '@playwright/test';

test('断言示例', async ({ page }) => {
  await page.goto('https://example.com');

  // ========== 页面断言 ==========

  // 检查 URL
  await expect(page).toHaveURL('https://example.com');
  await expect(page).toHaveURL(/example/);  // 正则匹配

  // 检查标题
  await expect(page).toHaveTitle('Example Domain');
  await expect(page).toHaveTitle(/Example/);

  // ========== 元素可见性断言 ==========

  const button = page.getByRole('button', { name: '提交' });

  // 可见
  await expect(button).toBeVisible();

  // 隐藏
  await expect(button).toBeHidden();

  // 存在于 DOM 中（不一定可见）
  await expect(button).toBeAttached();

  // ========== 元素状态断言 ==========

  // 启用/禁用
  await expect(button).toBeEnabled();
  await expect(button).toBeDisabled();

  // 可编辑
  await expect(page.getByLabel('备注')).toBeEditable();

  // 聚焦
  await expect(page.getByLabel('搜索')).toBeFocused();

  // 勾选状态
  await expect(page.getByLabel('同意')).toBeChecked();

  // ========== 文本内容断言 ==========

  const message = page.getByTestId('message');

  // 包含文本
  await expect(message).toContainText('成功');

  // 精确匹配文本
  await expect(message).toHaveText('操作成功！');

  // 正则匹配
  await expect(message).toHaveText(/成功|完成/);

  // 空内容
  await expect(message).toBeEmpty();

  // ========== 数值断言 ==========

  const list = page.getByRole('listitem');

  // 元素数量
  await expect(list).toHaveCount(5);

  // ========== 属性断言 ==========

  const input = page.getByLabel('邮箱');

  // 有某个 CSS 类
  await expect(input).toHaveClass(/error/);

  // 有某个属性
  await expect(input).toHaveAttribute('type', 'email');

  // 输入框的值
  await expect(input).toHaveValue('test@example.com');

  // ========== 截图对比（视觉测试）==========

  // 整页截图对比
  await expect(page).toHaveScreenshot();

  // 元素截图对比
  await expect(page.getByTestId('card')).toHaveScreenshot();

  // ========== 反向断言 ==========

  // 不可见
  await expect(button).not.toBeVisible();

  // 不包含文本
  await expect(message).not.toContainText('错误');
});
```

---

## 第七部分：测试组织

### 7.1 使用 describe 分组

```typescript
import { test, expect } from '@playwright/test';

// test.describe 将相关测试分组
test.describe('用户登录功能', () => {

  test('使用正确的账号登录', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.getByLabel('用户名').fill('admin');
    await page.getByLabel('密码').fill('123456');
    await page.getByRole('button', { name: '登录' }).click();
    await expect(page).toHaveURL(/dashboard/);
  });

  test('使用错误的密码登录', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.getByLabel('用户名').fill('admin');
    await page.getByLabel('密码').fill('wrong');
    await page.getByRole('button', { name: '登录' }).click();
    await expect(page.getByText('密码错误')).toBeVisible();
  });

  test('用户名为空时提示', async ({ page }) => {
    await page.goto('https://example.com/login');
    await page.getByRole('button', { name: '登录' }).click();
    await expect(page.getByText('请输入用户名')).toBeVisible();
  });
});

// 嵌套分组
test.describe('用户管理', () => {
  test.describe('用户列表', () => {
    test('显示所有用户', async ({ page }) => {
      // ...
    });
  });

  test.describe('用户详情', () => {
    test('显示用户信息', async ({ page }) => {
      // ...
    });
  });
});
```

### 7.2 测试钩子（Hooks）

```typescript
import { test, expect } from '@playwright/test';

test.describe('购物车功能', () => {

  // beforeAll: 在所有测试之前执行一次
  test.beforeAll(async () => {
    console.log('开始测试购物车功能');
  });

  // beforeEach: 在每个测试之前执行
  test.beforeEach(async ({ page }) => {
    // 每个测试都先登录
    await page.goto('https://example.com/login');
    await page.getByLabel('用户名').fill('testuser');
    await page.getByLabel('密码').fill('password');
    await page.getByRole('button', { name: '登录' }).click();
    await expect(page).toHaveURL(/dashboard/);
  });

  // afterEach: 在每个测试之后执行
  test.afterEach(async ({ page }, testInfo) => {
    // 如果测试失败，截图保存
    if (testInfo.status !== 'passed') {
      await page.screenshot({
        path: `screenshots/${testInfo.title}-failure.png`
      });
    }
  });

  // afterAll: 在所有测试之后执行一次
  test.afterAll(async () => {
    console.log('购物车功能测试完成');
  });

  // 实际测试
  test('添加商品到购物车', async ({ page }) => {
    await page.goto('https://example.com/products');
    await page.getByText('添加到购物车').first().click();
    await expect(page.getByText('已添加到购物车')).toBeVisible();
  });

  test('查看购物车', async ({ page }) => {
    await page.goto('https://example.com/cart');
    await expect(page.getByRole('heading', { name: '购物车' })).toBeVisible();
  });
});
```

---

## 第八部分：调试技巧

### 8.1 调试模式

```bash
# UI 模式（最推荐）
npx playwright test --ui

# 调试模式（逐步执行）
npx playwright test --debug

# 查看测试 trace
npx playwright show-trace trace.zip
```

### 8.2 代码生成器

```bash
# 启动代码生成器
npx playwright codegen

# 指定网站
npx playwright codegen https://example.com
```

然后在浏览器中操作，Playwright 会自动生成对应的测试代码。

### 8.3 测试中的调试

```typescript
test('调试示例', async ({ page }) => {
  await page.goto('https://example.com');

  // 暂停执行，打开 inspector
  await page.pause();

  // 打印信息
  console.log('当前 URL:', page.url());

  // 截图
  await page.screenshot({ path: 'debug.png' });

  // 打印元素内容
  const text = await page.getByRole('heading').textContent();
  console.log('标题内容:', text);
});
```

---

## 第九部分：完整示例

### 9.1 登录流程测试

```typescript
// tests/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('用户登录', () => {
  // 每个测试前先打开登录页
  test.beforeEach(async ({ page }) => {
    await page.goto('https://example.com/login');
  });

  test('成功登录', async ({ page }) => {
    // 填写表单
    await page.getByLabel('用户名').fill('admin');
    await page.getByLabel('密码').fill('correct_password');

    // 点击登录
    await page.getByRole('button', { name: '登录' }).click();

    // 验证跳转到首页
    await expect(page).toHaveURL(/dashboard/);

    // 验证显示用户名
    await expect(page.getByText('欢迎, admin')).toBeVisible();
  });

  test('密码错误显示错误提示', async ({ page }) => {
    await page.getByLabel('用户名').fill('admin');
    await page.getByLabel('密码').fill('wrong_password');
    await page.getByRole('button', { name: '登录' }).click();

    // 验证错误提示
    await expect(page.getByText('用户名或密码错误')).toBeVisible();

    // 验证仍在登录页
    await expect(page).toHaveURL(/login/);
  });

  test('表单验证 - 空用户名', async ({ page }) => {
    await page.getByLabel('密码').fill('some_password');
    await page.getByRole('button', { name: '登录' }).click();

    await expect(page.getByText('请输入用户名')).toBeVisible();
  });

  test('表单验证 - 空密码', async ({ page }) => {
    await page.getByLabel('用户名').fill('admin');
    await page.getByRole('button', { name: '登录' }).click();

    await expect(page.getByText('请输入密码')).toBeVisible();
  });
});
```

---

## 第十部分：常用命令速查

```bash
# 安装
npm init playwright@latest           # 初始化项目
npx playwright install               # 安装浏览器

# 运行测试
npx playwright test                  # 运行所有测试
npx playwright test login.spec.ts    # 运行指定文件
npx playwright test --project=chromium  # 指定浏览器
npx playwright test --headed         # 显示浏览器窗口
npx playwright test --debug          # 调试模式
npx playwright test --ui             # UI 模式

# 报告
npx playwright show-report           # 查看报告

# 代码生成
npx playwright codegen               # 打开代码生成器
npx playwright codegen example.com   # 打开指定网站

# 其他
npx playwright test --list           # 列出所有测试
npx playwright test --grep "登录"    # 运行名称包含"登录"的测试
```

---

## 学习建议

1. **先动手**：按照上面的步骤创建项目，写出第一个测试
2. **用代码生成器**：`npx playwright codegen` 可以帮你快速生成代码
3. **多用 UI 模式**：`npx playwright test --ui` 可以看到每一步的执行情况
4. **从简单开始**：先测试简单的页面，再逐步增加复杂度

---

## 进阶主题

当你掌握了基础知识后，可以学习以下进阶内容：

- **Page Object 模式**：将页面操作封装成类，提高代码复用性
- **API 测试**：使用 Playwright 测试后端 API
- **视觉回归测试**：通过截图对比检测 UI 变化
- **测试夹具（Fixtures）**：自定义测试环境和数据
- **CI/CD 集成**：在 GitHub Actions 等 CI 中运行测试
- **并行执行**：配置多进程并行运行测试

---

*文档生成日期：2026-02-24*
*Playwright 官方文档：https://playwright.dev*
