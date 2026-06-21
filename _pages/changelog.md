---
title: 变更记录
permalink: /changelog/
layout: page
description: 这个站点的变更记录。
comments: false
---

<ul class="changelog">
  <li class="changelog-entry">
    <time class="changelog-date">2026-06-21</time>
    <div class="changelog-content">
      目录结构重组：文章与图片合放至 <code>_posts/&lt;slug&gt;/</code> 同名目录，独立页面迁入 <code>_pages/</code> 集合，<code>page.html</code> 重构为继承 default 布局。
      取消文章隐藏机制：移除全部文章的 visibility 与 status 字段，删除 /legacy/ 历史归档页面及相关过滤逻辑。
      全站中文化：导航、页面标题统一使用中文；页脚改为三列中文网格布局，桌面平板手机响应式适配。
      首页排版重构：桌面端书本目录风格（标题 ············ 日期，虚线引导），移动端日期置顶、引导线隐藏。
      中文字体换用霞鹜文楷（LXGW WenKai），正文超链接新增蓝色下划线风格化，脚注重排为学术论文引用格式。
      图片加载优化：新增 lazy_images 与 image_dimensions 插件，自动添加 loading="lazy" 及 width/height 属性消除布局偏移；修复 JPEG 尺寸解析器字节偏移 bug；站点 logo 排除占位灰底。
      删除 disqus.js、galite.js、search.min.js 等冗余资源；修复旧文图片 alt 文本与相对路径；CSP 白名单适配 GA4。
      文章页水印重构：logo 从标题区移至目录右侧，CSS 固定定位 + JS 随机旋转；修复 JS 定位失效改用 right 锚点。
      标题锚点 # 修复：改用 anchorBody 参数 HTML 直出，绝对定位至标题左留白区；修复 article overflow:hidden 裁切锚点。
      TOC 回到顶部：目录标题可点击跳转页面顶端，修复 pushState hash 导致回到顶部按钮失效。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-28</time>
    <div class="changelog-content">
      浅色主题背景由纯白改为暖调纸色（#f3ede4），进一步强化 Dark Academia 旧书页质感。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-27</time>
    <div class="changelog-content">
      首页头部改为 logo 徽记居中布局，配装饰分隔线与衬线格言，奠定 Dark Academia 基调。
      归档页分类/标签分组显示，新增筛选状态栏及清除按钮。
      文章页排版重构：标题左对齐、serif 元信息、正文前装饰分隔线。
      纯 Liquid 文章目录自动生成，单栏内联展示，滚动高亮当前位置。
      文章页新增 logo 水印，低透明度倾斜置于标题区域背后。
      首页 logo 预留宽高比，消除图片加载导致的布局跳动。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-25</time>
    <div class="changelog-content">
      归档页全新设计：纵向时间线 + 水印年份，标签云 + 分类筛选，支持分类与标签组合过滤。
      文章分类与标签体系重构，统一命名规范。
      全站新增回到顶部按钮。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-24</time>
    <div class="changelog-content">
      左上角主题切换图标动态化：浅色主题显示太阳，深色主题显示月亮，切换带旋转过渡动画。首次访问自动跟随系统偏好。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-23</time>
    <div class="changelog-content">
      新增 <a href="/blank/">/blank/</a>、<a href="/ai/">/ai/</a>等页面。
      作者卡片左对齐（头像、姓名、独白）；导航菜单精简为英文。
      页脚重新设计，增加邮件、RSS、AI、Blank、Changes 链接及"少作"入口。
      历史文章归档至 <a href="/legacy/">/legacy/</a>；全局字号 16px。
      手机端菜单改进：汉堡/关闭图标切换，点击遮罩收起。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2025-05-05</time>
    <div class="changelog-content">
      回归建站：gaotianchi.com，Jekyll + GitHub Pages，主题 Klise。专注个人写作。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2022 — 2025</time>
    <div class="changelog-content">
      频繁更换域名与建站工具（WordPress、Blogger、Flask），精力消耗在工具上。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2022-09-03</time>
    <div class="changelog-content">
      首次建站，名"悲伤的斯蒂梵冈"。
    </div>
  </li>
</ul>

<style>
  .changelog {
    list-style: none;
    margin: 0;
    padding: 0;
  }
  .changelog-entry {
    display: flex;
    gap: 1rem;
    padding: 1.25rem 0;
    border-bottom: 1px solid #ececec;
  }
  .changelog-entry::before {
    display: none;
  }
  .changelog-entry:last-child {
    border-bottom: none;
  }
  .changelog-date {
    flex-shrink: 0;
    width: 6.5rem;
    font-size: 0.8125rem;
    font-weight: 700;
    color: #6b7886;
    padding-top: 1px;
  }
  .changelog-content {
    font-size: 0.9375rem;
    line-height: 1.7;
    color: #434648;
    min-width: 0;
    overflow-wrap: break-word;
    word-break: break-word;
  }
  .changelog-content a {
    color: #003fff;
  }
  @media (max-width: 768px) {
    .changelog-entry {
      flex-direction: column;
      gap: 0.25rem;
    }
    .changelog-date {
      width: auto;
    }
  }
  body[data-theme="dark"] .changelog-entry {
    border-bottom-color: #1b1d25;
  }
  body[data-theme="dark"] .changelog-date {
    color: #767f87;
  }
  body[data-theme="dark"] .changelog-content {
    color: #c7bebe;
  }
  body[data-theme="dark"] .changelog-content a {
    color: #ff5277;
  }
</style>

<small style="display:block; margin-top: 2em; opacity: 0.4; font-size: 0.8125rem;">此页面会随站点更新持续补充。</small>
