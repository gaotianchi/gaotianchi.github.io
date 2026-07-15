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

  # ---- 4. Fix <updated> to use lastmod front matter ----
  # jekyll-feed defaults <updated> to post.date; replace with front-matter
  # lastmod when present.  We read the raw YAML because Jekyll overwrites
  # post.data["lastmod"] with the file mtime.
  require "time"
  require "yaml"

  site.posts.docs.each do |post|
    front_matter = {}
    begin
      raw = File.read(post.path)
      if raw =~ /\A---\s*\n(.*?)\n---/m
        front_matter = YAML.safe_load(Regexp.last_match(1), permitted_classes: [Time])
      end
    rescue
      # If YAML parsing fails, skip this post
    end
    front_matter ||= {}

    lastmod = front_matter["lastmod"]
    next unless lastmod

    begin
      lastmod_time = lastmod.utc
      lastmod_iso = lastmod_time.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    rescue
      next
    end

    post_url = "#{base_url}#{post.url}"
    # Match the entire <entry> that contains this post's <id> URL,
    # then replace its <updated> value.
    # Use ((?!<entry>).)* instead of .*? to prevent matching across
    # entry boundaries — without this, a regex for a later entry can
    # accidentally span from the first <entry> in the feed.
    content.gsub!(
      %r{<entry>((?!<entry>).)*<id>#{Regexp.escape(post_url)}</id>((?!<entry>).)*</entry>}m
    ) do |entry|
      entry.sub(%r{<updated>[^<]*</updated>}, "<updated>#{lastmod_iso}</updated>")
    end
  end

  File.write(feed_path, content)
end
