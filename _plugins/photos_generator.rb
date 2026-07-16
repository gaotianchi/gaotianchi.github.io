# frozen_string_literal: true

# Locate ImageMagick across platforms. Committed display images already carry
# watermarks, so CI builds never call ImageMagick — it is only needed when a
# new photo is added locally without pre-generated derivatives.
IMAGEMAGICK_PATHS = ([
  Dir.glob('C:/Program Files/ImageMagick*').map { |d| d.tr('\\', '/') },
  '/usr/bin',
  '/usr/local/bin',
  '/opt/homebrew/bin'
].flatten + ['C:/Program Files/ImageMagick']).freeze

MAGICK_DIR = IMAGEMAGICK_PATHS.find { |d| Dir.exist?(d) }

if MAGICK_DIR
  begin
    require 'mini_magick'
    MiniMagick.configure do |config|
      config.cli = :imagemagick
      config.cli_path = MAGICK_DIR
    end
  rescue LoadError
    # mini_magick not available — new photos will skip thumbnail/display generation
  end
end

# Shared constants (DRY — defined once, referenced everywhere)
DATE_REGEX  = /\A(\d{4})-(\d{1,2})-(\d{1,2})\z/
IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp .gif].freeze
IMAGE_REGEX = /\.(jpg|jpeg|png|webp|gif)$/i

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

    THUMB_WIDTH     = 400
    THUMB_QUALITY   = 80
    DISPLAY_WIDTH   = 1600
    DISPLAY_QUALITY = 75
    WATERMARK_TEXT  = 'www.gaotianchi.com'
    PER_PAGE = 5

    def generate(site)
      # Remove stale photography pages (prevents duplicates during regeneration)
      site.pages.reject! { |p| p.is_a?(PhotoPage) }

      # Check mini_magick availability once, early — avoids repeated failures in the loop
      magick_available = defined?(MiniMagick) && MAGICK_DIR
      unless magick_available
        Jekyll.logger.warn "Photos:", "ImageMagick not found — new photos will lack thumbnails/display/watermark."
        Jekyll.logger.warn "Photos:", "Searched: #{IMAGEMAGICK_PATHS.join(', ')}"
      end

      photos_dir = File.join(site.source, '_photos')

      unless Dir.exist?(photos_dir)
        site.pages << PhotoPage.new(site, 1, [], 1)
        return
      end

      # Scan for date directories, normalize format
      date_entries = []
      Dir.entries(photos_dir).each do |d|
        m = d.match(DATE_REGEX)
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
        generate_thumbnails(site, entry[:path], entry[:dir], magick_available)

        thumbs_dir = File.join(entry[:path], 'thumbs')
        next unless Dir.exist?(thumbs_dir)

        filenames = Dir.entries(thumbs_dir)
          .select { |f| f.match?(IMAGE_REGEX) }
          .sort

        next if filenames.empty?

        # Build complete URLs + dimensions for aspect-ratio skeleton placeholders.
        photos = filenames.map do |f|
          thumb_path = File.join(entry[:path], 'thumbs', f)
          w, h = read_jpeg_dimensions(thumb_path) || [400, 300]
          {
            'thumb'   => "/_photos/#{entry[:dir]}/thumbs/#{f}",
            'display' => "/_photos/#{entry[:dir]}/display/#{f}",
            'w' => w,
            'h' => h
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

    # Pure-Ruby JPEG dimension reader — works without ImageMagick.
    # Returns [width, height] or [400, 300] on failure.
    def read_jpeg_dimensions(path)
      File.open(path, 'rb') do |f|
        return nil unless f.read(2).bytes == [0xFF, 0xD8] # SOI marker
        f.seek(2)
        while f.pos < f.size - 9
          b = f.read(2)
          break unless b&.bytesize == 2 && b[0].ord == 0xFF
          code = b[1].ord
          break if [0xDA, 0xD9].include?(code) # SOS or EOI
          seg_len = f.read(2)&.unpack1('n')
          break unless seg_len && seg_len >= 2
          if [0xC0, 0xC1, 0xC2].include?(code) # SOF markers
            data = f.read(5)
            h = data[1..2].unpack1('n')
            w = data[3..4].unpack1('n')
            return [w, h] if w && h && w > 0
          else
            f.seek(seg_len - 2, IO::SEEK_CUR)
          end
        end
      end
      nil
    rescue
      nil
    end

    def generate_thumbnails(site, dir, dir_name, magick_available)
      thumbs_dir  = File.join(dir, 'thumbs')
      display_dir = File.join(dir, 'display')
      FileUtils.mkdir_p(thumbs_dir)
      FileUtils.mkdir_p(display_dir)

      image_files = Dir.entries(dir)
        .select { |f| IMAGE_EXTENSIONS.include?(File.extname(f).downcase) }

      image_files.each do |filename|
        src  = File.join(dir, filename)
        base = File.basename(filename, File.extname(filename))
        thumb_dest   = File.join(thumbs_dir, "#{base}.jpg")
        display_dest = File.join(display_dir, "#{base}.jpg")

        # ── Dedup check ──
        thumb_current   = File.exist?(thumb_dest) &&
                          File.size(thumb_dest) > 0 &&
                          File.mtime(thumb_dest) >= File.mtime(src)
        display_current = File.exist?(display_dest) &&
                          File.size(display_dest) > 0 &&
                          File.mtime(display_dest) >= File.mtime(src)

        # ── Track per-file success — only register static files for generated variants ──
        thumb_ok   = thumb_current
        display_ok = display_current

        # ── Generate thumbnail ──
        unless thumb_current
          thumb_ok = if magick_available
                       begin
                         image = MiniMagick::Image.open(src)
                         image.auto_orient
                         image.resize "#{THUMB_WIDTH}x#{THUMB_WIDTH}>"
                         image.quality THUMB_QUALITY
                         image.write thumb_dest
                         Jekyll.logger.info "Photos:", "  → thumbnail #{File.basename(thumb_dest)}"
                         true
                       rescue => e
                         Jekyll.logger.warn "Photos:", "  ✗ thumbnail failed: #{filename} — #{e.message}"
                         false
                       end
                     else
                       false
                     end
        end

        # ── Generate display version + watermark ──
        unless display_current
          display_ok = if magick_available
                         begin
                           image = MiniMagick::Image.open(src)
                           image.auto_orient
                           image.resize "#{DISPLAY_WIDTH}x#{DISPLAY_WIDTH}>"
                           image.quality DISPLAY_QUALITY
                           image.write display_dest

                           # Watermark via ImageMagick mogrify (modifies file in-place)
                           font_size = [(image.width * 0.033).to_i, 18].max
                           magick = File.join(MAGICK_DIR, 'magick.exe')
                           magick = File.join(MAGICK_DIR, 'magick') unless File.exist?(magick)
                           unless system(magick, 'mogrify',
                                         '-gravity', 'southeast',
                                         '-fill', 'rgba(255,255,255,0.28)',
                                         '-pointsize', font_size.to_s,
                                         '-annotate', "+28+18", WATERMARK_TEXT,
                                         display_dest)
                             Jekyll.logger.warn "Photos:", "  ✗ watermark failed for #{File.basename(display_dest)}"
                           end

                           Jekyll.logger.info "Photos:", "  → display #{File.basename(display_dest)}"
                           true
                         rescue => e
                           Jekyll.logger.warn "Photos:", "  ✗ display failed: #{filename} — #{e.message}"
                           false
                         end
                       else
                         false
                       end
        end

        # ── Register static files only for successfully generated variants ──
        if thumb_ok
          site.static_files << StaticFile.new(site, site.source,
                                              "_photos/#{dir_name}/thumbs",
                                              "#{base}.jpg")
        end
        if display_ok
          site.static_files << StaticFile.new(site, site.source,
                                              "_photos/#{dir_name}/display",
                                              "#{base}.jpg")
        end
      end
    end
  end
end
