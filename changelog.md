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
      新增 <a href="/blank/">/blank/</a> 页面，遵循 IndieWeb 惯例。
      新增 <a href="/ai/">/ai/</a> 透明度声明页面。
      导航菜单精简为 Home、Archive、About。
      页脚新增 AI 与 Blank 链接。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-23</time>
    <div class="changelog-content">
      作者卡片重新设计为左对齐布局，精简为头像、姓名与独白。
      调整正文默认字号至 16px。
    </div>
  </li>
  <li class="changelog-entry">
    <time class="changelog-date">2026-05-23</time>
    <div class="changelog-content">
      将所有文章归档至 <a href="/legacy/">/legacy/</a>，首页、归档页与标签页不再列出。
      页脚重新设计，增加邮件、GitHub、Twitter、RSS 链接与隐蔽的"少作"入口。
      隐藏文章之间仍保留上下篇导航，边缘显示"回到首页"。
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
