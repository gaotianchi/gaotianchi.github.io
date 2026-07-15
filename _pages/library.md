---
title: 阅览
permalink: /library/
layout: page
description: 书影音记录。
date: 2026-07-16T00:00:00+08:00
lastmod: 2026-07-16T02:27:03+08:00
---

{% assign types = "书籍,影视,舞台剧,音乐" | split: "," %}
{% assign items = site.data.consuming | sort: "started" | reverse %}

{% for type in types %}
  {% assign type_items = items | where: "type", type %}
  {% if type_items.size > 0 %}
    <h2 class="library-type-title">{{ type }}</h2>
    <ul class="library-list">
    {% for item in type_items %}
      <li class="library-item">
        <div class="library-item-title">{{ item.title }} —— {{ item.creator }}</div>
        <div class="library-item-meta">
          {%- if item.notes -%}{{ item.notes }} · {%- endif -%}
          {%- assign started = item.started | date: "%Y.%m" -%}
          {%- if item.finished -%}
            {%- assign finished = item.finished | date: "%Y.%m" -%}
            {{ started }}–{{ finished }}
          {%- else -%}
            {{ started }}–
          {%- endif -%}
        </div>
      </li>
    {% endfor %}
    </ul>
  {% endif %}
{% endfor %}
