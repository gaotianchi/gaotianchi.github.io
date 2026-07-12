# 内链/外链分离插件

日期：2026-07-12

## 设计

- **插件**：post-render 钩子，扫描 `<a>` 标签，为非本站域名的外部链接添加 `class="external-link"`
- **样式**：外链使用虚线下划线（`text-decoration-style: dotted`），内链保持实线；颜色继承父级链接规则

## 实现

- 插件文件：`_plugins/external_links.rb`，参照 `lazy_images.rb` 模式
- SCSS：`.page-content .external-link`、`.post-body .external-link`、`.poem-body .external-link` 追加 `text-decoration-style: dotted`
- 深色模式同步
