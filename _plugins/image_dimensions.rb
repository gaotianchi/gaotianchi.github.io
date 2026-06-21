# frozen_string_literal: true

# Pure Ruby image dimension reader — PNG, JPEG, GIF, WebP.
# Adds width/height to <img> tags, eliminating layout shift as images load.
module Jekyll
  module ImageDimensions
    def self.read(filepath)
      return nil unless File.exist?(filepath) && File.size(filepath) > 32

      File.open(filepath, "rb") do |f|
        header = f.read(32)
        ext = File.extname(filepath).downcase

        case ext
        when ".png"
          return nil unless header[0..7].bytes == [137, 80, 78, 71, 13, 10, 26, 10]
          [header[16..19].unpack1("N"), header[20..23].unpack1("N")]
        when ".jpg", ".jpeg"
          f.seek(2)
          while f.pos < f.size - 8
            b = f.read(2)
            break if b.nil? || b.bytesize < 2
            break unless b[0].ord == 0xFF
            code = b[1].ord
            break if code == 0xDA
            if [0xC0, 0xC1, 0xC2].include?(code)
              seg = f.read(7)
              h = seg[1..2].unpack1("n")
              w = seg[3..4].unpack1("n")
              return [w, h] if w && h && w > 0
            end
            len = f.read(2).unpack1("n")
            break if len.nil? || len < 2
            f.seek(len - 2, IO::SEEK_CUR)
          end
          nil
        when ".gif"
          [header[6..7].unpack1("v"), header[8..9].unpack1("v")]
        when ".webp"
          return nil unless header[0..3] == "RIFF" && header[8..11] == "WEBP"
          case header[12..15]
          when "VP8 "
            [(header[26..27].unpack1("v") & 0x3FFF), (header[28..29].unpack1("v") & 0x3FFF)]
          when "VP8L"
            bits = header[21..24].unpack1("V")
            [(bits & 0x3FFF) + 1, ((bits >> 14) & 0x3FFF) + 1]
          when "VP8X"
            [(header[24..26].unpack1("V") & 0xFFFFFF) + 1,
             ((header[27..29].unpack1("V") >> 0) & 0xFFFFFF) + 1]
          end
        end
      end
    rescue
      nil
    end
  end

  Hooks.register [:pages, :documents], :post_render do |item|
    next if item.output.nil? || item.output.empty?

    # Base directory: for posts in subdirectories, resolve relative to the
    # post file's directory; for pages, resolve relative to site source.
    src_base = if item.respond_to?(:collection) && item.collection.label == "posts"
                 File.dirname(item.path)
               else
                 item.site.source
               end

    img_re = %r{<img\s+([^>]*?)>}i

    item.output = item.output.gsub(img_re) do |_match|
      attrs = $1
      src_match = attrs.match(/\bsrc="([^"]+)"/)
      next _match unless src_match

      src = src_match[1]
      next _match if src.start_with?("http://", "https://", "data:")

      # Build absolute path to the image file
      img_path = if src.start_with?("/")
                   File.join(item.site.source, src.sub(%r{^/}, ""))
                 else
                   File.join(src_base, src)
                 end

      modified = attrs.dup

      # Add width/height if missing
      unless modified.match?(/\bwidth=/)
        dims = ImageDimensions.read(img_path)
        if dims
          modified = "width=\"#{dims[0]}\" height=\"#{dims[1]}\" #{modified}"
        end
      end

      # Add loading=lazy if missing
      modified = "loading=\"lazy\" #{modified}" unless modified.match?(/\bloading=/)

      "<img #{modified}>"
    end
  end
end
