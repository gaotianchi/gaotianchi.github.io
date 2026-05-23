---
title: Changelog
permalink: /changelog/
layout: page
description: 这个站点的变更记录。
comments: false
---

<ul class="changelog">
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-23</time>
    <div class="changelog-content">
      新增 <a href="/blank/">/blank/</a>、<a href="/ai/">/ai/</a>、<a href="/changelog/">/changelog/</a> 页面。
      作者卡片重新设计为左对齐布局，精简为头像、姓名与独白。
      导航菜单精简为英文（Home、Archive、About）。
      页脚重新设计，增加邮件、RSS、AI、Blank、Changes 链接与隐蔽的"少作"入口。
      调整正文默认字号至 16px。
      将所有文章归档至 <a href="/legacy/">/legacy/</a>，首页、归档页与标签页不再列出。
      隐藏文章之间保留上下篇导航，边缘显示"回到首页"。
      新增 <a href="/colophon/">/colophon/</a> 页面，说明站点构建理念与技术选型。
      页脚链接重组为双行布局（联系与站点导航分离）。
      /about/ 页面移除站点历史章节（已迁移至 /changelog/）。
      手机端菜单改进：图标在汉堡与关闭之间切换，点击遮罩可收起菜单。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2025-05-05</time>
    <div class="changelog-content">
      回归建站，域名定为 gaotianchi.com，使用 Jekyll + GitHub Pages，主题采用 Klise。
      网站不再混杂，专注于个人写作：探究自我、疗愈内心、打开心结。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2022 — 2025</time>
    <div class="changelog-content">
      频繁更换域名、网站名称和建站工具。用过 WordPress、Blogger，甚至用 Flask 从零开发过博客网站。精力消耗在工具上，轻视了内容本身。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2022-09-03</time>
    <div class="changelog-content">
      初次建站，名为"悲伤的斯蒂梵冈"。
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
    gap: 1.5rem;
    padding: 1.25rem 0;
    border-bottom: 1px solid #ececec;
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
  }
  .changelog-content a {
    color: #003fff;
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
