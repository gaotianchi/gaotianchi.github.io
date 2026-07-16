# frozen_string_literal: true

# Ensure ImageMagick is in PATH on Windows
imgmagick_paths = [
  'C:/Program Files/ImageMagick-7.1.2-Q16-HDRI',
  'C:/Program Files/ImageMagick'
]
imgmagick_paths.each do |p|
  if Dir.exist?(p) && !ENV['PATH'].include?(p)
    ENV['PATH'] = "#{p};#{ENV['PATH']}"
  end
end

module Jekyll
  # Programmatic page for photography — bypasses file reading
  class PhotoPage < Page
    def initialize(site, page_num, photos, total_pages)
      @site = site
      @base = site.source
      @dir  = ''
      @name = 'index.html'
      @path = File.join(site.source, @dir, @name)

      process(@name)

      permalink = page_num == 1 ? '/photography/' : "/photography/page/#{page_num}/"
      title_suffix = page_num == 1 ? '' : " · 第 #{page_num} 页"
      self.data = {
        'layout'       => 'photography',
        'title'        => "摄影#{title_suffix}",
        'photos'       => photos,
        'page_num'     => page_num,
        'total_pages'  => total_pages,
        'permalink'    => permalink,
        'description'  => '用镜头记录生活的瞬间'
      }
      self.content = ''
    end

    def read_yaml(*)
      # No-op: data is set manually in constructor
    end
  end

  # Ensure display/thumbs directories exist in _site before static files are written
  Jekyll::Hooks.register :site, :pre_render do |site|
    photos_dir = File.join(site.source, '_photos')
    next unless Dir.exist?(photos_dir)

    Dir.entries(photos_dir).each do |d|
      next unless d.match?(/\A\d{4}-\d{1,2}-\d{1,2}\z/)
      src = File.join(photos_dir, d)
      next unless File.directory?(src)

      %w[thumbs display].each do |sub|
        src_sub = File.join(src, sub)
        next unless Dir.exist?(src_sub)
        dst_sub = File.join(site.dest, '_photos', d, sub)
        FileUtils.mkdir_p(dst_sub)
      end
    end
  end

  class PhotosGenerator < Generator
    safe false
    priority :low

    THUMB_WIDTH   = 400
    THUMB_QUALITY = 80
    DISPLAY_WIDTH   = 1600
    DISPLAY_QUALITY = 75
    WATERMARK_TEXT  = 'www.gaotianchi.com'
    PER_PAGE = 5

    def generate(site)
      # Remove stale photography pages (prevents duplicates during regeneration)
      site.pages.reject! { |p| p.is_a?(PhotoPage) }

      photos_dir = File.join(site.source, '_photos')

      unless Dir.exist?(photos_dir)
        site.pages << PhotoPage.new(site, 1, [], 1)
        return
      end

      # Scan for date directories, normalize format
      date_entries = []
      Dir.entries(photos_dir).each do |d|
        m = d.match(/\A(\d{4})-(\d{1,2})-(\d{1,2})\z/)
        next unless m
        full = File.join(photos_dir, d)
        next unless File.directory?(full)
        normalized = format('%04d-%02d-%02d', m[1].to_i, m[2].to_i, m[3].to_i)
        date_entries << { dir: d, date: normalized, path: full }
      end
      date_entries.sort_by! { |e| e[:date] }.reverse!

      if date_entries.empty?
        site.pages << PhotoPage.new(site, 1, [], 1)
        return
      end

      photo_groups = date_entries.filter_map do |entry|
        generate_thumbnails(site, entry[:path], entry[:dir])

        thumbs_dir = File.join(entry[:path], 'thumbs')
        next unless Dir.exist?(thumbs_dir)

        filenames = Dir.entries(thumbs_dir)
          .select { |f| f.match?(/\.(jpg|jpeg|png|webp|gif)$/i) }
          .sort

        next if filenames.empty?

        # Build complete URLs in Generator so Liquid never needs to concatenate
        # path segments — eliminates the risk of group.dir being empty at render time.
        photos = filenames.map do |f|
          {
            'thumb'   => "/_photos/#{entry[:dir]}/thumbs/#{f}",
            'display' => "/_photos/#{entry[:dir]}/display/#{f}"
          }
        end

        { 'date' => entry[:date], 'photos' => photos }
      end

      if photo_groups.empty?
        site.pages << PhotoPage.new(site, 1, [], 1)
        return
      end

      total_pages = (photo_groups.size.to_f / PER_PAGE).ceil

      (1..total_pages).each do |page_num|
        start_idx = (page_num - 1) * PER_PAGE
        page_photos = photo_groups[start_idx, PER_PAGE]
        site.pages << PhotoPage.new(site, page_num, page_photos, total_pages)
      end
    end

    private

    def generate_thumbnails(site, dir, dir_name)
      thumbs_dir = File.join(dir, 'thumbs')
      display_dir = File.join(dir, 'display')
      FileUtils.mkdir_p(thumbs_dir)
      FileUtils.mkdir_p(display_dir)

      image_exts = %w[.jpg .jpeg .png .webp .gif]
      image_files = Dir.entries(dir)
        .select { |f| image_exts.include?(File.extname(f).downcase) }

      image_files.each do |filename|
        src  = File.join(dir, filename)
        base = File.basename(filename, File.extname(filename))
        thumb_dest   = File.join(thumbs_dir, "#{base}.jpg")
        display_dest = File.join(display_dir, "#{base}.jpg")

        # --- Dedup check: skip if destination exists, is not older than source,
        #     and has non-zero file size (guards against corrupted partial writes). ---
        thumb_current   = File.exist?(thumb_dest) &&
                          File.size(thumb_dest) > 0 &&
                          File.mtime(thumb_dest) >= File.mtime(src)
        display_current = File.exist?(display_dest) &&
                          File.size(display_dest) > 0 &&
                          File.mtime(display_dest) >= File.mtime(src)

        unless thumb_current && display_current
          Jekyll.logger.info "Photos:", "Processing #{filename}..."
        end

        # Generate thumbnail if needed
        unless thumb_current
          begin
            require 'mini_magick'
            image = MiniMagick::Image.open(src)
            image.resize "#{THUMB_WIDTH}x#{THUMB_WIDTH}>"
            image.quality THUMB_QUALITY
            image.write thumb_dest
            Jekyll.logger.info "Photos:", "  → thumbnail #{thumb_dest}"
          rescue LoadError
            Jekyll.logger.warn "Photos:", "mini_magick not installed."
            return
          rescue => e
            Jekyll.logger.warn "Photos:", "  ✗ failed: #{filename} — #{e.message}"
            next
          end
        end

        # Generate display version if needed
        unless display_current
          begin
            require 'mini_magick'
            image = MiniMagick::Image.open(src)
            image.resize "#{DISPLAY_WIDTH}x#{DISPLAY_WIDTH}>"
            image.quality DISPLAY_QUALITY
            # Watermark: subtle, bottom-right, semi-transparent white
            font_size = [(image.width * 0.033).to_i, 18].max
            image.combine_options do |c|
              c.gravity 'southeast'
              c.fill 'rgba(255,255,255,0.28)'
              c.pointsize font_size
              c.annotate '+28+18', WATERMARK_TEXT
            end
            image.write display_dest
            Jekyll.logger.info "Photos:", "  → display #{display_dest}"
          rescue => e
            Jekyll.logger.warn "Photos:", "  ✗ display failed: #{filename} — #{e.message}"
          end
        end

        # Register thumbnail as static file
        site.static_files << StaticFile.new(site, site.source,
                                            "_photos/#{dir_name}/thumbs",
                                            "#{base}.jpg")

        # Register display version as static file
        site.static_files << StaticFile.new(site, site.source,
                                            "_photos/#{dir_name}/display",
                                            "#{base}.jpg")
      end
    end
  end
end
