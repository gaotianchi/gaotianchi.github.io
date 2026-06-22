# Strips tag-originated <category> elements from the feed, keeping only the
# genuine category from post front-matter.
Jekyll::Hooks.register :site, :post_write do |site|
  feed_path = File.join(site.dest, "feed.xml")
  next unless File.exist?(feed_path)

  content = File.read(feed_path)

  # Within each <entry>…</entry>, keep only the first <category /> and
  # remove all subsequent ones (which are tags injected by jekyll-feed).
  content.gsub!(%r{(<entry[^>]*>.*?)(<category term="[^"]*" />)(.*?</entry>)}m) do
    pre  = Regexp.last_match(1)
    cat  = Regexp.last_match(2)
    rest = Regexp.last_match(3)
    # strip any remaining <category … /> from rest
    clean_rest = rest.gsub(%r{<category term="[^"]*" />\s*}, "")
    "#{pre}#{cat}#{clean_rest}"
  end

  File.write(feed_path, content)
end
