# Phase 3: JS 内联代码收归 main.js

**Date**: 2026-07-12  
**Commit**: `04d6488`

## 概述

将所有散布在 Jekyll 模板和页面中的内联 JavaScript 代码统一收归到 `assets/js/main.js`，消除代码重复，统一主题初始化逻辑。

## 变更文件

| 文件 | 变更 | 说明 |
|------|------|------|
| `assets/js/main.js` | +217 / -228 | 集中管理全部 JS，一个文件加载 |
| `_layouts/default.html` | -26 行 | 移除内联主题初始化脚本 |
| `_layouts/post.html` | -61 行 | 移除水印 + TOC 滚动监听脚本 |
| `_layouts/404.html` | -19 行 | 移除内联主题初始化脚本 |
| `_pages/archive.html` | -56 行 | 移除分类筛选脚本 |

## 架构

```
main.js（单文件，defer 加载）
├── Theme init（立即执行，阻止主题闪烁）
│   ├── initTheme(): 从 localStorage 读取 / prefers-color-scheme 检测
│   └── notransition class 移除（75ms 后）
└── DOMContentLoaded（网页骨架就绪后执行）
    ├── Theme toggle（灯按钮点击切换）
    ├── Mobile menu（汉堡菜单 + 遮盖 + 滚动锁）
    ├── Back to top（滚动监听 + 平滑返回顶部）
    ├── Watermark（文章水印随机旋转，仅 post 页）
    ├── TOC scroll spy（目录高亮 + 锚点平滑滚动，仅 post 页）
    └── Archive filter（分类筛选 + 年分组显隐，仅 archive 页）
```

## 关键设计决策

1. **Theme init 必须同步执行**：放在外层 IIFE 顶部，不等待 DOMContentLoaded，避免页面加载时主题闪烁。

2. **闭包共享变量**：`body` 和 `initTheme` 定义在外层 IIFE，通过闭包让 DOMContentLoaded 内的各模块访问，无需暴露到 window。

3. **元素存在守卫**：每个功能模块都用 `if (document.getElementById(...))` 包裹，确保在不相关的页面（如首页不需要 TOC）不会报错。

4. **原始逻辑完整保留**：
   - 水印旋转：`Math.floor(Math.random() * 360)` + `setProperty('transform', ..., 'important')`
   - TOC 滚动监听：`IntersectionObserver` 带 `rootMargin: '-80px 0px -70% 0px'`
   - 归档筛选：`activate()` + `filter()` 函数，年份分组联动显隐
   - 回到顶部：`requestAnimationFrame` 节流 + `history.pushState` 清理 hash

## 加载方式

`footer.html` 中已有 `<script src="/assets/js/main.js" defer="defer"></script>`，无需改动，支持所有页面类型（首页、文章、归档、页面、404）。

## 构建验证

- `bundle exec jekyll build` — exit 0，无报错
- `_site/` 中 0 处残留内联主题脚本（`initTheme`、`notransition`、`toc-watermark`）
- `assets/js/main.js` 在所有页面类型中均正确加载
