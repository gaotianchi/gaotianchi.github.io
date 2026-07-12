# SCSS 拆分 Phase 2 报告

## 状态

构建通过 — `bundle exec jekyll build` 成功完成，所有编译后的 CSS 选择器已验证存在。

## Commit SHA

`3dc78554f05426f7ec6b7ea30f5833064f75d95b`

## 创建的文件

### components/（10 个文件）

| 文件 | 源文件 | 提取内容 |
|------|--------|----------|
| `_sass/components/_navbar.scss` | `_sass/klise/_layout.scss` | `.navbar` 和 `.menu` 区块（导航栏、主题切换、移动端菜单） |
| `_sass/components/_emblem.scss` | `_sass/klise/_layout.scss` | `.emblem` 区块（logo + 格言展示） |
| `_sass/components/_post-item.scss` | `_sass/klise/_layout.scss` | `.posts-item-note` 和 `.post-item` 通用文章列表样式 |
| `_sass/components/_footer.scss` | `_sass/klise/_layout.scss` | `.footer` 区块（三列页脚） |
| `_sass/components/_back-to-top.scss` | `_sass/klise/_layout.scss` | `#back-to-top` 回到顶部按钮 |
| `_sass/components/_toc.scss` | `_sass/klise/_post.scss` | `.toc-row`、`.toc-col`、`.toc-*` 目录相关全部样式 |
| `_sass/components/_post-nav.scss` | `_sass/klise/_post.scss` | `.post-nav` 上一篇/下一篇导航 |
| `_sass/components/_footnotes.scss` | `_sass/klise/_post.scss` | `.footnotes`、`.reversefootnote`、`sup[id^="fnref"]` 脚注样式 |
| `_sass/components/_changelog.scss` | `_sass/klise/_post.scss` | `.changelog-table` 变更记录表格 |
| `_sass/components/_content-footer.scss` | `_sass/klise/_post.scss` | `.page-lastmod`、`.email-reply-link`、`.ai-notice` 文章底部信息 |

### pages/（4 个文件）

| 文件 | 源文件 | 提取内容 |
|------|--------|----------|
| `_sass/pages/_post.scss` | `_sass/klise/_post.scss` | `.wrapper.post`、`.post-top`、`.toc-watermark`、`.header`、`.post-meta`、`.post-hero`、`.post-divider`、`.page-content`、`.post-body` |
| `_sass/pages/_home.scss` | `_sass/klise/_layout.scss` | `.home-wrapper` 首页样式（含文章点线列表布局） |
| `_sass/pages/_archive.scss` | `_sass/klise/_layout.scss` | `.archive-*` 和 `.timeline-*` 归档页时间线样式 |
| `_sass/pages/_404.scss` | `_sass/klise/_layout.scss` | `.not-found` 404 页面 |

## 修改的文件

| 文件 | 变更 |
|------|------|
| `_sass/main.scss` | 导入列表替换为新的分文件结构，`_dark.scss` 保持在最后 |
| `_sass/klise/_layout.scss` | 从 942 行缩减为 5 行，仅保留 `.wrapper main { padding-bottom: 2rem; }` |

## 删除的文件

| 文件 | 原因 |
|------|------|
| `_sass/klise/_post.scss` | 所有内容已提取到 `components/` 和 `pages/_post.scss` |

## 导入顺序

```scss
@import "variables", "mixins",
  "klise/base",
  "components/navbar", "components/emblem", "components/post-item",
  "components/footer", "components/back-to-top",
  "components/toc", "components/post-nav", "components/footnotes",
  "components/changelog", "components/content-footer",
  "pages/post", "pages/home", "pages/archive", "pages/404",
  "klise/layout", "klise/poem", "klise/syntax", "klise/dark";
```

`_variables.scss` 和 `_mixins.scss` 首先导入，确保后续所有文件均可访问 SCSS 变量和 mixin。`_dark.scss` 在最后，确保深色模式覆盖所有组件和页面样式。
