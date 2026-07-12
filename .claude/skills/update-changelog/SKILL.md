---
name: update-changelog
description: >
  从 git 历史更新 /changelog/ 页面（_pages/changelog.md）。
  当用户说"更新变更记录"、"更新 changelog"、"同步 changelog"，
  或在提交了一批用户可见的改动后希望记录到变更记录页面时触发。
---

# 更新变更记录

根据 git 历史，将今天的用户可见变动写入 `_pages/changelog.md`。
该文件是一个 Markdown 表格：

```
| 日期 | 变更 |
|------|------|
| YYYY-MM-DD | 一句话描述。 |
```

## 工作流程

### 1. 确定日期

默认取**今天**。如果用户指定了日期范围，则使用指定范围。

### 2. 收集 commit

运行 `git log --oneline --since="YYYY-MM-DD" --until="YYYY-MM-DD+1"`。
如果今天没有 commit，往前查一天，以此类推。

### 3. 筛选用户可见的变动

**纳入**以下前缀的 commit：
- `style(...)` — 视觉、排版、布局调整
- `feat(...)` — 新功能
- `fix(...)` — 影响用户体验的缺陷修复
- `docs(...)` — 面向读者的页面内容变更

**排除**以下 commit：
- `docs(spec):` — 内部设计文档
- `refactor(...)` — 内部代码重构
- `chore(...)`、`ci(...)`、`build(...)`、`test(...)` — 工具链
- `docs(changelog):` — 变更记录页自身的更新（避免无限循环）
- `refactor(skill):` — 技能管理

拿不准的纳入，用户可以之后删除。

### 4. 翻译为读者友好的中文

将每个 commit 转换为一句简洁的变动描述。规则：

- **不用技术术语。** 读者不知道 SCSS、Liquid、Jekyll 是什么。描述"读者看到了什么变化"，而非"代码里改了什么"。
- **一句话一件事。** 一个 commit 涉及多个视觉区域的，分别提及。
- **合并同类项。** 同一天多个 commit 都在改链接样式，合成一句话。
- **具体但简练。** "正文链接由蓝色改为灰褐色"优于"更新了链接颜色"。

### 5. 写入文件

打开 `_pages/changelog.md`。表格按日期倒序排列。

- 今天的行已存在：在现有单元格末尾追加新变动，用中文句号（`。`）分隔。
- 今天是新的一天：在表头行之后插入新行：

```
| 日期 | 变更 |
|------|------|
| 新行插入此处                              ← 插在这里
| 2026-07-10 | ... |
```

### 6. 提交

commit message：`docs(changelog): 补充 YYYY-MM-DD 变更记录`。

附加 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`。

## 翻译示例

**好的翻译：**

| 原始 commit message | 变更记录文本 |
|---|---|
| `style: 全站链接分型 + 背景色去黄` | 全站链接样式分型调整，页面背景色微调减少黄感 |
| `feat: 内链/外链分离——外链虚线下划线 + 箭头后缀` | 正文外链改用虚线下划线并添加箭头标识 |
| `style(archive): 缩小时间轴 hover 圆点并微调纵向位置` | 归档页时间轴 hover 圆点缩小并下移 |
| `refactor(changelog): HTML 列表转 Markdown 表格` | 变更记录页由列表改为表格 |
| `style(home): 移动端首页标题恢复默认字号` | 移动端首页标题字号恢复，与归档页一致 |

**不好的翻译（太技术化）：**

| 原始 commit message | 不好的文本 | 问题 |
|---|---|---|
| `style: 全站链接分型` | 将 $text-link-blue 替换为 #6d6260 | 出现了色号 |
| `refactor(changelog): 列表转表格` | HTML ul 替换为 GFM table，删除内联 style | 出现了 HTML/CSS 概念 |
| `feat: 新增 external_links.rb` | 新增 _plugins/external_links.rb 插件 | 出现了文件路径 |

## 基本原则

- 没有用户可见的 commit 就不要编造，如实告知并停止。
- 不确定一个 commit 是否用户可见时，读一下它的 diff 再判断。
- 每条描述尽量控制在 40 字以内。
- 表格行按日期倒序，永远不要重排行顺序。
