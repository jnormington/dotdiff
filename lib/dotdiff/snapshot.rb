module DotDiff
  class Snapshot
    include Image::Cropper

    attr_reader :base_filename, :subdir, :rootdir, :page

    IMAGE_EXT = 'png'.freeze

    def initialize(options = {})
      opts = { rootdir: DotDiff.image_store_path }.merge(Hash(options))
      @base_filename = opts[:filename]
      @subdir = opts[:subdir].to_s
      @rootdir = opts[:rootdir].to_s
      @page = opts[:page]
    end

    def fullscreen_file
      @fullscreen ||= File.join(Dir.tmpdir, subdir, base_filename)
    end

    def cropped_file
      @cropped ||= File.join(Dir.tmpdir, subdir, "#{base_filename(false)}_cropped.#{IMAGE_EXT}")
    end

    def basefile
      File.join(rootdir, subdir.to_s, base_filename)
    end

    def base_filename(with_extention=true)
      filename  = File.basename(@base_filename)
      extension = File.extname(filename)
      rtn_file  = @base_filename

      if with_extention
        rtn_file = "#{@base_filename}.#{IMAGE_EXT}" if extension.empty?
      else
        rtn_file = @base_filename.sub(ext, '') unless extension.empty?
      end

      rtn_file
    end

    def capture_from_browser(hide_and_show = true, element_handler = ElementHandler.new(page))
      if hide_and_show
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

      if !File.exists?(basefile) || DotDiff.overwrite_on_resave
        FileUtils.mv(self.send("#{version}_file"), basefile, force: true)
      else
        FileUtils.mv(self.send("#{version}_file"), "#{basefile}.r2", force: true)
      end
    end
  end
end
