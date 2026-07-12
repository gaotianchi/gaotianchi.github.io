# SCSS Refactor Phase 1 Report

**Status:** All 6 tasks completed successfully. Build passes.

**Commit:** `fb9a7e0a53aec302ecfb3807c6019ffe4a50c083`

## Summary of changes

### Task 1: Created `_sass/_variables.scss`
Extracted all SCSS variables (fonts, colors, widths, spacing, device breakpoints) from the top of `main.scss`, plus 5 new variables for link/mark/code styling:
- `$link-body-color: #6d6260`
- `$link-underline-color-light: rgba(0, 0, 0, 0.18)`
- `$link-underline-color-dark: rgba(255, 255, 255, 0.18)`
- `$mark-bg: #fffba0`
- `$code-inline-bg: #f6f6f6`

### Task 2: Created `_sass/_mixins.scss`
Extracted the two `@mixin` blocks from `main.scss`:
- `media-query($device)` — responsive breakpoint wrapper
- `relative-font-size($ratio)` — scales font size relative to `$base-font-size`

### Task 3: Updated `_sass/main.scss`
Replaced entire file content with a single `@import` line:
```scss
@import "variables", "mixins", "klise/base", "klise/layout", "klise/post",
  "klise/poem", "klise/syntax", "klise/dark";
```

### Task 4: Replaced hardcoded colors with variables
| File | Replacements |
|------|-------------|
| `_sass/klise/_post.scss` | `#6d6260` -> `$link-body-color` (2 occurrences)<br>`rgba(0,0,0,0.18)` -> `$link-underline-color-light` (2 occurrences) |
| `_sass/klise/_poem.scss` | `#6d6260` -> `$link-body-color` (1)<br>`rgba(0,0,0,0.18)` -> `$link-underline-color-light` (1) |
| `_sass/klise/_dark.scss` | `rgba(255,255,255,0.18)` -> `$link-underline-color-dark` (2 occurrences) |
| `_sass/klise/_base.scss` | `#fffba0` -> `$mark-bg` (1) |
| `_sass/klise/_syntax.scss` | `#f6f6f6` -> `$code-inline-bg` (1) |

### Task 5: Fixed `_config.yml` defaults scope
Changed `path: ""` to `path: "_posts"` so the default layout `post` only applies to files under `_posts/`, not to all files site-wide.

### Task 6: Build verification
`bundle exec jekyll build` completed without errors (0.768s).
