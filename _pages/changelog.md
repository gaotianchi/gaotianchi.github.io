---
title: 变更记录
permalink: /changelog/
layout: page
description: 这个站点的变更记录。
---

<ul class="changelog">
  <li class="changelog-entry">
    <time class="changelog-date">2026-07-09</time>
    <div class="changelog-content">
      首页归档入口文案改为"更多文字"，字号与字间距对齐日期列表。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-07-08</time>
    <div class="changelog-content">
      新增诗歌布局（poem layout），中文衬线换为 Noto Serif SC（宋体）。
      首页列表虚线改为 CSS 背景自适应填充，全站标题字间距统一调整。
      移除自定义文本选中色，恢复浏览器默认样式。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-07-08</time>
    <div class="changelog-content">
      归档页仅保留分类筛选，按文章数量降序，默认显示"全部"；主题切换过渡更平滑。
      移除 8 篇早期文章，旧链接重定向至留白页。
      出于隐私考量，作者名由真实姓名改为 Tianchi，网站标题改为大写 TIANCHI，头像和默认社交预览图一并移除。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-06-23</time>
    <div class="changelog-content">
      Feed RFC 4287 合规修复：修正 entry <code>id</code> 与 <code>link</code> 尾斜杠不一致问题，补充 <code>&lt;icon&gt;</code> 元素，修正 <code>xml:lang</code> 为 <code>zh-CN</code>（BCP 47），开启 feed 全文输出。
      Feed 分类净化：移除 feed.xml 中标签对 <code>&lt;category&gt;</code> 元素的污染，仅保留文章正文分类。
      移动端首页日期左对齐修复。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-06-21</time>
    <div class="changelog-content">
      全站中文化：导航、页面标题、页脚统一使用中文。
      首页排版重构：桌面端书本目录风格（标题 ············ 日期），移动端日期置顶。
      中文字体换用霞鹜文楷（LXGW WenKai），正文超链接新增蓝色下划线。
      图片支持懒加载，消除布局偏移；文章水印移至目录右侧并随机旋转。
      标题旁显示 # 锚点链接；目录标题可点击回到页面顶部。
      所有历史文章公开可见，移除旧版归档页。
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
