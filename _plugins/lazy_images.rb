# Add loading="lazy" to all <img> tags in rendered output
Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  next if item.output.nil? || item.output.empty?
  item.output = item.output.gsub(/<img(?!.*loading=)/, '<img loading="lazy"')
end
