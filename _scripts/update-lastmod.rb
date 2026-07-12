#!/usr/bin/env ruby
# frozen_string_literal: true

# Pre-commit helper: update `lastmod` in front matter of staged content files.
# Scans _pages/ and _posts/ .md files in the staging area, sets lastmod to
# current local time in ISO 8601 +08:00 format, then re-adds them.

require "time"

STAGED_FILES_CMD = "git diff --cached --name-only --diff-filter=ACM _pages/ _posts/"
PAGES_DIR = "_pages"
POSTS_DIR = "_posts"
TIMEZONE_OFFSET = "+08:00"
FRONT_MATTER_RE = /\A(---\s*\n.*?\n---)/m
LASTMOD_RE = /^lastmod:.*$/

staged = `#{STAGED_FILES_CMD}`.lines.map(&:strip).grep(/\.md$/)
exit 0 if staged.empty?

now = Time.now.getlocal(TIMEZONE_OFFSET).strftime("%Y-%m-%dT%H:%M:%S#{TIMEZONE_OFFSET}")

staged.each do |file|
  content = File.read(file)

  front_matter_match = content.match(FRONT_MATTER_RE)
  next unless front_matter_match

  front = front_matter_match[1]

  if front.match?(LASTMOD_RE)
    new_front = front.sub(LASTMOD_RE, "lastmod: #{now}")
  else
    # Append lastmod before closing ---
    new_front = front.sub(/\n---\z/, "\nlastmod: #{now}\n---")
  end

  new_content = content.sub(FRONT_MATTER_RE, new_front)
  File.write(file, new_content)

  # Re-stage the file
  system("git", "add", file)
end
