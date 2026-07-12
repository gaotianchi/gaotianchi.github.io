# Add class="external-link" to <a> tags pointing to external domains.
# Internal links (relative paths, same domain, anchors) are left unchanged.
Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  next if item.output.nil? || item.output.empty?

  site_host = item.site.config["url"]&.sub(%r{^https?://}, "")&.sub(%r{/$}, "")
  next unless site_host

  item.output = item.output.gsub(/<a\s+([^>]*?)>/i) do |_match|
    attrs = $1
    href_match = attrs.match(/\bhref="([^"]+)"/i)
    next _match unless href_match

    href = href_match[1]
    next _match unless href.start_with?("http://", "https://")
    next _match if attrs.match?(/\bexternal-link\b/)

    link_host = href.sub(%r{^https?://}, "").split("/").first
    next _match if link_host == site_host || link_host == "www.#{site_host}"

    # Merge with existing class attribute or add new one
    if attrs.match?(/\bclass="/i)
      next _match if attrs.match?(/\bexternal-link\b/)
      "<a #{attrs.sub(/\bclass="([^"]*)"/i, 'class="\1 external-link"')}>"
    else
      "<a class=\"external-link\" #{attrs}>"
    end
  end
end
