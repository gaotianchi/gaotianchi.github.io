# CLAUDE.md

本文件为 Claude Code（claude.ai/code）在此仓库中工作时提供指引。

## 项目概览

高天驰的个人博客，基于 **Jekyll 4.1** 构建，托管于 **GitHub Pages**，域名 `www.gaotianchi.com`。主题为高度定制化的 [Klisé](https://github.com/piharpi/jekyll-klise)。全站内容为**简体中文**。

## 常用命令

```bash
# 安装依赖
bundle install

# 启动开发服务器（含自动重载）
bundle exec jekyll serve

# 生产环境构建（输出到 _site/）
bundle exec jekyll build

# 创建新文章（使用 jekyll-compose，输出到 _posts/）
bundle exec jekyll post "文章标题"

# 创建草稿
bundle exec jekyll draft "草稿标题"
```

运行 `bundle exec jekyll serve`，浏览器打开 `http://localhost:4000` 即可预览。Jekyll 会自动监视文件变更并重新生成。

## 架构

### 文章组织方式

文章存放在 `_posts/<YYYY-MM-DD-slug>/` 目录下。每篇文章目录包含：
- `<YYYY-MM-DD-slug>.md` — 文章正文
- 文章中引用的图片（通过 `jekyll-postfiles` 插件与文章同目录存放）

每篇文章的 front matter 包含：`title`、`date`、`slug`、`lastmod`、`category`（单个分类）、`tags`（标签数组）、`description`、`author`。`category` 和 `tags` 同时用于归档页面筛选和 RSS 的分类/标签输出。

### 集合（Collections）

站点使用两个 Jekyll 集合：
- `posts` — 博客文章（默认，位于 `_posts/`）
- `pages` — 独立页面（位于 `_pages/`：关于、站点信息、变更记录、AI 声明、留白、404）

页面使用 `page` 布局；文章使用 `post` 布局。`_config.yml` 通过 `defaults` 配置了二者的对应关系。

### 布局链

```
compress.html         ← 最外层，压缩 HTML 输出中的空白
  └ default.html      ← <html>/<body> 外壳，主题初始化、导航栏、页脚、回到顶部
    ├ home.html       ← 首页：最近文章列表（上限由 site.number_of_posts=5 控制）
    ├ post.html       ← 文章页：题图、目录、水印、带锚点的正文
    ├ page.html       ← 通用页面（关于、站点信息等）
    └ 404.html        ← 自定义 404 页面
```

### 关键 include 文件

| Include | 用途 |
|---------|------|
| `header.html` | `<head>` 区域：SEO meta、Open Graph、Twitter cards、CSP、favicons、字体（EB Garamond + 霞鹜文楷）、MathJax 条件加载 |
| `navbar.html` | 导航栏：移动端汉堡菜单、主题切换（太阳/月亮图标）、来自 `_data/menus.yml` 的菜单链接、RSS 图标 |
| `toc.html` | 纯 Liquid 实现的目录生成器——解析渲染后的 HTML，提取 kramdown 生成的 h2–h4 标题及其 ID |
| `anchor_headings.html` | 在标题旁添加 `#` 锚点链接 |
| `footer.html` | 三列页脚 + Google Analytics + main.js |
| `emblem.html` | 首页文章列表上方的 logo + 格言居中展示 |

### 自定义插件（`_plugins/`）

纯 Ruby 文件，Jekyll 自动加载：

- **`lazy_images.rb`** — post-render 钩子，为所有缺少 `loading` 属性的 `<img>` 标签添加 `loading="lazy"`。
- **`image_dimensions.rb`** — post-render 钩子，从磁盘读取 PNG/JPEG/GIF/WebP 图片文件，自动注入 `width`/`height` 属性以消除布局偏移。图片路径解析方式：文章内图片相对于文章目录，页面内图片相对于站点根目录。同时补充缺失的 `loading="lazy"`。
- **`feed_polish.rb`** — `post_write` 钩子，对生成的 `feed.xml` 做三项修正：(1) 剔除标签产生的多余 `<category>` 元素，仅保留 front matter 中的分类；(2) 为 entry 的 `<id>` URL 补充末尾 `/`，与 `post.url` 保持一致（RFC 4287 §4.2.6 合规）；(3) 缺少 `<icon>` 元素时补充。

### SCSS 结构（`_sass/`）

```
assets/css/style.scss  → 入口，@import "main"
_sass/main.scss        → 导入所有分片
_sass/klise/
  _base.scss           → 重置、排版、间距
  _layout.scss         → 网格、头部、页脚、导航栏
  _post.scss           → 文章排版、目录、标签、题图、水印
  _syntax.scss         → Rouge 语法高亮主题（浅色 + 深色）
  _dark.scss           → 深色模式覆写
  _fonts.scss          → @font-face 和字体栈
  _miscellaneous.scss  → 工具类、回到顶部、汉堡菜单
```

主题配色：浅色模式使用暖调纸色背景（`#f3ede4`），深色模式使用深灰色调。字体：EB Garamond（衬线，用于标题），霞鹜文楷（用于中文正文）。

### RSS feed

由 `jekyll-feed` 生成，输出到 `/feed.xml`，经 `feed_polish.rb` 后处理。`_config.yml` 中 `feed:` 配置：上限 20 篇、全文输出（非摘要）、icon/logo 指向 favicon。

### JavaScript（`assets/js/main.js`）

原生 JS，无框架。处理：主题切换持久化（localStorage + 自动跟随系统偏好）、移动端菜单开关（含 body 滚动锁）、回到顶部按钮的滚动可见性。文章模板（`_layouts/post.html`）内嵌 JS 处理：水印随机旋转、目录滚动监控（IntersectionObserver）、平滑滚动导航。

### 导航数据

`_data/menus.yml` 驱动导航栏链接及其激活状态。目前三项：首页、归档、关于。在此文件中添加条目即可扩展主导航。

### front matter 约定

文章 front matter 可包含：`title`、`date`、`slug`、`lastmod`、`category`（单个字符串）、`tags`（数组）、`description`、`author`、`image`、`showImage`、`usemathjax`、`tweet`、`comments`、`redirect_from`。

`usemathjax: true` 启用 MathJax 3（`header.html` 中条件加载 CDN 资源）。

### 归档页

`/archive/` 由独立页面文件通过 Liquid 模板按年份、分类和标签分组生成。支持分类与标签的组合筛选，筛选状态栏显示当前激活的筛选项及清除按钮。

### GitHub Pages 部署

站点通过 `main` 分支部署到 GitHub Pages。`CNAME` 文件内容为 `www.gaotianchi.com`，`_config.yml` 中 `url` 为 `https://www.gaotianchi.com`。构建排除项：`CNAME`、`Gemfile`、`Gemfile.lock`、`klise.gemspec` 及其他开发文件。

### 关键依赖

Gemfile 中的主要 gem：
- `jekyll` ~> 4.1.0
- `jekyll-feed` ~> 0.13 — RSS/Atom feed 生成
- `jekyll-sitemap` ~> 1.4 — 生成 sitemap.xml
- `jekyll-compose` ~> 0.12.0 — 命令行辅助工具（创建文章/草稿）
- `jekyll-postfiles` ~> 3.1 — 图片与文章 markdown 同目录存放
- `jekyll-redirect-from` — 重定向支持
- `webrick` ~> 1.7 — 开发服务器
