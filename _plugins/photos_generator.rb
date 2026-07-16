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

  class PhotosGenerator < Generator
    safe false
    priority :low

    THUMB_WIDTH  = 400
    THUMB_QUALITY = 80
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

        photos = Dir.entries(thumbs_dir)
          .select { |f| f.match?(/\.(jpg|jpeg|png|webp|gif)$/i) }
          .sort

        next if photos.empty?

        { 'date' => entry[:date], 'dir' => entry[:dir], 'photos' => photos }
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
      FileUtils.mkdir_p(thumbs_dir)

      image_exts = %w[.jpg .jpeg .png .webp .gif]
      image_files = Dir.entries(dir)
        .select { |f| image_exts.include?(File.extname(f).downcase) }

      image_files.each do |filename|
        src  = File.join(dir, filename)
        base = File.basename(filename, File.extname(filename))
        dest = File.join(thumbs_dir, "#{base}.jpg")

        # Generate thumbnail if missing or outdated
        unless File.exist?(dest) && File.mtime(dest) >= File.mtime(src)
          begin
            require 'mini_magick'
            image = MiniMagick::Image.open(src)
            image.resize "#{THUMB_WIDTH}x#{THUMB_WIDTH}>"
            image.quality THUMB_QUALITY
            image.write dest
            Jekyll.logger.info "Photos:", "Generated #{dest}"
          rescue LoadError
            Jekyll.logger.warn "Photos:", "mini_magick not installed."
            return
          rescue => e
            Jekyll.logger.warn "Photos:", "Failed: #{filename} — #{e.message}"
            next
          end
        end

        # Register thumbnail as static file (whether newly generated or pre-existing)
        site.static_files << StaticFile.new(site, site.source,
                                            "_photos/#{dir_name}/thumbs",
                                            "#{base}.jpg")

        # Register original photo as static file
        site.static_files << StaticFile.new(site, site.source,
                                            "_photos/#{dir_name}",
                                            filename)
      end
    end
  end
end
