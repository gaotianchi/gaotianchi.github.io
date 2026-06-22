# Post-processes the generated feed.xml to:
# 1. Strip tag-originated <category> elements, keeping only the real category
#    from post front-matter.
# 2. Fix entry <id> trailing slash mismatch — jekyll-feed uses post.id
#    (no trailing /) while post.url has one, violating RFC 4287 §4.2.6.
# 3. Inject <icon> element if missing (RFC 4287 recommended).
Jekyll::Hooks.register :site, :post_write do |site|
  feed_path = File.join(site.dest, "feed.xml")
  next unless File.exist?(feed_path)

  content = File.read(feed_path)
  base_url = site.config["url"] || ""

  # ---- 1. Strip tag categories ----
  # Within each <entry>…</entry>, keep only the first <category /> and
  # remove all subsequent ones (which are tags injected by jekyll-feed).
  content.gsub!(%r{(<entry[^>]*>.*?)(<category term="[^"]*" />)(.*?</entry>)}m) do
    pre  = Regexp.last_match(1)
    cat  = Regexp.last_match(2)
    rest = Regexp.last_match(3)
    clean_rest = rest.gsub(%r{<category term="[^"]*" />\s*}, "")
    "#{pre}#{cat}#{clean_rest}"
  end

  # ---- 2. Fix entry <id> trailing slash ----
  # Only touch <id> inside <entry> blocks; leave the feed-level <id> alone.
  # Matches an entry-scoped <id> whose URL does NOT already end with "/".
  content.gsub!(%r{(<entry[^>]*>.*?<id>https?://[^<]+[^/])(</id>)}m) do
    "#{Regexp.last_match(1)}/#{Regexp.last_match(2)}"
  end

  # ---- 3. Inject <icon> ----
  unless content.include?("<icon>")
    favicon_url = "#{base_url}/favicon.ico"
    # Insert <icon> right after the feed-level <id> element
    content.sub!(%r{(<id>#{Regexp.escape(base_url)}/feed\.xml</id>)}) do
      "#{Regexp.last_match(1)}\n  <icon>#{favicon_url}</icon>"
    end
  end

  File.write(feed_path, content)
end
