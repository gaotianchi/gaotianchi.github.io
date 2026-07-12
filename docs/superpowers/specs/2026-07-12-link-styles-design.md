# 全站链接样式分型设计

日期：2026-07-12

## 设计原则

不同位置的链接服务不同的阅读场景，使用不同的视觉语言区隔，而非一刀切统一。

## 分类定义

| 类型 | 位置 | 选择器 | 颜色 | 装饰 | hover |
|---|---|---|---|---|---|
| ① 文章标题 | 首页列表、归档时间轴 | `.post-item-title a`、`.timeline-link` | `inherit` | 无 | opacity → 0.55 |
| ② 菜单 | 导航栏 | `.menu-link` | `inherit` | 无 | opacity 0.7 → 1 |
| ③ 正文内链 | 文章/页面/诗歌正文 | `.page-content a`、`.post-body a`、`.poem-body a` | `#7a5c4f` / 深色 `#c4a88c` | 半透明下划线 | 下划线加深 |
| ④ TOC 目录 | 文章侧边目录 | `.toc-item a` | `$gray` | 无 | opacity 0.5 → 0.55 |
| ⑤ 脚注 | 文内上标、文末回链 | `sup[id^="fnref"] a`、`.reversefootnote` | `inherit` | 无 | opacity 微调 |
| ⑥ 标签 | 文章头部 | `.tag` | `$gray` | `#` 前缀 | border 加深 |
| ⑦ 前后篇 | 文章底部 | `.post-nav-item` | `$black` | 无 | title opacity 0.55 |
| ⑧ 辅助入口 | 首页→归档、页脚 | `.home-archive-link`、`.footer_item` | `inherit` | 无 | opacity 0.65 → 0.55 |

## 实现要点

- 去掉正文内链的 `↗` 外链箭头
- 去掉所有 `!important` 覆盖
- 深色模式同步对应调整
