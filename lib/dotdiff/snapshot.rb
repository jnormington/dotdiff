# frozen_string_literal: true

module DotDiff
  class Snapshot
    include Image::Cropper

    attr_reader :subdir, :rootdir, :page, :use_custom_screenshot

    IMAGE_EXT = 'png'

    def initialize(options = {})
      opts = { rootdir: DotDiff.image_store_path }.merge(Hash(options))
      @base_filename = opts[:filename]
      @subdir = opts[:subdir].to_s
      @rootdir = opts[:rootdir].to_s
      @page = opts[:page]
      @fullscreen_file = opts[:fullscreen_file]
      @use_custom_screenshot = opts[:use_custom_screenshot]
    end

    def fullscreen_file
      @fullscreen_file ||= File.join(Dir.tmpdir, subdir, base_filename)
    end

    def cropped_file
      @cropped_file ||= File.join(Dir.tmpdir, subdir, "#{base_filename(false)}_cropped.#{IMAGE_EXT}")
    end

    def basefile
      File.join(rootdir, subdir.to_s, base_filename)
    end

    def base_filename(with_extension = true)
      filename  = File.basename(@base_filename)
      extension = File.extname(filename)
      rtn_file  = @base_filename

      if with_extension
        rtn_file = "#{@base_filename}.#{IMAGE_EXT}" if extension.empty?
      else
        rtn_file = @base_filename.sub(extension, '') unless extension.empty?
      end

      rtn_file
    end

    def failure_path
      File.join(DotDiff.failure_image_path.to_s, subdir)
    end

    def new_file
      File.join(failure_path, "#{base_filename(false)}.new.#{IMAGE_EXT}")
    end

    def diff_file
      File.join(failure_path, "#{base_filename(false)}.diff.#{IMAGE_EXT}")
    end

    def capture_from_browser(hide_and_show)
      return fullscreen_file if use_custom_screenshot

      if hide_and_show
        element_handler = ElementHandler.new(page)

        element_handler.hide
        page.save_screenshot(fullscreen_file)
        element_handler.show
      else
        page.save_screenshot(fullscreen_file)
      end
    end

    def resave_cropped_file
      resave_base_file(:cropped)
    end

    def resave_fullscreen_file
      resave_base_file(:fullscreen)
    end

    private

    def resave_base_file(version)
      FileUtils.mkdir_p(File.join(DotDiff.image_store_path, subdir))

      if !File.exist?(basefile) || DotDiff.overwrite_on_resave
        FileUtils.mv(send("#{version}_file"), basefile, force: true)
      else
        FileUtils.mv(send("#{version}_file"), "#{basefile}.r2", force: true)
      end
    end
  end
end
