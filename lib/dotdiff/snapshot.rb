module DotDiff
  class Snapshot
    include Image::Cropper

    attr_reader :base_filename, :subdir, :rootdir

    IMAGE_EXT = 'png'.freeze

    def initialize(base_filename, subdir = nil, rootdir = DotDiff.image_store_path)
      @base_filename = base_filename
      @subdir = subdir.to_s
      @rootdir = rootdir.to_s
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
  end
end
